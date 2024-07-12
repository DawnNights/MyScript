module object

// Scope 结构体表示作用域对象, 用于存储变量和其对应的对象
pub struct Scope {
pub:
	parent &Scope = unsafe { nil }
pub mut:
	store map[string]Object = {}
}

// get 方法从作用域中获取指定名称的对象
pub fn (s &Scope) get(name string) !Object {
	if name == 'null' {
		return only_null
	}

	if name !in s.store {
		if s.parent != unsafe { nil } {
			return s.parent.get(name)
		}

		return error('标识符 "${name}" 没有绑定的值')
	}

	return s.store[name]
}

// set 方法向作用域中设置指定名称的对象
pub fn (mut s Scope) set(name string, obj Object) {
	s.store[name] = obj
}

// del 方法从作用域中删除指定名称的变量和对象
pub fn (mut s Scope) del(name string) {
	s.store.delete(name)
}
