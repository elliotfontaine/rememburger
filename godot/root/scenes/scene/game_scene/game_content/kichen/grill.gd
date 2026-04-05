class_name Grill
extends Area2D

const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")


@export_node_path("Kitchen") var kitchen_path: NodePath


var placed_ingredient: StringName:
	set(value):
		placed_ingredient = value
		if INGREDIENT_REGISTRY.has_string_id(placed_ingredient):
			$Sprite2D.texture = INGREDIENT_REGISTRY.load_entry(placed_ingredient).texture
		else:
			$Sprite2D.texture = null

var step: int = 0

var kitchen: Kitchen


func _ready() -> void:
	kitchen = get_node(kitchen_path)

func _start_timer() -> void:
	if step == 0:
		print("cooking raw steak")
		$Timer.wait_time = 10
		$Timer.start()
	if step == 1:
		print("(over) cooking cooked steak")
		$Timer.wait_time = 20
		$Timer.start()

func has_ingredient_placed() -> bool:
	return placed_ingredient != &""

func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_current_item_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen and has_ingredient_placed():
		var new_ingredient_object := kitchen.spawn_ingredient(placed_ingredient, event.position, false)
		if kitchen.try_grab(new_ingredient_object):
			$Timer.stop()
			placed_ingredient = &""
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Movable ingredient grabbed from chopping board")
		else:
			new_ingredient_object.queue_free()


func _on_timer_timeout() -> void:
	if step == 1:
		step = 2
		placed_ingredient = &"steak_burnt"
		return

	if step == 0:
		step = 1
		placed_ingredient = &"steak_cooked"
		_start_timer()
