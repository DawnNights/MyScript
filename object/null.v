module object

// 唯一空值
pub const only_null = Object(&Null{datatype: .null})

// Null 结构体表示空对象
pub struct Null {
	BaseObject
}

fn (n Null) str() string {
	return 'null'
}

pub fn (n Null) equal(obj Object) !Object {
	if obj == object.only_null {
		return only_true
	}

	return only_false
}

pub fn (n Null) not_equal(obj Object) !Object {
	if obj != object.only_null {
		return only_true
	}

	return only_false
}
