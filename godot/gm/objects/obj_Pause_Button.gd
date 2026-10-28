extends GMInstance
## obj_Pause_Button (원작 room_Battle 하단 중앙 일시정지/귀환 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -2100


func mouse_left_pressed() -> void:
	ImClicked = true
	image_blend = Color8(0xA0, 0xA0, 0xA0)


func mouse_leave() -> void:
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	image_blend = Color.WHITE
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click05")
	GM.room_transition(0, "room_MainRoom")
