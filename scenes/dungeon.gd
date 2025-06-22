class_name dungeon extends TileMap



func _ready(): 
	Levelmanger.changetilemapbounds(gettilemapbounds())
	pass # Replace with function body.


func gettilemapbounds() -> Array[Vector2]:
	var bounds : Array[Vector2] = []
	bounds.append(
		Vector2(get_used_rect().position * rendering_quadrant_size)
	)
	bounds.append(
		Vector2(get_used_rect().end * rendering_quadrant_size)
	)
	return bounds
