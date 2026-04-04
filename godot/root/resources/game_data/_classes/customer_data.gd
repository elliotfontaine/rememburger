class_name CustomerData
extends Resource

enum State { IN_QUEUE, AT_COUNTER, WAITING, SERVED, LEFT_ANGRY }
const POINTS_PER_SECOND: float = 10.0 # to be fine-tuned

var id: int
var state: State = State.IN_QUEUE
var points: float = 100.0 # decreasing
var order: MealData


func is_alive() -> bool:
	return points > 0.0 and state != State.LEFT_ANGRY


func tick(delta: float) -> void:
	if state == State.SERVED or state == State.LEFT_ANGRY:
		return
	points -= POINTS_PER_SECOND * delta
	points = maxf(0.0, points)
