extends CanvasLayer

signal close_menu


func _on_health_upgrade_pressed() -> void:
	Upgradesystem.health_upgrade=true


func _on_close_pressed() -> void:
	close_menu.emit()


func _on_damage_upgrade_pressed() -> void:
	Upgradesystem.damage_upgrade=true
