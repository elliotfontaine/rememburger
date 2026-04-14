class_name GameContent
extends Control
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal game_ended

const CUSTOMER_HEAD_SCENE = preload("uid://c3fpwahskxru5")

@export var game_duration := 5 * 60

var display_score: int = 0
var remaining_time: int
var _score_tween: Tween

@onready var pause_menu_button: MenuButtonClass = %PauseMenuButton
@onready var queue_manager: QueueManager = %QueueManager
@onready var debug_margin_container: MarginContainer = %DebugMarginContainer
@onready var debug_info_label: Label = %DebugInfoLabel
@onready var queue_size_value_label: Label = %QueueSizeValueLabel
@onready var queue_customer_list_label: Label = %QueueCustomerListLabel
@onready var score_label: Label = %ScoreLabel
@onready var temp_meal_points_container: HBoxContainer = %TempMealPointsContainer
@onready var temp_meal_points_label: Label = %TempMealPointsLabel
@onready var temp_tip_points_container: HBoxContainer = %TempTipPointsContainer
@onready var temp_tip_customer_head: Node2D = %TempTipCustomerHead
@onready var temp_tip_points_label: Label = %TempTipPointsLabel
@onready var timer_label: Label = %TimerLabel
@onready var up_arrow_anchor: Control = %UpArrowAnchor
@onready var down_arrow_anchor: Control = %DownArrowAnchor


func _ready() -> void:
	GlobalScore.score = 0
	remaining_time = game_duration
	score_label.text = "%d" % GlobalScore.score
	temp_meal_points_container.hide()
	temp_tip_points_container.hide()
	up_arrow_anchor.hide()
	down_arrow_anchor.show()

	SignalBus.camera_target_changed.connect(_on_camera_target_changed)
	SignalBus.customer_served.connect(score_points)
	SignalBus.customer_ticked.connect(_on_queue_manager_customer_ticked)
	SignalBus.queue_changed.connect(_on_queue_manager_queue_changed)

	queue_manager.start()
	_update_debug_overlay()
	
	LogWrapper.debug(self, "Scene ready.")
	
	if OS.is_debug_build():
		_test_mealdata_distance()


func _process(_delta: float) -> void:
	timer_label.text = "%02d:%02d" % [remaining_time / 60, remaining_time % 60]


func score_points(customer_data: CustomerData, meal_points: int, tip_points: int) -> void:
	var current_score: int = GlobalScore.score
	GlobalScore.score += meal_points + tip_points
		
	if meal_points > 0:
		temp_meal_points_label.text = "+ %d €" % meal_points
		temp_meal_points_container.show()
		temp_meal_points_label.custom_minimum_size.x = temp_meal_points_label.size.x
		temp_tip_points_label.text = "+ %d €" % tip_points
		temp_tip_points_container.show()
		temp_tip_points_label.custom_minimum_size.x = temp_meal_points_label.size.x # uses meal for alignment
		temp_tip_customer_head.setup_visuals(customer_data)
		var meal_text_color := MainColorPalette.COLOR_SUCCESS if meal_points == customer_data.order.base_price else MainColorPalette.COLOR_WARNING
		var tip_text_color := MainColorPalette.COLOR_SUCCESS if tip_points else MainColorPalette.COLOR_FAILURE
		temp_meal_points_label.add_theme_color_override("font_color", meal_text_color)
		temp_tip_points_label.add_theme_color_override("font_color", tip_text_color)
	
	if _score_tween:
		_score_tween.kill()
	_score_tween = create_tween().set_parallel()
	@warning_ignore_start("untyped_declaration")
	_score_tween.tween_method(func(v): score_label.set_text("%d €" % v), current_score, GlobalScore.score, 1.0).set_delay(1.5)
	_score_tween.tween_method(func(v): temp_meal_points_label.set_text("+ %d €" % v), meal_points, 0, 1.0).set_delay(1.5)
	_score_tween.tween_method(func(v): temp_tip_points_label.set_text("+ %d €" % v), tip_points, 0, 1.0).set_delay(1.5)
	@warning_ignore_restore("untyped_declaration")
	_score_tween.set_parallel(false)
	_score_tween.tween_callback(temp_meal_points_container.set_visible.bind(false))
	_score_tween.tween_callback(temp_tip_points_container.set_visible.bind(false))
	
	
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
