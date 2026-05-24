extends CanvasLayer

func _ready() -> void:
	hide() # Hide it immediately on startup

func _on_resume_pressed() -> void:
	# We call the function on the parent (CommandRoom2) so it manages the state
	get_parent().toggle_pause()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_sign_off_pressed() -> void:
	get_tree().quit()
