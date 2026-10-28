extends GMInstance
## obj_Command_Button (원작 하단 3개 커맨드 버튼 ID=1,2,3 -> 스킬 시전 및 오토배틀 전술 전환)

var ID := 1
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -2100
	if vars.has("ID"):
		ID = int(vars["ID"])
	image_index = float(clampi(ID - 1, 0, 2))


func step() -> void:
	if vars.has("ID"):
		ID = int(vars["ID"])
	image_index = float(clampi(ID - 1, 0, 2))


func mouse_left_pressed() -> void:
	ImClicked = true
	image_blend = Color8(0xB0, 0xB0, 0xB0)


func mouse_leave() -> void:
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	image_blend = Color.WHITE
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	var sk_idx := clampi(ID - 1, 0, 2)
	for inst in GM.instances:
		if inst.obj_name == "obj_Digi_Battle" and not inst.dead:
			inst._cast_skill(sk_idx, 1.0)
			break
