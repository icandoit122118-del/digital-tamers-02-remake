extends GMInstance
## obj_MainMenu_Buttons (New Game / Continue / Options 버튼)

var ImClicked := false
var ShowColor := false
var color := 4522223


func create() -> void:
	image_speed = 0.0
	ImClicked = false
	ShowColor = false
	if GM.g["Language"] == 0 and sprite_index == "":
		sprite_index = "spr_MainMenu_Buttons"


func mouse_left_pressed() -> void:
	if not GM.instance_exists("obj_Transition"):
		ImClicked = true
		ShowColor = true


func mouse_leave() -> void:
	ShowColor = false
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ShowColor = false
	ImClicked = false
	GM.play_sound_fx("snd_Click06")
	if sprite_index == "spr_MainMenu_Buttons":
		if int(image_index) == 0:
			GM.room_transition(5, "room_Intro_Screen")
		elif int(image_index) == 1:
			GM.room_transition(0, "room_MainRoom")
	elif sprite_index == "spr_MenuOptions_Button":
		GM.room_transition(0, "room_options_MainMenu")


func draw() -> void:
	draw_set_color(color)
	if ShowColor and sprite_index == "spr_MainMenu_Buttons":
		draw_rectangle(x + 214, y + 7, x + 327, y + 17, false)
	draw_set_color(16777215)
	draw_self()
