extends GMInstance
## obj_Training_CTRL (원작 room_Training 체육관 미니게임/자동 훈련 진행 및 스탯 상승 컨트롤러)

var _timer := 0
var _step_done := 0
var _partner_inst: GMInstance = null
var _summary_txt := ""


func create() -> void:
	_timer = 0
	_step_done = 0
	_summary_txt = ""
	# 파트너 디지몬을 훈련장 중앙에 배치
	_partner_inst = GM.instance_create(245.0, 216.0, "obj_Digi")
	_partner_inst.hspeed = 0.0


func step() -> void:
	_timer += 1
	for inst in GM.instances:
		if inst.obj_name == "obj_Training_Main_HUD" and not inst.dead:
			if _timer == 20:
				inst.set("Tentativa", 1)
				GM.play_sound_fx("snd_Click01")
			elif _timer == 40:
				inst.set("Tentativa", 2)
				GM.play_sound_fx("snd_Click01")
			elif _timer == 60:
				inst.set("Tentativa", 3)
				GM.play_sound_fx("snd_Digivolve")
				_apply_training_gain()
	if _timer >= 105 and not GM.instance_exists("obj_Transition"):
		GM.room_transition(0, "room_SelectTraining")


func _apply_training_gain() -> void:
	if _step_done > 0:
		return
	_step_done = 1
	var tw: int = int(GM.g.get("TraningWhat", 0))
	var boost: int = maxi(1, int(GM.g.get("TrainBoost", 1)))
	match tw:
		0:
			GM.g["hp_max"] = int(GM.g.get("hp_max", 2200)) + 80 * boost
			GM.g["hp"] = int(GM.g["hp_max"])
			_summary_txt = "TRAINING COMPLETE! +%d Max HP" % (80 * boost)
		1:
			GM.g["atk"] = int(GM.g.get("atk", 384)) + 14 * boost
			_summary_txt = "TRAINING COMPLETE! +%d ATK" % (14 * boost)
		2:
			GM.g["sp_atk"] = int(GM.g.get("sp_atk", 340)) + 14 * boost
			_summary_txt = "TRAINING COMPLETE! +%d SP.ATK" % (14 * boost)
		3:
			GM.g["def"] = int(GM.g.get("def", 310)) + 12 * boost
			_summary_txt = "TRAINING COMPLETE! +%d DEF" % (12 * boost)
		4:
			GM.g["sp_def"] = int(GM.g.get("sp_def", 290)) + 12 * boost
			_summary_txt = "TRAINING COMPLETE! +%d SP.DEF" % (12 * boost)
		5:
			GM.g["spd"] = int(GM.g.get("spd", 265)) + 10 * boost
			_summary_txt = "TRAINING COMPLETE! +%d SPEED" % (10 * boost)
		_:
			GM.g["hp_max"] = int(GM.g.get("hp_max", 2200)) + 150
			GM.g["hp"] = int(GM.g["hp_max"])
			GM.g["atk"] = int(GM.g.get("atk", 384)) + 24
			GM.g["def"] = int(GM.g.get("def", 310)) + 20
			GM.g["sp_atk"] = int(GM.g.get("sp_atk", 340)) + 24
			GM.g["spd"] = int(GM.g.get("spd", 265)) + 16
			_summary_txt = "BULK GYM COACH COMPLETE! All Stats Boosted!"
	GM.init_battle_state()


func global_left_released() -> void:
	if _step_done == 0:
		_apply_training_gain()
	if not GM.instance_exists("obj_Transition"):
		GM.room_transition(0, "room_SelectTraining")


func draw() -> void:
	if not _summary_txt.is_empty():
		draw_set_format("fnt_MidText", 0xDDE105, 1, 1)
		draw_text_shadow(269.0, 145.0, _summary_txt, 0xDDE105, 0)
