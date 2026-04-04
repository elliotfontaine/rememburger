class_name KitchenMovableItem
extends Node2D

@export_category("Oscillator")
@export var spring: float = 200.0
@export var damp: float = 8.0
@export var velocity_multiplier: float = 1.0

var ingredient: IngredientData = preload("uid://d4lx5e0um04f6")
var is_grabbed: bool = false

var _displacement: float = 0.0
var _oscillator_velocity: float = 0.0
var _last_pos: Vector2
var _velocity: Vector2
var _position_offset: Vector2 = Vector2.ZERO


@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var grabbing_area_2d: Area2D = %GrabbingArea2D


func _ready() -> void:
	if ingredient:
		sprite_2d.texture = ingredient.texture


func _unhandled_input(event: InputEvent) -> void:
	if _is_mouse_left_click(event) and is_grabbed:
		is_grabbed = false
		get_viewport().set_input_as_handled()
		LogWrapper.debug(self, "Kitchen movable item released")


func _physics_process(delta: float) -> void:
	if not visible or not is_grabbed:
		return
	position = get_global_mouse_position() + _position_offset
	rotate_velocity(delta)


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
	if _is_mouse_left_click(event) and not is_grabbed:
		is_grabbed = true
		get_viewport().set_input_as_handled()
		LogWrapper.debug(self, "Kitchen movable item grabbed")
		

			
