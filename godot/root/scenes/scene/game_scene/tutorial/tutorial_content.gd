@tool
extends MarginContainer

const LOREM_IPSUM := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

@export var title: String = "Tutorial Content Title":
	set = set_title, get = get_title
@export_multiline() var text: String = LOREM_IPSUM:
	set = set_text, get = get_text
@export var image: CompressedTexture2D:
	set = set_image, get = get_image


func set_title(value: String) -> void:
	if %TitleLabel:
		%TitleLabel.text = value


func get_title() -> String:
	return %TitleLabel.text if %TitleLabel else ""


func set_text(value: String) -> void:
	if %RichTextLabel:
		%RichTextLabel.text = value


func get_text() -> String:
	return %RichTextLabel.text if %RichTextLabel else ""


func set_image(value: CompressedTexture2D) -> void:
	if %TextureRect:
		%TextureRect.texture = value


func get_image() -> CompressedTexture2D:
	return %TextureRect.texture if %TextureRect else null
