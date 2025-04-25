
# MyScript

`MyScript`是一门基于[`V`](https://github.com/vlang/v)语言实现的脚本语言。

该项目并不具备实用价值，只是本菜鸟处出于兴趣对编译原理基础知识的一些实践，特性尚未完善，bug多的飞起，需要很多时间慢慢打磨。以下是`MyScript`内容的介绍：

## 基本类型

`MyScript`是一门动态类型，脚本型语言，以下是内置的基本类型：

### bool 布尔类型
- `bool`类型的值只能是`true`或`false`，表示逻辑上的真与假。
- 示例:
  ```v
  i_love_you = true;
  you_love_me = false;
  ```

### int 整数类型
- `int`类型表示有符号64位整数。

- 示例:
  ```v
  age = 25;
  count = -42;
  ```

### float 小数类型
- `float`类型表示64位浮点数。

- 示例:
  ```v
  height = 5.9;
  weight = -70.5;
  ```

### range 范围类型
- `range`类型表示一段连续的数值范围，一般用作索引和 `for` 循环的遍历对象。
- 例如：`0..9`表示从0到8（包含0但不包含9）的整数范围。
- 示例:
  ```v
  range1 = 0..5;  	# 表示 0, 1, 2, 3, 4 这一段范围
  range2 = (-3)..3;  	# 表示 -3, -2, -1, 0, 1, 2 这一段范围
  ```

- 通过`in`操作符可以判断该范围对象是否包含某整数对象或者范围对象

  ```
  println(5 in 0..5)		# false
  println(1..3 in 0..3)	# true
  ```

  

### char 字符类型

- 字符对象由一对反引号表示，反引号内有且只有一个Unicode字符。

- 示例:

  ```v
  letter 	= `A`;
  digit 	= `5`;
  chinese = `爱`;
  ```

### string 字符串类型

- 字符串对象由一对双引号或单引号表示，采用UTF-8编码。

- 字符串中的每个字符都有对应的位置值，称为索引，索引从0开始。

- 字符串的索引也可以是`range`类型的值。

  ```v
  name = "马冬梅";
  println(name[0]);  	# `马`
  word = '我爱你中国';
  println(word[0..3]);	# "我爱你"
  ```

- 通过 `in` 操作符可以判断该字符串对象是否包含某字符对象或某字符串对象

  ```
  str = '你好，世界';
  println(`好` in str)		# true
  println('world' in str)	# false
  ```

  

### function 函数类型

- 在`MyScript`中, 通过`fn`关键字来定义一个函数对象。

- 示例:
  ```v
  fn hello() {
    println('hello, world');
  }
  
  add = fn (a, b) {
    return a + b;
  }
  
  hello();
  println(add(10, 8));
  ```

- 函数支持闭包，上级环境和闭包函数环境是两个单独的作用域。

- 示例:

  ```
  var = 123;
  println(var);		# 此时 var 为 123
  
  fn test() {
  	var = 456;
  	println(var);	# 此时 var 为 456
  }
  
  test();
  println(var);		# 此时 var 为 123
  ```

- `MyScript`实现了一些内置函数，包括:

  | 函数定义                       | 函数作用                                   |
  | :----------------------------- | :----------------------------------------- |
  | fn len(arg object) int         | 计算指定对象(string\|list\|table)的长度    |
  | fn type(arg object) string     | 获取对象类型的字符串                       |
  | fn print(args ...object)       | 打印不定长度的对象                         |
  | fn println(args ...object)     | 打印不定长度的对象并换行                   |
  | fn input(prompt string) string | 从控制台获取一段输入，prompt参数为提示内容 |
  | fn clone(arg object) object    | 将对象拷贝一份并返回                       |
  | fn time() table                | 获取当前时间对象                           |
  | fn bool(arg object) bool       | 将对象转换为 bool 对象并返回               |
  | fn char(arg object) bool       | 将对象转换为 char 对象并返回               |
  | fn float(arg object) bool      | 将对象转换为 float 对象并返回              |
  | fn int(arg object) bool        | 将对象转换为 int 对象并返回                |
  | fn list(arg object) bool       | 将对象转换为 list 对象并返回               |
  | fn string(object) string       | 将对象转换为 string 对象并返回             |
  

### list 列表类型

- 列表对象由一对中括号"[]"表示，元素间用逗号分隔，每个元素可以是不同类型。

- 列表中的每个元素都有对应索引，索引从0开始。

- 可以通过索引获取或重新赋值列表中的元素。
- 示例:
  ```v
  list = [1, 'two', 3.0, true];
  
  println(nums[1]);		# 'two'
  nums[3] = `4`;  		# nums 变为 [1, 'two', 3.0, `4`];
  ```

- 通过 `in` 操作符可以判断该列表对象是否包含某元素

  ```
  list = [1, '2', 3.0]
  println(1 in list)	# true
  println(2 in list)	# false
  ```

  

### table 字典类型

- 字典对象由一对大括号"{}"表示，键值对用冒号(:)分隔，键只能是`int`, `string`, `char`类型，值可以是任何类型。
- 字典对象的键值对间用逗号(,)分隔。
- 示例:
  ```v
  person = {
    'name': 'Bob',
    'age': 30,
    'is_student': false
  }
  
  println(person['name']);  # "Bob"
  person['age'] = 31;  	# 修改age的值
  ```

- 通过 `in` 操作符可以判断某元素是否为该字典对象的键值

  ```
  person = {
    'name': 'Bob',
  }
  println('name' in person)	# true
  println('age' in person)	# false
  ```

  

### null 空类型

- `null`表示空对象，可以用来删除一个变量。
- 示例:
  ```v
  value = 123;
  println(value);	# 123
  value = null;
  println(value);	# ERROR: 标识符 "value" 没有绑定的值
  ```

- `null`同样可以用来删除`list`对象和`table`对象中的元素。

- 示例:

  ```
  list = [0, 1, 2, 3];
  list[-1] = null;			# 此时 list 为 [0, 1, 2]
  
  table = {'name': '张三', 'age': 33};
  table['age'] = null;		# 此时 table 为 {'age': 33}
  ```

  

## 流程控制

### if 条件语句

```
num = 10;
if (num == 10) {
	println('num 的值等于10');
} else {
	println('num 的值不等于10');
}
```

条件赋值(if表达式)

```
love_you = false
word = if (love_you) { '喜欢你' } else { '讨厌你' }	# '讨厌你'
```

### for 循环语句

- for语句用来遍历一个可遍历(range，string，list，table)对象进行循环。

- 通过`break`关键字可以立即退出所在的循环。
- 通过`continue`关键字可以跳过当前循环的剩余部分。

```
for (v in 0..5) {
	println(v)	# 此时 v 的值依次为: 0, 1, 2, 3, 4
}

for (v in '我爱你中国') {
	if (v == `你`) {
		continue
	}
	println(v)	# 此时 v 的值依次为: `我`，`爱`，`中`，`国`
}

for (v in [123, true, 123.44, '你好']) {
	if (v == 123.44) {
		break
	}
	println(v)	# 此时 v 的值依次为: 123, true
}

for (v in {'name': '张三', 'age': 33}) {
	println(v)	# 此时 v 的值依次为: 'name', 'age'
}
```

### while 循环语句

- while 语句对一个条件进行判断并循环，当条件表达式的值为`true`进入循环，为`false`退出循环。
- 通过`break`关键字可以立即退出所在的循环。
- 通过`continue`关键字可以跳过当前循环的剩余部分。

```
x = 10

while (x > 0) {
	x = x - 1
	if (x == 6) {
		continue
	}
	if (x == 3) {
		break
	}
	println(x)	# 此时 x 的值依次为9，8，7，5，4
}
```

## 面向对象

我们知道，对象由属性和方法组成。在`Myscript`中可以通过`table`来存储对象的属性，`function`来实现对象的方法，借此模拟出面向对象的效果。

```
person = {
  'name': '张三',
  'age': 30,
  'show': fn (self) {
  	println('我的名字是{0}，我今年{1}岁'.format(self['name'], self['age']))
  }
}


person['show'](person)	# 我的名字是张三，我今年30岁
```

上述代码看起来显然不太美观，所以在`MyScript`中，下面这段代码与上面的代码是完全等价的。

```
person = {
	name: '张三',
	age: 30,
	show: fn (self) {
		println('我的名字是{0}，我今年{1}岁'.format(self.name, self.age))
	}
}
person.show()	# 我的名字是张三，我今年30岁
```

### 内置字符串方法

| 方法定义                                          | 方法作用                                                     |
| ------------------------------------------------- | ------------------------------------------------------------ |
| fn string.split(sep string) list                  | 按照给定的分割符，把字符串分割并返回字符串列表               |
| fn string.lower() string                          | 将字符串中的字母转为小写字母并返回                           |
| fn string.upper() string                          | 将字符串中的字母转为大写字母并返回                           |
| fn string.count(sub_str string) int               | 统计字符串中子字符串的出现次数并返回                         |
| fn string.index(sub_str string) int               | 返回子字符串在字符串中第一次出现的索引位置, 如果没有则返回-1 |
| fn string.replace(rep string, with string) string | 将替换字符串中所有的子字符串rep，替换为新的子字符串with并返回|
| fn string.format(args ...object) string           | 按顺序将参数替换为字符串中的格式化字符串                     |

### 内置列表方法
| 方法定义                                          | 方法作用                                                     |
| ------------------------------------------------- | ------------------------------------------------------------ |
| fn list.reverse()                                 | 将当前列表反转                                               |
| fn list.frist() object                            | 返回列表中的第一个元素对象                                   |
| fn list.last() object                             | 返回列表中的最后一个元素对象                                 |
