module parser

import ast

fn (mut p Parser) parse_block_statement() !&ast.BlockStatement {
	mut block := ast.BlockStatement{
		token: p.cur
	}
	p.shift_token(1)!

	for p.cur.t_type != .right_brace {
		if p.cur.t_type == .end {
			return error('代码块语句未正确闭合, 请在语句末添加 "}" 确保其完整')
		}

		block.body << p.parse_statement()!
		p.shift_token(1)!
	}

	return &block
}
