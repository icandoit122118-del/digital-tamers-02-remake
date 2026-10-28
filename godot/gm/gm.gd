extends Node
## GameMaker 런타임 호환 계층 (autoload "GM")
## - 추출 데이터(sprites/objects/rooms.json) 로드, 룸 전환, 인스턴스 생성/이벤트 루프,
##   마우스 이벤트, 사운드, 폰트, 전역 변수(global.*)

const ROOT := "D:/digimon-re/out/"
const DATA := ROOT + "data/"
const SPR := ROOT + "sprites/"
const SND := ROOT + "sounds/"
const RES_ASSETS := "res://assets/"
const FPS := 60

var sprites := {}
var objects := {}
var rooms := {}
var db := {"digimons": {}, "evolutions": {}, "items": {}, "quests": []}

## GML global.* 변수 및 리메이크 실시간 테이머/파트너 데이터
var g := {
	"Language": 0, "soundFX": true, "music": true, "DigimonVoice": true,
	"gameSaveSlot": 0, "MusicVOL": 100, "butCanClick": true,
	"ExtraVAR": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"PreviousRoom": "", "NPC_battle_stage": 0, "isAdventureMode": false, "isInfinityMode": false,
	"scrollPerc": 0,
	"dataMode": "demo", "reducedMotion": false,
	"partnerId": 5, "partnerLv": 28, "bits": 24500, "digiCores": 12,
	"hp": 2200, "hp_max": 2200, "en": 100, "xp": 74,
	"hunger": 82, "friendship": 75.0, "injury": 0, "poopCount": 0,
	"wins": 18, "losses": 2, "totalBattles": 20,
	"tamerLv": 12, "tamerXp": 420, "tamerSp": 5,
	"tamerSkills": [1, 1, 0, 1, 0, 0, 1, 0, 1, 1],
	"atk": 384, "def": 310, "sp_atk": 340, "sp_def": 290, "spd": 265, "luk": 48,
	"equippedItem": 10, "battleCards": [1, 5, 10, 14],
	"storageDigis": [5, 3, 22, 85, 151],
	"inventory": {"1": 5, "2": 3, "3": 4, "4": 2, "5": 2, "10": 1, "140": 1},
	"infinityFloor": 1, "adventureStage": 1, "challengeRank": 1,
	"enemyId": 87, "enemyLv": 32, "battleZone": "Magma Mountain", "battleMode": "world",
	"BattleBG": "bg_Btl_Magma_Mountain", "MainRoomBG": "BG26", "sanctuaryThemeIdx": 0,
	"CamMulti": 1.0, "StatsAberto": false, "TraningWhat": 0, "TrainBoost": 1, "BulkTraining": false,
	"LastEquipRoom": "room_PowerUpItems", "BiosLastPage": "room_Bios_Rookie",
	"TamerName": "Tamer", "AgeEnabled": true, "EvoStage": 2, "eggId": 0,
}

const STARTER_EGGS := [
	{"egg_spr": "spr_egg01", "baby_id": 1, "rookie_id": 3, "champ_id": 5, "name": "Botamon (Agumon Line)"},
	{"egg_spr": "spr_egg02", "baby_id": 6, "rookie_id": 8, "champ_id": 10, "name": "Punimon (Gabumon Line)"},
	{"egg_spr": "spr_egg03", "baby_id": 11, "rookie_id": 13, "champ_id": 15, "name": "Poyomon (Patamon Line)"},
	{"egg_spr": "spr_egg04", "baby_id": 16, "rookie_id": 18, "champ_id": 20, "name": "Yuramon (Palmon Line)"},
	{"egg_spr": "spr_egg05", "baby_id": 21, "rookie_id": 22, "champ_id": 24, "name": "Choromon (Tentomon Line)"},
	{"egg_spr": "spr_egg06", "baby_id": 26, "rookie_id": 28, "champ_id": 30, "name": "Pichimon (Gomamon Line)"},
	{"egg_spr": "spr_egg07", "baby_id": 31, "rookie_id": 33, "champ_id": 35, "name": "Nyokimon (Biyomon Line)"},
	{"egg_spr": "spr_egg08", "baby_id": 36, "rookie_id": 38, "champ_id": 40, "name": "YukimiBotamon (Gatomon Line)"},
	{"egg_spr": "spr_egg09", "baby_id": 41, "rookie_id": 43, "champ_id": 45, "name": "Chibomon (Veemon Line)"},
	{"egg_spr": "spr_egg10", "baby_id": 46, "rookie_id": 48, "champ_id": 50, "name": "Jyarimon (Guilmon Line)"},
]

