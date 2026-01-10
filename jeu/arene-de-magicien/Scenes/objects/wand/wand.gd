@tool
extends XRToolsPickable

@export var sample_rate : int = 2
@export var sample_count : int = 60
var current_frame: int = 0
var draw : bool = false
func _ready():
	super._ready()
	$Drawing.points_count = sample_count

func _physics_process(delta: float) -> void:
	if current_frame == 0:
		if draw:
			$Drawing.register_new_point($Muzzle.global_position)
	
	current_frame = (current_frame + 1) % sample_rate

func _on_spell_recognition_state_changed(new_state: String) -> void:
	pass
	#$DebugText.text = new_state


func _on_action_pressed(pickable: Variant) -> void:
	draw = true


func _on_action_released(pickable: Variant) -> void:
	draw = false
	$Drawing/GestureNode.classiffy_gesture($Drawing.get_drawing())


func _on_gesture_node_gesture_classified(GestureName: StringName) -> void:
	$DebugText.text = GestureName
