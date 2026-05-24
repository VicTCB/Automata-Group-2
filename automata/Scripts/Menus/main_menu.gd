extends Panel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.in_menu = true

func _exit_tree():
	Global.in_menu = false

func _on_board_station_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ControlRoom/Command_Room_2.tscn")


func _on_sign_off_pressed() -> void:
	get_tree().quit()
