module parser

import ast
import token

// parse_ident 方法解析标识符表达式
fn (mut p Parser) parse_ident() !ast.Expression {
	return &ast.Identifier{
		token: p.cur
		name: p.cur.t_raw
	}
}

// parse_int 方法解析整数表达式
fn (mut p Parser) parse_int() !ast.Expression {
	return &ast.Int{
		token: p.cur
		value: p.cur.t_raw.i64()
	}
}

// parse_float 方法解析浮点数表达式
fn (mut p Parser) parse_float() !ast.Expression {
	return &ast.Float{
		token: p.cur
		value: p.cur.t_raw.f64()
	}
}

// parse_bool 方法解析布尔表达式
fn (mut p Parser) parse_bool() !ast.Expression {
	return &ast.Bool{
		token: p.cur
		value: p.cur.t_type == .@true
	}
}

// parse_string 方法解析字符串表达式
fn (mut p Parser) parse_string() !ast.Expression {

	if p.next.t_type !in token.tokens_allow_after_string {
		return error('${p.next.t_type} 不允许出现在字符串定义后')
	}

	return &ast.String{
		token: p.cur
		value: p.cur.t_raw
	}
}

// parse_function 方法解析函数表达式
fn (mut p Parser) parse_function() !ast.Expression {
	mut func := &ast.Function{
		token: p.cur
		body: unsafe { nil }
	}

	// 判断是否有函数名称
	if p.next.t_type == .ident {
		func.name = &ast.Identifier{
			token: p.next
			name: p.next.t_raw
		}

		p.shift_token(1)!
	}

	// 判断是否有左侧圆括号
	if p.next.t_type != .left_paren {
		return error('定义函数时, 参数表达式应在完整的 "()" 中')
	}

	p.shift_token(1)!

	// 判断是否有参数表达式
	if p.next.t_type == .right_paren {
		p.shift_token(1)!
		unsafe {
			goto parse_func_block
		}
	}

	// 获取第一个参数
	p.shift_token(1)!
	func.params << &ast.Identifier{
		token: p.cur
		name: p.cur.t_raw
	}

	// 通过逗号判断是否有其它参数
	for p.next.t_type == .comma_symbol {
		p.shift_token(2)!
		func.params << &ast.Identifier{
			token: p.cur
			name: p.cur.t_raw
		}
	}

	// 判断是否有右侧圆括号
	if p.next.t_type != .right_paren {
		return error('参数表达式未闭合, 请在表达式末尾添加 ")" 使之完整')
	}
	p.shift_token(1)!

	// 判断是否为左侧大括号
	parse_func_block:
	if p.next.t_type != .left_brace {
		return error('定义函数时, 代码块内容应在完整的 "{}" 中')
	}

	p.shift_token(1)!
	func.body = p.parse_block_statement()!

	return func
}

// parse_list 方法解析列表表达式
fn (mut p Parser) parse_list() !ast.Expression {
	mut list := &ast.List{
		token: p.cur
	}

	// 若下个词法单元为右方括号则表示没有参数
	if p.next.t_type == .right_bracket {
		p.shift_token(1)!
		return list
	}

	// 获取第一个元素
	p.shift_token(1)!
	list.elems << p.parse_expression(.lowest)!

	// 通过逗号判断是否有其它参数
	for p.next.t_type == .comma_symbol {
		p.shift_token(2)!
		list.elems << p.parse_expression(.lowest)!
	}

	// 判断是否有右侧方括号
	if p.next.t_type != .right_bracket {
		return error(r'列表表达式未闭合, 请在表达式末尾添加 "]" 使之完整')
	}
	p.shift_token(1)!

	return list
}

// parse_table 方法解析字典表达式
fn (mut p Parser) parse_table() !ast.Expression {
	mut table := &ast.Table{
		token: p.cur
	}

	for p.next.t_type != .right_brace {
		p.shift_token(1)!
		key := p.parse_expression(.lowest)!

		if p.next.t_type != .colon_symbol {
			return error('定义 Table 对象时必须使用 ":" 进行键与值的配对, 而不是 "${p.next.t_raw}')
		}

		p.shift_token(2)!
		value := p.parse_expression(.lowest)!

		table.pairs << [key, value]

		if p.next.t_type == .comma_symbol {
			p.shift_token(1)!
		} else if p.next.t_type == .end {
			return error('字典表达式未闭合, 请在表达式末尾添加 "}" 使之完整')
		} else if p.next.t_type != .right_brace {
			return error('Table 对象的配对必须使用 `,` 分隔, 而不是 `${p.next.t_raw}`')
		}
	}

	if p.next.t_type == .right_brace {
		p.shift_token(1)!
	}

	return table
}
