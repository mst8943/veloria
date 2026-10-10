extends SceneTree
## English runtime leak gate: visible UI surfaces, tooltips, and generated campaign prose.
const Loc := preload("res://game/core/loc.gd")
const TR_CHARS := "çğıöşüİÇĞÖŞÜ"
const WORDS := ["ve", "bir", "için", "bu", "ile", "gibi", "olarak", "daha", "çok", "kadar", "ama", "ancak", "veya", "ise", "değil", "var", "yok", "mesai", "hafta", "karar", "kişi", "kişiler", "soruşturma", "istihbarat", "raporu", "ertelendi", "gerekçeler", "başla", "kapat", "seç", "yaptıkların"]
const NAMES := ["Veloria", "Sarne", "Arden", "Veyra", "Vale", "Voss", "Sarn", "Malenkov", "Duvall", "Lucien", "Marcus", "Helena", "Varos", "Renn", "Adrian", "Leyla"]
var main: Control
var sfx: Node
var seen := {}
var failures: Array[String] = []
var campaigns := 0

func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 3)
	call_deferred("_boot")

func _boot() -> void:
	await process_frame
	root.get_node("Sfx").set_language("en")
	sfx = root.get_node("Sfx")
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for frame in 10:
		await process_frame
	main._start_new()
	await _scan_game_ui()
	await _scan_campaigns()
	_finish()

func _scan_game_ui() -> void:
	for i in main._tabs.get_tab_count():
		main._tabs.current_tab = i
		await process_frame
		_collect(main, "main tab: " + main._tabs.get_tab_title(i))
	for category in main._cat_btns:
		main._show_act_cat(str(category))
		await process_frame
		_collect(main, "action category: " + str(category))
	main._divan.open()
	for frame in 16: await process_frame
	_collect(main, "Divan drawer")
	main._divan.close()
	main._desk.open()
	await process_frame
	_collect(main, "Desk")
	for tab in ["gundem", "kisiler", "gunluk", "dosyalar"]:
		main._on_desk_request(tab)
		await process_frame
		_collect(main, "Desk tab: " + tab)
	main._media.open()
	for channel in ["state", "free", "tv"]:
		main._media.show_tab(channel)
		await process_frame
		_collect(main, "Media: " + channel)
	main._media.close_view()
	main._city.open()
	await process_frame
	for site in main._city._sites:
		main._city.show_site(str(site))
		await process_frame
		_collect(main, "Map: " + str(site))
	main._city.close_view()
	main._show_menu()
	await process_frame
	_collect(main, "Menu")
	if main._menu != null:
		for child in main._menu.find_children("*", "Button", true, false):
			if child is Button and (child as Button).text.to_lower().contains("setting"):
				(child as Button).pressed.emit()
				await process_frame
				break
	_collect(main, "Settings")
	main._tour.active = true
	main._tour.show()
	for step in 10:
		main._tour.index = step
		main._tour._render()
		_collect(main, "Tour step %d" % step)
	main._tour.active = false
	main._tour.hide()
	var menu_script: Script = main._menu.get_script()
	for page in ["HOW_TO", "CREDITS"]:
		main._show_modal(main._menu._translate_lines(str(menu_script.get_script_constant_map().get(page, ""))))
		await process_frame
		_collect(main, "Modal: " + page)
	main._show_chronicle()
	await process_frame
	_collect(main, "Chronicle")
	sfx.short_fx = true
	main._end_week_pressed()
	await create_timer(0.65).timeout
	_collect(main, "Week curtain")
	main._curtain_skip = true
	for frame in 12: await process_frame
	sfx.short_fx = false
	main._play_cutscene("suikast", 2)
	await create_timer(1.0).timeout
	_collect(main, "Cutscene: suikast")
	for frame in 180: await process_frame
	_check_cutscenes()

