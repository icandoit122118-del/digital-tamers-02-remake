extends GMInstance
## obj_BLOCK_button (원작 좌하단 가드 버튼 -> 클릭 시 acao=5 가드 발동)

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
			inst._cast_skill(2, 1.0)
			break
