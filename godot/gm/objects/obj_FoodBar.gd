extends GMInstance
## obj_FoodBar (원작 gml_Object_obj_FoodBar_Step_0.gml: 좌측 슬라이드 케어/음식 탭)

var XX := 0.0
var YY := 0.0
var Aberto := false
var Spd := 30.0
var ImClicked := false


func create() -> void:
	image_index = 0.0
	image_speed = 0.0
	XX = 0.0
	Aberto = false


func step() -> void:
	if not Aberto and XX > 0.0:
		XX = maxf(0.0, XX - Spd)
	elif Aberto and XX < 335.0:
		XX = minf(335.0, XX + Spd)
	image_index = 1.0 if XX >= 335.0 else 0.0
	x = xstart + XX


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked and not GM.instance_exists("obj_Transition"):
		ImClicked = false
		Aberto = not Aberto
		GM.play_sound_fx("snd_DigiPad_ON" if Aberto else "snd_DigiPad_OFF")
