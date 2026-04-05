class_name KitchenMovableIngredient
extends Node2D

const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")

@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce") var ingredient: StringName:
	set(value):
		ingredient = value
		if is_node_ready() and INGREDIENT_REGISTRY.has_string_id(ingredient):
			sprite_2d.texture = INGREDIENT_REGISTRY.load_entry(ingredient).texture

@export_group("Oscillator")
@export var spring: float = 200.0
@export var damp: float = 8.0
@export var velocity_multiplier: float = 1.0

var kitchen: Kitchen

var _displacement: float = 0.0
var _oscillator_velocity: float = 0.0
var _last_pos: Vector2
var _velocity: Vector2


@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var grabbing_area_2d: Area2D = %GrabbingArea2D


func _ready() -> void:
	ingredient = ingredient # update sprite
	if not kitchen:
		LogWrapper.warn(self, "kitchen reference not set.")


func _physics_process(delta: float) -> void:
	if not visible or position == _last_pos:
		return
	rotate_velocity(delta)


func get_ingredient_data() -> IngredientData:
	return INGREDIENT_REGISTRY.load_entry(ingredient)


func rotate_velocity(delta: float) -> void:
	_velocity = (position - _last_pos) / delta
	_last_pos = position
	_oscillator_velocity += _velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force := -spring * _displacement - damp * _oscillator_velocity
	_oscillator_velocity += force * delta
	_displacement += _oscillator_velocity * delta
	
	rotation = - _displacement


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_grabbing_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen:
		var grabbed := kitchen.try_grab(self)
		if grabbed:
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Free movable ingredient grabbed")
		

			
