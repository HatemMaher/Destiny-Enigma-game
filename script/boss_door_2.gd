extends CharacterBody2D

@onready var gate = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready() -> void:
	$TextureRect.visible = false
	if SaveSystem.gate:
		gate.visible = false
		collision.disabled = true
		$TextureRect.visible = false


func _physics_process(_delta: float) -> void:
	if SaveSystem.key and Input.is_action_just_pressed("interact"):
		gate.visible = false
		collision.disabled = true
		SaveSystem.gate = true
		SaveSystem.key = false
		$TextureRect.visible = false
	else :
		if Input.is_action_just_pressed("interact"):
			$TextureRect.visible = true
			$LockSonund.play()
			await get_tree().create_timer(1).timeout
			$TextureRect.visible = false
