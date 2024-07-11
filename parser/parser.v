module parser

import ast
import lexer
import token

type ExprParser = fn () !ast.Expression

type InfixExprParser = fn (ast.Expression) !ast.Expression

// Parser 结构体表示一个语法分析器, 它使用词法分析器来读取输入, 并生成解析树
pub struct Parser {
mut:
	l               &lexer.Lexer
	cur             token.Token
	next            token.Token
	prefix_fn_table map[token.TokenType]ExprParser      = {}
	infix_fn_table  map[token.TokenType]InfixExprParser = {}
}

// shift_token 方法更新当前和下一个词法单元
fn (mut p Parser) shift_token(n int) ! {
	for i := 0; i < n; i++ {
		p.cur = p.next
		p.next = p.l.read_token()!
	}
}

// parse_program 方法解析整个程序并返回 Program 根节点
pub fn (mut p Parser) parse_program() !&ast.Program {
	mut program := &ast.Program{[]}

	for p.cur.t_type != .end {
		program.body << p.parse_statement()!
		p.shift_token(1)!
	}

	return program
}

// parse_statement 方法解析一条语句并返回对应的节点
fn (mut p Parser) parse_statement() !ast.Statement {
	match p.cur.t_type {
		.@return {
			return error('暂未实现 return 语句解析')
		}
		.@for {
			return error('暂未实现 for 语句解析')
		}
		else {
			return ast.ExpressionStatement{
				token: p.cur
				expression: p.parse_expression(-10)!
			}
		}
	}
}

// parse_expression 方法按优先级解析一条表达式并返回对应的节点
fn (mut p Parser) parse_expression(prec int) !ast.Expression {
	// 判断 prefix_fn_table 中是否有该词法单元的回调函数
	if p.cur.t_type !in p.prefix_fn_table {
		return error('没有找到 ${p.cur.t_type} 类型的词法解析函数')
	}
	prefix_fn := p.prefix_fn_table[p.cur.t_type]
	mut expr := prefix_fn()!

	// 循环判断下一个词法单元是否为分号, 并比较当前词法单元和下一个词法单元的优先级
	for p.next.t_type != .semicolon_symbol && prec < p.next.precedence() {
		if p.next.t_type !in p.infix_fn_table {
			return expr
		}

		infix_fn := p.infix_fn_table[p.next.t_type]
		p.shift_token(1)!
		expr = infix_fn(expr)!
	}

	// 跳过分号
	if p.next.t_type == .semicolon_symbol {
		p.shift_token(1)!
	}

	return expr
}

// new 创建并返回一个新的 Parser 实例
pub fn new(l &lexer.Lexer) !&Parser {
	unsafe {
		p := &Parser{
			l: l
			cur: l.read_token()!
			next: l.read_token()!
		}

		p.prefix_fn_table = {
			.ident:        p.parse_ident
			.int:          p.parse_int
			.float:        p.parse_float
			.@true:        p.parse_bool
			.@false:       p.parse_bool
			.string:       p.parse_string
			.function:     p.parse_function
			.left_bracket: p.parse_list
			.left_brace:   p.parse_table
		}

		p.infix_fn_table = {
		}

		return p
	}
}
