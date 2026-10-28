extends GMInstance
## obj_DRod_Logo (DragonRod 부팅 로고 -> room_MainMenu 이동)

var imgAlpha := 0.0
var sob := true


func create() -> void:
	x = 269.0
	y = 150.0
	image_alpha = 0.0
	imgAlpha = 0.0
	sob = true
	alarm[0] = 60


func on_alarm(n: int) -> void:
	if n == 0:
		sob = false
		alarm[1] = 45
	elif n == 1:
		GM.room_transition(5, "room_MainMenu")


func step() -> void:
	if sob and imgAlpha < 1.0:
		imgAlpha = minf(1.0, imgAlpha + 0.03)
	elif not sob and imgAlpha > 0.0:
		imgAlpha = maxf(0.0, imgAlpha - 0.03)
	image_alpha = imgAlpha


func global_left_released() -> void:
	GM.room_transition(5, "room_MainMenu")
