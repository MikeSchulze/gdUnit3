tool
class_name GdMarkDownReader
extends Node

var md_replace_patterns = [
	# horizontal rules
	[regex("(?m)^ {0,3}---$"), "[img=4000x2]res://addons/gdUnit3/src/update/assets/horizontal-line2.png[/img]"],
	[regex("(?m)^[ ]{0,3}___$"), "[img=4000x2]res://addons/gdUnit3/src/update/assets/horizontal-line2.png[/img]"],
	[regex("(?m)^[ ]{0,3}\\*\\*\\*$"), "[img=4000x2]res://addons/gdUnit3/src/update/assets/horizontal-line2.png[/img]"],
	
	# headers
	[regex("(?m)^##### (.*)"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h5.tres]$1[/font]"],
	[regex("(?m)^#### (.*)"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h4.tres]$1[/font]"],
	[regex("(?m)^### (.*)"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h3.tres]$1[/font]"],
	[regex("(?m)^## (.*)"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h2.tres]$1[/font]"],
	[regex("(?m)^# (.*)"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h1.tres]$1[/font]"],
	[regex("(?m)^(.+)=={2,}$"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h2.tres]$1[/font]"],
	[regex("(?m)^(.+)--{2,}$"), "[font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-h1.tres]$1[/font]"],
	
	# asterics
	#[regex("(\\*)"), "xxx$1xxx"],
	
	# extract/compile image references
	[regex("!\\[(.*?)\\]\\[(.*?)\\]"), funcref(self, "process_image_references")],
	# extract images with path and optional tool tip
	[regex("!\\[(.*?)\\]\\((.*?)(( )+(.*?))?\\)"), funcref(self, "process_image")],
	
	# links
	[regex("([!]|)\\[(.+)\\]\\(([^ ]+?)\\)"),  "[url={\"url\":\"$3\"}]$2[/url]"],
	# links with tool tip
	[regex("([!]|)\\[(.+)\\]\\(([^ ]+?)( \"(.+)\")?\\)"),  "[url={\"url\":\"$3\", \"tool_tip\":\"$5\"}]$2[/url]"],
	
	# embeded text
	[regex("(?m)^[ ]{0,3}>(.*?)$"), "[img=50x14]res://addons/gdUnit3/src/update/assets/embedded.png[/img][i]$1[/i]"],

	# italic + bold font
	[regex("[_]{3}(.*?)[_]{3}"), "[i][b]$1[/b][/i]"],
	[regex("[\\*]{3}(.*?)[\\*]{3}"), "[i][b]$1[/b][/i]"],
	# bold font
	[regex("<b>(.*?)<\/b>"), "[b]$1[/b]"],
	[regex("[_]{2}(.*?)[_]{2}"), "[b]$1[/b]"],
	[regex("[\\*]{2}(.*?)[\\*]{2}"), "[b]$1[/b]"],
	# italic font
	[regex("<i>(.*?)<\/i>"), "[i]$1[/i]"],
	[regex("_(.*?)_"), "[i]$1[/i]"],
	[regex("\\*(.*?)\\*"), "[i]$1[/i]"],

	# strikethrough font
	[regex("<s>(.*?)</s>"), "[s]$1[/s]"],
	[regex("~~(.*?)~~"), "[s]$1[/s]"],
	[regex("~(.*?)~"), "[s]$1[/s]"],
	
	# handling lists 
	# using an image for dots as workaroud because list is not supported on Godot 3.x
	[regex("(?m)^[ ]{0,1}[*\\-+] (.*)$"), list_replace(0)],
	[regex("(?m)^[ ]{2,3}[*\\-+] (.*)$"), list_replace(1)],
	[regex("(?m)^[ ]{4,5}[*\\-+] (.*)$"), list_replace(2)],
	[regex("(?m)^[ ]{6,7}[*\\-+] (.*)$"), list_replace(3)],
	[regex("(?m)^[ ]{8,9}[*\\-+] (.*)$"), list_replace(4)],
	
	# code blocks, code blocks looks not like code blocks in richtext
	[regex("```(javascript|python|)([\\s\\S]*?\n)```"), code_block("$2", true)],
	[regex("``([\\s\\S]*?)``"), code_block("$1")],
	[regex("`([\\s\\S]*?)`{1,2}"), code_block("$1")],
]

var _img_replace_regex := RegEx.new()
var _image_urls := Array()
var _on_table_tag := false
var _client :GdUnitUpdateClient

func _init():
	_img_replace_regex.compile("\\[img\\]((.*?))\\[/img\\]")

func set_http_client(client :GdUnitUpdateClient) -> void:
	_client = client

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# finally remove the downloaded images
		var dir := Directory.new()
		for image in _image_urls:
			dir.remove(image)
			dir.remove(image + ".import")

static func regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err = regex.compile(pattern)
	if err != OK:
		push_error("error '%s' on pattern '%s'" % [err, pattern])
		return null
	return regex

func list_replace(indent :int) -> String:
	var replace_pattern = "[img=12x12]res://addons/gdUnit3/src/update/assets/dot2.png[/img]" if indent %2 else "[img=12x12]res://addons/gdUnit3/src/update/assets/dot1.png[/img]"
	replace_pattern += " $1"
	
	for index in indent:
		replace_pattern = replace_pattern.insert(0, "   ")
	return replace_pattern

func code_block(replace :String, border :bool = false) -> String:
	var code_block := "[code][color=aqua][font=res://addons/gdUnit3/src/update/assets/fonts/RobotoMono-code.tres]%s[/font][/color][/code]" % replace
	if border:
		return "[img=1400x14]res://addons/gdUnit3/src/update/assets/border_top.png[/img]"\
			+ "[indent]" + code_block + "[/indent]"\
			+ "[img=1400x14]res://addons/gdUnit3/src/update/assets/border_bottom.png[/img]\n"
	return code_block

func to_bbcode(input :String) -> String:
	yield(get_tree(), "idle_frame")
	var bbcode := Array()
	
	input = input.replace("\r", "")
	input = process_tables(input)
	
	for pattern in md_replace_patterns:
		var regex :RegEx = pattern[0]
		var bb_replace = pattern[1]
		if bb_replace is FuncRef:
			var fs = bb_replace.call_func(regex, input)
			if GdUnitTools.is_yielded(fs):
				input = yield(fs, "completed")
			else:
				input = fs
		else:
			input = regex.sub(input, bb_replace, true)
	return input

func process_tables(input :String) -> String:
	var bbcode := Array()
	var lines := Array(input.split("\n"))
	while not lines.empty():
		if is_table(lines[0]):
			GdUnitTools.append_array(bbcode, parse_table(lines))
			continue
		bbcode.append(lines.pop_front())
	return PoolStringArray(bbcode).join("\n")

class Table:
	var _columns : int
	var _rows := Array()
	
	class Row:
		var _cells := PoolStringArray()
		
		func _init(cells :PoolStringArray, columns :int):
			_cells = cells
			for i in range(_cells.size(), columns):
				_cells.append("")
		
		func to_bbcode(cell_sizes :PoolIntArray, bold :bool) -> String:
			var cells := PoolStringArray()
			for cell_index in _cells.size():
				var cell :String = _cells[cell_index]
				if cell.strip_edges() == "--":
					cell = create_line(cell_sizes[cell_index])
				if bold:
					cell = "[b]%s[/b]" % cell
				cells.append("[cell]%s[/cell]" % cell)
			return cells.join("|")
		
		func create_line(length :int) -> String:
			var line := "" 
			for i in length:
				line += "-"
			return line
	
	func _init(columns :int):
		_columns = columns
	
	func parse_row(line :String) -> bool:
		# is line containing cells?
		if line.find("|") == -1:
			return false
		_rows.append(Row.new(line.split("|"), _columns))
		return true
	
	func calculate_max_cell_sizes() -> PoolIntArray:
		var cells_size := PoolIntArray()
		for column in _columns:
			cells_size.append(0)
		
		for row_index in _rows.size():
			var row :Row = _rows[row_index]
			for cell_index in row._cells.size():
				var cell_size :int = cells_size[cell_index]
				var size := row._cells[cell_index].length()
				if size > cell_size:
					cells_size[cell_index] = size
		return cells_size
	
	func to_bbcode() -> PoolStringArray:
		var cell_sizes := calculate_max_cell_sizes()
		var bb_code := PoolStringArray()
		
		bb_code.append("[table=%d]" % _columns)
		for row_index in _rows.size():
			bb_code.append(_rows[row_index].to_bbcode(cell_sizes, row_index==0))
		bb_code.append("[/table]\n")
		return bb_code

func parse_table(lines :Array) -> PoolStringArray:
	var line :String = lines[0]
	var table := Table.new(line.count("|") + 1)
	while not lines.empty():
		line = lines.pop_front()
		if not table.parse_row(line):
			break
	return table.to_bbcode()

func is_table(line :String) -> bool:
	return line.find("|") != -1

func open_table(line :String) -> String:
	_on_table_tag = true
	return "[table=%d]" % (line.count("|") + 1)

func close_table() -> String:
	_on_table_tag = false
	return "[/table]"

func extract_cells(line :String, bold := false) -> String:
	var cells := ""
	for cell in line.split("|"):
		if bold:
			cell = "[b]%s[/b]" % cell
		cells += "[cell]%s[/cell]" % cell
	return cells

func process_image_references(regex :RegEx, input :String) -> String:
	var to_replace := PoolStringArray()
	var tool_tips :=  PoolStringArray()
	# exists references?
	var matches := regex.search_all(input)
	if matches.empty():
		return input
	# collect image references and remove it
	var references := Dictionary()
	var link_regex := regex("\\[(\\S+)\\]:(\\S+)([ ]\"(.*)\")?")
	# create copy of original source to replace on it
	input = input.replace("\r", "")
	var extracted_references := input
	for reg_match in link_regex.search_all(input):
		var line = reg_match.get_string(0) + "\n"
		var reference = reg_match.get_string(1)
		var topl_tip = reg_match.get_string(4)
		# collect reference and url
		references[reference] = reg_match.get_string(2)
		extracted_references = extracted_references.replace(line, "")
	
	# replace image references by collected url's
	for reference_key in references.keys():
		var regex_key := regex("\\](\\[%s\\])" % reference_key)
		for reg_match in regex_key.search_all(extracted_references):
			var reference :String = reg_match.get_string(0)
			var image_url :String = "](%s)" % references.get(reference_key)
			extracted_references = extracted_references.replace(reference, image_url)
	return extracted_references

func process_image(regex :RegEx, input :String) -> String:
	var to_replace := PoolStringArray()
	var tool_tips :=  PoolStringArray()
	# find all matches
	var matches := regex.search_all(input)
	if matches.empty():
		return input
	for reg_match in matches:
		# grap the parts to replace and store temporay because a direct replace will distort the offsets
		to_replace.append(input.substr(reg_match.get_start(0), reg_match.get_end(0)))
		# grap optional tool tips
		tool_tips.append(reg_match.get_string(5))
	# finally replace all findings
	for replace in to_replace:
		var re := regex.sub(replace, "[img]$2[/img]")
		input = input.replace(replace, re)
	
	var fs = _process_external_image_resources(input)
	if GdUnitTools.is_yielded(fs):
		return yield(fs, "completed")
	return fs

func _process_external_image_resources(input :String) -> String:
	# scan all img for external resources and download it
	for value in _img_replace_regex.search_all(input):
		if value.get_group_count() >= 1:
			var image_url :String = value.get_string(1)
			# if not a local resource we need to download it
			if image_url.begins_with("http"):
				prints("download immage:", image_url)
				var response = yield(_client.request_image(image_url), "completed")
				if response.code() == 200:
					var image = Image.new()
					var error = image.load_png_from_buffer(response.body())
					if error != OK:
						prints("Error creating image from response", error)
					var new_url := "res://addons/gdUnit3/src/update/%s" % image_url.get_file()
					# replace characters where format characters
					new_url = new_url.replace("_", "-")
					image.save_png(new_url)
					_image_urls.append(new_url)
					input = input.replace(image_url, new_url)
	return input
