extends Node3D

# --- DFA DEFINITION ---
# Mapped exactly to your handwritten table
const TRANSITIONS = {
	"Q0": {"a": "Q1", "b": "Q2"},
	"Q1": {"a": "Q2", "b": "Q2"},
	"Q2": {"a": "Q3", "b": "Q5"},
	"Q3": {"a": "Q4", "b": "Q5"},
	"Q4": {"a": "Q7", "b": "Q5"},
	"Q5": {"a": "Q3", "b": "Q6"},
	"Q6": {"a": "Q3", "b": "Q7"},
	"Q7": {"a": "Q8", "b": "Q8"},
	"Q8": {"a": "Q8", "b": "Q8"}
}
const HOVER_OFFSET = Vector3(0, 3, 0)
const ACCEPT_STATES = ["Q8"]
const START_STATE = "Q0"

# --- STATE POSITIONS ---
const STATE_POSITIONS = {
	"Q0": Vector3(-60, 3, 0),
	"Q1": Vector3(-40, 3, 20),
	"Q2": Vector3(-30, 3, -15),
	"Q3": Vector3(0, 3, -25),
	"Q4": Vector3(25, 3, -15),
	"Q5": Vector3(0, 3, 10),
	"Q6": Vector3(25, 3, 20),
	"Q7": Vector3(45, 3, 0),
	"Q8": Vector3(65, 3, 0)
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
	
	# Auto-align the planet meshes to the mathematical coordinates
	for state_name in STATE_POSITIONS.keys():
		var planet_mesh = state_nodes_folder.get_node_or_null(state_name)
		if planet_mesh != null:
			planet_mesh.position = STATE_POSITIONS[state_name]
			
	run_current_string()

func run_current_string():
	current_input_string = Global.input_strings[Global.current_string_index]
	state_path = build_path(current_input_string)
	
	print("-----------------------------------")
	print("Simulating string: ", current_input_string)
	print("Path taken: ", state_path)

	# Teleport to start
	rocket.position = STATE_POSITIONS[state_path[0]] + HOVER_OFFSET

	# Wait 1 second before moving
	await get_tree().create_timer(1.0).timeout
	animate_rocket()

func build_path(input: String) -> Array:
	var path = [START_STATE]
	var current = START_STATE
	
	# .to_lower() ensures it works even if the user typed capital A or B
	for ch in input.to_lower():
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
	else:
		print("RESULT: STRING REJECTED!")

	await get_tree().create_timer(2.0).timeout
	_move_to_next_string()

func _move_to_next_string():
	Global.current_string_index += 1
	
	if Global.current_string_index < Global.input_strings.size():
		run_current_string()
	else:
		print("Simulation complete! Returning control.")
		queue_free()
