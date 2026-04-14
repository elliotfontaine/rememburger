extends Node2D


func setup_visuals(data: CustomerData) -> void:
	if not data:
		return
	$Head/Color.modulate = data.skin_color
	$Nose.texture = data.face
	$Hair/Color.texture = data.hair_color_texture
	$Hair/Color.modulate = data.hair_color
	$Hair/Outline.texture = data.hair_outline
