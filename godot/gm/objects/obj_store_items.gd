extends GMInstance
## obj_store_items (원작 gml_Object_obj_store_items_Draw_0.gml: 상점 판매 아이템 행)

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
	if sel_id == ID:
		draw_set_color(0xCE39FF)
		draw_rectangle(x - 5.0, y + 1.0, x + 189.0, y + 12.0, false)
	draw_set_color(0xFFFFFF)
	draw_self()
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x, y + 1.0, ItemName, 0xFFFFE7, 0x9C7342)
	draw_set_format("fnt_Text", 0xDDE105, 0, 2)
	draw_text_shadow(x + 190.0, y + 1.0, "%d B" % ItemPrice, 0xDDE105, 0)
