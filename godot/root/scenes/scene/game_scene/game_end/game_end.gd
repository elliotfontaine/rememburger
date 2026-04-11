extends Control

@onready var score_label: Label = %ScoreLabel
@onready var leaderboard: Control = %Leaderboard
@onready var username_line_edit: LineEdit = %UsernameLineEdit


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _process(_delta: float) -> void:
	score_label.text = "%d" % GlobalScore.score


func _on_main_menu_button_pressed() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.MENU_SCENE, "fade_play")


func _on_retry_button_pressed() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.GAME_SCENE, "fade_play")


func _on_visibility_changed() -> void:
	if visible:
		leaderboard.update()


func _on_submit_username_button_pressed() -> void:
	await Talo.players.identify("username", username_line_edit.text)
	var score := GlobalScore.score
	var res := await Talo.leaderboards.add_entry(leaderboard.leaderboard_internal_name, score)
	assert(is_instance_valid(res))

	leaderboard.update()
