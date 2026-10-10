extends SceneTree
## İngilizce katmanının biçimini denetler; L4'te tam içerik zorunlu olur.

const TURKISH := "çğıöşüİÇĞÖŞÜ"
const LOGIC := {"id": true, "fx": true, "needs_flag": true, "flag": true, "actor": true, "domain": true, "art": true, "min_stat": true, "max_stat": true, "stance": true, "court_share": true, "red_line": true}
const ContentData := preload("res://game/core/content_data.gd")
const Actor := preload("res://game/core/actor.gd")
const Loc := preload("res://game/core/loc.gd")
var ok := true
var _female_refs := RegEx.new()
var _male_refs := RegEx.new()
var _male_pronouns := RegEx.new()
var _female_pronouns := RegEx.new()


func _init() -> void:
	_female_refs.compile("(?i)\\b(Veyra|Sophia|Renn|Queen|Helena|Leyla|Sarn|Claire|Duvall|Elena|Varos|Prime Minister|Prosecutor|Judge)\\b")
	_male_refs.compile("(?i)\\b(Arden|Nadir|Vale|Victor|Sarne|Adrian|Voss|Marcus|Julian|Valerius|Viktor|Malenkov|Lucien|King|Prince|General|Heir)\\b")
	_male_pronouns.compile("(?i)\\b(he|him|his|himself)\\b")
	_female_pronouns.compile("(?i)\\b(she|her|hers|herself)\\b")
	_check_po()
	_check_plural_forms()
	_check_overlays()
	_check_overlay_shapes()
	_check_loader_fallback()
	_check_runtime_leaks()
	print("I18N: OK" if ok else "I18N: FAIL")
	quit(0 if ok else 1)


func _check_runtime_leaks() -> void:
	var output: Array = []
	var project_path := ProjectSettings.globalize_path("res://")
	var exit_code := OS.execute(OS.get_executable_path(), ["--headless", "--path", project_path, "--script", "res://tests/en_leak_test.gd"], output, true)
	var result := "\n".join(PackedStringArray(output))
	_expect(exit_code == 0 and result.contains("EN LEAK SCAN: 5 campaigns, 0 unique leaks"), "İngilizce çalışma zamanı sızıntı testi başarısız: " + result)


func _check_po() -> void:
	var f := FileAccess.open("res://game/i18n/en.po", FileAccess.READ)
	_expect(f != null, "en.po bulunamadı")
	if f == null: return
	var text := f.get_as_text()
	_expect(text.contains("\"Language: en\\n\""), "en.po dil başlığı eksik")
	_check_po_gender(text)
	var ids := text.split("msgid ")
	for entry in ids.slice(1):
		if entry.begins_with("\"\""):
			continue
		_expect(entry.contains("msgstr \"") or entry.contains("msgstr[0] \""), "en.po msgstr eksik")


func _check_po_gender(text: String) -> void:
	var collecting := false
	var value := ""
	for line in text.split("\n"):
		if line.begins_with("msgstr ") or line.begins_with("msgstr[0] ") or line.begins_with("msgstr[1] "):
			if collecting:
				_check_gender_pronouns(value, "en.po msgstr")
				_check_quote_style(value, "en.po msgstr")
			collecting = true
			value = _po_literal(line.substr(line.find(" ") + 1))
		elif collecting and line.begins_with("\""):
			value += _po_literal(line)
		elif collecting:
			_check_gender_pronouns(value, "en.po msgstr")
			_check_quote_style(value, "en.po msgstr")
			collecting = false
	if collecting:
		_check_gender_pronouns(value, "en.po msgstr")
		_check_quote_style(value, "en.po msgstr")


