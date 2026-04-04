class_name QueueManager
extends Node

signal customer_state_changed(customer: CustomerData)
signal customer_left_angry(customer: CustomerData)
signal customer_served(customer: CustomerData, points: int)

var customer_queue: Array[CustomerData] = []

func _process(delta: float) -> void:
	for customer in customer_queue:
		customer.points -= delta * CustomerData.POINTS_PER_SECOND
		if customer.points <= 0:
			pass
			#_handle_angry_leave(customer)
		customer_state_changed.emit(customer) # les Views réagissent


func add_customer() -> void:
	pass
