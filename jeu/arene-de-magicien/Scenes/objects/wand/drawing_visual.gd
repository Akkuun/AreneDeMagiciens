extends Node3D

var points : PackedVector3Array

func show_drawing(pts: PackedVector3Array, x : Vector3, y: Vector3, duration: float):
	points = pts
	
	var x_norm = x.normalized()
	var y_norm = y.normalized()
	global_basis = Basis(x_norm, y_norm, x_norm.cross(y_norm))
	
	get_tree().create_timer(duration).timeout.connect(func(): queue_free())

func _process(delta: float) -> void:
	DebugDraw3D.draw_line_path(points)
