extends GMInstance
## obj_SpecialHUD_Enemy (원작 gml_Object_obj_SpecialHUD_Enemy_Draw_0.gml: 우하단 적 SP 바 & Block 바)


func create() -> void:
	image_speed = 0.0
	depth = -2000


func draw() -> void:
	var sp_ratio: float = clampf(float(GM.battle.get("e_sp", 30.0)) / 100.0, 0.0, 1.0)
	draw_sprite_ext("spr_SpecialBar", 0, x + 14.0, y + 50.0, sp_ratio, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_ShieldBar", 0, x + 184.0, y + 42.0, -1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite(sprite_index, 1, x, y)
