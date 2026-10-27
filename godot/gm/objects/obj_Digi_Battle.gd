extends GMInstance
## obj_Digi_Battle — 단판 오토체스형 자율 기동·점프·회피·스킬 AI (능력치 기반 × 컨트롤/배율 운빨)
## - 아군과 적군 모두 중력(vy)·점프(jump)·이동(walk)·가드(block)·근접/원거리 스킬(atk01/atk02/atkSP) 수행
## - 상대 투사체/강공격 감지 시 [SPD + LUK] 기반 AI 반응 주사위로 실제 점프 회피(Jump Evade) 또는 패링(Parry)
## - 한쪽 HP가 0이 되면 즉시 단판 승패(VICTORY / DEFEAT) 확정

const GROUND_Y := 216.0
const GRAV := 0.44

var vy := 0.0
var vx := 0.0
var _anim_timer := 0
var _ai_think_timer := 0.0
var _projectiles: Array = []   # 아군/적군 탄환 모두 물리 좌표(x, y)로 충돌/점프회피 판정
var _popups: Array = []
var _rng := RandomNumberGenerator.new()


func create() -> void:
	_rng.seed = 7772026 + GM.frame * 13
	x = 124.0
	y = GROUND_Y
	vy = 0.0
	vx = 0.0
	image_xscale = -1.0
	image_speed = 0.24
	GM.init_battle_state()
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

	# 단판 승패 종료 상태
	if bool(b.get("finished", false)):
		vx = 0.0
		if y < GROUND_Y:
			vy += GRAV * spd_mult
			y = minf(GROUND_Y, y + vy * spd_mult)
		_sync_sprite("win" if bool(b.get("win", true)) else "lose")
		_tick_projectiles_and_popups(dt, enemy)
		queue_redraw()
		return

	# 1) 물리(중력 & 점프 & 수평 기동) 업데이트
	x = clampf(x + vx * spd_mult, 54.0, 468.0)
	if y < GROUND_Y or vy < 0.0:
		vy += GRAV * spd_mult
		y += vy * spd_mult
		if y >= GROUND_Y:
			y = GROUND_Y
			vy = 0.0
			if _anim_timer <= 0:
				vx = 0.0
				_sync_sprite("idle")

	if enemy != null and _anim_timer <= 0:
		image_xscale = -1.0 if enemy.x >= x else 1.0

	# 2) 전투 운빨 룰렛(환경 변수) 타이머
	b["slot_timer"] = float(b["slot_timer"]) - dt
	if float(b["slot_timer"]) <= 0.0:
		_roll_combat_luck_event(b)
	if float(b["fever_timer"]) > 0.0:
		b["fever_timer"] = maxf(0.0, float(b["fever_timer"]) - dt)

	# 3) 능력치(SPD) 기반 스킬 쿨타임 회복
	var cd_rate: float = 1.0 + clampf(float(b["p_spd"]) / 550.0, 0.0, 1.3)
	if float(b["fever_timer"]) > 0.0:
		cd_rate *= 2.0
	for sk in b["skills"]:
		if float(sk["cd"]) > 0.0:
			sk["cd"] = maxf(0.0, float(sk["cd"]) - dt * cd_rate)

	# 4) 적 탄환 접근 시 AI 자율 점프 회피(Jump Evade) 반응 체크
	_check_incoming_projectile_evade(b, true)

	# 5) 아군 오토체스 기동 & 자동 스킬 AI
	if _anim_timer > 0:
		_anim_timer -= int(ceil(spd_mult))
		if _anim_timer <= 0 and y >= GROUND_Y:
			vx = 0.0
			_sync_sprite("idle")
	else:
		_ai_think_timer -= dt
		if _ai_think_timer <= 0.0 and enemy != null:
			_ai_think_timer = 0.22
			_run_player_autochess_ai(b, enemy)

	_tick_projectiles_and_popups(dt, enemy)
	queue_redraw()


