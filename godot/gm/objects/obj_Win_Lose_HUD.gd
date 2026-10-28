extends GMInstance
## obj_Win_Lose_HUD (원작 gml_Object_obj_Win_Lose_HUD_Draw_0.gml: 전투 종료 후 BIT/XP/드랍 정산 창)

var Etapa := 4
var CanLeave := true
var imgIndex := 0


func create() -> void:
	sprite_index = "spr_Win_HUD" if bool(GM.battle.get("win", true)) else "spr_Lose_HUD"
	if not GM.sprites.has(sprite_index):
		sprite_index = "spr_Win_Lose_HUD"
	image_speed = 0.0
	depth = -3500
	Etapa = 4
	CanLeave = true


func step() -> void:
	imgIndex = (GM.frame / 10) % 2


func global_left_released() -> void:
	if CanLeave and not GM.instance_exists("obj_Transition"):
		GM.play_sound_fx("snd_Click01")
		GM.room_transition(0, "room_MainRoom")


func draw() -> void:
	if GM.sprites.has(sprite_index):
		draw_self()
	else:
		draw_set_color(0x16202A)
		draw_rectangle(x, y, x + 380.0, y + 135.0, false)
	var win := bool(GM.battle.get("win", true))
	var won_bits: int = int(GM.battle.get("bonus_bits", 1600))
	var given_xp: int = int(GM.battle.get("given_xp", 720))
	var tamer_xp: int = int(GM.battle.get("tamer_xp_gain", 180))

	draw_sprite_ext("spr_Win_Xp_Bar", 0, x + 20.0, y + 56.0, 0.75, 1.0, 0.0, Color.WHITE, 1.0)
	draw_sprite_ext("spr_Win_Xp_Bar", 0, x + 20.0, y + 73.0, 0.82, 1.0, 0.0, Color.WHITE, 1.0)

	draw_set_format("fnt_Text", 0xFFFFFF, 0, 2)
	var sign_str := "+" if win else "-"
	draw_text_shadow(x + 108.0, y + 19.0, "%s%d" % [sign_str, won_bits], 0xDDE105, 0)
	draw_text_shadow(x + 128.0, y + 62.0, "+%d" % tamer_xp, 0xFFFFFF, 0)
	draw_text_shadow(x + 128.0, y + 79.0, "+%d" % given_xp, 0xFFFFFF, 0)

	if win:
		draw_sprite("spr_Items", 1, x + 156.0, y + 57.0)
		draw_sprite("spr_Items", 10, x + 183.0, y + 57.0)
		draw_sprite_ext("spr_Icons", int(GM.battle.get("e_id", 87)), x + 350.0, y + 30.0, -1.0, 1.0, 0.0, Color.WHITE, 1.0)
		draw_set_format("fnt_Text", 0x6BFF5A, 0, 2)
		draw_text_shadow(x + 339.0, y + 20.0, "Data Acquired!", 0x6BFF5A, 0)

	if CanLeave and GM.sprites.has("spr_Tap_Continue_ING"):
		draw_sprite("spr_Tap_Continue_ING", imgIndex, x + 276.0, y + 123.0)
