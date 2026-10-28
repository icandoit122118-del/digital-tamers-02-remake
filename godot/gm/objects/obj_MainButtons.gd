extends GMInstance
## obj_MainButtons (원작 gml_Object_obj_MainButtons_Mouse_7.gml: 하단 7개 메인 아이콘 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
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
		0: x = 5.0
		2: x = 70.0
		6: x = 135.0
		3: x = 200.0
		4: x = 265.0
		1: x = 330.0
		5: x = 469.0


func mouse_left_pressed() -> void:
	ImClicked = true
	image_blend = Color8(0xB0, 0xB0, 0xB0)


func mouse_leave() -> void:
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	image_blend = Color.WHITE
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
