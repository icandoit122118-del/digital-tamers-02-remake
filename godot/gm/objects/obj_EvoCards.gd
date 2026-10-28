extends GMInstance
## obj_EvoCards (원작 gml_Object_obj_EvoCards_Draw_0.gml: 진화 분기 카드 & 클릭 시 진화 실행)

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
	image_blend = Color8(0xB8, 0xB8, 0xB8)


func mouse_leave() -> void:
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	image_blend = Color.WHITE
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	GM.evolve_partner(EvoInto, BonusHp, BonusAtk / 3, BonusDef / 3, BonusSp / 3)
	GM.g["EvoStage"] = mini(6, int(GM.g.get("EvoStage", 2)) + 1)


func draw() -> void:
	if x > 530.0:
		return
	draw_self()
	draw_sprite_ext("spr_EvoStage", clampi(int(GM.g.get("EvoStage", 2)) + 1, 1, 6), x + 4.0, y + 61.0, 1.0, 1.0, 0.0, image_blend, 1.0)
	draw_sprite_ext("spr_Family", EvoInto % 8, x + 14.0, y + 57.0, 1.0, 1.0, 0.0, image_blend, 1.0)
	draw_sprite_ext("spr_ElemAttribute", EvoInto % 10, x + 28.0, y + 57.0, 1.0, 1.0, 0.0, image_blend, 1.0)
	draw_sprite_ext("spr_Attribute", EvoInto % 4, x + 44.0, y + 58.0, 1.0, 1.0, 0.0, image_blend, 1.0)
	draw_sprite_ext("spr_Icons", EvoInto, x + 34.0, y + 30.0, -2.0, 2.0, 0.0, image_blend, 1.0)
	draw_sprite("spr_CanEvo", 0, x + 205.0, y + 6.0)

	draw_set_format("fnt_Text", 0xDDE105, 0, 0)
	draw_text_shadow(x + 69.0, y + 11.0, EvoName, 0xDDE105, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 70.0, y + 28.0, CondTxt, 0xFFFFFF, 0)
	draw_text_shadow(x + 70.0, y + 45.0, "+%d HP / +%d ATK" % [BonusHp, BonusAtk], 0x6BFF5A, 0)