func _check_plural_forms() -> void:
	var cases := [
		["%d mesai", "%d action", "%d actions"],
		["%d karar", "%d decision", "%d decisions"],
		["%d karar bekliyor", "%d decision waiting", "%d decisions waiting"],
		["%d söz", "%d promise", "%d promises"],
		["%d sözün vadesi geldi", "%d promise due", "%d promises due"],
		["%d sözün vadesi yaklaşıyor", "%d promise is coming due", "%d promises are coming due"],
		["%d düşman", "%d enemy", "%d enemies"],
		["%d şüpheli", "%d suspect", "%d suspects"],
		["%d kayıt", "%d entry", "%d entries"],
		["%d dedikodu", "%d rumour", "%d rumours"],
		["%d sırrın yayılıyor", "%d of your secrets is spreading", "%d of your secrets are spreading"],
		["%d kez yanılttı", "misled you %d time", "misled you %d times"],
		["%d KARAR BEKLİYOR   ·   GÜNDEMİ AÇ   »", "%d DECISION WAITING   ·   OPEN AGENDA   »", "%d DECISIONS WAITING   ·   OPEN AGENDA   »"],
		["%d söz verdin: %d tutuldu, %d bozuldu.", "You made %d promise: %d kept, %d broken.", "You made %d promises: %d kept, %d broken."],
		["%s ile %s'i yakın zamanda birbirine düşürmeyi denedin; %d hafta bekle.", "You recently tried to set %s and %s against each other; wait %d week.", "You recently tried to set %s and %s against each other; wait %d weeks."],
		["Saltanatının %d. haftasında Askerî darbeyle görevden alındı. Darbenin lideri %s, yalnızca %d hafta önce kendisi tarafından terfi ettirilmişti.", "You were deposed in week %d of your reign in a military coup. The coup leader was %s, whom you had promoted just %d week earlier.", "You were deposed in week %d of your reign in a military coup. The coup leader was %s, whom you had promoted just %d weeks earlier."],
		["Saltanatının %d. haftasında Saray darbesiyle görevden alındı. Darbenin lideri %s, yalnızca %d hafta önce kendisi tarafından terfi ettirilmişti.", "You were deposed in week %d of your reign in a palace coup. The coup leader was %s, whom you had promoted just %d week earlier.", "You were deposed in week %d of your reign in a palace coup. The coup leader was %s, whom you had promoted just %d weeks earlier."],
		["Bu çifti yakın zamanda denedin; %d hafta bekle.", "You tried this pair recently; wait %d week.", "You tried this pair recently; wait %d weeks."],
		["%s yeniden çağırmak için %d hafta beklemelisin.", "%s can be summoned again in %d week.", "%s can be summoned again in %d weeks."]
	]
	Loc.set_lang("en")
	for item in cases:
		var singular := str(item[1])
		var plural := str(item[2])
		var translated_one := Loc.ntr(str(item[0]), 1)
		var translated_two := Loc.ntr(str(item[0]), 2)
		_expect((translated_one % _plural_test_args(translated_one, 1)) == singular % _plural_test_args(singular, 1), "İngilizce tekil çoğul hatalı: " + str(item[0]))
		_expect((translated_two % _plural_test_args(translated_two, 2)) == plural % _plural_test_args(plural, 2), "İngilizce çoğul hatalı: " + str(item[0]))
	Loc.set_lang("tr")
	for item in cases:
		var source := str(item[0])
		_expect(Loc.ntr(source, 1) % _plural_test_args(source, 1) == source % _plural_test_args(source, 1), "Türkçe tekil kaynak değişti: " + source)
		_expect(Loc.ntr(source, 2) % _plural_test_args(source, 2) == source % _plural_test_args(source, 2), "Türkçe çoğul kaynak değişti: " + source)


func _plural_test_args(format: String, count: int) -> Variant:
	if format.contains("%d söz verdin") or format.contains("You made %d promise") or format.contains("You made %d promises"):
		return [count, 2, 0]
	if format.contains("hafta önce kendisi tarafından") or (format.contains("week") and format.contains("earlier")):
		return [10, "Viktor", count]
	if format.contains("%s"):
		if format.begins_with("%s ile %s") or format.contains("%s and %s"):
			return ["Selin", "Marcus", count]
		if format.begins_with("%s"):
			return ["Selin", count]
	return count