const MODERN_WORLD_WHITELIST := {
	"obj_Digi": true,
	"obj_Digi_Battle": true,
	"obj_Enemy_Battle": true,
	"obj_Floor": true,
	"obj_CTRL_persistent": true,
	"obj_Transition": true,
}

const LEGACY_UI_OBJECTS := {
	"obj_Game_Title": true,
	"obj_MainMenu_Buttons": true,
	"obj_OptionBut01": true,
	"obj_Options_But02": true,
	"obj_Back_Button": true,
	"obj_Room_Label": true,
	"obj_MainHUD": true,
	"obj_MainButtons": true,
	"obj_Side_Buttons": true,
	"obj_CloseGame_Button": true,
	"obj_FoodBar": true,
	"obj_FoodSlot": true,
	"obj_Digi_Info": true,
	"obj_Floor_Deco": true,
	"obj_DecoLayer01": true,
	"obj_DecoLayer02": true,
	"obj_TrainingStats_HUD": true,
	"obj_Training_Buttons": true,
	"obj_TrainingBoost": true,
	"obj_TrainingBoost_indicator": true,
	"obj_Money_Tab_HUD": true,
	"obj_Battle_CTRL": true,
	"obj_ENEMY_STATS": true,
	"obj_Top_Hud": true,
	"obj_SpecialHUD_Player": true,
	"obj_Special_PLAYER": true,
	"obj_SpecialHUD_Enemy": true,
	"obj_Special_ENEMY": true,
	"obj_BLOCK_button": true,
	"obj_Command_Button": true,
	"obj_Battle_Countdown": true,
	"obj_Abilities": true,
	"obj_SpCond_Atk": true,
	"obj_SpCond_SpAtk": true,
	"obj_SpCond_Extra": true,
	"obj_Equipment_stats": true,
	"obj_LeaderSkill": true,
	"obj_Pause_Button": true,
	"obj_Big_Button": true,
	"obj_Long_Buttons": true,
	"obj_Camera": true,
	"obj_Wall": true,
	"obj_Terrain": true,
}

var use_modern_ui := false
var battle: Dictionary = {}
var instances: Array = []
var room_name := ""
var room_data: Dictionary = {}
var bg_hspeed := {}
var bg_vspeed := {}
var world: Node2D
var gui: CanvasLayer
var fx_gui: CanvasLayer
var ui: TamerUI
var bg: GMBackground
var log_unhandled: Array = []

var _pending_room := ""
var _next_id := 100000
var _tex_cache := {}
var _fonts := {}
var _snd_index := {}
var _stream_cache := {}
var _warned := {}
var _press := false
var _release := false
var _press_pos := Vector2.ZERO
var _release_pos := Vector2.ZERO
var mouse := Vector2.ZERO
var frame := 0


func _ready() -> void:
	for s in _load_json("sprites.json"):
		sprites[s["name"]] = s
	for o in _load_json("objects.json"):
		objects[o["name"]] = o
	for r in _load_json("rooms.json"):
		rooms[r["name"]] = r
	if FileAccess.file_exists(DATA + "full_db.json"):
		db = _load_json("full_db.json")
	_index_sounds(SND)
	_index_sounds(SND + "external/")

	bg = GMBackground.new()
	bg.z_index = -4096
	bg.scale = Vector2(2, 2)
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bg)
	world = Node2D.new()
	world.scale = Vector2(2, 2)
	world.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(world)
	gui = CanvasLayer.new()
	gui.layer = 40
	add_child(gui)
	ui = TamerUI.new()
	ui.visible = use_modern_ui
	gui.add_child(ui)
	fx_gui = CanvasLayer.new()
	fx_gui.layer = 60
	add_child(fx_gui)
	init_battle_state()
	Engine.physics_ticks_per_second = FPS


