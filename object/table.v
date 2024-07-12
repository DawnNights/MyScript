module object

// Table 结构体表示字典对象
pub struct Table {
	BaseObject
pub mut:
	pairs map[u64][]Object = {}
}

pub fn (t Table) str() string {
	mut out := []string{}

	for _, pair in t.pairs {
		out << pair[0].str() + ':' + pair[1].str()
	}

	return '{' + out.join(', ') + '}'
}

pub fn (t Table) to_bool() !Object {
	if t.pairs.len == 0 {
		return only_false
	}

	return only_true
}

pub fn (t Table) negate() !Object {
	return t.to_bool()!.negate()
}

pub fn (t Table) to_string() !Object {
	return new_string(t.str())
}

pub fn (t Table) to_list() !Object {
	mut list := List{
		datatype: .list
		elems: []
	}

	for pair in t.pairs.values() {
		list.elems << List{
			datatype: .list
			elems: [pair[0], pair[1]]
		}
	}
	return list
}

pub fn (t Table) has(obj Object) !Object {
	hash := obj.hash() or { return only_false }

	if hash in t.pairs {
		return only_true
	}

	return only_false
}

pub fn (t Table) get(idx Object) !Object {
	hash := idx.hash() or {
		return error('${idx.datatype} 类型的对象不能作为 table 对象的键')
	}

	if hash in t.pairs {
		return t.pairs[hash][1]
	} else {
		return error('该 table 对象中不存在索引 `${idx}` 配对的值')
	}
}

pub fn (mut t Table) set(idx Object, obj Object) ! {
	hash := idx.hash() or {
		return error('${idx.datatype} 类型的对象不能作为 table 对象的键')
	}

	t.pairs[hash] = [idx, obj]
}
