extends Node2D

@onready var player = $Player

func _ready() -> void:

	if player != null:
		if SaveSystem.player_position_world_3 != Vector2.ZERO:
			player.position = SaveSystem.player_position_world_3
		else:
			SaveSystem.player_position_world_3 = position
