class_name TamerUI
extends Control
## D-Terminal OS — 모던 모바일 네이티브 UI (1076x600 고해상도)
## - 능력치 기반(ATK/DEF/SP.ATK/SPD/LUK) × 운빨(D100 0.5x~7.77x 잭팟 / AI 점프 회피·패링) 단판 오토체스 자동전투 HUD
## - Aseprite 1.3.18 픽셀아트 리마스터 아이템(spr_Items_HD) 인벤토리 & 운빨 옵션 재감정(Lucky Re-Roll)

const COL_BG_BASE := Color("#0B1118")
const COL_BG_HUD := Color(0.043, 0.067, 0.094, 0.92)
const COL_SURFACE := Color("#131D28")
const COL_SURFACE_HOVER := Color("#1B2938")
const COL_BORDER := Color("#26384D")
const COL_INK := Color("#F0F6FC")
const COL_INK_SEC := Color("#9BB0C7")
const COL_INK_MUTED := Color("#647D96")
const COL_ACCENT := Color("#00E5B0")
const COL_ACCENT_DARK := Color("#042F26")
const COL_BATTLE := Color("#FF6B4A")
const COL_GOLD := Color("#F5C451")
const COL_FOCUS := Color("#38BDF8")

const DATASETS := {
	"demo": {
		"name": "Greymon",
		"stage": "Champion · Vaccine · Luck Tier: SSR",
		"level": 28,
		"hp": 2200, "hp_max": 2200,
		"en": 88, "en_max": 100,
		"xp": 74, "xp_max": 100,
		"atk": 384, "def": 310, "sp_atk": 340, "sp_def": 270, "spd": 265, "luk": 48,
		"bits": "18,450 BIT",
		"icon_frame": 5,
		"preview_spr": "d5_idle",
		"status_note": "Jackpot Rate: 18.0% · AI Jump Dodge: 42%",
	},
	"worst": {
		"name": "BlackWarGreymon-X (Reinforced Awakened)",
		"stage": "Mega Ultra · Virus / Thunder-Dragon",
		"level": 999,
		"hp": 999999, "hp_max": 999999,
		"en": 1, "en_max": 100,
		"xp": 99, "xp_max": 100,
		"atk": 9999, "def": 9999, "sp_atk": 9999, "sp_def": 9999, "spd": 999, "luk": 99,
		"bits": "999,999,999 BIT",
		"icon_frame": 152,
		"preview_spr": "d152_idle",
		"status_note": "Low energy — rest required before training",
	},
	"empty": {
		"name": "No active partner",
		"stage": "Digi-Egg in incubator",
		"level": 0,
		"hp": 0, "hp_max": 100,
		"en": 0, "en_max": 100,
		"xp": 0, "xp_max": 100,
		"atk": 0, "def": 0, "sp_atk": 0, "sp_def": 0, "spd": 0, "luk": 10,
		"bits": "0 BIT",
		"icon_frame": 0,
		"preview_spr": "spr_egg01",
		"status_note": "Tap Hatch or Care to begin raising your partner",
	}
}

const REMADE_ITEMS := [
	{"id": 1, "name": "Prime Sirloin DX", "tier": "SSR Food", "stat": "+450 HP · +12 LUK (1 Match)", "roll": "777 Gourmet Jackpot (25% 2x Buff)", "col": COL_ACCENT},
	{"id": 2, "name": "Golden Acorn Core", "tier": "UR Relic", "stat": "+18% Crit Damage · +15 LUK", "roll": "D100 Roll Floor +8 Guaranteed", "col": COL_GOLD},
	{"id": 10, "name": "Chrome Digizoid Claw", "tier": "777 Mythic", "stat": "+145 ATK · +35 SPD", "roll": "22% Double-Cast Skill Proc", "col": COL_BATTLE},
	{"id": 14, "name": "Aegis Data Shield", "tier": "SSR Gear", "stat": "+120 DEF · +18% Parry", "roll": "Miracle Counter 2.4x on Block", "col": COL_FOCUS},
	{"id": 25, "name": "Azure Miracle Berry", "tier": "SSR Fruit", "stat": "+60 SP Charge · +20 SPD", "roll": "Jump-Evade Reflex +16%", "col": COL_FOCUS},
	{"id": 50, "name": "MOD Chip: SP.ATK 777", "tier": "777 Mythic", "stat": "+170 SP.ATK · +24 LUK", "roll": "Ultimate Jackpot Cap 7.77x Unlock", "col": COL_GOLD},
	{"id": 60, "name": "Overclock Booster X", "tier": "UR Chip", "stat": "+42 SPD · -18% Cooldown", "roll": "30% Instant Cooldown Reset", "col": COL_ACCENT},
	{"id": 75, "name": "Chaos Dice Capsule", "tier": "777 Gamble", "stat": "+55 LUK · Random Stat Surge", "roll": "Rolls 0.5x ~ 10.0x Dmg Multiplier", "col": COL_BATTLE},
]

var _current_room := ""
var _root_layer: Control
var _toast_panel: PanelContainer
var _toast_label: Label
var _toast_timer := 0.0
var _preview_tex_rect: TextureRect
var _preview_frame := 0.0

var _btn_springs := {}
var _panel_alpha := 1.0
var _panel_scale := 1.0

# 실시간 전투 HUD 위젯 참조 (room_Battle)
var _btl_p_hp_bar: ProgressBar
var _btl_p_hp_lbl: Label
var _btl_p_sp_bar: ProgressBar
var _btl_p_ai_lbl: Label
var _btl_e_hp_bar: ProgressBar
var _btl_e_hp_lbl: Label
var _btl_e_sp_bar: ProgressBar
var _btl_e_ai_lbl: Label
var _btl_slot_lbl: Label
var _btl_dice_lbl: Label
var _btl_log_lbl: Label
var _btl_result_card: PanelContainer
var _btl_result_lbl: Label
var _btl_skill_bars: Array = []
var _btl_skill_rolls: Array = []

# Aseprite 아이템 인스펙터 & 도감/퀘스트 페이지 상태
var _selected_item_idx := 0
var _compare_legacy_item := false
var _db_page := 0
var _selected_db_id := 5
var _quest_page := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root_layer = Control.new()
	_root_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root_layer)
	_build_toast()


func rebuild_for_room(room_name: String) -> void:
	_current_room = room_name
	_btn_springs.clear()
	_preview_tex_rect = null
	_btl_skill_bars.clear()
	_btl_skill_rolls.clear()
	_btl_result_card = null
	if is_instance_valid(_toast_panel):
		_toast_panel.visible = false
		_toast_timer = 0.0
	for c in _root_layer.get_children():
		c.queue_free()

	if not bool(GM.g.get("reducedMotion", false)):
		_panel_alpha = 0.0
		_panel_scale = 0.96
	else:
		_panel_alpha = 1.0
		_panel_scale = 1.0

	if room_name == "room_MainMenu":
		_build_main_menu()
	elif room_name == "room_options_MainMenu":
		_build_options_menu()
	elif room_name == "room_MainRoom":
		_build_sanctuary_hud()
	elif room_name == "room_Battle":
		_build_battle_hud()
	else:
		_build_subroom_hud(room_name)


func _process(dt: float) -> void:
	if _panel_alpha < 1.0 or _panel_scale < 1.0:
		if bool(GM.g.get("reducedMotion", false)):
			_panel_alpha = 1.0
			_panel_scale = 1.0
		else:
			_panel_alpha = move_toward(_panel_alpha, 1.0, dt * 7.5)
			_panel_scale = lerpf(_panel_scale, 1.0, 1.0 - exp(-dt * 18.0))
		_root_layer.modulate.a = _panel_alpha
		_root_layer.pivot_offset = Vector2(538, 300)
		_root_layer.scale = Vector2(_panel_scale, _panel_scale)

	for b in _btn_springs.keys():
		if not is_instance_valid(b):
			continue
		var st: Dictionary = _btn_springs[b]
		var target: float = float(st["target"])
		if bool(GM.g.get("reducedMotion", false)):
			st["scale"] = target
			st["vel"] = 0.0
		else:
			var cur: float = float(st["scale"])
			var vel: float = float(st["vel"])
			var omega := 28.0
			var accel := omega * omega * (target - cur) - 2.0 * omega * vel
			vel += accel * dt
			cur += vel * dt
			st["scale"] = cur
			st["vel"] = vel
		var ctrl: Control = b
		ctrl.pivot_offset = ctrl.size * 0.5
		ctrl.scale = Vector2(float(st["scale"]), float(st["scale"]))

	if is_instance_valid(_preview_tex_rect):
		var d: Dictionary = _active_data()
		var spr: String = str(d["preview_spr"])
		var s = GM.sprites.get(spr)
		if s != null and int(s["frames"]) > 0:
			_preview_frame = fposmod(_preview_frame + dt * 8.0, float(s["frames"]))
			_preview_tex_rect.texture = GM.tex(spr, int(_preview_frame))

	if _current_room == "room_Battle":
		_sync_battle_hud_live()

	if _toast_timer > 0.0:
		_toast_timer -= dt
		if _toast_timer <= 0.0 and is_instance_valid(_toast_panel):
			_toast_panel.visible = false


func _active_data() -> Dictionary:
	var mode: String = str(GM.g.get("dataMode", "demo"))
	if mode != "demo":
		return DATASETS.get(mode, DATASETS["demo"])
	var pid: int = int(GM.g.get("partnerId", 5))
	var entry: Dictionary = GM.db.get("digimons", {}).get(str(pid), {})
	var pname: String = str(entry.get("name", "Greymon"))
	var pstage: String = "%s · %s · %s" % [str(entry.get("stage", "Champion")), str(entry.get("attr", "Vaccine")), str(entry.get("elem", "Fire"))]
	var pspr: String = "d%d_idle" % pid
	if not GM.sprites.has(pspr):
		pspr = "d5_idle"
	return {
		"name": pname,
		"stage": pstage,
		"level": int(GM.g.get("partnerLv", 28)),
		"hp": int(GM.g.get("hp", 2200)), "hp_max": int(GM.g.get("hp_max", 2200)),
		"en": int(GM.g.get("en", 88)), "en_max": 100,
		"xp": int(GM.g.get("xp", 74)), "xp_max": 100,
		"atk": int(GM.g.get("atk", 384)), "def": int(GM.g.get("def", 310)),
		"sp_atk": int(GM.g.get("sp_atk", 340)), "sp_def": 280,
		"spd": int(GM.g.get("spd", 265)), "luk": int(GM.g.get("luk", 48)),
		"bits": "%s BIT" % str(GM.g.get("bits", 24500)),
		"icon_frame": pid,
		"preview_spr": pspr,
		"status_note": "Jackpot Rate: %.1f%% · AI Jump Dodge: %d%%" % [12.0 + float(GM.g.get("luk", 48)) * 0.25, 22 + int(float(GM.g.get("spd", 265)) * 0.08)],
	}


