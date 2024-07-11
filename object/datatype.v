module object

// DataType枚举
// 该枚举定义了求值对象的所有数据类型
pub enum DataType {
	// 整数类型
	int
	// 浮点数类型
	float
	// 布尔类型
	bool
	// 字符类型
	char
	// 字符串类型
	string
	// 函数类型
	function
	// 列表类型
	list
	// 字典类型
	table
	// 空类型
	null
	// 内置函数类型
	builtin_function
}

// 该方法返回 DataType 枚举成员的字符串表示形式
pub fn (dt DataType) str() string {
	return match dt {
		.int { 'int' }
		.float { 'float' }
		.bool { 'bool' }
		.char { 'char' }
		.string { 'string' }
		.function { 'function' }
		.list { 'list' }
		.table { 'table' }
		.null { 'null' }
		.builtin_function { 'function' }
	}
}
