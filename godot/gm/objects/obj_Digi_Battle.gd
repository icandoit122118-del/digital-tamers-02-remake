extends GMInstance
## obj_Digi_Battle — 원본 Digital Tamers 02 실시간 액션 전투 엔진 (acao 1..12 상태머신 + 자동전투 AI)
## - 원본 GML (`gml_Object_obj_Digi_Battle_MASTER_Step_0`, `Digi_Battle_1_to_100`) 그대로 재현:
##   acao=1(Idle), acao=2(Walk), acao=3(WaitTimer 대기), acao=4(Jump), acao=5(Block),
##   acao=6(Hit/Knockback), acao=7(Melee Atk), acao=8(Ranged Sp.Atk), acao=10(Special Ultimate),
##   acao=11(Lose), acao=12(Win)
## - 운빨 주사위/슬롯 제거, 순수 능력치(ATK/DEF/SP.ATK/SPD) + 정통 크리티컬(2.0x) + COMBO + SP 게이지 + 자동전투

const GROUND_Y := 216.0
const GRAV := 0.46

var acao := 1
var lado := 1.0
var can_jump := true
var vy := 0.0
var vx := 0.0
var wait_timer := 18
var alarm_wait := 0
var _anim_timer := 0
var _projectiles: Array = []
var _sp_balls: Array = []
var _popups: Array = []
var _rng := RandomNumberGenerator.new()


func create() -> void:
	_rng.seed = 20261028 + GM.frame * 11
	x = 124.0
	y = GROUND_Y
	vy = 0.0
	vx = 0.0
	acao = 1
	lado = 1.0
	can_jump = true
	image_xscale = -1.0
	image_speed = 0.25
	GM.init_battle_state()
	wait_timer = clampi(32 - int(float(GM.battle.get("p_spd", 265)) / 18.0), 8, 30)
	_sync_sprite("idle")


func _sync_sprite(act: String) -> void:
	var mode: String = str(GM.g.get("dataMode", "demo"))
	var pid: int = int(GM.battle.get("p_id", int(GM.g.get("partnerId", 5))))
	var prefix := "d%d_" % pid
	if mode == "worst":
		prefix = "d152_"
	elif mode == "empty":
		prefix = "d1_"
	var cand := prefix + act
	if GM.sprites.has(cand):
		sprite_index = cand
	elif act == "atk02" and GM.sprites.has(prefix + "atk01"):
		sprite_index = prefix + "atk01"
	elif GM.sprites.has(prefix + "idle"):
		sprite_index = prefix + "idle"
	else:
		sprite_index = "d5_idle"


func _enemy_inst() -> GMInstance:
	for inst in GM.instances:
		if inst.obj_name == "obj_Enemy_Battle" and not inst.dead:
			return inst
	return null


