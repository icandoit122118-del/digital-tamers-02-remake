extends GMInstance
## obj_Adv_Menu_Button (원작 room_Adventure_Mode_Start 어드벤처 모드 시작 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click06")
	var stg: int = maxi(1, int(GM.g.get("adventureStage", 1)))
	GM.g["battleMode"] = "adventure"
	GM.g["isAdventureMode"] = true
	GM.start_stage_battle(85, 22 + stg * 6, "Adventure Stage %d" % stg, "bg_Btl_Boot_Jungle")
