module ast

import token

// AST 节点接口
// 该接口定义了抽象语法树节点的基本行为
pub interface Node {
	// 该方法用于获取当前节点原始字面量字符串
	raw() string
	// 该方法用于获取当前节点的字符串表示形式
	str() string
}

// Expression 节点接口
// 该接口表示 AST 中的表达式节点
pub interface Expression {
	Node
	token token.Token
	expression_node()
}

// Statement 节点接口
// 该接口表示 AST 中的语句节点
pub interface Statement {
	Node
	token token.Token
	statement_node()
}

// Program 结构体是抽象语法树的根节点
pub struct Program {
pub mut:
	body []Statement
}

pub fn (p Program) raw() string {
	return ''
}

pub fn (p Program) str() string {
	return ''
}

// BaseExpression 结构体是所有表达式节点的基类
pub struct BaseExpression {
pub:
	token token.Token
}

pub fn (be BaseExpression) raw() string {
	return be.token.t_raw
}

pub fn (be BaseExpression) str() string {
	return be.token.t_raw
}

// BaseStatement 接口体是所有语句节点的基类
pub struct BaseStatement {
pub:
	token token.Token
}

pub fn (bs BaseStatement) raw() string {
	return bs.token.t_raw
}

pub fn (bs BaseStatement) str() string {
	return bs.token.t_raw
}
