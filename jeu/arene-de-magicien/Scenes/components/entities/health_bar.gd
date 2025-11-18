extends Sprite3D

@export var max_value: int = 100
@export var y_offset: int = 0
@export var hide_when_full: bool = true

@onready var progress_bar : ProgressBar = $SubViewport/ProgressBar

func _ready() -> void:
	progress_bar.max_value = max_value
	update_value(max_value)
	$SubViewport.size.y += y_offset

func update_value(value: int):
	progress_bar.value = value
	progress_bar.visible = hide_when_full and value < progress_bar.max_value
