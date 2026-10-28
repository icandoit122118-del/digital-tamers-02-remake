extends GMInstance
## obj_FoodSlot (원작 gml_Object_obj_FoodSlot_Draw_0.gml: 좌측 케어 슬롯 — 고기, 버섯, 비타민, 약, 붕대, 청소)

var ID := 1
var XX := -136.0
var YY := 69.0
var imgInd := 0
var Selected := false
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	_sync_vars()


func step() -> void:
	_sync_vars()
	var bar_xx := 0.0
	for inst in GM.instances:
		if inst.obj_name == "obj_FoodBar" and not inst.dead:
			bar_xx = float(inst.get("XX"))
			break
	x = XX + bar_xx
	y = YY


func _sync_vars() -> void:
	if vars.has("ID"):
		ID = int(vars["ID"])
	if vars.has("XX"):
		XX = float(vars["XX"])
	if vars.has("YY"):
		YY = float(vars["YY"])
	if vars.has("imgInd"):
		imgInd = int(vars["imgInd"])


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	Selected = not Selected
	GM.play_sound_fx("snd_Click01")
	if ID == 10:
		GM.care_action("clean")
	elif ID == 11 or ID == 12:
		GM.care_action("bandage")
	elif ID == 3 or ID == 4 or ID == 13 or ID == 57:
		GM.care_action("vitamin")
	elif ID == 56:
		GM.care_action("sleep")
	else:
		GM.care_action("food")


func draw() -> void:
	draw_sprite_ext("spr_Food_Slot", imgInd, x, y, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	if ID == 56:
		draw_sprite_ext("spr_Ball", 0, x, y, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	else:
		draw_sprite_ext("spr_Items", ID, x, y, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	if Selected:
		draw_sprite_ext("spr_Food_Slot", 1, x, y, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	if ID != 10 and ID != 56:
		draw_set_format("fnt_Text", 0xFFFFFF, 0, 2)
		draw_text_shadow(x + 15.0, y + 4.0, "x9", 0xFFFFFF, 0)
