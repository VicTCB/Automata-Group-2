extends Sprite3D

@export var dfa1_texture : Texture2D
@export var dfa2_texture : Texture2D

func _ready():
	update_texture()

func update_texture():
	if Global.active_dfa == 1:
		texture = dfa1_texture
	else:
		texture = dfa2_texture
