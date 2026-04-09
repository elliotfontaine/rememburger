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
@onready var points_label: Label = %PointsLabel
@onready var tmp_points_label: Label = %TmpPointsLabel
@onready var timer_label: Label = %TimerLabel


var display_score: int = 0
var remaining_time: int = 5 * 60

signal game_ended


func _ready() -> void:
	GlobalScore.score = 0
	LogWrapper.debug(self, "Scene ready.")

	queue_manager.connect("customer_added", SignalBus.customer_added.emit)
	queue_manager.connect("customer_ticked", SignalBus.customer_ticked.emit)
	queue_manager.connect("customer_state_changed", SignalBus.customer_state_changed.emit)
	queue_manager.connect("customer_left_angry", SignalBus.customer_left_angry.emit)
	queue_manager.connect("customer_served", SignalBus.customer_served.emit)
	queue_manager.connect("queue_changed", SignalBus.queue_changed.emit)

	queue_manager.connect("customer_served", score_points)

	queue_manager.start()
	#queue_view.update_customer_positions()
	_update_debug_overlay()

func _process(_delta: float) -> void:
	points_label.text = str(display_score)

	tmp_points_label.text = "+ %d" % (GlobalScore.score - display_score)
	tmp_points_label.visible = (GlobalScore.score != display_score)

	timer_label.text = "%02d:%02d" % [remaining_time / 60, remaining_time % 60]


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

func score_points(_customer_data: CustomerData, points_earned: int) -> void:
	GlobalScore.score += points_earned
	create_tween().tween_property(self, "display_score", GlobalScore.score, 1.0).set_delay(0.5)


func _on_timer_timeout() -> void:
	remaining_time -= 1
	if remaining_time == 0:
		game_ended.emit()
