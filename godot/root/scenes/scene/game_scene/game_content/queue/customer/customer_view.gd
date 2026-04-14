class_name CustomerView
extends Node2D

const MAX_WALK_DURATION := 3.0
const BONUS_COLOR := Color("5af873ff")
const MALUS_COLOR := Color("ff9384ff")

var data: CustomerData
var move_tween: Tween
var bonus_malus_tween: Tween
var target_position: Vector2

var _label_start_pos: Vector2

@onready var character_animation_player: AnimationPlayer = %CharacterAnimationPlayer
@onready var satisfaction_bar: ProgressBar = %SatisfactionBar
@onready var satisfaction_label: Label = %SatisfactionLabel
@onready var bonus_malus_label: Label = %BonusMalusLabel


func _ready() -> void:
	SignalBus.customer_bonus_malus_applied.connect(_on_customer_bonus_malus_applied)
	_label_start_pos = bonus_malus_label.position


func _process(_delta: float) -> void:
	satisfaction_bar.value = satisfaction_bar.max_value * (data.points / QueueManager.START_TIP)
	satisfaction_label.text = "%d €" % ceili(data.points)
	
	if data.points >= 0.5 * QueueManager.START_TIP:
		satisfaction_bar.self_modulate = Color("5af873ff")
	elif data.points >= 0.25 * QueueManager.START_TIP:
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
	move_tween.tween_callback(character_animation_player.play.bind(
		&"walking",
		-1,
		max(
			1.0,
			(walk_duration / MAX_WALK_DURATION) * (distance / QueueView.SPREAD.length())
		),
	))
	move_tween.finished.connect(_on_move_tween_finished)


func _on_move_tween_finished() -> void:
	if not character_animation_player.current_animation == &"breathing":
		character_animation_player.play(&"breathing", -1, randf_range(0.8, 1.2))


func _on_customer_bonus_malus_applied(customer: CustomerData, bonus_malus: float) -> void:
	if not customer == data:
		return
	
	if bonus_malus_tween:
		bonus_malus_tween.kill()
	
	var is_bonus := bonus_malus >= 0.0
	bonus_malus_label.text = "%s %d €" % ["+" if is_bonus else "-", absf(roundf(bonus_malus))]
	bonus_malus_label.add_theme_color_override(&"font_color", BONUS_COLOR if is_bonus else MALUS_COLOR)
	bonus_malus_label.position = _label_start_pos
	bonus_malus_label.self_modulate = Color.WHITE
	bonus_malus_label.show()

	bonus_malus_tween = create_tween().set_parallel()
	bonus_malus_tween.tween_property(bonus_malus_label, "position", Vector2.UP * 30, 1.5).as_relative()
	bonus_malus_tween.tween_property(bonus_malus_label, "self_modulate", Color.TRANSPARENT, 0.7).set_delay(0.8)
