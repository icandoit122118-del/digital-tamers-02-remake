extends GMInstance
## obj_World_Target (원작 room_Select_Map 디지털 월드 18개 지역 타겟 마커 -> 클릭 시 해당 지역 출격)

const ZONES := [
	{"name": "Village of Beginnings", "boss": 3, "lv": 12, "bg": "bg_Btl_Village_Beginnings", "dx": -28.0, "dy": -34.0},
	{"name": "Dina Plains", "boss": 5, "lv": 20, "bg": "bg_Btl_Dina_Plains", "dx": 22.0, "dy": -18.0},
	{"name": "Boot Jungle", "boss": 85, "lv": 28, "bg": "bg_Btl_Boot_Jungle", "dx": -48.0, "dy": 12.0},
	{"name": "Chrome Mines", "boss": 87, "lv": 34, "bg": "bg_Btl_Chrome_Mines", "dx": 44.0, "dy": -46.0},
	{"name": "Server City Arena", "boss": 151, "lv": 42, "bg": "bg_Btl_ServerCity_Ruins", "dx": 0.0, "dy": 6.0},
	{"name": "Magma Mountain", "boss": 151, "lv": 48, "bg": "bg_Btl_Magma_Mountain", "dx": 54.0, "dy": 22.0},
	{"name": "Net Ocean", "boss": 30, "lv": 30, "bg": "bg_Btl_Net_Ocean", "dx": -62.0, "dy": -6.0},
	{"name": "Snow Land", "boss": 10, "lv": 36, "bg": "bg_Btl_Snow_Land", "dx": -12.0, "dy": -58.0},
	{"name": "Mecha Plant", "boss": 85, "lv": 44, "bg": "bg_Btl_Mecha_Plant", "dx": 32.0, "dy": 44.0},
	{"name": "Dark Area Abyss", "boss": 152, "lv": 55, "bg": "bg_Btl_Dark_Area", "dx": -36.0, "dy": 48.0},
	{"name": "Chaos Tower Top", "boss": 210, "lv": 64, "bg": "bg_Btl_D_Dungeon01", "dx": 62.0, "dy": -12.0},
	{"name": "Kernel Zone Final", "boss": 310, "lv": 75, "bg": "BG_InfinityTower", "dx": 4.0, "dy": -36.0},
]

var iAm := 0
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	_sync_pos()


func step() -> void:
	_sync_pos()


func _sync_pos() -> void:
	if vars.has("iAm"):
		iAm = int(vars["iAm"])
	if iAm < 0 or iAm >= ZONES.size():
		x = -200.0
		y = -200.0
		visible = false
		return
	visible = true
	var z: Dictionary = ZONES[iAm]
	x = 143.0 + float(z["dx"])
	y = 156.0 + float(z["dy"])
	image_index = float(iAm % 8)


func mouse_left_pressed() -> void:
	ImClicked = true
	image_xscale = 1.25
	image_yscale = 1.25


func mouse_leave() -> void:
	ImClicked = false
	image_xscale = 1.0
	image_yscale = 1.0


func mouse_left_released() -> void:
	image_xscale = 1.0
	image_yscale = 1.0
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	if iAm >= 0 and iAm < ZONES.size():
		var z: Dictionary = ZONES[iAm]
		GM.play_sound_fx("snd_Click05")
		GM.start_stage_battle(int(z["boss"]), int(z["lv"]), str(z["name"]), str(z["bg"]))


func draw() -> void:
	draw_self()
	if _hover and iAm >= 0 and iAm < ZONES.size():
		var z: Dictionary = ZONES[iAm]
		draw_set_format("fnt_Text", 0xDDE105, 1, 1)
		draw_text_shadow(143.0, 268.0, "%s (Lv.%d) - Tap to Battle!" % [str(z["name"]), int(z["lv"])], 0xDDE105, 0)
