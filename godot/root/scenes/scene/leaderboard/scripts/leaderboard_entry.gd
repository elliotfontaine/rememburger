extends Control


func set_data(entry: TaloLeaderboardEntry) -> void:
	%Rank.text = str(entry.position + 1)
	%Username.text = entry.player_alias.identifier
	%Score.text = "%s" % int(entry.score)
	%Archived.text =  "" if entry.deleted_at.is_empty() else "(archived)"
