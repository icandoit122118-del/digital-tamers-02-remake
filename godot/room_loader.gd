extends Node2D
## 전체 이식 통합 시뮬레이터 (UI, 663 도감, 436 진화, 78 퀘스트, 750 Aseprite 아이템, 1v1 단판 오토체스 운빨 전투)

const SHOTS := "D:/digimon-re/out/shots/"


func _ready() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var start_room: String = args.get("room", "room_MainMenu")
	if args.has("modern_ui"):
		GM.use_modern_ui = true
	elif args.has("legacy"):
		GM.use_modern_ui = false
	GM.room_goto(start_room)

	var sc: String = args.get("scenario", "")
	if sc == "original_flow":
		_run_original_flow_scenario()
	elif sc == "full_port":
		_run_full_port_scenario()
	elif sc == "backgrounds_verify":
		_run_backgrounds_verify_scenario()
	elif sc == "battle_and_items":
		_run_battle_and_items_scenario()
	elif sc == "modern_ui_flow":
		_run_modern_ui_scenario()


func _wait_frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _shot(name: String) -> void:
	for i in 2:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var p := SHOTS + name + ".png"
	var err := img.save_png(p)
	print("SHOT %s err=%d room=%s instances=%d" % [name, err, GM.room_name, GM.instances.size()])


func _run_full_port_scenario() -> void:
	GM.g["dataMode"] = "demo"
	GM.g["partnerId"] = 5

	# 1) 디지바이스 & 78개 퀘스트 로그 + 세이브 검증 (room_DigiVice)
	GM.room_goto("room_DigiVice")
	await _wait_frames(24)
	GM.save_game_state()
	await _shot("full_01_digivice_quests")

	# 2) 436개 진화 루트 매트릭스 (room_Evo_Select) & 그레이몬(#5) -> 메탈그레이몬(#85) 실제 진화!
	GM.room_goto("room_Evo_Select")
	await _wait_frames(24)
	await _shot("full_02_digivolve_tree")
	GM.evolve_partner(85, 800, 140, 110, 130)

	# 3) 663종 디지몬 바이오 도감 (room_Database)
	GM.room_goto("room_Database")
	await _wait_frames(24)
	await _shot("full_03_database_663")

	# 4) 디지털 월드 원정 & 보스 아레나 출격 데크 (room_Select_Map)
	GM.room_goto("room_Select_Map")
	await _wait_frames(24)
	await _shot("full_04_world_expedition")

	# 5) 진화한 메탈그레이몬(#85) vs 워그레이몬(#151) 1v1 단판 오토체스 운빨 전투!
	GM.g["enemyId"] = 151
	GM.g["enemyLv"] = 48
	GM.g["battleZone"] = "Magma Mountain"
	GM.init_battle_state()
	GM.room_goto("room_Battle")
	await _wait_frames(38)
	await _shot("full_05_evolved_battle")

	get_tree().quit(0)


func _run_battle_and_items_scenario() -> void:
	GM.g["dataMode"] = "demo"
	GM.room_goto("room_Battle_Items")
	await _wait_frames(26)
	await _shot("ui_07_aseprite_items")
	get_tree().quit(0)


func _run_modern_ui_scenario() -> void:
	await _wait_frames(28)
	await _shot("ui_01_mainmenu")
	get_tree().quit(0)


