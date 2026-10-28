extends GMInstance
## obj_MainButtons (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 하단 플로팅 모듈 독 & 우측 독립 출격 코어)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -1500
	z_index = GM.z_for_depth(depth)
	sprite_index = "spr_MainButtons_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_MainButtons_PTBR"
	_sync_pos()


func step() -> void:
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")
	sprite_index = "spr_MainButtons_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_MainButtons_PTBR"
	_sync_pos()


func _sync_pos() -> void:
	y = 248.0
	var idx := int(round(image_index))
	match idx:
		0: x = 10.0
		2: x = 73.0
		6: x = 136.0
		3: x = 199.0
		4: x = 262.0
		1: x = 325.0
		5: x = 446.0


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	if int(GM.g.get("EvoStage", 2)) == 0:
		GM.hatch_partner_egg()
	GM.play_sound_fx("snd_Click01")
	var idx := int(round(image_index))
	match idx:
		0:
			GM.room_transition(0, "room_DigiVice")
		1:
			GM.room_transition(0, "room_Loja")
		2:
			GM.g["BulkTraining"] = false
			GM.room_transition(0, "room_SelectTraining")
		3:
			GM.room_transition(0, "room_Evo_Select")
		4:
			GM.room_transition(0, "room_Database")
		5:
			GM.room_transition(0, "room_Select_Battle_Mode")
		6:
			GM.room_transition(0, "room_Battle_Items")


func draw() -> void:
	var idx := int(round(image_index))
	match idx:
		0:
			CBStyle.draw_dock_module(self, Rect2(x, y + 6.0, 59.0, 38.0), CBStyle.ACCENT_CYAN, "01", "V-LINK", 0, ImClicked)
		2:
			CBStyle.draw_dock_module(self, Rect2(x, y + 6.0, 59.0, 38.0), CBStyle.ACCENT_EMERALD, "02", "GYM", 1, ImClicked)
		6:
			CBStyle.draw_dock_module(self, Rect2(x, y + 6.0, 59.0, 38.0), CBStyle.ACCENT_AMBER, "03", "GEAR", 2, ImClicked)
		3:
			CBStyle.draw_dock_module(self, Rect2(x, y + 6.0, 59.0, 38.0), CBStyle.ACCENT_INDIGO, "04", "EVOLVE", 3, ImClicked)
		4:
			CBStyle.draw_dock_module(self, Rect2(x, y + 6.0, 59.0, 38.0), CBStyle.ACCENT_CYAN, "05", "ARCHIVE", 4, ImClicked)
		1:
			CBStyle.draw_dock_module(self, Rect2(x, y + 6.0, 59.0, 38.0), CBStyle.ACCENT_AMBER, "06", "MARKET", 5, ImClicked)
		5:
			# 우하단 독립된 대형 택티컬 출격 런처 (배틀 진입 버튼)
			var lr := Rect2(444.0, 248.0, 88.0, 46.0)
			CBStyle.draw_vlink_panel(self, lr, Color8(136, 19, 55, 242) if not ImClicked else CBStyle.BG_SLOT, CBStyle.ACCENT_ROSE, 8.0, true)
			CBStyle.draw_hex_avatar(self, Vector2(464.0, 271.0), 13.0, CBStyle.BORDER_GOLD, Color8(76, 5, 25, 255))
			draw_colored_polygon(PackedVector2Array([Vector2(461.0, 266.0), Vector2(469.0, 271.0), Vector2(461.0, 276.0)]), CBStyle.TEXT_BRIGHT)
			draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 0)
			draw_text_shadow(481.0, 265.0, "DIGITAL", 0x0B9EF5, 0)
			draw_text_shadow(481.0, 277.0, "SORTIE", 0xFFFFFF, 0)
