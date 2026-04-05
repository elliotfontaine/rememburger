class_name MovableMealPlate
extends Node2D

@export var meal_data: MealData:
	set(value):
		meal_data = value
		if is_node_ready():
			meal_stack.meal_data = value

var kitchen: Kitchen

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var grabbing_area_2d: Area2D = %GrabbingArea2D
@onready var meal_stack: Node2D = %MealStack


func _ready() -> void:
	meal_data = meal_data
	if not kitchen:
		LogWrapper.warn(self, "kitchen reference not set.")


func add_ingredient_to_plate(ingredient: StringName) -> void:
	# TODO: aide en empechant de placer autre chose que bottom bread au debut
	#if ingredient.type == ingredient.IngredientType.BREAD_BOTTOM:
	if not meal_data:
		meal_data = MealData.new()
	meal_data.ingredients.append(ingredient)
	meal_data = meal_data

func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_grabbing_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen:
		var grabbed := kitchen.try_grab(self)
		if grabbed:
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Meal plate item grabbed")
