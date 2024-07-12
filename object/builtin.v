module object

pub struct BuiltinFunction {
	BaseObject
pub:
	str      string
	func     fn (...Object) !Object = unsafe { nil }
}

pub fn (bf BuiltinFunction) str() string {
	return bf.str
}

pub fn (bf BuiltinFunction) to_string() !Object {
	return new_string(bf.str)
}

// 获取内置函数作用域
pub fn get_builtin_scope() &Scope {
	mut scope := Scope{unsafe { nil }, {}}

	// 实现 len 函数用于获取对象的长度
	scope.set('len', BuiltinFunction{
		datatype: .function
		str: 'fn len(arg object) int'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "len" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			arg := args[0]
			match arg {
				String {
					return Object(&Int{
						datatype: .int
						value: arg.unicodes.len
					})
				}
				List {
					return Object(&Int{
						datatype: .int
						value: arg.elems.len
					})
				}
				Table {
					return Object(&Int{
						datatype: .int
						value: arg.pairs.len
					})
				}
				else {
					return error('${args[0].datatype} 类型的变量无法计算长度')
				}
			}
		}
	})

	// 实现 type 函数获取对象类型字符串
	scope.set('type', BuiltinFunction{
		datatype: .function
		str: 'fn type(arg object) string'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "type" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return new_string(args[0].datatype.str())
		}
	})

	// 实现 bool 函数将对象转为布尔对象
	scope.set('bool', BuiltinFunction{
		datatype: .function
		str: 'fn bool(arg object) bool'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "bool" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return args[0].to_bool()!
		}
	})

	// 实现 char 函数将对象转为字符对象
	scope.set('char', BuiltinFunction{
		datatype: .function
		str: 'fn char(arg object) char'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "char" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return args[0].to_char()!
		}
	})

	// 实现 float 函数将对象转为浮点数对象
	scope.set('float', BuiltinFunction{
		datatype: .function
		str: 'fn float(arg object) float'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "float" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return args[0].to_float()!
		}
	})

	// 实现 int 函数将对象转为整数对象
	scope.set('int', BuiltinFunction{
		datatype: .function
		str: 'fn int(arg object) int'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "int" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return args[0].to_int()!
		}
	})

	// 实现 list 函数将对象转为列表对象
	scope.set('list', BuiltinFunction{
		datatype: .function
		str: 'fn list(arg object) list'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "list" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return args[0].to_list()!
		}
	})

	// 实现 string 函数将对象转为字符串对象
	scope.set('string', BuiltinFunction{
		datatype: .function
		str: 'fn string(arg object) string'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "string" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			return args[0].to_string()!
		}
	})

	// 实现 clone 函数对引用对象进行克隆
	scope.set('clone', BuiltinFunction{
		datatype: .function
		str: 'fn clone(arg object) object'
		func: fn (args ...Object) !Object {
			if args.len != 1 {
				return error('内置函数 "clone" 只接收 1 个传参, 而不是 ${args.len} 个')
			}

			arg := args[0]
			if arg is List{
				return List{
					datatype: .list
					elems: arg.elems.clone()
				}
			}

			if arg is Table{
				return Table{
					datatype: .table
					pairs: arg.pairs.clone()
				}
			}

			return arg
		}
	})

	return &scope
}
