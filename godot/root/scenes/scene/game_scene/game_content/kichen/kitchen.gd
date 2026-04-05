class_name Kitchen
extends Node2D

const KITCHEN_MOVABLE_INGREDIENT := preload("uid://bf5nf4k4h46ll")
const KITCHEN_MOVABLE_PLATE := preload("uid://b0xikwrg7qjyy")
const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")

var grabbed_object: Node2D

@onready var movable_ingredients: Node2D = %MovableIngredients


func _physics_process(delta: float) -> void:
	if not grabbed_object:
		return
	grabbed_object.position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if _is_mouse_left_click(event) and grabbed_object:
		if try_release(event.position):
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Kitchen Item released")


func try_grab(object: Node2D) -> bool:
	if grabbed_object:
		return false
	else:
		grabbed_object = object
		return true


func try_release(where: Vector2) -> bool:
	if not grabbed_object:
		return false
	else:
		if grabbed_object is KitchenMovableIngredient:
			var object_area: Area2D = grabbed_object.grabbing_area_2d
			for other_area in object_area.get_overlapping_areas():
				if other_area.get_parent() is MovableMealPlate:
					var plate: MovableMealPlate = other_area.get_parent()
					var data: IngredientData = INGREDIENT_REGISTRY.load_entry(grabbed_object.ingredient)
					if data.processed: # only add processed food to plate
						plate.add_ingredient_to_plate(grabbed_object.ingredient)
						LogWrapper.debug(self, "Dropped ingredient on plate")
						grabbed_object.queue_free()
						break
					else:
						return false
		if grabbed_object is MovableMealPlate:
			var object_area: Area2D = grabbed_object.grabbing_area_2d
			for other_area in object_area.get_overlapping_areas():
				if other_area.name == &"ServingSpot":
					if grabbed_object.meal_data and not grabbed_object.meal_data.is_empty():
						SignalBus.meal_served.emit(grabbed_object.meal_data)
						LogWrapper.debug(self, "Dropped plate on serving spot")
						grabbed_object.queue_free()
					break
		grabbed_object = null
		return true


func spawn_ingredient(ingredient: StringName, where: Vector2, should_grab: bool = true) -> void:
	var item := KITCHEN_MOVABLE_INGREDIENT.instantiate()
	item.ingredient = ingredient
	item.kitchen = self
	item.position = where
	movable_ingredients.add_child(item)
	if should_grab:
		try_grab(item)


func spawn_meal_plate(where: Vector2, should_grab: bool = true) -> void:
	var plate := KITCHEN_MOVABLE_PLATE.instantiate()
	plate.meal_data = null
	plate.kitchen = self
	plate.position = where
	add_child(plate)
	if should_grab:
		try_grab(plate)


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_meal_plate_drawer_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and not grabbed_object:
		spawn_meal_plate(event.position)
