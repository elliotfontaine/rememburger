class_name MovableMealPlate
extends Node2D

const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")

@export var meal_data: MealData:
	set(value):
		meal_data = value
		if is_node_ready():
			_update_stack_view()

var kitchen: Kitchen

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var grabbing_area_2d: Area2D = %GrabbingArea2D
@onready var meal_stack: Node2D = %MealStack


func _ready() -> void:
	meal_data = meal_data
	if not kitchen:
		LogWrapper.warn(self, "kitchen reference not set.")


func add_ingredient_to_plate(ingredient: StringName) -> bool:
	# TODO: aide en empechant de placer autre chose que bottom bread au debut
	#if ingredient.type == ingredient.IngredientType.BREAD_BOTTOM:
	if not meal_data:
		meal_data = MealData.new()
	
	var processed_food := INGREDIENT_REGISTRY.filter(&"processed", true)
	if not ingredient in processed_food:
		return false
	
	var bottom_breads := INGREDIENT_REGISTRY.filter(&"type", IngredientData.IngredientType.BREAD_BOTTOM)
	if meal_data.is_empty() and not ingredient in bottom_breads:
		return false
	
	var top_breads := INGREDIENT_REGISTRY.filter(&"type", IngredientData.IngredientType.BREAD_TOP)
	if not meal_data.is_empty() and meal_data.ingredients[-1] in top_breads:
		return false

	meal_data.ingredients.append(ingredient)
	_update_stack_view()
	return true


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_grabbing_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen:
		var grabbed := kitchen.try_grab(self)
		if grabbed:
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Meal plate item grabbed")


func _update_stack_view() -> void:
	meal_stack.meal_data = meal_data
