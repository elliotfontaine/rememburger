extends Node2D

@onready var queue_view: QueueView = %QueueView
@onready var reject_button: Button = %RejectButton
@onready var take_order_button: Button = %TakeOrderButton
@onready var serving_spot: Area2D = %ServingSpot
@onready var bubble: Node2D = %Bubble
@onready var meal_desc: CanvasGroup = %MealDesc
@onready var meal_stack: CanvasGroup = %MealStack


func _hide_counter_buttons() -> void:
	bubble.visible = false
	reject_button.visible = false
	take_order_button.visible = false
	serving_spot.visible = false


func _on_queue_view_customer_exited(_customer_data: CustomerData) -> void:
	_hide_counter_buttons()


func _on_queue_view_customer_entered(customer_data: CustomerData) -> void:
	if not customer_data.state == CustomerData.State.AT_COUNTER:
		return
	
	reject_button.visible = true

	if customer_data.has_ordered:
		serving_spot.visible = true
	else:
		meal_desc.meal_data = customer_data.order
		meal_stack.meal_data = customer_data.order
		bubble.visible = true
		take_order_button.visible = true


func _on_reject_button_pressed() -> void:
	_hide_counter_buttons()
	SignalBus.reject_button_pressed.emit()


func _on_take_order_button_pressed() -> void:
	_hide_counter_buttons()
	SignalBus.take_order_button_pressed.emit()
