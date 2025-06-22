extends Area2D

@onready var bubble_sprite = $Sprite2D
@onready var dialogue_box = $DialogueBox
@onready var massege = $DialogueBox/Label

var player_in_range = false  # Track if player is in area


func _ready():
	bubble_sprite.visible = false  
	dialogue_box.visible = false
	massege.visible = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact") and ! dialogue_box.visible:
		bubble_sprite.visible = false
		dialogue_box.visible = true
		massege.visible = true
		
		$box_sound.play()


func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		bubble_sprite.visible = true


func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		bubble_sprite.visible = false
		dialogue_box.visible = false
		massege.visible = false
