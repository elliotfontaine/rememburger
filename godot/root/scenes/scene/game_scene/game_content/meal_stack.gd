@tool
extends Node2D

const INGREDIENTS: Registry = preload("uid://cgvbeut67x3ce")

@export var meal_data: MealData = MealData.new():
	set(new):
		meal_data = new
		if not is_node_ready():
			return
		_clear_textures()
		_setup_textures_from_meal(new)


func _clear_textures() -> void:
	for child in get_children():
		child.texture = null


func _setup_textures_from_meal(meal: MealData) -> void:
	if not meal:
		return
	var child_iter := 0
	for ingr_name: StringName in meal.ingredients:
		var ingredient: IngredientData = INGREDIENTS.load_entry(ingr_name)
		var sprite: Sprite2D = get_child(child_iter)
		if sprite:
			sprite.texture = ingredient.texture
			child_iter += 1
		else:
			break
		
