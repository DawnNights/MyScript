module code

// Opcode 操作码枚举
pub enum Opcode {
	// 占位指令
	nop

	// 获取常量
	const

	// 出栈指令
	pop

	// 加法运算
	add

	// 减法运算
	sub

	// 乘法运算
	mul

	// 除法运算
	div

	// 范围运算
	range

	// 取反运算
	negate

	// 取负运算
	negative

	// 大于比较
	more_than

	// 大于等于
	more_or_equal

	// 等于比较
	equal

	// 不等比较
	not_equal

	// 直接跳转
	jmp

	// 条件跳转
	jnt

	// 创建列表
	list

	// 创建字典
	table

	// 全局取值
	get_global

	// 全局赋值
	set_global

	// 局部取值
	get_local

	// 局部赋值
	set_local

	// 索引取值
	index_get

	// 索引赋值
	index_set

  // 是否存在
  index_has

	// 调用指令
	call

	// 返回指令
	return

  // 创建闭包
  closure

  // 自由变量
  get_free
}

// Instruction 机器指令结构体
pub struct Instruction {
pub:
	// 操作码
	code Opcode

	// 操作数
	operands []int
}

pub fn (ins Instruction) str() string {
	if ins.operands.len == 0 {
		return '${ins.code}'
	}

	operands := '${ins.operands}'.trim('[]')
	return '${ins.code}(${operands})'
}

pub fn (list []Instruction) str() string {
	mut outs := []string{}
	for ins in list {
		outs << ins.str()
	}

	return outs.join('->')
}
