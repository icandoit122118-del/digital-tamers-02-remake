extends GMInstance
## obj_TrainingBar_Full (원작 room_Training 하단 타이밍 게이지 바)

var _prog := 0.0


func create() -> void:
	image_speed = 0.0
	_prog = 0.0


func step() -> void:
	_prog = fmod(_prog + 0.035, 1.0)


func draw() -> void:
	draw_self()
	var px := x - 90.0 + _prog * 180.0
	draw_set_color(0xDDE105)
	draw_rectangle(px - 3.0, y - 10.0, px + 3.0, y + 10.0, false)
	draw_set_color(0xFFFFFF)
