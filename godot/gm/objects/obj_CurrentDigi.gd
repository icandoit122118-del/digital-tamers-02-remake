extends GMInstance
## obj_CurrentDigi (원작 gml_Object_obj_CurrentDigi_Draw_0.gml 그대로 렌더링)


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	draw_self()
	var pid: int = int(GM.g.get("partnerId", 5))
	var p_lv: int = int(GM.g.get("partnerLv", 28))
	var wins: int = int(GM.g.get("wins", 18))
	var total_b: int = maxi(1, int(GM.g.get("totalBattles", 20)))
	var win_ratio: int = int(round((float(wins) / float(total_b)) * 100.0))

	draw_sprite("spr_Icons", pid, x + 16.0, y + 13.0)
	draw_set_format("fnt_Text", 0, 0, 2)
	draw_text_shadow(x + 115.0, y + 7.0, str(p_lv), 0xFFFFFF, 0)
	draw_text_shadow(x + 75.0, y + 29.0, "680", 0x05E1DD, 0)
	draw_text_shadow(x + 75.0, y + 45.0, "340", 0x05E1DD, 0)
	draw_text_shadow(x + 75.0, y + 61.0, "120", 0x05E1DD, 0)
	draw_text_shadow(x + 130.0, y + 29.0, "150", 0x05E1DD, 0)
	draw_text_shadow(x + 130.0, y + 45.0, "210", 0x05E1DD, 0)
	draw_text_shadow(x + 130.0, y + 61.0, "420", 0x05E1DD, 0)
	draw_text_shadow(x + 185.0, y + 29.0, "390", 0x05E1DD, 0)
	draw_text_shadow(x + 185.0, y + 45.0, "180", 0x05E1DD, 0)
	draw_text_shadow(x + 185.0, y + 61.0, "260", 0x05E1DD, 0)
	draw_text_shadow(x + 301.0, y + 45.0, "-/50", 0x05E1DD, 0)
	draw_text_shadow(x + 301.0, y + 61.0, "%d%%" % win_ratio, 0x05E1DD, 0)

	draw_sprite("spr_EvoStage", clampi(int(GM.g.get("EvoStage", 2)), 0, 6), x + 29.0, y + 9.0)
	draw_sprite("spr_Family", pid % 8, x + 39.0, y + 5.0)
	draw_sprite("spr_ElemAttribute", pid % 10, x + 53.0, y + 5.0)
	draw_sprite("spr_Attribute", pid % 4, x + 69.0, y + 7.0)
