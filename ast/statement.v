module ast

// ExpressionStatement 表达式语句结构体, 是对表达式节点的语句封装
pub struct ExpressionStatement {
	BaseStatement
pub:
	expression Expression
}

pub fn (es ExpressionStatement) str() string {
	return es.expression.str()
}

// BlockStatement 代码块结构体, 表示由一系列语句组成的代码块
pub struct BlockStatement {
	BaseStatement
pub mut:
	body []Statement = []
}

pub fn (bs BlockStatement) str() string {
	mut out := []string{}

	for stmt in bs.body {
		out << stmt.str()
	}

	return out.join(';')
}

// ReturnStatement 返回语句结构体, 表示在函数体中返回一个结果
pub struct ReturnStatement {
	BaseStatement
pub mut:
	value Expression
}

pub fn (rs ReturnStatement) str() string {
	return 'return ${rs.value}'
}
