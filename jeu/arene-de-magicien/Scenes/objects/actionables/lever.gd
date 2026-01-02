extends Node3D

var activated : bool = false

@onready var pickable = $PickableObject
@onready var anim_player = $AnimationPlayer
var initial_dot: float
var anim_ratio : float

@export var pivot_offset: Vector3 = Vector3(0, -0.5, 0)
@export var trigger_ratio: float = 0.8

signal triggered

func _ready() -> void:
	initial_dot = pickable.basis.y.dot(-Vector3.FORWARD)
	
	anim_player.play("Activating")
	anim_player.seek(0.0, true)
	anim_player.pause()

func _process(delta: float) -> void:
	var forward_dot = pickable.basis.y.dot(-Vector3.FORWARD)
	
	anim_ratio = remap(forward_dot, initial_dot, -1.0, 0.0, 1.0)
	anim_player.seek(anim_ratio, true)
	
	if anim_ratio >= trigger_ratio:
		if !activated:
			activated = true
			triggered.emit()
	else:
		if activated and anim_ratio <= 0.1:
			activated = false


func _on_pickable_object_released(pickable: Variant, by: Variant) -> void:
	reset_lever()

func reset_lever():
	activated = false
	anim_player.seek(0.0, true)


func _on_pickable_object_picked_up(pickable: Variant) -> void:
	anim_player.pause()