func start_new_game_with_egg(egg_idx: int) -> void:
	var idx := clampi(egg_idx, 0, STARTER_EGGS.size() - 1)
	var egg_info: Dictionary = STARTER_EGGS[idx]
	g["eggId"] = idx
	g["EvoStage"] = 0
	g["partnerId"] = int(egg_info["rookie_id"])
	g["partnerLv"] = 1
	g["hp_max"] = 450
	g["hp"] = 450
	g["atk"] = 68
	g["def"] = 58
	g["sp_atk"] = 64
	g["sp_def"] = 56
	g["spd"] = 110
	g["en"] = 100
	g["xp"] = 0
	g["hunger"] = 70
	g["friendship"] = 25.0
	g["injury"] = 0
	g["poopCount"] = 0
	init_battle_state()


func hatch_partner_egg() -> void:
	var idx := clampi(int(g.get("eggId", 0)), 0, STARTER_EGGS.size() - 1)
	var egg_info: Dictionary = STARTER_EGGS[idx]
	g["EvoStage"] = 2
	g["partnerId"] = int(egg_info["rookie_id"])
	g["partnerLv"] = maxi(5, int(g.get("partnerLv", 1)))
	g["hp_max"] = maxi(950, int(g.get("hp_max", 450)) + 500)
	g["hp"] = int(g["hp_max"])
	g["atk"] = maxi(160, int(g.get("atk", 68)) + 92)
	g["def"] = maxi(140, int(g.get("def", 58)) + 82)
	g["sp_atk"] = maxi(155, int(g.get("sp_atk", 64)) + 91)
	g["spd"] = maxi(185, int(g.get("spd", 110)) + 75)
	play_sound_fx("snd_Digivolve")
	init_battle_state()