func step() -> void:
	var b: Dictionary = GM.battle
	var enemy := _enemy_inst()
	var spd_mult: float = 2.0 if bool(b.get("speed2x", true)) else 1.0
	var dt: float = (1.0 / 60.0) * spd_mult

	# 승패 확정 상태 (acao 11: Lose, acao 12: Win)
	if bool(b.get("finished", false)):
		vx = 0.0
		if y < GROUND_Y:
			vy += GRAV * spd_mult
			y = minf(GROUND_Y, y + vy * spd_mult)
		acao = 12 if bool(b.get("win", true)) else 11
		b["p_acao"] = acao
		_sync_sprite("win" if acao == 12 else "lose")
		_tick_projectiles_and_popups(dt, enemy)
		queue_redraw()
		return

	# 중력 & 바닥 착지 (`gml_Object_obj_Digi_Battle_Collision_obj_Floor`)
	x = clampf(x + vx * spd_mult, 48.0, 478.0)
	if y < GROUND_Y or vy < 0.0:
		vy += GRAV * spd_mult
		y += vy * spd_mult
		if y >= GROUND_Y:
			y = GROUND_Y
			vy = 0.0
			can_jump = true
			if acao == 4:
				acao = 3
				alarm_wait = maxi(4, wait_timer / 2)
				vx = 0.0
				_sync_sprite("idle")

	if enemy != null and acao < 6:
		lado = 1.0 if x < enemy.x else -1.0
		image_xscale = -lado

	# Block 게이지 자연 회복 & 스킬 쿨다운 갱신
	b["p_block"] = minf(100.0, float(b.get("p_block", 100.0)) + dt * 12.0)
	var cd_rate: float = 1.0 + clampf(float(b["p_spd"]) / 600.0, 0.0, 1.0)
	for sk in b["skills"]:
		if float(sk["cd"]) > 0.0:
			sk["cd"] = maxf(0.0, float(sk["cd"]) - dt * cd_rate)

	# 원본 적 탄환 접근 감지 (distance_to_object(obj_Enemy_SPAtk) < 140) → 자동 점프 회피(acao=4) 또는 가드(acao=5)
	_check_incoming_enemy_attack(b)

	# 액션 타이머 / WaitTimer (acao == 3)
	if _anim_timer > 0:
		_anim_timer -= int(ceil(spd_mult))
		if _anim_timer <= 0:
			vx = 0.0
			acao = 3
			alarm_wait = wait_timer
			_sync_sprite("idle")
	elif alarm_wait > 0:
		alarm_wait -= int(ceil(spd_mult))
		if alarm_wait <= 0:
			acao = 1
	elif enemy != null:
		_step_original_combat_ai(b, enemy)

	b["p_acao"] = acao
	_tick_projectiles_and_popups(dt, enemy)
	queue_redraw()


func _check_incoming_enemy_attack(b: Dictionary) -> void:
	if acao >= 5:
		return
	for p in _projectiles:
		if bool(p["from_player"]) or bool(p.get("evade_checked", false)):
			continue
		var dist_x: float = absf(float(p["x"]) - x)
		if dist_x < 120.0 and dist_x > 20.0:
			p["evade_checked"] = true
			var roll: int = _rng.randi_range(0, 9)
			var tactic: String = str(b.get("ai_tactic", "balanced"))
			# 원본 GML: z = floor(random(10)); if (z == 0 && CanJump) acao = 4; + 자동전투 보정
			if can_jump and (roll <= (3 if tactic == "evasive" else 2)):
				_trigger_jump(b, "JUMP EVADE (acao=4)")
				b["p_dodge_count"] = int(b["p_dodge_count"]) + 1
				_spawn_popup(x, y - 50.0, "JUMP EVADE!", Color("#00E5B0"))
				return
			elif bool(b.get("auto_skill", true)) and float(b.get("p_block", 100.0)) >= 25.0 and roll <= (6 if tactic == "evasive" else 4):
				cast_skill(2)
				return


func _trigger_jump(b: Dictionary, label: String) -> void:
	if not can_jump:
		return
	can_jump = false
	acao = 4
	alarm_wait = 0
	vy = -8.2
	vx = (3.6 if _rng.randi_range(0, 1) == 0 else -2.2) * lado
	_anim_timer = 22
	_sync_sprite("jump")
	b["p_ai_state"] = label


