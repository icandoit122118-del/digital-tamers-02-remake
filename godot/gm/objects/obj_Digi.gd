extends GMInstance
## obj_Digi (원작 room_MainRoom 파트너 디지몬: DigiTama 알 부화 -> 유년기/성장기/완전체 보행 및 케어 반응)

var acao := 1
var _dir := 1.0
var _walk_timer := 60
var _hatch_timer := 45


func create() -> void:
	image_speed = 0.22
	_hatch_timer = 45
	_sync_partner_sprite()


func step() -> void:
	if int(GM.g.get("EvoStage", 2)) == 0:
		hspeed = 0.0
		_hatch_timer -= 1
		if _hatch_timer <= 0:
			GM.hatch_partner_egg()
		_sync_partner_sprite()
		return

	_sync_partner_sprite()
	_walk_timer -= 1
	if _walk_timer <= 0:
		_walk_timer = 90 + (GM.frame % 60)
		_dir = -_dir if (GM.frame % 3 != 0) else 0.0
	hspeed = _dir * 0.45
	if x < 140.0:
		x = 140.0
		_dir = 1.0
	elif x > 398.0:
		x = 398.0
		_dir = -1.0
	if _dir != 0.0:
		image_xscale = -1.0 if _dir > 0.0 else 1.0


func mouse_left_released() -> void:
	if int(GM.g.get("EvoStage", 2)) == 0:
		GM.hatch_partner_egg()
		_sync_partner_sprite()
	else:
		GM.care_action("food")


func _sync_partner_sprite() -> void:
	if int(GM.g.get("EvoStage", 2)) == 0:
		var egg_idx := clampi(int(GM.g.get("eggId", 0)), 0, 9)
		sprite_index = "spr_egg%02d" % (egg_idx + 1)
		image_xscale = 1.0
		return
	var pid: int = int(GM.g.get("partnerId", 5))
	var act := "walk" if absf(hspeed) > 0.05 else "idle"
	var cand := "d%d_%s" % [pid, act]
	if GM.sprites.has(cand):
		sprite_index = cand
	elif GM.sprites.has("d%d_idle" % pid):
		sprite_index = "d%d_idle" % pid
	else:
		sprite_index = "d5_idle"


func draw() -> void:
	draw_self()
	if int(GM.g.get("EvoStage", 2)) == 0:
		draw_set_format("fnt_Text", 0xDDE105, 1, 1)
		draw_text_shadow(x, y - 34.0, "Hatching DigiTama... (Tap!)", 0xDDE105, 0)
