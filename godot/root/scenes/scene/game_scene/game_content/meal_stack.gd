@tool
extends CanvasGroup

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
		if child is Sprite2D:
			child.texture = null


func _setup_textures_from_meal(meal: MealData) -> void:
	if not meal:
		return
	var child_iter := 0
	var vertical_offset := 0.0
	var previous_ingr_name: StringName = &""
	for ingr_name: StringName in meal.ingredients:
		var ingredient: IngredientData = INGREDIENTS.load_entry(ingr_name)
		var sprite: Sprite2D
		if child_iter in range(get_child_count()):
			sprite = get_child(child_iter)
		else:
			sprite = Sprite2D.new()
			add_child(sprite)
		sprite.texture = ingredient.texture
		sprite.position = Vector2(0.0, vertical_offset)
		sprite.rotation_degrees = (
			randf_range(10.0, -10.0)
			if _should_rotate(ingr_name, previous_ingr_name)
			else 0.0
		)
		child_iter += 1
		vertical_offset -= ingredient.thickness
		previous_ingr_name = ingr_name


func _should_rotate(ingr_name: StringName, previous_ingr_name: StringName) -> bool:
	if previous_ingr_name == &"" or ingr_name == &"":
		return false
	elif ingr_name == previous_ingr_name:
		return true
	else:
		var sauces := INGREDIENTS.filter(&"type", IngredientData.IngredientType.SAUCE)
		if ingr_name in sauces and previous_ingr_name in sauces:
			return true
	
	return false
