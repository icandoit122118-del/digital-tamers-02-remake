extends GMInstance
## obj_Training_Main_HUD (원작 room_Training 상단 훈련 종류 및 3단계 아이콘 HUD)

var trainName := "HP"
var Tentativa := 0


func create() -> void:
	image_speed = 0.0
	var tw: int = int(GM.g.get("TraningWhat", 0))
	match tw:
		0: trainName = "HP"
		1: trainName = "Attack"
		2: trainName = "Sp. Attack"
		3: trainName = "Defense"
		4: trainName = "Sp. Defense"
		5: trainName = "Speed"
		6: trainName = "Bulk All-Stat"


func draw() -> void:
	draw_self()
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 8.0, y + 9.0, trainName + " Training", 0xFFFFFF, 0x212100)
	var tw: int = clampi(int(GM.g.get("TraningWhat", 0)), 0, 5)
	if Tentativa >= 1:
		draw_sprite("spr_TrainingIcons_BIG", tw, x + 40.0, y + 71.0)
	if Tentativa >= 2:
		draw_sprite("spr_TrainingIcons_BIG", tw, x + 90.0, y + 71.0)
	if Tentativa >= 3:
		draw_sprite("spr_TrainingIcons_BIG", tw, x + 140.0, y + 71.0)
