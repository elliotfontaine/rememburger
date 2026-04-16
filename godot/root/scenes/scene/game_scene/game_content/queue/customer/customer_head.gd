extends Node2D

const EYEBROWS_REGISTRY = preload("uid://1ohd70sqvhkq")
const EYES_REGISTRY = preload("uid://ws8rnmdop37h")
const MOUTH_REGISTRY = preload("uid://bex11e6h012jd")
const NOSE_REGISTRY = preload("uid://bic7bqjfx2rjs")

func setup_visuals(data: CustomerData) -> void:
	if not data:
		return
	$Head/Color.modulate = data.skin_color
	%Eyebrows.texture = EYEBROWS_REGISTRY.load_entry(data.face_eyebrows)
	%Eyes.texture = EYES_REGISTRY.load_entry(data.face_eyes)
	%Nose.texture = NOSE_REGISTRY.load_entry(data.face_nose)
	%Mouth.texture = MOUTH_REGISTRY.load_entry(data.face_mouth)
	%HairColor.texture = data.hair_color_texture
	%HairColor.modulate = data.hair_color
	%HairOutline.texture = data.hair_outline
