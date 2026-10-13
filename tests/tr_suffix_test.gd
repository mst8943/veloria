extends SceneTree

const SimCore := preload("res://game/core/sim.gd")
const BAD_TR := "(?i)(garnizonu|kolordusu|güvenlik)['’](nin|nın|nun|nün|in|ın|un|ün)\\b|['’](n?in|n?ın|n?un|n?ün)\\s+ile\\b|[A-ZÇĞİÖŞÜ][A-Za-zÇĞİÖŞÜçğıöşü]+['’](in|ın|un|ün)['’](in|ın|un|ün)"
const BAD_EN := "(?i)\\b(the|a|an|of|with|to|for)\\s+\\1\\b|\\b(of|with|to|for)\\s+of\\b|['’]s\\s+(with|to|for)\\b"
const DOUBLE_EN := "(?i)[a-z][ \\t]{2,}[a-z]"
const SCENARIOS := ["", "darbe", "naiplik", "bos_kasa"]
const KNOWN_BAD_TR := ["garnizonu'nin", "Sınır kolordusu'nin", "güvenlik'in", "Arden'in ile"]
const KNOWN_BAD_EN := ["the the guards", "broken  spacing", "the bill's with cost"]
const ACTOR_NAMES := ["Marcus Arden", "Ilyan Rell", "Sera Kest", "Marek Nadir", "Solen Vey", "Aven Dask",
	"Arden", "Sarne", "Leyla", "Voss", "Vale", "Veyra", "Helena", "Nadir", "Rell", "Kest", "Dask", "Solen", "Aven", "Marcus", "Julian", "Elena", "Brandt", "Dorn", "Kessler", "Falk", "Halden", "Sarn"]

var failures: Array[String] = []
var seen_strings: Dictionary = {}
var checked_tr := 0
var checked_en := 0
var tr_regex := RegEx.new()
var en_regex := RegEx.new()
var en_double_regex := RegEx.new()


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		push_error("TR SUFFIX: " + message)


func _scan(value: Variant, lang: String, context: String) -> void:
	if value is String:
		var line := str(value).strip_edges()
		if line.is_empty():
			return
		var cache_key := lang + "\u001f" + line
		if seen_strings.has(cache_key):
			return
		seen_strings[cache_key] = true
		var match_result: RegExMatch = tr_regex.search(line) if lang == "tr" else en_regex.search(line)
		if lang == "en" and match_result == null and not (line.contains("%") or line.contains("·") or line.contains("»")):
			match_result = en_double_regex.search(line)
		if match_result != null:
			_check(false, "%s (%s): %s" % [context, match_result.get_string(), line])
		if lang == "tr":
			var bad_harmony := _wrong_proper_suffix(line)
			if bad_harmony != "":
				_check(false, "%s (uyumsuz özel ad eki %s): %s" % [context, bad_harmony, line])
		if lang == "tr":
			checked_tr += 1
		else:
			checked_en += 1
	elif value is Dictionary:
		for key: Variant in value:
			_scan(value[key], lang, context)
	elif value is Array:
		for item: Variant in value:
			_scan(item, lang, context)


func _scan_runtime(sim: Node, lang: String, index: int) -> void:
	for field in ["pending", "history", "weekly_news", "reports", "truth_log", "plot_log", "external_history", "parliament_proposals"]:
		_scan(sim.get(field), lang, "%s campaign %d / %s" % [lang, index, field])
	for line in [sim.economy_journal_line(), sim.parliament_report_line(), sim.parliament_laws_line(),
		sim.government_status_line(), sim.army_report_line(), sim.region_report_line(), sim.foreign_report()]:
		_scan(line, lang, "%s campaign %d / report" % [lang, index])


func _play_campaign(sim: Node, seed_value: int, scenario: String, lang: String, index: int) -> void:
	sim.new_game(seed_value, 1, scenario)
	_scan_runtime(sim, lang, index)
	var guard := 0
	while not sim.ended and sim.week <= 104 and guard < 120:
		guard += 1
		var decisions := 0
		while not sim.pending.is_empty() and decisions < 5:
			decisions += 1
			var event: Dictionary = sim.pending[0]["event"]
			var choice_index := 0
			for i in event.get("choices", []).size():
				if event["choices"][i].get("available", true):
					choice_index = i
					break
			sim.resolve_decision(0, choice_index)
			_scan_runtime(sim, lang, index)
		if not sim.ended:
			sim.end_week()
			_scan_runtime(sim, lang, index)
	if not sim.ended:
		sim._end(false)
	_scan_runtime(sim, lang, index)
	_check(guard < 120, "%s campaign %d did not terminate" % [lang, index])


