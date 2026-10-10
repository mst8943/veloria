extends SceneTree
## Arayüz denetimi: her ekranı gezer, ekran görüntüsü alır, ölçer.
##   godot --path . --script res://tests/ux_audit.gd -- --out=KLASÖR [--mobile] [--lang=en]
## Ölçümler: küçük dokunma hedefleri, görünür alandan taşan kontroller, kırpılan metin.
## Çıktı: KLASÖR/audit.txt ve her ekran için PNG.

var out := "user://audit"
var main: Control
var mobile := false
var report: PackedStringArray = []
var screen := ""
const MIN_TOUCH := 44.0
const MIN_DESK := 26.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
	mobile = "--mobile" in OS.get_cmdline_user_args()
	if mobile:
		DisplayServer.window_set_size(Vector2i(1067, 600))
	DirAccess.make_dir_recursive_absolute(out)
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 3)
	_boot.call_deferred()


func _boot() -> void:
	await process_frame
	(get_root().get_node("Sfx")).set_language("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()


func _frames(n := 8) -> void:
	for i in n:
		await process_frame


func _snap(name: String, wait := 10) -> void:
	screen = name
	await _frames(wait)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(name + ".png"))
	_measure(name)
	print("AUDIT ", name)


func _path(n: Node) -> String:
	var parts: PackedStringArray = []
	var cur := n
	while cur != null and cur != root and parts.size() < 5:
		parts.append(cur.name)
		cur = cur.get_parent()
	parts.reverse()
	return "/".join(parts)


func _label_text(c: Control) -> String:
	if c is BaseButton and "text" in c:
		return str(c.get("text")).left(30)
	if c is Label:
		return (c as Label).text.left(30)
	return ""


func _measure(name: String) -> void:
	var vp := main.get_viewport_rect()
	var min_side := MIN_TOUCH if mobile else MIN_DESK
	var seen := 0
	var stack: Array[Node] = [main]
	for layer in main.get_children():
		if layer is CanvasLayer:
			stack.append(layer)
	var all: Array[Node] = []
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		all.append(n)
		for ch in n.get_children():
			stack.append(ch)
	for n in all:
		if not (n is Control):
			continue
		var c := n as Control
		if not c.is_visible_in_tree():
			continue
		var r := c.get_global_rect()
		if r.size.x < 1 or r.size.y < 1 or not r.intersects(vp):
			continue
		if c.modulate.a < 0.05 or c.self_modulate.a < 0.05:
			continue
		if c is BaseButton and not (c as BaseButton).disabled and c.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			# Klipsiz görünür kısmı: ebeveyn kaydırma alanlarına göre kırp.
			var vis := r.intersection(vp)
			var cur: Node = c.get_parent()
			while cur != null and cur != main:
				if cur is ScrollContainer or (cur is Control and (cur as Control).clip_contents):
					vis = vis.intersection((cur as Control).get_global_rect())
				cur = cur.get_parent()
			if vis.size.x < 1 or vis.size.y < 1:
				continue
			var small := minf(r.size.x, r.size.y) < min_side
			if small and r.size.x * r.size.y > 0:
				report.append("[%s] KÜÇÜK HEDEF %dx%d  %s  «%s»" % [name, r.size.x, r.size.y, _path(c), _label_text(c)])
			if vis.size.x < r.size.x * 0.6 or vis.size.y < r.size.y * 0.6:
				if vis.size.x * vis.size.y > 4.0:
					report.append("[%s] KISMEN KIRPIK DÜĞME %dx%d görünen %dx%d  %s  «%s»" % [name, r.size.x, r.size.y, vis.size.x, vis.size.y, _path(c), _label_text(c)])
		if c is Label:
			var l := c as Label
			if l.text != "" and l.autowrap_mode == TextServer.AUTOWRAP_OFF and not l.clip_text and l.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING:
				var font := l.get_theme_font("font")
				var fs := l.get_theme_font_size("font_size")
				var w := font.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
				if w > r.size.x + 2.0 and l.size.x > 4.0:
					report.append("[%s] METİN TAŞIYOR %dpx > %dpx  %s  «%s»" % [name, w, r.size.x, _path(l), l.text.left(40)])
		if r.end.x > vp.end.x + 2.0 or r.position.x < vp.position.x - 2.0:
			if c is BaseButton or c is Label:
				report.append("[%s] EKRANDAN TAŞAR  %s  %s  «%s»" % [name, r.position, _path(c), _label_text(c)])
	seen += 1


func _run() -> void:
	await _frames(30)
	var sim0: Node = root.get_node("Sim")
	# Bekleyen karar sayısını sabitle.
	sim0.pending.clear()
	for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
		for event in sim0._events:
			if event["id"] == id:
				sim0.pending.append({"event": event, "age": 0})
				break
	main._agenda_view.decision_index = 0
	main._refresh()
	await _frames(6)
	if mobile:
		main._tabs.current_tab = 0
		await _snap("m01_gundem")
		main._scroll.scroll_vertical = int(main._scroll.get_v_scroll_bar().max_value)
		await _snap("m02_gundem_alt")
		main._tabs.current_tab = 1
		await _snap("m03_kisiler")
		main._sel.clear()
		main._sel.append("arden")
		main._style_cards()
		main._update_info()
		await _snap("m04_kisiler_secili")
		main._tabs.current_tab = 2
		await _snap("m05_raporlar")
		main._mobile_report_tabs.current_tab = 1
		await _snap("m06_dosyalar")
		main._mobile_report_tabs.current_tab = 2
		await _snap("m07_gunluk")
		main._tabs.current_tab = 0
	else:
		main._tabs.current_tab = 0
		await _snap("d01_gundem")
		main._sel.clear()
		main._sel.append("arden")
		main._style_cards()
		main._update_info()
		await _snap("d02_kisi_secili")
		main._select_tab(main._files_tab)
		await _snap("d03_dosyalar")
		main._select_tab(main._journal)
		await _snap("d04_gunluk")
		main._select_tab(main._scroll)
	main._desk.open()
	await _snap("x01_masa", 90)
	main._desk.close_view()
	main._city.open()
	await _snap("x02_harita", 60)
	main._city.close_view()
	main._media.open("state")
	await _snap("x03_medya", 60)
	main._media.hide()
	main._show_menu()
	await _snap("x04_menu", 90)
	for page in ["new", "settings", "help"]:
		if main._menu.pages.has(page):
			main._menu.show_page(page)
			await _snap("x05_menu_" + page, 60)
	main._hide_menu()
	main._show_modal("Test", "Tamam")
	await _snap("x06_modal")
	main._hide_menu()
	main._modal.hide()
	sim0.timeline.clear()
	sim0.capacity_timeline.clear()
	for w in range(1, 13):
		sim0.timeline.append({"w": w * 8, "king": 70.0, "unrest": 30.0, "plot": 20.0, "foreign": 72.0, "heir": 75.0})
		sim0.capacity_timeline.append({"w": w * 8, "maliye": 78.0, "hukuk": 78.0, "ordu": 78.0, "idare": 78.0, "holding": 35.0})
	sim0.week = 105
	sim0._end(true)
	await _frames(20)
	main._end_overlay.show()
	for i in 5:
		main._end_overlay.tabs.current_tab = i
		await _snap("x07_son_%d" % i, 40)
	var f := FileAccess.open(out.path_join("audit.txt"), FileAccess.WRITE)
	f.store_string("\n".join(report))
	f.close()
	print("AUDIT BULGU: ", report.size())
	quit(0)
