extends GMInstance
## obj_ChooseEgg_HUD (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 10종 스타터 디지타마 인큐베이터 매트릭스)

var chosenEGG := -1
var EggName := ""


func create() -> void:
	image_speed = 0.0
	chosenEGG = -1
	var cols := [40.0, 114.0, 188.0, 262.0, 336.0]
	var rows := [71.0, 151.0]
	var idx := 0
	for r in rows.size():
		for c in cols.size():
			var egg := GM.instance_create(x + cols[c], y + rows[r], "obj_ChooseEgg")
			egg.vars["ID"] = idx
			egg.sprite_index = "spr_egg%02d" % (idx + 1)
			egg.depth = depth - 10
			idx += 1


func select_egg(id_val: int) -> void:
	chosenEGG = id_val
	var info: Dictionary = GM.STARTER_EGGS[clampi(id_val, 0, GM.STARTER_EGGS.size() - 1)]
	EggName = str(info["name"])
	GM.play_sound_fx("snd_Click01")
	GM.start_new_game_with_egg(id_val)
	GM.room_transition(5, "room_MainRoom")


func draw() -> void:
	# 상단 플로팅 인큐베이터 헤더
	CBStyle.draw_vlink_panel(self, Rect2(74.0, 6.0, 390.0, 24.0), CBStyle.BG_PANEL, CBStyle.BORDER_GOLD, 6.0, true)
	draw_set_format("fnt_MidText", 0xFFFFFF, 0, 1)
	draw_text_shadow(269.0, 12.0, "V-INCUBATOR // SELECT STARTER DIGITAMA", 0x0B9EF5, 0)

	# 메인 인큐베이션 챔버 패널
	CBStyle.draw_vlink_panel(self, Rect2(x - 4.0, y + 6.0, 384.0, 210.0), CBStyle.BG_DEEP, CBStyle.BORDER_CYAN, 10.0, true)
	var cols := [40.0, 114.0, 188.0, 262.0, 336.0]
	var rows := [71.0, 151.0]
	for r in rows.size():
		for c in cols.size():
			var cx: float = x + float(cols[c])
			var cy: float = y + float(rows[r])
			CBStyle.draw_hex_avatar(self, Vector2(cx, cy - 2.0), 26.0, CBStyle.BORDER_SUBTLE, CBStyle.BG_PANEL)

	# 하단 가이드 배지
	CBStyle.draw_vlink_panel(self, Rect2(64.0, 266.0, 410.0, 22.0), CBStyle.BG_PANEL, CBStyle.BORDER_SUBTLE, 5.0, false)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 1)
	draw_text_shadow(269.0, 272.0, "Tap any DigiTama Pod to initialize your V-Link Sanctuary!", 0x81B910, 0)
