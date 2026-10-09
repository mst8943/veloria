extends SceneTree
## Autoplay boyunca arayüz kontrollerinde gösterilmiş metinleri TSV'ye toplar.
const TURKISH_CHARS := "çğıöşüÇĞİÖŞÜ"
const TURKISH_WORDS := ["ve", "bir", "bu", "şu", "çok", "daha", "için", "ama", "artık", "değil", "hafta", "kriz", "taht", "kral", "saray", "meclis", "halk", "güç", "karar", "sakin", "zor", "kolay", "hazır", "dosya", "rapor", "olay", "darbe", "komplo", "oyun", "mesai", "medya", "haber", "günlük", "kişiler", "gündem", "devlet", "yeni", "seç", "konuş", "başla", "çalış", "düş", "terfi", "yönet", "tutuk", "geç", "ülke", "görev", "başarı", "ünvan"]

var out_path := "user://i18n_dump.tsv"
var rows := {}
var ended_frames := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_path = arg.substr(6)
	ProjectSettings.set_setting("veloria/dev_autostart", false)
	call_deferred("_boot")


func _boot() -> void:
	await process_frame
	root.get_node("Sfx").set_language("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	root.add_child((load("res://game/ui/main.tscn") as PackedScene).instantiate())


func _process(_delta: float) -> bool:
	var main := root.get_node_or_null("Main")
	if main == null:
		return false
	_capture(main)
	var sim := root.get_node("Sim")
	if sim.ended:
		ended_frames += 1
		var end_tabs := main._end_overlay.get("tabs") as TabContainer if main._end_overlay != null else null
		var done_at := 90
		if end_tabs != null:
			done_at = end_tabs.get_tab_count() * 12 + 90
			if ended_frames <= end_tabs.get_tab_count() * 12 and ended_frames % 12 == 1:
				end_tabs.current_tab = int((ended_frames - 1) / 12)
			elif ended_frames == end_tabs.get_tab_count() * 12 + 1:
				main._end_overlay.hide()
				main._show_menu()
				main._show_chronicle()
		if ended_frames >= done_at:
			_write_dump()
			quit(0)
	return false


func _capture(node: Node) -> void:
	if node is Control:
		var value := ""
		if node is RichTextLabel:
			value = node.get_parsed_text()
		elif node is Label or node is Button or node is LineEdit or node is TextEdit:
			value = node.text
		if value.strip_edges() != "":
			var key := "%s\t%s" % [str(node.get_path()), value.replace("\r", "").replace("\n", "\\n")]
			if node.is_visible_in_tree() or not rows.has(key):
				rows[key] = "visible" if node.is_visible_in_tree() else "hidden-only"
	for child in node.get_children():
		_capture(child)


func _write_dump() -> void:
	var path := ProjectSettings.globalize_path(out_path) if out_path.begins_with("user://") or out_path.begins_with("res://") else out_path
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("Cannot write i18n dump: " + path)
		return
	f.store_line("visibility\tcontrol\ttext")
	for key in rows:
		f.store_line("%s\t%s" % [rows[key], key])
	print("I18N_DUMP: %d unique control texts -> %s" % [rows.size(), path])
	var word_regex := RegEx.new()
	word_regex.compile("(?i)(^|[^A-Za-zçğıöşüÇĞİÖŞÜ])(" + "|".join(TURKISH_WORDS) + ")($|[^A-Za-zçğıöşüÇĞİÖŞÜ])")
	var suspect_count := 0
	for key in rows:
		if rows[key] != "visible":
			continue
		var value: String = str(key).substr(str(key).find("\t") + 1).replace("\\n", "\n")
		var suspect := false
		for ch in TURKISH_CHARS:
			if value.contains(ch):
				suspect = true
				break
		if not suspect:
			suspect = word_regex.search(value) != null
		if suspect:
			suspect_count += 1
			print("I18N_TURKISH? ", key.replace("\t", " | "))
	print("I18N_TURKISH? total=%d (heuristic; review every row)" % suspect_count)
