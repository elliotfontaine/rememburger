class_name MealData
extends Resource

@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce") var ingredients: Array[StringName] = []


func equals(other: MealData) -> bool:
	if ingredients.size() != other.ingredients.size():
		return false
	
	return ingredients == other.ingredients

## How different the meal is to another (from 0 to 100). Should be used as a malus.
func distance_to(other: MealData) -> int:
	# TODO: more complex logic than binary
	return 0 if equals(other) else 100

func _to_string() -> String:
	return "MealData(" + str(ingredients) + ")"
