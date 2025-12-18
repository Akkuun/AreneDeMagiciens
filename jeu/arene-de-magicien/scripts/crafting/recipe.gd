class_name Recipe extends Resource


enum IngredientType {
	WOOD,
	LAVA
}


@export var ingredients: Dictionary[IngredientType, int]

@export var result: PackedScene
@export var recipe_name : String
