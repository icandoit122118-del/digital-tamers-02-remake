extends GMInstance
## obj_Transition 포팅 (Create / Step_1 / Draw_64). GUI 레이어에서 그려진다.

var type := 0
var target := ""
var width := 1096.0
var height := 620.0
var height_half := 0.0
var width_half := 0.0
var percent := 0.0
var leading := 0
var trans_speed := 0.08
var color_white := Color.WHITE
var _on_gui := true


func create() -> void:
	persistent = true
	height_half = (height * 0.5) + (height * 0.3)
	width_half = (width * 0.5) + (height * 0.3)
	color_white = Color.WHITE if GM.g["ExtraVAR"][4] == 0 else Color.BLACK


func step() -> void:
	if leading == 0:
		percent = minf(1.0, percent + trans_speed)
		if percent >= 1.0:
			GM.g["scrollPerc"] = 0
			if target != "":
				GM.room_goto(target)
			leading = 1
			if type == 5:
				type = 8
	else:
		percent = maxf(0.0, percent - trans_speed)
		if percent <= 0.0:
			instance_destroy()


func draw() -> void:
	var black := Color.BLACK
	match type:
		0:
			draw_rect(Rect2(-5, -5, width + 5, percent * height_half + 5), black)
			draw_rect(Rect2(-5, height - percent * height_half, width + 5, percent * height_half), black)
		1:
			draw_rect(Rect2(-5, -5, width + 5, height + 5), Color(0, 0, 0, clampf(percent * 1.5, 0, 1)))
		2:
			trans_speed = 0.08
			draw_rect(Rect2(0, 0, width, height), Color(color_white, clampf(percent * 1.5, 0, 1)))
		3:
			trans_speed = 0.01
			draw_rect(Rect2(0, 0, width, height), Color(color_white, clampf(percent * 1.5, 0, 1)))
		4:
			trans_speed = 0.01
			draw_circle(Vector2(x, y), percent * height * 2.0, color_white)
		5:
			trans_speed = 0.06
			draw_sprite_stretched("spr_Battle_Transition", int(percent * 12.0), 0, 0, width, height, Color.WHITE, 1.0)
			draw_rect(Rect2(-5, -5, width + 5, height + 5), Color(color_white, clampf(percent * 1.5, 0, 1)))
		6:
			trans_speed = 0.06
			draw_sprite_stretched("spr_Gate", int(percent * 12.0), 0, 0, width, height, Color.WHITE, 1.0)
		7:
			draw_rect(Rect2(-5, -5, percent * width_half + 5, height + 5), black)
			draw_rect(Rect2(width - percent * width_half, -5, percent * width_half, height + 5), black)
		8:
			draw_rect(Rect2(-5, -5, width + 5, height + 5), Color(color_white, clampf(percent * 1.5, 0, 1)))
