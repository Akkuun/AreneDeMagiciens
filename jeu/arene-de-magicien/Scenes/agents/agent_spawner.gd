extends Node3D

@export var entity : PackedScene
@export var max_entity_count : int = 5
@export var initial_spawn_count : int = 0

@export var continuous_spawn : bool = true
@export var spawn_rate_seconds : float = 20

@onready var timer = $SpawnTimer


var active_entity_count : int = 0

func _ready() -> void:
	if continuous_spawn:
		timer.start(spawn_rate_seconds)
		
	for i in range(initial_spawn_count):
		get_tree().create_timer(i).timeout.connect(func():
			spawn()
		)


func entity_spawned_freed():
	active_entity_count -= 1

func spawn():
	var instance : Node3D = entity.instantiate()
	instance.tree_exited.connect(entity_spawned_freed)
	active_entity_count += 1
	add_child(instance)

func _on_spawn_timer_timeout() -> void:
	if active_entity_count >= max_entity_count:
		return
	spawn()
