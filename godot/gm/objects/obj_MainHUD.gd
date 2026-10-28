extends GMInstance
## obj_MainHUD (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌상단 헥사-코어 파트너 포드 & 우상단 플로팅 월렛 캡슐)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -1000
	var has_shop_btn := false
	for inst in GM.instances:
		if inst.obj_name == "obj_MainButtons" and int(inst.image_index) == 1:
			has_shop_btn = true
			break
	if not has_shop_btn and GM.room_name == "room_MainRoom":
		var sb := GM.instance_create(330.0, 248.0, "obj_MainButtons")
		sb.image_index = 1


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
	var pid: int = int(GM.g.get("partnerId", 5))
	var d_entry: Dictionary = GM.db["digimons"].get(str(pid), {})
	var p_name: String = str(d_entry.get("name", "Greymon"))
	if int(GM.g.get("EvoStage", 2)) == 0:
		p_name = "DigiTama"
	var p_lv: int = int(GM.g.get("partnerLv", 28))
	var evo_stage: int = int(GM.g.get("EvoStage", 2))
	var hp_val: float = float(GM.g.get("hp", 950))
	var hp_max_val: float = maxf(1.0, float(GM.g.get("hp_max", 950)))
	var hp_ratio := clampf(hp_val / hp_max_val, 0.0, 1.0)

	# 1) 하단 플로팅 아크 독 베이스 (화면 전체를 막지 않고 중앙~좌측에만 슬림하게 떠 있는 플로팅 글래스 독)
	CBStyle.draw_vlink_panel(self, Rect2(4.0, 250.0, 390.0, 46.0), Color8(11, 17, 30, 195), CBStyle.BORDER_SUBTLE, 8.0, true)

	# 2) 좌상단 메인 플로팅 캡슐 (Hexa-Core Partner Pod)
	CBStyle.draw_vlink_panel(self, Rect2(34.0, 7.0, 292.0, 44.0), CBStyle.BG_PANEL, CBStyle.BORDER_CYAN, 7.0, true)

	# 좌측 헥사곤 디지코어 아바타 포드 (캡슐 좌측에 걸치는 입체 육각 코어)
	CBStyle.draw_hex_avatar(self, Vector2(32.0, 29.0), 25.0, CBStyle.BORDER_GOLD if evo_stage >= 3 else CBStyle.BORDER_CYAN, CBStyle.BG_DEEP)
	draw_sprite_ext("spr_Icons", pid, 32.0, 27.0, 1.6, 1.6, 0.0, Color.WHITE, 1.0)

	# 상단 라인: 파트너 이름 + 레벨 배지 + 종족/속성 아이콘
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(64.0, 10.0, p_name, 0xFFF8FA, 0x0B111E)

	var lv_pill := Rect2(174.0, 10.0, 46.0, 13.0)
	CBStyle.draw_vlink_panel(self, lv_pill, CBStyle.BG_SLOT, CBStyle.BORDER_GOLD, 3.0, false)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(197.0, 16.5, "Lv.%d" % p_lv, 0x0B9EF5, 0)

	# 우측 종족·속성 마이크로 인디케이터 슬롯
	draw_sprite_ext("spr_EvoStage", clampi(evo_stage, 0, 6), 232.0, 11.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Family", pid % 8, 245.0, 8.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_ElemAttribute", pid % 10, 261.0, 8.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Attribute", pid % 4, 278.0, 10.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)

	# 중단 라인: 에메랄드 캡슐 HP 바
	CBStyle.draw_capsule_bar(self, Rect2(64.0, 26.0, 198.0, 10.0), hp_ratio, CBStyle.ACCENT_EMERALD, CBStyle.BG_DEEP)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(318.0, 25.0, "%d/%d" % [int(hp_val), int(hp_max_val)], 0xF8FAFC, 0x0B111E)

	# 하단 라인: 앰버 에너지 노드 10칸 + 포만감/유대감 미니 상태 태그
	var en_nodes := clampi(int(round(float(GM.g.get("en", 100)) / 10.0)), 1, 10)
	CBStyle.draw_energy_nodes(self, Vector2(64.0, 39.0), 11.0, 6.0, 2.0, 10, en_nodes, CBStyle.ACCENT_AMBER)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(318.0, 37.0, "EN %d%%" % int(GM.g.get("en", 100)), 0x38BDF8, 0)

	# 3) 우상단 플로팅 테이머 월렛 & 랭크 캡슐 (Stats 드로어가 닫혀 있을 때 표시)
	if not bool(GM.g.get("StatsAberto", false)):
		CBStyle.draw_vlink_panel(self, Rect2(372.0, 7.0, 160.0, 26.0), CBStyle.BG_PANEL, CBStyle.BORDER_GOLD, 6.0, true)
		draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
		draw_text_shadow(452.0, 20.0, "%d BIT  //  TAMER Lv.%d" % [int(GM.g.get("bits", 24500)), int(GM.g.get("tamerLv", 12))], 0x0B9EF5, 0x0B111E)
