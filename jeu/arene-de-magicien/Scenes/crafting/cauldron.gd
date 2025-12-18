extends Node3D

var active_ingredients : Dictionary[Recipe.IngredientType, int]
@export var recipes : Array[Recipe]

func _ready() -> void:
	for key in Recipe.IngredientType.keys():
		var enum_value = Recipe.IngredientType.get(key)
		active_ingredients[enum_value] = 0

func _on_ingredient_entry_body_entered(body: Node3D) -> void:
	if(body is IngredientBody):
		for ingredient in body.contained_ingredients:
			active_ingredients[ingredient] += 1
		
		update_output()

func _on_ingredient_entry_body_exited(body: Node3D) -> void:
	if(body is IngredientBody):
		for ingredient in body.contained_ingredients:
			active_ingredients[ingredient] -= 1
		
		update_output()

func update_output():
	var outputs : PackedStringArray
	for recipe in recipes:
		var possible := true
		for ingredient_enum in recipe.ingredients.keys():
			if recipe.ingredients[ingredient_enum] > active_ingredients[ingredient_enum]:
				possible = false
		
		if possible:
			outputs.append(recipe.recipe_name)
	
	$ExpectedResult.text = ", ".join(outputs)
