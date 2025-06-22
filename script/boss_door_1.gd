extends CharacterBody2D

@onready var gate = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready() -> void:
	if SaveSystem.gate:
		gate.visible = false
		collision.disabled = true


func _physics_process(_delta: float) -> void:
	if SaveSystem.key and Input.is_action_just_pressed("interact"):
		gate.visible = false
		collision.disabled = true
		SaveSystem.gate = true
