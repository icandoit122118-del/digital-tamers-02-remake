extends GMInstance
## obj_TrainingStats_HUD (원작 gml_Object_obj_TrainingStats_HUD_Draw_0.gml: 훈련 선택 화면 우측 파트너 스탯)

var YY := 0.0


func create() -> void:
	image_speed = 0.0


func draw() -> void:
	draw_self()
	var pid: int = int(GM.g.get("partnerId", 5))
	var hp_val: float = float(GM.g.get("hp", 2200))
	var hp_max_val: float = maxf(1.0, float(GM.g.get("hp_max", 2200)))
	draw_sprite_ext("spr_HP_XP_bars", 0, x + 24.0, y + 13.0, clampf(hp_val / hp_max_val, 0.0, 1.0), 1.0, 0.0, Color.WHITE, 1.0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 2)
	draw_text_shadow(x + 115.0, y + 19.0, str(int(hp_max_val)), 0xFFFFFF, 0)
	draw_set_format("fnt_Text", 0xDDE105, 0, 2)
	draw_text_shadow(x + 115.0, y + 31.0, str(GM.g.get("atk", 384)), 0xDDE105, 0)
	draw_text_shadow(x + 115.0, y + 47.0, str(GM.g.get("def", 310)), 0xDDE105, 0)
	draw_text_shadow(x + 115.0, y + 63.0, str(GM.g.get("sp_atk", 340)), 0xDDE105, 0)
	draw_text_shadow(x + 115.0, y + 79.0, str(GM.g.get("sp_def", 290)), 0xDDE105, 0)
	draw_text_shadow(x + 115.0, y + 95.0, str(GM.g.get("spd", 265)), 0xDDE105, 0)

	draw_sprite_ext("spr_Icons", pid, x + 142.0, y + YY + 122.0, -2.0, 2.0, 0.0, Color.WHITE, 1.0)