func _run_backgrounds_verify_scenario() -> void:
	GM.g["dataMode"] = "demo"
	GM.g["partnerId"] = 85

	# 1) Sanctuary Biome 0: File Island Coast (BG26 + Palm Trees + Stone Floor + Props)
	GM.g["sanctuaryThemeIdx"] = 0
	GM.room_goto("room_MainRoom")
	await _wait_frames(24)
	await _shot("bg_01_sanctuary_coast")

	# 2) Sanctuary Biome 1: Toy Town Sanctuary (BG28 + Teddy Bear Bushes + Props)
	GM.g["sanctuaryThemeIdx"] = 1
	GM.bg.setup(GM.room_data)
	GM.ui.rebuild_for_room("room_MainRoom")
	await _wait_frames(20)
	await _shot("bg_02_sanctuary_toytown")

	# 3) World Expedition Deck with Stage Background Previews
	GM.room_goto("room_Select_Map")
	await _wait_frames(22)
	await _shot("bg_03_expedition_stages")

	# 4) Battle Stage: Magma Mountain (bg_Btl_Magma_Mountain HD)
	GM.start_stage_battle(151, 48, "Magma Mountain", "bg_Btl_Magma_Mountain")
	GM.room_goto("room_Battle")
	await _wait_frames(34)
	await _shot("bg_04_battle_magma_mountain")

	# 5) Battle Stage: Village of Beginnings (bg_Btl_Village_Beginnings HD)
	GM.start_stage_battle(3, 15, "Village of Beginnings", "bg_Btl_Village_Beginnings")
	GM.room_goto("room_Battle")
	await _wait_frames(34)
	await _shot("bg_05_battle_village_beginnings")

	# 6) Battle Stage: Dark Area Abyss (bg_Btl_Dark_Area HD)
	GM.start_stage_battle(152, 55, "Dark Area Abyss", "bg_Btl_Dark_Area")
	GM.room_goto("room_Battle")
	await _wait_frames(34)
	await _shot("bg_06_battle_dark_area")

	get_tree().quit(0)


func _run_original_flow_scenario() -> void:
	GM.use_modern_ui = false

	# 1) room_MainMenu (원작 타이틀 + New Game / Continue / Options 버튼)
	GM.room_goto("room_MainMenu")
	await _wait_frames(12)
	for inst in GM.instances:
		if inst.obj_name == "obj_Game_Title":
			inst.global_left_released()
			inst.global_left_released()
	await _wait_frames(8)
	await _shot("orig_01_mainmenu")

	# 2) room_Intro_Screen (원작 연결 연출 -> 10종 스타터 디지타마 선택 화면)
	GM.room_goto("room_Intro_Screen")
	await _wait_frames(8)
	for inst in GM.instances.duplicate():
		if inst.obj_name == "obj_Intro_Connect":
			inst.global_left_released()
	await _wait_frames(10)
	await _shot("orig_02_intro_eggs")

	# 3) 디지타마 #0(Botamon/Agumon 라인) 선택 -> room_MainRoom 진입 (알 상태 -> 부화 -> FoodBar & Digi_Info 열기)
	GM.start_new_game_with_egg(0)
	GM.room_goto("room_MainRoom")
	await _wait_frames(12)
	await _shot("orig_03_mainroom_egg")
	GM.hatch_partner_egg()
	GM.g["StatsAberto"] = true
	for inst in GM.instances:
		if inst.obj_name == "obj_FoodBar":
			inst.set("Aberto", true)
	await _wait_frames(18)
	await _shot("orig_04_mainroom_hud_care")

	# 4) room_SelectTraining -> room_Training (원작 체육관 스탯 훈련 선택 및 미니게임 실행)
	GM.room_goto("room_SelectTraining")
	await _wait_frames(14)
	await _shot("orig_05_select_training")
	GM.g["TraningWhat"] = 1
	GM.room_goto("room_Training")
	await _wait_frames(65)
	await _shot("orig_06_training_gym")

	# 5) room_Select_Battle_Mode -> room_Select_Map -> room_Battle (원작 4대 배틀 모드 & 월드맵 & 실시간 액션 오토배틀)
	GM.room_goto("room_Select_Battle_Mode")
	await _wait_frames(14)
	await _shot("orig_07_battle_modes")
	GM.room_goto("room_Select_Map")
	await _wait_frames(14)
	await _shot("orig_08_world_map")
	GM.start_stage_battle(85, 28, "Boot Jungle", "bg_Btl_Boot_Jungle")
	GM.room_goto("room_Battle")
	await _wait_frames(42)
	await _shot("orig_09_battle_original_hud")

	# 6) room_Evolution & room_Loja & room_DigiVice (원작 진화 카드, 아이템 상점, 디지바이스)
	GM.room_goto("room_Evolution")
	await _wait_frames(14)
	await _shot("orig_10_evolution_cards")
	GM.room_goto("room_Loja")
	await _wait_frames(14)
	await _shot("orig_11_shop_loja")
	GM.room_goto("room_DigiVice")
	await _wait_frames(14)
	await _shot("orig_12_digivice_hub")

	get_tree().quit(0)
