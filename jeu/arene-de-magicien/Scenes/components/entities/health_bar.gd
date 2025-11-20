extends Sprite3D

@export var max_value: int = 100

func _ready() -> void:
	$SubViewport/ProgressBar.max_value = max_value
	$SubViewport/ProgressBar.value = max_value

func update_value(value: int):
	$SubViewport/ProgressBar.value = value
