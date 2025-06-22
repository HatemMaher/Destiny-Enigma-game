extends Area2D
class_name Hitbox

@export var damage :int = 0



func set_damage(value):
	damage = value

func get_damage()->int:
	return damage 
	
func _on_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.
