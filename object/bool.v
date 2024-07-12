module object

import hash

// 唯一布尔值
pub const only_true = Object(&Bool{
	datatype: .bool
	value: true
})
pub const only_false = Object(&Bool{
	datatype: .bool
	value: false
})

// Bool 结构体表示布尔对象
pub struct Bool {
	BaseObject
pub:
	value bool
}

pub fn (b Bool) str() string {
	return b.value.str()
}

pub fn (b Bool) to_int() !Object {
	return &Int{
		datatype: .int
		value: i64(b.value)
	}
}

pub fn (b Bool) to_float() !Object {
	return &Float{
		datatype: .float
		value: f64(b.value)
	}
}

pub fn (b Bool) to_bool() !Object {
	return &b
}

pub fn (b Bool) to_string() !Object {
	return new_string(b.value.str())
}

pub fn (b Bool) negate() !Object {
	if b.value {
		return object.only_false
	}
	return object.only_true
}

pub fn (b Bool) hash() !u64 {
	if b.value {
		return hash.sum64_string('true', u64(98399734576))
	}

	return hash.sum64_string('false', u64(37914743044))
}

pub fn (b Bool) add(obj Object) !Object {
	return b.to_int()!.add(obj)
}

pub fn (b Bool) sub(obj Object) !Object {
	return b.to_int()!.sub(obj)
}

pub fn (b Bool) mul(obj Object) !Object {
	return b.to_int()!.mul(obj)
}

pub fn (b Bool) div(obj Object) !Object {
	return b.to_int()!.div(obj)
}

pub fn (b Bool) more_than(obj Object) !Object {
	return b.to_int()!.more_than(obj)
}

pub fn (b Bool) less_than(obj Object) !Object {
	return b.to_int()!.less_than(obj)
}

pub fn (b Bool) more_or_equal(obj Object) !Object {
	return b.to_int()!.more_or_equal(obj)
}

pub fn (b Bool) less_or_equal(obj Object) !Object {
	return b.to_int()!.less_or_equal(obj)
}

pub fn (b Bool) equal(obj Object) !Object {
	if obj is Bool {
		if obj.value == b.value {
			return object.only_true
		}
	}

	return object.only_false
}

pub fn (b Bool) not_equal(obj Object) !Object {
	if b.equal(obj)! == object.only_true {
		return object.only_false
	}

	return object.only_true
}

fn get_only_bool(b bool) Object {
	if b {
		return object.only_true
	}

	return object.only_false
}
