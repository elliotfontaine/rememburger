extends Node2D

@onready var queue_view: QueueView = %QueueView
@onready var reject_button: Button = %RejectButton
@onready var take_order_button: Button = %TakeOrderButton
@onready var serving_spot: Area2D = %ServingSpot

func _ready() -> void:
	take_order_button.pressed.connect(SignalBus.take_order_button_pressed.emit)
	reject_button.pressed.connect(SignalBus.reject_button_pressed.emit)
	