func _check_incoming_projectile_evade(b: Dictionary, is_player: bool) -> void:
	if y < GROUND_Y - 8.0:
		return
	for p in _projectiles:
		if bool(p["from_player"]) == is_player or bool(p.get("evade_checked", false)):
			continue
		var dist_x: float = absf(float(p["x"]) - x)
		if dist_x < 78.0 and dist_x > 22.0:
			p["evade_checked"] = true
			var spd_v: int = int(b["p_spd"]) if is_player else int(b["e_spd"])
			var luk_v: int = int(b["p_luk"]) if is_player else int(b["e_luk"])
			var tactic_bonus: int = 18 if (is_player and str(b.get("ai_tactic", "")) == "evasive") else 0
			var evade_chance: int = clampi(18 + int(float(spd_v) * 0.05 + float(luk_v) * 0.32) + tactic_bonus, 15, 72)
			if _rng.randi_range(1, 100) <= evade_chance:
				# 실제 점프 기동으로 탄환을 뛰어넘음!
				vy = -8.4
				vx = -1.6 if is_player else 1.6
				_anim_timer = 24
				_sync_sprite("jump")
				b["p_ai_state"] = "JUMP EVADE!"
				b["p_dodge_count"] = int(b["p_dodge_count"]) + 1
				b["p_sp"] = minf(100.0, float(b["p_sp"]) + 18.0)
				_spawn_popup(x, y - 52.0, "⚡ AI JUMP EVADE!", Color("#00E5B0"), 1.2)
				b["last_log"] = "[AI CONTROL RNG] %s jumped over incoming projectile! (+18 SP)" % str(b["p_name"])
				return


func _run_player_autochess_ai(b: Dictionary, enemy: GMInstance) -> void:
	var dist: float = absf(enemy.x - x)
	var dir: float = 1.0 if enemy.x >= x else -1.0
	var move_spd: float = clampf(float(b["p_spd"]) / 115.0, 1.8, 3.6)

	# 자동 스킬 발동이 켜져 있으면 준비된 스킬 우선 시전
	if bool(b.get("auto_skill", true)):
		var skills: Array = b["skills"]
		# 1순위: 궁극기 (SP 100%)
		if float(b["p_sp"]) >= 100.0 and float(skills[3]["cd"]) <= 0.0:
			cast_skill(3)
			return
		# 2순위: 점프 다이브 강습 (Aerial Horn Dive - 중거리에서 점프하며 돌진!)
		if float(skills[1]["cd"]) <= 0.0 and dist < 240.0:
			cast_skill(1)
			return
		# 3순위: 근접 위협 시 미라클 가드/패링
		if float(skills[2]["cd"]) <= 0.0 and dist < 130.0:
			cast_skill(2)
			return
		# 4순위: 원거리 화염탄 (Nova Blast)
		if float(skills[0]["cd"]) <= 0.0:
			cast_skill(0)
			return

	# 스킬 쿨타임 중일 때 오토체스 자율 기동 (접근 / 전술 점프 / 거리유지 백스텝)
	var roll_move: int = _rng.randi_range(1, 100)
	if dist > 165.0:
		vx = dir * move_spd
		_sync_sprite("walk")
		b["p_ai_state"] = "APPROACH"
		if roll_move <= 24 and y >= GROUND_Y:
			vy = -7.2
			vx = dir * (move_spd * 1.25)
			_sync_sprite("jump")
			b["p_ai_state"] = "DASH JUMP"
	elif dist < 72.0:
		# 너무 가까우면 백스텝 점프 또는 견제
		vx = -dir * (move_spd * 1.1)
		if roll_move <= 45 and y >= GROUND_Y:
			vy = -6.8
			_sync_sprite("jump")
			b["p_ai_state"] = "BACKSTEP JUMP"
		else:
			_sync_sprite("walk")
			b["p_ai_state"] = "SPACING"
	else:
		vx = dir * (move_spd * 0.5) if roll_move <= 50 else -dir * (move_spd * 0.4)
		_sync_sprite("walk")
		b["p_ai_state"] = "FOOTSIES"


