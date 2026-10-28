extends GMInstance
## obj_item_info (원작 gml_Object_obj_item_info_Draw_0.gml: 상점 좌측 선택 아이템 상세 창)

var Iam := 1
var ItemPrice := 25
var YY := 0.0


func create() -> void:
	image_speed = 0.0
	Iam = 1


func draw() -> void:
	draw_self()
	var it: Dictionary = GM.db["items"].get(str(Iam), {})
	var lang: int = int(GM.g.get("Language", 0))
	var i_name: String = str(it.get("name_pt" if lang == 1 else "name", "Small Meat"))
	var i_desc: String = str(it.get("desc_pt" if lang == 1 else "desc", "Restores hunger."))
	ItemPrice = maxi(25, int(it.get("price", 25)))

	draw_set_format("fnt_Text", 0, 0, 0)
	draw_text(x + 9.0, y + 6.0, i_name)
	draw_set_color(0xE7FFFF)
	draw_text(x + 8.0, y + 5.0, i_name)

	draw_set_color(0xFFFFFF)
	draw_text(x + 16.0, y + 33.0, i_desc.substr(0, 32))
	if i_desc.length() > 32:
		draw_text(x + 16.0, y + 45.0, i_desc.substr(32, 32))

	if Iam > 0:
		draw_sprite("spr_Items", Iam, 90.0, 157.0 + YY)
		draw_set_format("fnt_Text", 0xE7FFFF, 0, 2)
		draw_text_shadow(x + 176.0, y + 134.0, "Has: 9", 0xE7FFFF, 0)

	var money: int = int(GM.g.get("bits", 24500))
	draw_set_format("fnt_Text", 0xE7FFFF, 0, 2)
	draw_text_shadow(517.0, 16.0, str(money), 0xE7FFFF, 0x9C7342)

	draw_set_format("fnt_BigText", 0xFFFFE7, 1, 1)
	draw_text_shadow(144.0, 210.0, "1", 0xFFFFE7, 0x9C7342)

	draw_set_format("fnt_Text", 0xFFFFE7, 0, 2)
	draw_text_shadow(116.0, 245.0, str(ItemPrice), 0xFFFFE7, 0x9C7342)
