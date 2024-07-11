module ast

// PrefixExpression 前缀表达式结构体, 表示一个包含操作符和右侧表达式的前缀操作
pub struct PrefixExpression {
	BaseExpression
pub:
	right Expression
}

pub fn (pe PrefixExpression) str() string {
	return '(${pe.token.t_raw}${pe.right})'
}

// InfixExpression 中缀表达式结构体, 表示一个包含操作符、左侧表达式和右侧表达式的中缀操作
pub struct InfixExpression {
	BaseExpression
pub:
	left  Expression
	right Expression
}

pub fn (ie InfixExpression) str() string {
	return '(${ie.left} ${ie.token.t_raw} ${ie.right})'
}

// IfExpression 条件表达式结构体, 表示一个包含条件和两个分支的条件语句
pub struct IfExpression {
	BaseExpression
pub mut:
	condition Expression
	if_true   &BlockStatement
	if_false  &BlockStatement
}

pub fn (ie IfExpression) str() string {
	if ie.if_false == unsafe { nil } {
		return 'if (${ie.condition}) {${ie.if_true}}'
	}
	return 'if (${ie.condition}) {${ie.if_true}} else {${ie.if_false}}'
}

// CallExpression 函数调用表达式结构体, 表示一个包含被调用函数和参数列表的调用操作
pub struct CallExpression {
	BaseExpression
pub:
	callable Expression
pub mut:
	arguments []Expression
}

pub fn (ce CallExpression) str() string {
	mut args := []string{}

	for a in ce.arguments {
		args << a.str()
	}

	return '${ce.callable}(${args.join(', ')})'
}

// IndexExpression 索引表达式结构体, 表示一个包含左侧表达式和索引表达式的索引操作
pub struct IndexExpression {
	BaseExpression
pub:
	left  Expression
	index Expression
}

fn (ie IndexExpression) str() string {
	return '(${ie.left.str()}[${ie.index.str()}])'
}

