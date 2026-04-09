class_name CustomerData
extends Resource

enum State { IN_QUEUE, AT_COUNTER, SERVED, LEFT_ANGRY }

const NAMES = [
	"Max", "Kim", "Pat", "Lee", "Mel", "Sasha", "Robin", "Casey", "Riley",
	"John", "Emilie", "Fabian", "Laura", "Thomas", "Greg", "Marco", "Louise",
	"Harry", "Mindy", "Rosa", "Richie", "Alex", "Sam", "Charlie", "Lou", "Jo",
	"Quinn", "Avery", "Jamie", "Sage", "Blake", "Remy"
]

const SHIRT_COLORS = [Color.BLUE, Color.BLACK, Color.GREEN, Color.RED]
const SKIN_COLORS = [Color.BEIGE, Color.LIGHT_PINK, Color.SANDY_BROWN, Color.SADDLE_BROWN]
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
const HAIR_COLORS = [Color.BROWN, Color.AQUAMARINE, Color.CHOCOLATE, Color.DARK_ORANGE, Color.LIGHT_YELLOW]

var id: int
var name: String = "John Doe"
var state: State = State.IN_QUEUE
var has_ordered: bool = false
var points: float = 100.0 # decreasing
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
