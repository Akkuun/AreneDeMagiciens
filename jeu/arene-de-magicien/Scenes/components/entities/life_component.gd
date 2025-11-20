extends Node

signal dead()
signal new_value(val: int)

@export var max_life = 100
@export var current_life = 0

func _ready() -> void:
	if(current_life == 0):
		current_life = max_life

func take_damage(quantity: int):
	current_life -= quantity
	if(current_life <= 0):
		dead.emit()
	else :
		new_value.emit(current_life)

func give_life(quantity: int):
	current_life += quantity
	if(current_life > max_life):
		current_life = max_life
	
	new_value.emit(current_life)