func _tr(en: String, pt: String) -> String:
	return en if int(GM.g.get("Language", 0)) == 0 else pt


# ---------- 스타일박스 & 공통 위젯 빌더 ----------
func _box(bg: Color, border: Color, radius: int = 10, border_w: int = 1, pad_h: int = 14, pad_v: int = 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = pad_h
	sb.content_margin_right = pad_h
	sb.content_margin_top = pad_v
	sb.content_margin_bottom = pad_v
	sb.shadow_color = Color(0, 0, 0, 0.28)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 3)
	return sb


func _make_button(label_text: String, kind: String = "secondary", min_w: float = 0.0, min_h: float = 48.0) -> Button:
	var b := Button.new()
	b.name = "Btn_" + label_text.replace(" ", "_")
	b.text = label_text
	b.custom_minimum_size = Vector2(min_w, min_h)
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var normal_bg := COL_SURFACE
	var hover_bg := COL_SURFACE_HOVER
	var border_col := COL_BORDER
	var fg_col := COL_INK
	if kind == "primary":
		normal_bg = COL_ACCENT
		hover_bg = COL_ACCENT.lightened(0.12)
		border_col = COL_ACCENT
		fg_col = COL_ACCENT_DARK
	elif kind == "battle":
		normal_bg = COL_BATTLE
		hover_bg = COL_BATTLE.lightened(0.10)
		border_col = COL_BATTLE
		fg_col = Color("#1A0804")
	elif kind == "gold":
		normal_bg = COL_GOLD
		hover_bg = COL_GOLD.lightened(0.12)
		border_col = COL_GOLD
		fg_col = Color("#1F1400")
	elif kind == "active_seg":
		normal_bg = COL_SURFACE_HOVER
		hover_bg = COL_SURFACE_HOVER
		border_col = COL_ACCENT
		fg_col = COL_ACCENT

	b.add_theme_stylebox_override("normal", _box(normal_bg, border_col, 10, 1, 14, 8))
	b.add_theme_stylebox_override("hover", _box(hover_bg, border_col.lightened(0.18), 10, 1, 14, 8))
	b.add_theme_stylebox_override("pressed", _box(hover_bg.darkened(0.08), COL_ACCENT, 10, 1, 14, 8))
	b.add_theme_stylebox_override("focus", _box(hover_bg, COL_FOCUS, 10, 2, 14, 8))
	b.add_theme_color_override("font_color", fg_col)
	b.add_theme_color_override("font_hover_color", fg_col)
	b.add_theme_color_override("font_pressed_color", fg_col)
	b.add_theme_color_override("font_focus_color", fg_col)
	b.add_theme_font_size_override("font_size", 13)

	_btn_springs[b] = {"scale": 1.0, "vel": 0.0, "target": 1.0}
	b.button_down.connect(func(): _btn_springs[b]["target"] = 0.96)
	b.button_up.connect(func(): _btn_springs[b]["target"] = 1.0)
	b.mouse_exited.connect(func(): _btn_springs[b]["target"] = 1.0)
	return b


func _make_label(txt: String, size: int = 13, color: Color = COL_INK, clip: bool = false) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if clip:
		l.clip_text = true
		l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return l


func _build_toast() -> void:
	_toast_panel = PanelContainer.new()
	_toast_panel.add_theme_stylebox_override("panel", _box(COL_BG_BASE, COL_ACCENT, 8, 1, 16, 8))
	_toast_panel.visible = false
	_toast_panel.position = Vector2(340, 14)
	_toast_panel.custom_minimum_size = Vector2(396, 38)
	_toast_label = _make_label("", 13, COL_ACCENT)
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_panel.add_child(_toast_label)
	add_child(_toast_panel)


func show_toast(msg: String) -> void:
	_toast_label.text = msg
	_toast_panel.visible = true
	_toast_timer = 2.4


# ---------- 1. 메인 메뉴 (room_MainMenu) ----------
func _build_main_menu() -> void:
	var deck := PanelContainer.new()
	deck.position = Vector2(44, 42)
	deck.custom_minimum_size = Vector2(430, 516)
	deck.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 26, 24))
	_root_layer.add_child(deck)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	deck.add_child(vbox)

	var logo_wrap := CenterContainer.new()
	var logo := TextureRect.new()
	logo.texture = GM.tex("spr_GameLogo", 0)
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo.custom_minimum_size = Vector2(275, 99)
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_wrap.add_child(logo)
	vbox.add_child(logo_wrap)

	var subtitle := _make_label(
		_tr("Real-Time Action Auto-Battle RPG", "RPG de Ação em Tempo Real (Auto-Battle)"),
		13, COL_INK_SEC
	)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)
	vbox.add_child(HSeparator.new())

	var btn_sanctuary := _make_button(_tr("Enter Sanctuary (Live HUD)", "Entrar no Santuário (HUD)"), "primary", 360, 52)
	btn_sanctuary.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		GM.room_transition(0, "room_MainRoom")
	)
	vbox.add_child(btn_sanctuary)

	var btn_battle := _make_button(_tr("1v1 Auto-Battle Arena (Original)", "Arena Auto-Battle 1v1 (Original)"), "battle", 360, 50)
	btn_battle.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		GM.room_transition(5, "room_Battle")
	)
	vbox.add_child(btn_battle)

	var btn_opt := _make_button(_tr("System Settings", "Configurações do Sistema"), "secondary", 360, 50)
	btn_opt.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		GM.room_transition(0, "room_options_MainMenu")
	)
	vbox.add_child(btn_opt)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var meta := _make_label("v2.0.2 Remake · Aseprite HD Items · Auto-Chess RNG Engine", 11, COL_INK_MUTED)
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(meta)

	var stage_card := PanelContainer.new()
	stage_card.position = Vector2(512, 86)
	stage_card.custom_minimum_size = Vector2(520, 428)
	stage_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 24, 20))
	_root_layer.add_child(stage_card)

	var svbox := VBoxContainer.new()
	svbox.add_theme_constant_override("separation", 12)
	stage_card.add_child(svbox)

	var d: Dictionary = _active_data()
	var head_row := HBoxContainer.new()
	head_row.add_child(_make_label(_tr("Active Tamer Link", "Conexão Tamer Ativa"), 15, COL_ACCENT))
	var hsp := Control.new()
	hsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(hsp)
	head_row.add_child(_make_label(str(d["bits"]), 14, COL_GOLD))
	svbox.add_child(head_row)

	var center_stage := CenterContainer.new()
	center_stage.custom_minimum_size = Vector2(460, 210)
	_preview_tex_rect = TextureRect.new()
	_preview_tex_rect.texture = GM.tex(str(d["preview_spr"]), 0)
	_preview_tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_preview_tex_rect.custom_minimum_size = Vector2(180, 180)
	_preview_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center_stage.add_child(_preview_tex_rect)
	svbox.add_child(center_stage)

	var name_lbl := _make_label("%s   ·   Lv. %d   (LUK %d)" % [str(d["name"]), int(d["level"]), int(d["luk"])], 18, COL_INK, true)
	name_lbl.custom_minimum_size = Vector2(460, 26)
	svbox.add_child(name_lbl)
	svbox.add_child(_make_label(str(d["stage"]), 13, COL_INK_SEC, true))
	svbox.add_child(_make_label(str(d["status_note"]), 12, COL_INK_MUTED, true))
	svbox.add_child(_build_data_mode_strip())


# ---------- 2. 시스템 설정 (room_options_MainMenu) ----------
func _build_options_menu() -> void:
	var card := PanelContainer.new()
	card.position = Vector2(138, 36)
	card.custom_minimum_size = Vector2(800, 528)
	card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 28, 22))
	_root_layer.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_child(_make_label(_tr("System Settings", "Configurações do Sistema"), 20, COL_INK))
	var hsp := Control.new()
	hsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(hsp)

	var btn_back := _make_button(_tr("Back to Title", "Voltar ao Menu"), "secondary", 150, 48)
	btn_back.pressed.connect(func():
		GM.play_sound_fx("snd_ClickBack")
		GM.room_transition(0, "room_MainMenu")
	)
	header.add_child(btn_back)
	vbox.add_child(header)
	vbox.add_child(HSeparator.new())

	var lang_str := "English (ENG)" if int(GM.g["Language"]) == 0 else "Português (PT-BR)"
	vbox.add_child(_make_setting_row(
		_tr("Interface language", "Idioma da interface"),
		_tr("Switches menus, dialogues, and item descriptions", "Altera menus, diálogos e descrições"),
		lang_str, true, "Btn_Toggle_Language",
		func():
			GM.g["Language"] = 1 if int(GM.g["Language"]) == 0 else 0
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
	))

	var mus_on := bool(GM.g["music"])
	vbox.add_child(_make_setting_row(
		_tr("Background music", "Música de fundo"),
		_tr("Controls sanctuary, battle, and field soundtrack", "Controla a trilha sonora do jogo"),
		_tr("On", "Ligado") if mus_on else _tr("Off", "Desligado"), mus_on, "Btn_Toggle_Music",
		func():
			GM.g["music"] = not bool(GM.g["music"])
			if not GM.g["music"]:
				GM.audio_stop_all()
			else:
				GM.play_music("BGM_Lab")
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
	))

	var sfx_on := bool(GM.g["soundFX"])
	vbox.add_child(_make_setting_row(
		_tr("Sound effects", "Efeitos sonoros"),
		_tr("UI feedback clicks, attack hits, and alerts", "Cliques de interface e efeitos de batalha"),
		_tr("On", "Ligado") if sfx_on else _tr("Off", "Desligado"), sfx_on, "Btn_Toggle_SFX",
		func():
			GM.g["soundFX"] = not bool(GM.g["soundFX"])
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
	))

	var voice_on := bool(GM.g["DigimonVoice"])
	vbox.add_child(_make_setting_row(
		_tr("Digimon voices", "Vozes dos Digimon"),
		_tr("Partner battle cries and evolution voice clips", "Vozes de parceiros durante batalhas"),
		_tr("On", "Ligado") if voice_on else _tr("Off", "Desligado"), voice_on, "Btn_Toggle_Voice",
		func():
			GM.g["DigimonVoice"] = not bool(GM.g["DigimonVoice"])
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
	))

	var rm_on := bool(GM.g.get("reducedMotion", false))
	vbox.add_child(_make_setting_row(
		_tr("Reduced motion", "Reduzir movimento"),
		_tr("Replaces spring and slide animations with instant transitions", "Substitui animações de mola por transições instantâneas"),
		_tr("Enabled", "Ativado") if rm_on else _tr("Standard", "Padrão"), rm_on, "Btn_Toggle_ReducedMotion",
		func():
			GM.g["reducedMotion"] = not bool(GM.g.get("reducedMotion", false))
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
	))

	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	var btn_transfer := _make_button(_tr("Save Transfer", "Transferir Save"), "secondary", 220, 48)
	btn_transfer.pressed.connect(func(): show_toast(_tr("Save transfer code ready in slot 0", "Código pronto")))
	var btn_backup := _make_button(_tr("Load Backup File", "Carregar Backup"), "secondary", 220, 48)
	btn_backup.pressed.connect(func(): show_toast(_tr("No external backup file found", "Nenhum backup encontrado")))
	foot.add_child(btn_transfer)
	foot.add_child(btn_backup)
	vbox.add_child(foot)


