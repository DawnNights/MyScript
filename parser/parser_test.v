module parser

import ast
import lexer

fn test_main() {
	l := lexer.new(r'
null
123
0.123
true
false
fn add (x, y) { x }
[0, 1, 2, 3, 4]
{ab: 123, bc: 321}
')
	mut p := new(l)!
	program := p.parse_program()!

	for stmt in program.body {
		if stmt is ast.ExpressionStatement {
			println('${stmt.expression.type_name()}: ${stmt}')
		}
		
	}
}
