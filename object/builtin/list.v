module builtin

import object

// list_frist 函数返回列表的第一个元素
fn list_frist(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.List {
		return error('错误的列表方法调用')
	}
	if args.len != 1 {
		return error('内置列表方法 "frist" 没有传参')
	}

	list := args[0] as object.List
	if list.elems.len == 0 {
		return error('列表元素为空')
	}

	return list.elems[0]
}

// list_last 函数返回列表的最后一个
fn list_last(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.List {
		return error('错误的列表方法调用')
	}
	if args.len != 1 {
		return error('内置列表方法 "last" 没有传参')
	}

	list := args[0] as object.List
	if list.elems.len == 0 {
		return error('列表元素为空')
	}

	return list.elems.last()
}

// list_reverse 函数对列表元素进行反转
fn list_reverse(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.List {
		return error('错误的列表方法调用')
	}
	if args.len != 1 {
		return error('内置列表方法 "reverse" 没有传参')
	}

	mut list := args[0] as object.List
  list.elems.reverse_in_place()

	return object.only_null
}