func _step_original_combat_ai(b: Dictionary, enemy: GMInstance) -> void:
	var dist: float = absf(enemy.x - x)
	var move_spd: float = clampf(float(b["p_spd"]) / 95.0, 2.2, 3.8)
	var auto_on: bool = bool(b.get("auto_skill", true))
	var skills: Array = b["skills"]
	var tactic: String = str(b.get("ai_tactic", "balanced"))

	# 1) 자동전투(AUTO): SP 100% 도달 시 원본 스페셜 필살기(acao=10) 즉시 발동
	if auto_on and float(b["p_sp"]) >= 100.0:
		cast_skill(3)
		return

	# 2) 원본 GML 거리별 행동 결정 (`Digi_Battle_1_to_100`)
	# - 원거리(dist >= 55): 적을 향해 전진(acao=2)하며 걷는 중 원거리 공격(acao=8) 발사
	if dist >= 58.0:
		acao = 2
		vx = move_spd * lado
		_sync_sprite("walk")
		b["p_ai_state"] = "WALK (acao=2)"
		if auto_on and float(skills[1]["cd"]) <= 0.0 and (dist > 95.0 or tactic == "ranged"):
			cast_skill(1)
			return
		elif can_jump and _rng.randi_range(1, 100) <= 6:
			_trigger_jump(b, "DASH JUMP (acao=4)")
			return
	# - 중근접(dist < 58): 근접 공격(acao=7), 원거리 사격(acao=8), 또는 전술 점프(acao=4)
	else:
		if auto_on:
			if float(skills[0]["cd"]) <= 0.0:
				cast_skill(0)
				return
			elif float(skills[1]["cd"]) <= 0.0:
				cast_skill(1)
				return
		if can_jump and _rng.randi_range(1, 100) <= 22:
			_trigger_jump(b, "JUMP (acao=4)")
		else:
			cast_skill(0)


