extends Control

@onready var string_list = $Panel/VBoxContainer/StringList

func _ready():
	Global.in_menu = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_add_input_field()

func _add_input_field():
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = "Enter coordinates..."
	line_edit.custom_minimum_size = Vector2(300, 40)
	line_edit.text_changed.connect(_on_input_text_changed.bind(line_edit))
	
	string_list.add_child(line_edit)

func _on_add_button_pressed():
	_add_input_field()

func _on_reload_button_pressed():

	for child in string_list.get_children():
		child.queue_free()
	_add_input_field()

func _on_simulate_button_pressed():

	var strings = []
	for child in string_list.get_children():
		if child.text.strip_edges() != "":
			strings.append(child.text.strip_edges())
	
	if strings.is_empty():
		return

	Global.input_strings = strings
	Global.current_string_index = 0
	queue_free()
	
	if Global.active_dfa == 1:
		get_tree().change_scene_to_file("res://Scenes/DFA1Simulation.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/DFA2Simulation.tscn")

func _on_input_text_changed(new_text: String, line_edit: LineEdit):
	var allowed_chars = ""
	var filtered_text = ""

	if Global.active_dfa == 1:
		allowed_chars = "abAB"
	else:
		allowed_chars = "01"

	for character in new_text:
		if character in allowed_chars:
			filtered_text += character

	if new_text != filtered_text:
		var caret_pos = line_edit.caret_column
		line_edit.text = filtered_text
		line_edit.caret_column = caret_pos - 1

func _exit_tree():
	Global.in_menu = false 
