extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if this coin has already been collected
	if name in SaveSystem.collected_coins:
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	SaveSystem.collected_coins.append(name)
	queue_free()
