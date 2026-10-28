extends GMInstance
## obj_Command_Button (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌하단 3대 택티컬 아츠 모듈)

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


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	var sk_idx := clampi(ID - 1, 0, 2)
	for inst in GM.instances:
		if inst.obj_name == "obj_Digi_Battle" and not inst.dead:
			inst._cast_skill(sk_idx, 1.0)
			break


func draw() -> void:
	var idx := clampi(ID - 1, 0, 2)
	var kx := 128.0 + float(idx) * 56.0
	var labels := ["STRIKE", "ASSAULT", "BLASTER"]
	var cols := [CBStyle.ACCENT_CYAN, CBStyle.ACCENT_EMERALD, CBStyle.ACCENT_INDIGO]
	var icons := [1, 2, 3]
	CBStyle.draw_dock_module(self, Rect2(kx, 254.0, 52.0, 38.0), cols[idx], "0%d" % (idx + 1), labels[idx], icons[idx], ImClicked)
