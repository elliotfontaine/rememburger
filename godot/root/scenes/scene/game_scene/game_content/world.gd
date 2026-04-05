extends Node2D

@onready var queue_view: QueueView = %QueueView
@onready var reject_button: Button = %RejectButton
@onready var take_order_button: Button = %TakeOrderButton
@onready var serving_spot: Area2D = %ServingSpot

func _ready() -> void:
	take_order_button.pressed.connect(SignalBus.take_order_button_pressed.emit)
	reject_button.pressed.connect(SignalBus.reject_button_pressed.emit)

func _on_queue_view_customer_exited(_customer_data: CustomerData) -> void:
	$Bubble.visible = false
	$RejectButton.visible = false
	$TakeOrderButton.visible = false

func _on_queue_view_customer_entered(customer_data: CustomerData) -> void:
	$RejectButton.visible = true

	if customer_data.has_ordered:
		$ServingSpot.visible = true
	else:
		$Bubble/MealDesc.meal_data = customer_data.order
		$Bubble.visible = true
		$TakeOrderButton.visible = true