func _scan_campaigns() -> void:
	var sim = root.get_node("Sim")
	for spec in [[7101, 0], [7102, 0], [7103, 1], [7104, 1], [7105, 2]]:
		Loc.set_lang("en")
		sim.new_game(int(spec[0]), int(spec[1]))
		var guard := 0
		while not sim.ended and guard < 110:
			sim.end_week()
			guard += 1
		for line in sim.history: _check_text(str(line), "campaign %d history" % spec[0])
		for line in sim.weekly_news: _check_text(sim.news_for_display(str(line)), "campaign %d news" % spec[0])
		for report in sim.reports:
			if report is Dictionary:
				for value in report.values():
					if value is String: _check_text(str(value), "campaign %d report" % spec[0])
		campaigns += 1
	if sim.record is Dictionary and not sim.record.is_empty() and main._end_overlay != null:
		main._end_overlay.show_record(sim.record)
		var tabs: TabContainer = main._end_overlay.get("tabs")
		if tabs != null:
			for i in tabs.get_tab_count():
				tabs.current_tab = i
				await process_frame
				_collect(main._end_overlay, "Game over: " + tabs.get_tab_title(i))

func _check_cutscenes() -> void:
	var file := FileAccess.open("res://game/data/cutscenes.json", FileAccess.READ)
	var scenes: Variant = JSON.parse_string(file.get_as_text()) if file != null else null
	if not scenes is Array:
		failures.append("res://game/data/cutscenes.json:1 | cutscenes | JSON could not be read")
		return
	for scene: Dictionary in scenes:
		for shot: Dictionary in scene.get("shots", []):
			for key in ["line", "sub"]:
				var source := str(shot.get(key, ""))
				if source != "": _check_text(tr(source), "Cutscene: " + str(scene.get("id", "?")))

func _collect(node: Node, screen: String) -> void:
	if node is Control:
		var c := node as Control
		if c.is_visible_in_tree():
			if c is Label or c is RichTextLabel or c is Button or c is LineEdit or c is TextEdit:
				var value: String = c.get_parsed_text() if c is RichTextLabel else c.text
				_check_text(str(value), screen)
			if c.tooltip_text.strip_edges() != "": _check_text(c.tooltip_text, screen + " tooltip")
			if c is TabContainer:
				for i in c.get_tab_count(): _check_text(c.get_tab_title(i), screen + " tab")
	for child in node.get_children(): _collect(child, screen)

func _check_text(value: String, screen: String) -> void:
	var text := value.strip_edges()
	if text.is_empty(): return
	var suspect := false
	for ch in TR_CHARS:
		if text.contains(ch):
			var legal := false
			for name in NAMES:
				if text == name: legal = true
			if not legal: suspect = true
			break
	if not suspect:
		var rx := RegEx.new()
		rx.compile("(?i)(^|[^A-Za-z])(" + "|".join(WORDS) + ")($|[^A-Za-z])")
		suspect = rx.search(text) != null
	if not suspect or seen.has(text): return
	seen[text] = true
	var location := _source_for(text)
	failures.append("%s | %s | %s" % [location, screen, text.replace("\n", " ")])


func _source_for(text: String) -> String:
	for path in ["res://game/i18n/en.po", "res://game/ui", "res://game/core", "res://game/data/en"]:
		var files: Array[String] = []
		_list_files(path, files)
		for file_path in files:
			var f := FileAccess.open(file_path, FileAccess.READ)
			if f == null: continue
			var line_number := 0
			while not f.eof_reached():
				line_number += 1
				if f.get_line().contains(text): return "%s:%d" % [file_path, line_number]
	return "runtime/generated"

func _list_files(path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		if FileAccess.file_exists(path): result.append(path)
		return
	dir.list_dir_begin()
	var item := dir.get_next()
	while item != "":
		if item != "." and item != "..":
			var full := path.path_join(item)
			if dir.current_is_dir(): _list_files(full, result)
			elif item.ends_with(".gd") or item.ends_with(".json") or item.ends_with(".po"): result.append(full)
		item = dir.get_next()
	dir.list_dir_end()

func _finish() -> void:
	print("EN LEAK SCAN: %d campaigns, %d unique leaks" % [campaigns, failures.size()])
	for failure in failures: printerr(failure)
	quit(1 if not failures.is_empty() else 0)
