extends GMInstance
## obj_FoodBar (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌측 플로팅 나노-케어 매트릭스 드로어)

var XX := 0.0
var YY := 0.0
var Aberto := false
var Spd := 30.0
var ImClicked := false


func create() -> void:
	image_index = 0.0
	image_speed = 0.0
	XX = 0.0
	Aberto = false


func step() -> void:
	if not Aberto and XX > 0.0:
		XX = maxf(0.0, XX - Spd)
	elif Aberto and XX < 335.0:
		XX = minf(335.0, XX + Spd)
	image_index = 1.0 if XX >= 335.0 else 0.0
	x = xstart + XX


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if ImClicked and not GM.instance_exists("obj_Transition"):
		ImClicked = false
		Aberto = not Aberto
		GM.play_sound_fx("snd_DigiPad_ON" if Aberto else "snd_DigiPad_OFF")


func draw() -> void:
	var tray_r := Rect2(x - 338.0, y - 34.0, 338.0, 68.0)
	CBStyle.draw_vlink_panel(self, tray_r, CBStyle.BG_DEEP, CBStyle.BORDER_CYAN, 7.0, true)
	# 우측 육각 코어 탭 핸들
	var handle_r := Rect2(x - 2.0, y - 18.0, 18.0, 36.0)
	CBStyle.draw_vlink_panel(self, handle_r, CBStyle.BG_SLOT, CBStyle.BORDER_GOLD, 4.0, true)
	var cx := x + 7.0
	var cy := y
	if Aberto:
		draw_colored_polygon(PackedVector2Array([Vector2(cx + 3.0, cy - 4.0), Vector2(cx - 3.0, cy), Vector2(cx + 3.0, cy + 4.0)]), CBStyle.TEXT_BRIGHT)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(cx - 3.0, cy - 4.0), Vector2(cx + 3.0, cy), Vector2(cx - 3.0, cy + 4.0)]), CBStyle.TEXT_BRIGHT)
