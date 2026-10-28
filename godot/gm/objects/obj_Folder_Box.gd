extends GMInstance
## obj_Folder_Box (원작 room_SelectDigi 디지몬 보관함 슬롯 -> 클릭 시 파트너 교체)

var slot_digi := 3
var ImClicked := false


func create() -> void:
	image_speed = 0.0
	var pool := [3, 5, 8, 10, 13, 22, 28, 38, 43, 48, 85, 87, 151, 152, 210, 310]
	var hash_idx := absi(int(x * 7.0 + y * 13.0)) % pool.size()
	slot_digi = int(pool[hash_idx])


func mouse_left_pressed() -> void:
	ImClicked = true


func mouse_leave() -> void:
	ImClicked = false


func mouse_left_released() -> void:
	if not ImClicked:
		return
	ImClicked = false
	GM.play_sound_fx("snd_Click01")
	GM.g["partnerId"] = slot_digi
	GM.init_battle_state()


func draw() -> void:
	draw_self()
	draw_sprite("spr_Icons", slot_digi, x + 16.0, y + 16.0)
