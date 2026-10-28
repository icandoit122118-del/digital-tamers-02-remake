extends GMInstance
## obj_ChooseEgg_HUD (원작 gml_Object_obj_ChooseEgg_HUD_Create_0.gml: 10종 스타터 디지타마 선택)

var chosenEGG := -1
var EggName := ""


func create() -> void:
	image_speed = 0.0
	chosenEGG = -1
	var cols := [40.0, 114.0, 188.0, 262.0, 336.0]
	var rows := [71.0, 151.0]
	var idx := 0
	for r in rows.size():
		for c in cols.size():
			var egg := GM.instance_create(x + cols[c], y + rows[r], "obj_ChooseEgg")
			egg.vars["ID"] = idx
			egg.sprite_index = "spr_egg%02d" % (idx + 1)
			egg.depth = depth - 10
			idx += 1


func select_egg(id_val: int) -> void:
	chosenEGG = id_val
	var info: Dictionary = GM.STARTER_EGGS[clampi(id_val, 0, GM.STARTER_EGGS.size() - 1)]
	EggName = str(info["name"])
	GM.play_sound_fx("snd_Click01")
	GM.start_new_game_with_egg(id_val)
	GM.room_transition(5, "room_MainRoom")


func draw() -> void:
	draw_self()
	draw_set_format("fnt_MidText", 0xDDE105, 0, 1)
	draw_text_shadow(269.0, 14.0, "Kurihara Hina: Choose your Starter DigiTama!", 0xDDE105, 0)
	draw_set_format("fnt_Text", 0xFFFFFF, 0, 1)
	draw_text_shadow(269.0, 272.0, "Tap any DigiTama to begin your Digital Tamers 02 journey in Network Lodging!", 0xFFFFFF, 0)
