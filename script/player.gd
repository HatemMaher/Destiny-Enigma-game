class_name Player extends CharacterBody2D

# Exported variables that can be set in the editor
@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, 1)
@export var max_health = 100
@export var pure_damage:int=20
var damage:int = pure_damage
var health = max_health
var x=RandomNumberGenerator.new()
var critical_chance:int = 0
@export var player_cr:int = 15
var player_alive = true
var attack_ip = true
var input_active_at_start = false
var coin_counter = 0
var stone_counter = 0
var movement_enabled = true
#signal to emit the player damage
signal playerdamage(damage)
@onready var coin_label = %Label
@onready var stone_label = $CanvasLayer/Label2


# Onready variable to get the AnimationTree node
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_player = $AnimationPlayer



# Variable to store the last direction of movement
var last_direction : Vector2 = Vector2.ZERO

# Function called when the node is ready
func _ready():
	if SaveSystem.key :
		$CanvasLayer/TextureRect3.visible = true
	else:
		$CanvasLayer/TextureRect3.visible = false
	# Update animation parameters with the starting direction
	update_animation_parameters(starting_direction)
	# Load health from global variable
	health = SaveSystem.player_health
	stone_counter = SaveSystem.player_stone_counter
	set_stone(stone_counter)
	coin_counter = SaveSystem.player_coin_counter
	set_coin(coin_counter)
	CoinSignal.connect("chest_opened_signal", Callable(self, "_on_chest_opened"))

	
	



# Function called every physics frame
func _physics_process(_delta: float) -> void:
	if SaveSystem.key :
		$CanvasLayer/TextureRect3.visible = true
	else:
		$CanvasLayer/TextureRect3.visible = false
	SaveSystem.current_player_position = global_position

	#upgrading player stats
	upgrading()
		
	#player takes damage
	update_health()
		
	if SaveSystem.dialogue:
		velocity = Vector2.ZERO 
		update_animation_parameters(velocity)
		return
	
	if !movement_enabled :
		velocity = Vector2.ZERO 
		update_animation_parameters(velocity)
		return
	#checking if player is alive
	if health <=0:
		player_alive = false #go back to menu or last checkpoint
		health = 0
		velocity = Vector2.ZERO
		update_animation_parameters(velocity)
		return
	# Get input direction based on player input
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	# Update animation parameters with the input direction
	update_animation_parameters(input_direction)
	
	# Update velocity based on input direction and move speed
	velocity = input_direction * move_speed 
	
	# Move the character using the move and slide function
	move_and_slide()
	# Handle footstep sound
	if input_direction.length() > 0:
		if not $player_walk_sound.playing:
			$player_walk_sound.play()
	else:
		if $player_walk_sound.playing:
			$player_walk_sound.stop()

# Function to update animation parameters based on movement input
func update_animation_parameters(move_input : Vector2):

	# If there is movement input
	if move_input != Vector2.ZERO:
		# Update the last direction to the current movement input
		last_direction = move_input
		# Set the blend position for the walk animation
		animation_tree.set("parameters/walk/blend_position", move_input)
		# Set the blend position for the idle animation
		animation_tree.set("parameters/idle/blend_position", move_input)
		# Set the idle condition to false and is_moving condition to true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	else:
		# If there is no movement input, set the idle condition to true and is_moving condition to false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false

	# Check if the strike action is just pressed
	if Input.is_action_just_pressed("strike") and attack_ip and movement_enabled:
		# Set the strike condition to true
		animation_tree["parameters/conditions/strike"] = true
		$PlyerSwingSound.play()
		damage=critical_hit()
		playerdamage.emit(damage)
		
		$"attack cooldown".start()
		attack_ip = false
	else:
		# Otherwise, set the strike condition to false
		animation_tree["parameters/conditions/strike"] = false
	
	
	# Set the blend position for the strike animation
	animation_tree.set("parameters/strike/blend_position", move_input)
	animation_tree.set("parameters/strike/blend_position", last_direction)
	
	if Input.is_action_just_pressed("roll"):
		animation_tree["parameters/conditions/is_roll"] = true
	else:
		animation_tree["parameters/conditions/is_roll"] = false
	animation_tree.set("parameters/roll/blend_position", move_input)
	animation_tree.set("parameters/roll/blend_position", last_direction)
	
	if health <=0:
		animation_tree.set("parameters/die/blend_position", move_input)
		animation_tree.set("parameters/die/blend_position", last_direction)
		animation_tree["parameters/conditions/die"] = true
		$PlayerHeartSound.stop()
		attack_ip = false
		$healthregen.stop()
		await get_tree().create_timer(1.1).timeout
		SaveSystem.save_game()
		SaveSystem.overwrite_save_with_backup()
		if SaveSystem.player_stone_counter <= 4 :
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/game_over_return.tscn")
			


func _on_attack_cooldown_timeout() -> void:
	attack_ip= true
	
func update_health():
	var healthbar = $CanvasLayer/TextureProgressBar
	healthbar.max_value =max_health
	healthbar.value = health
	SaveSystem.player_health = health
	healthbar.visible = true

func critical_hit():
	critical_chance = x.randi_range(1 , 100)
	if critical_chance <player_cr:
		damage= pure_damage*2
		return damage
	else:
		damage= pure_damage
		return damage
	
func _on_healthregen_timeout() -> void:
	if health < max_health:
		health += 2
		health = min(health,max_health)
	if health >= max_health:
		$healthregen.stop()
#player taking damage		
func _on_hurtbox_recieved_damage(incoming_damage: int) -> void:
	health-=incoming_damage
	$PlayerHeartSound.play()
	$healthregen.start()
	if health <= 0 :
		$player_die_sound.play()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		$coin_sound.play()
		set_coin(coin_counter + 1)
		SaveSystem.player_coin_counter = coin_counter
	elif area.is_in_group("stone"):
			$stone_sound.play()
			set_stone(stone_counter + 1)
			SaveSystem.player_stone_counter = stone_counter
	else:
		if area.is_in_group("key"):
			$stone_sound.play()
			$CanvasLayer/TextureRect3.visible = true
		

func set_coin(new_coin_count: int) -> void:
	coin_counter = new_coin_count
	SaveSystem.player_coin_counter = coin_counter
	coin_label.text =  str(coin_counter)
	
func set_stone(new_stone_count: int) -> void:
	stone_counter = new_stone_count
	SaveSystem.player_stone_counter = stone_counter
	stone_label.text =  str(stone_counter)

func _on_chest_opened(coins: int) -> void:
	$coin_prize.play()
	set_coin(coin_counter + coins)




func set_movement_enabled(enabled: bool):
	movement_enabled = enabled
	if !enabled:
		velocity = Vector2.ZERO


	
func upgrading():
	if Upgradesystem.health_upgrade:
		max_health +=20
		health = max_health
		SaveSystem.player_health=health
		Upgradesystem.health_upgrade=false
	if Upgradesystem.damage_upgrade:
		pure_damage+=5
		Upgradesystem.damage_upgrade=false
