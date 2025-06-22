extends Node2D

# save player health
var player_health = 100

var current_player_position: Vector2 = Vector2.ZERO
var player_position_world : Vector2 = Vector2.ZERO
var player_position_world_2 : Vector2 = Vector2.ZERO
var player_position_world_3 : Vector2 = Vector2.ZERO
var player_position_dungeon : Vector2 = Vector2.ZERO
var player_position_house : Vector2 = Vector2.ZERO

var orenthal_first_time=true
var arrival_at_village = true

var player_coin_counter = 0
var collected_coins = [] 


var player_stone_counter = 0
var collected_stones = []

var key = false
var gate = false

var chest_states = {}

func get_chest_opened(chest_id: int) -> bool:
	return chest_states.get(chest_id, false)

func set_chest_opened(chest_id: int, opened: bool) -> void:
	chest_states[chest_id] = opened

var dialogue = false

var enemy_states = {}  # Dictionary: enemy_id -> {position, health, dead}

var can_go = true
 
var current_scene_path = "res://scenes/cutscenes/cutscene_beginning.tscn"

var music_volume: float = 0.0
var sfx_volume: float = 0.0

# save file
var save_file_path = "user://savegame.save"
var save_file_path2 = "user://backup.save"

func _ready():
	load_settings()

func save_game():
	var save_data = {
		"player_health": player_health,
		"player_position_world": player_position_world,
		"player_position_world_2": player_position_world_2,
		"player_position_world_3": player_position_world_3,
		"player_position_dungeon": player_position_dungeon,
		"player_position_house": player_position_house,
		"player_coin_counter": player_coin_counter,
		"player_stone_counter": player_stone_counter,
		"collected_coins": collected_coins,
		"collected_stones": collected_stones,
		"key": key,
		"gate": gate,
		"chest_states": chest_states,
		"dialogue": dialogue,
		"enemy_states": enemy_states,
		"can_go": can_go,
		"current_scene_path": current_scene_path,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	file.store_var(save_data)
	file.close()


func load_game():
	if not FileAccess.file_exists(save_file_path):
		print("No save file found.")
		return
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	var save_data = file.get_var()
	file.close()

	# Restore values
	player_health = save_data.get("player_health", 100)
	player_position_world = save_data.get("player_position_world", Vector2.ZERO)
	player_position_world_2 = save_data.get("player_position_world_2", Vector2.ZERO)
	player_position_world_3 = save_data.get("player_position_world_3", Vector2.ZERO)
	player_position_dungeon = save_data.get("player_position_dungeon", Vector2.ZERO)
	player_position_house = save_data.get("player_position_house", Vector2.ZERO)
	player_coin_counter = save_data.get("player_coin_counter", 0)
	player_stone_counter = save_data.get("player_stone_counter", 0)
	collected_coins = save_data.get("collected_coins", [])
	collected_stones = save_data.get("collected_stones", [])
	key = save_data.get("key", false)
	gate = save_data.get("gate", false)
	chest_states = save_data.get("chest_states", {})
	dialogue = save_data.get("dialogue", false)
	enemy_states = save_data.get("enemy_states", {})
	can_go = save_data.get("can_go", true)
	current_scene_path = save_data.get("current_scene_path", "res://scenes/cutscenes/cutscene_beginning.tscn")

func clear_save():
	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)

	# Reset all in-memory data
	player_health = 100
	player_position_world = Vector2.ZERO
	player_position_world_2 = Vector2.ZERO
	player_position_world_3 = Vector2.ZERO
	player_position_dungeon = Vector2.ZERO
	player_position_house = Vector2.ZERO
	player_coin_counter = 0
	player_stone_counter = 0
	collected_coins = []
	collected_stones = []
	key = false
	gate = false
	chest_states = {}
	dialogue = false
	enemy_states = {}
	can_go = true
	current_scene_path = "res://scenes/cutscenes/cutscene_beginning.tscn"

