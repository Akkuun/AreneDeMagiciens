extends Node3D

const StatusEnum = Global.StatusEnum

signal status_applied(status: StatusEnum)
signal status_removed(status: StatusEnum)
signal dammage_taken(quantity: int)

var status_giver_scene: PackedScene

@export var emit_shape : CollisionShape3D

@export var status_tick_rates: Dictionary[StatusEnum, float] = {
	StatusEnum.FIRE: 0.5,
	StatusEnum.WATER: 0
}
var status_timers: Dictionary[StatusEnum, Timer];

@export var status_damages: Dictionary[StatusEnum, int] = {
	StatusEnum.FIRE: 10,
	StatusEnum.WATER: 20
}

var active_status: Dictionary[StatusEnum, bool] = {
	StatusEnum.FIRE: false,
	StatusEnum.WATER: false
}

var active_givers: Dictionary[StatusEnum, StatusGiver]

func _ready() -> void:
	status_giver_scene = load("res://Scenes/components/physic/status_giver.tscn")
	for child in get_children():
		if(child is StatusReceiver):
			child.status_entered.connect(received)
			child.status_leaved.connect(leaved)


func received(status: StatusEnum):
	if(status == StatusEnum.WATER and active_status[StatusEnum.FIRE]):
		remove_status(StatusEnum.FIRE)
	elif(status == StatusEnum.FIRE and active_status[StatusEnum.WATER]):
		return
	elif(!active_status[status]):
		active_status[status] = true
		emit_signal("status_applied", status)
		if(emit_shape != null):
			var new_giver := status_giver_scene.instantiate() as StatusGiver
			new_giver.status = status
			new_giver.add_child(emit_shape.duplicate())
			active_givers[status] = new_giver
			add_child(new_giver)
		
		if(status_tick_rates[status] != 0):
			var timer := Timer.new()
			timer.one_shot = false
			timer.timeout.connect(func() : dammage_taken.emit(status_damages[status]))
			status_timers[status] = timer
			add_child(timer)
			timer.start(status_tick_rates[status])

func remove_status(status: StatusEnum):
	if(active_status[status]):
		active_status[status] = false
		emit_signal("status_removed", status)
		if(active_givers.has(status)):
			active_givers[status].queue_free()
			active_givers.erase(status)
		if(status_timers.has(status)):
			status_timers[status].queue_free()
			status_timers.erase(status)

func leaved(status: StatusEnum):
	pass