func _make_setting_row(title: String, desc: String, state_txt: String, is_on: bool, btn_name: String, cb: Callable) -> PanelContainer:
	var row_panel := PanelContainer.new()
	row_panel.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_BORDER, 10, 1, 16, 10))
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	row_panel.add_child(hbox)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 2)
	left.add_child(_make_label(title, 15, COL_INK))
	left.add_child(_make_label(desc, 12, COL_INK_SEC))
	hbox.add_child(left)

	var toggle_btn := _make_button(state_txt, "active_seg" if is_on else "secondary", 164, 48)
	toggle_btn.name = btn_name
	toggle_btn.pressed.connect(cb)
	hbox.add_child(toggle_btn)
	return row_panel


# ---------- 3. 메인 육성 산토리움 HUD (room_MainRoom) ----------
func _build_sanctuary_hud() -> void:
	var d: Dictionary = _active_data()

	var hud_card := PanelContainer.new()
	hud_card.position = Vector2(16, 12)
	hud_card.custom_minimum_size = Vector2(540, 104)
	hud_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 12, 1, 14, 10))
	_root_layer.add_child(hud_card)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	hud_card.add_child(hbox)

	var avatar_box := PanelContainer.new()
	avatar_box.custom_minimum_size = Vector2(76, 76)
	avatar_box.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_ACCENT if int(d["level"]) > 0 else COL_BORDER, 10, 1, 6, 6))
	var icon := TextureRect.new()
	icon.texture = GM.tex("spr_Icons", int(d["icon_frame"]))
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = Vector2(64, 64)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_box.add_child(icon)
	hbox.add_child(avatar_box)

	var info_col := VBoxContainer.new()
	info_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_col.add_theme_constant_override("separation", 6)
	hbox.add_child(info_col)

	var top_line := HBoxContainer.new()
	top_line.add_theme_constant_override("separation", 10)
	var name_lbl := _make_label(str(d["name"]), 16, COL_INK, true)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.custom_minimum_size = Vector2(220, 22)
	top_line.add_child(name_lbl)

	var lv_lbl := _make_label("Lv. %d  ·  LUK %d" % [int(d["level"]), int(d["luk"])], 14, COL_GOLD)
	top_line.add_child(lv_lbl)
	info_col.add_child(top_line)

	var stage_lbl := _make_label(
		"%s  ·  Hunger %d%%  ·  Friend %.0f%%  ·  Injury %d  ·  W:%d / L:%d" % [
			str(d["stage"]),
			int(GM.g.get("hunger", 82)),
			float(GM.g.get("friendship", 75.0)),
			int(GM.g.get("injury", 0)),
			int(GM.g.get("wins", 18)),
			int(GM.g.get("losses", 2))
		],
		11, COL_INK_SEC, true
	)
	stage_lbl.custom_minimum_size = Vector2(400, 16)
	info_col.add_child(stage_lbl)

	var bars_row := HBoxContainer.new()
	bars_row.add_theme_constant_override("separation", 10)
	bars_row.add_child(_make_stat_bar("HP", int(d["hp"]), int(d["hp_max"]), COL_ACCENT))
	bars_row.add_child(_make_stat_bar("EN", int(d["en"]), int(d["en_max"]), COL_GOLD))
	bars_row.add_child(_make_stat_bar("XP", int(d["xp"]), int(d["xp_max"]), COL_FOCUS))
	info_col.add_child(bars_row)

	# 원작 생추어리 브이펫 케어 바 (obj_FoodBar, obj_Vitamins, obj_Clean, obj_Bandage, obj_Sleep)
	var care_bar := PanelContainer.new()
	care_bar.position = Vector2(16, 124)
	care_bar.custom_minimum_size = Vector2(540, 52)
	care_bar.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_ACCENT, 12, 1, 10, 6))
	_root_layer.add_child(care_bar)

	var chbox := HBoxContainer.new()
	chbox.add_theme_constant_override("separation", 8)
	care_bar.add_child(chbox)

	var care_items := [
		{"id": "food", "label": "🍖 Feed Meat", "kind": "primary"},
		{"id": "vitamin", "label": "💊 Vitamin (+EN)", "kind": "gold"},
		{"id": "clean", "label": "🧹 Clean", "kind": "secondary"},
		{"id": "bandage", "label": "🩹 Bandage", "kind": "secondary"},
		{"id": "sleep", "label": "💤 Sleep", "kind": "secondary"},
	]
	for ci in care_items:
		var cb := _make_button(str(ci["label"]), str(ci["kind"]), 96, 36)
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cid: String = str(ci["id"])
		cb.pressed.connect(func():
			var msg: String = GM.care_action(cid)
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
			show_toast(msg)
		)
		chbox.add_child(cb)

	var util_card := PanelContainer.new()
	util_card.position = Vector2(572, 12)
	util_card.custom_minimum_size = Vector2(488, 104)
	util_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 12, 1, 14, 10))
	_root_layer.add_child(util_card)

	var uvbox := VBoxContainer.new()
	uvbox.add_theme_constant_override("separation", 8)
	util_card.add_child(uvbox)

	var u_top := HBoxContainer.new()
	u_top.add_theme_constant_override("separation", 8)
	var bits_lbl := _make_label(str(d["bits"]), 16, COL_GOLD, true)
	bits_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	u_top.add_child(bits_lbl)

	var zoom_2x: bool = GM.world.scale.x > 2.2
	var cur_th_idx: int = clampi(int(GM.g.get("sanctuaryThemeIdx", 0)), 0, GMBackground.SANCTUARY_THEMES.size() - 1)
	var cur_th_name: String = str(GMBackground.SANCTUARY_THEMES[cur_th_idx]["name"])
	var btn_biome := _make_button("Biome: " + cur_th_name, "active_seg", 158, 40)
	btn_biome.name = "Btn_Sanctuary_Biome"
	btn_biome.pressed.connect(func():
		var next_idx := (cur_th_idx + 1) % GMBackground.SANCTUARY_THEMES.size()
		GM.g["sanctuaryThemeIdx"] = next_idx
		GM.bg.setup(GM.room_data)
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
		show_toast("Sanctuary Biome: " + str(GMBackground.SANCTUARY_THEMES[next_idx]["name"]))
	)
	u_top.add_child(btn_biome)

	var btn_zoom := _make_button("Zoom 2x" if zoom_2x else "Zoom 1x", "secondary", 82, 40)
	btn_zoom.pressed.connect(func():
		var next_s := 2.0 if GM.world.scale.x > 2.2 else 2.6
		GM.world.scale = Vector2(next_s, next_s)
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
	)
	u_top.add_child(btn_zoom)

	var btn_save := _make_button(_tr("Save", "Salvar"), "secondary", 64, 40)
	btn_save.pressed.connect(func():
		GM.save_game_state()
		GM.play_sound_fx("snd_Click06")
		show_toast(_tr("Sanctuary state saved to slot 0", "Progresso salvo no slot 0"))
	)
	u_top.add_child(btn_save)

	var btn_title := _make_button(_tr("Title", "Menu"), "secondary", 64, 40)
	btn_title.pressed.connect(func():
		GM.play_sound_fx("snd_ClickBack")
		GM.room_transition(0, "room_MainMenu")
	)
	u_top.add_child(btn_title)
	uvbox.add_child(u_top)
	uvbox.add_child(_build_data_mode_strip())

	var dock := PanelContainer.new()
	dock.position = Vector2(16, 512)
	dock.custom_minimum_size = Vector2(1044, 76)
	dock.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 12, 10))
	_root_layer.add_child(dock)

	var dhbox := HBoxContainer.new()
	dhbox.add_theme_constant_override("separation", 10)
	dock.add_child(dhbox)

	var actions := [
		{"id": "Digivice", "en": "Digivice & Quests", "pt": "Digivice e Missões", "room": "room_DigiVice", "kind": "secondary"},
		{"id": "Items", "en": "HD Items (750)", "pt": "Itens HD (750)", "room": "room_Battle_Items", "kind": "gold"},
		{"id": "Training", "en": "Lucky Training", "pt": "Treino da Sorte", "room": "room_SelectTraining", "kind": "secondary"},
		{"id": "Digivolve", "en": "Digivolve Tree", "pt": "Árvore de Evolução", "room": "room_Evo_Select", "kind": "primary"},
		{"id": "Database", "en": "663 Digimon DB", "pt": "Database (663)", "room": "room_Database", "kind": "secondary"},
		{"id": "Battle", "en": "World & Arena", "pt": "Mundo e Arena", "room": "room_Select_Map", "kind": "battle"},
	]
	for a in actions:
		var b := _make_button(_tr(a["en"], a["pt"]), a["kind"], 156, 54)
		b.name = "Btn_Dock_" + str(a["id"])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var target_room: String = str(a["room"])
		b.pressed.connect(func():
			GM.play_sound_fx("snd_Click06")
			GM.room_transition(0, target_room)
		)
		dhbox.add_child(b)


func _make_stat_bar(tag: String, val: int, max_val: int, fill_col: Color) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)

	var lbl := _make_label("%s %d/%d" % [tag, val, max_val], 11, COL_INK_SEC, true)
	box.add_child(lbl)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(115, 8)
	bar.max_value = maxi(max_val, 1)
	bar.value = clampi(val, 0, maxi(max_val, 1))
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _box(COL_SURFACE, COL_BORDER, 4, 1, 0, 0))
	bar.add_theme_stylebox_override("fill", _box(fill_col, fill_col, 4, 0, 0, 0))
	box.add_child(bar)
	return box


