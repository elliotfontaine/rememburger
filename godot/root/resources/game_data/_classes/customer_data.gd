class_name CustomerData
extends Resource

enum State { IN_QUEUE, AT_COUNTER, SERVED, LEFT_ANGRY }

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
var points: float = 100.0 # decreasing
var order: MealData


func is_alive() -> bool:
	return points > 0.0 and state != State.LEFT_ANGRY


func _to_string() -> String:
	return "{name}({id})".format(self)
