extends Area2D

var entered = false

func _on_body_entered(body: Player) :
	entered=true
	if body.name == "Player":
		SaveSystem.player_position_world_2 = body.position
	

func _physics_process(_delta: float) -> void:
	if entered==true:
		if Input.is_action_pressed ("left") :
			SaveSystem.current_scene_path = "res://scenes/world.tscn"
			SaveSystem.save_game()
			get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_body_exited(_body: Player) :
	entered=false
	pass