func cast_skill(idx: int) -> void:
	var b: Dictionary = GM.battle
	if bool(b.get("finished", false)):
		return
	var enemy := _enemy_inst()
	if enemy != null:
		lado = 1.0 if x < enemy.x else -1.0
		image_xscale = -lado

	var skills: Array = b["skills"]
	if idx < 0 or idx >= skills.size():
		return
	var sk: Dictionary = skills[idx]
	sk["cd"] = float(sk["cd_max"])

	# 원본 크리티컬 판정: crit = floor(random_range(1, clamp(20 - Focus, 2, 20))) == 1 → CRITICAL = 2
	var focus_stat: int = clampi(int(float(b["p_spd"]) / 30.0), 1, 14)
	var crit_denom: int = clampi(18 - focus_stat, 3, 18)
	var is_crit: bool = (_rng.randi_range(1, crit_denom) == 1)
	var crit_mult: int = 2 if is_crit else 1
	var p_lv: int = int(b["p_lv"])

	image_index = 0.0
	if idx == 0:
		# acao = 7: 원본 근접 물리 공격 (atk01 / obj_Player_Mask)
		acao = 7
		vx = 1.8 * lado
		_anim_timer = 18
		_sync_sprite("atk01")
		b["p_ai_state"] = "MELEE ATK (acao=7)"
		var raw_atk: int = maxi(p_lv, int(floor((float(b["p_atk"]) * 1.15 - float(b["e_def"]) * 0.55) / 1.8))) * crit_mult
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + float(sk["sp_gain"]))
		spawn_projectile(true, x + lado * 22.0, y - 24.0, lado * 7.8, raw_atk, "CRITICAL 2x!" if is_crit else "MELEE HIT", float(crit_mult), Color("#F5C451") if is_crit else Color("#F0F6FC"), false, true)
		sk["last_roll"] = "%d DMG%s" % [raw_atk, " (CRIT!)" if is_crit else ""]
		b["last_tier"] = "CRITICAL 2.0x" if is_crit else "MELEE (acao=7)"
		b["last_mult"] = float(crit_mult)
		b["last_log"] = "[AUTO] %s Melee Strike (acao=7) → %d DMG%s" % [str(b["p_name"]), raw_atk, " [CRITICAL!]" if is_crit else ""]
	elif idx == 1:
		# acao = 8: 원본 원거리 속성 공격 (atk02 / obj_Player_SPAtk)
		acao = 8
		vx = 0.0
		_anim_timer = 20
		_sync_sprite("atk02")
		b["p_ai_state"] = "RANGED SP.ATK (acao=8)"
		var raw_sp: int = maxi(p_lv, int(floor((float(b["p_sp_atk"]) * 1.25 - float(b["e_def"]) * 0.48) / 1.7))) * crit_mult
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + float(sk["sp_gain"]))
		spawn_projectile(true, x + lado * 26.0, y - 26.0, lado * 6.8, raw_sp, "CRITICAL 2x!" if is_crit else "SP.ATK SHOT", float(crit_mult), Color("#00E5B0") if not is_crit else Color("#F5C451"), false, false)
		sk["last_roll"] = "%d DMG%s" % [raw_sp, " (CRIT!)" if is_crit else ""]
		b["last_tier"] = "CRITICAL 2.0x" if is_crit else "SP.ATK (acao=8)"
		b["last_mult"] = float(crit_mult)
		b["last_log"] = "[AUTO] %s Ranged Sp.Atk (acao=8) → %d DMG%s" % [str(b["p_name"]), raw_sp, " [CRITICAL!]" if is_crit else ""]
	elif idx == 2:
		# acao = 5: 원본 가드 / 블록 (d_block + Block 게이지)
		acao = 5
		vx = 0.0
		_anim_timer = 22
		_sync_sprite("block")
		b["shield_active"] = true
		b["p_ai_state"] = "GUARD (acao=5)"
		sk["last_roll"] = "BLOCK %.0f%%" % float(b.get("p_block", 100.0))
		b["last_tier"] = "GUARD (acao=5)"
		b["last_mult"] = 1.0
		b["last_log"] = "[AUTO] %s raised Guard (acao=5, Block %.0f%%)" % [str(b["p_name"]), float(b.get("p_block", 100.0))]
	elif idx == 3:
		# acao = 10: 원본 스페셜 필살기 (d_atkSP / UltatkMASK)
		if float(b["p_sp"]) < 100.0:
			b["p_sp"] = 100.0
		b["p_sp"] = 0.0
		acao = 10
		vy = -3.8
		vx = 1.2 * lado
		_anim_timer = 30
		_sync_sprite("atkSP")
		b["p_ai_state"] = "SPECIAL (acao=10)"
		var ult_dmg: int = maxi(p_lv * 3, int(floor((float(b["p_sp_atk"]) * 2.35 - float(b["e_def"]) * 0.35)))) * crit_mult
		spawn_projectile(true, x + lado * 28.0, y - 28.0, lado * 7.6, ult_dmg, "SPECIAL ULTIMATE!", float(crit_mult), Color("#F5C451"), true, false)
		sk["last_roll"] = "ULT %d DMG!" % ult_dmg
		b["last_tier"] = "SPECIAL (acao=10)"
		b["last_mult"] = float(crit_mult)
		b["last_log"] = "★ [SPECIAL] %s unleashed Ultimate Special (acao=10) → %d DMG!" % [str(b["p_name"]), ult_dmg]

	GM.play_sound_fx("snd_Click06")


func spawn_projectile(from_player: bool, px: float, py: float, vx_spd: float, dmg: int, tier: String, mult: float, col: Color, is_ult: bool, is_melee: bool = false) -> void:
	_projectiles.append({
		"from_player": from_player,
		"x": px,
		"y": py,
		"vx": vx_spd,
		"dmg": dmg,
		"tier": tier,
		"mult": mult,
		"col": col,
		"is_ult": is_ult,
		"is_melee": is_melee,
		"evade_checked": false,
		"ttl": 0.32 if is_melee else 2.2,
	})


