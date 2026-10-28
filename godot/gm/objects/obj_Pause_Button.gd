extends GMInstance
## obj_Pause_Button (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌하단 'RETREAT' 귀환 모듈)

var ImClicked := false


func create() -> void:
	image_speed = 0.0
	depth = -2100


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click05")
	GM.room_transition(0, "room_MainRoom")


func draw() -> void:
	CBStyle.draw_dock_module(self, Rect2(296.0, 254.0, 56.0, 38.0), CBStyle.BORDER_SUBTLE, "EX", "RETURN", 4, ImClicked)
