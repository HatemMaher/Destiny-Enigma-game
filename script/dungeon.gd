extends Node2D
func _ready() -> void:
	var player = get_node("Player")  # Ensure the correct path to the player node
	if player != null:
		if SaveSystem.player_position_dungeon != Vector2.ZERO:
			player.position = SaveSystem.player_position_dungeon
		else:
			SaveSystem.position = position  # Default position
