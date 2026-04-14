class_name PauseMenu
extends Control
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const TINT_COLOR := Color("000000bf")

@onready var title_label: Label = %TitleLabel
@onready var tint_color_rect: ColorRect = %TintColorRect
@onready var main_menu_margin_container: MarginContainer = %MainMenuMarginContainer
@onready var continue_menu_button: MenuButtonClass = %ContinueMenuButton
@onready var options_menu_button: MenuButtonClass = %OptionsMenuButton
@onready var leave_menu_button: MenuButtonClass = %LeaveMenuButton
@onready var quit_menu_button: MenuButtonClass = %QuitMenuButton


func _ready() -> void:
	_connect_signals()
	_refresh_label()

	if OS.has_feature("web"):
		quit_menu_button.visible = false

	LogWrapper.debug(self, "Ready.")


func popup() -> void:
	main_menu_margin_container.scale = Vector2.ZERO
	tint_color_rect.self_modulate = Color.TRANSPARENT
	show()
	
	var scale_tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(main_menu_margin_container, "scale", Vector2.ONE, 0.5)
	
	var color_tweener := create_tween().tween_property(tint_color_rect, "self_modulate", TINT_COLOR, 0.5)
	color_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _refresh_label() -> void:
	title_label.text = TranslationServerWrapper.translate("MENU_LABEL_PAUSED")


func _connect_signals() -> void:
	SignalBus.language_changed.connect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	_refresh_label()
