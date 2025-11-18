class_name Recipe extends Resource


enum IngredientType {
	WOOD,
	LAVA
}


@export var ingredients: Array[IngredientType]

@export var result: PackedScene
