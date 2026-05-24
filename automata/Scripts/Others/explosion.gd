extends Node3D

@onready var anim_player = $AnimationPlayer # Make sure this path matches your Scene Tree!

func _ready():
	if anim_player:
		# 1. Grab the name of the imported animation (e.g., "Take 001")
		var anim_name = anim_player.get_animation_list()[0]
		
		# 2. Play it!
		anim_player.play(anim_name)
		
		# 3. Tell the script to wait until the animation physically finishes playing
		await anim_player.animation_finished
		
		# 4. Self-destruct!
		queue_free()
