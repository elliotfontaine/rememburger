class_name IngredientData
extends Resource

enum WorkStation {NONE, CHOPPING_BOARD, GRILL}
enum IngredientType {
	BREAD_BOTTOM,  # toujours 1, toujours en premier
	BREAD_TOP,     # toujours 1, toujours en dernier
	PROTEIN,       # steak, steak_veggie (1 à 2, cœur du burger)
	TOPPING,       # bacon, œuf frit, oignon caramélisé (0 à 2, optionnel)
	CHEESE,        # cheddar (0 à 1)
	VEGGIE,        # tomate, salade, oignon cru, pickle (0 à 3)
	SAUCE,         # bbq, mayo, moutarde, moutarde (0 à 2)
}

@export var name: String = ""
@export var texture: CompressedTexture2D
@export var type: IngredientType = IngredientType.TOPPING
# true means it can be used in a burger, and workstation should be NONE.
@export var processed: bool = true
@export_group("Work Recipe")
@export var workstation: WorkStation = WorkStation.NONE
@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce,true") var work_result_success: StringName
@export var n_produced_success: int = 1
@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce,true") var work_result_fail: StringName
@export var n_produced_fail: int = 1

func _to_string() -> String:
	return name