func cast_skill(idx: int) -> void:
	var b: Dictionary = GM.battle
	if bool(b.get("finished", false)):
		return
	var enemy := _enemy_inst()
	var dir: float = 1.0 if (enemy == null or enemy.x >= x) else -1.0
	var skills: Array = b["skills"]
	if idx < 0 or idx >= skills.size():
		return
	var sk: Dictionary = skills[idx]

	if idx == 3:
		b["p_sp"] = 0.0
	else:
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + float(sk["sp_gain"]))
	sk["cd"] = float(sk["cd_max"])

	# --- 능력치 기반 × 운빨(D100 Roll) 배율 판정 ---
	var luk: int = int(b["p_luk"])
	var tactic: String = str(b.get("ai_tactic", "gamble"))
	var raw_d100: int = _rng.randi_range(1, 100)
	var luk_bonus: int = int(clampf(float(luk) * 0.25, 0.0, 26.0))
	if tactic == "gamble":
		luk_bonus += 10
	if float(b["fever_timer"]) > 0.0:
		luk_bonus += 30
	var final_roll: int = clampi(raw_d100 + luk_bonus, 1, 120)

	var tier := "NORMAL"
	var mult := 1.0
	var popup_col := Color("#F0F6FC")
	if final_roll >= 94:
		tier = "★ 777 JACKPOT ★"
		mult = 7.77
		popup_col = Color("#F5C451")
		b["jackpot_count"] = int(b["jackpot_count"]) + 1
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + 45.0)
	elif final_roll >= 78:
		tier = "SSR OVERLOAD"
		mult = 4.0
		popup_col = Color("#FF6B4A")
	elif final_roll >= 50:
		tier = "LUCKY CRIT"
		mult = 2.2
		popup_col = Color("#00E5B0")
	elif final_roll <= (22 if tactic == "gamble" else 12) and float(b["fever_timer"]) <= 0.0:
		tier = "GRAZE (삐끗)"
		mult = 0.5
		popup_col = Color("#647D96")

	var stat_val: float = float(b["p_sp_atk"]) if idx in [0, 3] else float(b["p_atk"])
	var base_dmg: float = maxf(42.0, (stat_val * float(sk["power"])) - float(b["e_def"]) * 0.35)
	var final_dmg: int = maxi(1, int(round(base_dmg * mult)))

	# 운빨 연속 발동 (DOUBLE CAST x2)
	if idx != 3 and _rng.randi_range(1, 100) <= clampi(14 + int(float(luk) * 0.2), 14, 42):
		sk["cd"] = 0.2
		final_dmg = int(round(float(final_dmg) * 1.3))
		tier += " + DOUBLE CAST!"

	image_index = 0.0
	if idx == 1:
		# Aerial Horn Dive: 실제로 점프해서 적을 향해 공중 강습!
		vy = -7.6
		vx = dir * 4.8
		_anim_timer = 26
		_sync_sprite("jump")
		b["p_ai_state"] = "JUMP STRIKE!"
	elif idx == 2:
		# Miracle Guard: 방어 태세 + 패링 실드 활성
		vx = 0.0
		_anim_timer = 22
		_sync_sprite("block")
		b["shield_active"] = true
		b["p_ai_state"] = "MIRACLE GUARD"
	elif idx == 3 or mult >= 7.0:
		vy = -4.5
		vx = dir * 1.5
		_anim_timer = 30
		_sync_sprite("atkSP")
		b["p_ai_state"] = "ULTIMATE BURST!"
	else:
		vx = 0.0
		_anim_timer = 20
		_sync_sprite("atk01")
		b["p_ai_state"] = "SKILL: " + str(sk["name"])

	spawn_projectile(true, x + dir * 24.0, y - 26.0, dir * 6.8, final_dmg, tier, mult, popup_col, idx == 3 or mult >= 7.0)

	sk["last_roll"] = "D100:%d → %.2fx (%s)" % [min(final_roll, 100), mult, tier]
	sk["last_mult"] = mult
	b["last_dice"] = min(final_roll, 100)
	b["last_tier"] = tier
	b["last_mult"] = mult
	b["last_log"] = "[AUTO] %s → D100(%d) %s [%.2fx] · %d DMG" % [str(sk["name"]), min(final_roll, 100), tier, mult, final_dmg]
	GM.play_sound_fx("snd_Click06")


