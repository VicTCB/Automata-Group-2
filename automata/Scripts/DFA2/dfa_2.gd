extends Node3D

# --- DFA DEFINITION ---
const TRANSITIONS = {
	"Q0": {"0": "Q1", "1": "Q3"},
	"Q1": {"0": "Q5", "1": "Q2"},
	"Q2": {"0": "Q5", "1": "Q5"},
	"Q3": {"0": "Q4", "1": "Q5"},
	"Q4": {"0": "Q5", "1": "Q5"},
	"Q5": {"0": "Q6", "1": "Q7"},
	"Q6": {"0": "Q8", "1": "Q7"},
	"Q7": {"0": "Q6", "1": "Q8"},
	"Q8": {"0": "Q9", "1": "Q9"},
	"Q9": {"0": "Q9", "1": "Q9"},
}
const HOVER_OFFSET = Vector3(0, 7, 0)
const ACCEPT_STATES = ["Q9"]
const START_STATE = "Q0"

const STATE_POSITIONS = {
	"Q0": Vector3(-60, 3, 0),
	"Q1": Vector3(-40, 3, -20),
	"Q2": Vector3(-15, 3, -28),
	"Q3": Vector3(-40, 3, 20),
	"Q4": Vector3(-15, 3, 28),
	"Q5": Vector3(-15, 3, 0),
	"Q6": Vector3(15, 3, -15),
	"Q7": Vector3(15, 3, 15),
	"Q8": Vector3(35, 3, 0),
	"Q9": Vector3(65, 3, 0),
}

# --- NODE REFERENCES ---
@onready var rocket = $SimEnvironment/Rocket
@onready var sim_camera = $SimEnvironment/SimulationCamera
@onready var state_nodes_folder = $SimEnvironment/StateNodes
var explosion_scene = preload("res://Assets/3D/Use_This/explosion.tscn")
@onready var success_audio = $SimEnvironment/SuccessSound

# --- SIMULATION VARIABLES ---
var state_path = []
var current_input_string = ""

func _ready():
	sim_camera.make_current() 
	Global.in_menu = true
	# --- NEW: AUTO-ALIGN PLANETS ---
	# Loop through every state in the dictionary
	for state_name in STATE_POSITIONS.keys():
		# Find the 3D mesh with that exact name inside the StateNodes folder
		var planet_mesh = state_nodes_folder.get_node_or_null(state_name)
		
		# If the mesh exists, snap its position to the exact dictionary coordinates!
		if planet_mesh != null:
			planet_mesh.position = STATE_POSITIONS[state_name]
	# -------------------------------
	
	run_current_string()

func run_current_string():
	current_input_string = Global.input_strings[Global.current_string_index]
	state_path = build_path(current_input_string)
	
	print("-----------------------------------")
	print("Simulating string: ", current_input_string)
	print("Path taken: ", state_path)

	# --- NEW: Bring the rocket back to life! ---
	rocket.show()
	
	rocket.position = STATE_POSITIONS[state_path[0]] + HOVER_OFFSET

	await get_tree().create_timer(1.0).timeout
	animate_rocket()

func build_path(input: String) -> Array:
	var path = [START_STATE]
	var current = START_STATE
	
	for ch in input:
		if TRANSITIONS[current].has(ch):
			current = TRANSITIONS[current][ch]
		path.append(current)
		
	return path

func animate_rocket():
	var tween = create_tween()
	
	for i in range(1, state_path.size()):
		var current_state = state_path[i-1]
		var next_state = state_path[i]
		
		# Add the HOVER_OFFSET to the target destination!
		var target_pos = STATE_POSITIONS[next_state] + HOVER_OFFSET
		
		if current_state == next_state:
			var hop_height = target_pos + Vector3(0, 4, 0) 
			
			tween.tween_property(rocket, "position", hop_height, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(rocket, "rotation_degrees:y", 360.0, 0.8).as_relative()
			tween.tween_property(rocket, "position", target_pos, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
		else:
			tween.tween_property(rocket, "position", target_pos, 1.0).set_trans(Tween.TRANS_SINE)
			
		tween.tween_interval(0.2) 
	tween.finished.connect(_on_simulation_finished)

func _on_simulation_finished():
	var final_state = state_path[-1]
	
	if final_state in ACCEPT_STATES:
		print("RESULT: STRING ACCEPTED!")
		success_audio.play() # <--- PLAY THE AUDIO!
	else:
		print("RESULT: STRING REJECTED!")
		trigger_explosion() # <--- SPAWN THE EXPLOSION!

	await get_tree().create_timer(5.0).timeout
	_move_to_next_string()

func _move_to_next_string():
	Global.current_string_index += 1
	
	if Global.current_string_index < Global.input_strings.size():
		run_current_string()
	else:
		print("Simulation complete! Returning control.")
		queue_free()

func trigger_explosion():
	# 1. Spawn the explosion scene
	var boom = explosion_scene.instantiate()
	$SimEnvironment.add_child(boom)
	
	# 2. Snap it to the rocket's exact position
	boom.global_position = rocket.global_position
	
	# 3. Hide the rocket so it looks like it blew up
	rocket.hide()
	
	# Note: We don't need to tell it to play or queue_free anymore! 
	# The Explosion's own _ready() function handles all of that now.
