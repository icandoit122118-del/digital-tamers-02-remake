extends GMInstance
## obj_Long_Buttons (원작 gml_Object_obj_Long_Buttons_Mouse_7.gml: 디지바이스/진화/도감/배틀아이템 긴 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	sprite_index = "spr_Long_Button_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_Long_Button_PTBR"


func step() -> void:
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")
	sprite_index = "spr_Long_Button_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_Long_Button_PTBR"


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click02")
	var idx := int(round(image_index))
	match idx:
		0: GM.room_transition(5, "room_SelectDigi")
		1: GM.room_transition(5, str(GM.g.get("LastEquipRoom", "room_PowerUpItems")))
		2: GM.room_transition(5, "room_Inventory")
		3: GM.room_transition(5, str(GM.g.get("BiosLastPage", "room_Bios_Rookie")))
		4: GM.room_transition(5, "room_Achievements")
		5: GM.room_transition(5, "room_Tamer_Info")
		6: GM.room_transition(5, "room_Evolution")
		7: GM.room_transition(5, "room_Jogress")
		8: GM.room_transition(5, "room_Deco_BG")
		9: GM.room_transition(5, "room_Leader_Select")
		10: GM.room_transition(5, "room_Special_Food")
		11: GM.room_transition(5, "room_Equipments")
		12: GM.room_transition(5, "room_PowerUpItems")
		13: GM.room_transition(5, "room_options")
		14: GM.room_transition(5, "room_Quest_Log")
		15: GM.room_transition(5, "room_Leader_Cartridges")


func draw() -> void:
	draw_self()
	if ImClicked:
		draw_sprite("spr_Long_Button_SEL", 0, x, y)
