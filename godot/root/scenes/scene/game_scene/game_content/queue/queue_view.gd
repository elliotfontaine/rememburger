class_name QueueView
extends Node2D

# Vue de la queue des clients. Les nodes enfants sont des CustomerView.

const CUSTOMER_OFFSET := Vector2(100.0, -20.0)


func get_customer_target_position(index: int) -> Vector2:
	return index * CUSTOMER_OFFSET 


func update_customer_positions() -> void:
	for customer: CustomerView in get_children():
		move_customer(customer, get_customer_target_position(customer.get_index()))
		
	
func move_customer(customer: CustomerView, new_position: Vector2) -> void:
	create_tween().tween_property(customer, "position", new_position, 3.0)
