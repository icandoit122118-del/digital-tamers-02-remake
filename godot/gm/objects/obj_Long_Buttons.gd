extends GMInstance
## obj_Long_Buttons (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 플로팅 헥사-코어 서브메뉴 모듈 바)

var ImClicked := false

const LABELS := [
	"CRYO-STORAGE // DIGIMON BOX",
	"ARMORY // EQUIPMENT & GEAR",
	"V-BAG // ITEM INVENTORY",
	"ENCYCLOPEDIA // DIGIMON BIOS",
	"TACTICAL RECORD // ACHIEVEMENTS",
	"TAMER LICENSE // ID CARD",
	"EVO-LAB // DIGIVOLUTION",
	"DNA CORE // JOGRESS LAB",
	"TERRAFORM // SANCTUARY BIOME",
	"COMMAND // LEADER SELECTION",
	"BISTRO // SPECIAL CUISINE",
	"ARMORY // EQUIPMENTS",
	"ENHANCE // POWER-UP CHIPS",
	"SYSTEM // CONFIGURATION",
	"MISSIONS // ACTIVE QUESTS",
	"V-CORE // CARTRIDGES",
]


func create() -> void:
	image_speed = 0.0
	sprite_index = "spr_Long_Button_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_Long_Button_PTBR"


func step() -> void:
	if vars.has("image_index"):
		image_index = float(vars["image_index"])
		vars.erase("image_index")
	sprite_index = "spr_Long_Button_ENG" if int(GM.g.get("Language", 0)) == 0 else "spr_Long_Button_PTBR"


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked or GM.instance_exists("obj_Transition"):
		ImClicked = false
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click02")
	var idx := int(round(image_index))
	match idx:
		0: GM.room_transition(5, "room_SelectDigi")
		1: GM.room_transition(5, str(GM.g.get("LastEquipRoom", "room_PowerUpItems")))
		2: GM.room_transition(5, "room_Inventory")
		3: GM.room_transition(5, str(GM.g.get("BiosLastPage", "room_Bios_Rookie")))
		4: GM.room_transition(5, "room_Achievements")
		5: GM.room_transition(5, "room_Tamer_Info")
		6: GM.room_transition(5, "room_Evolution")
		7: GM.room_transition(5, "room_Jogress")
		8: GM.room_transition(5, "room_Deco_BG")
		9: GM.room_transition(5, "room_Leader_Select")
		10: GM.room_transition(5, "room_Special_Food")
		11: GM.room_transition(5, "room_Equipments")
		12: GM.room_transition(5, "room_PowerUpItems")
		13: GM.room_transition(5, "room_options")
		14: GM.room_transition(5, "room_Quest_Log")
		15: GM.room_transition(5, "room_Leader_Cartridges")


func draw() -> void:
	var idx := clampi(int(round(image_index)), 0, LABELS.size() - 1)
	var br := Rect2(x - 102.0, y - 14.0, 204.0, 28.0)
	CBStyle.draw_vlink_panel(self, br, CBStyle.BG_SLOT if ImClicked else CBStyle.BG_PANEL, CBStyle.BORDER_GOLD if ImClicked else CBStyle.BORDER_CYAN, 6.0, true)
	CBStyle.draw_hex_avatar(self, Vector2(br.position.x + 16.0, br.position.y + 14.0), 8.5, CBStyle.BORDER_GOLD, CBStyle.BG_DEEP)
	draw_colored_polygon(PackedVector2Array([Vector2(br.position.x + 14.0, br.position.y + 11.0), Vector2(br.position.x + 19.0, br.position.y + 14.0), Vector2(br.position.x + 14.0, br.position.y + 17.0)]), CBStyle.TEXT_BRIGHT)
	draw_set_format("fnt_Text", 0xFFFFFF, 1, 0)
	draw_text_shadow(br.position.x + 32.0, br.position.y + 14.0, LABELS[idx], 0xF8FAFC, 0x0B111E)
