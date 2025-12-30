extends State

@export var wand_root : XRToolsPickable

func get_state_name() -> String:
	return "Tilting"


var previous_dot : float = 0.0
var tilting_proba := 0.0

func state_enter(args : Dictionary) -> bool:
	tilting_proba = 0.0
	previous_dot = compute_tilt_dot()
	return true


func compute_tilt_dot() -> float:
	var actual_orientation := wand_root.global_basis.z
	var target_orientation := actual_orientation.cross(Vector3.FORWARD).cross(Vector3.UP)
	
	return actual_orientation.dot(target_orientation)


func state_process(delta: float) -> void:
	var actual_dot := compute_tilt_dot()
	var dot_diff = actual_dot - previous_dot
	tilting_proba += dot_diff
	
	if tilting_proba >= 0.8:
		state_manager.change_state("Idle")
