class_name CustomerView
extends Node2D

var data: CustomerData

func apply_visuals() -> void:
	$Body/Color.modulate = data.shirt_color
	$CustomerHead/Head/Color.modulate = data.skin_color
	$CustomerHead/Nose.texture = data.face
	$CustomerHead/Hair/Color.texture = data.hair_color_texture
	$CustomerHead/Hair/Color.modulate = data.hair_color
	$CustomerHead/Hair/Outline.texture = data.hair_outline

func _process(_delta: float) -> void:
	$SatisfactionBar.scale.x = data.points / 100.0

	if data.points >= 50:
		$SatisfactionBar.modulate = Color.GREEN
	elif data.points >= 20:
		$SatisfactionBar.modulate = Color.ORANGE
	else:
		$SatisfactionBar.modulate = Color.RED
