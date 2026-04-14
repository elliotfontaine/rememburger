@tool
class_name MealData
extends Resource

# @tool is required for the `_to_string` override to be accessed by YARD.

const COST_MISSING := 40 # deletion
const COST_EXTRA := 15 # insertion
const COST_WRONG := 30 # substitution
const COST_SWAP := 10 # transposition

@export_custom(Registry.PROPERTY_HINT_CUSTOM, "uid://cgvbeut67x3ce") var ingredients: Array[StringName] = []


func _init(...p_ingredients: Array) -> void:
	for ingredient: Variant in p_ingredients:
		if ingredient is StringName or ingredient is String:
			ingredients.append(StringName(ingredient))

func equals(other: MealData) -> bool:
	if ingredients.size() != other.ingredients.size():
		return false
	
	return ingredients == other.ingredients

## How different the meal is to another (from 0 to 100). Should be used as a malus.
## Uses weighted Damerau-Levenshtein distance (see constants).
func distance_to(other: MealData) -> int:
	var expected := ingredients
	var actual := other.ingredients
	var expected_size := expected.size()
	var actual_size := actual.size()
	
	# Build DP matrix (expected_size+1) x (actual_size+1)
	var dp: Array[Array] = []
	for i in expected_size + 1:
		var row: Array[int] = []
		row.resize(actual_size + 1)
		dp.append(row)
	
	# Base cases: removing all expected / adding all actual
	for i in expected_size + 1:
		dp[i][0] = i * COST_MISSING
	for j in actual_size + 1:
		dp[0][j] = j * COST_EXTRA
	
	for i in range(1, expected_size + 1):
		for j in range(1, actual_size + 1):
			var substitution_cost := 0 if expected[i - 1] == actual[j - 1] else COST_WRONG
			
			var deletion:    int = dp[i - 1][j    ] + COST_MISSING
			var insertion:   int = dp[i    ][j - 1] + COST_EXTRA
			var replacement: int = dp[i - 1][j - 1] + substitution_cost
			dp[i][j] = mini(mini(deletion, insertion), replacement)
			
			# Adjacent transposition (swap)
			var can_swap := (
				i > 1 and j > 1
				and expected[i - 1] == actual[j - 2]
				and expected[i - 2] == actual[j - 1]
			)
			if can_swap:
				dp[i][j] = mini(dp[i][j], dp[i - 2][j - 2] + COST_SWAP)
	
	var dist := mini(dp[expected_size][actual_size], 100)
	LogWrapper.debug(&"MealData", "Distance between meals : %s" % dist)
	return dist


func is_empty() -> bool:
	return ingredients.is_empty()


func _to_string() -> String:
	var names_array: PackedStringArray
	for ingredient: StringName in ingredients:
		names_array.append(ingredient)
	return "MealData(" + ", ".join(names_array) + ")"
