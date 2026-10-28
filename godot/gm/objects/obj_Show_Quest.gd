extends GMInstance
## obj_Show_Quest (원작 room_Quest_Log 퀘스트 상세 보드)


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	draw_self()
	var quests: Array = GM.db.get("quests", [])
	draw_set_format("fnt_Text", 0xDDE105, 0, 0)
	draw_text_shadow(x + 18.0, y + 14.0, "ACTIVE CAMPAIGN QUEST LOG (%d Quests)" % quests.size(), 0xDDE105, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	var max_show := mini(5, quests.size())
	for i in range(max_show):
		var q: Dictionary = quests[i]
		var line := "Q#%d %s (%s)" % [int(q.get("id", i + 1)), str(q.get("name_en", "Quest")), str(q.get("npc", "NPC"))]
		draw_text_shadow(x + 18.0, y + 38.0 + float(i) * 22.0, line, 0xFFFFFF, 0)
