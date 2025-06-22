class_name playercamera extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Levelmanger.tilemapboundschanged.connect(updatelimits)
	updatelimits(Levelmanger.current_tilemap_bounds)
	pass # Replace with function body.

func updatelimits( bounds : Array [ Vector2 ] ) -> void:
	if bounds == []:
		return
	limit_left = int ( bounds[0].x )
	limit_top = int ( bounds[0].y )
	limit_right = int ( bounds[1].x )
	limit_bottom = int ( bounds[1].y )
	pass
	
