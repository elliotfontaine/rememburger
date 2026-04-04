class_name GameContent
extends Control
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@onready var pause_menu_button: MenuButtonClass = %PauseMenuButton
@onready var queue_view: QueueView = %QueueView
@onready var queue_manager: QueueManager = %QueueManager


func _ready() -> void:
	LogWrapper.debug(self, "Scene ready.")
	queue_view.update_customer_positions()
