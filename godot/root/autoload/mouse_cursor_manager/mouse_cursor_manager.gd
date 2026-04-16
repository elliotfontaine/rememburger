extends Node

# Load the custom images for the mouse cursor.
var arrow := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/pointer_a.svg")
var pointing_hand := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/hand_small_point.svg")
var ibeam := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/bracket_b_vertical.svg")
var vsize := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/resize_a_vertical.svg")
var hsize := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/resize_a_horizontal.svg")
var bdiagsize := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/resize_a_diagonal.svg")
var fdiagsize := load("res://root/assets/image/ui/kenney-game-icons/kenney-cursor-pack/resize_a_diagonal_mirror.svg")


func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(pointing_hand, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(ibeam, Input.CURSOR_IBEAM)
	Input.set_custom_mouse_cursor(vsize, Input.CURSOR_VSIZE)
	Input.set_custom_mouse_cursor(hsize, Input.CURSOR_HSIZE)
	Input.set_custom_mouse_cursor(bdiagsize, Input.CURSOR_BDIAGSIZE)
	Input.set_custom_mouse_cursor(fdiagsize, Input.CURSOR_FDIAGSIZE)
	
