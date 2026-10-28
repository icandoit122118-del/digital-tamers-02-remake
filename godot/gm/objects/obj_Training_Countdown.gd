extends GMInstance
## obj_Training_Countdown (원작 room_Training 시작 카운트다운)

var _ticks := 0


func create() -> void:
	image_speed = 0.15
	_ticks = 0


func step() -> void:
	_ticks += 1
	if _ticks >= 30:
		instance_destroy()
