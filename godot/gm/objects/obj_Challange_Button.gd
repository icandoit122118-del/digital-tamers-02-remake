extends GMInstance
## obj_Challange_Button (원작 room_Select_Challenge 테이머 챌린지 대진 버튼)

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func step() -> void:
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click06")
	var rank_tier := int(round(image_index)) + 1
	var boss_pool := [5, 85, 87, 151, 152, 210]
	var boss_id: int = boss_pool[clampi(rank_tier, 0, boss_pool.size() - 1)]
	var boss_lv: int = 18 + rank_tier * 12 + int(GM.g.get("challengeRank", 1)) * 2
	GM.g["battleMode"] = "challenge"
	GM.start_stage_battle(boss_id, boss_lv, "Tamer Challenge Rank %d" % rank_tier, "bg_Btl_ServerCity_Ruins")


func draw() -> void:
	if y > 280.0:
		return
	draw_self()
	var rank_tier := int(round(image_index)) + 1
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 28.0, y - 6.0, "Rank %d Challenge Cup (Lv.%d)" % [rank_tier, 18 + rank_tier * 12], 0xFFFFFF, 0)
