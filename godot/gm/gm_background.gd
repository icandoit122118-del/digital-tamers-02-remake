class_name GMBackground
extends Node2D
## 룸 배경 레이어(타일링 + 스크롤) + 전투/거점 동적 바이옴·지형·데코레이션 렌더러
## - room_Battle: 선택한 원정 지역/스테이지에 맞춰 원본 + Aseprite HD 리마스터 전투 배경(bg_Btl_*) 렌더링
## - room_MainRoom: 거점 바이옴 테마(BG16/BG18/BG19/BG21/BG22/BG24/BG26/BG28) + 다중 전경 레이어(spr_DecoLayer02, spr_DecoLayer01) + 바닥(spr_Floor_Deco) + 성소 오브젝트(나무/석상/화석/고기밭) 렌더링

var layers: Array = []     # [{sprite, frame, tiledH, tiledV, xoff, yoff, index, depth}]
var scroll: Dictionary = {}  # index -> Vector2 (누적 오프셋)
var room_size := Vector2(538, 300)
var current_room_name := ""

const SANCTUARY_THEMES := [
	{"name": "File Island Coast", "bg": "BG26", "layer2": 1, "layer1": 5, "floor": 3, "props": [
		{"spr": "spr_DecoTree03", "x": 76.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoStatue03", "x": 438.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoMeatField", "x": 200.0, "y": 222.0, "sx": 1.0},
	]},
	{"name": "Toy Town Sanctuary", "bg": "BG28", "layer2": 2, "layer1": 2, "floor": 0, "props": [
		{"spr": "spr_DecoFossil01", "x": 92.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoStatue02", "x": 442.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoMeatField", "x": 212.0, "y": 222.0, "sx": 1.0},
	]},
	{"name": "Starlight Canyon", "bg": "BG19", "layer2": 1, "layer1": 1, "floor": 5, "props": [
		{"spr": "spr_Deco04", "x": 98.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoPlant20", "x": 444.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoStatue03", "x": 368.0, "y": 220.0, "sx": 1.0},
	]},
	{"name": "Royal Kernel Hall", "bg": "BG21", "layer2": -1, "layer1": 4, "floor": 1, "props": [
		{"spr": "spr_DecoStatue03", "x": 88.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoFossil01", "x": 440.0, "y": 220.0, "sx": 1.0},
	]},
	{"name": "Deep Savers Reef", "bg": "BG24", "layer2": -1, "layer1": 1, "floor": 4, "props": [
		{"spr": "spr_DecoPlant18", "x": 86.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoStatue02", "x": 438.0, "y": 220.0, "sx": 1.0},
	]},
	{"name": "Ancient Jungle", "bg": "BG16", "layer2": 1, "layer1": 5, "floor": 2, "props": [
		{"spr": "spr_DecoTree03", "x": 82.0, "y": 220.0, "sx": 1.0},
		{"spr": "spr_DecoMeatField", "x": 418.0, "y": 222.0, "sx": 1.0},
	]},
]

const BATTLE_ARENAS := [
	{"zone": "Village of Beginnings", "bg": "bg_Btl_Village_Beginnings"},
	{"zone": "Dina Plains", "bg": "bg_Btl_Dina_Plains"},
	{"zone": "Boot Jungle", "bg": "bg_Btl_Boot_Jungle"},
	{"zone": "Chrome Mines", "bg": "bg_Btl_Chrome_Mines"},
	{"zone": "Server City Arena", "bg": "bg_Btl_ServerCity_Ruins"},
	{"zone": "Magma Mountain", "bg": "bg_Btl_Magma_Mountain"},
	{"zone": "Dark Area Abyss", "bg": "bg_Btl_Dark_Area"},
	{"zone": "Chaos Tower Top", "bg": "bg_Btl_D_Dungeon01"},
	{"zone": "Kernel Zone Final", "bg": "BG_InfinityTower"},
	{"zone": "Net Ocean", "bg": "bg_Btl_Net_Ocean"},
	{"zone": "Snow Land", "bg": "bg_Btl_Snow_Land"},
	{"zone": "Mecha Plant", "bg": "bg_Btl_Mecha_Plant"},
]


func setup(room: Dictionary) -> void:
	layers.clear()
	scroll.clear()
	current_room_name = str(room.get("name", ""))
	room_size = Vector2(room["w"], room["h"])
	for l in room["layers"]:
		var bg = l["bg"]
		if bg == null or bg["sprite"] == null or not bg["visible"] or l["name"].ends_with("Colour"):
			continue
		var parts: PackedStringArray = l["name"].split("_")
		var idx := 0
		if parts.size() > 2 and parts[1] == "Background":
			idx = int(parts[2])
		layers.append({
			"sprite": bg["sprite"],
			"frame": 0,
			"tiledH": bg["tiledH"],
			"tiledV": bg["tiledV"],
			"xoff": l["xoff"],
			"yoff": l["yoff"],
			"index": idx,
			"depth": l["depth"],
		})
		scroll[idx] = Vector2.ZERO
	layers.sort_custom(func(a, b): return a["depth"] > b["depth"])
	_apply_dynamic_biome_layers()
	queue_redraw()


func _apply_dynamic_biome_layers() -> void:
	if current_room_name == "room_Battle":
		var b_bg: String = str(GM.g.get("BattleBG", ""))
		if b_bg.is_empty():
			b_bg = resolve_battle_bg_for_zone(str(GM.g.get("battleZone", "Magma Mountain")))
			GM.g["BattleBG"] = b_bg
		layers.clear()
		scroll.clear()
		# 원경 사이버 그리드 스크롤 레이어 + 지역별 실제 538x300 전투 스테이지 배경(지면 포함)
		layers.append({
			"sprite": b_bg,
			"frame": 0,
			"tiledH": false,
			"tiledV": false,
			"xoff": 0.0,
			"yoff": 0.0,
			"index": 0,
			"depth": 100,
		})
		scroll[0] = Vector2.ZERO
	elif current_room_name == "room_MainRoom":
		var theme_idx: int = clampi(int(GM.g.get("sanctuaryThemeIdx", 0)), 0, SANCTUARY_THEMES.size() - 1)
		var th: Dictionary = SANCTUARY_THEMES[theme_idx]
		GM.g["MainRoomBG"] = str(th["bg"])
		layers.clear()
		scroll.clear()
		# 1) 원경 하늘/바이옴 배경 (538x300)
		layers.append({
			"sprite": str(th["bg"]),
			"frame": 0,
			"tiledH": true,
			"tiledV": false,
			"xoff": 0.0,
			"yoff": 0.0,
			"index": 0,
			"depth": 500,
		})
		scroll[0] = Vector2.ZERO
		# 2) 중경 원경 장식 레이어 (spr_DecoLayer02: 바닥을 y=219 지면에 정렬)
		if int(th["layer2"]) >= 0:
			var s2: Dictionary = GM.sprites.get("spr_DecoLayer02", {})
			var h2: float = float(s2.get("h", 218.0))
			layers.append({
				"sprite": "spr_DecoLayer02",
				"frame": int(th["layer2"]),
				"tiledH": false,
				"tiledV": false,
				"xoff": 0.0,
				"yoff": 219.0 - h2,
				"index": 2,
				"depth": 400,
			})
			scroll[2] = Vector2.ZERO
		# 3) 전경 수풀/기둥 레이어 (spr_DecoLayer01: 바닥을 y=219 지면에 정렬)
		if int(th["layer1"]) >= 0:
			var s1: Dictionary = GM.sprites.get("spr_DecoLayer01", {})
			var h1: float = float(s1.get("h", 248.0))
			layers.append({
				"sprite": "spr_DecoLayer01",
				"frame": int(th["layer1"]),
				"tiledH": false,
				"tiledV": false,
				"xoff": 0.0,
				"yoff": 219.0 - h1,
				"index": 3,
				"depth": 300,
			})
			scroll[3] = Vector2.ZERO
		# 4) 지면 바닥 데코 (spr_Floor_Deco: 538x100, y=300 -> top=200)
		layers.append({
			"sprite": "spr_Floor_Deco",
			"frame": int(th["floor"]),
			"tiledH": false,
			"tiledV": false,
			"xoff": 0.0,
			"yoff": 200.0,
			"index": 1,
			"depth": 200,
		})
		scroll[1] = Vector2.ZERO


static func resolve_battle_bg_for_zone(zone: String) -> String:
	var z := zone.to_lower()
	if z.contains("village") or z.contains("begin"):
		return "bg_Btl_Village_Beginnings"
	elif z.contains("dina") or z.contains("plain"):
		return "bg_Btl_Dina_Plains"
	elif z.contains("jungle") or z.contains("boot"):
		return "bg_Btl_Boot_Jungle"
	elif z.contains("chrome") or z.contains("mine"):
		return "bg_Btl_Chrome_Mines"
	elif z.contains("server") or z.contains("city"):
		return "bg_Btl_ServerCity_Ruins"
	elif z.contains("magma") or z.contains("volcano") or z.contains("mountain"):
		return "bg_Btl_Magma_Mountain"
	elif z.contains("dark") or z.contains("abyss"):
		return "bg_Btl_Dark_Area"
	elif z.contains("chaos") or z.contains("tower") or z.contains("dungeon"):
		return "bg_Btl_D_Dungeon01"
	elif z.contains("kernel") or z.contains("infinity"):
		return "BG_InfinityTower"
	elif z.contains("ocean") or z.contains("sea"):
		return "bg_Btl_Net_Ocean"
	elif z.contains("snow") or z.contains("ice"):
		return "bg_Btl_Snow_Land"
	elif z.contains("mecha") or z.contains("plant"):
		return "bg_Btl_Mecha_Plant"
	return "bg_Btl_Magma_Mountain"


func tick() -> void:
	for idx in scroll.keys():
		var sp := Vector2(GM.bg_hspeed.get(idx, 0.0), GM.bg_vspeed.get(idx, 0.0))
		scroll[idx] += sp
	queue_redraw()


func _draw() -> void:
	for l in layers:
		var spr_name: String = str(l["sprite"])
		var f_idx: int = int(l.get("frame", 0))
		var t := GM.tex(spr_name, f_idx)
		if t == null:
			continue
		var s_info: Dictionary = GM.sprites.get(spr_name, {})
		var w: float = float(s_info.get("w", room_size.x))
		var h: float = float(s_info.get("h", room_size.y))
		var off: Vector2 = scroll.get(l["index"], Vector2.ZERO)
		var ox: float = float(l["xoff"]) + off.x
		var oy: float = float(l["yoff"]) + off.y
		if l["tiledH"]:
			ox = fposmod(ox, w) - w
		if l["tiledV"]:
			oy = fposmod(oy, h) - h
		var x: float = ox
		while x < room_size.x:
			var y: float = oy
			while y < room_size.y:
				draw_texture_rect(t, Rect2(floorf(x), floorf(y), w, h), false)
				if not l["tiledV"]:
					break
				y += h
			if not l["tiledH"]:
				break
			x += w

	# 거점(room_MainRoom)일 때 배치형 픽셀 성소 오브젝트(나무, 석상, 화석, 고기밭) 추가 렌더링
	if current_room_name == "room_MainRoom":
		var theme_idx: int = clampi(int(GM.g.get("sanctuaryThemeIdx", 0)), 0, SANCTUARY_THEMES.size() - 1)
		var props: Array = SANCTUARY_THEMES[theme_idx].get("props", [])
		for p in props:
			var spr_name: String = str(p["spr"])
			var ptex := GM.tex(spr_name, 0)
			if ptex != null and GM.sprites.has(spr_name):
				var s_meta: Dictionary = GM.sprites[spr_name]
				var pw: float = float(s_meta.get("w", ptex.get_width()))
				var ph: float = float(s_meta.get("h", ptex.get_height()))
				var orig := Vector2(float(s_meta.get("originX", pw * 0.5)), float(s_meta.get("originY", ph)))
				var draw_pos := Vector2(float(p["x"]) - orig.x, float(p["y"]) - orig.y)
				draw_texture_rect(ptex, Rect2(draw_pos, Vector2(pw, ph)), false)
