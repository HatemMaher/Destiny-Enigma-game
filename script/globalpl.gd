extends Node
var x=RandomNumberGenerator.new()
var critical_chance:int = 0
var player_cr:int = 15
var critical_strike = false

var player_current_attack = false
var player_damage = 20


func critical_hit():
	critical_chance = x.randi_range(1 , 100)
	if critical_chance <player_cr:
		critical_strike=true
	return critical_strike
