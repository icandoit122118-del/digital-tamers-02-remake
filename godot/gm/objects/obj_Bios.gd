extends GMInstance
## obj_Bios (원작 room_Bios_* 우측 선택 디지몬 도감 상세 정보 패널)

var selected_id := 5


func create() -> void:
	image_speed = 0.0
	selected_id = int(GM.g.get("partnerId", 5))


func draw() -> void:
	draw_self()
	var d_entry: Dictionary = GM.db["digimons"].get(str(selected_id), {})
	var d_name: String = str(d_entry.get("name", "Digimon #%d" % selected_id))
	var d_stage: String = str(d_entry.get("stage", "Champion"))
	var d_attr: String = str(d_entry.get("attr", "Vaccine"))
	var d_elem: String = str(d_entry.get("elem", "Fire"))
	var d_hp: int = int(d_entry.get("base_hp", 2200))
	var d_atk: int = int(d_entry.get("base_atk", 350))
	var d_def: int = int(d_entry.get("base_def", 300))

	draw_sprite_ext("spr_Icons", selected_id, x + 46.0, y + 48.0, 2.0, 2.0, 0.0, Color.WHITE, 1.0)
	draw_set_format("fnt_Text", 0xDDE105, 0, 0)
	draw_text_shadow(x + 88.0, y + 24.0, "#%d %s" % [selected_id, d_name], 0xDDE105, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 0)
	draw_text_shadow(x + 88.0, y + 42.0, "%s | %s | %s" % [d_stage, d_attr, d_elem], 0xFFFFFF, 0)
	draw_text_shadow(x + 24.0, y + 86.0, "Base HP: %d   ATK: %d   DEF: %d" % [d_hp, d_atk, d_def], 0x6BFF5A, 0)
	draw_text_shadow(x + 24.0, y + 106.0, "Tap any Digimon icon on the left to inspect & set Partner!", 0xFFFFFF, 0)
