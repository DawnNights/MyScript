module object

import hash
import lexer

// String 结构体表示字符串对象
pub struct String {
	BaseObject
pub:
	value    string
	unicodes []rune
	datatype DataType = .string
}

pub fn (s String) str() string {
	str := s.value.replace('"', '\\"')
	return '"${str}"'
}

pub fn (s String) to_bool() !Object {
	if s.unicodes.len == 0 {
		return only_false
	}

	return only_true
}

pub fn (s String) to_string() !Object {
	return &s
}

pub fn (s String) to_list() !Object {
	mut list := List{
		elems: []
	}

	for u in s.unicodes {
		list.elems << Object(&Char{
			value: u
		})
	}

	return list
}

pub fn (s String) negate() !Object {
	return s.to_bool()!.negate()
}

pub fn (s String) hash() !u64 {
	return hash.sum64_string(s.value, u64(77803247735))
}

pub fn (s String) add(obj Object) !Object {
	if obj is String {
		return new_string(s.value + obj.value)
	}

	return error('string 对象无法与 ${obj.datatype} 类型的对象相加')
}

pub fn (s String) mul(obj Object) !Object {
	if obj is Int {
		mut str := ''
		for i := 0; i < obj.value; i++ {
			str = str + s.value
		}
		return new_string(str)
	}

	return error('string 对象无法与 ${obj.datatype} 类型的对象相乘')
}

pub fn (s String) equal(obj Object) !Object {
	if obj is String{
		if s.value == obj.value {
			return only_true
		}
	}
	return only_false
}

pub fn (s String) not_equal(obj Object) !Object {
	if s.equal(obj)! == only_true {
		return only_false
	}
	return only_true
}

pub fn (s String) get(idx Object) !Object {
	if idx !is Int {
		return error('字符串的索引必须是 int 类型的值')
	}

	mut i := (idx as Int).value
	if i < 0 {
		i = s.unicodes.len + i
	}

	if i > s.unicodes.len - 1 || i < 0 {
		return error('索引的值超出了字符串的范围')
	}

	return Char{
		value: s.unicodes[i]
	}
}

pub fn new_string(str string) Object {
	return &String{
		value: str
		unicodes: lexer.string_to_runes(str)
	}
}
