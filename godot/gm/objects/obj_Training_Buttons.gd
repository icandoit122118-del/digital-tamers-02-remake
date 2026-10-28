extends GMInstance
## obj_Training_Buttons (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 헥사곤 훈련 코어 노드)

var MyTraining := 0
var ImClicked := false

const TRAIN_LABELS := ["HP", "ATK", "DEF", "SP.ATK", "SP.DEF", "SPIRIT", "RANDOM"]
const TRAIN_SUBS := ["VITALITY", "STRIKE", "ARMOR", "BLASTER", "BARRIER", "SPEED", "ALL-SYNC"]


func create() -> void:
	image_speed = 0.0
	if vars.has("MyTraining"):
		MyTraining = int(vars["MyTraining"])


func step() -> void:
	if vars.has("MyTraining"):
		MyTraining = int(vars["MyTraining"])
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")


func mouse_left_pressed() -> void:
	ImClicked = true
	y = ystart + 2.0


func mouse_leave() -> void:
	ImClicked = false
	y = ystart


func mouse_left_released() -> void:
	y = ystart
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click06")
	GM.g["TraningWhat"] = int(vars.get("MyTraining", MyTraining))
	GM.room_transition(6, "room_Training")


func draw() -> void:
	var tid := clampi(int(vars.get("MyTraining", MyTraining)), 0, 6)
	var cols := [
		CBStyle.ACCENT_EMERALD,
		CBStyle.ACCENT_ROSE,
		CBStyle.ACCENT_CYAN,
		CBStyle.ACCENT_INDIGO,
		CBStyle.ACCENT_AMBER,
		CBStyle.BORDER_GOLD,
		CBStyle.BORDER_CYAN,
	]
	var col: Color = cols[tid]
	CBStyle.draw_hex_avatar(self, Vector2(x, y), 27.0, col, CBStyle.BG_PANEL if not ImClicked else CBStyle.BG_SLOT)
	draw_set_format("fnt_Text", 0xFFFFFF, 1, 1)
	draw_text_shadow(x, y - 4.0, TRAIN_LABELS[tid], 0xFFFFFF, 0x0B111E)
	draw_set_format("fnt_SmlText", 0xFFFFFF, 1, 1)
	draw_text_shadow(x, y + 8.0, TRAIN_SUBS[tid], 0x0B9EF5, 0x0B111E)
