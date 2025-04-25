module vm

import code
import compiler
import object

const stack_size = 2048

// VM 虚拟机结构体
pub struct VM {
pub mut:
	builtin      &object.Scope
	running      &object.ClosureFunction = unsafe { nil }
	constants    []object.Object
	instructions []code.Instruction

	stack   []object.Object
	globals []object.Object
}

// exec 方法执行机器指令集
pub fn (mut v VM) exec(instructions []code.Instruction) ! {
	mut pos := 0
	for pos < instructions.len {
		ins := instructions[pos]
		match ins.code {
			.nop {}
			.const {
				idx := ins.operands[0]
				v.push(v.constants[idx])!
			}
			.pop {
				v.pop()!
			}
			.add, .sub, .mul, .div, .range {
				right := v.pop()!
				left := v.pop()!

				if ins.code == .add {
					v.push(left.add(right)!)!
				} else if ins.code == .sub {
					v.push(left.sub(right)!)!
				} else if ins.code == .mul {
					v.push(left.mul(right)!)!
				} else if ins.code == .div {
					v.push(left.div(right)!)!
				} else if ins.code == .range {
					v.push(object.Range{
						datatype: .range
						start:    (left as object.Int).value
						end:      (right as object.Int).value
					})!
				}
			}
			.negate {
				right := v.pop()!
				v.push(right.negate()!)!
			}
			.negative {
				right := v.pop()!
				v.push(right.negative()!)!
			}
			.more_than, .more_or_equal, .equal, .not_equal {
				right := v.pop()!
				left := v.pop()!

				if ins.code == .more_than {
					v.push(left.more_than(right)!)!
				} else if ins.code == .more_or_equal {
					v.push(left.more_or_equal(right)!)!
				} else if ins.code == .equal {
					v.push(left.equal(right)!)!
				} else if ins.code == .not_equal {
					v.push(left.not_equal(right)!)!
				}
			}
			.jmp {
				pos = ins.operands[0] - 1
			}
			.jnt {
				if v.pop()! == object.only_false {
					pos = ins.operands[0] - 1
				}
			}
			.list {
				mut elems := []object.Object{}
				for i := 0; i < ins.operands[0]; i++ {
					elems << v.pop()!
				}

				v.push(object.List{
					datatype: .list
					elems:    elems.reverse()
				})!
			}
			.table {
				mut pairs := map[u64][]object.Object{}
				for i := 0; i < ins.operands[0]; i++ {
					value := v.pop()!
					key := v.pop()!

					pairs[key.hash()!] = [key, value]
				}

				v.push(object.Table{
					datatype: .table
					pairs:    pairs
				})!
			}
			.set_global {
				idx := ins.operands[0]
				if v.globals.len == idx {
					v.globals << v.pop()!
				} else {
					v.globals[idx] = v.pop()!
				}
			}
			.get_global {
				idx := ins.operands[0]
				v.push(v.globals[idx])!
			}
			.set_local {
				idx := ins.operands[0]
				v.stack[idx] = v.pop()!
			}
			.get_local {
				idx := ins.operands[0]
				v.push(v.stack[idx])!
			}
			.index_get {
				index := v.pop()!
				left := v.pop()!

				obj := left.get(index) or {
					if index is object.String {
						now_err := err
						v.builtin.get('${left.datatype}.${index.value}') or { return now_err }
					} else {
						return err
					}
				}
				v.push(obj)!
			}
			.index_set {
				index := v.pop()!
				mut left := v.pop()!
				value := v.pop()!

				left.set(index, value)!
			}
			.index_has {
				right := v.pop()!
				left := v.pop()!
        v.push(right.has(left)!)!
			}
			.call {
				mut params := []object.Object{}
				for _ in 0 .. ins.operands[0] {
					params << v.pop()!
				}

				callable := v.pop()!
				if callable is object.ClosureFunction {
					func := callable.func
					running := v.running

					mut stack := v.stack.clone()
					v.running = callable

					v.stack = params.reverse()
					for _ in 0 .. func.num_local {
						v.stack << object.only_null
					}
					v.exec(func.instructions)!

					if v.stack.len > (func.num_local + ins.operands[0]) {
						stack << v.pop()!
					} else {
						stack << object.only_null
					}
					v.stack = stack
					v.running = running
				} else if callable is object.BuiltinFunction {
					v.push(callable.func(...params.reverse())!)!
				}
			}
			.return {
				break
			}
			.closure {
				func := v.constants[ins.operands[0]]
				mut frees := []object.Object{}

				for _ in 0 .. ins.operands[1] {
					frees << v.pop()!
				}

				v.push(object.ClosureFunction{
					datatype: .function
					func:     &(func as object.CompiledFunction)
					frees:    frees.reverse()
				})!
			}
			.get_free {
				obj := v.running.frees[ins.operands[0]]
				v.push(obj)!
			}
		}

		pos++
	}
}

// run 方法启动虚拟机
pub fn (mut v VM) run() ! {
	v.exec(v.instructions)!
}

// push方法将一个元素压栈
fn (mut v VM) push(obj object.Object) ! {
	if v.stack.len == stack_size {
		return error('栈空间不足')
	}
	v.stack << obj
}

// pop方法让一个元素出栈
fn (mut v VM) pop() !object.Object {
	if v.stack.len == 0 {
		return error('当前栈内容为空')
	}
	obj := v.stack.last()
	v.stack.delete_last()
	return obj
}

// new 函数创建并返回一个虚拟机对象
pub fn new(bytecode compiler.Bytecode) &VM {
	return &VM{
		builtin:      bytecode.builtin
		constants:    bytecode.constants
		instructions: bytecode.instructions
		stack:        []object.Object{cap: stack_size}
	}
}

// new_with_state 函数创建并返回一个虚拟机对象
pub fn new_with_state(bytecode compiler.Bytecode, globals []object.Object) &VM {
	return &VM{
		builtin:      bytecode.builtin
		constants:    bytecode.constants
		instructions: bytecode.instructions
		stack:        []object.Object{cap: stack_size}
		globals:      globals
	}
}
