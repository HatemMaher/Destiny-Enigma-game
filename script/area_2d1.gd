extends Area2D

var entered = false

func _on_body_entered(body: Player) :
	entered=true
	if body.name == "Player":
		SaveSystem.player_position_world = body.position
		
func _physics_process(_delta: float) -> void:
	if entered==true:
		if Input.is_action_pressed("right") :
			SaveSystem.current_scene_path = "res://scenes/world_2.tscn"
			SaveSystem.save_game()
			SaveSystem.save_backup()
			get_tree().change_scene_to_file("res://scenes/world_2.tscn")

func _on_body_exited(_body: Player) :
	entered=false
	pass
