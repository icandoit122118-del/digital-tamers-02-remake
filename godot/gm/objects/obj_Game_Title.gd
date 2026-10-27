extends GMInstance
## obj_Game_Title (타이틀 로고 애니메이션 -> 탭하여 메뉴 버튼 생성)

var Stage := 0
var showClickText := false
var pisc := false


func create() -> void:
	image_alpha = 0.0
	Stage = 0
	showClickText = false
	pisc = false
	alarm[1] = 18


func on_alarm(n: int) -> void:
	if n == 0:
		Stage = 2
	elif n == 1:
		if not pisc:
			pisc = true
			alarm[1] = 6
		else:
			pisc = false
			alarm[1] = 18


func step() -> void:
	if image_alpha < 1.0:
		image_alpha = minf(1.0, image_alpha + 0.02)
	if image_alpha == 1.0 and Stage == 0:
		Stage = 1
		alarm[0] = 45
	if Stage == 2:
		if y > 97.0:
			var dist := absf(y - 90.0)
			vspeed = -2.0 - clampf(dist, -2.0, 1.0)
		else:
			y = 97.0
			vspeed = 0.0
			Stage = 3
	elif Stage == 3:
		y = 97.0
		vspeed = 0.0
		showClickText = true
	elif Stage == 4:
		y = 97.0
		vspeed = 0.0
		showClickText = false


func global_left_released() -> void:
	if Stage < 3:
		Stage = 3
		image_alpha = 1.0
		y = 97.0
		vspeed = 0.0
	elif Stage == 3:
		var has_save := FileAccess.file_exists("user://DT2_save%d.sav" % int(GM.g["gameSaveSlot"]))
		if has_save:
			var b0 := GM.instance_create(0, 177, "obj_MainMenu_Buttons")
			b0.image_index = 0
			var b1 := GM.instance_create(0, 210, "obj_MainMenu_Buttons")
			b1.image_index = 1
		else:
			var b0 := GM.instance_create(0, 193, "obj_MainMenu_Buttons")
			b0.image_index = 0
		var opt := GM.instance_create(538, 275, "obj_MainMenu_Buttons")
		opt.sprite_index = "spr_MenuOptions_Button"
		Stage = 4
		alarm[0] = -1


func draw() -> void:
	draw_self()
	draw_set_format("fnt_MidText", 16777215, 1, 1)
	if showClickText and not pisc and Stage == 3:
		draw_text(x, y + 137, "Tap to Continue...")
	if Stage == 4:
		draw_set_format("fnt_Text", 16777215, 1, 1)
		draw_text(269, 285, "®Akiyoshi Hongo, Toei Animation ®&© Bandai Namco.")
		draw_set_format("fnt_Text", 16777215, 0, 2)
		draw_text(404, 148, "V 2.0.2")