# ---------- 4. 단판 오토체스형 운빨 자동전투 HUD (room_Battle) ----------
func _build_battle_hud() -> void:
	var b: Dictionary = GM.battle
	if b.is_empty():
		GM.init_battle_state()
		b = GM.battle

	# 1) 상단 좌측: 아군 디지몬 상태 & AI 기동 배지
	var p_card := PanelContainer.new()
	p_card.position = Vector2(14, 10)
	p_card.custom_minimum_size = Vector2(348, 108)
	p_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_ACCENT, 12, 1, 12, 8))
	_root_layer.add_child(p_card)

	var p_hbox := HBoxContainer.new()
	p_hbox.add_theme_constant_override("separation", 10)
	p_card.add_child(p_hbox)

	var p_icon := TextureRect.new()
	p_icon.texture = GM.tex("spr_Icons", int(b["p_icon"]))
	p_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p_icon.custom_minimum_size = Vector2(56, 56)
	p_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p_hbox.add_child(p_icon)

	var p_col := VBoxContainer.new()
	p_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p_col.add_theme_constant_override("separation", 3)
	p_hbox.add_child(p_col)

	var p_top := HBoxContainer.new()
	var p_name_lbl := _make_label("%s (Lv.%d)" % [str(b["p_name"]), int(b["p_lv"])], 14, COL_INK, true)
	p_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p_top.add_child(p_name_lbl)
	_btl_p_ai_lbl = _make_label("AI: " + str(b["p_ai_state"]), 11, COL_ACCENT)
	p_top.add_child(_btl_p_ai_lbl)
	p_col.add_child(p_top)

	p_col.add_child(_make_label("ATK %d · DEF %d · SPD %d · LUK %d" % [int(b["p_atk"]), int(b["p_def"]), int(b["p_spd"]), int(b["p_luk"])], 11, COL_INK_SEC, true))

	_btl_p_hp_lbl = _make_label("HP %d / %d" % [int(b["p_hp"]), int(b["p_hp_max"])], 11, COL_ACCENT)
	p_col.add_child(_btl_p_hp_lbl)
	_btl_p_hp_bar = ProgressBar.new()
	_btl_p_hp_bar.custom_minimum_size = Vector2(240, 8)
	_btl_p_hp_bar.max_value = int(b["p_hp_max"])
	_btl_p_hp_bar.value = int(b["p_hp"])
	_btl_p_hp_bar.show_percentage = false
	_btl_p_hp_bar.add_theme_stylebox_override("background", _box(COL_SURFACE, COL_BORDER, 4, 1, 0, 0))
	_btl_p_hp_bar.add_theme_stylebox_override("fill", _box(COL_ACCENT, COL_ACCENT, 4, 0, 0, 0))
	p_col.add_child(_btl_p_hp_bar)

	_btl_p_sp_bar = ProgressBar.new()
	_btl_p_sp_bar.custom_minimum_size = Vector2(240, 6)
	_btl_p_sp_bar.max_value = 100
	_btl_p_sp_bar.value = float(b["p_sp"])
	_btl_p_sp_bar.show_percentage = false
	_btl_p_sp_bar.add_theme_stylebox_override("background", _box(COL_SURFACE, COL_BORDER, 3, 1, 0, 0))
	_btl_p_sp_bar.add_theme_stylebox_override("fill", _box(COL_GOLD, COL_GOLD, 3, 0, 0, 0))
	p_col.add_child(_btl_p_sp_bar)

	# 2) 상단 중앙: 원본 실시간 전투 전광판 (Stage · Combo · Block Gauge · Combat Log)
	var c_card := PanelContainer.new()
	c_card.position = Vector2(372, 10)
	c_card.custom_minimum_size = Vector2(332, 108)
	c_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_GOLD, 12, 1, 12, 8))
	_root_layer.add_child(c_card)

	var c_col := VBoxContainer.new()
	c_col.add_theme_constant_override("separation", 3)
	c_card.add_child(c_col)

	var c_head := _make_label("REAL-TIME AUTO BATTLE  ·  " + str(GM.g.get("battleZone", "ARENA")).to_upper(), 11, COL_INK_SEC)
	c_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_col.add_child(c_head)

	_btl_slot_lbl = _make_label("⚔️ COMBO: %d HIT  |  🛡️ BLOCK: %.0f%%" % [int(b.get("p_combo", 0)), float(b.get("p_block", 100.0))], 14, COL_GOLD, true)
	_btl_slot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_col.add_child(_btl_slot_lbl)

	_btl_dice_lbl = _make_label("ACTION: %s  (Dodges: %d · Blocks: %d)" % [str(b.get("last_tier", "READY")), int(b.get("p_dodge_count", 0)), int(b.get("p_parry_count", 0))], 12, COL_ACCENT, true)
	_btl_dice_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_col.add_child(_btl_dice_lbl)

	_btl_log_lbl = _make_label(str(b["last_log"]), 11, COL_INK, true)
	_btl_log_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_col.add_child(_btl_log_lbl)

	# 3) 상단 우측: 적군 보스 상태 & AI 기동 배지
	var e_card := PanelContainer.new()
	e_card.position = Vector2(714, 10)
	e_card.custom_minimum_size = Vector2(348, 108)
	e_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BATTLE, 12, 1, 12, 8))
	_root_layer.add_child(e_card)

	var e_hbox := HBoxContainer.new()
	e_hbox.add_theme_constant_override("separation", 10)
	e_card.add_child(e_hbox)

	var e_col := VBoxContainer.new()
	e_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	e_col.add_theme_constant_override("separation", 3)
	e_hbox.add_child(e_col)

	var e_top := HBoxContainer.new()
	var e_name_lbl := _make_label("%s (Lv.%d)" % [str(b["e_name"]), int(b["e_lv"])], 14, COL_INK, true)
	e_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	e_top.add_child(e_name_lbl)
	_btl_e_ai_lbl = _make_label("AI: " + str(b["e_ai_state"]), 11, COL_BATTLE)
	e_top.add_child(_btl_e_ai_lbl)
	e_col.add_child(e_top)

	e_col.add_child(_make_label("ATK %d · DEF %d · SPD %d · LUK %d" % [int(b["e_atk"]), int(b["e_def"]), int(b["e_spd"]), int(b["e_luk"])], 11, COL_INK_SEC, true))

	_btl_e_hp_lbl = _make_label("HP %d / %d" % [int(b["e_hp"]), int(b["e_hp_max"])], 11, COL_BATTLE)
	e_col.add_child(_btl_e_hp_lbl)
	_btl_e_hp_bar = ProgressBar.new()
	_btl_e_hp_bar.custom_minimum_size = Vector2(240, 8)
	_btl_e_hp_bar.max_value = int(b["e_hp_max"])
	_btl_e_hp_bar.value = int(b["e_hp"])
	_btl_e_hp_bar.show_percentage = false
	_btl_e_hp_bar.add_theme_stylebox_override("background", _box(COL_SURFACE, COL_BORDER, 4, 1, 0, 0))
	_btl_e_hp_bar.add_theme_stylebox_override("fill", _box(COL_BATTLE, COL_BATTLE, 4, 0, 0, 0))
	e_col.add_child(_btl_e_hp_bar)

	_btl_e_sp_bar = ProgressBar.new()
	_btl_e_sp_bar.custom_minimum_size = Vector2(240, 6)
	_btl_e_sp_bar.max_value = 100
	_btl_e_sp_bar.value = float(b["e_sp"])
	_btl_e_sp_bar.show_percentage = false
	_btl_e_sp_bar.add_theme_stylebox_override("background", _box(COL_SURFACE, COL_BORDER, 3, 1, 0, 0))
	_btl_e_sp_bar.add_theme_stylebox_override("fill", _box(COL_GOLD, COL_GOLD, 3, 0, 0, 0))
	e_col.add_child(_btl_e_sp_bar)

	var e_icon := TextureRect.new()
	e_icon.texture = GM.tex("spr_Icons", int(b["e_icon"]))
	e_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	e_icon.custom_minimum_size = Vector2(56, 56)
	e_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	e_hbox.add_child(e_icon)

	# 4) 단판 승패 결정 시 중앙 결과 모달 배너
	_btl_result_card = PanelContainer.new()
	_btl_result_card.position = Vector2(288, 134)
	_btl_result_card.custom_minimum_size = Vector2(500, 64)
	_btl_result_card.add_theme_stylebox_override("panel", _box(COL_BG_BASE, COL_GOLD, 12, 2, 18, 10))
	_btl_result_card.visible = bool(b.get("finished", false))
	_btl_result_lbl = _make_label(str(b.get("result_banner", "")), 16, COL_GOLD)
	_btl_result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_btl_result_card.add_child(_btl_result_lbl)
	_root_layer.add_child(_btl_result_card)

	# 5) 하단: 4슬롯 자동 스킬 RNG 덱 + 오토배틀 전술 컨트롤러
	var bottom_bar := PanelContainer.new()
	bottom_bar.position = Vector2(14, 476)
	bottom_bar.custom_minimum_size = Vector2(1048, 114)
	bottom_bar.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 12, 10))
	_root_layer.add_child(bottom_bar)

	var b_hbox := HBoxContainer.new()
	b_hbox.add_theme_constant_override("separation", 10)
	bottom_bar.add_child(b_hbox)

	var skills: Array = b["skills"]
	for idx in skills.size():
		var sk: Dictionary = skills[idx]
		var sk_card := PanelContainer.new()
		sk_card.custom_minimum_size = Vector2(174, 92)
		sk_card.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_GOLD if idx == 3 else COL_BORDER, 10, 1, 10, 8))
		var sv := VBoxContainer.new()
		sv.add_theme_constant_override("separation", 4)
		sk_card.add_child(sv)

		var stitle := _make_label("[AUTO] " + str(sk["name"]), 13, COL_GOLD if idx == 3 else COL_INK, true)
		sv.add_child(stitle)
		sv.add_child(_make_label(str(sk["tag"]), 11, COL_INK_SEC, true))

		var roll_lbl := _make_label(str(sk["last_roll"]), 11, COL_ACCENT, true)
		sv.add_child(roll_lbl)
		_btl_skill_rolls.append(roll_lbl)

		var cd_bar := ProgressBar.new()
		cd_bar.custom_minimum_size = Vector2(150, 7)
		cd_bar.max_value = 100
		cd_bar.value = 100
		cd_bar.show_percentage = false
		cd_bar.add_theme_stylebox_override("background", _box(COL_BG_BASE, COL_BORDER, 3, 1, 0, 0))
		cd_bar.add_theme_stylebox_override("fill", _box(COL_GOLD if idx == 3 else COL_ACCENT, COL_ACCENT, 3, 0, 0, 0))
		sv.add_child(cd_bar)
		_btl_skill_bars.append(cd_bar)
		b_hbox.add_child(sk_card)

	# 우측 컨트롤 컬럼 (Auto ON/OFF, AI Tactic, 2x Speed, Rematch, Sanctuary)
	var ctrl_col := VBoxContainer.new()
	ctrl_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctrl_col.add_theme_constant_override("separation", 6)
	b_hbox.add_child(ctrl_col)

	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 6)
	var auto_on := bool(b.get("auto_skill", true))
	var btn_auto := _make_button("AUTO: ON" if auto_on else "AUTO: OFF", "primary" if auto_on else "secondary", 96, 42)
	btn_auto.pressed.connect(func():
		GM.battle["auto_skill"] = not bool(GM.battle.get("auto_skill", true))
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
	)
	row1.add_child(btn_auto)

	var spd2x := bool(b.get("speed2x", true))
	var btn_spd := _make_button("2x SPD" if spd2x else "1x SPD", "active_seg" if spd2x else "secondary", 76, 42)
	btn_spd.pressed.connect(func():
		GM.battle["speed2x"] = not bool(GM.battle.get("speed2x", true))
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
	)
	row1.add_child(btn_spd)

	var cur_b_bg: String = str(GM.g.get("BattleBG", "bg_Btl_Magma_Mountain"))
	var btn_stage_bg := _make_button("Stage BG", "secondary", 92, 42)
	btn_stage_bg.name = "Btn_Battle_StageBG"
	btn_stage_bg.pressed.connect(func():
		var idx := 0
		for i in GMBackground.BATTLE_ARENAS.size():
			if str(GMBackground.BATTLE_ARENAS[i]["bg"]) == cur_b_bg:
				idx = (i + 1) % GMBackground.BATTLE_ARENAS.size()
				break
		var next_arena: Dictionary = GMBackground.BATTLE_ARENAS[idx]
		GM.g["BattleBG"] = str(next_arena["bg"])
		GM.g["battleZone"] = str(next_arena["zone"])
		GM.bg.setup(GM.room_data)
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
		show_toast("Battle Stage: " + str(next_arena["zone"]))
	)
	row1.add_child(btn_stage_bg)
	ctrl_col.add_child(row1)

	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	var tactic: String = str(b.get("ai_tactic", "balanced"))
	var btn_tac := _make_button("AI: " + tactic.to_upper(), "gold", 106, 42)
	btn_tac.pressed.connect(func():
		var order := ["balanced", "evasive", "ranged"]
		var next_i := (order.find(tactic) + 1) % order.size()
		GM.battle["ai_tactic"] = order[next_i]
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
	)
	row2.add_child(btn_tac)

	var btn_rematch := _make_button("Rematch", "battle", 88, 42)
	btn_rematch.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		GM.init_battle_state()
		GM.room_goto("room_Battle")
	)
	row2.add_child(btn_rematch)

	var btn_exit := _make_button("Exit", "secondary", 70, 42)
	btn_exit.pressed.connect(func():
		GM.play_sound_fx("snd_ClickBack")
		GM.room_transition(0, "room_MainRoom")
	)
	row2.add_child(btn_exit)
	ctrl_col.add_child(row2)


