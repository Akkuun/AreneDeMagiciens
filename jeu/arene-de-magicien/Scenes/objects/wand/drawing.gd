class_name DrawingRecognizer extends Node
var points_count : int
var point_history: Array[Vector3]
var planned_points : PackedVector3Array
var x_dir := Vector3.ZERO
var y_dir := Vector3.ZERO
var center := Vector3.ZERO

func _enter_tree() -> void:
	Global.draw_recog = self


func register_new_point(point: Vector3):
	if point_history.size() > points_count:
		point_history.pop_front()
	
	point_history.push_back(point)

func clear_history():
	point_history.clear()

func compute_barycentre() -> Vector3:
	var point_sum := Vector3.ZERO
	
	for point in point_history:
		point_sum += point
	
	return point_sum / point_history.size()

func jacobi_eigen_decomposition(mat : Basis) -> Dictionary:
	# mat est symétrique
	var V := Basis.IDENTITY # vecteurs propres en colonnes
	var D := Vector3(mat.x.x, mat.y.y, mat.z.z) # valeurs propres approximatives
	
	for iteration in range(50): # plus d'itérations pour convergence
		# Trouver le plus grand élément hors-diagonal
		var max_val := 0.0
		var p := 0
		var q := 1
		
		for i in range(3):
			for j in range(i + 1, 3):
				var val : float = abs(mat[i][j])
				if val > max_val:
					max_val = val
					p = i
					q = j
		
		# Critère de convergence
		if max_val < 1e-9:
			break
		
		var app = mat[p][p]
		var aqq = mat[q][q]
		var apq = mat[p][q]
		
		# Calcul de l'angle de rotation
		var phi := 0.5 * atan2(2.0 * apq, aqq - app)
		var c := cos(phi)
		var s := sin(phi)
		
		# Rotation de Givens sur la matrice
		var mat_copy := mat
		for k in range(3):
			mat[k][p] = c * mat_copy[k][p] - s * mat_copy[k][q]
			mat[k][q] = s * mat_copy[k][p] + c * mat_copy[k][q]
		
		for k in range(3):
			mat[p][k] = c * mat_copy[p][k] - s * mat_copy[q][k]
			mat[q][k] = s * mat_copy[p][k] + c * mat_copy[q][k]
		
		# Accumuler les rotations dans V (vecteurs propres en colonnes)
		var v_copy := V
		for k in range(3):
			V[k][p] = c * v_copy[k][p] - s * v_copy[k][q]
			V[k][q] = s * v_copy[k][p] + c * v_copy[k][q]
		
		# Mettre à jour les valeurs propres
		D[p] = mat[p][p]
		D[q] = mat[q][q]
	
	D.x = mat.x.x
	D.y = mat.y.y
	D.z = mat.z.z
	
	return {"values": D, "vectors": V}

func get_drawing() -> Array[Vector2]:
	var barycentre := compute_barycentre()
	center = barycentre
	
	var centered_points : Array[Vector3]
	for point in point_history:
		centered_points.push_back(point - barycentre)
	
	var cov_mat := Basis()
	for q in centered_points:
		cov_mat.x.x += q.x * q.x
		cov_mat.x.y += q.x * q.y
		cov_mat.x.z += q.x * q.z
		
		cov_mat.y.x += q.y * q.x
		cov_mat.y.y += q.y * q.y
		cov_mat.y.z += q.y * q.z
		
		cov_mat.z.x += q.z * q.x
		cov_mat.z.y += q.z * q.y
		cov_mat.z.z += q.z * q.z
	
	cov_mat = cov_mat / float(centered_points.size())
	
	var eigen = jacobi_eigen_decomposition(cov_mat)
	var values : Vector3 = eigen["values"]
	var vectors : Basis = eigen["vectors"]
	
	var indices = [0, 1, 2]
	indices.sort_custom(func(a, b): return values[a] > values[b])
	
	var e1 := Vector3(vectors.x[indices[0]], vectors.y[indices[0]], vectors.z[indices[0]])
	var e2 := Vector3(vectors.x[indices[1]], vectors.y[indices[1]], vectors.z[indices[1]])
	
	x_dir = e1.normalized()
	y_dir = e2.normalized()
	
	var projected_points : Array[Vector2] = []
	planned_points.clear()
	
	for q in centered_points:
		var u := q.dot(x_dir)
		var v := q.dot(y_dir)
		
		projected_points.push_back(Vector2(u, v))
		
		var proj_3d : Vector3 = barycentre + x_dir * u + y_dir * v
		planned_points.push_back(proj_3d)
	
	return projected_points
