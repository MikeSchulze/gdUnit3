extends Reference


func test_no_args():
	pass

func test_with_timeout(timeout=2000):
	pass
	
func test_with_fuzzer(fuzzer := Fuzzers.rangei(-10, 22)):
	pass

func test_with_fuzzer_iterations(fuzzer := Fuzzers.rangei(-10, 22), fuzzer_iterations = 10):
	pass

func test_with_multible_fuzzers(fuzzer_a := Fuzzers.rangei(-10, 22), fuzzer_b := Fuzzers.rangei(23, 42), fuzzer_iterations = 10):
	pass
