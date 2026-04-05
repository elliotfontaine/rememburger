class_name KitchenTool
extends Area2D

@export_node_path("Kitchen") var kitchen_path: NodePath
@export var storage_position: Vector2
@export_range(0, 360, 0.1, "radians_as_degrees") var storage_rotation: float
@export_range(0, 360, 0.1, "radians_as_degrees") var usage_rotation: float


var kitchen: Kitchen

func _ready() -> void:
	if storage_position:
		position = storage_position
	kitchen = get_node(kitchen_path)


func reset_tool() -> void:
	position = storage_position
	rotation = storage_rotation


func _is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _is_mouse_left_click(event) and kitchen:
		var grabbed := kitchen.try_grab(self)
		if grabbed:
			rotation = usage_rotation
			get_viewport().set_input_as_handled()
			LogWrapper.debug(self, "Kitchen tool grabbed")
