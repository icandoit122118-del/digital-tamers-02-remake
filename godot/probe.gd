extends SceneTree

func _init() -> void:
	print("AudioStreamWAV.load_from_file: ", ClassDB.class_has_method("AudioStreamWAV", "load_from_file"))
	print("AudioStreamWAV.load_from_buffer: ", ClassDB.class_has_method("AudioStreamWAV", "load_from_buffer"))
	print("AudioStreamOggVorbis.load_from_file: ", ClassDB.class_has_method("AudioStreamOggVorbis", "load_from_file"))
	var dir := "D:/digimon-re/out/sounds/"
	for n in ["snd_Click06.wav", "snd_ClickBack.wav", "snd_warning02.wav", "snd_Message.wav", "BGM_Lab.ogg", "BGM_MainMenu02.ogg", "bgm_mainmenu02.ogg", "BGM_Lab.wav"]:
		print(n, " exists=", FileAccess.file_exists(dir + n), " ext=", FileAccess.file_exists(dir + "external/" + n))
	if ClassDB.class_has_method("AudioStreamWAV", "load_from_file"):
		var s = AudioStreamWAV.load_from_file(dir + "snd_Click06.wav")
		print("wav loaded: ", s, " len=", s.get_length() if s else -1)
	var o = AudioStreamOggVorbis.load_from_file(dir + "BGM_Battle03.ogg")
	print("ogg loaded: ", o, " len=", o.get_length() if o else -1)
	quit()
