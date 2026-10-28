extends GMInstance
## obj_Top_Hud (원작 gml_Object_obj_Top_Hud_Draw_0.gml: 상단 양측 체력바·아이콘·속성·레벨 HUD)


func create() -> void:
	image_speed = 0.0
	depth = -2000


func draw() -> void:
	var b: Dictionary = GM.battle
	var p_hp: float = clampf(float(b.get("p_hp", 2200)), 0.0, float(b.get("p_hp_max", 2200)))
	var p_hp_max: float = maxf(1.0, float(b.get("p_hp_max", 2200)))
	var e_hp: float = clampf(float(b.get("e_hp", 2800)), 0.0, float(b.get("e_hp_max", 2800)))
	var e_hp_max: float = maxf(1.0, float(b.get("e_hp_max", 2800)))

	var pid: int = int(b.get("p_id", 5))
	var eid: int = int(b.get("e_id", 87))
	var p_name: String = str(b.get("p_name", "Greymon"))
	var e_name: String = str(b.get("e_name", "SkullGreymon"))
	var p_lv: int = int(b.get("p_lv", 28))
	var e_lv: int = int(b.get("e_lv", 32))

	var is_inf := bool(GM.g.get("isInfinityMode", false))
	draw_sprite("spr_Btl_HealthBars", 1 if is_inf else 0, x, y)
	draw_sprite_ext("spr_Btl_HealthBar", 0, x + 50.0, y + 14.0, p_hp / p_hp_max, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Btl_HealthBar", 0, x + 488.0, y + 14.0, -(e_hp / e_hp_max), 1.0, 0.0, Color.WHITE, 1.0)

	draw_sprite("spr_Icons", pid, x + 32.0, y + 18.0)
	draw_sprite_ext("spr_Icons", eid, x + 506.0, y + 18.0, -1.0, 1.0, 0.0, Color.WHITE, 1.0)

	draw_sprite("spr_Family", pid % 8, x + 1.0, y + 2.0)
	draw_sprite("spr_EvoStage", clampi(int(GM.g.get("EvoStage", 2)), 0, 6), x + 4.0, y + 21.0)
	draw_sprite("spr_ElemAttribute", pid % 10, x + 13.0, y + 29.0)
	draw_sprite("spr_Attribute", pid % 4, x + 40.0, y + 31.0)

	draw_sprite("spr_Family", eid % 8, x + 522.0, y + 2.0)
	draw_sprite("spr_EvoStage", 3, x + 525.0, y + 21.0)
	draw_sprite("spr_ElemAttribute", eid % 10, x + 510.0, y + 29.0)
	draw_sprite("spr_Attribute", eid % 4, x + 487.0, y + 31.0)

	var s01 := 0 if float(b.get("p_atr_mod", 1.0)) > 1.0 else (1 if float(b.get("p_atr_mod", 1.0)) < 1.0 else 2)
	var s02 := 0 if float(b.get("e_atr_mod", 1.0)) > 1.0 else (1 if float(b.get("e_atr_mod", 1.0)) < 1.0 else 2)
	draw_sprite("spr_attri_Setas", s01, x + 28.0, y + 32.0)
	draw_sprite("spr_attri_Setas", s02, x + 499.0, y + 32.0)

	draw_set_format("fnt_Text", 0, 0, 0)
	draw_text(x + 52.0, y + 2.0, p_name)
	draw_set_color(0xFFFFFF)
	draw_text(x + 51.0, y + 1.0, p_name)

	draw_set_format("fnt_Text", 0, 0, 2)
	draw_text(x + 487.0, y + 1.0, e_name)
	draw_set_color(0xFFFFFF)
	draw_text(x + 488.0, y + 2.0, e_name)

	if is_inf:
		draw_set_format("fnt_Text", 0xFFFFFF, 1, 1)
		draw_text_shadow(269.0, 42.0, "Current Wave: %d" % int(GM.g.get("infinityFloor", 1)), 0xFFFFFF, 0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 53.0, y + 34.0, "L%d" % p_lv, 0xFFFFFF, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 2)
	draw_text_shadow(x + 485.0, y + 34.0, "L%d" % e_lv, 0xFFFFFF, 0)