func _po_literal(raw: String) -> String:
	var parsed: Variant = JSON.parse_string(raw)
	return str(parsed) if parsed is String else ""


func _check_overlays() -> void:
	var dir := DirAccess.open("res://game/data/en")
	if dir == null:
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.ends_with(".json"):
			var f := FileAccess.open("res://game/data/en/" + name, FileAccess.READ)
			var parsed: Variant = JSON.parse_string(f.get_as_text()) if f else null
			_expect(parsed != null, "İngilizce JSON bozuk: " + name)
			if parsed != null:
				_check_tree(parsed, name)
		name = dir.get_next()
	dir.list_dir_end()


func _check_overlay_shapes() -> void:
	for file_name in ["content_labels.json", "content_council.json", "content_reports.json", "content_achievements.json", "content_history.json"]:
		var source: Variant = _json("res://game/data/" + file_name)
		var overlay: Variant = _json("res://game/data/en/" + file_name)
		_expect(source is Dictionary and overlay is Dictionary, "kaplama kök yapısı hatalı: " + file_name)
		if source is Dictionary and overlay is Dictionary:
			_check_matching_tree(source, overlay, file_name)
	var actors: Variant = _json("res://game/data/actors.json")
	var actor_overlay: Variant = _json("res://game/data/en/actors.json")
	_expect(actors is Array and actor_overlay is Dictionary, "actors kaplama yapısı hatalı")
	if not actors is Array or not actor_overlay is Dictionary:
		return
	for actor in actors:
		var id := str(actor.get("id", ""))
		_expect(actor_overlay.has(id), "actors kaplamasında kişi eksik: " + id)
		if not actor_overlay.has(id):
			continue
		var translated: Variant = actor_overlay[id]
		_expect(translated is Dictionary, "actors girdisi sözlük değil: " + id)
		if translated is Dictionary:
			_expect(translated.size() == 3, "actors girdisinde gösterim alanı sayısı hatalı: " + id)
			_expect(not translated.has("red_line"), "actors kaplaması mantık alanı içeriyor: %s/red_line" % id)
			for field in ["name", "title", "weak_point"]:
				_expect(translated.has(field) and translated[field] is String and not str(translated[field]).strip_edges().is_empty(), "actors alanı eksik: %s/%s" % [id, field])
	Loc.set_lang("en")
	var translated_actors: Array = ContentData.new().load_actors()
	var arden_data: Dictionary = translated_actors.filter(func(actor: Dictionary) -> bool: return actor.get("id") == "arden")[0]
	var arden = Actor.new()
	arden.setup(arden_data)
	_expect(arden.red_line.contains("ateş") and arden.crosses_red_line("bastir"), "İngilizce kaplama kırmızı çizgi mantığını değiştirdi")
	_expect(tr(arden.red_line) != arden.red_line, "kırmızı çizgi gösterim çevirisi eksik")
	Loc.set_lang("tr")
	for id in actor_overlay:
		_expect(actors.any(func(actor: Dictionary) -> bool: return str(actor.get("id", "")) == str(id)), "actors kaplamasında bilinmeyen kişi: " + str(id))


