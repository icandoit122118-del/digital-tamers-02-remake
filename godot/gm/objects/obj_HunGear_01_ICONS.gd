extends GMInstance
## obj_HunGear_01_ICONS .. 04_ICONS (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 기어 슬롯 캡슐 아이콘)

var ID := 0
var image := 0


func create() -> void:
	image_speed = 0.0
	image_index = 0.0
	depth = -2500
	z_index = GM.z_for_depth(depth)


func step() -> void:
	if vars.has("ID"):
		ID = int(vars["ID"])
	if vars.has("image"):
		image = int(vars["image"])


func draw() -> void:
	if x > 315.0 and x < 535.0:
		var sr := Rect2(x - 12.0, y - 12.0, 24.0, 24.0)
		CBStyle.draw_vlink_panel(self, sr, CBStyle.BG_DEEP, CBStyle.BORDER_SUBTLE, 3.0, false)
		if image >= 0:
			draw_sprite("spr_Items_MINI", image, x, y)