func init_battle_state() -> void:
	var mode: String = str(g.get("dataMode", "demo"))
	var pid: int = int(g.get("partnerId", 5))
	var p_entry: Dictionary = db["digimons"].get(str(pid), {})
	var p_name: String = str(p_entry.get("name", "Greymon"))
	var p_lv: int = int(g.get("partnerLv", 28))
	var p_hp_max: int = int(g.get("hp_max", 2200))
	var p_atk: int = int(g.get("atk", 384))
	var p_def: int = int(g.get("def", 310))
	var p_sp_atk: int = int(g.get("sp_atk", 340))
	var p_spd: int = int(g.get("spd", 265))
	var p_luk: int = int(g.get("luk", 48))
	var p_icon: int = pid
	if mode == "worst":
		pid = 152
		p_name = "BlackWarGreymon-X (Reinforced Awakened)"
		p_lv = 999
		p_hp_max = 9999
		p_atk = 999
		p_def = 850
		p_sp_atk = 999
		p_spd = 420
		p_luk = 88
		p_icon = 152
	elif mode == "empty":
		pid = 2
		p_name = "Koromon (Rookie Trial)"
		p_lv = 5
		p_hp_max = 950
		p_atk = 180
		p_def = 140
		p_sp_atk = 175
		p_spd = 210
		p_luk = 65
		p_icon = 2

	var eid: int = int(g.get("enemyId", 87))
	var e_entry: Dictionary = db["digimons"].get(str(eid), {})
	var e_name: String = str(e_entry.get("name", "SkullGreymon"))
	var e_lv: int = int(g.get("enemyLv", 32))
	var e_hp_max: int = int(e_entry.get("base_hp", 2400)) + e_lv * 48
	var e_atk: int = int(e_entry.get("base_atk", 320)) + e_lv * 3
	var e_def: int = int(e_entry.get("base_def", 260)) + e_lv * 2
	var e_spd: int = int(e_entry.get("base_spd", 240)) + e_lv
	var e_luk: int = int(e_entry.get("base_luk", 38))

	var p_attr: String = str(p_entry.get("attr", "Vaccine"))
	var e_attr: String = str(e_entry.get("attr", "Virus"))
	var atr_mod := 1.0
	var ini_atr_mod := 1.0
	# 원작 gml_Object_obj_Battle_CTRL_Create_0.gml 속성 상성 공식 (Vaccine > Virus > Data > Vaccine)
	if (p_attr == "Vaccine" and e_attr == "Virus") or (p_attr == "Virus" and e_attr == "Data") or (p_attr == "Data" and e_attr == "Vaccine"):
		atr_mod = 1.2
		ini_atr_mod = 0.9
	elif (e_attr == "Vaccine" and p_attr == "Virus") or (e_attr == "Virus" and p_attr == "Data") or (e_attr == "Data" and p_attr == "Vaccine"):
		atr_mod = 0.9
		ini_atr_mod = 1.2
	elif p_attr == "Free" and e_attr != "Free":
		atr_mod = 1.1
		ini_atr_mod = 0.9

	var injury_pen: int = int(floor(float(g.get("injury", 0)) * (float(p_lv) * 0.5)))
	var btl_p_atk: int = int(round(float(p_atk) * atr_mod))
	var btl_p_sp_atk: int = int(round(float(p_sp_atk) * atr_mod))
	var btl_p_def: int = maxi(10, p_def - injury_pen)
	var btl_e_atk: int = int(round(float(e_atk) * ini_atr_mod))

	var prev_tactic: String = str(battle.get("ai_tactic", "balanced"))

	battle = {
		"bonus_bits": 0,
		"given_xp": 0,
		"tamer_xp_gain": 0,
		"auto_skill": true,
		"speed2x": true,
		"ai_tactic": prev_tactic,
		"finished": false,
		"win": true,
		"result_banner": "",
		"p_id": pid,
		"p_name": p_name,
		"p_lv": p_lv,
		"p_attr": p_attr,
		"p_atr_mod": atr_mod,
		"p_icon": p_icon,
		"p_hp": p_hp_max,
		"p_hp_max": p_hp_max,
		"p_sp": 45.0,
		"p_block": 100.0,
		"p_combo": 0,
		"p_acao": 1,
		"p_atk": btl_p_atk,
		"p_def": btl_p_def,
		"p_sp_atk": btl_p_sp_atk,
		"p_spd": p_spd,
		"p_luk": p_luk,
		"p_ai_state": "IDLE (acao=1)",
		"p_dodge_count": 0,
		"p_parry_count": 0,
		"jackpot_count": 0,
		"shield_active": false,
		"e_id": eid,
		"e_name": e_name,
		"e_lv": e_lv,
		"e_attr": e_attr,
		"e_atr_mod": ini_atr_mod,
		"e_icon": eid,
		"e_hp": e_hp_max,
		"e_hp_max": e_hp_max,
		"e_sp": 30.0,
		"e_combo": 0,
		"e_acao": 1,
		"e_atk": btl_e_atk,
		"e_def": e_def,
		"e_spd": e_spd,
		"e_luk": e_luk,
		"e_ai_state": "IDLE (acao=1)",
		"slot_timer": 0.0,
		"fever_timer": 0.0,
		"slot_reels": "AUTO BATTLE",
		"slot_title": "ORIGINAL COMBAT ENGINE",
		"slot_desc": "Authentic acao State Machine + Auto-Battle",
		"last_dice": 0,
		"last_tier": "READY",
		"last_mult": atr_mod,
		"last_log": "[AUTO BATTLE] %s (%s %.1fx) vs %s (%s) — Original Combat!" % [p_name, p_attr, atr_mod, e_name, str(g.get("battleZone", "Arena"))],
		"skills": [
			{"name": "Melee Strike", "tag": "acao=7 · Physical ATK", "cd": 0.2, "cd_max": 1.4, "power": 1.15, "sp_gain": 18.0, "last_roll": "READY (ATK)", "last_mult": 1.0},
			{"name": "Ranged Sp.Atk", "tag": "acao=8 · Elemental SP.ATK", "cd": 0.4, "cd_max": 2.0, "power": 1.25, "sp_gain": 22.0, "last_roll": "READY (SP.ATK)", "last_mult": 1.0},
			{"name": "Guard / Jump", "tag": "acao=4/5 · Block & Evade", "cd": 0.6, "cd_max": 2.8, "power": 1.00, "sp_gain": 15.0, "last_roll": "BLOCK 100%", "last_mult": 1.0},
			{"name": "Special Ultimate", "tag": "acao=10 · SP 100% Finisher", "cd": 0.0, "cd_max": 1.0, "power": 2.35, "sp_gain": 0.0, "last_roll": "SP GAUGE AUTO", "last_mult": 2.0},
		]
	}


