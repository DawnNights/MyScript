module eval

import os
import ast
import lexer
import object
import parser

fn test_main() {
	mut scope := object.Scope{object.get_builtin_scope(), {}}
	for {
		print('>>> ')
		input := os.get_raw_line()
		mut p := parser.new(lexer.new(input)) or {
			println('ERROR: ' + err.msg())
			continue
		}

		program := p.parse_program() or {
			println('ERROR: ' + err.msg())
			continue
		}

		for stmt in program.body {
			result := eval(stmt as ast.Node, mut scope) or {
				println('ERROR: ' + err.msg())
				continue
			}

			if result != object.only_null {
				println(result)
			}
		}
	}
}