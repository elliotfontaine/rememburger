class_name CustomerView
extends Node2D

var data: CustomerData

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var satisfaction_bar: ProgressBar = %SatisfactionBar
@onready var satisfaction_label: Label = %SatisfactionLabel


func apply_visuals() -> void:
	$Body/Color.modulate = data.shirt_color
	$CustomerHead/Head/Color.modulate = data.skin_color
	$CustomerHead/Nose.texture = data.face
	$CustomerHead/Hair/Color.texture = data.hair_color_texture
	$CustomerHead/Hair/Color.modulate = data.hair_color
	$CustomerHead/Hair/Outline.texture = data.hair_outline


func _process(_delta: float) -> void:
	satisfaction_bar.value = data.points
	satisfaction_label.text = str(int(data.points))
	
	if data.points >= 50:
		satisfaction_bar.self_modulate = Color.GREEN
	elif data.points >= 20:
		satisfaction_bar.self_modulate = Color.ORANGE
	else:
		satisfaction_bar.self_modulate = Color.RED
