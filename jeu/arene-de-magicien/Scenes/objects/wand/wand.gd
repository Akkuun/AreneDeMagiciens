@tool
extends XRToolsPickable

enum WandState {IDLE, VACUUM, FIRE_BALL}

@export var lock_position : bool = false
@export var can_rotate : bool = false

func change_state(new_state: WandState) -> void:
	if new_state == WandState.VACUUM:
		$Spells.change_state("Vacuum")
	elif new_state == WandState.FIRE_BALL:
		$Spells.change_state("FireBall")
	else:
		$Spells.change_state("Idle")

var activate = true
func controller_action(controller : XRController3D):
	if controller.is_button_pressed("trigger_click"):
		process_spell()
		#if activate:
			#change_state(WandState.FIRE_BALL)
		#else:
			#change_state(WandState.IDLE)
		#
		#activate = !activate

func _input(event: InputEvent) -> void:
	if !is_picked_up():
		if event.is_action_pressed("debug_lock_rotation"):
			can_rotate = !can_rotate

func _physics_process(delta: float) -> void:
	if can_rotate:
		rotate_x(delta * deg_to_rad(90))
	
	axis_lock_linear_x = lock_position
	axis_lock_linear_y = lock_position
	axis_lock_linear_z = lock_position


func _on_spells_state_changed(new_state: String) -> void:
	$CurrentState.text = new_state


var move_list : PackedStringArray
func _on_spell_recognition_state_changed(new_state: String) -> void:
	$CurrentState.text = new_state
	#move_list.append(new_state)
	
	#$CurrentState.text = ", ".join(move_list)


var move_enum_list : Array[Global.MoveTypeEnum]
func _on_tilting_move_state_move_detected(move: Global.MoveTypeEnum) -> void:
	move_enum_list.append(move)
	
	move_list.append("push" if move == Global.MoveTypeEnum.SEND else "tornado")
	
	#$DebugText.text = ", ".join(move_list)

func play_fail():
	$CurrentState.text = "fail"

func process_spell():
	var fail : bool = false
	var throw : bool = false
	var tornado : bool = false
	
	for move in move_enum_list:
		if move == Global.MoveTypeEnum.SEND:
			fail = throw
			throw = true
		elif move == Global.MoveTypeEnum.TORNADO:
			tornado = true
	
	if fail:
		play_fail()
	elif tornado:
		change_state(WandState.VACUUM)
	elif throw:
		change_state(WandState.FIRE_BALL)
	
	move_enum_list.clear()
	move_list.clear()
