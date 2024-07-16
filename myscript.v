module main

import os
import term
import ast
import eval
import lexer
import parser
import object
import object.builtin { get_builtin_scope }


fn main() {
	mut scope := object.Scope{get_builtin_scope(), {}}

	if os.args.len == 1 {
		start_interactive_mode(mut scope)
	}

	if os.exists(os.args[1]) && os.is_file(os.args[1]) {
		exec_file_script(os.args[1], mut scope)
		os.get_line()
	}

	match os.args[1] {
		'-v', '-version' {
			println('MyScript 0.0.1')
		}
		'-h', '-help' {
			println('MyScript使用方式: myscript.exe [option] [...args]')
			println('以下是允许的 option 参数:')
			println('-v|-version:        获取解释器当前版本')
			println('-h|-help:           获取解释器使用说明')
			println('-f|-file:           执行指定的脚本文件')
			println('-e|-execute:        直接执行提供的代码片段')
		}
		'-f', '-file' {
			if os.args.len >= 3 && os.exists(os.args[2]) && os.is_file(os.args[2]) {
				exec_file_script(os.args[2], mut scope)
			}
		}
		'-e', '-execute' {
			if os.args.len >= 3 {
				eval_script(os.args[2..].join(';'), mut scope) or {
					println(term.rgb(255, 0, 0, 'ERROR: ' + err.msg()))
					return
				}
			}
		}
		else {
			println(term.rgb(255, 0, 0, '无法识别的参数: "${os.args[1]}"'))
		}
	}
}

fn exec_file_script(path string, mut scope object.Scope) {
	if !os.exists(path) || !os.is_file(path) {
		println(term.rgb(255, 0, 0, 'ERROR: "${path}" 路径指向的文件不存在'))
		return
	}

	input := os.read_file(path) or {
		println(term.rgb(255, 0, 0, 'ERROR: 无法读取路径 "${path}" 指向的文件内容'))
		return
	}

	eval_script(input, mut scope) or {
		println(term.rgb(255, 0, 0, 'ERROR: ' + err.msg()))
		return
	}
}

fn start_interactive_mode(mut scope object.Scope) {
	for {

		mut input := os.input('>>> ')
		mut context := []string{}

		// 用于判断代码块是否闭合
		for c in input {
			if c == 123 {
				context << 'LEFT_BRACE'
			}

			if c == 125 {
				context.delete(0)
			}
		}

		for context.len != 0 {
			added := os.get_line()
			for c in added {
				if c == 123 {
					context << 'LEFT_BRACE'
				}

				if c == 125 && context.len > 0 {
					context.delete(0)
				}
			}
			input = input + added
		}

		list := eval_script(input, mut scope) or {
			println(term.rgb(255, 0, 0, 'ERROR: ' + err.msg()))
			continue
		}

		for obj in list {
			println(term.rgb(67, 142, 219, obj.str()))
		}
	}
}

fn eval_script(input string, mut scope object.Scope) ![]object.Object {
	mut list := []object.Object{}
	mut p := parser.new(lexer.new(input))!
	program := p.parse_program()!

	for stmt in program.body {
		result := eval.eval(stmt as ast.Node, mut scope)!

		if result != object.only_null {
			list << result
		}
	}

	return list
}
