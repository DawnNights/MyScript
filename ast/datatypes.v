module ast

// Identifier 标识符结构体, 表示程序中的变量或函数名等
pub struct Identifier {
	BaseExpression
pub:
	name string
}

// Int 整数结构体, 表示程序中的整数常量
pub struct Int {
	BaseExpression
pub:
	value i64
}

// Float 浮点数结构体, 表示程序中的浮点数常量
pub struct Float {
	BaseExpression
pub:
	value f64
}

// Bool 布尔值结构体, 表示程序中的布尔常量（true 或 false）
pub struct Bool {
	BaseExpression
pub:
	value bool
}

// Char 字符结构体, 表示程序中的字符常量
pub struct Char {
	BaseExpression
pub:
	value rune
}

// String 字符串结构体, 表示程序中的字符串常量
pub struct String {
	BaseExpression
pub:
	value string
}

pub fn (s String) str() string {
	str := s.value.replace('"', '\\"')
	return '"${str}"'
}

// Function 函数结构体, 表示一个包含函数名、参数列表和函数体的函数定义
pub struct Function {
	BaseExpression
pub mut:
	name   &Identifier     = unsafe { nil }
	params []&Identifier   = []
	body   &BlockStatement = unsafe { nil }
}

pub fn (f Function) str() string {
	mut params := []string{}

	for p in f.params {
		params << p.name
	}

	mut name := ''
	if f.name != unsafe { nil } {
		name = f.name.name
	}

	return 'fn ${name} (${params.join(', ')}) { ${(*f.body).str()} }'
}

// List 列表结构体, 表示一个包含多个表达式元素的列表定义
pub struct List {
	BaseExpression
pub mut:
	elems []Expression = []
}

fn (l List) str() string {
	mut elems := []string{}

	for elem in l.elems {
		elems << elem.str()
	}

	return '[' + elems.join(', ') + ']'
}

// Table 字典结构体, 表示一个包含键值对的表定义
pub struct Table {
	BaseExpression
pub mut:
	pairs [][]Expression = []
}

fn (t Table) str() string {
	mut out := []string{}

	for k_and_v in t.pairs {
		out << '${k_and_v[0]}:${k_and_v[1]}'
	}

	return '{' + out.join(', ') + '}'
}
