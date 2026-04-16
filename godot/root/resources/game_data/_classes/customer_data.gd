class_name CustomerData
extends Resource

enum State { IN_QUEUE, AT_COUNTER, SERVED, LEFT_ANGRY }

const MENU_ENTRY_REGISTRY: Registry = preload("uid://b7eqya2l1ru20")
const EYEBROWS_REGISTRY = preload("uid://1ohd70sqvhkq")
const EYES_REGISTRY = preload("uid://ws8rnmdop37h")
const MOUTH_REGISTRY = preload("uid://bex11e6h012jd")
const NOSE_REGISTRY = preload("uid://bic7bqjfx2rjs")


const NAMES = [
	"Max", "Kim", "Pat", "Lee", "Mel", "Sasha", "Robin", "Casey", "Riley",
	"John", "Emilie", "Fabian", "Laura", "Thomas", "Greg", "Marco", "Louise",
	"Harry", "Mindy", "Rosa", "Richie", "Alex", "Sam", "Charlie", "Lou", "Jo",
	"Quinn", "Avery", "Jamie", "Sage", "Blake", "Remy"
]
const SHIRT_COLORS = [
	
	Color("343b48ff"),
	Color("a3ffb8ff"),
	Color("d7c8bfff"),
	Color("891e6cff"),
	Color("#6dce5e"),
	Color("c92a4e"),
	Color("005ca5"),
	Color("f8d778"),
	Color("c4d2a4"),
	Color("c6a5d8"),
	Color("4c3e4d"),
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
const CAP_COLORS = [
	Color("00ac43ff"),
	Color("07578fff"),
	Color("c53929ff"),
	Color("6a74ffff"),
	Color("dadbcdff"),
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
var points: float
var order: MenuEntry

var shirt_color: Color
var skin_color: Color
var face_mouth: StringName
var face_nose: StringName
var face_eyes: StringName
var face_eyebrows: StringName
var hair_outline: Texture2D
var hair_color_texture: Texture2D
var hair_color: Color


func _init(p_id: int, p_optional_name: String = "") -> void:
	id = p_id
	name = p_optional_name if p_optional_name else NAMES.pick_random()
	_generate_random_look()


func _to_string() -> String:
	return "{name}({id})".format(self)


func is_alive() -> bool:
	return points > 0.0 and state != State.LEFT_ANGRY


func generate_order(difficulty: MenuEntry.Difficulty = MenuEntry.Difficulty.NORMAL) -> void:
	var entry_name: StringName = MENU_ENTRY_REGISTRY.filter(&"difficulty", difficulty).pick_random()
	order = MENU_ENTRY_REGISTRY.load_entry(entry_name)


func _generate_random_look() -> void:
	shirt_color = SHIRT_COLORS.pick_random()
	
	skin_color = SKIN_COLORS.pick_random()
	face_mouth = MOUTH_REGISTRY.get_all_string_ids().pick_random()
	face_nose = NOSE_REGISTRY.get_all_string_ids().pick_random()
	face_eyes = EYES_REGISTRY.get_all_string_ids().pick_random()
	face_eyebrows = EYEBROWS_REGISTRY.get_all_string_ids().pick_random()
	
	var hair_id: int = randi() % 6
	hair_outline = HAIR_OUTLINES[hair_id]
	hair_color_texture = HAIR_COLORS_TEXTURES[hair_id]
	if hair_id == 5:
		hair_color = CAP_COLORS.pick_random()
	else:
		hair_color = HAIR_COLORS.pick_random()
