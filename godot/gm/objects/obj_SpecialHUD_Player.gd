extends GMInstance
## obj_SpecialHUD_Player (원작 gml_Object_obj_SpecialHUD_Player_Draw_0.gml: 좌하단 SP 바 & Block 바)


func create() -> void:
	image_speed = 0.0
	depth = -2000


func draw() -> void:
	var sp_ratio: float = clampf(float(GM.battle.get("p_sp", 45.0)) / 100.0, 0.0, 1.0)
	var blk_ratio: float = clampf(float(GM.battle.get("p_block", 100.0)) / 100.0, 0.0, 1.0)
	draw_sprite_ext("spr_SpecialBar", 0, x + 240.0, y + 50.0, -sp_ratio, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_ShieldBar", 0, x + 70.0, y + 42.0, blk_ratio, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite(sprite_index, 0, x, y)
