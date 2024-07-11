module token

// Precedence 枚举定义了不同操作符的优先级顺序
pub enum Precedence {
	// 最低优先级
	lowest
	// 赋值操作
	assgin
	// 比较操作（如 ==, != 等）
	compare
	// 加减操作（如 +, -）
	sum
	// 乘除操作（如 *, /）
	product
	// 前缀操作（如 -x, !x 等）
	prefix
	// 中缀操作（如 a in b 等）
	infix
	// 函数调用
	call
	// 索引操作（如 array[index]）
	index
}

pub fn (p Precedence) int() int {
	return match p {
		.lowest { 0 }
		.assgin { 1 }
		.compare { 2 }
		.sum { 3 }
		.product { 4 }
		.prefix { 5 }
		.call { 6 }
		.infix { 7 }
		.index { 8 }
	}
}
