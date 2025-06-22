extends Area2D

var entered = false

func _on_body_entered(body: Node) -> void:
	if body is Player:
		entered = true

func _physics_process(_delta: float) -> void:
	if entered == true:
		if Input.is_action_just_pressed("interact"):
			SaveSystem.current_scene_path = "res://scenes/world.tscn"
			SaveSystem.save_game()
			SaveSystem.save_backup()
			get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_body_exited(body: Node) -> void:
	if body is Player:
		entered = false