func _tick_projectiles_and_popups(dt: float, enemy: GMInstance) -> void:
	var b: Dictionary = GM.battle
	for p in _projectiles.duplicate():
		p["x"] = float(p["x"]) + float(p["vx"]) * (dt * 60.0)
		p["ttl"] = float(p["ttl"]) - dt
		if float(p["ttl"]) <= 0.0 or float(p["x"]) < 20.0 or float(p["x"]) > 518.0:
			_projectiles.erase(p)
			continue

		var from_p: bool = bool(p["from_player"])
		var target: GMInstance = enemy if from_p else self
		if target == null:
			continue

		if from_p and not bool(p["evade_checked"]) and absf(float(p["x"]) - target.x) < 96.0:
			p["evade_checked"] = true
			if target.has_method("try_jump_evade"):
				target.call("try_jump_evade")

		var dx: float = absf(float(p["x"]) - target.x)
		var dy: float = absf(float(p["y"]) - (target.y - 26.0))
		var hit_r: float = 34.0 if bool(p["is_ult"]) else (28.0 if bool(p.get("is_melee", false)) else 22.0)
		if dx <= hit_r and dy <= (hit_r + 8.0):
			_projectiles.erase(p)
			_apply_hit(b, from_p, target, p)

	# 스페셜 에너지 구슬(`obj_SpecialBall`) 흡수 연출
	for ball in _sp_balls.duplicate():
		ball["ttl"] = float(ball["ttl"]) - dt
		var dest_x: float = x if bool(ball["to_player"]) else (enemy.x if enemy != null else 412.0)
		ball["x"] = lerpf(float(ball["x"]), dest_x, clampf(dt * 7.0, 0.0, 1.0))
		ball["y"] = lerpf(float(ball["y"]), GROUND_Y - 28.0, clampf(dt * 7.0, 0.0, 1.0))
		if float(ball["ttl"]) <= 0.0 or absf(float(ball["x"]) - dest_x) < 12.0:
			_sp_balls.erase(ball)

	for pop in _popups.duplicate():
		pop["y"] = float(pop["y"]) - dt * 26.0
		pop["ttl"] = float(pop["ttl"]) - dt
		if float(pop["ttl"]) <= 0.0:
			_popups.erase(pop)


func _apply_hit(b: Dictionary, from_p: bool, target: GMInstance, p: Dictionary) -> void:
	if bool(b.get("finished", false)):
		return
	var dmg: int = int(p["dmg"])
	var is_crit: bool = float(p["mult"]) >= 2.0

	if from_p:
		b["e_hp"] = maxi(0, int(b["e_hp"]) - dmg)
		b["p_combo"] = int(b.get("p_combo", 0)) + 1
		b["e_combo"] = 0
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + 10.0)
		b["e_sp"] = minf(100.0, float(b["e_sp"]) + 12.0)

		# 원본 obj_SpecialBall 드롭 연출
		for i in range(3):
			_sp_balls.append({
				"x": target.x + _rng.randf_range(-16.0, 16.0),
				"y": target.y - 30.0 + _rng.randf_range(-12.0, 8.0),
				"to_player": true,
				"ttl": 0.45,
			})

		var tag := "-%d%s" % [dmg, " CRIT!" if is_crit else ""]
		if int(b["p_combo"]) >= 2:
			tag += " (%d HIT)" % int(b["p_combo"])
		_spawn_popup(target.x, target.y - 52.0, tag, p["col"], 1.2 if is_crit else 1.0)

		if target.has_method("on_hit_knockback"):
			target.call("on_hit_knockback", 1.0 if target.x >= x else -1.0)

		if int(b["e_hp"]) <= 0:
			_finish_single_match(b, true)
	else:
		# 아군 가드 상태(acao == 5 또는 shield_active) 판정 (`Target.HitWhileBlocking = true`)
		if acao == 5 or bool(b.get("shield_active", false)):
			b["shield_active"] = false
			b["p_block"] = maxf(0.0, float(b.get("p_block", 100.0)) - 28.0)
			b["p_parry_count"] = int(b["p_parry_count"]) + 1
			var blocked_dmg: int = maxi(1, int(round(float(dmg) * 0.15)))
			b["p_hp"] = maxi(0, int(b["p_hp"]) - blocked_dmg)
			_spawn_popup(x, y - 54.0, "BLOCKED! (-%d)" % blocked_dmg, Color("#38BDF8"), 1.15)
			b["last_log"] = "[BLOCK] Guard absorbed enemy attack (-%d DMG) & countered!" % blocked_dmg
			# 원본 HitWhileBlocking 카운터 공격
			var counter_dmg: int = maxi(int(b["p_lv"]), int(round(float(b["p_atk"]) * 1.35 - float(b["e_def"]) * 0.4)))
			spawn_projectile(true, x + lado * 22.0, y - 24.0, lado * 7.5, counter_dmg, "COUNTER", 1.0, Color("#00E5B0"), false, true)
			return

		# 원본 피격 (acao = 6, Player_COMBO = 0, 넉백)
		b["p_hp"] = maxi(0, int(b["p_hp"]) - dmg)
		b["p_combo"] = 0
		b["e_combo"] = int(b.get("e_combo", 0)) + 1
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + 12.0)
		acao = 6
		vx = -2.6 * lado
		_anim_timer = 14
		_sync_sprite("dmg")
		b["p_ai_state"] = "HIT (acao=6)"
		_spawn_popup(x, y - 48.0, "-%d%s" % [dmg, " CRIT!" if is_crit else ""], Color("#FF6B4A"), 1.1)

		if int(b["p_hp"]) <= 0:
			_finish_single_match(b, false)


