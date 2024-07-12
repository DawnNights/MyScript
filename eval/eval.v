module eval

import ast
import object

// eval 函数对抽象语法树节点进行求值并返回相应的对象
pub fn eval(node ast.Node, mut scope object.Scope) !object.Object {
	match node {
		ast.Identifier {
			return scope.get(node.name)
		}
		ast.Int {
			return &object.Int{
				datatype: .int
				value: node.value
			}
		}
		ast.Float {
			return &object.Float{
				datatype: .float
				value: node.value
			}
		}
		ast.Bool {
			if node.value {
				return object.only_true
			}
			return object.only_false
		}
		ast.Char {
			return &object.Char{
				datatype: .char
				value: node.value
			}
		}
		ast.String {
			return object.new_string(node.value)
		}
		ast.Function {
			return eval_function(node, mut scope)
		}
		ast.List {
			return eval_list(node, mut scope)
		}
		ast.Table {
			return eval_table(node, mut scope)
		}
		ast.ExpressionStatement {
			return eval(node.expression as ast.Node, mut scope)
		}
		ast.BlockStatement {
			return eval_block_statement(node, mut scope)
		}
		ast.ReturnStatement {
			return eval_return_statement(node, mut scope)
		}
		ast.PrefixExpression {
			return eval_prefix_expression(node, mut scope)
		}
		ast.InfixExpression {
			return eval_infix_expression(node, mut scope)
		}
		ast.IfExpression {
			return eval_if_expression(node, mut scope)
		}
		ast.CallExpression {
			return eval_call_expression(node, mut scope)
		}
		ast.IndexExpression {
			return eval_index_expression(node, mut scope)
		}
		else {
			return object.only_null
		}
	}
}
