extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.002

@onready var camera = $Camera3D
@onready var interact_ray = $Camera3D/RayCast3D
# NEW: Grab the reference to your new label
@onready var interact_label = $CanvasLayer/InteractLabel

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# NEW: Hide the label by default when the game starts
	interact_label.hide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if Global.in_menu:
		interact_label.hide()
		return
		
	# NEW: Check what the raycast is looking at every single frame
	update_hover_text()
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir = Input.get_vector("Movement_Left", "Movement_Right", "Movement_Forward", "Movement_Backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if Input.is_action_just_pressed("User_Interact"):
		try_interact()

# NEW: The function that controls the UI visibility
func update_hover_text():
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		
		# Find the specific node that holds the interact logic
		var interact_node = null
		if target.has_method("on_interact"):
			interact_node = target
		elif target.get_parent() and target.get_parent().has_method("on_interact"):
			interact_node = target.get_parent()
			
		# If we are looking at an interactable object...
		if interact_node:
			# If the object has a custom 'interact_text' variable, show it!
			if "interact_text" in interact_node:
				interact_label.text = "" + interact_node.interact_text
			else:
				# Default text if no variable is found
				interact_label.text = "[F] Interact"
				
			interact_label.show()
			return # Exit the function early so we don't hide it below
			
	# If we hit nothing, or the object isn't interactable, hide the text
	interact_label.hide()

func try_interact():
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()   
		if target.has_method("on_interact"):
			target.on_interact()
		elif target.get_parent().has_method("on_interact"):
			target.get_parent().on_interact()
