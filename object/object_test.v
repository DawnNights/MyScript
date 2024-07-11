module object

fn test_main() {
	v1 := Object(&Int{
		value: 123
	})
	v2 := Object(&Int{
		value: 123
	})
	println(v1 == v2)
}
