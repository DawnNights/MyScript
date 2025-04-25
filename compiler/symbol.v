module compiler

import code

// 标识符作用域
pub enum SymbolScope {
	// 全局作用域
	global

	// 局部作用域
	local

	// 自由作用域
	free
}

// 标识符
pub struct Symbol {
pub:
	name  string
	index int
	scope SymbolScope
}

pub fn (s Symbol) opcode() code.Opcode {
	return match s.scope {
		.global { code.Opcode.get_global }
		.local { code.Opcode.get_local }
		.free { code.Opcode.get_free }
	}
}

// 符号表
pub struct SymbolTable {
pub mut:
	parent &SymbolTable = unsafe { nil }
	data   map[string]Symbol
	frees  []Symbol
}

pub fn (mut st SymbolTable) define(name string) Symbol {
	if name in st.data {
		return st.data[name]
	}

	symbol := Symbol{
		name:  name
		index: st.data.len
		scope: if st.parent == unsafe { nil } { .global } else { .local }
	}
	st.data[name] = symbol
	return symbol
}

fn (mut st SymbolTable) define_free(original Symbol) Symbol {
	st.frees << original
	st.data[original.name] = Symbol{
		name:  original.name
		index: st.frees.len - 1
		scope: .free
	}

	return st.data[original.name]
}

pub fn (mut st SymbolTable) lookup(name string) ?Symbol {
	if name in st.data {
		return st.data[name]
	}

	if st.parent != unsafe { nil } {
		symbol := st.parent.lookup(name) or { return none }
		if symbol.scope == .global {
			return symbol
		}

		return st.define_free(symbol)
	}
	return none
}
