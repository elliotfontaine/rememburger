class_name MenuEntry
extends Resource

enum Difficulty {
	EASY,
	NORMAL,
	HARD
}

@export var name: String = "Fooburger"
@export var meal: MealData
@export var base_price: int = 20
@export var difficulty: Difficulty = Difficulty.EASY