func _sync_battle_hud_live() -> void:
	var b: Dictionary = GM.battle
	if b.is_empty():
		return
	if is_instance_valid(_btl_p_hp_bar):
		_btl_p_hp_bar.max_value = maxi(1, int(b["p_hp_max"]))
		_btl_p_hp_bar.value = int(b["p_hp"])
		_btl_p_hp_lbl.text = "HP %d / %d  (SP: %.0f%%)" % [int(b["p_hp"]), int(b["p_hp_max"]), float(b["p_sp"])]
		_btl_p_sp_bar.value = float(b["p_sp"])
		_btl_p_ai_lbl.text = "AI: " + str(b["p_ai_state"])
	if is_instance_valid(_btl_e_hp_bar):
		_btl_e_hp_bar.max_value = maxi(1, int(b["e_hp_max"]))
		_btl_e_hp_bar.value = int(b["e_hp"])
		_btl_e_hp_lbl.text = "HP %d / %d  (SP: %.0f%%)" % [int(b["e_hp"]), int(b["e_hp_max"]), float(b["e_sp"])]
		_btl_e_sp_bar.value = float(b["e_sp"])
		_btl_e_ai_lbl.text = "AI: " + str(b["e_ai_state"])
	if is_instance_valid(_btl_slot_lbl):
		_btl_slot_lbl.text = "⚔️ COMBO: %d HIT  |  🛡️ BLOCK: %.0f%%" % [int(b.get("p_combo", 0)), float(b.get("p_block", 100.0))]
		_btl_dice_lbl.text = "ACTION: %s  (Dodges: %d · Blocks: %d)" % [str(b.get("last_tier", "READY")), int(b.get("p_dodge_count", 0)), int(b.get("p_parry_count", 0))]
		_btl_log_lbl.text = str(b["last_log"])
	if is_instance_valid(_btl_result_card):
		_btl_result_card.visible = bool(b.get("finished", false))
		_btl_result_lbl.text = str(b.get("result_banner", ""))

	var skills: Array = b["skills"]
	for i in mini(skills.size(), _btl_skill_bars.size()):
		var sk: Dictionary = skills[i]
		var bar: ProgressBar = _btl_skill_bars[i]
		var r_lbl: Label = _btl_skill_rolls[i]
		if i == 3:
			bar.value = float(b["p_sp"])
		else:
			var ratio: float = 1.0 - clampf(float(sk["cd"]) / maxf(0.1, float(sk["cd_max"])), 0.0, 1.0)
			bar.value = ratio * 100.0
		r_lbl.text = str(sk["last_roll"])


# ---------- 5. 서브룸 공통 내비게이션 & 운빨 훈련소 / Aseprite 아이템 리마스터 ----------
func _build_subroom_hud(room_name: String) -> void:
	var bar := PanelContainer.new()
	bar.position = Vector2(16, 12)
	bar.custom_minimum_size = Vector2(1044, 60)
	bar.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 12, 1, 16, 8))
	_root_layer.add_child(bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	bar.add_child(hbox)

	var clean_title := room_name.trim_prefix("room_").replace("_", " ")
	if room_name == "room_Battle_Items":
		clean_title = "Aseprite HD Item Remaster & Lucky Forge"
	elif room_name == "room_SelectTraining":
		clean_title = "Stat × RNG Jackpot Training Deck"
	hbox.add_child(_make_label("D-Terminal  /  " + clean_title, 16, COL_ACCENT))

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(sp)

	var d: Dictionary = _active_data()
	hbox.add_child(_make_label("%s (Lv.%d · LUK %d)  ·  %s" % [str(d["name"]), int(d["level"]), int(d["luk"]), str(d["bits"])], 13, COL_INK_SEC, true))

	var btn_return := _make_button(_tr("Return to Sanctuary", "Voltar ao Santuário"), "primary", 190, 44)
	btn_return.name = "Btn_Return_Sanctuary"
	btn_return.pressed.connect(func():
		GM.play_sound_fx("snd_ClickBack")
		GM.room_transition(0, "room_MainRoom")
	)
	hbox.add_child(btn_return)

	if room_name == "room_SelectTraining":
		_build_training_deck(d)
	elif room_name == "room_Battle_Items":
		_build_aseprite_items_deck(d)
	elif room_name in ["room_Evo_Select", "room_Evolution", "room_Jogress"]:
		_build_evolution_deck(d)
	elif room_name.begins_with("room_Database") or room_name.begins_with("room_Bios"):
		_build_database_deck(d)
	elif room_name in ["room_DigiVice", "room_Quest_Log", "room_Tamer_Info", "room_Tamer_Skills"]:
		_build_digivice_quest_deck(d)
	else:
		_build_world_map_deck(d, room_name)


func _build_aseprite_items_deck(d: Dictionary) -> void:
	# 좌측: Aseprite 1.3.18 HD 리메이크 아이템 8종 그리드
	var left_card := PanelContainer.new()
	left_card.position = Vector2(24, 86)
	left_card.custom_minimum_size = Vector2(616, 494)
	left_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 20, 16))
	_root_layer.add_child(left_card)

	var lvbox := VBoxContainer.new()
	lvbox.add_theme_constant_override("separation", 10)
	left_card.add_child(lvbox)

	var head := HBoxContainer.new()
	head.add_child(_make_label("Aseprite 1.3.18 Remastered Items (52×52 EPX + Specular + Halo)", 16, COL_INK))
	var hsp := Control.new()
	hsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(hsp)
	head.add_child(_make_label("36 Sprites Remade", 12, COL_GOLD))
	lvbox.add_child(head)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	lvbox.add_child(grid)

	for i in REMADE_ITEMS.size():
		var it: Dictionary = REMADE_ITEMS[i]
		var is_sel: bool = (i == _selected_item_idx)
		var icard := PanelContainer.new()
		icard.custom_minimum_size = Vector2(280, 96)
		icard.add_theme_stylebox_override("panel", _box(COL_SURFACE_HOVER if is_sel else COL_SURFACE, it["col"] if is_sel else COL_BORDER, 10, 2 if is_sel else 1, 12, 8))

		var ihbox := HBoxContainer.new()
		ihbox.add_theme_constant_override("separation", 12)
		icard.add_child(ihbox)

		var icon_box := PanelContainer.new()
		icon_box.custom_minimum_size = Vector2(68, 68)
		icon_box.add_theme_stylebox_override("panel", _box(COL_BG_BASE, it["col"], 8, 1, 4, 4))
		var tex_rect := TextureRect.new()
		tex_rect.texture = GM.tex_item(int(it["id"]), not _compare_legacy_item)
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex_rect.custom_minimum_size = Vector2(56, 56)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_box.add_child(tex_rect)
		ihbox.add_child(icon_box)

		var icol := VBoxContainer.new()
		icol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icol.add_theme_constant_override("separation", 2)
		ihbox.add_child(icol)

		icol.add_child(_make_label("%s  [%s]" % [str(it["name"]), str(it["tier"])], 13, it["col"], true))
		icol.add_child(_make_label(str(it["stat"]), 11, COL_INK, true))
		icol.add_child(_make_label("🎲 " + str(it["roll"]), 11, COL_INK_SEC, true))

		var btn_use := _make_button("Inspect / Equip", "active_seg" if is_sel else "secondary", 140, 32)
		var idx_capture: int = i
		btn_use.pressed.connect(func():
			_selected_item_idx = idx_capture
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
		)
		icol.add_child(btn_use)
		grid.add_child(icard)

	# 우측: Aseprite Before/After 비교 & 운빨 옵션 재감정(Lucky Re-Roll) 패널
	var right_card := PanelContainer.new()
	right_card.position = Vector2(654, 86)
	right_card.custom_minimum_size = Vector2(406, 494)
	right_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_GOLD, 14, 1, 20, 16))
	_root_layer.add_child(right_card)

	var rvbox := VBoxContainer.new()
	rvbox.add_theme_constant_override("separation", 12)
	right_card.add_child(rvbox)

	var sel: Dictionary = REMADE_ITEMS[_selected_item_idx]
	rvbox.add_child(_make_label("Aseprite Quality Comparison", 16, COL_GOLD))

	var cmp_row := HBoxContainer.new()
	cmp_row.add_theme_constant_override("separation", 16)
	rvbox.add_child(cmp_row)

	# Legacy 26x26 박스
	var leg_box := PanelContainer.new()
	leg_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leg_box.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_BORDER, 10, 1, 12, 10))
	var leg_v := VBoxContainer.new()
	leg_v.alignment = BoxContainer.ALIGNMENT_CENTER
	leg_box.add_child(leg_v)
	leg_v.add_child(_make_label("Original (26×26)", 12, COL_INK_MUTED))
	var leg_tex := TextureRect.new()
	leg_tex.texture = GM.tex("spr_Items", int(sel["id"]))
	leg_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	leg_tex.custom_minimum_size = Vector2(96, 96)
	leg_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	leg_v.add_child(leg_tex)
	cmp_row.add_child(leg_box)

	# Aseprite HD 60x60 박스
	var hd_box := PanelContainer.new()
	hd_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hd_box.add_theme_stylebox_override("panel", _box(COL_SURFACE_HOVER, COL_ACCENT, 10, 2, 12, 10))
	var hd_v := VBoxContainer.new()
	hd_v.alignment = BoxContainer.ALIGNMENT_CENTER
	hd_box.add_child(hd_v)
	hd_v.add_child(_make_label("Aseprite Remake (60×60)", 12, COL_ACCENT))
	var hd_tex := TextureRect.new()
	hd_tex.texture = GM.tex_item(int(sel["id"]), true)
	hd_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hd_tex.custom_minimum_size = Vector2(96, 96)
	hd_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hd_v.add_child(hd_tex)
	cmp_row.add_child(hd_box)

	rvbox.add_child(_make_label(str(sel["name"]) + "  ·  " + str(sel["tier"]), 16, COL_INK))
	rvbox.add_child(_make_label("Base Stats: " + str(sel["stat"]), 13, COL_ACCENT))
	rvbox.add_child(_make_label("RNG Effect: " + str(sel["roll"]), 12, COL_GOLD))
	rvbox.add_child(_make_label("Source: out/aseprite/item_%d_remake.aseprite" % int(sel["id"]), 11, COL_INK_MUTED))

	var btn_reroll := _make_button("🎲 Lucky Option Re-Roll (500 BIT)", "gold", 350, 48)
	btn_reroll.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		show_toast("★ 777 MYTHIC AFFIX ROLLED! (+28 LUK & +1.5x Crit Multiplier)")
	)
	rvbox.add_child(btn_reroll)

	var btn_equip := _make_button("Equip & Enter 1v1 Auto-Battle Arena", "battle", 350, 48)
	btn_equip.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		GM.room_transition(5, "room_Battle")
	)
	rvbox.add_child(btn_equip)