func care_action(kind: String) -> String:
	if kind == "food":
		g["hunger"] = mini(100, int(g.get("hunger", 80)) + 25)
		g["hp"] = mini(int(g["hp_max"]), int(g["hp"]) + int(float(g["hp_max"]) * 0.25))
		g["xp"] = mini(100, int(g.get("xp", 50)) + 15)
		if int(g["xp"]) >= 100:
			g["xp"] = 0
			g["partnerLv"] = int(g["partnerLv"]) + 1
			g["hp_max"] = int(g["hp_max"]) + 85
			g["atk"] = int(g["atk"]) + 12
			g["def"] = int(g["def"]) + 10
		return "🍖 Fed Meat! Hunger %d%% · HP Restored" % int(g["hunger"])
	elif kind == "vitamin":
		g["en"] = mini(100, int(g.get("en", 80)) + 40)
		g["friendship"] = minf(100.0, float(g.get("friendship", 75.0)) + 3.0)
		return "💊 Gave Vitamin! Energy %d/100 · Friendship %.0f%%" % [int(g["en"]), float(g["friendship"])]
	elif kind == "clean":
		g["poopCount"] = 0
		g["friendship"] = minf(100.0, float(g.get("friendship", 75.0)) + 4.0)
		return "🧹 Cleaned Sanctuary Floor! Hygiene 100%%"
	elif kind == "bandage":
		g["injury"] = 0
		g["hp"] = int(g["hp_max"])
		return "🩹 Treated Injury (machucado=0)! Full DEF & HP Restored"
	elif kind == "sleep":
		g["en"] = 100
		g["hp"] = int(g["hp_max"])
		return "💤 Partner Rested! Energy 100/100 & Full HP"
	return ""


func evolve_partner(to_id: int, bonus_hp: int = 600, bonus_atk: int = 95, bonus_def: int = 80, bonus_sp: int = 90) -> void:
	g["partnerId"] = to_id
	g["partnerLv"] = int(g["partnerLv"]) + 5
	g["hp_max"] = int(g["hp_max"]) + bonus_hp
	g["hp"] = int(g["hp_max"])
	g["atk"] = int(g["atk"]) + bonus_atk
	g["def"] = int(g["def"]) + bonus_def
	g["sp_atk"] = int(g["sp_atk"]) + bonus_sp
	g["spd"] = int(g["spd"]) + 28
	g["luk"] = mini(99, int(g["luk"]) + 8)
	init_battle_state()


func start_stage_battle(enemy_id: int, enemy_lv: int, zone_label: String, custom_bg: String = "") -> void:
	g["enemyId"] = enemy_id
	g["enemyLv"] = enemy_lv
	g["battleZone"] = zone_label
	g["BattleBG"] = custom_bg if not custom_bg.is_empty() else GMBackground.resolve_battle_bg_for_zone(zone_label)
	init_battle_state()
	room_transition(5, "room_Battle")


func save_game_state() -> bool:
	var f := FileAccess.open("user://tamer_save_v2.json", FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(g, "\t"))
	return true


func load_game_state() -> bool:
	if not FileAccess.file_exists("user://tamer_save_v2.json"):
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("user://tamer_save_v2.json"))
	if parsed is Dictionary:
		for k in parsed.keys():
			g[k] = parsed[k]
		init_battle_state()
		return true
	return false


# ---------- 데이터 / 리소스 ----------
func _load_json(name: String) -> Variant:
	var res_p := RES_ASSETS + "data/" + name
	var p := res_p if FileAccess.file_exists(res_p) else (DATA + name)
	return JSON.parse_string(FileAccess.get_file_as_string(p))


func col(c: int) -> Color:
	return Color8(c & 0xFF, (c >> 8) & 0xFF, (c >> 16) & 0xFF)


