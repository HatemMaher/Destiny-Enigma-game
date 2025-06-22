extends Node2D

@export var animation_player : AnimationPlayer
@export var camera1 : Camera2D
 
func _ready():

	# Connect the signal to detect when the animation finishes
	animation_player.animation_finished.connect(_on_animation_finished)

func _input(event):
	if event.is_action_pressed("next") and not animation_player.is_playing() :
		animation_player.play()


func pause() -> void:
	if animation_player.is_playing() :
		animation_player.pause()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Chapter1_1":  # Optional: check for specific animation
		SaveSystem.current_scene_path = "res://scenes/world.tscn"
		get_tree().change_scene_to_file("res://scenes/world.tscn")
