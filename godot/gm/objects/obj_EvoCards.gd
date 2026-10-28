extends GMInstance
## obj_EvoCards (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 헥사-코어 진화 매트릭스 캡슐 카드)

var ID := 1
var EvoInto := 5
var EvoName := "Greymon"
var CondTxt := "Lv. 16+ Ready"
var BonusHp := 800
var BonusAtk := 380
var BonusDef := 250
var BonusSp := 240
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	_sync_route()


func step() -> void:
	_sync_route()


func _sync_route() -> void:
	if vars.has("ID"):
		ID = int(vars["ID"])
	var pid: int = int(GM.g.get("partnerId", 3))
	var routes: Array = GM.db["evolutions"].get(str(pid), [])
	if routes.is_empty():
		routes = GM.db["evolutions"].get("3", [])
	if routes.is_empty():
		return
	var r_idx := (ID - 1) % routes.size()
	var r: Dictionary = routes[r_idx]
	EvoInto = int(r.get("to_id", 5))
	EvoName = str(r.get("name", "Greymon"))
	CondTxt = str(r.get("cond", "Lv. 16+")).split("·")[0].strip_edges()
	BonusHp = int(r.get("bonus_hp", 800))
	BonusAtk = int(r.get("bonus_atk", 360))
	BonusDef = int(r.get("bonus_def", 240))
	BonusSp = int(r.get("bonus_sp_atk", 240))


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	GM.evolve_partner(EvoInto, BonusHp, BonusAtk / 3, BonusDef / 3, BonusSp / 3)
	GM.g["EvoStage"] = mini(6, int(GM.g.get("EvoStage", 2)) + 1)


func draw() -> void:
	if x > 530.0:
		return
	var cr := Rect2(x, y, 244.0, 76.0)
	CBStyle.draw_vlink_panel(self, cr, CBStyle.BG_PANEL if not ImClicked else CBStyle.BG_SLOT, CBStyle.BORDER_CYAN, 7.0, true)

	# 좌측 육각 디지코어 초상화 포드
	CBStyle.draw_hex_avatar(self, Vector2(x + 34.0, y + 32.0), 24.0, CBStyle.BORDER_GOLD, CBStyle.BG_DEEP)
	draw_sprite_ext("spr_Icons", EvoInto, x + 34.0, y + 30.0, -1.6, 1.6, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_EvoStage", clampi(int(GM.g.get("EvoStage", 2)) + 1, 1, 6), x + 8.0, y + 58.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Family", EvoInto % 8, x + 20.0, y + 54.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_ElemAttribute", EvoInto % 10, x + 34.0, y + 54.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Attribute", EvoInto % 4, x + 49.0, y + 56.0, 1.0, 1.0, 0.0, Color.WHITE, 1.0)

	# 우측 진화 데이터 & UNLOCKED 배지
	CBStyle.draw_vlink_panel(self, Rect2(x + 178.0, y + 8.0, 58.0, 16.0), Color8(6, 78, 59, 240), CBStyle.ACCENT_EMERALD, 3.5, false)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(x + 207.0, y + 16.0, "UNLOCKED", 0x81B910, 0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 68.0, y + 10.0, EvoName, 0x0B9EF5, 0)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 68.0, y + 29.0, "REQ // %s" % CondTxt, 0xF8FAFC, 0)

	CBStyle.draw_vlink_panel(self, Rect2(x + 68.0, y + 46.0, 168.0, 20.0), CBStyle.BG_DEEP, CBStyle.BORDER_SUBTLE, 4.0, false)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(x + 152.0, y + 56.0, "+%d HP   |   +%d ATK" % [BonusHp, BonusAtk], 0x81B910, 0)