func spawn_projectile(from_player: bool, px: float, py: float, vx_spd: float, dmg: int, tier: String, mult: float, col: Color, is_ult: bool) -> void:
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
		"evade_checked": false,
		"ttl": 2.2,
	})


func _roll_combat_luck_event(b: Dictionary) -> void:
	b["slot_timer"] = 3.8
	var events := [
		{"sym": "7 · 7 · 7", "title": "777 FEVER OVERDRIVE!", "desc": "Cooldown 2x Faster + +30 LUK Roll (4.5s)", "kind": "jackpot"},
		{"sym": "⚡ · ⚡ · ⚡", "title": "AI HYPER REFLEX!", "desc": "Instant Skill Reset + Jump Dodge Boost", "kind": "reflex"},
		{"sym": "🛡️ · 🛡️ · 🛡️", "title": "MIRACLE PARRY SHIELD!", "desc": "Blocks Next Hit & Counters 3.0x", "kind": "shield"},
		{"sym": "🎲 · 💀 · 🎲", "title": "BOSS ENRAGE JINX!", "desc": "Enemy Boss Gains +40 SP & High Crit Risk!", "kind": "jinx"},
	]
	var pick: Dictionary = events[_rng.randi_range(0, events.size() - 1)]
	b["slot_reels"] = str(pick["sym"])
	b["slot_title"] = str(pick["title"])
	b["slot_desc"] = str(pick["desc"])
	var k: String = str(pick["kind"])
	if k == "jackpot":
		b["fever_timer"] = 4.5
		b["p_sp"] = minf(100.0, float(b["p_sp"]) + 40.0)
	elif k == "reflex":
		for sk in b["skills"]:
			sk["cd"] = 0.0
	elif k == "shield":
		b["shield_active"] = true
	elif k == "jinx":
		b["e_sp"] = minf(100.0, float(b["e_sp"]) + 45.0)
	_spawn_popup(269.0, 96.0, "🎰 " + str(pick["title"]), Color("#F5C451"), 1.25)


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

		# 적군도 탄환이 다가오면 자체 점프 회피 시도!
		if from_p and not bool(p["evade_checked"]) and absf(float(p["x"]) - target.x) < 74.0:
			p["evade_checked"] = true
			if target.has_method("try_jump_evade"):
				target.call("try_jump_evade")

		# 실제 2D 히트박스(x 거리 + y 점프 높이) 충돌 판정!
		var dx: float = absf(float(p["x"]) - target.x)
		var dy: float = absf(float(p["y"]) - (target.y - 26.0))
		var hit_r: float = 34.0 if bool(p["is_ult"]) else 22.0
		if dx <= hit_r and dy <= (hit_r + 8.0):
			_projectiles.erase(p)
			_apply_hit(b, from_p, target, p)

	for pop in _popups.duplicate():
		pop["y"] = float(pop["y"]) - dt * 26.0
		pop["ttl"] = float(pop["ttl"]) - dt
		if float(pop["ttl"]) <= 0.0:
			_popups.erase(pop)


