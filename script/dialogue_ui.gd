extends CanvasLayer

@onready var portrait = $Panel/Portrait
@onready var dialogue_text = $Panel/DialogueText

var current_lines = []
var current_line_index = 0
var is_active = false

signal dialogue_started  # Add this
signal dialogue_ended    # Add this

func _ready():
	SaveSystem.dialogue = true
	hide()

func show_dialogue():
	show()
	is_active = true

func hide_dialogue():
	hide()
	is_active = false

func start_dialogue(lines):

	emit_signal("dialogue_started")
	if is_active:
		return
	
	current_lines = lines
	current_line_index = 0
	show_dialogue()
	_display_current_line()

func _display_current_line():
	if current_line_index < current_lines.size():
		dialogue_text.text = current_lines[current_line_index]
	else:
		end_dialogue()

func next_line():
	current_line_index += 1
	_display_current_line()

func end_dialogue():
	emit_signal("dialogue_ended")
	hide_dialogue()
	current_lines = []
	current_line_index = 0

func _input(event):
	if event.is_action_pressed("ui_accept") and is_active:
		next_line()
