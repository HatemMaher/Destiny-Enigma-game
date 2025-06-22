extends CharacterBody2D

# Define the size of the square area
const AREA_SIZE = 100.0
const AREA_MIN_X = -AREA_SIZE / 2.0
const AREA_MAX_X = AREA_SIZE / 2.0
const AREA_MIN_Y = -AREA_SIZE / 2.0
const AREA_MAX_Y = AREA_SIZE / 2.0

@export var speed : float = 100

var last_direction : Vector2 = Vector2.ZERO
var target_position : Vector2
var movement_timer: Timer
var waiting_for_move: bool = true
var start_position : Vector2
var player_in_range = false
var player = null

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	animation_tree.active = true  # Ensure the AnimationTree is active
	update_animation_parameters(Vector2.ZERO)  # Initialize animation parameters
	movement_timer = $movement_timer
	
	movement_timer.start(3)
	start_position = position 
	set_random_target_position()

func _physics_process(_delta: float) -> void:
	if player_in_range:
		nav_agent.target_position = player.position
		var direction = to_local(nav_agent.target_position).normalized()
		velocity = direction 
		update_animation_parameters(velocity)
		if Input.is_action_just_pressed("interact"):
			DialogueManager.create_dialogue(load("res://dialogue/orenthal.dialogue"),"start")
	else:
		if waiting_for_move:
			return
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		# Check if the slime has reached the target position
		if global_position.distance_to(target_position) < 10:
			waiting_for_move = true
			movement_timer.start(3)
			set_random_target_position()
		update_animation_parameters(velocity)

func set_random_target_position():
	target_position = start_position + Vector2(
		randf_range(-AREA_SIZE / 2.0, AREA_SIZE / 2.0),
		randf_range(-AREA_SIZE / 2.0, AREA_SIZE / 2.0)
	)
	target_position.x = clamp(target_position.x, start_position.x - AREA_SIZE / 2.0, start_position.x + AREA_SIZE / 2.0)
	target_position.y = clamp(target_position.y, start_position.y - AREA_SIZE / 2.0, start_position.y + AREA_SIZE / 2.0)

func update_animation_parameters(move_input: Vector2):
	if move_input != Vector2.ZERO:
		last_direction = move_input
		# Use only the x-component for horizontal movement
		var blend_value = move_input.x
		animation_tree.set("parameters/Walk/blend_position", blend_value)
		animation_tree.set("parameters/Idle/blend_position", blend_value)
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	else:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		
	if waiting_for_move:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false

	if player_in_range:
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/is_moving"] = false

func _on_movement_timer_timeout() -> void:
	waiting_for_move = false
	set_random_target_position()


func _on_area_2d_body_entered(body: Player) -> void:
	if body.name == "Player":
		player = body
		player_in_range = true
	


func _on_area_2d_body_exited(body: Player) -> void:
	if body.name == "Player":
		player_in_range = false
	
