extends GMInstance
## obj_Special_PLAYER (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌하단 'OVERDRIVE' 궁극기 모듈)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -2100


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	for inst in GM.instances:
		if inst.obj_name == "obj_Digi_Battle" and not inst.dead:
			inst._cast_skill(3, 1.0)
			break


func draw() -> void:
	CBStyle.draw_dock_module(self, Rect2(10.0, 254.0, 56.0, 38.0), CBStyle.ACCENT_ROSE, "EX", "BURST", 6, ImClicked)
