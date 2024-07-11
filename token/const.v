module token

// 允许出现在字符串定义后的词法单元
pub const tokens_allow_after_string = [
	TokenType.end,
	.assign_symbol,
	.plus_symbol,
	.asterisk_symbol,
	.equal_symbol,
	.not_equal_symbol,
	.colon_symbol,
	.comma_symbol,
	.semicolon_symbol,
	.point_symbol,
	.comment_symbol,
	.left_paren,
	.right_paren,
	.left_bracket,
	.right_bracket,
	.left_brace,
	.right_brace,
	.@in,
]