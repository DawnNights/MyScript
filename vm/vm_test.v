module vm

import compiler
import lexer
import parser
import object

fn test_main() ! {
	l := lexer.new(r"

fibonacci = fn (x) {
  if (x == 0) {
    return 0
  }

  if (x == 1) {
    return 1
  }

  return fibonacci(x - 1) + fibonacci(x - 2)
}

num = 30
start = time()
result = fibonacci(num)
end = time()

println('计算fibonacci({0})的结果为{1}，用时{2}秒'.format(num, result, end.unix - start.unix))
println(fibonacci)
")
	mut p := parser.new(l)!

	mut c := compiler.new()
	c.compile(p.parse_program()!)!

	bytecode := c.bytecode()

	mut v := new(bytecode)
	v.run() or { println('Error: ${err}') }
	if v.stack.len > 0 && v.stack[0] != object.only_null {
		println(v.stack[0].str())
	}
}
