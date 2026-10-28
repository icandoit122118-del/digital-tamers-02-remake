extends GMInstance
## obj_Room_Label (Digital Tamers 02 Original "DIGIVICE V-LINK OS" — 좌상단 플로팅 OS 브레드크럼 헤더)

const TITLES := {
	"room_SelectTraining": "V-GYM // TRAINING MATRIX",
	"room_Equipments": "V-GEAR // EQUIPMENTS",
	"room_Leader_Cartridges": "V-CORE // CARTRIDGES",
	"room_DigiVice": "DIGIVICE V-LINK OS",
	"room_Loja": "V-MARKET // SUPPLY SHOP",
	"room_Inventory": "V-BAG // INVENTORY",
	"room_Achievements": "V-LOG // ACHIEVEMENTS",
	"room_Database": "V-ARCHIVE // DATABASE",
	"room_Loja_Core": "V-CORE // EXCHANGE",
	"room_Tamer_Info": "TAMER LICENSE CARD",
	"room_Select_Battle_Mode": "SORTIE // BATTLE MODES",
	"room_Select_Map": "DIGITAL WORLD // EXPEDITION",
	"room_SelectDigi": "CRYO-STORAGE // DIGIMON BOX",
	"room_PowerUpItems": "ENHANCE // POWER-UP CHIPS",
	"room_Evo_Select": "EVO-LAB // DIGIVOLUTION",
	"room_Evolution": "EVO-LAB // DIGIVOLUTION",
	"room_Leader_Select": "COMMAND // LEADER SKILL",
	"room_Select_Challenge": "COLOSSEUM // CHALLENGE",
	"room_Infinity_Mode": "ABYSS // INFINITY TOWER",
	"room_Special_Food": "BISTRO // SPECIAL CUISINE",
	"room_Tamer_Skills": "MASTERY // TAMER SKILLS",
	"room_Battle_Items": "ARMORY // BATTLE GEAR",
	"room_Quest_Log": "MISSIONS // QUEST LOG",
	"room_Adventure_Mode_Start": "CAMPAIGN // ADVENTURE",
}


func create() -> void:
	image_speed = 0.0
	depth = -2000


func draw() -> void:
	var r := GM.room_name
	var title: String = str(TITLES.get(r, "DIGIVICE V-LINK OS"))
	if r.begins_with("room_Bios_"):
		title = "ENCYCLOPEDIA // DIGIMON BIOS"
	CBStyle.draw_vlink_panel(self, Rect2(6.0, 3.0, 224.0, 22.0), CBStyle.BG_PANEL, CBStyle.BORDER_CYAN, 5.0, true)
	CBStyle.draw_hex_avatar(self, Vector2(18.0, 14.0), 6.0, CBStyle.BORDER_GOLD, CBStyle.BG_DEEP)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(28.0, 6.5, title, 0xF8FAFC, 0x0B111E)
