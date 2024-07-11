module object

import ast

// Function 结构体表示函数对象
pub struct Function {
	BaseObject
pub:
	params   []&ast.Identifier
	body     &ast.BlockStatement
	scope    &Scope
	datatype DataType = .function
}

pub fn (f Function) str() string {
	mut out := []string{}

	for p in f.params {
		out << (*p).name + ' object'
	}

	return 'fn (${out.join(', ')})'
}

pub fn (f Function) to_string() !Object {
	return new_string(f.str())
}