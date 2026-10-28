extends GMInstance
## obj_Top_Hud (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 전투 상단 듀얼 싱크 윙 & 육각 코어 HUD)


func create() -> void:
	image_speed = 0.0
	depth = -2000


func draw() -> void:
	var b: Dictionary = GM.battle
	var p_hp: float = clampf(float(b.get("p_hp", 2200)), 0.0, float(b.get("p_hp_max", 2200)))
	var p_hp_max: float = maxf(1.0, float(b.get("p_hp_max", 2200)))
	var e_hp: float = clampf(float(b.get("e_hp", 2800)), 0.0, float(b.get("e_hp_max", 2800)))
	var e_hp_max: float = maxf(1.0, float(b.get("e_hp_max", 2800)))

	var pid: int = int(b.get("p_id", 5))
	var eid: int = int(b.get("e_id", 87))
	var p_name: String = str(b.get("p_name", "Greymon"))
	var e_name: String = str(b.get("e_name", "SkullGreymon"))
	var p_lv: int = int(b.get("p_lv", 28))
	var e_lv: int = int(b.get("e_lv", 32))

	var p_sp_nodes := clampi(int(round(float(b.get("p_sp", 45.0)) / 12.5)), 1, 8)
	var e_sp_nodes := clampi(int(round(float(b.get("e_sp", 35.0)) / 12.5)), 1, 8)

	# --- 1) 좌측 아군 싱크 윙 (Player Sync Wing) ---
	CBStyle.draw_vlink_panel(self, Rect2(34.0, 6.0, 202.0, 42.0), CBStyle.BG_PANEL, CBStyle.BORDER_CYAN, 7.0, true)
	CBStyle.draw_hex_avatar(self, Vector2(28.0, 27.0), 23.0, CBStyle.BORDER_CYAN, CBStyle.BG_DEEP)
	draw_sprite_ext("spr_Icons", pid, 28.0, 25.0, 1.5, 1.5, 0.0, Color.WHITE, 1.0)
	draw_sprite("spr_Attribute", pid % 4, 38.0, 35.0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(56.0, 9.0, p_name, 0xF8BDF8, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(228.0, 10.0, "Lv.%d" % p_lv, 0x0B9EF5, 0)

	CBStyle.draw_capsule_bar(self, Rect2(56.0, 22.0, 172.0, 10.0), p_hp / p_hp_max, CBStyle.ACCENT_EMERALD, CBStyle.BG_DEEP)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(224.0, 21.5, "%d/%d" % [int(p_hp), int(p_hp_max)], 0xFFFFFF, 0)
	CBStyle.draw_energy_nodes(self, Vector2(56.0, 35.0), 12.0, 6.0, 2.0, 8, p_sp_nodes, CBStyle.ACCENT_AMBER)

	# --- 2) 우측 적군 싱크 윙 (Enemy Sync Wing) ---
	CBStyle.draw_vlink_panel(self, Rect2(302.0, 6.0, 202.0, 42.0), CBStyle.BG_PANEL, CBStyle.ACCENT_ROSE, 7.0, true)
	CBStyle.draw_hex_avatar(self, Vector2(510.0, 27.0), 23.0, CBStyle.ACCENT_ROSE, CBStyle.BG_DEEP)
	draw_sprite_ext("spr_Icons", eid, 510.0, 25.0, -1.5, 1.5, 0.0, Color.WHITE, 1.0)
	draw_sprite("spr_Attribute", eid % 4, 488.0, 35.0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(310.0, 9.0, e_name, 0xFFFFFF, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(482.0, 10.0, "Lv.%d" % e_lv, 0x5E3FF4, 0)

	CBStyle.draw_capsule_bar(self, Rect2(310.0, 22.0, 172.0, 10.0), e_hp / e_hp_max, CBStyle.ACCENT_ROSE, CBStyle.BG_DEEP)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(478.0, 21.5, "%d/%d" % [int(e_hp), int(e_hp_max)], 0xFFFFFF, 0)
	CBStyle.draw_energy_nodes(self, Vector2(310.0, 35.0), 12.0, 6.0, 2.0, 8, e_sp_nodes, CBStyle.ACCENT_AMBER)

	# --- 3) 중앙 헥사곤 V-SYNC 코어 ---
	CBStyle.draw_hex_avatar(self, Vector2(269.0, 27.0), 21.0, CBStyle.BORDER_GOLD, CBStyle.BG_DEEP)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(269.0, 22.0, "V-SYNC", 0x0B9EF5, 0)
	draw_text_shadow(269.0, 32.0, "AUTO 2X", 0x81B910, 0)
