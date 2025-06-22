extends Node2D
@onready var upgrade_ui: CanvasLayer = $upgrade_ui
@onready var player = $Player

func _ready() -> void:
	if player != null:
		if SaveSystem.player_position_house != Vector2.ZERO:
			player.position = SaveSystem.player_position_house
		else:
			SaveSystem.player_position_house = position

func _process(_delta: float) -> void:
	if Upgradesystem.open_menu:
		upgrade_ui.visible=true
		



func _on_upgrade_ui_close_menu() -> void:
	Upgradesystem.open_menu=false
	upgrade_ui.visible=false
