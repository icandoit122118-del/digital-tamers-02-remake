extends GMInstance
## obj_Big_Button (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 4대 출격 모드 버티컬 홀로-배너)

var ImClicked := false
var MyRoom := "room_Select_Map"
var CanGo := true


func create() -> void:
	image_speed = 0.0
	sprite_index = "spr_Big_Buttons_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_Big_Buttons_PTBR"
	if vars.has("MyRoom"):
		MyRoom = str(vars["MyRoom"])


func step() -> void:
	if vars.has("MyRoom"):
		MyRoom = str(vars["MyRoom"])
	sprite_index = "spr_Big_Buttons_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_Big_Buttons_PTBR"


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	if CanGo:
		GM.play_sound_fx("snd_Click06")
		var target := str(vars.get("MyRoom", MyRoom))
		if target == "room_Select_Map":
			GM.g["battleMode"] = "world"
		elif target == "room_Select_Challenge":
			GM.g["battleMode"] = "challenge"
		elif target == "room_Infinity_Mode":
			GM.g["battleMode"] = "infinity"
			GM.g["isInfinityMode"] = true
		elif target == "room_Adventure_Mode_Start":
			GM.g["battleMode"] = "adventure"
			GM.g["isAdventureMode"] = true
		GM.room_transition(5, target)


func draw() -> void:
	var target := str(vars.get("MyRoom", MyRoom))
	var accent := CBStyle.ACCENT_CYAN
	var title := "DIGITAL WORLD"
	var sub := "FREE EXPEDITION"
	if target == "room_Select_Challenge":
		accent = CBStyle.ACCENT_AMBER
		title = "COLOSSEUM"
		sub = "TAMER CHALLENGE"
	elif target == "room_Infinity_Mode":
		accent = CBStyle.ACCENT_INDIGO
		title = "INFINITY TOWER"
		sub = "ENDLESS BOSS RUSH"
	elif target == "room_Adventure_Mode_Start":
		accent = CBStyle.ACCENT_ROSE
		title = "CAMPAIGN"
		sub = "ADVENTURE STORY"

	var br := Rect2(x - 52.0, y - 92.0, 104.0, 184.0)
	CBStyle.draw_vlink_panel(self, br, CBStyle.BG_PANEL if not ImClicked else CBStyle.BG_SLOT, accent, 8.0, true)
	# 중앙 원본 일러스트 크롭/표시
	draw_self()
	# 하단 V-LINK 캡슐 타이틀 오버레이
	var cap_r := Rect2(x - 48.0, y + 48.0, 96.0, 38.0)
	CBStyle.draw_vlink_panel(self, cap_r, CBStyle.BG_DEEP, accent, 5.0, false)
	draw_set_format("fnt_Text", 0xFFFFFF, 1, 1)
	draw_text_shadow(x, y + 61.0, title, 0xFFFFFF, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(x, y + 75.0, sub, 0x0B9EF5, 0)
