extends SceneTree
## İngilizce katmanının biçimini denetler; L4'te tam içerik zorunlu olur.

const TURKISH := "çğıöşüİÇĞÖŞÜ"
const LOGIC := {"id": true, "fx": true, "needs_flag": true, "flag": true, "actor": true, "domain": true, "art": true, "min_stat": true, "max_stat": true, "stance": true, "court_share": true}
const ContentData := preload("res://game/core/content_data.gd")
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
	_check_overlays()
	_check_overlay_shapes()
	_check_loader_fallback()
	print("I18N: OK" if ok else "I18N: FAIL")
	quit(0 if ok else 1)


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
		_expect(entry.contains("msgstr \""), "en.po msgstr eksik")


func _check_po_gender(text: String) -> void:
	var collecting := false
	var value := ""
	for line in text.split("\n"):
		if line.begins_with("msgstr "):
			if collecting:
				_check_gender_pronouns(value, "en.po msgstr")
			collecting = true
			value = _po_literal(line.trim_prefix("msgstr "))
		elif collecting and line.begins_with("\""):
			value += _po_literal(line)
		elif collecting:
			_check_gender_pronouns(value, "en.po msgstr")
			collecting = false
	if collecting:
		_check_gender_pronouns(value, "en.po msgstr")


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
			_expect(translated.size() == 4, "actors girdisinde gösterim alanı sayısı hatalı: " + id)
			for field in ["name", "title", "red_line", "weak_point"]:
				_expect(translated.has(field) and translated[field] is String and not str(translated[field]).strip_edges().is_empty(), "actors alanı eksik: %s/%s" % [id, field])
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


func _check_gender_pronouns(value: String, path: String) -> void:
	var has_female := _female_refs.search(value) != null
	var has_male := _male_refs.search(value) != null
	if has_female and not has_male and _male_pronouns.search(value) != null:
		push_warning("I18N gender warning (%s): female reference with masculine pronoun" % path)
	if has_male and not has_female and _female_pronouns.search(value) != null:
		push_warning("I18N gender warning (%s): male reference with feminine pronoun" % path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		ok = false
