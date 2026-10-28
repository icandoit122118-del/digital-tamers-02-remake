extends GMInstance
## obj_MainHUD (원작 gml_Object_obj_MainHUD_Draw_0.gml: 좌상단 파트너 상태 바 & 클릭 시 obj_Digi_Info 열기)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -1000
	# 원작 상점 버튼(image_index=1)이 rooms.json에 누락된 경우 자동 보강
	var has_shop_btn := false
	for inst in GM.instances:
		if inst.obj_name == "obj_MainButtons" and int(inst.image_index) == 1:
			has_shop_btn = true
			break
	if not has_shop_btn and GM.room_name == "room_MainRoom":
		var sb := GM.instance_create(330.0, 248.0, "obj_MainButtons")
		sb.image_index = 1


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
	var pid: int = int(GM.g.get("partnerId", 5))
	var d_entry: Dictionary = GM.db["digimons"].get(str(pid), {})
	var p_name: String = str(d_entry.get("name", "Greymon"))
	if int(GM.g.get("EvoStage", 2)) == 0:
		p_name = "DigiTama"
	var p_lv: int = int(GM.g.get("partnerLv", 28))
	var evo_stage: int = int(GM.g.get("EvoStage", 2))

	draw_sprite_ext("spr_MainHUD", 0, 0.0, 0.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_MainHUD_Lv_Symbol", int(GM.g.get("Language", 0)), 290.0, 5.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Icons", pid, 30.0, 23.0, 2.0, 2.0, 0.0, Color.WHITE, 1.0)

	draw_set_format("fnt_Text", 0, 0, 0)
	draw_text(82.0, 5.0, p_name)
	draw_set_color(0xDDE105)
	draw_text(81.0, 4.0, p_name)

	draw_sprite_ext("spr_EvoStage", clampi(evo_stage, 0, 6), 237.0, 7.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Family", pid % 8, 247.0, 3.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_ElemAttribute", pid % 10, 261.0, 3.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Attribute", pid % 4, 277.0, 5.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)

	draw_set_format("fnt_Text", 0, 0, 2)
	draw_text(323.0, 5.0, str(p_lv))
	draw_set_color(0xFFFFFF)
	draw_text(322.0, 4.0, str(p_lv))

	# 우측 상단 보유 BIT 및 Tamer Level 표시
	draw_set_format("fnt_Text", 0xDDE105, 0, 2)
	draw_text_shadow(525.0, 6.0, "%d BIT | Tamer Lv.%d" % [int(GM.g.get("bits", 24500)), int(GM.g.get("tamerLv", 12))], 0xDDE105, 0)
