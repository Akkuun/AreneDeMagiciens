extends Node3D

# Array of IngredientBody inside dict
var active_ingredients : Dictionary[Recipe.IngredientType, Array]
var colliding_rigid_bodies : Array[RigidBody3D]
@export var recipes : Array[Recipe]
@export var fire_speed : float = 50.0
var active : bool = false

func _ready() -> void:
	for key in Recipe.IngredientType.keys():
		var enum_value = Recipe.IngredientType.get(key)
		active_ingredients[enum_value] = []

var total_time : float = 0.0
func _physics_process(delta: float) -> void:
	total_time += delta * fire_speed
	$FireLight.omni_attenuation = sin(total_time) * 0.1 + 1.0
	
	for body in colliding_rigid_bodies:
		var depth =  $Surface.global_position.y - body.global_position.y
		if depth > 0:
			var buoyancy = min(depth, 0.5) * 50.0
			var v = body.linear_velocity.y
			var damping = -v * 5.0
			var pushing_force : Vector3 = Vector3.UP * (buoyancy + damping)
			DebugDraw3D.draw_arrow(body.global_position, body.global_position + pushing_force)
			body.apply_central_force(pushing_force)

func _on_ingredient_entry_body_entered(body: Node3D) -> void:
	if body is IngredientBody:
		for ingredient in body.contained_ingredients:
			active_ingredients[ingredient].append(body)
		
		update_output()
	
	if body is RigidBody3D:
		colliding_rigid_bodies.append(body)

func _on_ingredient_entry_body_exited(body: Node3D) -> void:
	if body is IngredientBody:
		for ingredient in body.contained_ingredients:
			var ing_index = active_ingredients[ingredient].find(body)
			active_ingredients[ingredient].erase(ing_index)
		
		update_output()
	
	if body is RigidBody3D:
		colliding_rigid_bodies.erase(body)

func get_possible_outputs() -> Array[Recipe]:
	var outputs : Array[Recipe] = []
	for recipe in recipes:
		var possible := true
		for ingredient_enum in recipe.ingredients.keys():
			if !active_ingredients.has(ingredient_enum) || recipe.ingredients[ingredient_enum] > active_ingredients[ingredient_enum].size():
				possible = false
		
		if possible:
			outputs.append(recipe)
	
	return outputs

func update_output():
	var possible_recipes = get_possible_outputs()
	var outputs : PackedStringArray
	for recipe in possible_recipes:
		outputs.append(recipe.recipe_name)
	
	
	if(!outputs.is_empty() and active):
		$CraftTimer.start()
	
	$ExpectedResult.text = ", ".join(outputs)


func craft():
	var possible_recipes = get_possible_outputs()
	if(possible_recipes.is_empty()):
		return
	var first_craft_recipe = possible_recipes[0]
	# Delete used ingredients
	var new_craft = first_craft_recipe.result.instantiate()
	add_child(new_craft)
	new_craft.global_position = $Surface.global_position
	
	
	for ingredient in first_craft_recipe.ingredients:
		for i in range(first_craft_recipe.ingredients[ingredient]):
			free_ingredient(ingredient)
	
	$ExpectedResult.text = "crafted " + first_craft_recipe.recipe_name

func free_ingredient(ingredient: Recipe.IngredientType):
	active_ingredients[ingredient].back().queue_free()
	active_ingredients[ingredient].remove_at(active_ingredients[ingredient].size() - 1)

func _on_craft_timer_timeout() -> void:
	craft()

func _on_status_receiver_status_entered(status: int, damage: int, position: Vector3) -> void:
	if status == Global.StatusEnum.FIRE:
		active = true
	if status == Global.StatusEnum.WATER:
		active = false
	
	$Bubbles.visible = active
	$FireLight.visible = active