func _run() -> void:
	await process_frame
	_check(tr_regex.compile(BAD_TR) == OK, "Turkish scanner compiles")
	_check(en_regex.compile(BAD_EN) == OK, "English scanner compiles")
	_check(en_double_regex.compile(DOUBLE_EN) == OK, "English double-space scanner compiles")
	for sample in KNOWN_BAD_TR:
		_check(tr_regex.search(sample) != null, "Turkish scanner detects %s" % sample)
	_check(_wrong_proper_suffix("Arden'ın kararı") == "Arden'ın", "Turkish scanner detects incompatible apostrophe vowel")
	_check(_wrong_proper_suffix("Arden'in kararı") == "", "Turkish scanner accepts compatible apostrophe vowel")
	for sample in KNOWN_BAD_EN:
		_check(en_regex.search(sample) != null or en_double_regex.search(sample) != null, "English scanner detects %s" % sample)
	var sim: Node = root.get_node("Sim")
	var sfx: Node = root.get_node("Sfx")
	var old_lang := str(sfx.language)
	var old_path := str(sim.save_path)
	sim.save_path = "user://tr_suffix_test.txt"
	sim.autosave = false
	sim.record_chronicle = false
	for lang in ["tr", "en"]:
		sfx.set_language(lang)
		var valid_names := {"Arden": "Arden'in", "Voss": "Voss'un", "Vale": "Vale'nin", "Leyla": "Leyla'nın", "Sera Kest": "Sera Kest'in"}
		for name: String in valid_names:
			_check(SimCore.ek_tr(name, "in") == valid_names[name], "Sim.ek harmony for %s" % name)
		var count := 0
		for scenario: String in SCENARIOS:
			for sample in 5:
				count += 1
				_play_campaign(sim, 761000 + count, scenario, lang, count)
	# Scan content trees as well as generated campaign strings; JSON is parsed so indentation is ignored.
	var tr_data: Array = []
	var en_data: Array = []
	_collect_data("res://game/data", tr_data, "tr")
	_collect_data("res://game/data", en_data, "en")
	_collect_po("res://game/i18n/en.po", en_data)
	_scan(tr_data, "tr", "TR content catalog")
	_scan(en_data, "en", "EN content catalog")
	var source_texts: Array = []
	_collect_source_literals("res://game", source_texts)
	_scan(source_texts, "tr", "source templates")
	var source_errors := _source_suffix_errors("res://game")
	for error: String in source_errors:
		_check(false, error)
	_check(source_errors.is_empty(), "source suffix scan")
	var content_errors := failures.size()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	sim.save_path = old_path
	sfx.set_language(old_lang)
	if failures.is_empty():
		print("TR SUFFIX: OK (%d Turkish, %d English strings; 40 campaigns)" % [checked_tr, checked_en])
	else:
		push_error("TR SUFFIX: FAILED (%d findings)" % content_errors)
	quit(0 if failures.is_empty() else 1)


func _collect_data(path: String, output: Array, lang: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for file_name in dir.get_files():
		var full_path := path.path_join(file_name)
		if file_name.ends_with(".json"):
			if (lang == "en") != path.begins_with("res://game/data/en"):
				continue
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(full_path))
			if parsed != null:
				output.append(parsed)
	for subdir in dir.get_directories():
		_collect_data(path.path_join(subdir), output, lang)


func _collect_po(path: String, output: Array) -> void:
	for line in FileAccess.get_file_as_string(path).split("\n"):
		if line.begins_with("msgstr "):
			var translated: Variant = JSON.parse_string(line.substr(7))
			if translated is String:
				output.append(translated)


func _source_suffix_errors(path: String) -> Array[String]:
	var errors: Array[String] = []
	var dir := DirAccess.open(path)
	if dir == null:
		return errors
	for file_name in dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		var source := FileAccess.get_file_as_string(path.path_join(file_name))
		for bad in ["garnizonu'nin", "kolordusu'nin", "güvenlik'in", "'in ile", "'ın ile", "'un ile", "'ün ile"]:
			if source.to_lower().contains(bad):
				errors.append("%s contains %s" % [file_name, bad])
	for subdir in dir.get_directories():
		errors.append_array(_source_suffix_errors(path.path_join(subdir)))
	return errors


func _collect_source_literals(path: String, output: Array) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	var quoted := RegEx.new()
	quoted.compile("\\\"([^\\\"\\\\]|\\\\.)*\\\"")
	for file_name in dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		for line in FileAccess.get_file_as_string(path.path_join(file_name)).split("\n"):
			for found: RegExMatch in quoted.search_all(line):
				var decoded: Variant = JSON.parse_string(found.get_string())
				if decoded is String:
					output.append(decoded)
	for subdir in dir.get_directories():
		_collect_source_literals(path.path_join(subdir), output)


func _wrong_proper_suffix(line: String) -> String:
	if not line.contains("'") and not line.contains("’"):
		return ""
	for name: String in ACTOR_NAMES:
		var expected := SimCore.ek_tr(name, "in")
		for suffix: String in ["in", "ın", "un", "ün", "nin", "nın", "nun", "nün"]:
			var candidate: String = name + "'" + suffix
			if line.contains(candidate) and candidate != expected:
				return candidate
	return ""
