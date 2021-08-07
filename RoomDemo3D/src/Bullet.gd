extends RigidBody


func _ready():
	connect("body_entered", self, "collided")
	#connect("body_shape_entered", self, "shape_collided")
	pass

func collided(body):
	
	if body is GridMap:
		#print("collided with: ", body)
		var grid = body
		var pos =  self.global_transform.origin - grid.translation
		var gridPos = grid.world_to_map( pos )
		var cell = grid.get_cell_item(gridPos.x, gridPos.y, gridPos.z)
		if cell != GridMap.INVALID_CELL_ITEM :
			print("gridPos ", gridPos)
			grid.set_cell_item(gridPos.x, gridPos.y, gridPos.z, 0, 0)
	
	#queue_free()
	
func shape_collided(body_id: int, body: Node, body_shape: int, local_shape: int):
	
	print("shape_collided with: ", body_id, body, body_shape, local_shape)
	
	var collisionBody:StaticBody = body
	
	var grid:GridMap = collisionBody.get_parent()
	if grid is GridMap:
		var gridPos = grid.world_to_map( collisionBody.translation )
		print("gridPos ", gridPos)
		
		var item = grid.get_cell_item(gridPos.x, gridPos.y, gridPos.z)
		grid.set_cell_item(gridPos.x, gridPos.y, gridPos.z, item, rand_range(0,10) as int)
		#queue_free()
