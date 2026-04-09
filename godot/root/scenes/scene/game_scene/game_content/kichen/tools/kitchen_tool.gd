class_name KitchenTool
extends Area2D

const RESET_TWEEN_DURATION := 0.3

@export_node_path("Kitchen") var kitchen_path: NodePath
@export_range(-360, 360, 0.1, "radians_as_degrees") var storage_rotation: float
@export_range(-360, 360, 0.1, "radians_as_degrees") var usage_rotation: float
@export_group("Sauce")
@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce") var sauce_ingredient: StringName

var kitchen: Kitchen
var storage_position: Vector2

@onready var grabber_area_2d: Area2D = %GrabberArea2D


func _ready() -> void:
	storage_position = position
	kitchen = get_node(kitchen_path)
	grabber_area_2d.input_event.connect(_on_grabber_area_2d_input_event)


func reset_tool() -> void:
	create_tween().tween_property(self, "position", storage_position, RESET_TWEEN_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(self, "rotation", storage_rotation, RESET_TWEEN_DURATION)


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_grabber_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen:
		var grabbed := kitchen.try_grab(self)
		if grabbed:
			create_tween().tween_property(self, "rotation", usage_rotation, RESET_TWEEN_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Kitchen tool grabbed")
