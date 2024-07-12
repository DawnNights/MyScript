module object

import hash

// Int 结构体表示整数对象
pub struct Int {
	BaseObject
pub:
	value    i64
}

pub fn (i Int) str() string {
	return i.value.str()
}

pub fn (i Int) to_int() !Object {
	return &i
}

pub fn (i Int) to_float() !Object {
	return &Float{
		datatype: .float
		value: f64(i.value)
	}
}

pub fn (i Int) to_bool() !Object {
	if i.value == 0 {
		return only_false
	}

	return only_true
}

pub fn (i Int) to_char() !Object {
	return &Char{
		datatype: .char
		value: rune(i.value)
	}
}

pub fn (i Int) to_string() !Object {
	return new_string(i.value.str())
}

pub fn (i Int) negate() !Object {
	return i.to_bool()!.negate()
}

pub fn (i Int) negative() !Object {
	return &Int{
		datatype: .int
		value: -i.value
	}
}

pub fn (i Int) hash() !u64 {
	mut byte_array := []u8{len: 8}

	for a := 0; a < 8; a++ {
		byte_array[a] = u8((i.value >> (a * 8)) & 0xFF)
	}

	return hash.sum64(byte_array, u64(210957157742))
}

pub fn (i Int) add(obj Object) !Object {
	return match obj {
		Float {
			Object(&Float{
				datatype: .float
				value: i.value + obj.value
			})
		}
		Int {
			Object(&Int{
				datatype: .int
				value: i.value + obj.value
			})
		}
		Char {
			Object(&Int{
				datatype: .int
				value: i.value + obj.value
			})
		}
		Bool {
			Object(&Int{
				datatype: .int
				value: i.value + i64(obj.value)
			})
		}
		else {
			error('float 对象无法与 ${obj.datatype} 类型的对象相加')
		}
	}
}

pub fn (i Int) sub(obj Object) !Object {
	return match obj {
		Float {
			Object(&Float{
				datatype: .float
				value: i.value - obj.value
			})
		}
		Int {
			Object(&Int{
				datatype: .int
				value: i.value - obj.value
			})
		}
		Char {
			Object(&Int{
				datatype: .int
				value: i.value - obj.value
			})
		}
		Bool {
			Object(&Int{
				datatype: .int
				value: i.value - i64(obj.value)
			})
		}
		else {
			error('float 对象无法与 ${obj.datatype} 类型的对象相减')
		}
	}
}

pub fn (i Int) mul(obj Object) !Object {
	return match obj {
		Float {
			Object(&Float{
				datatype: .float
				value: i.value * obj.value
			})
		}
		Int {
			Object(&Int{
				datatype: .int
				value: i.value * obj.value
			})
		}
		Char {
			Object(&Int{
				datatype: .int
				value: i.value * obj.value
			})
		}
		Bool {
			if obj.value {
				Object(&i)
			} else {
				Object(&Int{
				datatype: .int
					value: 0
				})
			}
		}
		else {
			error('float 对象无法与 ${obj.datatype} 类型的对象相乘')
		}
	}
}

pub fn (i Int) div(obj Object) !Object {
	match obj {
		Float {
			if obj.value == 0.00 {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&Float{
				datatype: .float
				value: i.value / obj.value
			})
		}
		Int {
			if obj.value == 0 {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&Int{
				datatype: .int
				value: i.value / obj.value
			})
		}
		Char {
			if obj.value == 0 {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&Int{
				datatype: .int
				value: i.value / obj.value
			})
		}
		Bool {
			if !obj.value {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&i)
		}
		else {
			return error('float 对象无法与 ${obj.datatype} 类型的对象相乘')
		}
	}
}

pub fn (i Int) more_than(obj Object) !Object {
	return match obj {
		Float { get_only_bool(i.value > obj.value) }
		Int { get_only_bool(i.value > obj.value) }
		Char { get_only_bool(i.value > obj.value) }
		Bool { get_only_bool(i.value > f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (i Int) less_than(obj Object) !Object {
	return match obj {
		Float { get_only_bool(i.value < obj.value) }
		Int { get_only_bool(i.value < obj.value) }
		Char { get_only_bool(i.value < obj.value) }
		Bool { get_only_bool(i.value < f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (i Int) more_or_equal(obj Object) !Object {
	return match obj {
		Float { get_only_bool(i.value >= obj.value) }
		Int { get_only_bool(i.value >= obj.value) }
		Char { get_only_bool(i.value >= obj.value) }
		Bool { get_only_bool(i.value >= f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (i Int) less_or_equal(obj Object) !Object {
	return match obj {
		Float { get_only_bool(i.value <= obj.value) }
		Int { get_only_bool(i.value <= obj.value) }
		Char { get_only_bool(i.value <= obj.value) }
		Bool { get_only_bool(i.value <= f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (i Int) equal(obj Object) !Object {
	if obj is Float {
		if obj.value == i.value {
			return only_true
		}
	} else if obj is Int {
		if obj.value == i.value {
			return only_true
		}
	}

	return only_false
}

pub fn (i Int) not_equal(obj Object) !Object {
	if i.equal(obj)! == only_true {
		return only_false
	}

	return only_true
}
