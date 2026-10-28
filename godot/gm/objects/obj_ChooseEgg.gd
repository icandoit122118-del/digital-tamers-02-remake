extends GMInstance
## obj_ChooseEgg (원작 10종 스타터 디지타마 개별 오브젝트)

var ID := 0
var ImClicked := false


func create() -> void:
	image_speed = 0.12
	ID = int(vars.get("ID", 0))


func step() -> void:
	ID = int(vars.get("ID", ID))


func mouse_left_pressed() -> void:
	ImClicked = true
	image_xscale = 1.15
	image_yscale = 1.15


func mouse_leave() -> void:
	ImClicked = false
	image_xscale = 1.0
	image_yscale = 1.0


func mouse_left_released() -> void:
	image_xscale = 1.0
	image_yscale = 1.0
	if not ImClicked:
		return
	ImClicked = false
	for inst in GM.instances:
		if inst.obj_name == "obj_ChooseEgg_HUD" and not inst.dead:
			inst.select_egg(ID)
			return
	GM.start_new_game_with_egg(ID)
	GM.room_transition(5, "room_MainRoom")


func draw() -> void:
	draw_self()
	var info: Dictionary = GM.STARTER_EGGS[clampi(ID, 0, GM.STARTER_EGGS.size() - 1)]
	var short_name: String = str(info["name"]).split(" ")[0]
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 1)
	draw_text_shadow(x, y + 24.0, short_name, 0xFFFFFF, 0)