func tex(spr: String, frame_i: int = 0) -> Texture2D:
	var key := "%s:%d" % [spr, frame_i]
	if _tex_cache.has(key):
		return _tex_cache[key]
	var t: Texture2D = null
	var candidates: Array = []
	if spr == "spr_Items":
		candidates.append("%ssprites/spr_Items_HD/spr_Items_HD_%d.png" % [RES_ASSETS, frame_i])
		candidates.append("%sspr_Items_HD/spr_Items_HD_%d.png" % [SPR, frame_i])
	candidates.append_array([
		"%ssprites/ui_HD/%s_%d.png" % [RES_ASSETS, spr, frame_i],
		"%ssprites/bg_HD/%s_%d.png" % [RES_ASSETS, spr, frame_i],
		"%sui_HD/%s_%d.png" % [SPR, spr, frame_i],
		"%sbg_HD/%s_%d.png" % [SPR, spr, frame_i],
		"%ssprites/%s/%s_%d.png" % [RES_ASSETS, spr, spr, frame_i],
		"%s%s/%s_%d.png" % [SPR, spr, spr, frame_i],
	])
	var p := ""
	for c in candidates:
		if FileAccess.file_exists(c):
			p = c
			break
	if p != "":
		var img := Image.load_from_file(p)
		if img != null:
			t = ImageTexture.create_from_image(img)
	elif not _warned.has(key):
		_warned[key] = true
		push_warning("missing sprite frame: " + key)
	_tex_cache[key] = t
	return t


func tex_item(frame_i: int, prefer_hd: bool = true) -> Texture2D:
	if prefer_hd:
		var hd_key := "spr_Items_HD:%d" % frame_i
		if _tex_cache.has(hd_key):
			return _tex_cache[hd_key]
		var hd_path := "%sspr_Items_HD/spr_Items_HD_%d.png" % [SPR, frame_i]
		if FileAccess.file_exists(hd_path):
			var img := Image.load_from_file(hd_path)
			if img != null:
				var hd_tex := ImageTexture.create_from_image(img)
				_tex_cache[hd_key] = hd_tex
				return hd_tex
	return tex("spr_Items", frame_i)


func font(name: String) -> GMFont:
	if not _fonts.has(name):
		_fonts[name] = GMFont.load_font(name)
	return _fonts[name]


# ---------- 사운드 ----------
func _index_sounds(dir: String) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		var ext := f.get_extension().to_lower()
		if ext == "ogg" or ext == "wav":
			var key := f.get_basename().to_lower()
			if not _snd_index.has(key):
				_snd_index[key] = dir + f


func _stream(name: String, loop: bool) -> AudioStream:
	var key := name.to_lower()
	var ck := "%s:%s" % [key, loop]
	if _stream_cache.has(ck):
		return _stream_cache[ck]
	var st: AudioStream = null
	if _snd_index.has(key):
		var path: String = _snd_index[key]
		if path.get_extension().to_lower() == "ogg":
			var o := AudioStreamOggVorbis.load_from_file(path)
			if o != null:
				o.loop = loop
				st = o
		else:
			var w := AudioStreamWAV.load_from_file(path)
			if w != null:
				if loop:
					w.loop_mode = AudioStreamWAV.LOOP_FORWARD
					w.loop_begin = 0
					w.loop_end = int(w.get_length() * w.mix_rate)
				st = w
	elif not _warned.has(key):
		_warned[key] = true
		push_warning("missing sound: " + name)
	_stream_cache[ck] = st
	return st


func audio_play_sound(name: String, loop: bool = false) -> AudioStreamPlayer:
	var st := _stream(name, loop)
	if st == null:
		return null
	var p := AudioStreamPlayer.new()
	p.stream = st
	p.set_meta("snd", name.to_lower())
	add_child(p)
	p.play()
	if not loop:
		p.finished.connect(p.queue_free)
	return p


func audio_stop_all() -> void:
	for c in get_children():
		if c is AudioStreamPlayer:
			c.queue_free()


func audio_is_playing(name: String) -> bool:
	for c in get_children():
		if c is AudioStreamPlayer and not c.is_queued_for_deletion() and c.get_meta("snd", "") == name.to_lower() and c.playing:
			return true
	return false


func play_music(name: String) -> void:
	if g["music"] == true:
		audio_play_sound(name, true)


func play_sound_fx(name: String) -> void:
	if g["soundFX"] == true:
		audio_play_sound(name, false)


# ---------- 인스턴스 ----------
func z_for_depth(d: float) -> int:
	return int(-signf(d) * log(1.0 + absf(d)) * 100.0)


func make_instance(obj_name: String) -> GMInstance:
	var path := "res://gm/objects/%s.gd" % obj_name
	var inst: GMInstance
	if ResourceLoader.exists(path):
		inst = load(path).new()
	else:
		inst = GMInstance.new()
	inst.obj_name = obj_name
	inst.id = _next_id
	_next_id += 1
	var o = objects.get(obj_name)
	if o != null:
		inst.sprite_index = o["sprite"] if o["sprite"] != null else ""
		inst.visible = o["visible"]
		inst.depth = o["depth"]
		inst.persistent = o["persistent"]
	else:
		push_warning("unknown object: " + obj_name)
	return inst


