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

const ACCEPT_STATES = ["Q9"]
const START_STATE = "Q0"

const STATE_POSITIONS = {
	"Q0": Vector3(-32, 3, 0),
	"Q1": Vector3(-20, 3, -6),
	"Q2": Vector3(-8, 3, -6),
	"Q3": Vector3(-20, 3, 6),
	"Q4": Vector3(-8, 3, 6),
	"Q5": Vector3(0, 3, 0),
	"Q6": Vector3(12, 3, -6),
	"Q7": Vector3(12, 3, 6),
	"Q8": Vector3(24, 3, 0),
	"Q9": Vector3(36, 3, 0),
}

# --- NODE REFERENCES ---
@onready var rocket = $SimEnvironment/Rocket
@onready var sim_camera = $SimEnvironment/SimulationCamera
@onready var state_nodes_folder = $SimEnvironment/StateNodes

# --- SIMULATION VARIABLES ---
var state_path = []
var current_input_string = ""

func _ready():
	sim_camera.make_current() 
	
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

	# Instantly teleport the rocket to the starting position (Local position)
	rocket.position = STATE_POSITIONS[state_path[0]]

	# Wait 1 second before moving so the player can orient themselves
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
		
		var target_pos = STATE_POSITIONS[next_state]
		
		# Check if the rocket is looping back to the exact same state
		if current_state == next_state:
			var hop_height = target_pos + Vector3(0, 4, 0) 
			
			# 1. Hop up (using position, not global_position)
			tween.tween_property(rocket, "position", hop_height, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
			# 2. Barrel roll! Spin exactly 360 degrees from wherever we currently are
			tween.parallel().tween_property(rocket, "rotation_degrees:y", 360.0, 0.8).as_relative()
			
			# 3. Hop down
			tween.tween_property(rocket, "position", target_pos, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
		else:
			# Normal flight to the next node
			tween.tween_property(rocket, "position", target_pos, 1.0).set_trans(Tween.TRANS_SINE)
			
		# Add a tiny pause at each node so it doesn't slide continuously
		tween.tween_interval(0.2) 

	# Once the entire sequence is finished, trigger the evaluation
	tween.finished.connect(_on_simulation_finished)

func _on_simulation_finished():
	var final_state = state_path[-1]
	
	if final_state in ACCEPT_STATES:
		print("RESULT: STRING ACCEPTED!")
	else:
		print("RESULT: STRING REJECTED!")

	# Wait 2 seconds so the player can see the final result
	await get_tree().create_timer(2.0).timeout
	
	_move_to_next_string()

func _move_to_next_string():
	Global.current_string_index += 1
	
	if Global.current_string_index < Global.input_strings.size():
		run_current_string()
	else:
		print("Simulation complete! Returning control.")
		queue_free()
