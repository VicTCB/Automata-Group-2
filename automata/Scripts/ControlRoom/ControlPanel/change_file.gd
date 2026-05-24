extends StaticBody3D

var interact_text = "PRESS [F] TO CHANGE FILES"

func on_interact():
	if Global.active_dfa == 1:
		Global.active_dfa = 2
	else:
		Global.active_dfa = 1
	get_tree().get_first_node_in_group("DisplayScreen").update_texture()
