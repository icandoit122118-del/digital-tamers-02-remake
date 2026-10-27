extends GMInstance
## obj_Enemy_Battle — 원본 Digital Tamers 02 적군 디지몬 실시간 액션 AI (acao 1..12 상태머신)

const GROUND_Y := 216.0
const GRAV := 0.46

var acao := 1
var lado := -1.0
var can_jump := true
var vy := 0.0
var vx := 0.0
var _anim_timer := 0
var _think_timer := 0.32
var _atk_cd := 1.2
var _rng := RandomNumberGenerator.new()


func create() -> void:
	_rng.seed = 9092026 + GM.frame * 7
	x = 412.0
	y = GROUND_Y
	vy = 0.0
	vx = 0.0
	acao = 1
	lado = -1.0
	can_jump = true
	image_xscale = 1.0
	image_speed = 0.24
	_sync_sprite("idle")


func _sync_sprite(act: String) -> void:
	var eid: int = int(GM.battle.get("e_id", 87))
	var prefix := "d%d_" % eid
	var cand := prefix + act
	if GM.sprites.has(cand):
		sprite_index = cand
	elif act == "atk02" and GM.sprites.has(prefix + "atk01"):
		sprite_index = prefix + "atk01"
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
		acao = 11 if bool(b.get("win", true)) else 12
		b["e_acao"] = acao
		_sync_sprite("lose" if acao == 11 else "win")
		queue_redraw()
		return

	x = clampf(x + vx * spd_mult, 64.0, 486.0)
	if y < GROUND_Y or vy < 0.0:
		vy += GRAV * spd_mult
		y += vy * spd_mult
		if y >= GROUND_Y:
			y = GROUND_Y
			vy = 0.0
			can_jump = true
			if _anim_timer <= 0:
				acao = 1
				vx = 0.0
				_sync_sprite("idle")

	var player := _player_inst()
	if player != null and _anim_timer <= 0:
		lado = -1.0 if player.x <= x else 1.0
		image_xscale = -lado

	_atk_cd = maxf(0.0, _atk_cd - dt)

	if _anim_timer > 0:
		_anim_timer -= int(ceil(spd_mult))
		if _anim_timer <= 0 and y >= GROUND_Y:
			acao = 1
			vx = 0.0
			_sync_sprite("idle")
	elif player != null:
		_think_timer -= dt
		if _think_timer <= 0.0:
			_think_timer = 0.24
			_run_enemy_original_ai(b, player)

	b["e_acao"] = acao
	queue_redraw()


func try_jump_evade() -> void:
	var b: Dictionary = GM.battle
	if not can_jump or y < GROUND_Y - 4.0 or bool(b.get("finished", false)):
		return
	# 원본 적군 탄환 감지 점프 (`z = floor(random(10)); if (z == 0 && CanJump) acao = 4`)
	if _rng.randi_range(0, 9) <= 1:
		can_jump = false
		acao = 4
		vy = -7.8
		vx = -2.0 * lado
		_anim_timer = 20
		_sync_sprite("jump")
		b["e_ai_state"] = "JUMP (acao=4)"


func _run_enemy_original_ai(b: Dictionary, player: GMInstance) -> void:
	var dist: float = absf(player.x - x)
	var move_spd: float = clampf(float(b["e_spd"]) / 105.0, 1.8, 3.4)

	if _atk_cd <= 0.0:
		_atk_cd = 1.65
		var is_ult: bool = float(b["e_sp"]) >= 100.0
		if is_ult:
			b["e_sp"] = 0.0
		else:
			b["e_sp"] = minf(100.0, float(b["e_sp"]) + 22.0)

		var is_crit: bool = (_rng.randi_range(1, 14) == 1)
		var crit_mult: int = 2 if is_crit else 1
		var e_lv: int = int(b["e_lv"])
		var is_melee: bool = (dist < 68.0 and not is_ult)
		var raw_dmg: int = maxi(
			e_lv,
			int(floor((float(b["e_atk"]) * (1.85 if is_ult else (1.15 if is_melee else 1.22)) - float(b["p_def"]) * 0.52) / 1.8))
		) * crit_mult

		image_index = 0.0
		if is_ult:
			acao = 10
			vy = -4.2
			vx = 1.6 * lado
			_sync_sprite("atkSP")
			_anim_timer = 28
			b["e_ai_state"] = "SPECIAL (acao=10)"
		elif is_melee:
			acao = 7
			vx = 1.8 * lado
			_sync_sprite("atk01")
			_anim_timer = 18
			b["e_ai_state"] = "MELEE (acao=7)"
		else:
			acao = 8
			vx = 0.0
			_sync_sprite("atk02")
			_anim_timer = 20
			b["e_ai_state"] = "SP.ATK (acao=8)"

		if player.has_method("spawn_projectile"):
			player.call(
				"spawn_projectile",
				false,
				x + lado * 24.0,
				y - 26.0,
				lado * (7.2 if is_melee else 6.4),
				raw_dmg,
				"CRIT 2x" if is_crit else ("SPECIAL" if is_ult else "ATK"),
				float(crit_mult),
				Color("#FF6B4A"),
				is_ult,
				is_melee
			)
		return

	if dist > 64.0:
		acao = 2
		vx = move_spd * lado
		_sync_sprite("walk")
		b["e_ai_state"] = "WALK (acao=2)"
	else:
		if can_jump and _rng.randi_range(1, 100) <= 18:
			can_jump = false
			acao = 4
			vy = -7.2
			vx = -2.4 * lado
			_sync_sprite("jump")
			_anim_timer = 18
			b["e_ai_state"] = "JUMP (acao=4)"
		else:
			acao = 1
			vx = 0.0
			_sync_sprite("idle")
			b["e_ai_state"] = "IDLE (acao=1)"


func on_hit_knockback(push_dir: float) -> void:
	acao = 6
	image_index = 0.0
	_sync_sprite("dmg")
	_anim_timer = 12
	vx = push_dir * 2.2
	GM.battle["e_ai_state"] = "HIT (acao=6)"


func draw() -> void:
	var shadow_y := GROUND_Y - y
	var shadow_w := clampf(28.0 - absf(shadow_y) * 0.15, 10.0, 28.0)
	draw_rect(Rect2(-shadow_w, shadow_y - 3.0, shadow_w * 2.0, 6.0), Color(0, 0, 0, 0.42))
	super.draw()
