extends GMInstance
## obj_Intro_Connect (신규 게임 진입 시 연결 연출 -> 완료 후 obj_ChooseEgg_HUD 스타터 디지타마 선택창 생성)

var cont := 0


func create() -> void:
	image_speed = 0.0
	image_alpha = 0.0
	alarm[0] = 18
	cont = 0
	image_index = 0 if GM.g["Language"] == 0 else 2


func on_alarm(n: int) -> void:
	if n != 0:
		return
	if cont < 5:
		if image_alpha == 0.0:
			image_alpha = 1.0
			if cont < 2:
				cont += 1
				alarm[0] = 15
				GM.play_sound_fx("snd_warning02")
			else:
				alarm[0] = 35
				GM.play_sound_fx("snd_Message")
				cont = 5
				image_index = 1 if GM.g["Language"] == 0 else 3
		else:
			image_alpha = 0.0
			alarm[0] = 8
	else:
		GM.play_music("BGM_Intro_music")
		if not GM.instance_exists("obj_ChooseEgg_HUD"):
			GM.instance_create(33.0, 35.0, "obj_ChooseEgg_HUD")
		instance_destroy()


func global_left_released() -> void:
	if not GM.instance_exists("obj_ChooseEgg_HUD"):
		GM.play_music("BGM_Intro_music")
		GM.instance_create(33.0, 35.0, "obj_ChooseEgg_HUD")
		instance_destroy()
