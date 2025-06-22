extends Control

var Music_Bus = AudioServer.get_bus_index("Music")
var SFX_Bus = AudioServer.get_bus_index("SFX")
var waiting_for_input = false
var current_action = ""
var current_button = null

func _ready() -> void:
	update_input_ui()
	$volume/HSlider_Music.value = SaveSystem.music_volume
	$volume/HSlider_SFX.value = SaveSystem.sfx_volume

	AudioServer.set_bus_volume_db(Music_Bus, SaveSystem.music_volume)
	AudioServer.set_bus_mute(Music_Bus, SaveSystem.music_volume == -30)

	AudioServer.set_bus_volume_db(SFX_Bus, SaveSystem.sfx_volume)
	AudioServer.set_bus_mute(SFX_Bus, SaveSystem.sfx_volume == -30)
	visible = false
	$option.visible = false
	$volume.visible = false
	$control.visible = false

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and  !get_tree().paused and ! $option.visible and !$volume.visible and ! $control.visible:
		$pause_sound.play()
		visible = true
		pause()
		
	elif Input.is_action_just_pressed("esc") and get_tree().paused and ! $option.visible and !$volume.visible and ! $control.visible:
		$pause_sound.play()
		visible = false
		resume()


func _on_resume_pressed() -> void:
	$select_sound.play()
	visible = false
	resume()



func _on_main_menu_pressed() -> void:
	if SaveSystem.current_scene_path == "res://scenes/world.tscn":
		SaveSystem.player_position_world = SaveSystem.current_player_position
		SaveSystem.save_game()
	elif SaveSystem.current_scene_path == "res://scenes/world_2.tscn":
		SaveSystem.player_position_world_2 = SaveSystem.current_player_position
		SaveSystem.save_game()
	elif SaveSystem.current_scene_path == "res://scenes/world_3.tscn":
		SaveSystem.player_position_world_3 =  SaveSystem.current_player_position
		SaveSystem.save_game()
	elif SaveSystem.current_scene_path == "res://scenes/house.tscn":
		SaveSystem.player_position_house =  SaveSystem.current_player_position
		SaveSystem.save_game()
	else: 
		if SaveSystem.current_scene_path == "res://scenes/dungeon.tscn":
			SaveSystem.player_position_dungeon = SaveSystem.current_player_position
			SaveSystem.save_game()
	$select_sound.play()
	await get_tree().create_timer(0.2).timeout
	resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_option_pressed() -> void:
	$select_sound.play()
	$Panel.visible = false
	$option.visible = true

func _process(_delta: float) -> void:
	testEsc()
	if $option.visible:
		if Input.is_action_just_pressed("esc"):
			$select_sound.play()
			$Panel.visible = true
			$option.visible = false
	if $volume.visible:
		if Input.is_action_just_pressed("esc"):
			$select_sound.play()
			$option.visible = true
			$volume.visible = false
	if $control.visible:
		if Input.is_action_just_pressed("esc"):
			$select_sound.play()
			$option.visible = true
			$control.visible = false


func _on_volume_pressed() -> void:
	$select_sound.play()
	$volume.visible = true
	$option.visible = false

func _on_control_pressed() -> void:
	$control.visible = true
	$option.visible = false

func _on_back_pressed() -> void:
	$select_sound.play()
	$Panel.visible = true
	$option.visible = false


func _on_h_slider_music_value_changed(value: float) -> void:
	SaveSystem.music_volume = value
	SaveSystem.save_settings()
	AudioServer.set_bus_volume_db(Music_Bus, value)
	if value == -30:
		AudioServer.set_bus_mute(Music_Bus, true)
		$volume/AnimatedSprite2D.play("new_animation")
	else :
		if AudioServer.is_bus_mute(Music_Bus):  # Only play backwards if previously muted
			$volume/AnimatedSprite2D.play_backwards("new_animation")
		AudioServer.set_bus_mute(Music_Bus, false)
		
	


func _on_h_slider_sfx_value_changed(value: float) -> void:
	SaveSystem.sfx_volume = value
	SaveSystem.save_settings()
	AudioServer.set_bus_volume_db(SFX_Bus, value)
	if value == -30:
		AudioServer.set_bus_mute(SFX_Bus, true)
		$volume/AnimatedSprite2D2.play("new_animation")
	else :
		if AudioServer.is_bus_mute(SFX_Bus):  # Only play backwards if previously muted
			$volume/AnimatedSprite2D2.play_backwards("new_animation")
		AudioServer.set_bus_mute(SFX_Bus, false)

func _start_remap(action_name: String, button: Button) -> void:
	waiting_for_input = true
	current_action = action_name
	current_button = button
	button.text = "Press any key..."

func _unhandled_input(event: InputEvent) -> void:
	if not waiting_for_input:
		return

	if event is InputEventKey or event is InputEventJoypadButton:
		# Check for duplicates
		for action in InputMap.get_actions():
			if action == current_action:
				continue
			if InputMap.event_is_action(event, action):
				if current_button != null:
					current_button.text = "Already in use!"
					await get_tree().create_timer(1.0).timeout
					update_input_ui()
				_reset_remap_state()
				return

		# Safe remap
		InputMap.action_erase_events(current_action)
		InputMap.action_add_event(current_action, event)

		if current_button != null:
			if event is InputEventKey:
				current_button.text = OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventJoypadButton:
				current_button.text = "Joypad " + str(event.button_index)


		SaveSystem.save_settings()
		_reset_remap_state()

func _reset_remap_state():
	waiting_for_input = false
	current_action = ""
	current_button = null

		

func _on_btn_move_up_pressed() -> void:
	_start_remap("up", $control/move_up/BtnMoveUp)

func _on_btn_move_down_pressed() -> void:
	_start_remap("down", $control/move_down/BtnMoveDown)

func _on_btn_move_left_pressed() -> void:
	_start_remap("left", $control/move_left/BtnMoveLeft)

func _on_btn_move_right_pressed() -> void:
	_start_remap("right", $control/move_right/BtnMoveRight)

func _on_btn_interact_pressed() -> void:
	_start_remap("interact", $control/interact/BtnInteract)

func _on_btn_attack_pressed() -> void:
	_start_remap("strike", $control/Attack/BtnAttack)

func _on_btn_roll_pressed() -> void:
	_start_remap("roll", $control/roll/BtnRoll)


func _on_back_2_pressed() -> void:
	$select_sound.play()
	$option.visible = true
	$volume.visible = false


func _on_back_3_pressed() -> void:
	$select_sound.play()
	$option.visible = true
	$control.visible = false
	

func get_action_label(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	if events.size() == 0:
		return "Unbound"
	var event = events[0]
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventJoypadButton:
		return "Joypad " + str(event.button_index)
	return "Unknown"

func update_input_ui():
	$control/move_up/BtnMoveUp.text = get_action_label("up")
	$control/move_down/BtnMoveDown.text = get_action_label("down")
	$control/move_left/BtnMoveLeft.text = get_action_label("left")
	$control/move_right/BtnMoveRight.text = get_action_label("right")
	$control/interact/BtnInteract.text = get_action_label("interact")
	$control/Attack/BtnAttack.text = get_action_label("strike")
	$control/roll/BtnRoll.text = get_action_label("roll")
