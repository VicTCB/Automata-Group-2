extends StaticBody3D

var interact_text = "PRESS [F] TO VIEW MISSION REPORT"

func on_interact():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var report = load("res://Scenes/Others/monitor_2.tscn").instantiate()
	get_tree().root.add_child(report) 
