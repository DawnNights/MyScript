module eval

import ast
import object

// eval_prefix_expression 函数对前缀表达式节点求值并返回对应对象
fn eval_prefix_expression(node ast.PrefixExpression, mut scope object.Scope) !object.Object {
	right := eval(node.right as ast.Node, mut scope)!

	return match node.token.t_type {
		.bang_symbol { right.negate()! }
		.minus_symbol { right.negative()! }
		else { error('未定义的前缀运算符 "${node.token.t_type}"') }
	}
}

// eval_infix_expression 函数对中缀表达式节点求值并返回对应对象
fn eval_infix_expression(node ast.InfixExpression, mut scope object.Scope) !object.Object {
	if node.token.t_type == .assign_symbol {
		right := eval(node.right as ast.Node, mut scope)!

		if node.left is ast.Identifier {
			if right == object.only_null {
				scope.del(node.left.name)
			} else {
				scope.set(node.left.name, right)
			}
			return object.only_null
		}

		if node.left is ast.IndexExpression {
			mut left := eval(node.left.left as ast.Node, mut scope)!
			index := eval(node.left.index as ast.Node, mut scope)!

			left.set(index, right)!
			return object.only_null
		}

		if node.left is ast.MemberExpression {
			mut self := eval(node.left.self as ast.Node, mut scope)!
			member:= eval(node.left.member as ast.Node, mut scope)!

			self.set(member, right)!
			return object.only_null
		}

		return error('${node.left} 不是一个可赋值对象')
	}

	left := eval(node.left as ast.Node, mut scope)!
	right := eval(node.right as ast.Node, mut scope)!

	match node.token.t_type {
		.plus_symbol {
			return left.add(right)
		}
		.minus_symbol {
			return left.sub(right)
		}
		.asterisk_symbol {
			return left.mul(right)
		}
		.slash_symbol {
			return left.div(right)
		}
		.less_symbol {
			return left.less_than(right)
		}
		.greater_symbol {
			return left.more_than(right)
		}
		.less_assign_symbol {
			return left.less_or_equal(right)
		}
		.greater_assign_symbol {
			return left.more_or_equal(right)
		}
		.equal_symbol {
			return left.equal(right)
		}
		.not_equal_symbol {
			return left.not_equal(right)
		}
		.range_symbol {
			if left is object.Int && right is object.Int {
				if left.value >= right.value {
					return error('范围表达式的左值必须小于右值')
				}
				return &object.Range{
					datatype: .range
					start: left.value
					end: right.value
				}
			}

			return error('范围表达式的左值和右值必须都是 int 对象')
		}
		.@in {
			return right.has(left)
		}
		else {
			return error('未定义的中缀运算符 "${node.token.t_type}"')
		}
	}
}

// eval_if_expression 函数对 if 表达式求值并返回对应对象
fn eval_if_expression(node ast.IfExpression, mut scope object.Scope) !object.Object {
	condition := eval(node.condition as ast.Node, mut scope)!

	if condition.to_bool()! == object.only_true {
		return eval(node.if_true, mut scope)
	} else if node.if_false != unsafe { nil } {
		return eval(node.if_false, mut scope)
	}

	return object.only_null
}

// eval_call_expression 函数对调用表达式求值并返回结果对象
fn eval_call_expression(node ast.CallExpression, mut scope object.Scope) !object.Object {
	callable := eval(node.callable as ast.Node, mut scope)!

	mut args := []object.Object{}
	for arg in node.arguments {
		args << eval(arg as ast.Node, mut scope)!
	}

	// 调用对象为内置函数
	if callable is object.BuiltinFunction {
		return callable.func(...args)
	}

	// 调用对象为自定义函数
	if callable is object.Function {
		mut local_scope := object.Scope{unsafe { &scope }, {}}

		if args.len != callable.params.len {
			return error('函数 "${node.callable.raw()}" 的传参应该是 ${callable.params.len} 个, 而不是 ${args.len} 个')
		}

		for i := 0; i < callable.params.len; i++ {
			local_scope.set(callable.params[i].name, args[i])
		}

		// 求值对象为 return 语句返回结果
		result := eval(callable.body, mut local_scope)!
		if result is object.ReturnObject {
			return result.value
		}

		return object.only_null
	}

	return error('对象 "${callable}" 不是一个可调用函数')
}

// eval_index_expression 函数对索引表达式求值并返回对应对象
fn eval_index_expression(node ast.IndexExpression, mut scope object.Scope) !object.Object {
	left := eval(node.left as ast.Node, mut scope)!
	index := eval(node.index as ast.Node, mut scope)!
	return left.get(index)!
}

// eval_member_expression 函数对成员访问表达式求值并返回求值对象
fn eval_member_expression(node ast.MemberExpression, mut scope object.Scope) !object.Object {
	self := eval(node.self as ast.Node, mut scope)!

	if node.member is ast.String {
		name := eval(node.member, mut scope)!
		result := self.get(name) or {
			now_err := err
			return scope.get('${self.datatype}.${node.member.value}') or {
				return now_err
			}
		}

		return result
	}

	if node.member is ast.CallExpression {
		method_name := node.member.callable.token.t_raw
		mut callable := object.only_null
		mut args := []object.Object{}

		for arg in node.member.arguments {
			args << eval(arg as ast.Node, mut scope)!
		}

		if self is object.Table {
			key := object.new_string(method_name)
			if self.has(key)! == object.only_true {
				callable = self.get(key)!
			}
		} 
		
		if callable == object.only_null {
			callable = scope.get('${self.datatype}.${method_name}') or {
				return error('成员方法 "${method_name}" 尚未定义')
			}
		}

		// 调用对象为内置函数
		if mut callable is object.BuiltinFunction {
			return callable.func(...args)
		}

		// 调用对象为自定义函数
		if mut callable is object.Function {
			mut local_scope := object.Scope{unsafe { &scope }, {}}

			if args.len != callable.params.len {
				return error('成员方法 "${method_name}" 的传参应该是 ${callable.params.len - 1} 个, 而不是 ${args.len - 1} 个')
			}

			for i := 0; i < callable.params.len; i++ {
				local_scope.set(callable.params[i].name, args[i])
			}

			// 求值对象为 return 语句返回结果
			result := eval(callable.body, mut local_scope)!
			if result is object.ReturnObject {
				return result.value
			}

			return object.only_null
		}
	}

	return error('"." 操作符的右侧必须该是标识符或者函数调用')
}
