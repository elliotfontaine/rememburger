class_name Grill
extends Area2D

const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")
const WAIT_TIME_COOKED := 7
const WAIT_TIME_BURNED := 20

@export_node_path("Kitchen") var kitchen_path: NodePath

var kitchen: Kitchen
var placed_ingredient: StringName:
	set(value):
		_set_placed_ingredient(value)
		placed_ingredient = value

var _step: int = 0
var _volume_tween: Tween

@onready var timer: Timer = %Timer


func _ready() -> void:
	kitchen = get_node(kitchen_path)


func has_ingredient_placed() -> bool:
	return placed_ingredient != &""


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _advance_step() -> void:
	var ingredient_data: IngredientData = INGREDIENT_REGISTRY.load_entry(placed_ingredient)
	match _step:
		0:
			LogWrapper.debug(self, "Cooking raw ingredient")
			timer.wait_time = WAIT_TIME_COOKED
			timer.start()
		1:
			
			placed_ingredient = ingredient_data.work_result_success
			LogWrapper.debug(self, "Overcooking cooked ingredient (!)")
			timer.wait_time = WAIT_TIME_BURNED
			timer.start()
		2:
			placed_ingredient = ingredient_data.work_result_fail
			LogWrapper.debug(self, "Ingredient burned...")


func _set_placed_ingredient(value: StringName) -> void:
	if INGREDIENT_REGISTRY.has_string_id(value):
		%Sprite2D.texture = INGREDIENT_REGISTRY.load_entry(value).texture
		if not placed_ingredient:
			_step = 0
			_advance_step()
			if _volume_tween:
				_volume_tween.kill()
			%AudioStreamPlayer2D.volume_db = 0.0
			%AudioStreamPlayer2D.play()
	else:
		%Sprite2D.texture = null
		_volume_tween = create_tween()
		_volume_tween.tween_property(%AudioStreamPlayer2D, "volume_db", -80.0, 0.5)
		_volume_tween.tween_callback(%AudioStreamPlayer2D.stop)


func _on_current_item_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen and has_ingredient_placed():
		var new_ingredient_object := kitchen.spawn_ingredient(placed_ingredient, event.position, false)
		if kitchen.try_grab(new_ingredient_object):
			timer.stop()
			placed_ingredient = &""
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Movable ingredient grabbed from grill")
		else:
			new_ingredient_object.queue_free()


func _on_timer_timeout() -> void:
	_step += 1
	_advance_step()
