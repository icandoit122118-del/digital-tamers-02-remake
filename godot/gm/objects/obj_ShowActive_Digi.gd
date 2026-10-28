extends GMInstance
## obj_ShowActive_Digi (원작 room_SelectDigi 디지몬 보관함의 현재 파트너 표시)


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	draw_self()
	var pid: int = int(GM.g.get("partnerId", 5))
	var d_entry: Dictionary = GM.db["digimons"].get(str(pid), {})
	var d_name: String = str(d_entry.get("name", "Greymon"))
	draw_sprite_ext("spr_Icons", pid, x + 48.0, y + 54.0, 2.0, 2.0, 0.0, Color.WHITE, 1.0)
	draw_set_format("fnt_Text", 0xDDE105, 0, 0)
	draw_text_shadow(x + 14.0, y + 88.0, "%s (Lv.%d)" % [d_name, int(GM.g.get("partnerLv", 28))], 0xDDE105, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 14.0, y + 106.0, "ATK %d / DEF %d" % [int(GM.g.get("atk", 384)), int(GM.g.get("def", 310))], 0xFFFFFF, 0)