func _build_training_deck(d: Dictionary) -> void:
	var left_card := PanelContainer.new()
	left_card.position = Vector2(36, 92)
	left_card.custom_minimum_size = Vector2(548, 480)
	left_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 22, 18))
	_root_layer.add_child(left_card)

	var lvbox := VBoxContainer.new()
	lvbox.add_theme_constant_override("separation", 12)
	left_card.add_child(lvbox)

	lvbox.add_child(_make_label(_tr("Original Gym Training Protocol (obj_Training_CTRL)", "Protocolo de Treino Original (Gym)"), 18, COL_INK))
	lvbox.add_child(_make_label(_tr("Consumes Energy (EN) to permanently train HP, ATK, DEF, SP.ATK, SP.DEF, or SPD.", "Consome Energia (EN) para treinar atributos permanentemente."), 12, COL_INK_SEC))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	lvbox.add_child(grid)

	var modules := [
		{"stat": "hp_max", "title": "HP Endurance Drill", "sub": "Permanent +80 Max HP (-15 EN)", "gain": 80, "kind": "primary"},
		{"stat": "atk", "title": "ATK Strike Dummy", "sub": "Permanent +14 Physical ATK (-15 EN)", "gain": 14, "kind": "secondary"},
		{"stat": "def", "title": "DEF Iron Shield", "sub": "Permanent +12 Physical DEF (-15 EN)", "gain": 12, "kind": "secondary"},
		{"stat": "sp_atk", "title": "SP.ATK Elemental Core", "sub": "Permanent +14 Elemental SP.ATK (-15 EN)", "gain": 14, "kind": "secondary"},
		{"stat": "spd", "title": "SPD Agility Sprint", "sub": "Permanent +10 Speed & WaitTimer (-15 EN)", "gain": 10, "kind": "secondary"},
		{"stat": "bulk", "title": "Bulk Gym Coach (All Stats)", "sub": "Consumes 50 EN → All Stats Boost!", "gain": 25, "kind": "gold"},
	]
	for m in modules:
		var m_card := PanelContainer.new()
		m_card.custom_minimum_size = Vector2(244, 102)
		m_card.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_BORDER, 10, 1, 14, 10))
		var mv := VBoxContainer.new()
		mv.add_theme_constant_override("separation", 6)
		m_card.add_child(mv)
		mv.add_child(_make_label(str(m["title"]), 14, COL_INK, true))
		mv.add_child(_make_label(str(m["sub"]), 11, COL_INK_SEC, true))
		var btn_launch := _make_button("🏋️ Start Training", str(m["kind"]), 210, 40)
		var st_key: String = str(m["stat"])
		var st_gain: int = int(m["gain"])
		var t_title: String = str(m["title"])
		btn_launch.pressed.connect(func():
			GM.play_sound_fx("snd_Click06")
			if st_key == "bulk":
				GM.g["hp_max"] = int(GM.g["hp_max"]) + 160
				GM.g["hp"] = int(GM.g["hp_max"])
				GM.g["atk"] = int(GM.g["atk"]) + 24
				GM.g["def"] = int(GM.g["def"]) + 20
				GM.g["sp_atk"] = int(GM.g["sp_atk"]) + 24
				GM.g["spd"] = int(GM.g["spd"]) + 16
				GM.g["en"] = maxi(0, int(GM.g.get("en", 100)) - 30)
			else:
				GM.g[st_key] = int(GM.g.get(st_key, 200)) + st_gain
				if st_key == "hp_max":
					GM.g["hp"] = int(GM.g["hp_max"])
				GM.g["en"] = maxi(0, int(GM.g.get("en", 100)) - 15)
			GM.init_battle_state()
			rebuild_for_room(_current_room)
			show_toast("🏋️ Training Complete: " + t_title + "!")
		)
		mv.add_child(btn_launch)
		grid.add_child(m_card)

	var right_card := PanelContainer.new()
	right_card.position = Vector2(604, 92)
	right_card.custom_minimum_size = Vector2(436, 480)
	right_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 22, 18))
	_root_layer.add_child(right_card)

	var rvbox := VBoxContainer.new()
	rvbox.add_theme_constant_override("separation", 12)
	right_card.add_child(rvbox)

	var p_head := HBoxContainer.new()
	p_head.add_theme_constant_override("separation", 12)
	var p_icon := TextureRect.new()
	p_icon.texture = GM.tex("spr_Icons", int(d["icon_frame"]))
	p_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p_icon.custom_minimum_size = Vector2(48, 48)
	p_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p_head.add_child(p_icon)

	var p_titles := VBoxContainer.new()
	p_titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p_titles.add_child(_make_label(str(d["name"]), 16, COL_INK, true))
	p_titles.add_child(_make_label("Combat Stats & Luck · Lv. %d" % int(d["level"]), 12, COL_GOLD))
	p_head.add_child(p_titles)
	rvbox.add_child(p_head)
	rvbox.add_child(HSeparator.new())

	var stats_list := [
		{"k": "HP Capacity", "v": int(d["hp"]), "max": maxi(int(d["hp_max"]), 100), "col": COL_ACCENT},
		{"k": "Attack (ATK)", "v": int(d["atk"]), "max": 1000, "col": COL_BATTLE},
		{"k": "Defense (DEF)", "v": int(d["def"]), "max": 1000, "col": COL_FOCUS},
		{"k": "Sp. Attack", "v": int(d["sp_atk"]), "max": 1000, "col": COL_GOLD},
		{"k": "Speed (Jump Evade)", "v": int(d["spd"]), "max": 1000, "col": COL_ACCENT},
		{"k": "Luck (777 Jackpot%)", "v": int(d["luk"]), "max": 100, "col": COL_GOLD},
	]
	for st in stats_list:
		rvbox.add_child(_make_stat_bar(str(st["k"]), int(st["v"]), int(st["max"]), st["col"]))

	rvbox.add_child(HSeparator.new())
	rvbox.add_child(_build_data_mode_strip())


# ---------- 6. break-ui 데이터 상태 전환 스트립 ----------
func _build_data_mode_strip() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(_make_label("Data fixture:", 11, COL_INK_MUTED))

	var cur_mode: String = str(GM.g.get("dataMode", "demo"))
	for m in [
		{"id": "demo", "label": "Demo data"},
		{"id": "worst", "label": "Worst case"},
		{"id": "empty", "label": "Empty state"},
	]:
		var mid: String = str(m["id"])
		var b := _make_button(str(m["label"]), "active_seg" if cur_mode == mid else "secondary", 96, 36)
		b.name = "Btn_Data_" + mid
		b.add_theme_font_size_override("font_size", 12)
		b.pressed.connect(func():
			GM.g["dataMode"] = mid
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
		)
		row.add_child(b)
	return row


