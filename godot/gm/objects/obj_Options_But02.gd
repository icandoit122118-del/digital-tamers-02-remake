extends GMInstance
## obj_Options_But02 (옵션 우측 On/Off 스위치)

var ImClicked := false
var iAm := -4
var Text := "On"
var _switch := 0


func create() -> void:
	image_speed = 0.0


func step() -> void:
	if vars.has("iAm"):
		iAm = int(vars["iAm"])
	if iAm == 7:
		instance_destroy()
		return
	var on := true
	match iAm:
		1: on = bool(GM.g["music"])
		2: on = bool(GM.g["soundFX"])
		3: on = bool(GM.g["DigimonVoice"])
		6: on = int(GM.g["ExtraVAR"][1]) == 0
		8: on = int(GM.g["ExtraVAR"][4]) == 0
		9: on = int(GM.g["ExtraVAR"][5]) == 1
	Text = "On" if on else "Off"
	_switch = 0 if on else 1


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	y = ystart
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked and not GM.instance_exists("obj_Transition"):
		match iAm:
			1:
				GM.g["music"] = not bool(GM.g["music"])
				if not GM.g["music"]:
					GM.audio_stop_all()
				else:
					GM.play_music("BGM_Lab")
			2:
				GM.g["soundFX"] = not bool(GM.g["soundFX"])
			3:
				GM.g["DigimonVoice"] = not bool(GM.g["DigimonVoice"])
			6:
				GM.g["ExtraVAR"][1] = 1 - int(GM.g["ExtraVAR"][1])
			8:
				GM.g["ExtraVAR"][4] = 1 - int(GM.g["ExtraVAR"][4])
			9:
				GM.g["ExtraVAR"][5] = 1 - int(GM.g["ExtraVAR"][5])
		GM.play_sound_fx("snd_Click06")
	ImClicked = false


func draw() -> void:
	draw_set_format("fnt_Text", 16777215, 1, 0)
	draw_self()
	draw_text_shadow(x - 20, y + 1, Text, Color.WHITE, 0)
	draw_sprite("spr_switch", _switch, x + 12, y)
