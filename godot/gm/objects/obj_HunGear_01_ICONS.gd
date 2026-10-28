extends GMInstance
## obj_HunGear_01_ICONS .. 04_ICONS (원작 gml_Object_obj_HunGear_01_ICONS_Draw_0.gml: 슬롯 내 미니 아이템 아이콘)

var ID := 0
var image := 0


func create() -> void:
	image_speed = 0.0
	image_index = 0.0


func step() -> void:
	if vars.has("ID"):
		ID = int(vars["ID"])
	if vars.has("image"):
		image = int(vars["image"])


func draw() -> void:
	if x > 315.0 and x < 535.0:
		draw_self()
		if image >= 0:
			draw_sprite("spr_Items_MINI", image, x, y)
