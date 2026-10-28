extends GMInstance
## obj_Unlock_TS_Button (원작 room_Tamer_Info -> room_Tamer_Skills 이동 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked and not GM.instance_exists("obj_Transition"):
		ImClicked = false
		GM.play_sound_fx("snd_Click02")
		GM.room_transition(5, "room_Tamer_Skills")
