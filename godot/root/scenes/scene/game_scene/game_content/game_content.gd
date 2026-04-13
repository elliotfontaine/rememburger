class_name GameContent
extends Control
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export var game_duration := 5 * 60

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
@onready var up_arrow_anchor: Control = %UpArrowAnchor
@onready var down_arrow_anchor: Control = %DownArrowAnchor


var display_score: int = 0
var remaining_time: int

signal game_ended


func _ready() -> void:
	GlobalScore.score = 0
	remaining_time = game_duration
	up_arrow_anchor.hide()
	down_arrow_anchor.show()

	queue_manager.customer_added.connect(SignalBus.customer_added.emit)
	queue_manager.customer_ticked.connect(SignalBus.customer_ticked.emit)
	queue_manager.customer_state_changed.connect(SignalBus.customer_state_changed.emit)
	queue_manager.customer_left_angry.connect(SignalBus.customer_left_angry.emit)
	queue_manager.customer_served.connect(SignalBus.customer_served.emit)
	queue_manager.queue_changed.connect(SignalBus.queue_changed.emit)
	SignalBus.camera_target_changed.connect(_on_camera_target_changed)

	queue_manager.customer_served.connect(score_points)

	queue_manager.start()
	_update_debug_overlay()
	
	LogWrapper.debug(self, "Scene ready.")
	
	if OS.is_debug_build():
		_test_mealdata_distance()


func _process(_delta: float) -> void:
	points_label.text = "%s €" % display_score

	tmp_points_label.text = "+ %d €" % (GlobalScore.score - display_score)
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
		AudioManagerWrapper.play_sfx(AudioEnum.Sfx.GAME_OVER)
		game_ended.emit()


func _on_camera_target_changed(direction: Vector2) -> void:
	match direction:
		Vector2.UP:
			up_arrow_anchor.hide()
			down_arrow_anchor.show()
		Vector2.DOWN:
			down_arrow_anchor.hide()
			up_arrow_anchor.show()
		_:
			pass
	

func _test_mealdata_distance() -> void:
	#const COST_MISSING := 40 # deletion
	#const COST_EXTRA := 15 # insertion
	#const COST_WRONG := 30 # substitution
	#const COST_SWAP := 10 # transposition

	var diff_ok := MealData.new(
		&"bread_bottom", &"bread_top").distance_to(MealData.new(
		&"bread_bottom", &"bread_top"))
	var diff_missing := MealData.new(
		&"bread_bottom", &"bread_top").distance_to(MealData.new(
		&"bread_bottom"))
	var diff_wrong := MealData.new(
		&"bread_bottom", &"steak_cooked", &"bread_top").distance_to(MealData.new(
		&"bread_bottom", &"lettuce", &"bread_top"))
	var diff_swap := MealData.new(
		&"bread_bottom", &"steak_cooked", &"lettuce", &"bread_top").distance_to(MealData.new(
		&"bread_bottom", &"lettuce", &"steak_cooked", &"bread_top"))
	var diff_swap_and_missing := MealData.new(
		&"bread_bottom", &"steak_cooked", &"lettuce", &"cheddar", &"bread_top").distance_to(MealData.new(
		&"bread_bottom", &"lettuce", &"steak_cooked", &"bread_top"))
	var diff_wrong_and_swap := MealData.new(
		&"bread_bottom", &"ketchup", &"steak_cooked", &"lettuce", &"cheddar", &"bread_top").distance_to(MealData.new(
		&"bread_bottom", &"mustard", &"lettuce", &"steak_cooked", &"cheddar", &"bread_top"))
	LogWrapper.debug(self, "(O) OK         should be 0:  %s" % diff_ok)
	LogWrapper.debug(self, "(M) MISSING   should be 40: %s" % diff_missing)
	LogWrapper.debug(self, "(W) WRONG     should be 30: %s" % diff_wrong)
	LogWrapper.debug(self, "(S) SWAP      should be 10: %s" % diff_swap)
	LogWrapper.debug(self, "(S) + (M)     should be 50: %s" % diff_swap_and_missing)
	LogWrapper.debug(self, "(W) + (S)     should be 40: %s" % diff_wrong_and_swap)
