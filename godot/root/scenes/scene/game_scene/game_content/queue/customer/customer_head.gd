extends Node2D

const EYEBROWS_REGISTRY = preload("uid://1ohd70sqvhkq")
const EYES_REGISTRY = preload("uid://ws8rnmdop37h")
const MOUTH_REGISTRY = preload("uid://bex11e6h012jd")
const NOSE_REGISTRY = preload("uid://bic7bqjfx2rjs")
const HAIR_DATA_REGISTRY = preload("uid://gtqjb3b5c3eo")

func setup_visuals(data: CustomerData) -> void:
	if not data:
		return
	
	var hair_data: HairData = HAIR_DATA_REGISTRY.load_entry(data.hair_data)
	var hair_colors: PackedColorArray =  (
		hair_data.color_palette.colors
		if hair_data.color_palette
		else PackedColorArray()
	)
	
	%Eyebrows.texture = EYEBROWS_REGISTRY.load_entry(data.face_eyebrows)
	%Eyes.texture = EYES_REGISTRY.load_entry(data.face_eyes)
	%Nose.texture = NOSE_REGISTRY.load_entry(data.face_nose)
	%Mouth.texture = MOUTH_REGISTRY.load_entry(data.face_mouth)
	
	$Head/Color.modulate = data.skin_color
	%HairOutline.texture = hair_data.outline_texture
	%HairColor.texture = hair_data.color_texture
	if not hair_colors.is_empty():
		%HairColor.modulate = hair_colors[randi() % hair_colors.size()]
