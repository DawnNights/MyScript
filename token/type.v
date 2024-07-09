module token

// TokenType枚举
// 该枚举定义了词法分析阶段可能识别出的所有词法单元类型
pub enum TokenType {
	// 表示未知的词法单元
	unknow
	// 表示到达代码的末尾
	end
	// 表示一个合法的标识符
	ident
	// 表示一个整数
	int
	// 表示一个字符串
	string
	// 表示赋值符号 '='
	assign_symbol
	// 表示感叹号 '!'
	bang_symbol
	// 表示加号 '+'
	plus_symbol
	// 表示减号 '-'
	minus_symbol
	// 表示星号 '*'
	asterisk_symbol
	// 表示斜杠 '/'
	slash_symbol
	// 表示小于号 '<'
	less_symbol
	// 表示大于号 '>'
	greater_symbol
	// 表示小于等于符号 '<='
	less_assign_symbol
	// 表示大于等于符号 '>='
	greater_assign_symbol
	// 表示等号 '=='
	equal_symbol
	// 表示不等号 '!='
	not_equal_symbol
	// 表示范围符号 '..'
	range_symbol
	// 表示冒号 ':'
	colon_symbol
	// 表示逗号 ','
	comma_symbol
	// 表示分号 ';'
	semicolon_symbol
	// 表示点 '.'
	point_symbol
	// 表示反引号 '`'
	back_quote
	// 表示单引号 '''
	single_quote
	// 表示双引号 '"'
	double_quote
	// 表示左圆括号 '('
	left_paren
	// 表示右圆括号 ')'
	right_paren
	// 表示左方括号 '['
	left_bracket
	// 表示右方括号 ']'
	right_bracket
	// 表示左花括号 '{'
	left_brace
	// 表示右花括号 '}'
	right_brace
	// 关键字：表示布尔值 true
	@true
	// 关键字：表示布尔值 false
	@false
	// 关键字：表示返回语句
	@return
	// 关键字：表示 if 语句
	@if
	// 关键字：表示 else 语句
	@else
	// 关键字：表示 in 语句或操作符
	@in
	// 关键字：表示 for 循环
	@for
}

// 该方法返回 TokenType 枚举成员的字符串表示形式
fn (t_type TokenType) str() string {
	return match t_type {
		.unknow { 'UNKNOWN' }
		.end { 'END' }
		.ident { 'IDENT' }
		.int { 'INT' }
		.string { 'STRING' }
		.assign_symbol { '=' }
		.bang_symbol { '!' }
		.plus_symbol { '+' }
		.minus_symbol { '-' }
		.asterisk_symbol { '*' }
		.slash_symbol { '/' }
		.less_symbol { '<' }
		.greater_symbol { '>' }
		.less_assign_symbol { '<=' }
		.greater_assign_symbol { '>=' }
		.equal_symbol { '==' }
		.not_equal_symbol { '!=' }
		.range_symbol { '..' }
		.colon_symbol { ':' }
		.comma_symbol { ',' }
		.semicolon_symbol { ';' }
		.point_symbol { '.' }
		.back_quote { '`' }
		.single_quote { "'" }
		.double_quote { '"' }
		.left_paren { '(' }
		.right_paren { ')' }
		.left_bracket { '[' }
		.right_bracket { ']' }
		.left_brace { '{' }
		.right_brace { '}' }
		.@true { 'TRUE' }
		.@false { 'FALSE' }
		.@return { 'RETURN' }
		.@if { 'IF' }
		.@else { 'ELSE' }
		.@in { 'IN' }
		.@for { 'FOR' }
	}
}
