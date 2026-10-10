extends SceneTree
## Ses dosyaları yüklenebiliyor mu, müzik döngüde mi?

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var sfx: Node = root.get_node("Sfx")
	var ok := true
	for n in ["click", "hover", "paper", "seal", "bell", "stinger_loss", "stinger_win", "cutscene", "alert", "menu", "ambient", "tension", "crisis"]:
		var st: AudioStream = sfx._streams.get(n)
		if st == null:
			printerr("AUDIO: eksik akış: ", n)
			ok = false
			continue
		var from_file := st is AudioStreamWAV and (st as AudioStreamWAV).mix_rate == 44100 or st is AudioStreamOggVorbis or st is AudioStreamMP3
		print("AUDIO ", n, " ", st.get_class(), " ", snappedf(st.get_length(), 0.01), "s", " dosya" if from_file else " sentez")
	for n in ["menu", "ambient", "tension", "crisis"]:
		sfx.crossfade_to(n)
		var playing: AudioStreamPlayer = sfx._music if sfx._music.playing else sfx._music_b
		if not playing.playing or playing.stream != sfx._streams[n]:
			printerr("AUDIO: geçiş başarısız: ", n)
			ok = false
		var stream: AudioStream = sfx._streams[n]
		if "loop" in stream and not stream.loop:
			printerr("AUDIO: müzik döngüde değil: ", n)
			ok = false
	sfx.crossfade_to("")
	print("AUDIO: OK" if ok else "AUDIO: FAIL")
	quit(0 if ok else 1)