func _apply_hit(b: Dictionary, from_p: bool, target: GMInstance, p: Dictionary) -> void:
	if bool(b.get("finished", false)):
		return
	var dmg: int = int(p["dmg"])
	var mult: float = float(p["mult"])

	if from_p:
		# 적군 피격 (적군도 운빨 가드/블록 확률 존재)
		var e_parry: bool = _rng.randi_range(1, 100) <= clampi(int(float(b["e_luk"]) * 0.35), 8, 28) and mult < 7.0
		if e_parry:
			dmg = maxi(1, int(round(float(dmg) * 0.35)))
			_spawn_popup(target.x, target.y - 54.0, "🛡️ BOSS GUARD (-65%%) -%d" % dmg, Color("#9BB0C7"), 1.0)
		else:
			var tag := "-%d (%.2fx)" % [dmg, mult]
			if mult >= 7.0:
				tag = "★ 777 JACKPOT! -%d ★" % dmg
			elif mult >= 3.5:
				tag = "SSR 4.0x! -%d" % dmg
			elif mult >= 2.0:
				tag = "CRIT 2.2x! -%d" % dmg
			_spawn_popup(target.x, target.y - 52.0, tag, p["col"], 1.25)

		b["e_hp"] = maxi(0, int(b["e_hp"]) - dmg)
		b["e_sp"] = minf(100.0, float(b["e_sp"]) + 14.0)
		if target.has_method("on_hit_knockback"):
			target.call("on_hit_knockback", 1.0 if target.x >= x else -1.0)

		if int(b["e_hp"]) <= 0:
			_finish_single_match(b, true)
	else:
		# 아군 피격 — 미라클 패링 실드 또는 LUK 기반 저스트 패링 반격!
		var luk: int = int(b["p_luk"])
		var parry_roll: bool = bool(b.get("shield_active", false)) or (_rng.randi_range(1, 100) <= clampi(12 + int(float(luk) * 0.28), 12, 48))
		if parry_roll:
			b["shield_active"] = false
			b["p_parry_count"] = int(b["p_parry_count"]) + 1
			var counter_dmg: int = int(round(float(b["p_atk"]) * 2.4))
			_spawn_popup(x, y - 56.0, "🛡️ PERFECT PARRY & COUNTER!", Color("#00E5B0"), 1.3)
			b["last_log"] = "🛡️ PERFECT PARRY! Blocked attack & launched 2.4x Counter Wave!"
			var dir: float = -1.0 if image_xscale > 0.0 else 1.0
			spawn_projectile(true, x + dir * 24.0, y - 26.0, dir * 7.5, counter_dmg, "COUNTER 2.4x", 2.4, Color("#00E5B0"), false)
			return

		b["p_hp"] = maxi(0, int(b["p_hp"]) - dmg)
		vx = -2.4 if image_xscale < 0.0 else 2.4
		_anim_timer = 14
		_sync_sprite("dmg")
		_spawn_popup(x, y - 48.0, "-%d (%s)" % [dmg, str(p["tier"])], Color("#FF6B4A"), 1.1)

		if int(b["p_hp"]) <= 0:
			_finish_single_match(b, false)


func _finish_single_match(b: Dictionary, is_win: bool) -> void:
	b["finished"] = true
	b["win"] = is_win
	if is_win:
		b["bonus_bits"] = 3200 + int(b["jackpot_count"]) * 1500
		b["result_banner"] = "🏆 VICTORY! (+%d BIT · Jackpots: %d)" % [int(b["bonus_bits"]), int(b["jackpot_count"])]
		b["last_log"] = "🏆 MATCH DECIDED: %s won the 1v1 Auto-Battle!" % str(b["p_name"])
		_spawn_popup(269.0, 104.0, b["result_banner"], Color("#00E5B0"), 1.5)
	else:
		b["result_banner"] = "💀 DEFEAT — Enemy Boss Overwhelmed Your Partner"
		b["last_log"] = "💀 MATCH DECIDED: %s was defeated. Adjust AI Tactic or train stats!" % str(b["p_name"])
		_spawn_popup(269.0, 104.0, b["result_banner"], Color("#FF6B4A"), 1.5)


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
	# 점프 중일 때 바닥(GROUND_Y)에 그림자 표시
	var shadow_y := GROUND_Y - y
	var shadow_w := clampf(26.0 - absf(shadow_y) * 0.15, 10.0, 26.0)
	draw_Rect_shadow(shadow_w, shadow_y)
	super.draw()

	# 아레나 바닥 네온 라인
	draw_line(Vector2(-x + 30.0, GROUND_Y - y + 2.0), Vector2(-x + 508.0, GROUND_Y - y + 2.0), Color(0.0, 0.898, 0.69, 0.32), 2.0)

	# 날아가는 모든 투사체 렌더링
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

	# 월드 플로팅 데미지 & AI 액션 배너
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
