extends GMInstance
## obj_Room_Label (상단 좌측 룸 타이틀 배너)

const MAP := {
	"room_SelectTraining": 1,
	"room_Equipments": 2,
	"room_Leader_Cartridges": 2,
	"room_DigiVice": 3,
	"room_Loja": 4,
	"room_Inventory": 5,
	"room_Achievements": 6,
	"room_Database": 7,
	"room_Loja_Core": 8,
	"room_Tamer_Info": 9,
	"room_Select_Battle_Mode": 10,
	"room_Select_Map": 11,
	"room_SelectDigi": 12,
	"room_PowerUpItems": 13,
	"room_Evo_Select": 15,
	"room_Leader_Select": 17,
	"room_Select_Challenge": 18,
	"room_Infinity_Mode": 19,
	"room_Infinity_PitStop": 19,
	"room_Special_Food": 20,
	"room_Tamer_Skills": 21,
	"room_Battle_Items": 22,
	"room_Skin_Selection": 23,
	"room_options": 24,
	"room_options_MainMenu": 24,
	"room_Quest_Log": 25,
	"room_Adventure_Mode_Start": 26,
}


func create() -> void:
	image_speed = 0.0
	_sync()


func step() -> void:
	_sync()


func _sync() -> void:
	sprite_index = "spr_RoomNames" if GM.g["Language"] == 0 else "spr_RoomNames_PTBR"
	var r := GM.room_name
	if r.begins_with("room_Bios_"):
		image_index = 0
	elif r.begins_with("room_Deco"):
		image_index = 16
	elif r.begins_with("room_Adventure_"):
		image_index = 26
	else:
		image_index = MAP.get(r, 24)
