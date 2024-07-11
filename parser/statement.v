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
