module object

// Range 结构体表示范围对象
pub struct Range {
	BaseObject
pub:
	start    i64
	end      i64
}

pub fn (r Range) str() string {
	return '${r.start}≤..<${r.end}'
}

pub fn (r Range) to_string() !Object {
	return new_string(r.str())
}

pub fn (r Range) to_list() !Object {
	mut list := List{
		datatype: .list
		elems: []
	}

	for i := r.start; i < r.end; i++ {
		list.elems << Int{
			datatype: .int
			value: i
		}
	}

	return list
}

pub fn (r Range) equal(obj Object) !Object {
	if obj is Range {
		if obj.start == r.start && obj.end == r.end {
			return only_true
		}
	}
	return only_false
}

pub fn (r Range) not_equal(obj Object) !Object {
	if r.equal(obj)! == only_true {
		return only_false
	}
	return only_true
}

pub fn (r Range) has(obj Object) !Object {
	if obj is Int {
		if obj.value >= r.start && obj.value < r.end {
			return only_true
		}
	}

	return only_false
}
