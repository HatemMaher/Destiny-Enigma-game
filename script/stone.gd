extends Area2D




func _on_body_entered(_body: Player) -> void:
	SaveSystem.collected_stones.erase(position)  
	queue_free()
