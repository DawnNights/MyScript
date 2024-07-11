module parser

import ast

fn (mut p Parser) parse_block_statement() !&ast.BlockStatement {
	mut block := ast.BlockStatement{
		token: p.cur
	}
	p.shift_token(1)!

	for p.cur.t_type != .right_brace {
		if p.cur.t_type == .end {
			return error('代码块语句未闭合, 请在表达式末尾添加 "}" 使之完整')
		}

		block.body << p.parse_statement()!
		p.shift_token(1)!
	}

	return &block
}