func _check_matching_tree(source: Variant, overlay: Variant, file_name: String, path: String = "") -> void:
	if source is Dictionary:
		_expect(overlay is Dictionary, "%s sözlük yapısı uyuşmuyor: %s" % [file_name, path])
		if not overlay is Dictionary:
			return
		for key in source:
			var key_name := str(key)
			if key_name in ["experts", "prizes", "regime_names", "regime_titles", "regime_threats", "regime_order", "stance", "court_share"]:
				_expect(not overlay.has(key), "%s mantık alanı içeriyor: %s" % [file_name, key_name])
				continue
			_expect(overlay.has(key), "%s kaplama anahtarı eksik: %s/%s" % [file_name, path, key_name])
			if overlay.has(key):
				var child_path := key_name if path.is_empty() else path + "/" + key_name
				_check_matching_tree(source[key], overlay[key], file_name, child_path)
		for key in overlay:
			_expect(source.has(key), "%s kaplamasında bilinmeyen anahtar: %s/%s" % [file_name, path, key])
	elif source is Array:
		_expect(overlay is Array and source.size() == overlay.size(), "%s dizi boyutu uyuşmuyor: %s" % [file_name, path])
		if overlay is Array:
			for i in mini(source.size(), overlay.size()):
				_check_matching_tree(source[i], overlay[i], file_name, "%s/%d" % [path, i])
	elif source is String:
		_expect(overlay is String and not str(overlay).strip_edges().is_empty(), "%s metin eksik: %s" % [file_name, path])
	else:
		_expect(false, "%s kaplamasında metin olmayan alan var: %s" % [file_name, path])


func _check_loader_fallback() -> void:
	var loader: RefCounted = ContentData.new()
	Loc.set_lang("en")
	var translated: Dictionary = loader.load_all()
	_expect(not translated.is_empty() and str(translated.get("history", {}).get("pro_survived", "")).begins_with("King %s"), "İngilizce içerik kaplaması yüklenmedi")
	var source_labels: Variant = _json("res://game/data/content_labels.json")
	for key in ["prizes", "regime_names", "regime_titles", "regime_threats"]:
		_expect(translated.get("labels", {}).get(key) == source_labels.get(key), "İngilizce yükleme iç anahtarı değiştirdi: " + key)
	var probe := {"pro_survived": "Türkçe kaynak cümlesi", "untranslated": "Türkçe yedek"}
	var merged: Variant = loader._translated("res://game/data/content_history.json", probe)
	_expect(merged.get("untranslated", "") == "Türkçe yedek", "eksik metin Türkçe kaynağa düşmedi")
	var missing := ["Türkçe satır"]
	_expect(loader._translated("res://game/data/no_overlay.json", missing) == missing, "eksik kaplama Türkçe kaynağa düşmedi")
	Loc.set_lang("tr")
	var source: Variant = _json("res://game/data/content_history.json")
	var turkish: Dictionary = loader.load_all()
	_expect(turkish.get("history", {}) == source, "Türkçe mod ana içeriği değiştirdi")


func _json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(f.get_as_text()) if f else null


func _check_tree(value: Variant, file_name: String, key: String = "") -> void:
	if value is Dictionary:
		for k in value:
			_expect(not LOGIC.has(str(k)), "%s mantık alanı içeriyor: %s" % [file_name, k])
			var path := str(k) if key.is_empty() else key + "/" + str(k)
			_check_tree(value[k], file_name, path)
	elif value is Array:
		for i in value.size():
			_check_tree(value[i], file_name, key + "/%d" % i)
	elif value is String:
		_expect(not value.strip_edges().is_empty(), "%s boş çeviri içeriyor" % file_name)
		for ch in TURKISH:
			_expect(not value.contains(ch), "%s Türkçe karakter içeriyor: %s" % [file_name, value])
		_check_gender_pronouns(value, file_name + "/" + key)
		_check_quote_style(value, file_name + "/" + key)


func _check_gender_pronouns(value: String, path: String) -> void:
	var has_female := _female_refs.search(value) != null
	var has_male := _male_refs.search(value) != null
	if has_female and not has_male and _male_pronouns.search(value) != null:
		push_warning("I18N gender warning (%s): female reference with masculine pronoun" % path)
	if has_male and not has_female and _female_pronouns.search(value) != null:
		push_warning("I18N gender warning (%s): male reference with feminine pronoun" % path)


func _check_quote_style(value: String, path: String) -> void:
	if value.contains("’") or value.contains("‘"):
		push_warning("I18N quote style warning (%s): use straight apostrophes/single quotes" % path)
	if value.contains("\""):
		push_warning("I18N quote style warning (%s): use curly double quotes" % path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		ok = false
