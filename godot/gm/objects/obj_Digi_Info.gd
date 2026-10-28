extends GMInstance
## obj_Digi_Info (원작 gml_Object_obj_Digi_Info_Draw_0.gml: 파트너 상세 스탯 슬라이드 패널)

var YY := 0.0
var Spd := 25.0
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	YY = 207.0 if bool(GM.g.get("StatsAberto", false)) else 0.0


func step() -> void:
	var open := bool(GM.g.get("StatsAberto", false))
	if not open and YY > 0.0:
		YY = maxf(0.0, YY - Spd)
	elif open and YY < 207.0:
		YY = minf(207.0, YY + Spd)
	image_index = (1 if YY >= 207.0 else 0) + (2 if int(GM.g.get("Language", 0)) == 1 else 0)
	x = 377.0
	y = -(201.0 - YY)


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked:
		ImClicked = false
		GM.g["StatsAberto"] = not bool(GM.g.get("StatsAberto", false))
		GM.play_sound_fx("snd_DigiPad_ON" if bool(GM.g["StatsAberto"]) else "snd_DigiPad_OFF")


func draw() -> void:
	var py := -(201.0 - YY)
	draw_sprite_ext(sprite_index, int(image_index), 377.0, py, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	var hp_val: float = float(GM.g.get("hp", 2200))
	var hp_max_val: float = maxf(1.0, float(GM.g.get("hp_max", 2200)))
	var xp_val: float = float(GM.g.get("xp", 74))
	var xp_max_val := 100.0
	draw_sprite_ext("spr_HP_XP_bars", 0, 400.0, py + 9.0, clampf(hp_val / hp_max_val, 0.0, 1.0), 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_HP_XP_bars", 1, 400.0, py + 25.0, clampf(xp_val / xp_max_val, 0.0, 1.0), 1.0, 0.0, Color.WHITE, 1.0)

	var hunger_val: int = int(GM.g.get("hunger", 82))
	var hunger_txt := "Satisfied" if hunger_val >= 60 else ("Hungry" if hunger_val >= 30 else "Starving!")
	var health_txt := "Healthy" if int(GM.g.get("injury", 0)) == 0 else "Hurt"
	var en_val: int = int(GM.g.get("en", 100))
	var en_txt := "Full Energy!" if en_val >= 100 else ("%d/100" % en_val)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 2)
	draw_text_shadow(529.0, py + 13.0, "%d/%d" % [int(hp_val), int(hp_max_val)], 0xFFFFFF, 0)
	draw_text_shadow(529.0, py + 30.0, "%d/100" % int(xp_val), 0xFFFFFF, 0)
	draw_text_shadow(496.0, py + 43.0, str(GM.g.get("atk", 384)), 0xDDE105, 0)
	draw_text_shadow(496.0, py + 59.0, str(GM.g.get("def", 310)), 0xDDE105, 0)
	draw_text_shadow(496.0, py + 75.0, str(GM.g.get("sp_atk", 340)), 0xDDE105, 0)
	draw_text_shadow(496.0, py + 91.0, str(GM.g.get("sp_def", 290)), 0xDDE105, 0)
	draw_text_shadow(496.0, py + 107.0, str(GM.g.get("spd", 265)), 0xDDE105, 0)
	draw_text_shadow(529.0, py + 139.0, "-", 0xFFFFFF, 0)
	draw_text_shadow(529.0, py + 155.0, hunger_txt, 0xFFFFFF, 0)
	draw_text_shadow(529.0, py + 171.0, health_txt, 0xFFFFFF, 0)
	draw_text_shadow(529.0, py + 187.0, en_txt, 0xFFFFFF, 0)
