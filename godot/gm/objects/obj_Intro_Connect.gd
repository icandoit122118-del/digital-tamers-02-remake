extends GMInstance
## obj_Intro_Connect (신규 게임 진입 시 연결 연출)

var cont := 0


func create() -> void:
	image_speed = 0.0
	image_alpha = 0.0
	alarm[0] = 45
	cont = 0
	image_index = 0 if GM.g["Language"] == 0 else 2


func on_alarm(n: int) -> void:
	if n != 0:
		return
	if cont < 5:
		if image_alpha == 0.0:
			image_alpha = 1.0
			if cont < 3:
				cont += 1
				alarm[0] = 30
				GM.play_sound_fx("snd_warning02")
			else:
				alarm[0] = 90
				GM.play_sound_fx("snd_Message")
				cont = 5
				image_index = 1 if GM.g["Language"] == 0 else 3
		else:
			image_alpha = 0.0
			alarm[0] = 12
	else:
		instance_destroy()
		GM.play_music("BGM_Intro_music")
