extends Area2D
var entered = false
var player = null

func _on_body_entered(body: Player) :
	if body.name == "Player":
		player = body
		entered=true
		SaveSystem.player_position_dungeon = body.position
		
func _physics_process(_delta: float) -> void:
	if entered==true:
		if Input.is_action_pressed("interact") and SaveSystem.key:
			SaveSystem.current_scene_path = "res://scenes/dungeon.tscn"
			SaveSystem.save_game()
			SaveSystem.save_backup()

func _on_body_exited(_body: Player) :
	entered=false
	pass
