class_name StatusCard extends Resource

@export var propagate : bool = false
@export var tick_rate : float = 1.0
@export var damage_by_tick : float = 5
@export var stoped_by : Global.StatusEnum = Global.StatusEnum.NONE

var currently_applied : bool = false
