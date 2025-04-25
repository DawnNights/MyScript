module compiler

import ast
import code
import object
import object.builtin

// Compiler 编译器结构体
pub struct Compiler {
mut:
	// 机器指令序列
	instructions []code.Instruction

	// 常量对象池
	constants []object.Object

	// 全局符号表
	symbol_table SymbolTable

	// 内置函数作用域
	builtin &object.Scope
}

// Bytecode 字节码结构体
pub struct Bytecode {
pub:
	// 机器指令序列
	instructions []code.Instruction

	// 常量对象池
	constants []object.Object

	// 全局符号表
	symbol_table SymbolTable

	// 内置函数作用域
	builtin &object.Scope
}

// compile 方法将 ast 节点编译为指令
pub fn (mut c Compiler) compile(node ast.Node) ! {
	match node {
		ast.Program {
			for s in node.body {
				c.compile(s as ast.Node)!
			}
		}
		ast.ExpressionStatement {
			c.compile(node.expression as ast.Node)!
		}
		ast.BlockStatement {
			for s in node.body {
				c.compile(s as ast.Node)!
			}
		}
		ast.ReturnStatement {
			c.compile(node.value as ast.Node)!
			c.emit(.return)
		}
		ast.PrefixExpression {
			c.compile_prefix_expression(node)!
		}
		ast.InfixExpression {
			c.compile_infix_expression(node)!
		}
		ast.IfExpression {
			c.compile_if_expression(node)!
		}
		ast.IndexExpression {
			c.compile(node.left as ast.Node)!
			c.compile(node.index as ast.Node)!
			c.emit(.index_get)
		}
		ast.MemberExpression {
			c.compile_member_expression(node)!
		}
		ast.CallExpression {
			c.compile_call_expression(node)!
		}
		ast.Identifier {
			if node.name == 'null' {
				c.emit(.const, c.add_constant(object.only_null))
				return
			}

			if node.name in c.builtin.store {
				c.emit(.const, c.add_constant(c.builtin.get(node.name)!))
				return
			}

			symbol := c.symbol_table.lookup(node.name)
			if symbol != none {
				c.emit(symbol.opcode(), symbol.index)
			} else {
				return error('标识符 "${node.name}" 未定义')
			}
		}
		ast.Bool {
			if node.value {
				c.emit(.const, c.add_constant(object.only_true))
			} else {
				c.emit(.const, c.add_constant(object.only_false))
			}
		}
		ast.Int {
			c.emit(.const, c.add_constant(object.Int{
				datatype: .int
				value:    node.value
			}))
		}
		ast.Float {
			c.emit(.const, c.add_constant(object.Float{
				datatype: .float
				value:    node.value
			}))
		}
		ast.Char {
			c.emit(.const, c.add_constant(object.Char{
				datatype: .char
				value:    node.value
			}))
		}
		ast.String {
			c.emit(.const, c.add_constant(object.new_string(node.value)))
		}
		ast.List {
			for elem in node.elems {
				c.compile(elem as ast.Node)!
			}
			c.emit(.list, node.elems.len)
		}
		ast.Table {
			for pair in node.pairs {
				c.compile(pair[0] as ast.Node)!
				c.compile(pair[1] as ast.Node)!
			}
			c.emit(.table, node.pairs.len)
		}
		ast.Function {
			mut instructions := c.instructions.clone()
			symbol_table := c.symbol_table

			c.instructions.clear()
			c.symbol_table = SymbolTable{
				parent: &symbol_table
			}

			for p in node.params {
				c.symbol_table.define(p.name)
			}
			c.compile(node.body)!

			frees := c.symbol_table.frees
			for s in frees {
				instructions << code.Instruction{
					code:     s.opcode()
					operands: [s.index]
				}
			}

			obj := object.CompiledFunction{
				datatype:     .function
				params:       node.params
				instructions: c.instructions
				num_local:    c.symbol_table.data.len - node.params.len
			}

			c.instructions = instructions
			c.symbol_table = symbol_table

			idx := c.add_constant(obj)
			c.emit(.closure, idx, frees.len)
			if node.name != unsafe { nil } {
				symbol := c.symbol_table.define(node.name.name)
				if symbol.scope == .global {
					c.emit(.set_global, symbol.index)
				} else {
					c.emit(.set_local, symbol.index)
				}
			}
		}
		else {}
	}
}

// compile_prefix_expression 方法编译前缀表达式
fn (mut c Compiler) compile_prefix_expression(node ast.PrefixExpression) ! {
	operator := node.token.t_raw
	c.compile(node.right as ast.Node)!

	match operator {
		'-' {
			c.emit(.negative)
		}
		'!' {
			c.emit(.negate)
		}
		else {
			return error("操作符 '${operator}' 尚未定义")
		}
	}
}

