extends Control

const TINT_COLOR := Color("000000bf")

@onready var tint_color_rect: ColorRect = %TintColorRect
@onready var panel_container: PanelContainer = %PanelContainer
@onready var dont_show_again_check_box: CheckBox = %DontShowAgainCheckBox
@onready var close_button: MenuButtonClass = %CloseButton


func popup() -> void:
	panel_container.scale = Vector2.ZERO
	tint_color_rect.self_modulate = Color.TRANSPARENT
	show()
	
	var scale_tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(panel_container, "scale", Vector2.ONE, 0.5)
	
	var color_tweener := create_tween().tween_property(tint_color_rect, "self_modulate", TINT_COLOR, 1)
	color_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
