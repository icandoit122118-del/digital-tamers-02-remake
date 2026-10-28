extends GMInstance
## obj_BuyButton (원작 room_Loja 아이템 구매 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


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
	var sel_id := 1
	for inst in GM.instances:
		if inst.obj_name == "obj_item_info" and not inst.dead:
			sel_id = int(inst.get("Iam"))
			break
	var it: Dictionary = GM.db["items"].get(str(sel_id), {})
	var price: int = maxi(100, int(it.get("price", 250)))
	if int(GM.g.get("bits", 24500)) >= price:
		GM.g["bits"] = int(GM.g.get("bits", 24500)) - price
		GM.g["equippedItem"] = sel_id
		GM.play_sound_fx("snd_buy")
