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

// eval_for_statement 函数对 for 语句求值
fn eval_for_statement(node ast.ForStatement, mut scope object.Scope) !object.Object {
	name := node.name.name
	list := eval(node.list as ast.Node, mut scope)!.to_list()! as object.List

	for elem in list.elems {
		scope.set(name, elem)

		for stmt in node.block.body {
			result := eval(stmt as ast.Node, mut scope)!

			if result is object.ReturnObject {
				return result
			}

			if result is object.BreakObject {
				return object.only_null
			}

			if result is object.ContinueObject {
				break
			}
		}
	}

	return object.only_null
}

// eval_while_statement 函数对 while 语句求值
fn eval_while_statement(node ast.WhileStatement, mut scope object.Scope) !object.Object {
	mut condition := eval(node.condition as ast.Node, mut scope)!

	for condition == object.only_true {
		for stmt in node.block.body {
			result := eval(stmt as ast.Node, mut scope)!

			if result is object.ReturnObject {
				return result
			}

			if result is object.BreakObject {
				return object.only_null
			}

			if result is object.ContinueObject {
				break
			}
		}
		condition = eval(node.condition as ast.Node, mut scope)!
	}

	return object.only_null
}
