extends RefCounted
## Digital Tamers 02 Original UI Engine ("DIGIVICE V-LINK OS")
## - 원작이나 타 게임을 모방하지 않은 독창적인 플로팅 캡슐·헥사코어·듀얼 윙·오비탈 택티컬 UI 시스템
## - Godot 4 Native CanvasItem 벡터 드로잉 + 2x HD 픽셀 아트 하이브리드 아키텍처

const BG_DEEP := Color8(11, 17, 30, 232)
const BG_PANEL := Color8(17, 26, 46, 238)
const BG_CARD := Color8(24, 36, 62, 242)
const BG_SLOT := Color8(32, 48, 80, 235)
const BORDER_SUBTLE := Color8(56, 82, 130, 220)
const BORDER_CYAN := Color8(56, 189, 248, 255)
const BORDER_GOLD := Color8(245, 158, 11, 255)
const ACCENT_CYAN := Color8(14, 165, 233, 255)
const ACCENT_EMERALD := Color8(16, 185, 129, 255)
const ACCENT_AMBER := Color8(245, 158, 11, 255)
const ACCENT_ROSE := Color8(244, 63, 94, 255)
const ACCENT_INDIGO := Color8(99, 102, 241, 255)
const TEXT_BRIGHT := Color8(248, 250, 252, 255)
const TEXT_MUTED := Color8(148, 163, 184, 255)


## 모서리가 깎인 챔퍼 캡슐(Chamfered Tactical Capsule) 폴리곤 생성
static func make_chamfer_rect(r: Rect2, cut_tl: float = 6.0, cut_tr: float = 6.0, cut_br: float = 6.0, cut_bl: float = 6.0) -> PackedVector2Array:
	var x0 := r.position.x
	var y0 := r.position.y
	var x1 := r.position.x + r.size.x
	var y1 := r.position.y + r.size.y
	return PackedVector2Array([
		Vector2(x0 + cut_tl, y0),
		Vector2(x1 - cut_tr, y0),
		Vector2(x1, y0 + cut_tr),
		Vector2(x1, y1 - cut_br),
		Vector2(x1 - cut_br, y1),
		Vector2(x0 + cut_bl, y1),
		Vector2(x0, y1 - cut_bl),
		Vector2(x0, y0 + cut_tl),
	])


