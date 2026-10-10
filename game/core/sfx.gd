extends Node
## Ses ve ayarlar (autoload: Sfx).
## Sesler kodla sentezlenir. res://audio/<ad>.ogg|wav varsa o kullanılır:
##   ambient, click, hover, paper, seal, bell, stinger_loss, stinger_win, cutscene, alert

const RATE := 22050
const Loc := preload("res://game/core/loc.gd")
const SETTINGS_PATH := "user://veloria_settings.cfg"
const NAMES := ["click", "hover", "paper", "seal", "bell", "stinger_loss", "stinger_win", "cutscene", "alert"]

var music_volume := 0.5
var sfx_volume := 0.8
var fullscreen := false
var short_fx := false      # kısa geçişler (animasyonları hızlandırır)
var difficulty := 1        # 0 Kolay, 1 Normal, 2 Zor
var tips := true           # ilk haftalarda danışman ipuçları
var intro := true          # yeni oyunda açılış sineması
var desk_start := true     # her haftaya çalışma masasından başla
var tour_enabled := true
var tour_done := false
var language := "tr"

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _next := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	_load_settings()
	Loc.set_lang(language)
	_ensure_bus("Music")
	_ensure_bus("SFX")
	for i in 6:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	_build_streams()
	_apply()


func _ensure_bus(name: String) -> void:
	if AudioServer.get_bus_index(name) == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, name)
		AudioServer.set_bus_send(idx, "Master")


func _apply() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(maxf(music_volume, 0.0001)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(maxf(sfx_volume, 0.0001)))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func set_music(v: float) -> void:
	music_volume = v
	_apply()


func set_sfx(v: float) -> void:
	sfx_volume = v
	_apply()


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply()


func save_settings() -> void:
	var c := ConfigFile.new()
	c.set_value("audio", "music", music_volume)
	c.set_value("audio", "sfx", sfx_volume)
	c.set_value("video", "fullscreen", fullscreen)
	c.set_value("video", "short_fx", short_fx)
	c.set_value("game", "difficulty", difficulty)
	c.set_value("game", "tips", tips)
	c.set_value("game", "intro", intro)
	c.set_value("game", "desk_start", desk_start)
	c.set_value("game", "language", language)
	c.set_value("game", "tour_enabled", tour_enabled)
	c.set_value("game", "tour_done", tour_done)
	c.save(SETTINGS_PATH)


func _load_settings() -> void:
	var c := ConfigFile.new()
	if c.load(SETTINGS_PATH) != OK:
		return
	music_volume = c.get_value("audio", "music", music_volume)
	sfx_volume = c.get_value("audio", "sfx", sfx_volume)
	fullscreen = c.get_value("video", "fullscreen", false)
	short_fx = c.get_value("video", "short_fx", false)
	difficulty = c.get_value("game", "difficulty", 1)
	tips = c.get_value("game", "tips", true)
	intro = c.get_value("game", "intro", true)
	desk_start = c.get_value("game", "desk_start", true)
	tour_enabled = c.get_value("game", "tour_enabled", true)
	tour_done = c.get_value("game", "tour_done", false)
	language = str(c.get_value("game", "language", "tr"))


func set_language(value: String) -> void:
	language = "en" if value == "en" else "tr"
	Loc.set_lang(language)


func play(name: String, volume_db := 0.0, pitch := 1.0) -> void:
	if not _streams.has(name) or _players.is_empty():
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[name]
	p.volume_db = volume_db
	p.pitch_scale = pitch * _rng.randf_range(0.97, 1.03)
	p.play()


func start_music() -> void:
	if _music.playing or not _streams.has("ambient"):
		return
	var amb: AudioStream = _streams["ambient"]
	if "loop" in amb:
		amb.loop = true   # ogg/mp3 müzik döngüde çalar
	_music.stream = amb
	_music.volume_db = -6.0
	_music.play()


# ---------------------------------------------------------------- Sentez

func _build_streams() -> void:
	for n in NAMES + ["ambient"]:
		var loaded := _try_load(n)
		if loaded != null:
			_streams[n] = loaded
	if not _streams.has("click"):
		_streams["click"] = _synth_click()
	if not _streams.has("hover"):
		_streams["hover"] = _synth_hover()
	if not _streams.has("paper"):
		_streams["paper"] = _synth_paper()
	if not _streams.has("seal"):
		_streams["seal"] = _synth_seal()
	if not _streams.has("bell"):
		_streams["bell"] = _synth_bell()
	if not _streams.has("stinger_loss"):
		_streams["stinger_loss"] = _synth_loss()
	if not _streams.has("stinger_win"):
		_streams["stinger_win"] = _synth_win()
	if not _streams.has("ambient"):
		_streams["ambient"] = _synth_ambient()


