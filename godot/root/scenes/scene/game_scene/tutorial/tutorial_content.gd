@tool
extends MarginContainer

const LOREM_IPSUM := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

@export var title: String = "Tutorial Content Title":
	set = set_title, get = get_title
@export_multiline() var text: String = LOREM_IPSUM:
	set = set_text, get = get_text
@export_custom(PROPERTY_HINT_RESOURCE_TYPE,"CompressedTexture2D,VideoStreamTheora") var media: Resource:
	set = set_media, get = get_media

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


func set_media(value: Resource) -> void:
	if value is CompressedTexture2D and %TextureRect:
		%TextureRect.texture = value
		%TextureRect.show()
		%VideoStreamPlayer.stream = null
		%AspectRatioContainer.hide()
	elif value is VideoStreamTheora and %VideoStreamPlayer:
		%VideoStreamPlayer.stream = value
		%AspectRatioContainer.show()
		%TextureRect.texture = null
		%TextureRect.hide()
	elif not value:
		%TextureRect.texture = null
		%TextureRect.hide()
		%VideoStreamPlayer.stream = null
		%AspectRatioContainer.hide()


func get_media() -> Resource:
	if %TextureRect and %TextureRect.texture:
		return %TextureRect.texture
	elif %VideoStreamPlayer and %VideoStreamPlayer.stream:
		return %VideoStreamPlayer.stream
	else:
		return null


func _on_visibility_changed() -> void:
	if not is_inside_tree():
		return
	if visible:
		%VideoStreamPlayer.play()
	else:
		%VideoStreamPlayer.stop()
		
