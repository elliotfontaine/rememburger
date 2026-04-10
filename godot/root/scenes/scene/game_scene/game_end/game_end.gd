extends Control

@onready var score_label: Label = %ScoreLabel

func _process(_delta: float) -> void:
	score_label.text = "%d" % GlobalScore.score


func _on_main_menu_button_pressed() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.MENU_SCENE, "fade_play")
