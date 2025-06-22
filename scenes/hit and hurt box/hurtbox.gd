extends Area2D
class_name Hurtbox
 

signal recieved_damage(damage:int)


func _on_area_entered(hitbox: Object) -> void:
	if hitbox is Hitbox:  # Ensure the object is of type Hitbox
		recieved_damage.emit(hitbox.damage)
		
	pass # Replace with function body.
