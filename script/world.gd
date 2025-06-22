extends Node2D

@onready var player = $Player
func _ready() -> void:
	if player != null:
		if SaveSystem.player_position_world != Vector2.ZERO:
			player.position = SaveSystem.player_position_world
		else:
			SaveSystem.player_position_world = position  # Default position
