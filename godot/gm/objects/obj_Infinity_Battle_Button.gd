extends GMInstance
## obj_Infinity_Battle_Button (원작 room_Infinity_Mode 무한탑 출격 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func mouse_left_pressed() -> void:
	ImClicked = true
	image_blend = Color8(0xB0, 0xB0, 0xB0)


func mouse_leave() -> void:
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	image_blend = Color.WHITE
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click06")
	var fl: int = maxi(1, int(GM.g.get("infinityFloor", 1)))
	var boss_pool := [85, 87, 151, 152, 210, 310]
	var boss_id: int = boss_pool[fl % boss_pool.size()]
	GM.g["battleMode"] = "infinity"
	GM.g["isInfinityMode"] = true
	GM.start_stage_battle(boss_id, 25 + fl * 5, "Infinity Tower B%dF" % fl, "BG_InfinityTower")


func draw() -> void:
	draw_self()
	var fl: int = maxi(1, int(GM.g.get("infinityFloor", 1)))
	draw_set_format("fnt_MidText", 0xDDE105, 1, 1)
	draw_text_shadow(269.0, 140.0, "INFINITY TOWER - CURRENT FLOOR: B%dF" % fl, 0xDDE105, 0)
