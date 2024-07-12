module object

fn test_main() {
	v1 := Object(&Int{
		datatype: .int
		value: 123
	})
	v2 := Object(&Int{
		datatype: .int
		value: 123
	})
	println(v1 == v2)
}
