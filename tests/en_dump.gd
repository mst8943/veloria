extends SceneTree
## EN arayüzündeki TÜM metinleri (görünür olmayanlar dahil) TSV'ye döker: tests/en_dump.gd -- --out=DOSYA.tsv [--mobile]
var main: Control
var out_path := "C:/Users/USER/Desktop/en_dump.tsv"
var rows := {}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 3)
	call_deferred("_boot")


func _boot() -> void:
	await process_frame
	root.get_node("Sfx").set_language("en")
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for i in 20:
		await process_frame
	await _run()


func _grab(node: Node, ctx: String) -> void:
	if node is Control:
		var c := node as Control
		var t := ""
		if c is RichTextLabel:
			t = (c as RichTextLabel).get_parsed_text()
		elif c is Label or c is BaseButton or c is LineEdit:
			t = str(c.get("text"))
		if t.strip_edges() != "":
			rows[t.strip_edges()] = ctx
		if c.tooltip_text.strip_edges() != "":
			rows[c.tooltip_text.strip_edges()] = ctx + " [tooltip]"
		if c is TabContainer:
			for i in c.get_tab_count():
				rows[c.get_tab_title(i)] = ctx + " [tab]"
		if c is OptionButton:
			for i in (c as OptionButton).item_count:
				rows[(c as OptionButton).get_item_text(i)] = ctx + " [option]"
	for ch in node.get_children():
		_grab(ch, ctx)


func _run() -> void:
	var sim: Node = root.get_node("Sim")
	_grab(main, "boot")
	var keys: Array = []
	for k in main._person_panel.ACTION_META:
		keys.append(k)
	for id in sim.actors:
		main._sel.clear()
		main._sel.append(id)
		main._style_cards()
		main._update_info()
		main._refresh()
		for cat in main._cat_btns:
			main._show_act_cat(str(cat))
			await process_frame
			_grab(main, "actor %s cat %s" % [id, cat])
			for k in keys:
				main._preview(str(k))
				_grab(main, "actor %s preview %s" % [id, k])
	main._sel.clear()
	# birkaç hafta oyna; bekleyen kararlar, raporlar, günlük, dosyalar
	for w in 24:
		for i in range(sim.pending.size() - 1, -1, -1):
			sim.resolve_decision(i, 0)
		main._refresh()
		_grab(main, "week %d" % sim.week)
		sim.end_week()
	main._refresh()
	main._desk.open()
	await process_frame
	_grab(main, "desk")
	main._desk.close_view()
	main._show_chronicle()
	await process_frame
	_grab(main, "chronicle")
	main._show_menu()
	for page in main._menu.pages:
		main._menu.show_page(str(page))
		_grab(main, "menu " + str(page))
	main._show_modal(main._menu._translate_lines(main._menu.CREDITS))
	_grab(main, "credits")
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	for t in rows:
		f.store_line(str(rows[t]).replace("\t", " ") + "\t" + str(t).replace("\n", " ⏎ ").replace("\t", " "))
	f.close()
	print("DUMP ", rows.size())
	quit(0)
