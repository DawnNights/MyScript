module main

import os
import term
import object
import parser
import lexer
import compiler
import vm

fn main() {
	// 进入交互模式
	if os.args.len == 1 {
		mut contants := []object.Object{}
		mut globals := []object.Object{}
		mut symbol_table := compiler.SymbolTable{}
		for {
			start_interactive_mode(mut contants, mut globals, mut symbol_table) or {
				println(term.rgb(255, 0, 0, 'ERROR: ' + err.msg()))
			}
		}
	}

	// 编译代码文件
	if os.exists(os.args[1]) && os.is_file(os.args[1]) {
		exec_file_script(os.args[1]) or { println(term.rgb(255, 0, 0, 'ERROR: ' + err.msg())) }
		os.get_line()
		return
	}

	// 识别命令行参数
	match os.args[1] {
		'-v', '-version' {
			println('MyScript 0.0.2')
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
				exec_file_script(os.args[2]) or {
					println(term.rgb(255, 0, 0, 'error: ' + err.msg()))
					return
				}
			}
		}
		'-e', '-execute' {
			if os.args.len >= 3 {
				exec_script(os.args[2..].join(';')) or {
					println(term.rgb(255, 0, 0, 'error: ' + err.msg()))
					return
				}
			}
		}
		else {
			println(term.rgb(255, 0, 0, '无法识别的参数: "${os.args[1]}"'))
		}
	}
}

fn exec_file_script(path string) ! {
	input := os.read_file(path)!
	exec_script(input)!
}

fn exec_script(script string) ! {
	l := lexer.new(script)
	mut p := parser.new(l)!

	mut c := compiler.new()
	c.compile(p.parse_program()!)!

	bytecode := c.bytecode()

	mut v := vm.new(bytecode)
	v.run()!
}

fn start_interactive_mode(mut constants []object.Object, mut globals []object.Object, mut symbol_table compiler.SymbolTable) ! {
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

	l := lexer.new(input)
	mut p := parser.new(l)!

	mut c := compiler.new_with_state(symbol_table, constants)
	c.compile(p.parse_program()!)!

	bytecode := c.bytecode()
	constants = unsafe { bytecode.constants }
	symbol_table = unsafe { bytecode.symbol_table }

	mut v := vm.new_with_state(bytecode, globals)
	v.run()!
	if v.stack.len > 0 && v.stack[0] != object.only_null {
		println(term.rgb(67, 142, 219, v.stack[0].str()))
	}
	globals = unsafe { v.globals }
}
