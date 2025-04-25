module object

import ast
import code

// Function 结构体表示函数对象
pub struct Function {
	BaseObject
pub:
	params []&ast.Identifier   = []
	body   &ast.BlockStatement = unsafe { nil }
	scope  &Scope              = unsafe { nil }
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

// BuiltinFunction 结构体是内置的函数类型对象
pub struct BuiltinFunction {
	BaseObject
pub:
	str  string
	func fn (...Object) !Object = unsafe { nil }
}

pub fn (bf BuiltinFunction) str() string {
	return bf.str
}

pub fn (bf BuiltinFunction) to_string() !Object {
	return new_string(bf.str)
}

// CompiledFunction 结构体是存储指令序列的函数对象
pub struct CompiledFunction {
	BaseObject
pub:
	params []&ast.Identifier = []

	// 指令序列
	instructions []code.Instruction

	// 局部变量数量
	num_local int
}

pub fn (cf CompiledFunction) str() string {
	mut out := []string{}

	for p in cf.params {
		out << (*p).name + ' object'
	}

	return 'fn (${out.join(', ')}){${cf.instructions}}'
}

pub fn (cf CompiledFunction) to_string() !Object {
	return new_string(cf.str())
}

// ClosureFunction 结构体是函数闭包
pub struct ClosureFunction {
	BaseObject
pub:
	func  &CompiledFunction
	frees []Object
}

pub fn (cf ClosureFunction) str() string {
	return cf.func.str()
}

pub fn (cf ClosureFunction) to_string() !Object {
	return new_string(cf.str())
}
