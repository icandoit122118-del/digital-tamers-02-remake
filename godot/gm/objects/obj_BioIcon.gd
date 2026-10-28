extends GMInstance
## obj_BioIcon (원작 room_Bios_* 좌측 도감 디지몬 아이콘 슬롯)

var ID := 1
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	if vars.has("ID"):
		ID = int(vars["ID"])
	elif vars.has("image_index"):
		ID = int(vars["image_index"])
	else:
		ID = clampi((int(x) / 32) + (int(y) / 32) * 6, 1, 663)


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	GM.g["partnerId"] = clampi(ID, 1, 663)
	GM.init_battle_state()
	for inst in GM.instances:
		if inst.obj_name == "obj_Bios" and not inst.dead:
			inst.set("selected_id", clampi(ID, 1, 663))
			break


func draw() -> void:
	if y < 24.0 or y > 272.0:
		return
	draw_sprite("spr_Icons", clampi(ID, 1, 663), x, y)
