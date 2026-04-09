class_name Kitchen
extends Node2D

const KITCHEN_MOVABLE_INGREDIENT := preload("uid://bf5nf4k4h46ll")
const KITCHEN_MOVABLE_PLATE := preload("uid://b0xikwrg7qjyy")
const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")

var grabbed_object: Node2D
var grabbed_previous_z_index: int

@onready var movable_ingredients: Node2D = %MovableIngredients


func _physics_process(delta: float) -> void:
	if not grabbed_object:
		return
	
	grabbed_object.position = get_global_mouse_position()
	if grabbed_object is KitchenMovableIngredient:
		grabbed_object.rotate_velocity(delta)


func _unhandled_input(event: InputEvent) -> void:
	if _is_mouse_left_click(event) and grabbed_object:
		if try_release(event.position):
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Kitchen Object released")


func try_grab(object: Node2D) -> bool:
	if grabbed_object:
		return false
	else:
		grabbed_object = object
		grabbed_previous_z_index = object.z_index
		object.z_index = 100
		LogWrapper.debug(self, "Kitchen Object grabbed")
		return true


func try_release(where: Vector2) -> bool:
	if not grabbed_object:
		return false

	elif grabbed_object is KitchenMovableIngredient:
		var ingredient_data: IngredientData = grabbed_object.get_ingredient_data()
		var object_area: Area2D = grabbed_object.grabbing_area_2d
		for other_area in object_area.get_overlapping_areas():
			if other_area.get_parent() is MovableMealPlate:
				var plate: MovableMealPlate = other_area.get_parent()
				if plate.add_ingredient_to_plate(grabbed_object.ingredient):
					LogWrapper.debug(self, "Dropped ingredient %s on plate" % ingredient_data)
					grabbed_object.queue_free()
					break
				else:
					return false
			if other_area is ChoppingBoard:
				if not other_area.has_ingredient_placed() and ingredient_data.workstation == IngredientData.WorkStation.CHOPPING_BOARD:
					# Ref used in the tweener callback below, since `grabbed_object` will be set to null
					var ref_to_grabbed := grabbed_object
					create_tween().tween_property(grabbed_object, "rotation", 0, 0.2)
					var pos_tweener := create_tween().tween_property(grabbed_object, "position", other_area.position, 0.2)
					pos_tweener.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
					pos_tweener.finished.connect(func() -> void:
						other_area.placed_ingredient = ref_to_grabbed.ingredient
						LogWrapper.debug(self, "Dropped %s on chopping board" % ingredient_data)
						ref_to_grabbed.queue_free())
					break
				else:
					return false
			if other_area is Grill:
				if not other_area.has_ingredient_placed() and ingredient_data.workstation == IngredientData.WorkStation.GRILL:
					# Ref used in the tweener callback below, since `grabbed_object` will be set to null
					var ref_to_grabbed := grabbed_object
					create_tween().tween_property(grabbed_object, "rotation", 0, 0.2)
					var pos_tweener := create_tween().tween_property(grabbed_object, "position", other_area.position, 0.2)
					pos_tweener.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
					pos_tweener.finished.connect(func() -> void:
						other_area.placed_ingredient = ref_to_grabbed.ingredient
						other_area.step = 0
						other_area._start_timer()
						LogWrapper.debug(self, "Dropped %s on grill" % ingredient_data)
						ref_to_grabbed.queue_free())
					break
				else:
					return false

	elif grabbed_object is MovableMealPlate:
		var object_area: Area2D = grabbed_object.grabbing_area_2d
		for other_area in object_area.get_overlapping_areas():
			if other_area.name == &"ServingSpot" and other_area.is_visible_in_tree():
				if grabbed_object.meal_data and not grabbed_object.meal_data.is_empty():
					SignalBus.meal_served.emit(grabbed_object.meal_data)
					LogWrapper.debug(self, "Dropped plate on serving spot")
					var ref_to_grabbed := grabbed_object
					var pos_tweener := create_tween().tween_property(grabbed_object, "position", Vector2(0, -100), 0.6)
					pos_tweener.as_relative().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
					pos_tweener.finished.connect(func() -> void: ref_to_grabbed.queue_free())
					create_tween().tween_property(grabbed_object.plate_sprite_2d, "self_modulate", Color.TRANSPARENT, 0.3)
					create_tween().tween_property(grabbed_object.meal_stack, "self_modulate", Color.TRANSPARENT, 0.6)
				break

	elif grabbed_object is KitchenTool:
		if grabbed_object.name == &"Knife":
			for other_area: Area2D in grabbed_object.get_overlapping_areas():
				if other_area is ChoppingBoard:
					if other_area.has_ingredient_placed():
						var placed_ingr_data: IngredientData = INGREDIENT_REGISTRY.load_entry(other_area.placed_ingredient)
						var success := placed_ingr_data.work_result_success
						var success_n_drop := placed_ingr_data.n_produced_success
						for i in success_n_drop:
							var new_ingr := spawn_ingredient(success, other_area.position, false)
							var tweener := create_tween().tween_property(new_ingr, "position", _random_position_offset(60, 90), 0.3)
							tweener.as_relative().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
						other_area.placed_ingredient = &""
						LogWrapper.debug(self, "Cut %s on chopping board" % placed_ingr_data)
						break
					else:
						return false
		elif grabbed_object.sauce_ingredient != &"":
			for other_area: Area2D in grabbed_object.get_overlapping_areas():
				if other_area.get_parent() is MovableMealPlate:
					var plate: MovableMealPlate = other_area.get_parent()
					if plate.add_ingredient_to_plate(grabbed_object.sauce_ingredient):
						LogWrapper.debug(self, "Added sauce %s on plate" % grabbed_object.sauce_ingredient)
						break
					else:
						return false
					
		grabbed_object.reset_tool()
	
		
	grabbed_object.z_index = grabbed_previous_z_index
	grabbed_object = null
	return true


func spawn_ingredient(ingredient: StringName, where: Vector2, should_grab: bool = true) -> KitchenMovableIngredient:
	var item := KITCHEN_MOVABLE_INGREDIENT.instantiate()
	item.ingredient = ingredient
	item.kitchen = self
	item.position = where
	movable_ingredients.add_child(item)
	if should_grab:
		try_grab(item)
	return item


func spawn_meal_plate(where: Vector2, should_grab: bool = true) -> void:
	var plate := KITCHEN_MOVABLE_PLATE.instantiate()
	plate.meal_data = null
	plate.kitchen = self
	plate.position = where
	add_child(plate)
	if should_grab:
		try_grab(plate)


func _random_position_offset(min_distance: float, max_distance: float) -> Vector2:
	var angle := randf() * TAU
	var distance := randf_range(min_distance, max_distance)
	return Vector2(cos(angle), sin(angle)) * distance


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_meal_plate_drawer_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and not grabbed_object:
		spawn_meal_plate(event.position)
