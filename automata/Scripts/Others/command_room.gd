extends Node3D

@onready var pause_menu = $PauseMenu 

func _unhandled_input(event):
	if event.is_action_pressed("Escape Key"):
		var monitor_is_open = get_tree().root.has_node("Monitor2") 
		if not monitor_is_open:
			toggle_pause()

func toggle_pause():
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