func _finish_single_match(b: Dictionary, is_win: bool) -> void:
	b["finished"] = true
	b["win"] = is_win
	var e_lv: int = int(b["e_lv"])
	var p_lv: int = int(b["p_lv"])
	var ini_atr_mod: float = float(b.get("e_atr_mod", 1.0))
	GM.g["totalBattles"] = int(GM.g.get("totalBattles", 20)) + 1

	if is_win:
		acao = 12
		# 원작 gml_Object_obj_Win_Lose_HUD_Create_0.gml 보상 정산 공식
		var won_bits: int = maxi(50, int(floor(float(e_lv) * 50.0 * ini_atr_mod * 2.0)))
		var given_xp: int = maxi(15, int(floor(float(e_lv) * 15.0 + float(e_lv - p_lv) * 1.6 + 12.0)))
		var tamer_xp_gain: int = maxi(5, int(floor(float(given_xp) / 4.0)))
		b["bonus_bits"] = won_bits
		b["given_xp"] = given_xp
		b["tamer_xp_gain"] = tamer_xp_gain
		GM.g["bits"] = int(GM.g.get("bits", 24500)) + won_bits
		GM.g["wins"] = int(GM.g.get("wins", 18)) + 1
		GM.g["friendship"] = minf(100.0, float(GM.g.get("friendship", 75.0)) + 1.0)
		GM.g["hunger"] = maxi(0, int(GM.g.get("hunger", 80)) - 6)
		GM.g["tamerXp"] = int(GM.g.get("tamerXp", 420)) + tamer_xp_gain
		if int(GM.g["tamerXp"]) >= 500:
			GM.g["tamerXp"] = int(GM.g["tamerXp"]) - 500
			GM.g["tamerLv"] = int(GM.g.get("tamerLv", 12)) + 1
			GM.g["tamerSp"] = int(GM.g.get("tamerSp", 5)) + 1
		if str(GM.g.get("battleMode", "world")) == "infinity":
			GM.g["infinityFloor"] = int(GM.g.get("infinityFloor", 1)) + 1
		elif str(GM.g.get("battleMode", "world")) == "challenge":
			GM.g["challengeRank"] = int(GM.g.get("challengeRank", 1)) + 1
		b["result_banner"] = "🏆 VICTORY! (+%d BIT · +%d XP · +%d Tamer XP)" % [won_bits, given_xp, tamer_xp_gain]
		b["last_log"] = "🏆 WIN: %s defeated %s! (+%d BIT, +%d XP, W:%d/L:%d)" % [str(b["p_name"]), str(b["e_name"]), won_bits, given_xp, int(GM.g["wins"]), int(GM.g.get("losses", 2))]
		_spawn_popup(269.0, 104.0, b["result_banner"], Color("#00E5B0"), 1.4)
	else:
		acao = 11
		var won_bits: int = p_lv * 7
		var given_xp: int = p_lv * 3
		GM.g["bits"] = int(GM.g.get("bits", 24500)) + won_bits
		GM.g["losses"] = int(GM.g.get("losses", 2)) + 1
		GM.g["friendship"] = maxf(0.0, float(GM.g.get("friendship", 75.0)) - 1.0)
		GM.g["injury"] = mini(5, int(GM.g.get("injury", 0)) + 1)
		b["result_banner"] = "💀 DEFEAT (+%d BIT · +%d XP · Injury +1)" % [won_bits, given_xp]
		b["last_log"] = "💀 DEFEAT: Treat injury (Bandage) or train stats in Sanctuary!"
		_spawn_popup(269.0, 104.0, b["result_banner"], Color("#FF6B4A"), 1.4)
	if not GM.instance_exists("obj_Win_Lose_HUD"):
		GM.instance_create(79.0, 92.0, "obj_Win_Lose_HUD")


