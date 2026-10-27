extends GMInstance
## obj_OptionBut01 (옵션 라벨/클릭 버튼)

var ImClicked := false
var Clickable := false
var iAm := -4
var OptText := ""
var ExtraText := ""

const LABELS_EN := {
	1: "Music", 2: "Sound Effects", 3: "Digimon Voices", 4: "Credits",
	5: "Delete Save", 6: "Auto-Save", 7: "Full Screen", 8: "White Transitions",
	9: "Brighten Night-time", 10: "Save Transfer", 11: "Load Backup File", 12: "Language"
}
const LABELS_PT := {
	1: "Música", 2: "Efeitos Sonoros", 3: "Vozes dos Digimon", 4: "Créditos",
	5: "Deletar Save", 6: "Salvamento Automático", 7: "Tela Cheia", 8: "Transições Brancas",
	9: "Clarear Noite", 10: "Transferir Save", 11: "Carregar Backup", 12: "Idioma"
}


func create() -> void:
	image_speed = 0.0
	image_blend = Color.WHITE


func step() -> void:
	if vars.has("iAm"):
		iAm = int(vars["iAm"])
	if vars.has("Clickable"):
		Clickable = bool(vars["Clickable"])
	if iAm == 7:
		# Android 빌드에서는 Full Screen 항목 제거 (switch(4) case 4: instance_destroy())
		instance_destroy()
		return
	image_index = 1 if Clickable else 0
	var dict := LABELS_EN if GM.g["Language"] == 0 else LABELS_PT
	OptText = dict.get(iAm, "")
	if iAm == 12:
		ExtraText = "ENG" if GM.g["Language"] == 0 else "PT-BR"
	else:
		ExtraText = ""


func mouse_left_pressed() -> void:
	if iAm > 3:
		ImClicked = true
		if Clickable:
			image_blend = Color8(0x6A, 0x6A, 0x6A)


func mouse_leave() -> void:
	y = ystart
	ImClicked = false
	image_blend = Color.WHITE


func mouse_left_released() -> void:
	if ImClicked and not GM.instance_exists("obj_Transition"):
		if iAm == 4:
			GM.room_transition(0, "room_Credits")
			GM.play_sound_fx("snd_Click03")
		elif iAm == 10:
			GM.room_transition(0, "room_Transfer_Save")
			GM.play_sound_fx("snd_Click03")
		elif iAm == 12:
			GM.g["Language"] = 1 if GM.g["Language"] == 0 else 0
			GM.play_sound_fx("snd_Click06")
	ImClicked = false
	image_blend = Color.WHITE


func draw() -> void:
	draw_set_format("fnt_Text", 16777215, 1, 1)
	draw_self()
	draw_text_shadow(x, y, OptText, image_blend, 0)
	if ExtraText != "":
		draw_text_shadow(x + 99, y, ExtraText, image_blend, 0)
