extends SceneTree
## İngilizce katmanının biçimini denetler; L4'te tam içerik zorunlu olur.

const TURKISH := "çğıöşüİÇĞÖŞÜ"
const LOGIC := {"id": true, "fx": true, "needs_flag": true, "flag": true, "actor": true, "domain": true, "art": true, "min_stat": true, "max_stat": true, "stance": true, "court_share": true}
var ok := true


func _init() -> void:
	_check_po()
	_check_overlays()
	print("I18N: OK" if ok else "I18N: FAIL")
	quit(0 if ok else 1)


func _check_po() -> void:
	var f := FileAccess.open("res://game/i18n/en.po", FileAccess.READ)
	_expect(f != null, "en.po bulunamadı")
	if f == null: return
	var text := f.get_as_text()
	_expect(text.contains("\"Language: en\\n\""), "en.po dil başlığı eksik")
	var ids := text.split("msgid ")
	for entry in ids.slice(1):
		if entry.begins_with("\"\""):
			continue
		_expect(entry.contains("msgstr \""), "en.po msgstr eksik")


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


func _check_tree(value: Variant, file_name: String, key: String = "") -> void:
	if value is Dictionary:
		for k in value:
			_expect(not LOGIC.has(str(k)), "%s mantık alanı içeriyor: %s" % [file_name, k])
			_check_tree(value[k], file_name, str(k))
	elif value is Array:
		for item in value:
			_check_tree(item, file_name, key)
	elif value is String:
		_expect(not value.strip_edges().is_empty(), "%s boş çeviri içeriyor" % file_name)
		for ch in TURKISH:
			_expect(not value.contains(ch), "%s Türkçe karakter içeriyor: %s" % [file_name, value])


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		ok = false
