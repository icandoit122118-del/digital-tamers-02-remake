extends GMInstance
## obj_Digi_Info (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 우측 홀로-텔레메트리 파트너 스탯 인스펙터)

var YY := 0.0
var Spd := 25.0
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	YY = 207.0 if bool(GM.g.get("StatsAberto", false)) else 0.0


func step() -> void:
	var open := bool(GM.g.get("StatsAberto", false))
	if not open and YY > 0.0:
		YY = maxf(0.0, YY - Spd)
	elif open and YY < 207.0:
		YY = minf(207.0, YY + Spd)
	image_index = (1 if YY >= 207.0 else 0) + (2 if int(GM.g.get("Language", 0)) == 1 else 0)
	x = 377.0
	y = -(201.0 - YY)


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked:
		ImClicked = false
		GM.g["StatsAberto"] = not bool(GM.g.get("StatsAberto", false))
		GM.play_sound_fx("snd_DigiPad_ON" if bool(GM.g["StatsAberto"]) else "snd_DigiPad_OFF")


func draw() -> void:
	var py := -(201.0 - YY)
	var hp_val: float = float(GM.g.get("hp", 2200))
	var hp_max_val: float = maxf(1.0, float(GM.g.get("hp_max", 2200)))
	var xp_val: float = float(GM.g.get("xp", 74))
	var xp_max_val := 100.0

	# 우측 플로팅 홀로-텔레메트리 패널
	CBStyle.draw_vlink_panel(self, Rect2(374.0, py, 158.0, 204.0), CBStyle.BG_DEEP, CBStyle.BORDER_CYAN, 7.0, true)

	# 상단 HP / XP 캡슐 게이지
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(382.0, py + 8.0, "HP", 0x81B910, 0)
	CBStyle.draw_capsule_bar(self, Rect2(400.0, py + 8.0, 124.0, 9.0), hp_val / hp_max_val, CBStyle.ACCENT_EMERALD, CBStyle.BG_PANEL)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(522.0, py + 7.5, "%d/%d" % [int(hp_val), int(hp_max_val)], 0xFFFFFF, 0)

	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(382.0, py + 21.0, "XP", 0x0B9EF5, 0)
	CBStyle.draw_capsule_bar(self, Rect2(400.0, py + 21.0, 124.0, 9.0), xp_val / xp_max_val, CBStyle.ACCENT_AMBER, CBStyle.BG_PANEL)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(522.0, py + 20.5, "%d/100" % int(xp_val), 0xFFFFFF, 0)

	# 5대 전투 파라미터 미니 프로그레스 바 + 수치
	var combat_stats := [
		["ATK", int(GM.g.get("atk", 160)), 500.0, CBStyle.ACCENT_ROSE],
		["DEF", int(GM.g.get("def", 140)), 500.0, CBStyle.ACCENT_CYAN],
		["SP.A", int(GM.g.get("sp_atk", 155)), 500.0, CBStyle.ACCENT_INDIGO],
		["SP.D", int(GM.g.get("sp_def", 56)), 500.0, CBStyle.ACCENT_EMERALD],
		["SPD", int(GM.g.get("spd", 185)), 500.0, CBStyle.ACCENT_AMBER],
	]
	for i in combat_stats.size():
		var sy := py + 36.0 + float(i) * 16.5
		var label_s: String = str(combat_stats[i][0])
		var val_i: int = int(combat_stats[i][1])
		var ratio_f: float = clampf(float(val_i) / float(combat_stats[i][2]), 0.12, 1.0)
		var bar_c: Color = combat_stats[i][3]
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
		draw_text_shadow(382.0, sy, label_s, 0xB8A394, 0)
		CBStyle.draw_capsule_bar(self, Rect2(414.0, sy + 2.0, 74.0, 7.0), ratio_f, bar_c, CBStyle.BG_PANEL)
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
		draw_text_shadow(524.0, sy, str(val_i), 0x0B9EF5, 0)

	# 하단 바이탈 상태 캡슐 요약 (Bond, Hunger, Health, Energy)
	var hunger_val: int = int(GM.g.get("hunger", 82))
	var hunger_txt := "SATISFIED" if hunger_val >= 60 else ("HUNGRY" if hunger_val >= 30 else "STARVING")
	var health_txt := "OPTIMAL" if int(GM.g.get("injury", 0)) == 0 else "INJURED"
	var en_val: int = int(GM.g.get("en", 100))

	var vitals := [
		["BOND SYNC", "100% (MAX)", 0x81B910],
		["NUTRITION", hunger_txt, 0xF8BD38],
		["CONDITION", health_txt, 0x81B910],
		["STAMINA", "%d / 100" % en_val, 0x0B9EF5],
	]
	for j in vitals.size():
		var vy := py + 121.0 + float(j) * 15.0
		draw_rect(Rect2(382.0, vy, 142.0, 13.0), CBStyle.BG_PANEL if j % 2 == 0 else CBStyle.BG_CARD, true)
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
		draw_text(386.0, vy + 1.5, str(vitals[j][0]))
		draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
		draw_text_shadow(520.0, vy + 1.5, str(vitals[j][1]), int(vitals[j][2]), 0)

	# 하단 드로어 핸들 캡슐
	var tab_r := Rect2(404.0, py + 184.0, 120.0, 16.0)
	CBStyle.draw_vlink_panel(self, tab_r, CBStyle.BG_SLOT, CBStyle.BORDER_GOLD, 4.0, false)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(464.0, py + 192.0, "TELEMETRY [CLOSE]" if YY >= 200.0 else "TELEMETRY [OPEN]", 0xFFFFFF, 0)
