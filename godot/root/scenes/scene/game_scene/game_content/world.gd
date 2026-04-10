extends Node2D

@onready var queue_view: QueueView = %QueueView
@onready var reject_button: Button = %RejectButton
@onready var take_order_button: Button = %TakeOrderButton
@onready var serving_spot: Area2D = %ServingSpot
@onready var bubble: Node2D = %Bubble
@onready var meal_desc: CanvasGroup = %MealDesc
@onready var meal_stack: CanvasGroup = %MealStack
@onready var meal_price_label: Label = %MealPriceLabel
@onready var meal_name_label: Label = %MealNameLabel


func _ready() -> void:
	bubble.hide()

func _hide_counter_buttons() -> void:
	for node in [reject_button, take_order_button, serving_spot]:
		node.hide()
	
	var tweener := create_tween().tween_property(bubble, "scale", Vector2.ZERO, 0.3)
	tweener.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)


func _on_queue_view_customer_exited(_customer_data: CustomerData) -> void:
	_hide_counter_buttons()


func _on_queue_view_customer_entered(customer_data: CustomerData) -> void:
	if not customer_data.state == CustomerData.State.AT_COUNTER:
		return
	
	reject_button.show()

	if customer_data.has_ordered:
		serving_spot.show()
	else:
		take_order_button.show()
		
		meal_desc.meal_data = customer_data.order.meal
		meal_stack.meal_data = customer_data.order.meal
		meal_price_label.text = str(customer_data.order.base_price) + " $"
		meal_name_label.text = customer_data.order.name
		
		bubble.scale = Vector2.ZERO
		var tweener := create_tween().tween_property(bubble, "scale", Vector2.ONE, 0.4)
		tweener.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		bubble.show()
		


func _on_reject_button_pressed() -> void:
	_hide_counter_buttons()
	SignalBus.reject_button_pressed.emit()


func _on_take_order_button_pressed() -> void:
	_hide_counter_buttons()
	SignalBus.take_order_button_pressed.emit()
