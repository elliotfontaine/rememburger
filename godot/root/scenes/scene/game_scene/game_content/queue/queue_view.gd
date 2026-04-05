class_name QueueView
extends Node2D

# Vue de la queue des clients. Les nodes enfants sont des CustomerView.

signal customer_entered(customer_data: CustomerData)
signal customer_exited(customer_data: CustomerData)

@onready var customerScene: PackedScene = preload("res://root/scenes/scene/game_scene/game_content/queue/customer/customer_view.tscn")

const SPREAD: Vector2 = Vector2(200, -10)
const CUSTOMER_OFFSET := Vector2(100.0, -20.0)
const START_POSITION := Vector2(1200, CUSTOMER_OFFSET.y)

func _ready() -> void:
	SignalBus.customer_added.connect(add_customer)
	SignalBus.customer_state_changed.connect(customer_state_changed)
	SignalBus.customer_left_angry.connect(leave_angry)
	SignalBus.customer_served.connect(leave_happy)


func add_customer(customer_data: CustomerData) -> void:
	var new_customer: CustomerView  = customerScene.instantiate()
	new_customer.data = customer_data
	new_customer.apply_visuals()
	new_customer.position = Vector2(1200, CUSTOMER_OFFSET.y)
	$Waiting.add_child(new_customer)
	update_customer_positions()

func customer_state_changed(customer_data: CustomerData) -> void:
	if customer_data.state == CustomerData.State.IN_QUEUE:
		var first_in_line: CustomerView = $Waiting.get_child(0)
		$Waiting.remove_child(first_in_line)
		$Waiting.add_child(first_in_line)
		update_customer_positions()

func leave_angry(customer_data: CustomerData) -> void:
	for customer: CustomerView in $Waiting.get_children():
		if customer.data.id == customer_data.id:
			make_leave(customer)
			break

	update_customer_positions()

func leave_happy(customer_data: CustomerData, _points: int) -> void:
	for customer: CustomerView in $Waiting.get_children():
		if customer.data.id == customer_data.id:
			make_leave(customer)
			break

	update_customer_positions()

func make_leave(customer: CustomerView) -> void:
	$Waiting.remove_child(customer)
	$Leaving.add_child(customer)
	create_tween().tween_property(customer, "position", START_POSITION, 2.0)
	create_tween().tween_callback(customer.queue_free).set_delay(2.1)


func get_customer_target_position(index: int) -> Vector2:
	return CUSTOMER_OFFSET + index * SPREAD


func update_customer_positions() -> void:
	for customer: CustomerView in $Waiting.get_children():
		move_customer(customer, get_customer_target_position(customer.get_index()))


func move_customer(customer: CustomerView, new_position: Vector2) -> void:
	create_tween().tween_property(customer, "position", new_position, 3.0)


func _on_area_2d_area_entered(area: Area2D) -> void:
	var customer: CustomerView = area.get_parent() as CustomerView
	if not customer:
		return
	emit_signal("customer_entered", customer.data)


func _on_area_2d_area_exited(area: Area2D) -> void:
	var customer: CustomerView = area.get_parent() as CustomerView
	if not customer:
		return
	emit_signal("customer_exited", customer.data)
