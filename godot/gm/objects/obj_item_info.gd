extends GMInstance
## obj_item_info (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — V-MARKET 좌측 홀로그램 아이템 인스펙터)

var Iam := 1
var ItemPrice := 25
var YY := 0.0


func create() -> void:
	image_speed = 0.0
	Iam = 1


func draw() -> void:
	var it: Dictionary = GM.db["items"].get(str(Iam), {})
	var lang: int = int(GM.g.get("Language", 0))
	var i_name: String = str(it.get("name_pt" if lang == 1 else "name", "Small Meat"))
	var i_desc: String = str(it.get("desc_pt" if lang == 1 else "desc", "Restores hunger."))
	ItemPrice = maxi(25, int(it.get("price", 25)))

	# 좌측 아이템 상세 캡슐 카드
	CBStyle.draw_vlink_panel(self, Rect2(x, y + 2.0, 186.0, 150.0), CBStyle.BG_PANEL, CBStyle.BORDER_CYAN, 8.0, true)
	CBStyle.draw_vlink_panel(self, Rect2(x + 6.0, y + 6.0, 174.0, 20.0), CBStyle.BG_SLOT, CBStyle.BORDER_GOLD, 4.0, false)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 14.0, y + 10.0, i_name, 0x0B9EF5, 0)

	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 12.0, y + 34.0, i_desc.substr(0, 34), 0xF8FAFC, 0)
	if i_desc.length() > 34:
		draw_text_shadow(x + 12.0, y + 46.0, i_desc.substr(34, 34), 0xF8FAFC, 0)

	# 중앙 헥사곤 아이템 쇼케이스 포드
	if Iam > 0:
		CBStyle.draw_hex_avatar(self, Vector2(x + 44.0, y + 108.0), 26.0, CBStyle.BORDER_GOLD, CBStyle.BG_DEEP)
		draw_sprite_ext("spr_Items", Iam, x + 44.0, y + 108.0 + YY, 1.5, 1.5, 0.0, Color.WHITE, 1.0)
		CBStyle.draw_vlink_panel(self, Rect2(x + 114.0, y + 124.0, 64.0, 18.0), CBStyle.BG_DEEP, CBStyle.BORDER_SUBTLE, 4.0, false)
		draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
		draw_text_shadow(x + 146.0, y + 133.0, "OWNED: 9", 0x81B910, 0)

	# 우상단 BIT 월렛 캡슐
	var money: int = int(GM.g.get("bits", 24500))
	CBStyle.draw_vlink_panel(self, Rect2(396.0, 6.0, 136.0, 24.0), CBStyle.BG_PANEL, CBStyle.BORDER_GOLD, 5.0, true)
	draw_set_format("fnt_Text", 0xFFFFFF, 1, 1)
	draw_text_shadow(464.0, 18.0, "%d BIT" % money, 0x0B9EF5, 0)

	# 수량 및 총액 표시
	CBStyle.draw_vlink_panel(self, Rect2(120.0, 194.0, 48.0, 30.0), CBStyle.BG_DEEP, CBStyle.BORDER_CYAN, 5.0, false)
	draw_set_format("fnt_BigText", 0xFFFFFF, 1, 1)
	draw_text_shadow(144.0, 209.0, "1", 0xFFFFFF, 0)

	CBStyle.draw_vlink_panel(self, Rect2(48.0, 232.0, 84.0, 32.0), CBStyle.BG_PANEL, CBStyle.BORDER_GOLD, 5.0, false)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(90.0, 240.0, "TOTAL COST", 0xB8A394, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 1, 1)
	draw_text_shadow(90.0, 253.0, "%d BIT" % ItemPrice, 0x0B9EF5, 0)
