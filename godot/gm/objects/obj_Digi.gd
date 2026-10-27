extends GMInstance
## obj_Digi (Sanctuary 파트너 디지몬 애니메이션 — 663종 전체 디지몬 동적 연동)

var _dir := 1.0
var _walk_timer := 90


func create() -> void:
	image_speed = 0.22
	_sync_partner_sprite()


func step() -> void:
	_sync_partner_sprite()
	var mode: String = str(GM.g.get("dataMode", "demo"))
	if mode == "empty":
		hspeed = 0.0
		return
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


func _sync_partner_sprite() -> void:
	var mode: String = str(GM.g.get("dataMode", "demo"))
	if mode == "empty":
		sprite_index = "spr_egg01"
		image_xscale = 1.0
		return
	elif mode == "worst":
		sprite_index = "d152_idle"
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