func _spawn_popup(px: float, py: float, txt: String, col: Color, scale_f: float = 1.0) -> void:
	_popups.append({
		"x": px,
		"y": py,
		"txt": txt,
		"col": col,
		"ttl": 1.25,
		"scale": scale_f,
	})


func draw() -> void:
	var shadow_y := GROUND_Y - y
	var shadow_w := clampf(26.0 - absf(shadow_y) * 0.15, 10.0, 26.0)
	draw_Rect_shadow(shadow_w, shadow_y)
	super.draw()

	# 스페셜 에너지 구슬 (obj_SpecialBall)
	for ball in _sp_balls:
		var bx: float = float(ball["x"]) - x
		var by: float = float(ball["y"]) - y
		draw_circle(Vector2(bx, by), 5.0, Color(0.96, 0.77, 0.32, 0.45))
		draw_circle(Vector2(bx, by), 3.0, Color("#F5C451"))

	# 투사체 / 근접 이펙트 렌더링
	for p in _projectiles:
		var cx: float = float(p["x"]) - x
		var cy: float = float(p["y"]) - y
		var r: float = 13.0 if bool(p["is_ult"]) else 8.0
		var c: Color = p["col"]
		draw_circle(Vector2(cx, cy), r + 4.0, Color(c.r, c.g, c.b, 0.32))
		draw_circle(Vector2(cx, cy), r, c)
		var spr_name := "spr_FireBurst01" if bool(p["from_player"]) else "spr_FireBarr04"
		var max_f: int = maxi(1, int(GM.sprites.get(spr_name, {"frames": 1})["frames"]))
		var tex := GM.tex(spr_name, int(GM.frame / 3) % max_f)
		if tex != null:
			draw_texture(tex, Vector2(cx - 14.0, cy - 14.0))

	# 플로팅 데미지 마커 (obj_DmgMarker)
	var fnt := ThemeDB.fallback_font
	if fnt != null:
		for pop in _popups:
			var alpha: float = clampf(float(pop["ttl"]) * 1.4, 0.0, 1.0)
			var pos := Vector2(float(pop["x"]) - x - 75.0, float(pop["y"]) - y)
			var c: Color = pop["col"]
			c.a = alpha
			draw_string_outline(fnt, pos, str(pop["txt"]), HORIZONTAL_ALIGNMENT_CENTER, 150, 11, 3, Color(0, 0, 0, alpha))
			draw_string(fnt, pos, str(pop["txt"]), HORIZONTAL_ALIGNMENT_CENTER, 150, 11, c)


func draw_Rect_shadow(w: float, sy: float) -> void:
	draw_rect(Rect2(-w, sy - 3.0, w * 2.0, 6.0), Color(0, 0, 0, 0.42))
