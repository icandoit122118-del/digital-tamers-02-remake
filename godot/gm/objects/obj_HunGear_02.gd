extends GMInstance
## obj_HunGear_02 (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 월드맵 LURES 모듈)

var buttonX := 0.0
var YY := 0.0
var ID := 75
var FXs := "Attracts Dragon Digimon."
var img := 0
var scrollPerc := 0.0


func create() -> void:
	alarm[0] = 15


func on_alarm(n: int) -> void:
	if n == 0:
		YY = -2.0 if YY == 0.0 else 0.0
		alarm[0] = 15


func draw() -> void:
	var r := Rect2(x - 76.0, y - 58.0, 256.0, 62.0)
	CBStyle.draw_vlink_panel(self, r, CBStyle.BG_PANEL, CBStyle.ACCENT_CYAN, 6.0, true)
	CBStyle.draw_hex_avatar(self, Vector2(x - 44.0, y - 24.0), 20.0, CBStyle.ACCENT_CYAN, CBStyle.BG_DEEP)
	draw_sprite("spr_Items", ID, x - 44.0, (y + YY) - 24.0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x - 70.0, y - 54.0, "SIGNAL BEACON // LURES", 0xF8BD38, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(x + 174.0, y - 53.0, FXs, 0x0B9EF5, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(x - 16.0, y - 9.0, "x5", 0xFFFFFF, 0)
