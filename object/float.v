module object

import hash

// Float 结构体表示浮点数对象
pub struct Float {
	BaseObject
pub:
	value    f64
}

pub fn (f Float) str() string {
	return f.value.str()
}

pub fn (f Float) to_int() !Object {
	return &Int{
		datatype: .int
		value: i64(f.value)
	}
}

pub fn (f Float) to_float() !Object {
	return &f
}

pub fn (f Float) to_bool() !Object {
	if f.value == 0 {
		return only_false
	}

	return only_true
}

pub fn (f Float) to_string() !Object {
	return new_string(f.value.str())
}

pub fn (f Float) negate() !Object {
	return f.to_bool()!.negate()
}

pub fn (f Float) negative() !Object {
	return &Float{
		datatype: .float
		value: -f.value
	}
}

pub fn (f Float) hash() !u64 {
	mut byte_array := []u8{len: 8}
	value := i64(f.value)

	for i := 0; i < 8; i++ {
		byte_array[i] = u8((value >> (i * 8)) & 0xFF)
	}

	return hash.sum64(byte_array, u64(9771919965))
}

pub fn (f Float) add(obj Object) !Object {
	return match obj {
		Float {
			Object(&Float{
				datatype: .float
				value: f.value + obj.value
			})
		}
		Int {
			Object(&Float{
				datatype: .float
				value: f.value + obj.value
			})
		}
		Char {
			Object(&Float{
				datatype: .float
				value: f.value + f64(obj.value)
			})
		}
		Bool {
			Object(&Float{
				datatype: .float
				value: f.value + f64(obj.value)
			})
		}
		else {
			error('float 对象无法与 ${obj.datatype} 类型的对象相加')
		}
	}
}

pub fn (f Float) sub(obj Object) !Object {
	return match obj {
		Float {
			Object(&Float{
				datatype: .float
				value: f.value - obj.value
			})
		}
		Int {
			Object(&Float{
				datatype: .float
				value: f.value - obj.value
			})
		}
		Char {
			Object(&Float{
				datatype: .float
				value: f.value - f64(obj.value)
			})
		}
		Bool {
			Object(&Float{
				datatype: .float
				value: f.value - f64(obj.value)
			})
		}
		else {
			error('float 对象无法与 ${obj.datatype} 类型的对象相减')
		}
	}
}

pub fn (f Float) mul(obj Object) !Object {
	return match obj {
		Float {
			Object(&Float{
				datatype: .float
				value: f.value * obj.value
			})
		}
		Int {
			Object(&Float{
				datatype: .float
				value: f.value * obj.value
			})
		}
		Char {
			Object(&Float{
				datatype: .float
				value: f.value * f64(obj.value)
			})
		}
		Bool {
			if obj.value {
				Object(&f)
			} else {
				Object(&Float{
					datatype: .float
					value: 0
				})
			}
		}
		else {
			error('float 对象无法与 ${obj.datatype} 类型的对象相乘')
		}
	}
}

pub fn (f Float) div(obj Object) !Object {
	match obj {
		Float {
			if obj.value == 0.00 {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&Float{
				datatype: .float
				value: f.value / obj.value
			})
		}
		Int {
			if obj.value == 0 {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&Float{
				datatype: .float
				value: f.value / obj.value
			})
		}
		Char {
			if obj.value == 0 {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&Float{
				datatype: .float
				value: f.value / f64(obj.value)
			})
		}
		Bool {
			if !obj.value {
				return error('进行除法运算时, 除数不能为 0')
			}

			return Object(&f)
		}
		else {
			return error('float 对象无法与 ${obj.datatype} 类型的对象相乘')
		}
	}
}

pub fn (f Float) more_than(obj Object) !Object {
	return match obj {
		Float { get_only_bool(f.value > obj.value) }
		Int { get_only_bool(f.value > obj.value) }
		Char { get_only_bool(f.value > obj.value) }
		Bool { get_only_bool(f.value > f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (f Float) less_than(obj Object) !Object {
	return match obj {
		Float { get_only_bool(f.value < obj.value) }
		Int { get_only_bool(f.value < obj.value) }
		Char { get_only_bool(f.value < obj.value) }
		Bool { get_only_bool(f.value < f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (f Float) more_or_equal(obj Object) !Object {
	return match obj {
		Float { get_only_bool(f.value >= obj.value) }
		Int { get_only_bool(f.value >= obj.value) }
		Char { get_only_bool(f.value >= obj.value) }
		Bool { get_only_bool(f.value >= f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (f Float) less_or_equal(obj Object) !Object {
	return match obj {
		Float { get_only_bool(f.value <= obj.value) }
		Int { get_only_bool(f.value <= obj.value) }
		Char { get_only_bool(f.value <= obj.value) }
		Bool { get_only_bool(f.value <= f64(obj.value)) }
		else { error('float 对象无法与 ${obj.datatype} 类型的对象比较') }
	}
}

pub fn (f Float) equal(obj Object) !Object {
	if obj is Float {
		if obj.value == f.value {
			return only_true
		}
	} else if obj is Int {
		if obj.value == f.value {
			return only_true
		}
	}

	return only_false
}

pub fn (f Float) not_equal(obj Object) !Object {
	if f.equal(obj)! == only_true {
		return only_false
	}

	return only_true
}
