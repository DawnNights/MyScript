module parser

import ast

// parse_expr_statement 方法解析一个表达式语句并返回相应的节点
// 表达式语句是一个对表达式的语句封装
fn (mut p Parser) parse_expr_statement() !&ast.ExpressionStatement {
	stmt := ast.ExpressionStatement{
		token: p.cur
		expression: p.parse_expression(.lowest)!
	}

	// 如果表达式后有分号则跳过
	if p.next.t_type == .semicolon_symbol {
		p.shift_token(1)!
	}

	return &stmt
}

// parse_block_statement 方法解析一个代码块语句并返回相应的节点
// 代码块语句是由大括号括起来的多条语句组成的序列
fn (mut p Parser) parse_block_statement() !&ast.BlockStatement {
	mut stmt := ast.BlockStatement{
		token: p.cur
	}
	p.shift_token(1)!

	for p.cur.t_type != .right_brace {
		if p.cur.t_type == .end {
			return error('代码块语句未闭合, 请在表达式末尾添加 "}" 使之完整')
		}

		stmt.body << p.parse_statement()!
		p.shift_token(1)!
	}

	return &stmt
}

// parse_return_statement 方法解析一个返回语句并返回相应的节点
// 返回语句用于从函数或方法中返回结果
fn (mut p Parser) parse_return_statement() !&ast.ReturnStatement {
	if 'FUNCTION' !in p.context {
		return error('return 语句必须在函数体内使用')
	}

	mut stmt := ast.ReturnStatement{
		token: p.cur
		value: unsafe { nil }
	}

	// 获取返回值的表达式
	p.shift_token(1)!
	stmt.value = p.parse_expression(.lowest)!

	// 如果表达式后有分号则跳过
	if p.next.t_type == .semicolon_symbol {
		p.shift_token(1)!
	}

	return &stmt
}

// parse_for_statement 方法解析一个遍历语句并返回相应的节点
fn (mut p Parser) parse_for_statement() !&ast.ForStatement {
	mut stmt := ast.ForStatement{
		token: p.cur
		name: unsafe { nil }
		list: unsafe { nil }
		block: unsafe { nil }
	}

	// 判断是否有左侧圆括号
	if p.next.t_type != .left_paren {
		return error(r'for 语句的赋值表达式应在完整的 "()" 中')
	}
	p.shift_token(1)!

	// 解析赋值表达式
	if p.next.t_type != .ident {
		return error('"${p.next.t_raw}" 不是一个合理的标识符字面量')
	}

	p.shift_token(1)!
	stmt.name = &ast.Identifier{
		token: p.cur
		name: p.cur.t_raw
	}

	if p.next.t_type != .@in {
		return error('for 语句的赋值表达式中缺少关键字 `in`')
	}

	p.shift_token(2)!
	stmt.list = p.parse_expression(.lowest)!

	// 判断是否有右侧圆括号
	if p.next.t_type != .right_paren {
		return error(r'for 语句的赋值表达式未闭合, 请在表达式末尾添加 ")" 使之完整')
	}
	p.shift_token(1)!

	// 判断是否有左侧大括号
	if p.next.t_type != .left_brace {
		return error(r'for 语句的执行的代码块内容应在完整的 "{}" 中')
	}
	p.shift_token(1)!
	stmt.block = p.parse_block_statement()!

	// 如果表达式后有分号则跳过
	if p.next.t_type == .semicolon_symbol {
		p.shift_token(1)!
	}

	return &stmt
}

// parse_while_statement 方法解析一个循环语句并返回相应的节点
fn (mut p Parser) parse_while_statement() !&ast.WhileStatement {
	mut stmt := ast.WhileStatement{
		token: p.cur
		condition: unsafe { nil }
		block: unsafe { nil }
	}

	// 判断是否有左侧圆括号
	if p.next.t_type != .left_paren {
		return error(r'while 语句的条件表达式应在完整的 "()" 中')
	}
	p.shift_token(2)!

	// 解析条件表达式
	stmt.condition = p.parse_expression(.lowest)!

	// 判断是否有右侧圆括号
	if p.next.t_type != .right_paren {
		return error(r'while 语句的条件表达式未闭合, 请在表达式末尾添加 ")" 使之完整')
	}
	p.shift_token(1)!

	// 判断是否有左侧大括号
	if p.next.t_type != .left_brace {
		return error(r'while 语句执行的代码块内容应在完整的 "{}" 中')
	}
	p.shift_token(1)!
	stmt.block = p.parse_block_statement()!

	// 如果表达式后有分号则跳过
	if p.next.t_type == .semicolon_symbol {
		p.shift_token(1)!
	}

	return &stmt
}
