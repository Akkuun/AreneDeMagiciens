extends Node3D

var activated : bool = false

@onready var pickable = $PickableObject
@onready var orientation_target : Skeleton3D = $ lever/Armature/Skeleton3D
var bone_attachment : BoneAttachment3D
@export var anim_player : AnimationPlayer
var initial_dot: float
var anim_ratio : float

@export var pivot_offset: Vector3 = Vector3(0, -0.5, 0)
@export var trigger_ratio: float = 0.8

signal triggered

var anim_total_duration : float = 0
func _ready() -> void:
	anim_player.play("ArmatureAction")
	anim_total_duration = anim_player.current_animation_length
	anim_player.seek(0.0, true)
	anim_player.pause()
	
	bone_attachment = BoneAttachment3D.new()
	bone_attachment.bone_name = "Bone"
	orientation_target.add_child(bone_attachment)
	
	reset_lever()

func _process(delta: float) -> void:
	var forward_dot = pickable.position.normalized().dot(-Vector3.FORWARD)
	
	anim_ratio = remap(forward_dot, initial_dot, -1.0, 0.0, 1.0)
	anim_player.seek(anim_ratio * anim_total_duration, true)
	
	pickable.global_rotation = bone_attachment.global_rotation
	pickable.global_position = bone_attachment.global_position
	
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
	
	pickable.global_rotation = bone_attachment.global_rotation
	pickable.global_position = bone_attachment.global_position
	initial_dot = pickable.position.normalized().dot(-Vector3.FORWARD)


func _on_pickable_object_picked_up(pickable: Variant) -> void:
	anim_player.pause()
