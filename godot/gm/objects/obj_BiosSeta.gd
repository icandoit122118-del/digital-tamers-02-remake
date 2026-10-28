extends GMInstance
## obj_BiosSeta (원작 room_Bios_* 등급 전환 화살표 버튼)

const BIOS_ROOMS := [
	"room_Bios_BabyI",
	"room_Bios_BabyII",
	"room_Bios_Rookie",
	"room_Bios_Champion",
	"room_Bios_Ultimate",
	"room_Bios_Mega",
	"room_Bios_Ultra",
	"room_Bios_Armor",
]

var ImClicked := false


func create() -> void:
	image_speed = 0.0


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	var cur_idx := BIOS_ROOMS.find(GM.room_name)
	if cur_idx < 0:
		cur_idx = 2
	var dir := 1 if x > 269.0 else -1
	var next_idx := posmod(cur_idx + dir, BIOS_ROOMS.size())
	var next_room: String = BIOS_ROOMS[next_idx]
	GM.g["BiosLastPage"] = next_room
	GM.room_transition(0, next_room)
