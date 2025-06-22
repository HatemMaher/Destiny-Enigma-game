extends Area2D

var entered = false

func _on_body_entered(body: Player) :
	entered=true
	SaveSystem.player_position_dungeon = body.position
		
func _physics_process(_delta: float) -> void:
	if entered==true:
		if Input.is_action_pressed("down") :
			SaveSystem.current_scene_path = "res://scenes/world_2.tscn"
			SaveSystem.save_game()
			get_tree().change_scene_to_file("res://scenes/world_2.tscn")

func _on_body_exited(_body: Player) :
	entered=false
	pass
