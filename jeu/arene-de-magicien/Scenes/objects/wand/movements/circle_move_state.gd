extends State

@export var wand_root : XRToolsPickable
@export var move_recognizer : MoveRecognizer
@export var preparation_visual : Node3D

func get_state_name() -> String:
	return "Circle"


func state_process(delta: float) -> void:
	if wand_root.get_picked_up_by_controller():
		if move_recognizer.current_move == MoveRecognizer.MoveType.THRUST_Y:
			move_recognizer.consume_move()
			state_manager.change_state("Aim", {"Type": "Tornado"})

func state_enter(args : Dictionary) -> bool:
	Global.gesture_node.gesture_classified.connect(evaluate_move)
	preparation_visual.visible = true
	return true


func evaluate_move(move : String):
	if move == "Arrow":
		state_manager.change_state("Aim", {"Type": "Tornado"})
	#elif move == "Spiral":
		#state_manager.change_state("Vacuum")
	else:
		state_manager.change_state("Fail")

func state_leave() -> void:
	Global.gesture_node.gesture_classified.disconnect(evaluate_move)
	preparation_visual.visible = false
