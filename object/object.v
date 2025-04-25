module object

// Object 接口定义了一组通用方法, 用于表示和操作不同数据类型的对象
pub interface Object {
	// 该对象的数据类型
	datatype DataType
	// 返回该对象的字符串表示形式
	str() string
	// 将该对象转换为整数对象
	to_int() !Object
	// 将该对象转换为浮点数对象
	to_float() !Object
	// 将该对象转换为布尔对象
	to_bool() !Object
	// 将该对象转换为字符对象
	to_char() !Object
	// 将该对象转换为字符串对象
	to_string() !Object
	// 将该对象转换为列表对象
	to_list() !Object
	// 返回该对象的取反值
	negate() !Object
	// 返回该对象的负值
	negative() !Object
	// 返回该对象的哈希值
	hash() !u64
	// 返回该对象与另一个对象相加的结果
	add(Object) !Object
	// 返回该对象与另一个对象相减的结果
	sub(Object) !Object
	// 返回该对象与另一个对象相乘的结果
	mul(Object) !Object
	// 返回该对象与另一个对象相除的结果
	div(Object) !Object
	// 判断该对象是否大于另一个对象
	more_than(Object) !Object
	// 判断该对象是否小于另一个对象
	less_than(Object) !Object
	// 判断该对象是否大于或等于另一个对象
	more_or_equal(Object) !Object
	// 判断该对象是否小于或等于另一个对象
	less_or_equal(Object) !Object
	// 判断该对象是否等于另一个对象
	equal(Object) !Object
	// 判断该对象是否不等于另一个对象
	not_equal(Object) !Object
	// 判断该对象是否包含指定对象
	has(Object) !Object
	// 获取该对象中指定键的值
	get(Object) !Object
	// 设置该对象中指定键的值
mut:
	set(Object, Object) !
}

// BaseObject 结构体是所有对象的基类
pub struct BaseObject {
pub:
	datatype DataType @[required]
}

pub fn (bo BaseObject) str() string {
	return bo.datatype.str()
}

pub fn (bo BaseObject) to_int() !Object {
	return error('${bo.datatype} 类型的对象无法转换成 int 类型的对象')
}

pub fn (bo BaseObject) to_float() !Object {
	return error('${bo.datatype} 类型的对象无法转换成 float 类型的对象')
}

pub fn (bo BaseObject) to_bool() !Object {
	return error('${bo.datatype} 类型的对象无法转换成 bool 类型的对象')
}

pub fn (bo BaseObject) to_char() !Object {
	return error('${bo.datatype} 类型的对象无法转换成 char 类型的对象')
}

pub fn (bo BaseObject) to_string() !Object {
	return error('${bo.datatype} 类型的对象无法转换成 string 类型的对象')
}

pub fn (bo BaseObject) to_list() !Object {
	return error('${bo.datatype} 类型的对象无法转换成 list 类型的对象')
}

pub fn (bo BaseObject) negate() !Object {
	return error('${bo.datatype} 类型的对象无法进行取反运算')
}

pub fn (bo BaseObject) negative() !Object {
	return error('${bo.datatype} 类型的对象无法进行取负运算')
}

pub fn (bo BaseObject) hash() !u64 {
	return error('${bo.datatype} 类型的对象无法进行哈希运算')
}

pub fn (bo BaseObject) add(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法进行加法运算')
}

pub fn (bo BaseObject) sub(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法进行减法运算')
}

pub fn (bo BaseObject) mul(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法进行乘法运算')
}

pub fn (bo BaseObject) div(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法进行除法运算')
}

pub fn (bo BaseObject) more_than(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法与 ${obj.datatype} 类型的对象进行比较')
}

pub fn (bo BaseObject) less_than(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法与 ${obj.datatype} 类型的对象进行比较')
}

pub fn (bo BaseObject) more_or_equal(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法与 ${obj.datatype} 类型的对象进行比较')
}

pub fn (bo BaseObject) less_or_equal(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法与 ${obj.datatype} 类型的对象进行比较')
}

pub fn (bo BaseObject) equal(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法与 ${obj.datatype} 类型的对象进行比较')
}

pub fn (bo BaseObject) not_equal(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法与 ${obj.datatype} 类型的对象进行比较')
}

pub fn (bo BaseObject) has(obj Object) !Object {
	return error('${bo.datatype} 类型的对象无法判断是否包含其它对象')
}

pub fn (bo BaseObject) get(idx Object) !Object {
	return error('${bo.datatype} 类型的对象无法通过索引获取值')
}

pub fn (mut bo BaseObject) set(idx Object, obj Object) ! {
	return error('${bo.datatype} 类型的对象无法通过索引设置值')
}

// ReturnObject 结构体是 return 语句返回对象的封装
pub struct ReturnObject {
	BaseObject
pub:
	value Object
}

// BreakObject 结构体是对 break 语句的封装对象, 无实际作用
pub struct BreakObject {
	BaseObject
}

// ContinueObject 结构体是对 continue 语句的封装对象, 无实际作用
pub struct ContinueObject {
	BaseObject
}

