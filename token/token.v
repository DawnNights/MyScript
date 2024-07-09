module token

// Token 结构体表示词法分析器中的一个词法单元
pub struct Token {
pub:
	// t_type 表示当前 Token 的类型
	t_type TokenType
	// t_raw 表示当前 Token 的原始字符串
	t_raw string
}

// 根据 Token 的类型 t_type 进行匹配，返回相应的优先级值
fn (t Token) precedence() int {
	return match t.t_type {
		.assign_symbol { 10 }
		.less_symbol, .greater_symbol, .less_assign_symbol { 20 }
		.greater_assign_symbol, .equal_symbol, .not_equal_symbol { 20 }
		.plus_symbol, .minus_symbol { 30 }
		.asterisk_symbol, .slash_symbol { 40 }
		.left_paren { 50 }
		.left_bracket, .point_symbol { 60 }
		else { -10 }
	}
}
