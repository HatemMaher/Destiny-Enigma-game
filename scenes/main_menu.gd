extends Control

func _ready():
	SaveSystem.load_settings()
	var continue_button = $"MarginContainer/VBoxContainer/Continue Game"  
	if not SaveSystem.save_file_exists() :  
		continue_button.disabled = true

func _on_options_pressed() -> void:
	$select_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/option_menu.tscn")

func _on_exit_pressed() -> void:
	$select_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _on_continue_game_pressed() -> void:
	SaveSystem.load_game()
	$select_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file(SaveSystem.current_scene_path)

func _on_new_game_pressed() -> void:
	SaveSystem.clear_save()
	SaveSystem.clear_backup()
	$select_sound.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/cutscenes/cutscene_beginning.tscn")
