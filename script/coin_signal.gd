extends Node2D

signal chest_opened_signal
signal enemy_death_signal


func open_chest(coins_to_add):
	emit_signal("chest_opened_signal", coins_to_add)

func enemy_death(coins_to_add):
	emit_signal("enemy_death_signal", coins_to_add)