func _attach(inst: GMInstance) -> void:
	inst.z_index = z_for_depth(inst.depth)
	instances.append(inst)
	if inst.get("_on_gui") == true:
		fx_gui.add_child(inst)
	else:
		world.add_child(inst)


func instance_create(px: float, py: float, obj_name: String) -> GMInstance:
	var inst := make_instance(obj_name)
	inst.x = px
	inst.y = py
	inst.xstart = px
	inst.ystart = py
	_attach(inst)
	inst.create()
	return inst


func instance_exists(obj_name: String) -> bool:
	for i in instances:
		if i.obj_name == obj_name and not i.dead:
			return true
	return false


func instance_removed(inst: GMInstance) -> void:
	instances.erase(inst)
	inst.queue_free()


func room_transition(type: int, target: String) -> void:
	if instance_exists("obj_Transition"):
		return
	var t := instance_create(0, 0, "obj_Transition")
	t.type = type
	t.target = target


# ---------- 룸 ----------
func room_goto(name: String) -> void:
	_pending_room = name


func _switch_room(name: String) -> void:
	if not rooms.has(name):
		push_error("room not found: " + name)
		return
	g["PreviousRoom"] = room_name
	for i in instances.duplicate():
		if not i.persistent:
			i.dead = true
			instances.erase(i)
			i.queue_free()
	bg_hspeed.clear()
	bg_vspeed.clear()
	room_name = name
	room_data = rooms[name]
	bg.setup(room_data)
	for l in room_data["layers"]:
		if l["bg"] != null and l["name"].ends_with("Colour"):
			RenderingServer.set_default_clear_color(col(int(l["bg"]["color"])))

	var inst_depth := {}
	for l in room_data["layers"]:
		if l["instIds"] != null:
			for iid in l["instIds"]:
				inst_depth[int(iid)] = l["depth"]

	for d in room_data["instances"]:
		var obj_name_str: String = str(d["obj"])
		if use_modern_ui and not MODERN_WORLD_WHITELIST.has(obj_name_str):
			continue
		var obj = objects.get(obj_name_str)
		if obj != null and obj["persistent"] and instance_exists(obj_name_str):
			continue
		var inst := make_instance(obj_name_str)
		inst.x = d["x"]
		inst.y = d["y"]
		inst.xstart = d["x"]
		inst.ystart = d["y"]
		inst.image_xscale = d["sx"]
		inst.image_yscale = d["sy"]
		inst.image_angle = d["rot"]
		inst.image_index = d["imgIndex"]
		inst.image_speed = d["imgSpeed"]
		inst.depth = inst_depth.get(int(d["id"]), inst.depth)
		_attach(inst)
		inst.create()
		if d["code"] != null:
			_apply_creation_code(inst, d["code"])
	_run_room_code(room_data["creationCode"])
	if ui != null:
		ui.visible = use_modern_ui
		if use_modern_ui:
			ui.rebuild_for_room(name)


## 인스턴스 생성 코드: 단순 대입 및 Language/BulkTraining 조건부 대입을 모두 해석한다.
func _apply_creation_code(inst: GMInstance, code_name: String) -> void:
	var text := FileAccess.get_file_as_string(ROOT + "code/" + code_name + ".gml")
	var re := RegEx.create_from_string("^\\s*([A-Za-z_]\\w*)\\s*=\\s*(.+?);\\s*$")
	var skip_block := false
	for line in text.split("\n"):
		var s := line.strip_edges()
		if s.is_empty() or s == "{" or s.begins_with("enum ") or s.begins_with("Value_"):
			continue
		if s == "}":
			skip_block = false
			continue
		if s.begins_with("if (global.Language == 1)") or s.begins_with("else if (global.Language == 1)") or s.begins_with("else if (global.Language == 2)"):
			skip_block = (int(g.get("Language", 0)) != 1)
			continue
		elif s.begins_with("if (global.Language == 0)"):
			skip_block = (int(g.get("Language", 0)) != 0)
			continue
		elif s.begins_with("if (global.BulkTraining == false)"):
			skip_block = (bool(g.get("BulkTraining", false)) != false)
			continue
		elif s == "else":
			skip_block = not skip_block
			continue
		if skip_block:
			continue
		if s == "instance_destroy();":
			inst.instance_destroy()
			return
		var m := re.search(s)
		if m == null:
			continue
		var v: Variant = _parse_value(m.get_string(2))
		var key := m.get_string(1)
		if key in inst:
			inst.set(key, v)
		else:
			inst.vars[key] = v