# ---------- 7. 436개 진화 루트 실시간 진화 트리 & 운빨 돌연변이 진화 (room_Evo_Select) ----------
func _build_evolution_deck(d: Dictionary) -> void:
	var pid: int = int(GM.g.get("partnerId", 5))
	var evos: Array = GM.db.get("evolutions", {}).get(str(pid), [])
	if evos.is_empty():
		evos = GM.db.get("evolutions", {}).get("5", [])

	var left_card := PanelContainer.new()
	left_card.position = Vector2(24, 86)
	left_card.custom_minimum_size = Vector2(640, 494)
	left_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_ACCENT, 14, 1, 20, 16))
	_root_layer.add_child(left_card)

	var lvbox := VBoxContainer.new()
	lvbox.add_theme_constant_override("separation", 10)
	left_card.add_child(lvbox)

	lvbox.add_child(_make_label("Digivolution Matrix  ·  Current: %s (ID #%d)" % [str(d["name"]), pid], 17, COL_INK))
	lvbox.add_child(_make_label("436 Evolution Routes Extracted · Standard Evolve or 🎲 Lucky Mutation Gamble!", 12, COL_INK_SEC))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	lvbox.add_child(grid)

	for i in mini(evos.size(), 6):
		var ev: Dictionary = evos[i]
		var to_id: int = int(ev["to_id"])
		var ecard := PanelContainer.new()
		ecard.custom_minimum_size = Vector2(292, 120)
		ecard.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_GOLD if i == 0 else COL_BORDER, 10, 1, 12, 8))

		var ehbox := HBoxContainer.new()
		ehbox.add_theme_constant_override("separation", 10)
		ecard.add_child(ehbox)

		var icon_rect := TextureRect.new()
		icon_rect.texture = GM.tex("spr_Icons", to_id)
		icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_rect.custom_minimum_size = Vector2(56, 56)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ehbox.add_child(icon_rect)

		var ecol := VBoxContainer.new()
		ecol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ecol.add_theme_constant_override("separation", 3)
		ehbox.add_child(ecol)

		ecol.add_child(_make_label("%s (#%d)" % [str(ev["name"]), to_id], 14, COL_GOLD if i == 0 else COL_INK, true))
		ecol.add_child(_make_label("%s · %s · Req: %s" % [str(ev["stage"]), str(ev["attr"]), str(ev["cond"])], 11, COL_INK_SEC, true))
		ecol.add_child(_make_label("+%d HP · +%d ATK · +%d DEF" % [int(ev["bonus_hp"]), int(ev["bonus_atk"]), int(ev["bonus_def"])], 11, COL_ACCENT, true))

		var btn_evo := _make_button("⚡ Digivolve Now", "primary" if i == 0 else "secondary", 160, 34)
		var b_hp: int = maxi(400, int(ev["bonus_hp"]))
		var b_atk: int = maxi(65, int(ev["bonus_atk"]))
		var b_def: int = maxi(55, int(ev["bonus_def"]))
		var b_sp: int = maxi(65, int(ev["bonus_sp_atk"]))
		var target_name: String = str(ev["name"])
		btn_evo.pressed.connect(func():
			GM.play_sound_fx("snd_Click06")
			GM.evolve_partner(to_id, b_hp, b_atk, b_def, b_sp)
			rebuild_for_room(_current_room)
			show_toast("★ DIGIVOLUTION COMPLETE! → " + target_name + "!")
		)
		ecol.add_child(btn_evo)
		grid.add_child(ecard)

	# 우측: 현재 파트너 프리뷰 & 운빨 초진화(777 Random Mega Gamble)
	var right_card := PanelContainer.new()
	right_card.position = Vector2(680, 86)
	right_card.custom_minimum_size = Vector2(380, 494)
	right_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_GOLD, 14, 1, 20, 16))
	_root_layer.add_child(right_card)

	var rvbox := VBoxContainer.new()
	rvbox.add_theme_constant_override("separation", 12)
	right_card.add_child(rvbox)

	rvbox.add_child(_make_label("Active Partner Core", 16, COL_GOLD))
	var center_p := CenterContainer.new()
	center_p.custom_minimum_size = Vector2(330, 170)
	_preview_tex_rect = TextureRect.new()
	_preview_tex_rect.texture = GM.tex(str(d["preview_spr"]), 0)
	_preview_tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_preview_tex_rect.custom_minimum_size = Vector2(156, 156)
	_preview_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center_p.add_child(_preview_tex_rect)
	rvbox.add_child(center_p)

	rvbox.add_child(_make_label("%s  ·  Lv. %d" % [str(d["name"]), int(d["level"])], 17, COL_INK, true))
	rvbox.add_child(_make_label("HP %d · ATK %d · DEF %d · SPD %d · LUK %d" % [int(d["hp_max"]), int(d["atk"]), int(d["def"]), int(d["spd"]), int(d["luk"])], 12, COL_ACCENT, true))

	var btn_mutation := _make_button("🎲 777 Chaos Mutation Gamble (WarGreymon / Omegamon)", "gold", 330, 48)
	btn_mutation.pressed.connect(func():
		var mega_pool := [85, 151, 152, 155, 296, 347]
		var pick_id: int = mega_pool[GM.frame % mega_pool.size()]
		GM.evolve_partner(pick_id, 1200, 180, 150, 175)
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
		show_toast("★ 777 MUTATION JACKPOT! Evolved to ID #" + str(pick_id) + "!")
	)
	rvbox.add_child(btn_mutation)

	var btn_reset_agumon := _make_button("Rebirth as Agumon (#3 · Keep 50% Bonus)", "secondary", 330, 44)
	btn_reset_agumon.pressed.connect(func():
		GM.g["partnerId"] = 3
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
	)
	rvbox.add_child(btn_reset_agumon)


# ---------- 8. 663종 전체 디지몬 바이오 도감 (room_Database) ----------
func _build_database_deck(d: Dictionary) -> void:
	var digis: Dictionary = GM.db.get("digimons", {})
	var keys: Array = digis.keys()
	keys.sort_custom(func(a, b): return int(a) < int(b))

	var per_page := 8
	var max_page := maxi(0, int((keys.size() - 1) / per_page))
	_db_page = clampi(_db_page, 0, max_page)

	var left_card := PanelContainer.new()
	left_card.position = Vector2(24, 86)
	left_card.custom_minimum_size = Vector2(616, 494)
	left_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 18, 14))
	_root_layer.add_child(left_card)

	var lvbox := VBoxContainer.new()
	lvbox.add_theme_constant_override("separation", 10)
	left_card.add_child(lvbox)

	var nav := HBoxContainer.new()
	nav.add_child(_make_label("663 Digimon Encyclopedia  (Page %d / %d)" % [_db_page + 1, max_page + 1], 16, COL_INK))
	var nsp := Control.new()
	nsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(nsp)

	var btn_prev := _make_button("◀ Prev", "secondary", 84, 36)
	btn_prev.pressed.connect(func():
		_db_page = maxi(0, _db_page - 1)
		rebuild_for_room(_current_room)
	)
	nav.add_child(btn_prev)

	var btn_next := _make_button("Next ▶", "secondary", 84, 36)
	btn_next.pressed.connect(func():
		_db_page = mini(max_page, _db_page + 1)
		rebuild_for_room(_current_room)
	)
	nav.add_child(btn_next)
	lvbox.add_child(nav)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	lvbox.add_child(grid)

	var start_i := _db_page * per_page
	for offset in per_page:
		if start_i + offset >= keys.size():
			break
		var k: String = str(keys[start_i + offset])
		var info: Dictionary = digis[k]
		var did: int = int(info["id"])
		var is_sel: bool = (did == _selected_db_id)

		var c := PanelContainer.new()
		c.custom_minimum_size = Vector2(284, 96)
		c.add_theme_stylebox_override("panel", _box(COL_SURFACE_HOVER if is_sel else COL_SURFACE, COL_ACCENT if is_sel else COL_BORDER, 10, 2 if is_sel else 1, 10, 8))

		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 10)
		c.add_child(hb)

		var ic := TextureRect.new()
		ic.texture = GM.tex("spr_Icons", did)
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.custom_minimum_size = Vector2(48, 48)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hb.add_child(ic)

		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 2)
		hb.add_child(vb)

		vb.add_child(_make_label("#%d %s" % [did, str(info["name"])], 13, COL_INK, true))
		vb.add_child(_make_label("%s · %s · %s" % [str(info["stage"]), str(info["attr"]), str(info["elem"])], 11, COL_INK_SEC, true))

		var btn_sel := _make_button("Inspect Bio", "active_seg" if is_sel else "secondary", 120, 30)
		btn_sel.pressed.connect(func():
			_selected_db_id = did
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
		)
		vb.add_child(btn_sel)
		grid.add_child(c)

	# 우측: 선택한 디지몬 바이오 상세 설명 & 즉시 파트너 소환 / 1v1 대결
	var right_card := PanelContainer.new()
	right_card.position = Vector2(654, 86)
	right_card.custom_minimum_size = Vector2(406, 494)
	right_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_ACCENT, 14, 1, 20, 16))
	_root_layer.add_child(right_card)

	var rvbox := VBoxContainer.new()
	rvbox.add_theme_constant_override("separation", 10)
	right_card.add_child(rvbox)

	var sel_info: Dictionary = digis.get(str(_selected_db_id), digis.get("5", {}))
	rvbox.add_child(_make_label("#%d  %s" % [int(sel_info.get("id", 5)), str(sel_info.get("name", "Greymon"))], 18, COL_ACCENT, true))
	rvbox.add_child(_make_label("%s  ·  %s  ·  %s Element" % [str(sel_info.get("stage", "Champion")), str(sel_info.get("attr", "Vaccine")), str(sel_info.get("elem", "Fire"))], 12, COL_GOLD))

	var spr_box := CenterContainer.new()
	spr_box.custom_minimum_size = Vector2(350, 130)
	var spr_rect := TextureRect.new()
	var sname := "d%d_idle" % int(sel_info.get("id", 5))
	spr_rect.texture = GM.tex(sname if GM.sprites.has(sname) else "d5_idle", 0)
	spr_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr_rect.custom_minimum_size = Vector2(124, 124)
	spr_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	spr_box.add_child(spr_rect)
	rvbox.add_child(spr_box)

	rvbox.add_child(_make_label("Base Stats: HP %d · ATK %d · DEF %d · SPD %d · LUK %d" % [
		int(sel_info.get("base_hp", 1800)), int(sel_info.get("base_atk", 320)),
		int(sel_info.get("base_def", 280)), int(sel_info.get("base_spd", 240)), int(sel_info.get("base_luk", 45))
	], 12, COL_INK, true))

	var desc_lbl := _make_label(str(sel_info.get("desc", "")).substr(0, 220) + "...", 11, COL_INK_SEC)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.custom_minimum_size = Vector2(360, 76)
	rvbox.add_child(desc_lbl)

	var btn_set_partner := _make_button("Set as Active Partner", "primary", 350, 44)
	var target_did: int = int(sel_info.get("id", 5))
	btn_set_partner.pressed.connect(func():
		GM.g["partnerId"] = target_did
		GM.init_battle_state()
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
		show_toast("Active partner linked to #" + str(target_did))
	)
	rvbox.add_child(btn_set_partner)

	var btn_duel := _make_button("⚔️ 1v1 Auto-Battle vs This Digimon", "battle", 350, 44)
	btn_duel.pressed.connect(func():
		GM.play_sound_fx("snd_Click06")
		GM.start_stage_battle(target_did, 35, "Database Simulation")
	)
	rvbox.add_child(btn_duel)


