module parser

import ast
import lexer

fn test_main() {
	l := lexer.new(r'
null;
123;
0.123;
true;
false;
`H`;
"Hello, World";
fn add (x, y) { return x + y };
[0, 1, 2, 3, 4];
{ab: abc(), bc: 321};
1 + 1 * 2;
(1 + 1) * 2;
!123;
-321;
if (true) { 123 };
if (false) { 123 } else { 456 };
1 + 1;
2 - 1;
2 * 2;
8 / 4;
1 < 2;
1 > 3;
1 <= 3;
2 >= 0;
1 == 1;
1 != 9;
0 .. 9;
1 in [0, 1, 2, 3, 4];
add(1, 2, 3, 4);
iter[123];
iter.name;
a.hello();
')
	mut p := new(l)!
	program := p.parse_program() or { 
		println("ERROR: " + err.msg())
		return
	 }

	for stmt in program.body {
		if stmt is ast.ExpressionStatement {
			println('${stmt.expression.type_name()}: ${stmt}')
		}
		
	}
}