func _parse_value(s: String) -> Variant:
	s = s.strip_edges()
	if s == "true": return true
	if s == "false": return false
	if s.is_valid_int(): return int(s)
	if s.is_valid_float(): return float(s)
	if s.begins_with("\"") and s.ends_with("\""): return s.substr(1, s.length() - 2)
	return s  # room_* / obj_* / spr_* 등 식별자는 이름 문자열로 취급


## 룸 생성 코드: audio_stop_all / PlayMusic / __background_set(HSpeed|VSpeed) / 음악 조건부 재생만 처리
func _run_room_code(code_name: Variant) -> void:
	if code_name == null:
		return
	var text := FileAccess.get_file_as_string(ROOT + "code/" + code_name + ".gml")
	var cond := RegEx.create_from_string("if \\(global\\.music == true && !audio_is_playing\\((\\w+)\\)\\)\\s*\\{\\s*audio_stop_all\\(\\);\\s*audio_play_sound\\(\\1, \\d+, true\\);\\s*\\}")
	var cm := cond.search(text)
	if cm != null:
		if g["music"] == true and not audio_is_playing(cm.get_string(1)):
			audio_stop_all()
			audio_play_sound(cm.get_string(1), true)
		text = text.replace(cm.get_string(), "")
	var re_bg := RegEx.create_from_string("__background_set\\(e__BG\\.(HSpeed|VSpeed),\\s*(\\d+),\\s*(-?[\\d.]+)\\)")
	var re_play := RegEx.create_from_string("^PlayMusic\\((\\w+)\\);")
	var in_enum := false
	for raw in text.split("\n"):
		var line := raw.strip_edges()
		if line.is_empty() or line == "{" or line == "}":
			continue
		if line.begins_with("enum "):
			in_enum = true
			continue
		if in_enum:
			if line == "}":
				in_enum = false
			continue
		if line == "audio_stop_all();":
			audio_stop_all()
		elif re_play.search(line) != null:
			play_music(re_play.search(line).get_string(1))
		elif re_bg.search(line) != null:
			var m := re_bg.search(line)
			if m.get_string(1) == "HSpeed":
				bg_hspeed[int(m.get_string(2))] = float(m.get_string(3))
			else:
				bg_vspeed[int(m.get_string(2))] = float(m.get_string(3))
		else:
			log_unhandled.append("%s: %s" % [code_name, line])


# ---------- 입력 / 메인 루프 ----------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse = event.position
		if event.pressed:
			_press = true
			_press_pos = event.position
		else:
			_release = true
			_release_pos = event.position


func _physics_process(_dt: float) -> void:
	frame += 1
	for i in instances.duplicate():
		if not i.dead:
			i._gm_step()
	bg.tick()
	_mouse_events()
	if _pending_room != "":
		var r := _pending_room
		_pending_room = ""
		_switch_room(r)


func _mouse_events() -> void:
	var pressed := _press
	var released := _release
	_press = false
	_release = false
	var w_mouse := mouse / world.scale
	var w_press := _press_pos / world.scale
	var w_release := _release_pos / world.scale
	for i in instances.duplicate():
		if i.dead:
			continue
		var m_pos := mouse if i.get("_on_gui") == true else w_mouse
		var p_pos := _press_pos if i.get("_on_gui") == true else w_press
		var r_pos := _release_pos if i.get("_on_gui") == true else w_release
		var inside: bool = i.contains_point(m_pos)
		if inside != i._hover:
			i._hover = inside
			if inside:
				i.mouse_enter()
			else:
				i.mouse_leave()
		if pressed and not i.dead and i.contains_point(p_pos):
			i.mouse_left_pressed()
		if released and not i.dead and i.contains_point(r_pos):
			i.mouse_left_released()
		if released and not i.dead:
			i.global_left_released()
