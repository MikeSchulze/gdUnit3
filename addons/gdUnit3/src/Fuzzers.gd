class_name Fuzzers
extends Resource

# Generates an random integer in a range form to 
static func rangei(from: int, to: int) -> Fuzzer:
	return IntFuzzer.new(from, to)

# Generates an integer in a range form to that can be divided exactly by 2
static func eveni(from: int, to: int) -> Fuzzer:
	return IntFuzzer.new(from, to, IntFuzzer.EVEN)

# Generates an integer in a range form to that cannot be divided exactly by 2
static func oddi(from: int, to: int) -> Fuzzer:
	return IntFuzzer.new(from, to, IntFuzzer.ODD)
