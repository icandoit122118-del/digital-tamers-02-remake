extends GMInstance
## obj_Tamer_Info (원작 room_Tamer_Info 테이머 프로필 카드)


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	draw_self()
	draw_set_format("fnt_MidText", 0xDDE105, 0, 0)
	draw_text_shadow(x + 28.0, y + 22.0, "TAMER: %s  (Lv.%d)" % [str(GM.g.get("TamerName", "Tamer")), int(GM.g.get("tamerLv", 12))], 0xDDE105, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 28.0, y + 52.0, "Tamer XP: %d / 500   |   Skill Points (SP): %d" % [int(GM.g.get("tamerXp", 420)), int(GM.g.get("tamerSp", 5))], 0xFFFFFF, 0)
	draw_text_shadow(x + 28.0, y + 76.0, "Total Battles: %d   (Victories: %d / Defeats: %d)" % [int(GM.g.get("totalBattles", 20)), int(GM.g.get("wins", 18)), int(GM.g.get("losses", 2))], 0xFFFFFF, 0)
	draw_text_shadow(x + 28.0, y + 100.0, "Owned BIT: %d   |   DigiCores: %d" % [int(GM.g.get("bits", 24500)), int(GM.g.get("digiCores", 12))], 0x6BFF5A, 0)
	draw_text_shadow(x + 28.0, y + 124.0, "Infinity Tower Best: B%dF   |   Challenge Rank: #%d" % [int(GM.g.get("infinityFloor", 1)), int(GM.g.get("challengeRank", 1))], 0xFFFFFF, 0)
