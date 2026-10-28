extends GMInstance
## obj_HunGear_03 (원작 gml_Object_obj_HunGear_03_Draw_0.gml: 월드맵 Utility Gear 슬롯)

var buttonX := 0.0
var YY := 0.0
var ID := 54
var FXs := "Reveals hidden items."
var img := 0
var scrollPerc := 0.0


func create() -> void:
	alarm[0] = 15
	alarm[1] = 5


func on_alarm(n: int) -> void:
	if n == 0:
		YY = -2.0 if YY == 0.0 else 0.0
		alarm[0] = 15
	elif n == 1:
		img = (img + 1) % 2
		alarm[1] = 5


func draw() -> void:
	draw_self()
	draw_sprite("spr_Scroll_Button", img, x + buttonX, y)
	draw_sprite("spr_Items", ID, x - 43.0, (y + YY) - 26.0)
	draw_set_format("fnt_Text", 0, 0, 0)
	draw_text(x - 72.0, y - 52.0, "Utility Gear")
	draw_set_color(0xFFFFFF)
	draw_text(x - 73.0, y - 53.0, "Utility Gear")
	draw_set_format("fnt_SmlText", 0, 0, 0)
	draw_text(x - 11.0, y - 49.0, FXs)
	draw_set_color(0xDDE105)
	draw_text(x - 12.0, y - 50.0, FXs)
	draw_set_format("fnt_Text", 0, 0, 2)
	draw_text(x - 10.0, y - 6.0, "x3")
	draw_set_color(0xFFFFFF)
	draw_text(x - 11.0, y - 7.0, "x3")
