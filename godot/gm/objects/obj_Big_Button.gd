extends GMInstance
## obj_Big_Button (원작 gml_Object_obj_Big_Button_Mouse_7.gml: 4대 배틀 모드 선택 카드)

var ImClicked := false
var MyRoom := "room_Select_Map"
var color := 8816262
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
	color = 4522223


func mouse_leave() -> void:
	ImClicked = false
	color = 8816262


func mouse_left_released() -> void:
	color = 8816262
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
	draw_set_color(color)
	draw_rectangle(x - 47.0, y - 80.0, x + 47.0, y + 80.0, false)
	draw_set_color(0xFFFFFF)
	draw_self()
