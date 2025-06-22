extends CharacterBody2D

# Define the size of the square area
const AREA_SIZE = 70.0
const AREA_MIN_X = -AREA_SIZE / 2.0
const AREA_MAX_X = AREA_SIZE / 2.0
const AREA_MIN_Y = -AREA_SIZE / 2.0
const AREA_MAX_Y = AREA_SIZE / 2.0
@export var id = 0
@export var speed : float = 100
@export var speed_attack = 50
@export var health:int = 100
@export var orc_damage = 10

var last_direction : Vector2 = Vector2.ZERO
var player_chase = false
var player = null
var attack = false
var attack_run = false
var stop_range = 11
var attack_range = 20.0
var attack_run_range = 40.0
var target_position : Vector2
var movement_timer: Timer
var waiting_for_move: bool = true
var start_position : Vector2
var is_attacking = false 
var is_alive = true
var attack_ip = true
var dead = false
signal orcdamage(orc_damage)
signal died

var stone_scene := preload("res://scenes/stone.tscn") 
@onready var attack_timer = $attack_timer
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var detection_area : Area2D = $detection_area
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	if SaveSystem.enemy_states.has(id) and SaveSystem.enemy_states[id].dead:
		queue_free()
		return
	# Load previous state if available
	if SaveSystem.enemy_states.has(id):
		var data = SaveSystem.enemy_states[id]
		global_position = data.position
		health = data.health
	else:
		# Register new enemy state
		SaveSystem.enemy_states[id] = {
			"position": global_position,
			"health": health,
			"dead": false
		}
	animation_tree.active = true  # Ensure the AnimationTree is active
	update_animation_parameters(Vector2.ZERO)  # Initialize animation parameters
	movement_timer = $movement_timer
	
	movement_timer.start(1)
	start_position = position 
	set_random_target_position()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		player_chase = true 


func _on_detection_area_body_exited(_body: Node2D) -> void:
	player = null
	player_chase = false


func _physics_process(_delta: float) -> void:
	update_health()
	is_orc_alive()
	if health <= 0:
		health = 0
		velocity = Vector2.ZERO
		update_animation_parameters(velocity)
		return
	else:
		SaveSystem.enemy_states[id].position = global_position
		SaveSystem.enemy_states[id].health = health
	if player_chase:
		nav_agent.target_position = player.position
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = current_agent_position.direction_to(next_path_position)*speed_attack
		if nav_agent.is_navigation_finished():
			return
		if nav_agent.avoidance_enabled:
			nav_agent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
		var distance_to_player = global_position.distance_to(player.global_position)
		if is_attacking:
			velocity = Vector2.ZERO
		if distance_to_player > attack_run_range:
			attack = false
			attack_run = false
			velocity = new_velocity
		elif distance_to_player > attack_range:
			attack = false
			attack_run = true
			velocity = new_velocity
		else:
			if not is_attacking:
				attack = true
				attack_run = false
				is_attacking = true
				attack_timer.start()  # Start attack cooldown
			if distance_to_player < stop_range:
				var direction = global_position.direction_to(player.global_position)
				velocity = - direction * 200
			else:
				velocity = Vector2.ZERO 
		update_animation_parameters(new_velocity)
		move_and_slide()

	else:
		if waiting_for_move:
			return

		move_and_slide()
		# Check if the slime has reached the target position
		if global_position.distance_to(target_position) < 10:
			waiting_for_move = true
			movement_timer.start(1)
			set_random_target_position()
		update_animation_parameters(velocity)

func set_random_target_position():
	target_position = start_position + Vector2(
		randf_range(-AREA_SIZE / 2.0, AREA_SIZE / 2.0),
		randf_range(-AREA_SIZE / 2.0, AREA_SIZE / 2.0)
	)
	target_position.x = clamp(target_position.x, start_position.x - AREA_SIZE / 2.0, start_position.x + AREA_SIZE / 2.0)
	target_position.y = clamp(target_position.y, start_position.y - AREA_SIZE / 2.0, start_position.y + AREA_SIZE / 2.0)
	nav_agent.target_position = target_position
	var current_agent_position = global_position
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position)*speed
	if nav_agent.is_navigation_finished():
		return
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func update_animation_parameters(move_input: Vector2):
	if move_input != Vector2.ZERO:
		last_direction = move_input
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Run/blend_position", move_input)
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	else:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	 
	if waiting_for_move:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	
	if health <= 0:
		animation_tree.set("parameters/Death/blend_position", move_input)
		animation_tree.set("parameters/die/blend_position", last_direction)
		animation_tree["parameters/conditions/die"] = true
		if $death.is_stopped():
			$OrcDeathSound.play()
			$death.start()
	
	if player_chase:
		if attack_run:
			
			animation_tree.set("parameters/Run_attack/blend_position", move_input)
			animation_tree["parameters/conditions/is_run"] = false
			animation_tree["parameters/conditions/run_attack"] = true
			animation_tree["parameters/conditions/attack"] = false 
			animation_tree["parameters/conditions/is_moving"] = true  
			orcdamage.emit(orc_damage)
			
			
		elif attack:
			
			animation_tree.set("parameters/Attack/blend_position", move_input)
			animation_tree["parameters/conditions/run_attack"] = false
			animation_tree["parameters/conditions/attack"] = true
			animation_tree["parameters/conditions/is_run"] = false
			animation_tree["parameters/conditions/is_moving"] = false  
			orcdamage.emit(orc_damage)
			
			
		else:
			
			animation_tree.set("parameters/Run/blend_position", move_input)
			animation_tree["parameters/conditions/idle"] = false
			animation_tree["parameters/conditions/is_run"] = true
			animation_tree["parameters/conditions/run_attack"] = false
			animation_tree["parameters/conditions/attack"] = false
			animation_tree["parameters/conditions/is_moving"] = false
			
	else:
		
		animation_tree["parameters/conditions/is_run"] = false
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/run_attack"] = false

func _on_movement_timer_timeout() -> void:
	waiting_for_move = false
	set_random_target_position()

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	healthbar.visible = true

func _on_attack_timer_timeout() -> void:
	is_attacking = false  # Allow movement after attack
	attack = false  # Reset attack state



func is_orc_alive():
	if is_alive == false:
		emit_signal("died")
		dead = true
		for i in range(3):
			var stone_instance = stone_scene.instantiate()
			stone_instance.position = self.position + Vector2(2 * i, 0) 
			get_parent().add_child(stone_instance)
		SaveSystem.enemy_states[id].dead = true
		self.queue_free()
		var coins_to_add = int(2)
		CoinSignal.emit_signal("enemy_death_signal", coins_to_add)
		
func _on_death_timeout() -> void:
	is_alive = false
func _on_hurtbox_recieved_damage(incoming_damage: int) -> void:
	health-=incoming_damage
	$PlayerHitSwingSound.play()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