# ---------- 9. 디지바이스 OS & 78개 전체 퀘스트 로그 (room_DigiVice) ----------
func _build_digivice_quest_deck(d: Dictionary) -> void:
	var quests: Array = GM.db.get("quests", [])
	var per_page := 4
	var max_page := maxi(0, int((quests.size() - 1) / per_page))
	_quest_page = clampi(_quest_page, 0, max_page)

	var left_card := PanelContainer.new()
	left_card.position = Vector2(24, 86)
	left_card.custom_minimum_size = Vector2(636, 494)
	left_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 20, 16))
	_root_layer.add_child(left_card)

	var lvbox := VBoxContainer.new()
	lvbox.add_theme_constant_override("separation", 10)
	left_card.add_child(lvbox)

	var qnav := HBoxContainer.new()
	qnav.add_child(_make_label("78 Extracted Campaign Quests  (Page %d / %d)" % [_quest_page + 1, max_page + 1], 16, COL_INK))
	var qsp := Control.new()
	qsp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qnav.add_child(qsp)

	var b_prev := _make_button("◀ Prev", "secondary", 84, 36)
	b_prev.pressed.connect(func():
		_quest_page = maxi(0, _quest_page - 1)
		rebuild_for_room(_current_room)
	)
	qnav.add_child(b_prev)

	var b_next := _make_button("Next ▶", "secondary", 84, 36)
	b_next.pressed.connect(func():
		_quest_page = mini(max_page, _quest_page + 1)
		rebuild_for_room(_current_room)
	)
	qnav.add_child(b_next)
	lvbox.add_child(qnav)

	var start_q := _quest_page * per_page
	for i in per_page:
		if start_q + i >= quests.size():
			break
		var q: Dictionary = quests[start_q + i]
		var q_panel := PanelContainer.new()
		q_panel.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_BORDER, 10, 1, 14, 10))
		var qv := VBoxContainer.new()
		qv.add_theme_constant_override("separation", 4)
		q_panel.add_child(qv)

		var qname: String = str(q.get("name_pt" if int(GM.g["Language"]) == 1 else "name", q["name"]))
		var qdesc: String = str(q.get("desc_pt" if int(GM.g["Language"]) == 1 else "desc", q["desc"]))
		qv.add_child(_make_label("Q#%d · %s  [Client: %s · ★%d]" % [int(q["id"]), qname, str(q["npc"]), int(q["stars"])], 14, COL_GOLD, true))
		qv.add_child(_make_label(qdesc, 11, COL_INK_SEC, true))
		qv.add_child(_make_label("Hint: " + str(q.get("hint", "")), 11, COL_ACCENT, true))
		lvbox.add_child(q_panel)

	# 우측: 디지바이스 OS 세이브/로드 & 바로가기
	var right_card := PanelContainer.new()
	right_card.position = Vector2(674, 86)
	right_card.custom_minimum_size = Vector2(386, 494)
	right_card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_ACCENT, 14, 1, 20, 16))
	_root_layer.add_child(right_card)

	var rvbox := VBoxContainer.new()
	rvbox.add_theme_constant_override("separation", 12)
	right_card.add_child(rvbox)

	rvbox.add_child(_make_label("D-Terminal OS Kernel", 17, COL_ACCENT))
	rvbox.add_child(_make_label("Persistent Save File: user://tamer_save_v2.json", 12, COL_INK_SEC))

	var btn_save := _make_button("💾 Save Progress Now", "primary", 340, 48)
	btn_save.pressed.connect(func():
		var ok := GM.save_game_state()
		GM.play_sound_fx("snd_Click06")
		show_toast("Saved to user://tamer_save_v2.json" if ok else "Save failed")
	)
	rvbox.add_child(btn_save)

	var btn_load := _make_button("📂 Load Saved State", "secondary", 340, 48)
	btn_load.pressed.connect(func():
		var ok := GM.load_game_state()
		GM.play_sound_fx("snd_Click06")
		rebuild_for_room(_current_room)
		show_toast("Save loaded!" if ok else "No save file yet — click Save first")
	)
	rvbox.add_child(btn_load)

	var btn_evo := _make_button("Open Digivolution Matrix (436 Routes)", "gold", 340, 48)
	btn_evo.pressed.connect(func(): GM.room_transition(0, "room_Evo_Select"))
	rvbox.add_child(btn_evo)

	var btn_db := _make_button("Open 663 Digimon Encyclopedia", "secondary", 340, 48)
	btn_db.pressed.connect(func(): GM.room_transition(0, "room_Database"))
	rvbox.add_child(btn_db)


# ---------- 10. 디지털 월드 12대 원정 사냥터 & 보스 출격 데크 (room_Select_Map 등) ----------
func _build_world_map_deck(d: Dictionary, room_name: String) -> void:
	var card := PanelContainer.new()
	card.position = Vector2(24, 86)
	card.custom_minimum_size = Vector2(1028, 494)
	card.add_theme_stylebox_override("panel", _box(COL_BG_HUD, COL_BORDER, 14, 1, 22, 16))
	_root_layer.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	var cur_bmode: String = str(GM.g.get("battleMode", "world"))
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 10)
	mode_row.add_child(_make_label("Battle Mode (room_Select_Battle_Mode):", 14, COL_ACCENT))
	var modes := [
		{"id": "world", "label": "🌍 Digital World Field"},
		{"id": "challenge", "label": "🏅 Tamer Challenge (Rank %d)" % int(GM.g.get("challengeRank", 1))},
		{"id": "infinity", "label": "🗼 Infinity Tower (Floor %d)" % int(GM.g.get("infinityFloor", 1))},
		{"id": "adventure", "label": "🧭 Adventure Mode (Stage %d)" % int(GM.g.get("adventureStage", 1))},
	]
	for bm in modes:
		var bmid: String = str(bm["id"])
		var mbtn := _make_button(str(bm["label"]), "active_seg" if cur_bmode == bmid else "secondary", 170, 36)
		mbtn.pressed.connect(func():
			GM.g["battleMode"] = bmid
			GM.play_sound_fx("snd_Click06")
			rebuild_for_room(_current_room)
		)
		mode_row.add_child(mbtn)
	vbox.add_child(mode_row)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	var stages := [
		{"zone": "Village of Beginnings", "bg": "bg_Btl_Village_Beginnings", "boss_id": 3, "boss": "Agumon (Leader)", "lv": 10, "reward": "+1,500 BIT"},
		{"zone": "Dina Plains", "bg": "bg_Btl_Dina_Plains", "boss_id": 35, "boss": "GeoGreymon", "lv": 20, "reward": "+2,400 BIT"},
		{"zone": "Boot Jungle", "bg": "bg_Btl_Boot_Jungle", "boss_id": 85, "boss": "MetalGreymon", "lv": 28, "reward": "+3,200 BIT"},
		{"zone": "Chrome Mines", "bg": "bg_Btl_Chrome_Mines", "boss_id": 87, "boss": "SkullGreymon", "lv": 34, "reward": "+4,500 BIT"},
		{"zone": "Server City Arena", "bg": "bg_Btl_ServerCity_Ruins", "boss_id": 89, "boss": "RizeGreymon", "lv": 40, "reward": "+5,500 BIT"},
		{"zone": "Magma Mountain", "bg": "bg_Btl_Magma_Mountain", "boss_id": 151, "boss": "WarGreymon", "lv": 48, "reward": "+7,200 BIT"},
		{"zone": "Dark Area Abyss", "bg": "bg_Btl_Dark_Area", "boss_id": 152, "boss": "BlackWarGreymon", "lv": 55, "reward": "+9,000 BIT"},
		{"zone": "Chaos Tower Top", "bg": "bg_Btl_D_Dungeon01", "boss_id": 155, "boss": "ShineGreymon", "lv": 64, "reward": "+12,000 BIT"},
		{"zone": "Kernel Zone Final", "bg": "BG_InfinityTower", "boss_id": 347, "boss": "VictoryGreymon", "lv": 75, "reward": "+20,000 BIT"},
	]
	for st in stages:
		var sc := PanelContainer.new()
		sc.custom_minimum_size = Vector2(320, 118)
		sc.add_theme_stylebox_override("panel", _box(COL_SURFACE, COL_BORDER, 10, 1, 12, 10))
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 10)
		sc.add_child(hb)

		var bic := TextureRect.new()
		bic.texture = GM.tex(str(st["bg"]), 0)
		bic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bic.custom_minimum_size = Vector2(88, 54)
		bic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		hb.add_child(bic)

		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 3)
		hb.add_child(vb)

		vb.add_child(_make_label(str(st["zone"]), 14, COL_ACCENT, true))
		vb.add_child(_make_label("Boss: %s (Lv.%d) · %s" % [str(st["boss"]), int(st["lv"]), str(st["reward"])], 11, COL_INK, true))

		var btn_go := _make_button("⚔️ Deploy 1v1 Auto-Battle", "battle", 190, 36)
		var bid: int = int(st["boss_id"])
		var blv: int = int(st["lv"])
		var bzone: String = str(st["zone"])
		var bbg: String = str(st["bg"])
		btn_go.pressed.connect(func():
			GM.play_sound_fx("snd_Click06")
			GM.start_stage_battle(bid, blv, bzone, bbg)
		)
		vb.add_child(btn_go)
		grid.add_child(sc)

