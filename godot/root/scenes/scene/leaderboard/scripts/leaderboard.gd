extends Control

const ENTRY_SCENE = preload("uid://ux6qqklo3p0r")

@export var leaderboard_internal_name: String = ""
@export var include_archived: bool

@onready var entries_container: VBoxContainer = %Entries
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var info_label: Label = %InfoLabel
@onready var current_player_entry: PanelContainer = %CurrentPlayerEntry

var _entries_error: bool


func update() -> void:
	info_label.text = "Loading..."
	info_label.show()
	scroll_container.hide()
	current_player_entry.hide()
	_entries_error = false
	
	await _load_entries()
	if not _entries_error:
		info_label.hide()
		scroll_container.show()
	else:
		info_label.text = "Could not access leaderboard."


func _load_entries() -> void:
	var page := 0
	var done := false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = include_archived

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)

		if not is_instance_valid(res):
			_entries_error = true
			return

		var is_last_page := res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_build_entries()


func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance := ENTRY_SCENE.instantiate()
	entry_instance.set_data(entry)
	entries_container.add_child(entry_instance)


func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries := Talo.leaderboards.get_cached_entries(leaderboard_internal_name)

	for entry in entries:
		_create_entry(entry)
		if Talo.current_alias and entry.player_alias.identifier == Talo.current_alias.identifier:
			current_player_entry.set_data(entry)
			current_player_entry.show()


func _on_refresh_button_pressed() -> void:
	update()
