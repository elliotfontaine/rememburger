class_name QueueView
extends Node2D

# Vue de la queue des clients. Les nodes enfants sont des CustomerView.

signal customer_entered(customer_data: CustomerData)
signal customer_exited(customer_data: CustomerData)

const CUSTOMER_VIEW_SCENE: PackedScene = preload("uid://cokofndbolbnc")
const SPREAD: Vector2 = Vector2(200, -10)
const CUSTOMER_OFFSET := Vector2(100.0, -20.0)
const START_POSITION := Vector2(1200, CUSTOMER_OFFSET.y)

var _first_client: bool = true

@onready var waiting_group: Node2D = %WaitingGroup
@onready var leaving_group: Node2D = %LeavingGroup


func _ready() -> void:
	SignalBus.customer_added.connect(add_customer)
	SignalBus.customer_state_changed.connect(customer_state_changed)
	SignalBus.customer_left_angry.connect(leave_angry)
	SignalBus.customer_served.connect(leave_happy)


func add_customer(customer_data: CustomerData) -> void:
	var new_customer: CustomerView  = CUSTOMER_VIEW_SCENE.instantiate()
	new_customer.data = customer_data
	new_customer.apply_visuals()
	new_customer.position = Vector2(1200, CUSTOMER_OFFSET.y)
	waiting_group.add_child(new_customer)
	if _first_client:
		_first_client = false
	else:
		AudioManagerWrapper.play_sfx(AudioEnum.Sfx.CLIENT_ENTER)
	update_customer_positions()


func customer_state_changed(customer_data: CustomerData) -> void:
	if customer_data.state == CustomerData.State.IN_QUEUE:
		var first_in_line: CustomerView = waiting_group.get_child(0)
		waiting_group.remove_child(first_in_line)
		waiting_group.add_child(first_in_line)
		update_customer_positions()


func leave_angry(customer_data: CustomerData) -> void:
	for customer: CustomerView in waiting_group.get_children():
		if customer.data.id == customer_data.id:
			make_leave(customer)
			break

	update_customer_positions()


func leave_happy(customer_data: CustomerData, _points: int) -> void:
	for customer: CustomerView in waiting_group.get_children():
		if customer.data.id == customer_data.id:
			make_leave(customer)
			break

	update_customer_positions()


func make_leave(customer: CustomerView) -> void:
	customer.reparent(leaving_group)
	move_customer(customer, START_POSITION)
	create_tween().tween_property(customer, "modulate", Color.TRANSPARENT, 1.0).set_delay(1.4)
	create_tween().tween_callback(customer.queue_free).set_delay(3.1)


func get_customer_target_position(index: int) -> Vector2:
	return CUSTOMER_OFFSET + index * SPREAD


func update_customer_positions() -> void:
	for customer: CustomerView in waiting_group.get_children():
		var target_pos := get_customer_target_position(customer.get_index())
		if target_pos != customer.position:
			move_customer(customer, target_pos)


func move_customer(customer: CustomerView, new_position: Vector2) -> void:
	var move_tween := create_tween()
	var distance := new_position.distance_to(customer.position)
	move_tween.tween_property(customer, "position", new_position, randf_range(2.3, 3.0))
	move_tween.finished.connect(_on_move_tween_finished.bind(customer))

	customer.animation_player.play(
		&"walking",
		-1,
		max(1.0, randf_range(0.6, 1.0) * (distance / SPREAD.length())),
	)


func _on_area_2d_area_entered(area: Area2D) -> void:
	var customer: CustomerView = area.get_parent() as CustomerView
	if not customer:
		return
	
	customer_entered.emit(customer.data)


func _on_area_2d_area_exited(area: Area2D) -> void:
	var customer: CustomerView = area.get_parent() as CustomerView
	if not customer:
		return
	
	customer_exited.emit(customer.data)


func _on_move_tween_finished(customer: Variant) -> void:
	# Variant because it might have been freed.
	if not customer or customer in leaving_group.get_children():
		return
		
	if not customer.animation_player.current_animation == &"breathing":
		customer.animation_player.play(&"breathing", -1, randf_range(0.8, 1.2))