// compile_infix_expression 方法编译中缀表达式
fn (mut c Compiler) compile_infix_expression(node ast.InfixExpression) ! {
	operator := node.token.t_raw
	if operator == '=' {
		return c.compile_assign_expression(node)
	}
	if operator == '<' || operator == '<=' {
		c.compile(node.right as ast.Node)!
		c.compile(node.left as ast.Node)!
	} else {
		c.compile(node.left as ast.Node)!
		c.compile(node.right as ast.Node)!
	}
	match operator {
		'+' {
			c.emit(.add)
		}
		'-' {
			c.emit(.sub)
		}
		'*' {
			c.emit(.mul)
		}
		'/' {
			c.emit(.div)
		}
		'..' {
			c.emit(.range)
		}
		'>', '<' {
			c.emit(.more_than)
		}
		'>=', '<=' {
			c.emit(.more_or_equal)
		}
		'==' {
			c.emit(.equal)
		}
		'!=' {
			c.emit(.not_equal)
		}
		'in' {
			c.emit(.index_has)
		}
		else {
			return error("操作符 '${operator}' 尚未定义")
		}
	}
}

// compile_assign_expression 方法编译赋值表达式
fn (mut c Compiler) compile_assign_expression(node ast.InfixExpression) ! {
	if node.left is ast.Identifier {
		name := node.left.name
		symbol := c.symbol_table.define(name)

		c.compile(node.right as ast.Node)!
		if symbol.scope == .global {
			c.emit(.set_global, symbol.index)
		} else {
			c.emit(.set_local, symbol.index)
		}
	} else if node.left is ast.IndexExpression {
		c.compile(node.right as ast.Node)!

		c.compile(node.left.left as ast.Node)!
		c.compile(node.left.index as ast.Node)!
		c.emit(.index_set)
	} else if node.left is ast.MemberExpression {
		c.compile(node.right as ast.Node)!

		c.compile(node.left.self as ast.Node)!
		c.compile(node.left.member as ast.Node)!
		c.emit(.index_set)
	} else {
		return error('${node.left} 不是一个可赋值对象')
	}
}

// compile_if_expression 方法编译判断表达式
fn (mut c Compiler) compile_if_expression(node ast.IfExpression) ! {
	c.compile(node.condition as ast.Node)!

	mut idx := c.emit(.nop)
	c.compile(node.if_true)!

	if node.if_false == unsafe { nil } {
		c.instructions[idx] = code.Instruction{
			code:     .jnt
			operands: [c.instructions.len]
		}
	} else {
		c.instructions[idx] = code.Instruction{
			code:     .jnt
			operands: [c.instructions.len + 1]
		}

		idx = c.emit(.nop)
		c.compile(node.if_false)!
		c.instructions[idx] = code.Instruction{
			code:     .jmp
			operands: [c.instructions.len]
		}
	}
}

// compile_member_expression 方法编译成员表达式
fn (mut c Compiler) compile_member_expression(node ast.MemberExpression) ! {
	c.compile(node.self as ast.Node)!

	if node.member is ast.String {
		c.emit(.const, c.add_constant(object.new_string(node.member.value)))
		c.emit(.index_get)
	} else if node.member is ast.CallExpression {
		ident := node.member.callable as ast.Identifier
		c.emit(.const, c.add_constant(object.new_string(ident.name)))
		c.emit(.index_get)
		for arg in node.member.arguments {
			c.compile(arg as ast.Node)!
		}
		c.emit(.call, node.member.arguments.len)
	}
}

// compile_call_expression 方法编译调用表达式
fn (mut c Compiler) compile_call_expression(node ast.CallExpression) ! {
	c.compile(node.callable as ast.Node)!
	for arg in node.arguments {
		c.compile(arg as ast.Node)!
	}
	c.emit(.call, node.arguments.len)
}

// bytecode 方法编译返回字节码
pub fn (mut c Compiler) bytecode() &Bytecode {
	return &Bytecode{
		instructions: c.instructions
		constants:    c.constants
		symbol_table: c.symbol_table
		builtin:      c.builtin
	}
}

// add_constant 方法添加对象至常量池并返回索引
fn (mut c Compiler) add_constant(obj object.Object) int {
	idx := c.constants.index(obj)
	if idx != -1 {
		return idx
	}

	c.constants << obj
	return c.constants.len - 1
}

// add_instruction 方法添加指令至指令池并返回索引
fn (mut c Compiler) add_instruction(ins code.Instruction) int {
	c.instructions << ins
	return c.instructions.len - 1
}

// emit 方法发出指令并返回索引
fn (mut c Compiler) emit(op code.Opcode, operands ...int) int {
	return c.add_instruction(code.Instruction{
		code:     op
		operands: operands
	})
}

// new 函数创建并返回一个编译器对象
pub fn new() &Compiler {
	return &Compiler{
		builtin: builtin.get_builtin_scope()
	}
}

// new_with_state 函数创建并返回一个编译器对象
pub fn new_with_state(symbol_table SymbolTable, constants []object.Object) &Compiler {
	return &Compiler{
		instructions: []code.Instruction{}
		constants:    constants
		symbol_table: symbol_table
		builtin:      builtin.get_builtin_scope()
	}
}
