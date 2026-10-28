extends GMInstance
## obj_FoodSlot (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 나노-케어 2x HD 아이템 캡슐 슬롯)

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
	if x < -20.0:
		return
	var sr := Rect2(x - 13.0, y - 13.0, 26.0, 26.0)
	var bd_c := CBStyle.BORDER_GOLD if Selected else CBStyle.BORDER_SUBTLE
	var bg_c := CBStyle.BG_SLOT if Selected else CBStyle.BG_CARD
	CBStyle.draw_vlink_panel(self, sr, bg_c, bd_c, 3.5, false)
	if ID == 56:
		draw_sprite_ext("spr_Ball", 0, x, y, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	else:
		draw_sprite_ext("spr_Items", ID, x, y, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	if ID != 10 and ID != 56:
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
		draw_text_shadow(x + 12.0, y + 3.0, "x9", 0x0B9EF5, 0)
