extends GMInstance
## obj_SpecialHUD_Player (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌하단 플로팅 택티컬 독 & 우하단 AI 텔레메트리 모니터)


func create() -> void:
	image_speed = 0.0
	depth = -2000


func draw() -> void:
	# 1) 좌하단 플로팅 택티컬 커맨드 독 (화면 중앙 지면을 가리지 않고 좌하단에 슬림하게 부유)
	CBStyle.draw_vlink_panel(self, Rect2(6.0, 250.0, 352.0, 46.0), Color8(11, 17, 30, 205), CBStyle.BORDER_SUBTLE, 8.0, true)

	# 2) 우하단 독립 AI 텔레메트리 미니 모니터
	var mon_r := Rect2(368.0, 250.0, 164.0, 46.0)
	CBStyle.draw_vlink_panel(self, mon_r, CBStyle.BG_PANEL, CBStyle.BORDER_CYAN, 7.0, true)

	var sp_val := clampf(float(GM.battle.get("p_sp", 45.0)), 0.0, 100.0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(376.0, 256.0, "OVERDRIVE CHARGE", 0x0B9EF5, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 2)
	draw_text_shadow(524.0, 256.0, "%d%%" % int(sp_val), 0xFFFFFF, 0)

	CBStyle.draw_capsule_bar(self, Rect2(376.0, 267.0, 148.0, 8.0), sp_val / 100.0, CBStyle.ACCENT_AMBER, CBStyle.BG_DEEP)

	var ai_state: String = str(GM.battle.get("p_ai_state", "AI: AUTO-ENGAGE"))
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(450.0, 284.0, ai_state, 0x81B910, 0)
