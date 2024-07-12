module eval

import ast
import object

// eval_block_statement 函数对代码块语句进行遍历求值并返回对应对象
fn eval_block_statement(node ast.BlockStatement, mut scope object.Scope) !object.Object {
	mut result := object.only_null
	for stmt in node.body {
		result = eval(stmt as ast.Node, mut scope)!

		if mut result is object.ReturnObject {
			return result
		}
	}
	return result
}

// eval_return_statement 函数对返回语句求值并返回结果对象
fn eval_return_statement(node ast.ReturnStatement, mut scope object.Scope) !object.Object {
	obj := eval(node.value as ast.Node, mut scope)!

	return &object.ReturnObject{
		datatype: obj.datatype
		value: obj
	}
}
