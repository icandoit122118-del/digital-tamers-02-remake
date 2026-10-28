extends GMInstance
## obj_CurrentDigi (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 진화 트리 상단 코어 텔레메트리 헤더)


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	var pid: int = int(GM.g.get("partnerId", 5))
	var d_entry: Dictionary = GM.db["digimons"].get(str(pid), {})
	var p_name: String = str(d_entry.get("name", "Agumon"))
	var p_lv: int = int(GM.g.get("partnerLv", 28))
	var wins: int = int(GM.g.get("wins", 18))
	var total_b: int = maxi(1, int(GM.g.get("totalBattles", 20)))
	var win_ratio: int = int(round((float(wins) / float(total_b)) * 100.0))

	CBStyle.draw_vlink_panel(self, Rect2(x - 6.0, y + 2.0, 330.0, 74.0), CBStyle.BG_PANEL, CBStyle.BORDER_GOLD, 7.0, true)
	CBStyle.draw_hex_avatar(self, Vector2(x + 22.0, y + 38.0), 22.0, CBStyle.BORDER_CYAN, CBStyle.BG_DEEP)
	draw_sprite_ext("spr_Icons", pid, x + 22.0, y + 36.0, 1.5, 1.5, 0.0, Color.WHITE, 1.0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 54.0, y + 8.0, "%s  //  Lv.%d" % [p_name, p_lv], 0x0B9EF5, 0)

	draw_sprite("spr_EvoStage", clampi(int(GM.g.get("EvoStage", 2)), 0, 6), x + 190.0, y + 9.0)
	draw_sprite("spr_Family", pid % 8, x + 204.0, y + 5.0)
	draw_sprite("spr_ElemAttribute", pid % 10, x + 220.0, y + 5.0)
	draw_sprite("spr_Attribute", pid % 4, x + 236.0, y + 7.0)

	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 54.0, y + 28.0, "DR: 680   NS: 150   ME: 390", 0xF8FAFC, 0)
	draw_text_shadow(x + 54.0, y + 42.0, "NSp: 340  WG: 210   JT: 180", 0xF8FAFC, 0)
	draw_text_shadow(x + 54.0, y + 56.0, "DS: 120   VB: 420   DA: 260", 0xF8FAFC, 0)

	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(x + 314.0, y + 28.0, "BOND: 100%", 0x81B910, 0)
	draw_text_shadow(x + 314.0, y + 42.0, "AGE: -/50", 0xB8A394, 0)
	draw_text_shadow(x + 314.0, y + 56.0, "WIN RATE: %d%%" % win_ratio, 0x0B9EF5, 0)
