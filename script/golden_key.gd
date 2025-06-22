extends Area2D

func _ready() -> void:
	if SaveSystem.key:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
	SaveSystem.key = true
