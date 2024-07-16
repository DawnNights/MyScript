module parser

import ast

// parse_group_expression 方法解析分组表达式并返回相应的节点
// 分组表达式使用括号来显式指定运算优先级, 如 (1 + 1) * 1
fn (mut p Parser) parse_group_expression() !ast.Expression {
	p.shift_token(1)!
	expr := p.parse_expression(.lowest)!

	if p.next.t_type != .right_paren {
		return error(r'分组表达式未闭合, 请在表达式末尾添加 ")" 使之完整')
	}
	p.shift_token(1)!

	return expr
}

// parse_prefix_expression 方法解析前缀表达式并返回相应的节点
// 前缀表达式包括一个前缀运算符和一个右值表达式, 如 -a 或 !b
fn (mut p Parser) parse_prefix_expression() !ast.Expression {
	tok := p.cur
	p.shift_token(1)!

	return &ast.PrefixExpression{
		token: tok
		right: p.parse_expression(.prefix)!
	}
}

// parse_infix_expression 方法解析中缀表达式并返回相应的节点
// 中缀表达式包括一个中缀运算符和一个左值、右值表达式，如 a + b
fn (mut p Parser) parse_infix_expression(left ast.Expression) !ast.Expression {
	tok := p.cur
	prec := p.cur.precedence()
	p.shift_token(1)!

	return &ast.InfixExpression{
		token: tok
		left: left
		right: p.parse_expression(prec)!
	}
}

// parse_if_expression 方法解析 if 表达式并返回相应的节点
// if 表达式由条件表达式、可选的 else 分支和相应的语句块组成
fn (mut p Parser) parse_if_expression() !ast.Expression {
	mut expr := &ast.IfExpression{
		token: p.cur
		condition: unsafe { nil }
		if_true: unsafe { nil }
		if_false: unsafe { nil }
	}

	// 判断是否有左侧圆括号
	if p.next.t_type != .left_paren {
		return error(r'if表达式的条件表达式应在完整的 "()" 中')
	}
	p.shift_token(2)!

	// 解析 if 条件表达式
	expr.condition = p.parse_expression(.lowest)!

	// 判断是否有右侧圆括号
	if p.next.t_type != .right_paren {
		return error(r'if 表达式的条件表达式未闭合, 请在表达式末尾添加 ")" 使之完整')
	}
	p.shift_token(1)!

	// 判断是否有左侧大括号
	if p.next.t_type != .left_brace {
		return error(r'if 表达式执行的代码块内容应在完整的 "{}" 中')
	}
	p.shift_token(1)!

	expr.if_true = p.parse_block_statement()!

	// 判断是否有 else 代码块
	if p.next.t_type == .@else {
		p.shift_token(1)!

		// 判断是否有左侧大括号
		if p.next.t_type != .left_brace {
			return error(r'else 表达式执行的代码块内容应在完整的 "{}" 中')
		}
		p.shift_token(1)!

		expr.if_false = p.parse_block_statement()!
	}

	return expr
}

// parse_call_expression 方法解析函数调用表达式并返回相应的节点
// 函数调用表达式包括被调用的可调用对象和参数列表
fn (mut p Parser) parse_call_expression(callable ast.Expression) !ast.Expression {
	mut expr := &ast.CallExpression{
		token: p.cur
		callable: callable
		arguments: []
	}

	// 判断 callable 是否为可调用对象
	if callable.token.t_type in [.int, .float, .char, .string] {
		return error('${callable} 不是一个可调用对象')
	}

	// 若下个词法单元为右圆括号则表示没有参数
	if p.next.t_type == .right_paren {
		p.shift_token(1)!
		return expr
	}

	// 获取第一个参数
	p.shift_token(1)!
	expr.arguments << p.parse_expression(.lowest)!

	// 通过逗号判断是否有其它参数
	for p.next.t_type == .comma_symbol {
		p.shift_token(2)!
		expr.arguments << p.parse_expression(.lowest)!
	}

	// 判断是否有右侧圆括号
	if p.next.t_type != .right_paren {
		return error(r'参数表达式未闭合, 请在表达式末尾添加 ")" 使之完整')
	}

	p.shift_token(1)!

	return expr
}

// parse_index_expression 方法解析索引表达式并返回相应的节点
// 索引表达式包括被索引的左侧表达式和用于索引的索引表达式
fn (mut p Parser) parse_index_expression(left ast.Expression) !ast.Expression {
	tok := p.cur
	p.shift_token(1)!
	expr := &ast.IndexExpression{
		token: tok
		left: left
		index: p.parse_expression(.lowest)!
	}

	if p.next.t_type != .right_bracket {
		return error(r'索引表达式应在完整的 "[]" 中')
	}

	p.shift_token(1)!
	return expr
}

// parse_member_expression 方法解析成员访问表达式并返回相应的节点
// 成员访问表达式包括被访问的左侧对象和用于访问的成员名称
fn (mut p Parser) parse_member_expression(self ast.Expression) !ast.Expression {
	tok := p.cur
	p.shift_token(1)!
	mut expr := &ast.MemberExpression{
		token: tok
		self: self
		member: unsafe { nil }
	}


	if p.cur.t_type != .ident {
		return error('"." 操作符的右侧必须该是标识符或者函数调用')
	}

	if p.next.t_type == .left_paren {
		expr.member = p.parse_expression(.lowest)!

		if mut expr.member is ast.CallExpression {
			expr.member.arguments.prepend(self)
			return expr
		}

		if mut expr.member is ast.MemberExpression {
			return error('因内部实现原因, 暂不支持调用成员方法后的链式访问')
		}
	}

	expr.member = ast.String{
		token: p.cur
		value: p.cur.t_raw
	}
	return expr
}
