module builtin

import os
import term
import time
import object

fn new_builtin(str string, func fn (...object.Object) !object.Object) object.Object {
	return &object.BuiltinFunction{
		datatype: .function
		str:      str
		func:     func
	}
}

// get_builtin_scope 获取内置作用域
pub fn get_builtin_scope() &object.Scope {
	mut scope := object.Scope{}

	// 为作用域添加内置函数
	scope.set('len', new_builtin('fn len(arg object) int', builtin_len))
	scope.set('type', new_builtin('fn type(arg object) string', builtin_type))
	scope.set('print', new_builtin('fn print(args ...object)', builtin_print))
	scope.set('println', new_builtin('fn println(args ...object)', builtin_println))
	scope.set('input', new_builtin('fn input(prompt string) string', builtin_input))
	scope.set('exit', new_builtin('fn exit(code int)', builtin_exit))
	scope.set('clone', new_builtin('fn clone(arg object) object', builtin_clone))
	scope.set('time', new_builtin('fn time() table', builtin_time))

	// 为作用域添加类型转换函数
	scope.set('bool', new_builtin('fn bool(arg object) bool', builtin_bool))
	scope.set('char', new_builtin('fn char(arg object) char', builtin_char))
	scope.set('float', new_builtin('fn float(arg object) float', builtin_float))
	scope.set('int', new_builtin('fn int(arg object) int', builtin_int))
	scope.set('list', new_builtin('fn list(arg object) list', builtin_list))
	scope.set('string', new_builtin('fn string(arg object) string', builtin_string))

	// 为作用域添加字符串内置方法
	scope.set('string.split', new_builtin('fn string.split(sep string) list', string_split))
	scope.set('string.lower', new_builtin('fn string.lower() string', string_lower))
	scope.set('string.upper', new_builtin('fn string.upper() string', string_upper))
	scope.set('string.count', new_builtin('fn string.count(sub_str string) int', string_count))
	scope.set('string.index', new_builtin('fn string.index(sub_str string) int', string_index))
	scope.set('string.replace', new_builtin('fn string.replace(rep string, with string) string',
		string_replace))
	scope.set('string.format', new_builtin('fn string.format(args ...object) string',
		string_format))

	// 为作用域添加列表内置方法
	scope.set('list.frist', new_builtin('fn list.frist() object', list_frist))
	scope.set('list.last', new_builtin('fn list.last() object', list_last))
	scope.set('list.reverse', new_builtin('fn list.reverse()', list_reverse))

	return &scope
}

// builtin_len 函数用于计算对象的长度
fn builtin_len(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "len" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	arg := args[0]

	match arg {
		object.String {
			return &object.Int{
				datatype: .int
				value:    arg.unicodes.len
			}
		}
		object.List {
			return &object.Int{
				datatype: .int
				value:    arg.elems.len
			}
		}
		object.Table {
			return &object.Int{
				datatype: .int
				value:    arg.pairs.len
			}
		}
		else {
			return error('${args[0].datatype} 类型的变量无法计算长度')
		}
	}
}

// builtin_type 函数用于获取对象类型字符串
fn builtin_type(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "type" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return object.new_string(args[0].datatype.str())
}

// builtin_print 函数用于打印对象
fn builtin_print(args ...object.Object) !object.Object {
	mut out := []string{}
	for arg in args {
		if arg is object.String {
			out << arg.value
		} else {
			out << arg.str()
		}
	}

	print(term.rgb(67, 142, 219, out.join(' ')))

	return object.only_null
}

// builtin_println 函数用于打印对象并换行
fn builtin_println(args ...object.Object) !object.Object {
	mut out := []string{}
	for arg in args {
		if arg is object.String {
			out << arg.value
		} else {
			out << arg.str()
		}
	}
	println(term.rgb(67, 142, 219, out.join(' ')))

	return object.only_null
}

// builtin_input 函数用于接收控制台输入并返回
fn builtin_input(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "input" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	prompt := args[0]
	if prompt is object.String {
		return object.new_string(os.input(prompt.value))
	}

	return error('prompt 参数必须是 string 类型的对象')
}

// builtin_exit 函数用于退出程序
fn builtin_exit(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "exit" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	code := args[0]
	if code is object.Int {
		exit(int(code.value))
	}

	return error('code 参数必须是 int 类型的对象')
}

// builtin_clone 函数用于克隆对象
fn builtin_clone(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "clone" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	arg := args[0]
	if arg is object.List {
		return &object.List{
			datatype: .list
			elems:    arg.elems.clone()
		}
	}

	if arg is object.Table {
		return &object.Table{
			datatype: .table
			pairs:    arg.pairs.clone()
		}
	}

	return arg
}

// builtin_time 函数用于获取时间
fn builtin_time(args ...object.Object) !object.Object {
	if args.len != 0 {
		return error('内置函数 "time" 没有传参')
	}

	now := time.now()
	unix := now.unix()
	mut pairs := map[u64][]object.Object{}

	pairs[4529160379687933655] = pair_str_int('year', now.year)
	pairs[6763692497213297715] = pair_str_int('month', now.month)
	pairs[6916137823918662716] = pair_str_int('day', now.day)
	pairs[6370219436190560914] = pair_str_int('hour', now.hour)
	pairs[8842083489598056460] = pair_str_int('minute', now.minute)
	pairs[5198021219645224562] = pair_str_int('second', now.second)
	pairs[10850537461975135521] = pair_str_int('unix', unix)

	return object.Table{
		datatype: .table
		pairs:    pairs
	}
}

fn pair_str_int(s string, i i64) []object.Object {
	return [
		object.String{
			datatype: .string
			value:    s
		},
		object.Int{
			datatype: .int
			value:    i
		},
	]
}

// 以下函数用于进行类型转换
fn builtin_bool(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "bool" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return args[0].to_bool()!
}

fn builtin_char(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "char" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return args[0].to_char()!
}

fn builtin_float(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "float" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return args[0].to_float()!
}

fn builtin_int(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "int" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return args[0].to_int()!
}

fn builtin_list(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "list" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return args[0].to_list()!
}

fn builtin_string(args ...object.Object) !object.Object {
	if args.len != 1 {
		return error('内置函数 "string" 应该接收 1 个传参, 而不是 ${args.len} 个')
	}

	return args[0].to_string()!
}
