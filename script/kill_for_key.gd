extends Node2D

@export var key_node: Node2D  # Assign the key node in the inspector
var last_death_position: Vector2

func _ready():
	if key_node:
		key_node.hide()


	_connect_to_enemies()

func _connect_to_enemies():
	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			if enemy.has_signal("died"):
				enemy.connect("died", Callable(self, "_on_enemy_died").bind(enemy))


func _on_enemy_died(enemy):
	last_death_position = enemy.global_position


	await get_tree().process_frame  # Wait for removal

	var enemies_remaining = false
	for child in get_children():
		if child.is_in_group("enemy"):
			enemies_remaining = true
			break


	if !enemies_remaining:
		if key_node:
			key_node.global_position = last_death_position
			key_node.show()
