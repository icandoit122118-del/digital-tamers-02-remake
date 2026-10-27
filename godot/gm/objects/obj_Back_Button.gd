extends GMInstance
## obj_Back_Button (우측 하단 Back 버튼)

var ImClicked := false
var BackRoom := "room_MainMenu"


func create() -> void:
	image_speed = 0.0
	ImClicked = false
	image_index = 0 if GM.g["Language"] == 0 else 1


func step() -> void:
	image_index = 0 if GM.g["Language"] == 0 else 1
	if vars.has("BackRoom"):
		BackRoom = str(vars["BackRoom"])


func mouse_left_pressed() -> void:
	image_blend = Color8(0x6A, 0x6A, 0x6A)
	ImClicked = true


func mouse_leave() -> void:
	image_blend = Color.WHITE
	ImClicked = false


func mouse_left_released() -> void:
	image_blend = Color.WHITE
	if ImClicked and GM.g["butCanClick"] and not GM.instance_exists("obj_Transition"):
		var target := str(vars.get("BackRoom", BackRoom))
		if target == "" or target == "-4":
			target = "room_MainMenu"
		GM.room_transition(0, target)
		GM.play_sound_fx("snd_ClickBack")
	ImClicked = false
