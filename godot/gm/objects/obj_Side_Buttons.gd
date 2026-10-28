extends GMInstance
## obj_Side_Buttons (원작 room_MainRoom 우측 상단 카메라/바이옴/세이브 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func step() -> void:
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")


func mouse_left_pressed() -> void:
	ImClicked = true
	image_blend = Color8(0xA0, 0xA0, 0xA0)


func mouse_leave() -> void:
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	image_blend = Color.WHITE
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click04")
	var idx := int(round(image_index))
	if idx == 0:
		GM.g["sanctuaryThemeIdx"] = (int(GM.g.get("sanctuaryThemeIdx", 0)) + 1) % GMBackground.SANCTUARY_THEMES.size()
		GM.bg.setup(GM.room_data)
	elif idx == 1:
		GM.g["StatsAberto"] = not bool(GM.g.get("StatsAberto", false))
	elif idx == 2:
		GM.save_game_state()
