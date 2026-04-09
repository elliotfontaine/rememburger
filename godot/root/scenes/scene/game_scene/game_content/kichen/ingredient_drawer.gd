@tool
extends Node2D

const INGREDIENT_REGISTRY := preload("uid://cgvbeut67x3ce")

@export_node_path("Kitchen") var kitchen_path: NodePath
@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce") var ingredient: StringName
@export var shape_size: Vector2 = Vector2(100.0, 100.0):
	set(value):
		shape_size = value
		if collision_shape_2d and collision_shape_2d.shape:
			collision_shape_2d.shape.size = value

@onready var area_2d: Area2D = %Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	shape_size = shape_size


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _spawn_ingredient() -> void:
	if not INGREDIENT_REGISTRY.has_string_id(ingredient):
		return
	
	var kitchen: Kitchen = get_node(kitchen_path)
	if kitchen:
		kitchen.spawn_ingredient(ingredient, position)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_mouse_left_click(event):
		get_viewport().set_input_as_handled()
		LogWrapper.debug(self, "Ingredient drawer clicked.")
		_spawn_ingredient()
