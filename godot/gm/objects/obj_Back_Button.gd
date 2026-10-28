extends GMInstance
## obj_Back_Button (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 우하단 플로팅 'RETURN' 캡슐 버튼)

var ImClicked := false
var BackRoom := "room_MainMenu"


func create() -> void:
	image_speed = 0.0
	ImClicked = false
	depth = -2000


func step() -> void:
	if vars.has("BackRoom"):
		BackRoom = str(vars["BackRoom"])


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked and GM.g["butCanClick"] and not GM.instance_exists("obj_Transition"):
		var target := str(vars.get("BackRoom", BackRoom))
		if target == "" or target == "-4":
			target = "room_MainMenu"
		GM.room_transition(0, target)
		GM.play_sound_fx("snd_ClickBack")
	ImClicked = false


func draw() -> void:
	var br := Rect2(x - 6.0, y - 2.0, 56.0, 22.0)
	CBStyle.draw_vlink_panel(self, br, CBStyle.BG_SLOT if ImClicked else CBStyle.BG_PANEL, CBStyle.ACCENT_ROSE, 5.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(br.position.x + 12.0, br.position.y + 7.0), Vector2(br.position.x + 7.0, br.position.y + 11.0), Vector2(br.position.x + 12.0, br.position.y + 15.0)]), CBStyle.ACCENT_ROSE)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(br.position.x + 33.0, br.position.y + 11.0, "RETURN", 0xFFFFFF, 0)
