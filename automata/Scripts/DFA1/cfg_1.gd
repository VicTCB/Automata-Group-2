extends Panel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.in_menu = true

func _exit_tree():
	Global.in_menu = false
