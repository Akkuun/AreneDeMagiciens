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
	$DebugText.text = new_state


func _on_action_pressed(pickable: Variant) -> void:
	draw = true

func analyze_gesture():
	
	$Drawing/GestureNode.classiffy_gesture($Drawing.get_drawing())
	
	var drawing_instance = load("res://Scenes/objects/wand/drawing_visual.tscn").instantiate() as Node3D
	get_parent_node_3d().add_child(drawing_instance)
	drawing_instance.show_drawing($Drawing.planned_points, $Drawing.x_dir, $Drawing.y_dir, 5)
	
	$Drawing.clear_history()
	

func _on_action_released(pickable: Variant) -> void:
	draw = false
	call_deferred_thread_group("analyze_gesture")
	#$Drawing/GestureNode.classiffy_gesture($Drawing.get_drawing())
