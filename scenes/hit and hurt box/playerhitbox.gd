extends Hitbox


func _ready() -> void:
	pass
	


func _on_player_playerdamage(value: Variant) -> void:
	damage = value
