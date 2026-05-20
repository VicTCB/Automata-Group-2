extends Panel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_show_pda_pressed() -> void:
	var scene
	if Global.active_dfa == 1:
		scene = load("res://Scenes/DFA1/pda_1.tscn").instantiate()
	else:
		scene = load("res://Scenes/DFA2/pda_2.tscn").instantiate()
	get_tree().root.add_child(scene)


func _on_show_cfg_pressed() -> void:
	var scene
	if Global.active_dfa == 1:
		scene = load("res://Scenes/DFA1/cfg_1.tscn").instantiate()
	else:
		scene = load("res://Scenes/DFA2/cfg_2.tscn").instantiate()
	get_tree().root.add_child(scene)


func _on_show_reg_ex_pressed() -> void:
	var scene
	if Global.active_dfa == 1:
		scene = load("res://Scenes/DFA1/reg_ex_1.tscn").instantiate()
	else:
		scene = load("res://Scenes/DFA2/reg_ex_2.tscn").instantiate()
	get_tree().root.add_child(scene)