func _try_load(n: String) -> AudioStream:
	for ext in ["ogg", "wav", "mp3"]:
		var p := "res://audio/%s.%s" % [n, ext]
		if ResourceLoader.exists(p):
			return load(p)
	return null


func _to_wav(data: PackedFloat32Array, looped := false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(data.size() * 2)
	for i in data.size():
		bytes.encode_s16(i * 2, int(clampf(data[i], -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = bytes
	if looped:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = data.size()
	return w


func _buf(seconds: float) -> PackedFloat32Array:
	var a := PackedFloat32Array()
	a.resize(int(RATE * seconds))
	return a


func _synth_click() -> AudioStreamWAV:
	var a := _buf(0.07)
	for i in a.size():
		var t := float(i) / RATE
		a[i] = (sin(TAU * 230.0 * t) * 0.55 + _rng.randf_range(-1, 1) * 0.25) * exp(-t * 70.0) * 0.7
	return _to_wav(a)


func _synth_hover() -> AudioStreamWAV:
	var a := _buf(0.04)
	for i in a.size():
		var t := float(i) / RATE
		a[i] = sin(TAU * 1500.0 * t) * exp(-t * 150.0) * 0.12
	return _to_wav(a)


func _synth_paper() -> AudioStreamWAV:
	var a := _buf(0.38)
	var lp := 0.0
	for i in a.size():
		var x := float(i) / a.size()
		var env := pow(sin(PI * x), 2.0)
		var n := _rng.randf_range(-1, 1)
		lp += (n - lp) * 0.22
		a[i] = (n - lp) * env * 0.28 + lp * env * 0.12
	return _to_wav(a)


func _synth_seal() -> AudioStreamWAV:
	var a := _buf(0.55)
	var ph := 0.0
	for i in a.size():
		var t := float(i) / RATE
		ph += TAU * (48.0 + 70.0 * exp(-t * 10.0)) / RATE
		var thud := sin(ph) * exp(-t * 7.5) * 0.85
		var tick := _rng.randf_range(-1, 1) * exp(-t * 90.0) * 0.4
		a[i] = thud + tick
	return _to_wav(a)


func _synth_bell() -> AudioStreamWAV:
	var a := _buf(2.4)
	var parts := [[1.0, 1.0], [2.76, 0.55], [5.4, 0.3], [8.93, 0.16]]
	for i in a.size():
		var t := float(i) / RATE
		var v := 0.0
		for k in parts.size():
			v += sin(TAU * 311.0 * parts[k][0] * t) * parts[k][1] * exp(-t * (1.6 + k * 0.9))
		a[i] = v * 0.22 * minf(t * 200.0, 1.0)
	return _to_wav(a)


func _synth_loss() -> AudioStreamWAV:
	var a := _buf(4.2)
	for i in a.size():
		var t := float(i) / RATE
		var env := pow(sin(PI * minf(t / 4.2, 1.0)), 1.4)
		var v := sin(TAU * 55.0 * t) + sin(TAU * 58.3 * t) * 0.9 + sin(TAU * 82.4 * t) * 0.6 + sin(TAU * 116.5 * t) * 0.35
		a[i] = v * env * 0.22 + _rng.randf_range(-1, 1) * env * 0.03
	return _to_wav(a)


func _synth_win() -> AudioStreamWAV:
	var a := _buf(3.4)
	var freqs := [130.8, 196.0, 261.6, 329.6, 392.0]
	for i in a.size():
		var t := float(i) / RATE
		var env := minf(t / 0.6, 1.0) * exp(-maxf(t - 0.6, 0.0) * 0.9)
		var v := 0.0
		for f in freqs:
			v += sin(TAU * f * t) + sin(TAU * f * 2.0 * t) * 0.25
		a[i] = v * env * 0.1
	return _to_wav(a)


## 12 saniyelik dikişsiz döngü: alçak pedal sesleri, yavaş titreşimle.
func _synth_ambient() -> AudioStreamWAV:
	var secs := 12.0
	var a := _buf(secs)
	var base := [55.0, 82.5, 110.0, 164.5]
	var amps := [0.5, 0.32, 0.22, 0.12]
	for i in a.size():
		var t := float(i) / RATE
		var v := 0.0
		for k in base.size():
			# Tam sayı çevrim: döngü noktasında süreksizlik olmaz.
			var f: float = round(base[k] * secs) / secs
			var lfo := 0.7 + 0.3 * sin(TAU * float(k + 1) / secs * t)
			v += sin(TAU * f * t) * amps[k] * lfo
		var bell_t := fmod(t, 6.0)
		v += sin(TAU * round(440.0 * 3.0) / 3.0 * t) * exp(-bell_t * 1.3) * 0.015 * (1.0 if int(t / 6.0) == 1 else 0.0)
		a[i] = v * 0.30
	return _to_wav(a, true)
