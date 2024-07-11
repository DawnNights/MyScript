module object

import hash

// Char 结构体表示布尔对象
pub struct Char {
	BaseObject
pub:
	value    rune
	datatype DataType = .char
}

pub fn (c Char) str() string {
	return '`${c.value.str()}`'
}

pub fn (c Char) to_int() !Object {
	return &Int{
		value: i64(c.value)
	}
}

pub fn (c Char) to_float() !Object {
	return &Float{
		value: f64(c.value)
	}
}

pub fn (c Char) to_bool() !Object {
	if c.value == 0 {
		return only_false
	}
	return only_true
}

pub fn (c Char) to_char() !Object {
	return &c
}

pub fn (c Char) to_string() !Object {
	return new_string(c.value.str())
}

pub fn (c Char) negate() !Object {
	return c.to_bool()!.negate()
}

pub fn (c Char) hash() !u64 {
	mut byte_array := []u8{len: 8}
	value := i64(c.value)

	for i := 0; i < 8; i++ {
		byte_array[i] = u8((value >> (i * 8)) & 0xFF)
	}

	return hash.sum64(byte_array, u64(1196620054))
}

pub fn (c Char) add(obj Object) !Object {
	return c.to_int()!.add(obj)
}

pub fn (c Char) sub(obj Object) !Object {
	return c.to_int()!.sub(obj)
}

pub fn (c Char) mul(obj Object) !Object {
	return c.to_int()!.mul(obj)
}

pub fn (c Char) div(obj Object) !Object {
	return c.to_int()!.div(obj)
}

pub fn (c Char) more_than(obj Object) !Object {
	return c.to_int()!.more_than(obj)
}

pub fn (c Char) less_than(obj Object) !Object {
	return c.to_int()!.less_than(obj)
}

pub fn (c Char) more_or_equal(obj Object) !Object {
	return c.to_int()!.more_or_equal(obj)
}

pub fn (c Char) less_or_equal(obj Object) !Object {
	return c.to_int()!.less_or_equal(obj)
}

pub fn (c Char) equal(obj Object) !Object {
	if obj is Char {
		if obj.value == c.value {
			return only_true
		}
	}

	return only_false
}

pub fn (c Char) not_equal(obj Object) !Object {
	if c.equal(obj)! == only_true {
		return only_false
	}

	return only_true
}
