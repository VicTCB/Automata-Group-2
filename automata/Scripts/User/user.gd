extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.002

@onready var camera = $Camera3D
@onready var interact_ray = $Camera3D/RayCast3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if Global.in_menu:
		return
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

func try_interact():
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()   
		if target.has_method("on_interact"):
			target.on_interact()
		elif target.get_parent().has_method("on_interact"):
			target.get_parent().on_interact()
