extends Control

const TINT_COLOR := Color("000000bf")

@onready var panel_container: PanelContainer = %PanelContainer
@onready var tint_color_rect: ColorRect = %TintColorRect
@onready var times_up_label: Label = %TimesUpLabel
@onready var score_label: Label = %ScoreLabel
@onready var leaderboard: Control = %Leaderboard
@onready var username_line_edit: LineEdit = %UsernameLineEdit
@onready var first_time_save: PanelContainer = %FirstTimeSave
@onready var could_not_save: Label = %CouldNotSave
@onready var new_best: RichTextLabel = %NewBest


func popup() -> void:
	first_time_save.hide()
	could_not_save.hide()
	new_best.hide()
	panel_container.scale = Vector2.ZERO
	times_up_label.scale = Vector2.ZERO
	tint_color_rect.self_modulate = Color.TRANSPARENT
	show()
	
	var scale_tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(panel_container, "scale", Vector2.ONE, 0.5)
	scale_tween.tween_property(times_up_label, "scale", Vector2.ONE, 0.5).set_delay(0.2)
	
	var color_tweener := create_tween().tween_property(tint_color_rect, "self_modulate", TINT_COLOR, 1)
	color_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var set_score_text := func(value: int) -> void: score_label.text = "%d €" % value
	var score_tweener := create_tween().tween_method(set_score_text, 0, GlobalScore.score, 2.5)
	score_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

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
