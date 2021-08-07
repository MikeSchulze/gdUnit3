# This class is an hack to get access to the debuger push error list
tool
class_name GdUnitPushErrorHandler
extends Node

var _debugger_tree :Tree = null
var _error_icon :Texture = null

func _ready():
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	if plugin:
		var debugger := _find_by_class(plugin.get_parent(), "ScriptEditorDebugger")
		#prints(debugger[-1].get_path())
		var trees := _find_by_class(debugger[-1], "Tree", true)
		for t in trees:
			var node_path : String = t.get_path()
			if node_path.find_last("Fehler") != -1:
				#prints(node_path)
				#prints("Register debugger error handler on", t, self)
				_debugger_tree = t
		
		# get error icon from theme to be uses to compare it the item an error or warning
		var editiorTheme := plugin.get_editor_interface().get_base_control().theme
		_error_icon = editiorTheme.get_icon("Error", "EditorIcons")

func get_tree_root() -> TreeItem:
	return null if _debugger_tree == null else _debugger_tree.get_root()

func list_errors(from_id :int, to_id :int) -> Result:
	var tree_root := get_tree_root()
	if tree_root == null:
		return Result.warn("No push errors available")
	var values := _collect_values(tree_root, from_id, to_id)
	return Result.success(values)

func get_last_error() -> Result:
	var tree_root := get_tree_root()
	if tree_root == null:
		return Result.warn("No push errors available")
		
	var item := _find_last_item(tree_root)
	if item == null:
		return Result.empty()
		
	var error_info := to_value(item)
	return Result.success(error_info)

func clear_error_list():
	var tree_root := get_tree_root()
	if _debugger_tree != null:
		_debugger_tree.clear()

func to_value(item :TreeItem) -> Dictionary:
	return  {
		"item_id" : item.get_instance_id(),
		"is_error" : item.get_icon(0) == _error_icon,
		"message" : item.get_text(1),
		"meta" : item.get_metadata(0)
	}
 
static func _find_last_item(root :TreeItem) -> TreeItem:
	var current := root.get_children()
	var next : TreeItem
	while current != null:
		next = current.get_next()
		if next == null:
			return current
		current = next
	return null

static func _find_item_by_id(root :TreeItem, item_id :int) -> TreeItem:
	var current := root.get_children()
	var next : TreeItem
	while current != null:
		next = current.get_next()
		if next == null or current.get_instance_id() == item_id:
			return current
		current = next
	return null

# collects all values by id, starting one after from_id inclusive to_id
func _collect_values(root :TreeItem, from_id :int, to_id: int) -> Array:
	assert(from_id != -1)
	assert(to_id != -1)
	var items := Array()
	# is from_id == -1 collect all items
	var find_end := false
	var current := _find_item_by_id(root, from_id)
	var next : TreeItem
	while current != null and current.get_instance_id() != to_id:
		current = current.get_next()
		items.append(to_value(current))
	return items


static func _find_by_class(root: Node, clazz_name: String, collect_all := false) -> Array:
	var result = []
	var stack = [root]
	var clazz_to_find := "[" + clazz_name
	while stack:
		var node = stack.pop_back()
		if str(node).begins_with(clazz_to_find):
			result.append(node)
			if not collect_all:
				break
		for ch in node.get_children():
			stack.push_back(ch)
	return result

func _print_items(tree:Tree):
	var root :TreeItem = tree.get_root()
	if root == null:
		prints("invalid root")
	#prints(root.get_text(0))
	var child = root.get_children()
	while child != null:
		prints(child.get_text(0), child.get_text(1))
		child = child.get_next()
		
func get_tasks() -> Array:
	var tasks := Array()	
	tasks.append(GdUnitTask.new("GdUnitPushErrorHandler:get_last_error", self, "get_last_error"))
	tasks.append(GdUnitTask.new("GdUnitPushErrorHandler:list_errors", self, "list_errors"))
	tasks.append(GdUnitTask.new("GdUnitPushErrorHandler:clear_error_list", self, "clear_error_list"))
	return tasks
