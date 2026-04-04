extends Camera2D

const viewport_size := Vector2(1920, 1080) # Issues with `viewport_size := Vector2(get_viewport().size)` which is based on window size (?)

const COUNTER_VIEW_POSITION := Vector2(0, -400)
const WORKSTATION_VIEW_POSITION := Vector2(0, 300)
const COUNTER_VERTICAL_RATIO_TRIGGER := 0.10
const WORKSTATION_VERTICAL_RATIO_TRIGGER := 0.10
const TRANSITION_LERP_SPEED := 2.0

const CAMERA_DEAD_ZONE := 20
const MOUSE_OFFSET_STRENGTH := 0.1
const OFFSET_LERP_SPEED := 1.0

var mouse_offset := Vector2.ZERO
var base_target := COUNTER_VIEW_POSITION


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = event.global_position

		var vertical_ratio := mouse_pos.y / viewport_size.y
		if vertical_ratio < COUNTER_VERTICAL_RATIO_TRIGGER:
			base_target = COUNTER_VIEW_POSITION
		elif vertical_ratio > WORKSTATION_VERTICAL_RATIO_TRIGGER:
			base_target = WORKSTATION_VIEW_POSITION

		var _target: Vector2 = mouse_pos - viewport_size * 0.5
		if _target.length() < CAMERA_DEAD_ZONE:
			mouse_offset = Vector2.ZERO
		else:
			mouse_offset = _target.normalized() * (_target.length() - CAMERA_DEAD_ZONE) * MOUSE_OFFSET_STRENGTH


func _process(delta: float) -> void:
	position = position.lerp(base_target, TRANSITION_LERP_SPEED * delta)
	offset = offset.lerp(mouse_offset, OFFSET_LERP_SPEED * delta)
