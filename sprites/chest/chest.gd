extends Area2D

class_name Chest

@onready var animation_player = $AnimatedSprite2D
var player_near = false # Track if the player is near
var chest_opened = false
@export var chest_id = 0

func _ready() -> void:
	chest_opened = SaveSystem.get_chest_opened(chest_id)
	if chest_opened:
		animation_player.play("open")  
		animation_player.frame = 3 


func _on_body_entered(_body: Player):
	if _body is Player:
		player_near = true

func _on_body_exited(_body: Node):
	player_near = false


func _process(_delta: float):
	if player_near and Input.is_action_just_pressed("interact") and chest_opened==false:
		open_chest()


func open_chest():
	animation_player.play("open")
	chest_opened = true
	SaveSystem.set_chest_opened(chest_id, chest_opened)
	$ChestOpenSound.play()
	await animation_player.animation_finished
	# Generate a random number of coins
	var coins_to_add = int(randf_range(1, 6))
	CoinSignal.emit_signal("chest_opened_signal", coins_to_add)
