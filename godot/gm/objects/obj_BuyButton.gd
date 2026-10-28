extends GMInstance
## obj_BuyButton (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — V-MARKET 구매 확정 캡슐 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	var sel_id := 1
	for inst in GM.instances:
		if inst.obj_name == "obj_item_info" and not inst.dead:
			sel_id = int(inst.get("Iam"))
			break
	var it: Dictionary = GM.db["items"].get(str(sel_id), {})
	var price: int = maxi(25, int(it.get("price", 25)))
	if int(GM.g.get("bits", 24500)) >= price:
		GM.g["bits"] = int(GM.g.get("bits", 24500)) - price
		GM.g["equippedItem"] = sel_id
		GM.play_sound_fx("snd_buy")


func draw() -> void:
	var br := Rect2(x - 46.0, y - 15.0, 92.0, 30.0)
	CBStyle.draw_vlink_panel(self, br, CBStyle.ACCENT_EMERALD if ImClicked else Color8(6, 95, 70, 245), CBStyle.BORDER_GOLD, 6.0, true)
	draw_set_format("fnt_Text", 0xFFFFFF, 1, 1)
	draw_text_shadow(x, y, "PURCHASE", 0xFFFFFF, 0x0B111E)
