class_name CustomerData
extends Resource

enum State { IN_QUEUE, AT_COUNTER, SERVED, LEFT_ANGRY }

const MENU_ENTRY_REGISTRY: Registry = preload("uid://b7eqya2l1ru20")
const EYEBROWS_REGISTRY: Registry = preload("uid://cntama5dodoaj")
const EYES_REGISTRY: Registry = preload("uid://ws8rnmdop37h")
const MOUTH_REGISTRY: Registry = preload("uid://bex11e6h012jd")
const NOSE_REGISTRY: Registry = preload("uid://bic7bqjfx2rjs")
const HAIR_DATA_REGISTRY = preload("uid://gtqjb3b5c3eo")
const SKIN_TONE_PALETTE: ColorPalette = preload("uid://du487wli3xs7b")
const SHIRT_PALETTE: ColorPalette = preload("uid://cll8m52alq68c")

const NAMES = [
	"Max", "Kim", "Pat", "Lee", "Mel", "Sasha", "Robin", "Casey", "Riley",
	"John", "Emilie", "Fabian", "Laura", "Thomas", "Greg", "Marco", "Louise",
	"Harry", "Mindy", "Rosa", "Richie", "Alex", "Sam", "Charlie", "Lou", "Jo",
	"Quinn", "Avery", "Jamie", "Sage", "Blake", "Remy"
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
var hair_data: StringName


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
	shirt_color = SHIRT_PALETTE.colors[randi() % SHIRT_PALETTE.colors.size()]
	skin_color = SKIN_TONE_PALETTE.colors[randi() % SKIN_TONE_PALETTE.colors.size()]
	face_mouth = MOUTH_REGISTRY.get_all_string_ids().pick_random()
	face_nose = NOSE_REGISTRY.get_all_string_ids().pick_random()
	face_eyes = EYES_REGISTRY.get_all_string_ids().pick_random()
	face_eyebrows = EYEBROWS_REGISTRY.get_all_string_ids().pick_random()
	hair_data = HAIR_DATA_REGISTRY.get_all_string_ids().pick_random()
