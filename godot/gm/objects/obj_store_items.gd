extends GMInstance
## obj_store_items (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — V-MARKET 우측 HD 아이템 카탈로그 행)

var ID := 1
var ItemName := "Small Meat"
var ItemPrice := 25
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	_sync_item()


func step() -> void:
	_sync_item()


func _sync_item() -> void:
	if vars.has("ID"):
		ID = int(vars["ID"])
	var it: Dictionary = GM.db["items"].get(str(ID), {})
	var lang: int = int(GM.g.get("Language", 0))
	ItemName = str(it.get("name_pt" if lang == 1 else "name", "Item %d" % ID))
	ItemPrice = maxi(25, int(it.get("price", 100)))


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	for inst in GM.instances:
		if inst.obj_name == "obj_item_info" and not inst.dead:
			inst.set("Iam", ID)
			inst.set("ItemPrice", ItemPrice)
			break


func draw() -> void:
	if y > 280.0:
		return
	var sel_id := 1
	for inst in GM.instances:
		if inst.obj_name == "obj_item_info" and not inst.dead:
			sel_id = int(inst.get("Iam"))
			break
	var is_sel := (sel_id == ID)
	var row_r := Rect2(x - 20.0, y, 214.0, 14.0)
	CBStyle.draw_vlink_panel(
		self,
		row_r,
		CBStyle.BG_SLOT if is_sel else CBStyle.BG_DEEP,
		CBStyle.BORDER_GOLD if is_sel else CBStyle.BORDER_SUBTLE,
		3.0,
		false
	)
	draw_sprite_stretched("spr_Items", ID, x - 16.0, y + 1.0, 12.0, 12.0, Color.WHITE, 1.0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 2.0, y + 1.5, ItemName, 0x0B9EF5 if is_sel else 0xF8FAFC, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 2)
	draw_text_shadow(x + 188.0, y + 1.5, "%d B" % ItemPrice, 0x81B910, 0)
