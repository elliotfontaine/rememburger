extends Control

@onready var score_label: Label = %ScoreLabel
@onready var leaderboard: Control = %Leaderboard
@onready var username_line_edit: LineEdit = %UsernameLineEdit
@onready var first_time_save: PanelContainer = %FirstTimeSave
@onready var could_not_save: Label = %CouldNotSave
@onready var new_best: RichTextLabel = %NewBest


func _ready() -> void:
	first_time_save.hide()
	could_not_save.hide()
	new_best.hide()
	visibility_changed.connect(_on_visibility_changed)


func _process(_delta: float) -> void:
	score_label.text = "%d" % GlobalScore.score


func _submit_score() -> LeaderboardsAPI.AddEntryResult:
	var score := GlobalScore.score
	if Talo.current_player:
		var high_score := int(Talo.current_player.get_prop("high_score", "0"))
		if score > high_score:
			Talo.current_player.set_prop("high_score", str(score), true)
	
	var res := await Talo.leaderboards.add_entry(leaderboard.leaderboard_internal_name, score)
	return res


func _retrieve_talo_identifier() -> String:
	var alias := TaloPlayerAlias.get_offline_alias()
	if alias != null:
		return alias.identifier
	return ""


func _on_visibility_changed() -> void:
	if visible:
		var identifier := _retrieve_talo_identifier()
		if identifier:
			await Talo.players.identify("username", identifier)
			if GlobalScore.score > int(Talo.current_player.get_prop("high_score", "0")):
				new_best.scale = Vector2.ZERO
				create_tween().tween_property(new_best, "scale", Vector2.ONE, 1).set_trans(Tween.TRANS_BACK)
				new_best.show()
			_submit_score()
		else:
			first_time_save.show()
			
		leaderboard.update()


func _on_submit_username_button_pressed() -> void:
	await Talo.players.identify("username", username_line_edit.text)
	var add_entry_result := await _submit_score()
	if add_entry_result:
		first_time_save.hide()
		could_not_save.hide()
		leaderboard.update()
	else:
		could_not_save.show()



func _on_main_menu_button_pressed() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.MENU_SCENE, "fade_play")


func _on_play_again_button_pressed() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.GAME_SCENE, "fade_play")