## 정육각형(Hexagon Core) 폴리곤 생성
static func make_hexagon(center: Vector2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var ang := deg_to_rad(60.0 * float(i) - 30.0)
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	return pts


## 독창적인 플로팅 챔퍼 캡슐 패널 (소프트 드롭 섀도우 + 이중 코어 라인 + 상단 액센트 글로우)
static func draw_vlink_panel(ci: CanvasItem, r: Rect2, fill: Color = BG_PANEL, border: Color = BORDER_CYAN, cut: float = 6.0, top_glow: bool = true) -> void:
	var sh_poly := make_chamfer_rect(Rect2(r.position + Vector2(0.0, 3.0), r.size), cut, cut, cut, cut)
	ci.draw_colored_polygon(sh_poly, Color(0.0, 0.0, 0.0, 0.48))

	var outer := make_chamfer_rect(r, cut, cut, cut, cut)
	ci.draw_colored_polygon(outer, border)

	var inner_r := r.grow(-1.0)
	var inner := make_chamfer_rect(inner_r, maxf(1.0, cut - 1.0), maxf(1.0, cut - 1.0), maxf(1.0, cut - 1.0), maxf(1.0, cut - 1.0))
	ci.draw_colored_polygon(inner, fill)

	if top_glow and r.size.x > cut * 2.5:
		ci.draw_line(
			Vector2(r.position.x + cut + 2.0, r.position.y + 2.0),
			Vector2(r.position.x + r.size.x - cut - 2.0, r.position.y + 2.0),
			Color(1.0, 1.0, 1.0, 0.18),
			1.0
		)


## 육각 디지코어 아바타 프레임 (파트너 초상화 및 보스 초상화용)
static func draw_hex_avatar(ci: CanvasItem, center: Vector2, radius: float, ring_col: Color = BORDER_CYAN, bg_col: Color = BG_DEEP) -> void:
	ci.draw_colored_polygon(make_hexagon(center + Vector2(0.0, 2.0), radius + 1.0), Color(0.0, 0.0, 0.0, 0.5))
	ci.draw_colored_polygon(make_hexagon(center, radius), ring_col)
	ci.draw_colored_polygon(make_hexagon(center, radius - 2.0), bg_col)
	ci.draw_colored_polygon(make_hexagon(center, radius - 4.0), Color(ring_col.r, ring_col.g, ring_col.b, 0.16))


## 마이크로 캡슐 게이지 바 (내부 눈금 그리드 + 하이라이트 리본 포함)
static func draw_capsule_bar(ci: CanvasItem, r: Rect2, ratio: float, fill_col: Color = ACCENT_EMERALD, bg_col: Color = BG_DEEP) -> void:
	var bg_poly := make_chamfer_rect(r, 2.5, 2.5, 2.5, 2.5)
	ci.draw_colored_polygon(bg_poly, BORDER_SUBTLE)
	ci.draw_colored_polygon(make_chamfer_rect(r.grow(-1.0), 2.0, 2.0, 2.0, 2.0), bg_col)

	var cl := clampf(ratio, 0.0, 1.0)
	if cl > 0.01:
		var fw := maxf(4.0, (r.size.x - 2.0) * cl)
		var fg_r := Rect2(r.position.x + 1.0, r.position.y + 1.0, fw, r.size.y - 2.0)
		ci.draw_colored_polygon(make_chamfer_rect(fg_r, 1.5, 1.5, 1.5, 1.5), fill_col)
		# 상단 광택 라인
		ci.draw_rect(Rect2(fg_r.position.x + 1.0, fg_r.position.y, maxf(1.0, fw - 2.0), maxf(1.0, fg_r.size.y * 0.35)), Color(1.0, 1.0, 1.0, 0.28), true)


## 세그먼트 노드 에너지 바 (다이아몬드/캡슐 노드 배열)
static func draw_energy_nodes(ci: CanvasItem, pos: Vector2, node_w: float, node_h: float, gap: float, total: int, active: int, active_col: Color = ACCENT_AMBER) -> void:
	for i in total:
		var nx := pos.x + float(i) * (node_w + gap)
		var nr := Rect2(nx, pos.y, node_w, node_h)
		var col := active_col if i < active else Color8(30, 41, 59, 220)
		ci.draw_colored_polygon(make_chamfer_rect(nr, 1.5, 1.5, 1.5, 1.5), col)


## 플로팅 모듈 독 버튼 (하단 아크 독 및 전술 버튼용)
static func draw_dock_module(ci: Node2D, r: Rect2, accent: Color, code_tag: String, label: String, icon_id: int, pressed: bool = false) -> void:
	var dy := 1.5 if pressed else 0.0
	var mr := Rect2(r.position.x, r.position.y + dy, r.size.x, r.size.y)
	draw_vlink_panel(ci, mr, BG_CARD if not pressed else BG_SLOT, accent, 5.0, true)

	# 상단 컬러 코드 스트립
	ci.draw_rect(Rect2(mr.position.x + 6.0, mr.position.y + 3.0, mr.size.x - 12.0, 2.0), accent, true)

	# 중앙 벡터 심볼 아이콘 (고유 디지바이스 OS 기하학 아이콘)
	var cx := mr.position.x + mr.size.x * 0.5
	var cy := mr.position.y + 15.0
	match icon_id:
		0: # 디지바이스 코어 (육각 링 + 센터 도트)
			ci.draw_colored_polygon(make_hexagon(Vector2(cx, cy), 6.5), accent)
			ci.draw_colored_polygon(make_hexagon(Vector2(cx, cy), 4.0), BG_CARD)
			ci.draw_circle(Vector2(cx, cy), 2.0, TEXT_BRIGHT)
		1: # 트레이닝 펄스 (듀얼 덤벨/파형 바)
			ci.draw_rect(Rect2(cx - 7.0, cy - 4.0, 3.0, 8.0), accent, true)
			ci.draw_rect(Rect2(cx - 3.0, cy - 1.5, 6.0, 3.0), TEXT_BRIGHT, true)
			ci.draw_rect(Rect2(cx + 4.0, cy - 4.0, 3.0, 8.0), accent, true)
		2: # 배틀 기어/칩 (다이아몬드 코어 칩)
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx, cy - 6.0), Vector2(cx + 6.0, cy), Vector2(cx, cy + 6.0), Vector2(cx - 6.0, cy)]), accent)
			ci.draw_rect(Rect2(cx - 2.0, cy - 2.0, 4.0, 4.0), BG_CARD, true)
		3: # 진화 나선/애로우 (이중 쉐브론 업)
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx, cy - 6.0), Vector2(cx + 6.0, cy), Vector2(cx + 3.0, cy), Vector2(cx, cy - 3.0), Vector2(cx - 3.0, cy), Vector2(cx - 6.0, cy)]), accent)
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx, cy - 1.0), Vector2(cx + 5.0, cy + 4.0), Vector2(cx - 5.0, cy + 4.0)]), TEXT_BRIGHT)
		4: # 아카이브/도감 (그리드 매트릭스)
			for gx in 2:
				for gy in 2:
					ci.draw_rect(Rect2(cx - 5.0 + float(gx) * 6.0, cy - 5.0 + float(gy) * 6.0, 4.0, 4.0), accent if (gx + gy) % 2 == 0 else TEXT_BRIGHT, true)
		5: # 마켓/상점 (크리스탈 프리즘)
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx - 5.0, cy - 4.0), Vector2(cx + 5.0, cy - 4.0), Vector2(cx + 7.0, cy + 4.0), Vector2(cx - 7.0, cy + 4.0)]), accent)
			ci.draw_rect(Rect2(cx - 2.0, cy - 2.0, 4.0, 4.0), TEXT_BRIGHT, true)
		6: # 출격/배틀 런처 (크로스 블레이드/타겟 코어)
			ci.draw_colored_polygon(make_hexagon(Vector2(cx, cy), 7.5), accent)
			ci.draw_colored_polygon(PackedVector2Array([Vector2(cx - 3.0, cy - 4.0), Vector2(cx + 5.0, cy), Vector2(cx - 3.0, cy + 4.0)]), TEXT_BRIGHT)

	# 하단 모듈 라벨
	ci.draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	ci.draw_text_shadow(cx, mr.position.y + mr.size.y - 7.5, label, 0xFFFFFF, 0x0B111E)
