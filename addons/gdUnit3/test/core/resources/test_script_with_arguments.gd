extends Reference


func test_no_args():
	pass

func test_with_timeout(timeout=2000):
	pass
	
func test_whith_fuzzer(fuzzer := Fuzzers.rangei(-10, 22)):
	pass

func test_whith_fuzzer_iterations(fuzzer := Fuzzers.rangei(-10, 22), fuzzer_iterations = 10):
	pass
