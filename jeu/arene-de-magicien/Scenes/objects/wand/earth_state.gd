extends State

@onready var earth_spell : PackedScene = load("res://Scenes/objects/earth_attack/earth_spikes.tscn") 

@export var muzzle : RayCast3D

func get_state_name() -> String:
	return "Earth"

func state_enter(args : Dictionary) -> bool:
	var start_pos = muzzle.global_transform.origin
	var down_dir = Vector3(0, -1, 0)
	var max_dist = 10.0

	var space_state = muzzle.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(start_pos, start_pos + down_dir * max_dist)
	var result = space_state.intersect_ray(query)

	if result.size() > 0:
		var ground_y = result.position.y
		var spike_instance = earth_spell.instantiate()
		spike_instance.ready.connect(func(): spike_instance.init(muzzle, muzzle.global_basis.y))
		get_tree().get_nodes_in_group("root_3d").front().add_child(spike_instance)
		spike_instance.global_position = Vector3(muzzle.global_position.x, ground_y, muzzle.global_position.z)
		spike_instance.connect("finished", func(): 
			state_manager.change_state("Idle"))
	
	return true
