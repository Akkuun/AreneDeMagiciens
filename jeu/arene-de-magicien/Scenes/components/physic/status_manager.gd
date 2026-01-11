extends Node3D

const StatusEnum = Global.StatusEnum

signal status_applied(status: StatusEnum)
signal status_removed(status: StatusEnum)
signal dammage_taken(quantity: int)
signal first_hit_status_taken(dammage: int, direction: Vector3)

var status_giver_scene: PackedScene

@export var emit_shape : CollisionShape3D

@export var status_managed : Dictionary[StatusEnum, StatusCard]

#var status_tick_rates: Dictionary[StatusEnum, float]
	#StatusEnum.WATER: 0,
var status_timers: Dictionary[StatusEnum, Timer];
#@export var status_damages: Dictionary[StatusEnum, int]
	#StatusEnum.WATER: 20,


var active_givers: Dictionary[StatusEnum, StatusGiver]

func _ready() -> void:
	status_giver_scene = load("res://Scenes/components/physic/status_giver.tscn")
	for child in get_children():
		if(child is StatusReceiver):
			child.status_entered.connect(received)
			child.status_leaved.connect(leaved)


func received(status: StatusEnum, dammage: int, position: Vector3):
	for status_type in StatusEnum.values():
		if !status_managed.has(status_type):
			continue
		var current_status_card := status_managed[status_type]
		if current_status_card.currently_applied and status_type != status:
			if current_status_card.stoped_by == status:
				remove_status(status_type)
	
	if(!status_managed.has(status)):
		return
	else:
		var knockback : Vector3 = global_position - position
		first_hit_status_taken.emit(dammage, knockback)
		dammage_taken.emit(dammage)
		
	var received_status_card := status_managed[status]
	
	for status_type in StatusEnum.values():
		if !status_managed.has(status_type):
			continue
		var current_status_card := status_managed[status_type]
		if current_status_card.currently_applied and status_type != status:
			if received_status_card.stoped_by == status_type:
				return
	
	if !received_status_card.currently_applied:
		received_status_card.currently_applied = true
		emit_signal("status_applied", status)
		if(received_status_card.propagate):
			var new_giver := status_giver_scene.instantiate() as StatusGiver
			new_giver.status = status
			new_giver.add_child(emit_shape.duplicate())
			active_givers[status] = new_giver
			get_tree().create_timer(received_status_card.time_before_propagation).timeout.connect(func():
				if is_instance_valid(new_giver):
					add_child(new_giver)
				)
		
		if(received_status_card.tick_rate != 0):
			var timer := Timer.new()
			timer.one_shot = false
			timer.timeout.connect(func() : dammage_taken.emit(received_status_card.damage_by_tick))
			status_timers[status] = timer
			add_child(timer)
			timer.start(received_status_card.tick_rate)

func remove_status(status: StatusEnum):
	if(status_managed[status].currently_applied):
		status_managed[status].currently_applied = false
		emit_signal("status_removed", status)
		if(active_givers.has(status)):
			active_givers[status].queue_free()
			active_givers.erase(status)
		if(status_timers.has(status)):
			status_timers[status].queue_free()
			status_timers.erase(status)

func leaved(status: StatusEnum):
	if status == StatusEnum.HEAL:
		remove_status(StatusEnum.HEAL)
