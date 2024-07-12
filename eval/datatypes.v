module eval

import ast
import object

// eval_function 函数对函数节点进行求值并返回函数对象
fn eval_function(node ast.Function, mut scope object.Scope) !object.Object {
	func := &object.Function{
		datatype: .function
		params: node.params
		body: node.body
		scope: &object.Scope{
			parent: unsafe { &scope }
		}
	}

	if node.name != unsafe { nil } {
		scope.set(node.name.name, func)
		return object.only_null
	}

	return func
}

// eval_list 函数对列表节点进行求值并返回列表对象
fn eval_list(node ast.List, mut scope object.Scope) !object.Object {
	mut list := &object.List{
		datatype: .list
	}

	for elem in node.elems {
		obj := eval(elem as ast.Node, mut scope)!
		if obj != object.only_null {
			list.elems << obj
		}
	}

	return list
}

// eval_table 函数对字典节点进行求值并返回字典对象
fn eval_table(node ast.Table, mut scope object.Scope) !object.Object {
	mut table := &object.Table{
		datatype: .table
	}

	for pair in node.pairs {
		key := eval(pair[0] as ast.Node, mut scope)!
		hash := key.hash() or {
			return error('${key.datatype} 类型的对象不能作为 table 的键')
		}

		value := eval(pair[1] as ast.Node, mut scope)!
		if value != object.only_null {
			table.pairs[hash] = [key, value]
		}
	}

	return table
}
