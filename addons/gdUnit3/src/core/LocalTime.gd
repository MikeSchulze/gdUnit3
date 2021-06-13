# This class provides Date/Time functionallity to Godot
class_name LocalTime
extends Resource

const SCRIPT_PATH = "res://addons/gdUnit3/src/core/LocalTime.gd"

const SECONDS_PER_MINUTE:int = 60
const MINUTES_PER_HOUR:int = 60
const HOURS_PER_DAY:int = 24
const MILLIS_PER_SECOND:int = 1000
const MILLIS_PER_MINUTE:int = MILLIS_PER_SECOND * SECONDS_PER_MINUTE
const MILLIS_PER_HOUR:int   = MILLIS_PER_MINUTE * MINUTES_PER_HOUR

var _time:int
var _hour:int
var _minute:int
var _second:int
var _millisecond:int


static func _create(time_ms:int):
	var _instance = load(SCRIPT_PATH)
	return _instance.new(time_ms)

static func now() -> LocalTime:
	var time := OS.get_system_time_msecs()
	return _create(time)
	#return local_time(time.get("hour"), time.get("minute"), time.get("second"), 0)

static func of_unix_time(time_ms:int) -> LocalTime:
	return _create(time_ms)
	
static func local_time(hours:int, minutes:int, seconds:int, millis:int) -> LocalTime:
	return _create(MILLIS_PER_HOUR * hours\
	 + MILLIS_PER_MINUTE * minutes\
	 + MILLIS_PER_SECOND * seconds\
	 + millis)

func elapsed_since() -> String:
	return elapsed(OS.get_system_time_msecs() - _time)

func elapsed_since_ms() -> int:
	return OS.get_system_time_msecs() - _time
	
func plus( time_unit, value:int) -> LocalTime:
	var addValue:int = 0
	match time_unit:
		TimeUnit.MILLIS:
			addValue = value
		TimeUnit.SECOND:
			addValue = value * MILLIS_PER_SECOND
		TimeUnit.MINUTE:
			addValue = value * MILLIS_PER_MINUTE
		TimeUnit.HOUR:
			addValue = value * MILLIS_PER_HOUR
	
	_init(_time + addValue)
	return self

static func elapsed(time_ms:int) -> String:
	var local_time = _create(time_ms)
	if local_time._hour > 0:
		return "%dh %dmin %ds %dms" % [local_time._hour, local_time._minute, local_time._second, local_time._millisecond]
	if local_time._minute > 0:
		return "%dmin %ds %dms" % [local_time._minute, local_time._second, local_time._millisecond]
	if local_time._second > 0:
		return "%ds %dms" % [local_time._second, local_time._millisecond]
	return "%dms" % local_time._millisecond

# create from epoch timestamp in ms
func _init(time:int):
	_time = time
	_hour  =  (time / MILLIS_PER_HOUR) % 24
	_minute =  (time / MILLIS_PER_MINUTE) % 60
	_second =  (time / MILLIS_PER_SECOND) % 60
	_millisecond = time % 1000

func hour() -> int:
	return _hour

func minute() -> int:
	return _minute

func second() -> int:
	return _second

func millis() -> int:
	return _millisecond

func _to_string() -> String:
	return "%02d:%02d:%02d.%03d" % [_hour, _minute, _second, _millisecond]
