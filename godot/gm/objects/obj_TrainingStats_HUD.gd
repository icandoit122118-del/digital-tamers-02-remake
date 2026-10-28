extends GMInstance
## obj_TrainingStats_HUD (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — V-GYM 우측 홀로그램 스탯 모니터)

var YY := 0.0


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	var pid: int = int(GM.g.get("partnerId", 5))
	var hp_val: float = float(GM.g.get("hp", 2200))
	var hp_max_val: float = maxf(1.0, float(GM.g.get("hp_max", 2200)))

	CBStyle.draw_vlink_panel(self, Rect2(x, y, 168.0, 148.0), CBStyle.BG_PANEL, CBStyle.BORDER_CYAN, 7.0, true)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 10.0, y + 10.0, "HP", 0x81B910, 0)
	CBStyle.draw_capsule_bar(self, Rect2(x + 28.0, y + 10.0, 130.0, 9.0), hp_val / hp_max_val, CBStyle.ACCENT_EMERALD, CBStyle.BG_DEEP)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(x + 154.0, y + 9.5, str(int(hp_max_val)), 0xFFFFFF, 0)

	var stats := [
		["ATTACK", int(GM.g.get("atk", 160)), CBStyle.ACCENT_ROSE],
		["DEFENSE", int(GM.g.get("def", 140)), CBStyle.ACCENT_CYAN],
		["SP.ATTACK", int(GM.g.get("sp_atk", 155)), CBStyle.ACCENT_INDIGO],
		["SP.DEFENSE", int(GM.g.get("sp_def", 56)), CBStyle.ACCENT_EMERALD],
		["SPIRIT", int(GM.g.get("spd", 185)), CBStyle.ACCENT_AMBER],
	]
	for i in stats.size():
		var sy := y + 28.0 + float(i) * 18.0
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
		draw_text_shadow(x + 10.0, sy, str(stats[i][0]), 0xF8FAFC, 0)
		CBStyle.draw_capsule_bar(self, Rect2(x + 68.0, sy + 2.0, 52.0, 6.0), clampf(float(stats[i][1]) / 450.0, 0.15, 1.0), stats[i][2], CBStyle.BG_DEEP)
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
		draw_text_shadow(x + 154.0, sy, str(stats[i][1]), 0x0B9EF5, 0)

	CBStyle.draw_hex_avatar(self, Vector2(x + 142.0, y + 128.0), 22.0, CBStyle.BORDER_GOLD, CBStyle.BG_DEEP)
	draw_sprite_ext("spr_Icons", pid, x + 142.0, y + YY + 124.0, -1.6, 1.6, 0.0, Color.WHITE, 1.0)
