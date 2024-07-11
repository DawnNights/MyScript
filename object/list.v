module object

// List 结构体表示列表对象
pub struct List {
	BaseObject
pub mut:
	elems []Object
pub:
	datatype DataType = .list
}

pub fn (l List) str() string {
	mut out := []string{}

	for elem in l.elems {
		out << elem.str()
	}

	return '[' + out.join(', ') + ']'
}

pub fn (l List) to_bool() !Object {
	if l.elems.len == 0 {
		return only_false
	}

	return only_true
}

pub fn (l List) to_string() !Object {
	return new_string(l.str())
}

pub fn (l List) to_list() !Object {
	return &l
}

pub fn (l List) negate() !Object {
	return l.to_bool()!.negate()
}

pub fn (l List) has(obj Object) !Object {
	for elem in l.elems {
		if elem == obj {
			return only_true
		}
	}

	return only_false
}

pub fn (l List) get(idx Object) !Object {
	if idx !is Int {
		return error('获取值时, 列表的索引必须是 int 类型的值')
	}

	if idx is Int {
		mut i := idx.value
		if i < 0 {
			i = l.elems.len + i
		}

		if i > l.elems.len - 1 || i < 0 {
			return error('索引的值超出了列表的范围')
		}

		return l.elems[i]
	}

	return error('')
}

pub fn (mut l List) set(idx Object, obj Object) ! {
	if idx !is Int {
		return error('设置值时, 列表的索引必须是 int 类型的值')
	}

	mut i := (idx as Int).value
	if i < 0 {
		i = l.elems.len + i
	}

	if i > l.elems.len - 1 || i < 0 {
		return error('索引的值超出了列表的范围')
	}

	if obj == only_null {
		l.elems.delete(i)
	} else {
		l.elems[i] = obj
	}
}
