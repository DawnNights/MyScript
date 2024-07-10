module lexer

import token

// Lexer 结构体表示一个词法分析器, 作用是对输入的代码进行词法分析, 生成词法单元
pub struct Lexer {
pub mut:
	input string
}

// read_token 方法读取并返回一个词法单元
pub fn (mut l Lexer) read_token() !token.Token {
	mut tok := token.Token{
		t_type: .unknow
		t_raw: ''
	}

	// 跳过输入中的空白字符（包括空格、换行、回车和制表符）
	l.input = l.input.trim_left(' \n\r\t')

	// 检查是否已经到达代码的末端
	if l.input == '\0' {
		tok.t_type = .end
		return tok
	}

	// 检查当前输入是否为关键字
	if l.is_keyword(mut tok) {
		return tok
	}

	// 检查当前输入是否为复合符号
	if l.is_symbols(mut tok) {
		return tok
	}

	// 匹配当前输入的词法类型
	tok.t_type = l.get_char_type()

	// 判断当前输入为 字符 | 字符串
	if tok.t_type == .back_quote {
		return l.read_char_token(mut tok)
	} else if tok.t_type == .single_quote {
		return l.read_string_token(mut tok, 39)
	} else if tok.t_type == .double_quote {
		return l.read_string_token(mut tok, 34)
	}

	// 判断当前输入为单符号
	if tok.t_type != .unknow {
		tok.t_raw = tok.t_type.str()
		l.input = l.input[1..]
		return tok
	}

	// 判断当前输入为 整数 | 小数
	if l.input[0].is_digit() {
		for l.input[0].is_digit() || l.input[0] == 46 {
			if l.input[0] == 46 {
				tok.t_type = .float
			}

			tok.t_raw = tok.t_raw + unsafe { tos(l.input.str, 1) }
			l.input = l.input[1..]
		}

		if tok.t_type != .float {
			tok.t_type = .int
		}

		return tok
	}

	// 判断当前输入为标识符
	mut unicode := rune(0)
	mut size := 0

	for {
		unicode, size = get_rune_from_string(l.input)

		if rune_is_valid(unicode) {
			tok.t_raw = tok.t_raw + l.input[0..size]
			l.input = l.input[size..]
			continue
		}

		tok.t_type = .ident
		return tok
	}


	tok.t_raw = unicode.str()
	l.input = l.input[size..]
	return tok
}

// is_symbols 方法检查输入是否为复合符号, 并相应地设置 Token 类型和原始字符串
fn (mut l Lexer) is_symbols(mut tok token.Token) bool {
	if l.input.starts_with('<=') {
		tok.t_type = .less_assign_symbol
		return l.tok_set(mut tok, '<=')
	}

	if l.input.starts_with('>=') {
		tok.t_type = .greater_assign_symbol
		return l.tok_set(mut tok, '>=')
	}

	if l.input.starts_with('==') {
		tok.t_type = .equal_symbol
		return l.tok_set(mut tok, '==')
	}

	if l.input.starts_with('!=') {
		tok.t_type = .not_equal_symbol
		return l.tok_set(mut tok, '!=')
	}

	if l.input.starts_with('..') {
		tok.t_type = .range_symbol
		return l.tok_set(mut tok, '..')
	}

	return false
}

// is_keyword 方法检查输入是否为关键字, 并相应地设置 Token 类型和原始字符串
fn (mut l Lexer) is_keyword(mut tok token.Token) bool {
	if l.input.starts_with('fn') {
		tok.t_type = .function
		return l.tok_set(mut tok, 'fn')
	}

	if l.input.starts_with('true') {
		tok.t_type = .@true
		return l.tok_set(mut tok, 'true')
	}

	if l.input.starts_with('false') {
		tok.t_type = .@false
		return l.tok_set(mut tok, 'false')
	}

	if l.input.starts_with('return') {
		tok.t_type = .@return
		return l.tok_set(mut tok, 'return')
	}

	if l.input.starts_with('if') {
		tok.t_type = .@if
		return l.tok_set(mut tok, 'if')
	}

	if l.input.starts_with('else') {
		tok.t_type = .@else
		return l.tok_set(mut tok, 'else')
	}

	if l.input.starts_with('in') {
		tok.t_type = .@in
		return l.tok_set(mut tok, 'in')
	}

	if l.input.starts_with('for') {
		tok.t_type = .@for
		return l.tok_set(mut tok, 'for')
	}

	return false
}

// tok_set 方法设置 Token 的原始字符串, 并从输入中移除相应的部分
fn (mut l Lexer) tok_set(mut tok token.Token, str string) bool {
	tok.t_raw = str
	l.input = l.input[str.len..]
	return true
}

// get_char_type 匹配当前输入首字符的词法类型
fn (l Lexer) get_char_type() token.TokenType {
	return match rune(l.input[0]) {
		`=` { .assign_symbol }
		`!` { .bang_symbol }
		`+` { .plus_symbol }
		`-` { .minus_symbol }
		`*` { .asterisk_symbol }
		`/` { .slash_symbol }
		`<` { .less_symbol }
		`>` { .greater_symbol }
		`:` { .colon_symbol }
		`,` { .comma_symbol }
		`;` { .semicolon_symbol }
		`.` { .point_symbol }
		`\`` { .back_quote }
		`'` { .single_quote }
		`"` { .double_quote }
		`(` { .left_paren }
		`)` { .right_paren }
		`[` { .left_bracket }
		`]` { .right_bracket }
		`{` { .left_brace }
		`}` { .right_brace }
		else { .unknow }
	}
}

// read_char_token 读取并返回一个字符词法单元
fn (mut l Lexer) read_char_token(mut tok token.Token) !token.Token {
	if l.input[1] == 0 {
		return error('字符表达式未正确闭合, 请将其填充完整')
	}

	if l.input[1] == 96 {
		return error('字符表达式不能为空, 请确保在 `` 中输入一个有效的字符')
	}

	l.input = l.input[1..]
	size := get_utf8_size(l.input[0])
	if l.input[size] != 96 {
		return error('字符表达式中只能包含一个字符, 请将 `` 中的输入改为单个字符')
	}

	tok.t_type = .char
	tok.t_raw = l.input[0..size]
	l.input = l.input[size+1..]
	return tok
}

// read_string_token 读取并返回一个字符串词法单元
fn (mut l Lexer) read_string_token(mut tok token.Token, quote_char u8) !token.Token {
	l.input = l.input[1..]

	for {
		if l.input[0] == quote_char {
			l.input = l.input[1..]
			break
		}

		if l.input[0] == 0 {
			if quote_char == 39 {
				return error('字符串表达式未正确闭合, 请在字符串的右侧加上单引号')
			}
			return error('字符串表达式未正确闭合, 请在字符串的右侧加上双引号')
		}

		tok.t_raw = tok.t_raw + unsafe { tos(l.input.str, 1) }
		l.input = l.input[1..]
	}

	tok.t_type = .string
	return tok
}

// new 创建并返回一个新的 Lexer 实例
pub fn new(input string) &Lexer {
    return &Lexer{
		input: input + '\0'
	}
}