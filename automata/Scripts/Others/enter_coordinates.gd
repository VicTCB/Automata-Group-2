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
	
	# 1. Instantiate the correct DFA scene
	var sim_scene
	if Global.active_dfa == 1:
		sim_scene = load("res://Scenes/DFA1/DFA1.tscn").instantiate()
	else:
		sim_scene = load("res://Scenes/DFA2/DFA2.tscn").instantiate()
		
	# 2. Add it directly to the root of the game
	get_tree().root.add_child(sim_scene)
	
	# 3. Destroy this UI menu
	queue_free()

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
