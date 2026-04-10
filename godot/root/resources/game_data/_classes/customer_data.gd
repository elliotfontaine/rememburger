class_name CustomerData
extends Resource

enum State { IN_QUEUE, AT_COUNTER, SERVED, LEFT_ANGRY }

const START_TIP := 30.0

const NAMES = [
	"Max", "Kim", "Pat", "Lee", "Mel", "Sasha", "Robin", "Casey", "Riley",
	"John", "Emilie", "Fabian", "Laura", "Thomas", "Greg", "Marco", "Louise",
	"Harry", "Mindy", "Rosa", "Richie", "Alex", "Sam", "Charlie", "Lou", "Jo",
	"Quinn", "Avery", "Jamie", "Sage", "Blake", "Remy"
]
const SHIRT_COLORS = [
	Color(0.0, 0.333, 0.628, 1.0),
	Color(0.184, 0.176, 0.176, 1.0),
	Color(0.638, 1.0, 0.721, 1.0),
	Color(0.752, 0.203, 0.273, 1.0),
	Color(0.842, 0.786, 0.748, 1.0),
	Color(0.776, 0.724, 0.341, 1.0),
	Color(0.539, 0.117, 0.425, 1.0),
]
const SKIN_COLORS = [
	Color("f7e2eeff"),
	Color("FEE3D4"),
	Color("f1c27d"),
	Color("E5B5A1"),
	Color("c68642"),
	Color("8d5524"),
	# Color("3b2219"), too dark for face texture (which is pure black)
]
const HAIR_COLORS = [
	Color("4f1a00"),
	Color("241c11"),
	Color("9a3300"),
	Color("aa8866"),
	Color("DDD39E"),
	Color("C6812A"),
	Color("7639DC"),
	Color("1FB9CF"),
]
const FACE_TEXTURES = [
	preload("res://root/assets/image/game/characters/faces/face0000.png"),
	preload("res://root/assets/image/game/characters/faces/face0001.png"),
	preload("res://root/assets/image/game/characters/faces/face0002.png"),
	preload("res://root/assets/image/game/characters/faces/face0003.png"),
	preload("res://root/assets/image/game/characters/faces/face0004.png")
]
const HAIR_OUTLINES = [
	preload("res://root/assets/image/game/characters/hair/outline/image0000.png"),
	preload("res://root/assets/image/game/characters/hair/outline/image0001.png"),
	preload("res://root/assets/image/game/characters/hair/outline/image0002.png"),
	preload("res://root/assets/image/game/characters/hair/outline/image0003.png"),
	preload("res://root/assets/image/game/characters/hair/outline/image0004.png"),
	preload("res://root/assets/image/game/characters/hair/outline/image0005.png"),
]
const HAIR_COLORS_TEXTURES = [
	preload("res://root/assets/image/game/characters/hair/color/image0000.png"),
	preload("res://root/assets/image/game/characters/hair/color/image0001.png"),
	preload("res://root/assets/image/game/characters/hair/color/image0002.png"),
	preload("res://root/assets/image/game/characters/hair/color/image0003.png"),
	preload("res://root/assets/image/game/characters/hair/color/image0004.png"),
	preload("res://root/assets/image/game/characters/hair/color/image0005.png"),
]

var id: int
var name: String = "John Doe"
var state: State = State.IN_QUEUE
var has_ordered: bool = false
var points: float = START_TIP # decreasing
var order: MenuEntry

var shirt_color: Color
var skin_color: Color
var face: Texture2D
var hair_outline: Texture2D
var hair_color_texture: Texture2D
var hair_color: Color


func is_alive() -> bool:
	return points > 0.0 and state != State.LEFT_ANGRY


func _to_string() -> String:
	return "{name}({id})".format(self)
