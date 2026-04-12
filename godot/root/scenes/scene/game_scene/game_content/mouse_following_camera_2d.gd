extends Camera2D

const VIEWPORT_SIZE := Vector2(1920, 1080)
# Issues with `viewport_size := Vector2(get_viewport().size)` which is based on window size (?)

const COUNTER_VIEW_POSITION := Vector2(0, -400)
const WORKSTATION_VIEW_POSITION := Vector2(0, 300)
const COUNTER_VERTICAL_RATIO_TRIGGER := 0.10
const WORKSTATION_VERTICAL_RATIO_TRIGGER := 0.90
const TRANSITION_LERP_SPEED := 2.0

const CAMERA_DEAD_ZONE := 20
const offset_target_STRENGTH := 0.1
const OFFSET_LERP_SPEED := 1.0

var base_target := COUNTER_VIEW_POSITION
var offset_target := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = event.global_position

		var vertical_ratio := mouse_pos.y / VIEWPORT_SIZE.y
		if vertical_ratio < COUNTER_VERTICAL_RATIO_TRIGGER:
			base_target = COUNTER_VIEW_POSITION
			SignalBus.camera_target_changed.emit(Vector2.UP)
		elif vertical_ratio > WORKSTATION_VERTICAL_RATIO_TRIGGER:
			base_target = WORKSTATION_VIEW_POSITION
			SignalBus.camera_target_changed.emit(Vector2.DOWN)

		var mouse_offset: Vector2 = mouse_pos - VIEWPORT_SIZE * 0.5
		if mouse_offset.length() < CAMERA_DEAD_ZONE:
			offset_target = Vector2.ZERO
		else:
			mouse_offset = mouse_offset.normalized() * (mouse_offset.length() - CAMERA_DEAD_ZONE)
			offset_target = mouse_offset * offset_target_STRENGTH


func _process(delta: float) -> void:
	position = position.lerp(base_target, TRANSITION_LERP_SPEED * delta)
	offset = offset.lerp(offset_target, OFFSET_LERP_SPEED * delta)
