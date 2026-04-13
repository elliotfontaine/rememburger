class_name CustomerView
extends Node2D

const MAX_WALK_DURATION := 3.0

var data: CustomerData
var move_tween: Tween
var target_position: Vector2

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var satisfaction_bar: ProgressBar = %SatisfactionBar
@onready var satisfaction_label: Label = %SatisfactionLabel


func _process(_delta: float) -> void:
	satisfaction_bar.value = satisfaction_bar.max_value * (data.points / CustomerData.START_TIP)
	satisfaction_label.text = "%d €" % ceili(data.points)
	
	if data.points >= 0.5 * CustomerData.START_TIP:
		satisfaction_bar.self_modulate = Color("5af873ff")
	elif data.points >= 0.25 * CustomerData.START_TIP:
		satisfaction_bar.self_modulate = Color("f8cd79ff")
	else:
		satisfaction_bar.self_modulate = Color("ff5c4dff")


func apply_visuals() -> void:
	$Body/Color.modulate = data.shirt_color
	$CustomerHead/Head/Color.modulate = data.skin_color
	$CustomerHead/Nose.texture = data.face
	$CustomerHead/Hair/Color.texture = data.hair_color_texture
	$CustomerHead/Hair/Color.modulate = data.hair_color
	$CustomerHead/Hair/Outline.texture = data.hair_outline


func move(to: Vector2, delay: float = 0.0) -> void:
	if to in [position, target_position]:
		return
		
	target_position = to
	var distance := target_position.distance_to(position)
	var walk_duration := randf_range(MAX_WALK_DURATION * 0.7, MAX_WALK_DURATION)
	
	if move_tween: move_tween.kill()
	move_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	move_tween.tween_property(self, "position", target_position, walk_duration).set_delay(delay)
	move_tween.tween_callback(animation_player.play.bind(
		&"walking",
		-1,
		max(
			1.0,
			(walk_duration / MAX_WALK_DURATION) * (distance / QueueView.SPREAD.length())
		),
	))
	move_tween.finished.connect(_on_move_tween_finished)


func _on_move_tween_finished() -> void:
	if not animation_player.current_animation == &"breathing":
		animation_player.play(&"breathing", -1, randf_range(0.8, 1.2))
