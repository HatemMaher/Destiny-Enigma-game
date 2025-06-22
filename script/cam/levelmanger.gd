extends Node


var current_tilemap_bounds : Array[Vector2]
signal tilemapboundschanged( bounds : Array[Vector2])

func changetilemapbounds (bounds : Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	tilemapboundschanged.emit(bounds)