func save_file_exists() -> bool:
	var save_path = "user://savegame.save"
	return FileAccess.file_exists(save_path)

func save_backup():
	var save_data = {
		"player_health": player_health,
		"player_position_world": player_position_world,
		"player_position_world_2": player_position_world_2,
		"player_position_world_3": player_position_world_3,
		"player_position_dungeon": player_position_dungeon,
		"player_position_house": player_position_house,
		"player_coin_counter": player_coin_counter,
		"player_stone_counter": player_stone_counter,
		"collected_coins": collected_coins,
		"collected_stones": collected_stones,
		"key": key,
		"gate": gate,
		"chest_states": chest_states,
		"dialogue": dialogue,
		"enemy_states": enemy_states,
		"can_go": can_go,
		"current_scene_path": current_scene_path,
	}
	var file = FileAccess.open(save_file_path2, FileAccess.WRITE)
	file.store_var(save_data)
	file.close()



func clear_backup():
	if FileAccess.file_exists(save_file_path2):
		DirAccess.remove_absolute(save_file_path2)

	# Reset all in-memory data
	player_health = 100
	player_position_world = Vector2.ZERO
	player_position_world_2 = Vector2.ZERO
	player_position_world_3 = Vector2.ZERO
	player_position_dungeon = Vector2.ZERO
	player_position_house = Vector2.ZERO
	player_coin_counter = 0
	player_stone_counter = 0
	collected_coins = []
	collected_stones = []
	key = false
	gate = false
	chest_states = {}
	dialogue = false
	enemy_states = {}
	can_go = true
	current_scene_path = "res://scenes/cutscenes/cutscene_beginning.tscn"

func overwrite_save_with_backup():
	if FileAccess.file_exists("user://backup.save"):
		var file = FileAccess.open("user://backup.save", FileAccess.READ)
		var backup_data = file.get_var()
		file.close()

		# Load main save first to preserve enemy states
		var main_data = {}
		if FileAccess.file_exists("user://savegame.save"):
			var main_file = FileAccess.open("user://savegame.save", FileAccess.READ)
			main_data = main_file.get_var()
			main_file.close()


		backup_data["player_health"] = 100
		backup_data["player_stone_counter"] = main_data.get("player_stone_counter", 0)
		backup_data["player_coin_counter"] = main_data.get("player_coin_counter", 0)
		backup_data["chest_states"] = main_data.get("chest_states", {})

		

		# Save it back
		var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
		save_file.store_var(backup_data)
		save_file.close()

func reduce_stone_and_update_save():
	if FileAccess.file_exists("user://savegame.save"):
		var file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = file.get_var()
		file.close()

		var current_stones = save_data.get("player_stone_counter", 0)

		if current_stones <= 4:
			SaveSystem.clear_save()
			SaveSystem.clear_backup()
		else:
			var reduced_by = max(int(current_stones * 0.2), 5)
			current_stones -= reduced_by
			save_data["player_stone_counter"] = current_stones
			SaveSystem.player_stone_counter = current_stones  # Also update runtime value

			# Save the updated data back
			var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
			save_file.store_var(save_data)
			save_file.close()


func save_settings():
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	file.store_var(music_volume)
	file.store_var(sfx_volume)

	# Save input remaps
	var input_data = {}
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_data[action] = events[0].as_text()  # Save first input only
	file.store_var(input_data)
	file.close()

func load_settings():
	if FileAccess.file_exists("user://settings.save"):
		var file = FileAccess.open("user://settings.save", FileAccess.READ)
		music_volume = file.get_var()
		sfx_volume = file.get_var()
		# Load input remaps
		if not file.eof_reached():
			var input_data = file.get_var()
			for action in input_data.keys():
				var event = input_data[action]
				if event is InputEvent:
					InputMap.action_erase_events(action)
					InputMap.action_add_event(action, event)
		file.close()
