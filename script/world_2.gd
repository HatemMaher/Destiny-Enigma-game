extends Node2D

var stone_scene := preload("res://scenes/stone.tscn")


func _ready() -> void:
	for pos in SaveSystem.collected_stones:
		var stone = stone_scene.instantiate()
		stone.position = pos
		add_child(stone)
	var player = get_node("Player")  # Ensure the correct path to the player node
	if player != null:
		if SaveSystem.player_position_world_2 != Vector2.ZERO:
			player.position = SaveSystem.player_position_world_2
		else:
			SaveSystem.position = position  # Default position
