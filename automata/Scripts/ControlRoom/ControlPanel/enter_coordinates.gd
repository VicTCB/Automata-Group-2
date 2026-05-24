extends StaticBody3D

var interact_text = "PRESS [F] TO INPUT COORDINATES"

func on_interact():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var scene = load("res://Scenes/Others/enter_coordinates.tscn").instantiate()
	get_tree().root.add_child(scene)
