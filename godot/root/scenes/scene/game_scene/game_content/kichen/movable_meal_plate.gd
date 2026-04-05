class_name MovableMealPlate
extends Node2D

@export var meal_data: MealData:
	set(value):
		if is_node_ready():
			meal_stack.meal_data = meal_data
	get():
		return meal_stack.meal_data

var kitchen: Kitchen

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var grabbing_area_2d: Area2D = %GrabbingArea2D
@onready var meal_stack: Node2D = %MealStack


func _ready() -> void:
	meal_data = meal_data
	if not kitchen:
		LogWrapper.warn(self, "kitchen reference not set.")


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_grabbing_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen:
		var grabbed := kitchen.try_grab(self)
		if grabbed:
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Meal plate item grabbed")
