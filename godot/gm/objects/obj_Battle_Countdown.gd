extends GMInstance
## obj_Battle_Countdown (원작 room_Battle 시작 카운트다운 연출)

var _ticks := 0


func create() -> void:
	image_speed = 0.16
	depth = -2500
	_ticks = 0


func step() -> void:
	_ticks += 1
	if _ticks >= 32:
		instance_destroy()
