extends Area2D

var entered = false

func _on_body_entered(body: Player) :
	entered=true
	if body.name == "Player":
		SaveSystem.player_position_world = body.position
		
func _physics_process(_delta: float) -> void:
	if entered==true:
		if Input.is_action_just_pressed("interact") :
			SaveSystem.current_scene_path = "res://scenes/house.tscn"
			SaveSystem.save_game()
			get_tree().change_scene_to_file("res://scenes/house.tscn")

func _on_body_exited(_body: Player) :
	entered=false
	pass
