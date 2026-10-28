extends GMInstance
## obj_Training_Buttons (원작 gml_Object_obj_Training_Buttons_Mouse_7.gml: 7개 스탯 훈련 선택 버튼)

var MyTraining := 0
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	if vars.has("MyTraining"):
		MyTraining = int(vars["MyTraining"])


func step() -> void:
	if vars.has("MyTraining"):
		MyTraining = int(vars["MyTraining"])
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")


func mouse_left_pressed() -> void:
	ImClicked = true
	y = ystart + 2.0


func mouse_leave() -> void:
	ImClicked = false
	y = ystart


func mouse_left_released() -> void:
	y = ystart
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click06")
	GM.g["TraningWhat"] = int(vars.get("MyTraining", MyTraining))
	GM.room_transition(6, "room_Training")
