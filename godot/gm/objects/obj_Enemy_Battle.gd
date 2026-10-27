extends GMInstance
## obj_Enemy_Battle — 663종 전체 적군 디지몬 동적 스프라이트 & 오토체스형 자율 기동·점프·스킬 AI

const GROUND_Y := 216.0
const GRAV := 0.44

var vy := 0.0
var vx := 0.0
var _anim_timer := 0
var _think_timer := 0.4
var _atk_cd := 1.4
var _rng := RandomNumberGenerator.new()


func create() -> void:
	_rng.seed = 9092026 + GM.frame * 7
	x = 412.0
	y = GROUND_Y
	vy = 0.0
	vx = 0.0
	image_xscale = 1.0
	image_speed = 0.22
	_sync_sprite("idle")


func _sync_sprite(act: String) -> void:
	var eid: int = int(GM.battle.get("e_id", 87))
	var prefix := "d%d_" % eid
	var cand := prefix + act
	if GM.sprites.has(cand):
		sprite_index = cand
	elif GM.sprites.has(prefix + "idle"):
		sprite_index = prefix + "idle"
	else:
		sprite_index = "d87_" + act if GM.sprites.has("d87_" + act) else "d87_idle"


func _player_inst() -> GMInstance:
	for inst in GM.instances:
		if inst.obj_name == "obj_Digi_Battle" and not inst.dead:
			return inst
	return null


func step() -> void:
	var b: Dictionary = GM.battle
	var spd_mult: float = 2.0 if bool(b.get("speed2x", true)) else 1.0
	var dt: float = (1.0 / 60.0) * spd_mult

	if bool(b.get("finished", false)):
		vx = 0.0
		if y < GROUND_Y:
			vy += GRAV * spd_mult
			y = minf(GROUND_Y, y + vy * spd_mult)
		_sync_sprite("lose" if bool(b.get("win", true)) else "win")
		queue_redraw()
		return

	x = clampf(x + vx * spd_mult, 68.0, 482.0)
	if y < GROUND_Y or vy < 0.0:
		vy += GRAV * spd_mult
		y += vy * spd_mult
		if y >= GROUND_Y:
			y = GROUND_Y
			vy = 0.0
			if _anim_timer <= 0:
				vx = 0.0
				_sync_sprite("idle")

	var player := _player_inst()
	if player != null and _anim_timer <= 0:
		image_xscale = 1.0 if player.x <= x else -1.0

	_atk_cd = maxf(0.0, _atk_cd - dt)

	if _anim_timer > 0:
		_anim_timer -= int(ceil(spd_mult))
		if _anim_timer <= 0 and y >= GROUND_Y:
			vx = 0.0
			_sync_sprite("idle")
	elif player != null:
		_think_timer -= dt
		if _think_timer <= 0.0:
			_think_timer = 0.26
			_run_enemy_autochess_ai(b, player)

	queue_redraw()


func try_jump_evade() -> void:
	var b: Dictionary = GM.battle
	if y < GROUND_Y - 6.0 or bool(b.get("finished", false)):
		return
	var evade_chance: int = clampi(14 + int(float(b["e_spd"]) * 0.04 + float(b["e_luk"]) * 0.25), 14, 48)
	if _rng.randi_range(1, 100) <= evade_chance:
		vy = -8.0
		vx = 1.8
		_anim_timer = 22
		_sync_sprite("jump")
		b["e_ai_state"] = "JUMP EVADE!"
		var player := _player_inst()
		if player != null and player.has_method("_spawn_popup"):
			player.call("_spawn_popup", x, y - 52.0, "💨 BOSS JUMP DODGE!", Color("#F5C451"), 1.15)


func _run_enemy_autochess_ai(b: Dictionary, player: GMInstance) -> void:
	var dist: float = absf(player.x - x)
	var dir: float = -1.0 if player.x <= x else 1.0
	var move_spd: float = clampf(float(b["e_spd"]) / 120.0, 1.6, 3.2)

	if _atk_cd <= 0.0:
		_atk_cd = 2.1
		var is_ult: bool = float(b["e_sp"]) >= 100.0
		if is_ult:
			b["e_sp"] = 0.0
		else:
			b["e_sp"] = minf(100.0, float(b["e_sp"]) + 24.0)

		var roll: int = _rng.randi_range(1, 100) + int(float(b["e_luk"]) * 0.2)
		var mult := 1.0
		var tier := "BOSS ATK 1.0x"
		if roll >= 92:
			mult = 3.2
			tier = "💀 BOSS JACKPOT 3.2x!"
		elif roll >= 68:
			mult = 1.8
			tier = "BOSS CRIT 1.8x"
		elif roll <= 15:
			mult = 0.55
			tier = "GRAZE 0.55x"

		var raw_dmg: float = maxf(35.0, (float(b["e_atk"]) * (1.55 if is_ult else 1.15) * mult) - float(b["p_def"]) * 0.38)
		var dmg: int = maxi(12, int(round(raw_dmg)))

		image_index = 0.0
		if is_ult:
			vy = -5.2
			vx = dir * 2.2
			_sync_sprite("atkSP")
			_anim_timer = 28
			b["e_ai_state"] = "ULTIMATE BURST!"
		elif dist < 170.0 and _rng.randi_range(1, 100) <= 45:
			vy = -7.2
			vx = dir * 4.2
			_sync_sprite("jump")
			_anim_timer = 24
			b["e_ai_state"] = "JUMP SLAM!"
		else:
			vx = 0.0
			_sync_sprite("atk01")
			_anim_timer = 22
			b["e_ai_state"] = "SKILL SHOT"

		if player.has_method("spawn_projectile"):
			player.call("spawn_projectile", false, x + dir * 24.0, y - 26.0, dir * 6.2, dmg, tier, mult, Color("#FF6B4A"), is_ult)
		return

	if dist > 175.0:
		vx = dir * move_spd
		_sync_sprite("walk")
		b["e_ai_state"] = "STALKING"
	elif dist < 78.0:
		vx = -dir * move_spd
		if _rng.randi_range(1, 100) <= 35 and y >= GROUND_Y:
			vy = -6.5
			_sync_sprite("jump")
			b["e_ai_state"] = "LEAP BACK"
		else:
			_sync_sprite("walk")
			b["e_ai_state"] = "RETREAT"
	else:
		vx = dir * (move_spd * 0.45) if _rng.randi_range(0, 1) == 0 else -dir * (move_spd * 0.45)
		_sync_sprite("walk")
		b["e_ai_state"] = "SPACING"


func on_hit_knockback(push_dir: float) -> void:
	image_index = 0.0
	_sync_sprite("dmg")
	_anim_timer = 14
	vx = push_dir * 2.2


func draw() -> void:
	var shadow_y := GROUND_Y - y
	var shadow_w := clampf(28.0 - absf(shadow_y) * 0.15, 10.0, 28.0)
	draw_rect(Rect2(-shadow_w, shadow_y - 3.0, shadow_w * 2.0, 6.0), Color(0, 0, 0, 0.42))
	super.draw()
