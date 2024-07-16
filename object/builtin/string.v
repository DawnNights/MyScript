module builtin

import lexer
import object

// string_split 函数按照给定的分割符，把字符串分割并返回字符串列表
fn string_split(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}
	if args.len != 2 {
		return error('内置字符串方法 "split" 应该接收 1 个传参')
	}

	sep := args[1]
	if sep is object.String {
		str := (args[0] as object.String).value
		mut list := &object.List{
			datatype: .list
			elems: []
		}

		for s in str.split(sep.value) {
			list.elems << object.new_string(s)
		}

		return list
	}

	return error('sep 参数必须是 string 类型的对象')
}

// string_lower 函数将字符串中的字母转为小写字母
fn string_lower(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}
	if args.len != 1 {
		return error('内置字符串方法 "lower" 没有传参')
	}

	str := (args[0] as object.String).value
	return object.new_string(str.to_lower())
}

// string_upper 函数将字符串中的字母转为大写字母
fn string_upper(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}
	if args.len != 1 {
		return error('内置字符串方法 "upper" 没有传参')
	}

	str := (args[0] as object.String).value
	return object.new_string(str.to_upper())
}

// string_count 函数统计字符串中子字符串的出现次数
fn string_count(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}
	if args.len != 2 {
		return error('内置字符串方法 "count" 应该接收 1 个传参')
	}

	sub_str := args[1]
	if sub_str is object.String {
		str := (args[0] as object.String).value
		return &object.Int{
			datatype: .int
			value: str.count(sub_str.value)
		}
	}

	return error('sub_str 参数必须是 string 类型的对象')
}

// string_index 函数返回子字符串在字符串中第一次出现的索引位置
fn string_index(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}
	if args.len != 2 {
		return error('内置字符串方法 "index" 应该接收 1 个传参')
	}

	sub_str := args[1]
	if sub_str is object.String {
		str := (args[0] as object.String).value
		index := str.index(sub_str.value) or {
			return &object.Int{
				datatype: .int
				value: -1
			}
		}

		return &object.Int{
			datatype: .int
			value: lexer.string_to_runes(str[0..index]).len
		}
	}

	return error('sub_str 参数必须是 string 类型的对象')
}

// string_replace 函数将替换字符串中所有的子字符串rep，替换为新的子字符串with并返回
fn string_replace(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}
	if args.len != 3 {
		return error('内置字符串方法 "replace" 应该接收 2 个传参')
	}

	rep := args[1]
	with := args[2]

	if rep is object.String && with is object.String {
		str := (args[0] as object.String).value
		return object.new_string(str.replace(rep.value, with.value))
	}

	return error('rep 参数和 with 参数必须都是 string 类型的对象')
}

// string_format 函数按顺序将参数替换为字符串中的格式化字符串
fn string_format(args ...object.Object) !object.Object {
	if args.len < 1 || args[0] !is object.String {
		return error('错误的字符串方法调用')
	}

	mut str := (args[0] as object.String).value
	for i := 1; i < args.len; i++ {
		obj := args[i]

		if obj is object.String {
			str = str.replace('{${i-1}}', obj.value)
		} else {
			str = str.replace('{${i-1}}', obj.str())
		}
		
	}

	return object.new_string(str)
}