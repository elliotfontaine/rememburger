class_name GameContent
extends Control
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@onready var pause_menu_button: MenuButtonClass = %PauseMenuButton
#@onready var queue_view: QueueView = %QueueView
@onready var queue_manager: QueueManager = %QueueManager

# Debug
@onready var debug_margin_container: MarginContainer = %DebugMarginContainer
@onready var queue_size_value_label: Label = %QueueSizeValueLabel
@onready var queue_customer_list_label: Label = %QueueCustomerListLabel
@onready var debug_info_label: Label = %DebugInfoLabel


func _ready() -> void:
	LogWrapper.debug(self, "Scene ready.")

	queue_manager.connect("customer_added", SignalBus.customer_added.emit)
	queue_manager.connect("customer_ticked", SignalBus.customer_ticked.emit)
	queue_manager.connect("customer_state_changed", SignalBus.customer_state_changed.emit)
	queue_manager.connect("customer_left_angry", SignalBus.customer_left_angry.emit)
	queue_manager.connect("customer_served", SignalBus.customer_served.emit)
	queue_manager.connect("queue_changed", SignalBus.customer_served.emit)

	queue_manager.start()
	#queue_view.update_customer_positions()
	_update_debug_overlay()


func _update_debug_overlay() -> void:
	if not debug_margin_container.visible:
		return

	var queue := queue_manager.queue

	var customer_strings: PackedStringArray
	var info: String = ""
	for customer: CustomerData in queue:
		var customer_string := str(customer)
		customer_strings.append(customer_string)
		info += " | ".join([
			customer_string,
			"State: %s" % CustomerData.State.keys()[customer.state],
			"Has Ordered: %s" % customer.has_ordered,
			"Points: %s" % int(customer.points),
			str(customer.order),
		])
		info += "\n"
	queue_size_value_label.text = str(queue_manager.queue.size())
	queue_customer_list_label.text = "[" + ", ".join(customer_strings) + "]"
	debug_info_label.text = info


func _on_queue_manager_queue_changed() -> void:
	_update_debug_overlay()


func _on_queue_manager_customer_ticked(_customer: CustomerData) -> void:
	_update_debug_overlay()
