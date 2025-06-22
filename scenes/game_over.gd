extends Node2D

func _ready() -> void:
	SaveSystem.reduce_stone_and_update_save()
	SaveSystem.load_game()
	$game_end.play()
	$AnimationPlayer.play("new_animation")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press_E"):
		$Press_E_Sound.play()
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
