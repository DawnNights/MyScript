module lexer

// 获取 utf8 字符编码大小
fn get_utf8_size(c u8) u8 {
	if (c & 0x80) == 0x00 {
		return 1
	}

	if (c & 0xe0) == 0xc0 {
		return 2
	}

	if (c & 0xf0) == 0xe0 {
		return 3
	}

	if (c & 0xf8) == 0xf0 {
		return 4
	}

	return 0
}

// 从 string 中获取一个 rune, 返回 rune 的值以及 rune 占用的 utf8 字节数
fn get_rune_from_string(str string) (rune, int) {
	match get_utf8_size(str[0]) {
		1 {
			return rune(str[0]), 1
		}
		2 {
			b1 := u32(str[0] & 0x1f)
			b2 := u32(str[1] & 0x3f)

			return rune(b1 << 6 | b2), 2
		}
		3 {
			b1 := u32(str[0] & 0x1f)
			b2 := u32(str[1] & 0x3f)
			b3 := u32(str[2] & 0x3f)

			return rune(b1 << 12 | b2 << 6 | b3), 3
		}
		4 {
			b1 := u32(str[0] & 0x1f)
			b2 := u32(str[1] & 0x3f)
			b3 := u32(str[2] & 0x3f)
			b4 := u32(str[3] & 0x3f)

			return rune(b1 << 18 | b2 << 12 | b3 << 6 | b4), 4
		}
		else {
			return 0, 0
		}
	}
}


// 判断是否为数字
fn rune_is_digit(r rune) bool {
	return `0` <= r && r <= `9`
}

// 判断是否为字母或下划线
fn rune_is_lettter(r rune) bool {
	return (`a` <= r && r <= `z`) || (`A` <= r && r <= `Z`) || r == `_`
}

// 判断是否为中文字符
fn rune_is_chinese(r rune) bool {
	return 0x4e00 <= r && r <= 0x9fff
}

// 判断是否为日文字符
fn rune_is_japanese(r rune) bool {
	return (0x3040 <= r && r <= 0x30ff) || (0x3400 <= r && r <= 0x4dbf)
}

// 判断是否为韩文字符
fn rune_is_korean(r rune) bool {
	return 0xac00 <= r && r <= 0xd7af
}

// 判断给定的 rune 是否是标点符号
fn rune_is_punctuation(r rune) bool {
	return (r >= 0x0020 && r <= 0x002F) || // 基本拉丁字母
	 (r >= 0x003A && r <= 0x0040) || // 拉丁-1 补充
	 (r >= 0x005B && r <= 0x0060) || // 拉丁-2 补充
	 (r >= 0x007B && r <= 0x00FF) || // 拉丁-3 补充
	 (r >= 0x2000 && r <= 0x206F) || // 常用标点
	 (r >= 0x2070 && r <= 0x209F) || // 上标和下标
	 (r >= 0x20A0 && r <= 0x20CF) || // 货币符号
	 (r >= 0x0300 && r <= 0x036F) || // 字母变音符号
	 (r >= 0x2200 && r <= 0x22FF) || // 数学运算符
	 (r >= 0x25A0 && r <= 0x25FF) || // 几何图形
	 (r >= 0x3000 && r <= 0x303F) || // 中日韩标点
	 (r >= 0xFF00 && r <= 0xFFEF) // 全角和半角形式
}

// 判断是否为合理的字面量(包括数字, 英文字母, 下划线, 中日韩文字符)
fn rune_is_valid(r rune) bool {
	return rune_is_lettter(r) || rune_is_chinese(r) || rune_is_japanese(r) || rune_is_korean(r)
		|| rune_is_digit(r)
}