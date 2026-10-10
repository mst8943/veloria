extends SceneTree
## EN: oyun boyunca ÜRETİLEN metinler (eylem sonuçları, haberler, raporlar, günlük, dosyalar, oyun sonu) -> TSV.
var main: Control
var out_path := "C:/Users/USER/Desktop/en_dump2.tsv"
var rows := {}
var rng := RandomNumberGenerator.new()


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 0)
	call_deferred("_boot")


func _boot() -> void:
	await process_frame
	root.get_node("Sfx").set_language("en")
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for i in 20:
		await process_frame
	await _run()


func _add(t: String, ctx: String) -> void:
	var s := t.strip_edges()
	if s != "" and not rows.has(s):
		rows[s] = ctx


func _grab(node: Node, ctx: String) -> void:
	if node is Control:
		var c := node as Control
		var t := ""
		if c is RichTextLabel:
			t = (c as RichTextLabel).get_parsed_text()
		elif c is Label or c is BaseButton or c is LineEdit:
			t = str(c.get("text"))
		_add(t, ctx)
		_add(c.tooltip_text, ctx + " [tooltip]")
		if c is TabContainer:
			for i in c.get_tab_count():
				_add(c.get_tab_title(i), ctx + " [tab]")
	for ch in node.get_children():
		_grab(ch, ctx)


func _act(sim: Node, id: String) -> void:
	var calls: Array = [
		func() -> String: return str(sim.summon(id)), func() -> String: return str(sim.promote(id)),
		func() -> String: return str(sim.bribe(id)), func() -> String: return str(sim.cross_check(id)),
		func() -> String: return str(sim.investigate(id)), func() -> String: return str(sim.order(id, "sorustur", "sozlu")),
		func() -> String: return str(sim.order(id, "bastir", "yazili")), func() -> String: return str(sim.order(id, "bastir", "ima")),
		func() -> String: return str(sim.blackmail(id)), func() -> String: return str(sim.dismiss(id)),
		func() -> String: return str(sim.appoint(id, "loyal")), func() -> String: return str(sim.appoint(id, "merit")),
		func() -> String: return str(sim.train_heir(id)),
	]
	var c: Callable = calls[rng.randi() % calls.size()]
	_add(str(c.call()), "action result")


func _run() -> void:
	var sim: Node = root.get_node("Sim")
	for seed_i in 12:
		rng.seed = 100 + seed_i
		sim.new_game(seed_i * 7 + 3, seed_i % 3)
		main._refresh()
		for w in 104:
			if sim.ended:
				break
			sim.mesai = 6
			for k in 3:
				var ids: Array = sim.actors.keys()
				_act(sim, str(ids[rng.randi() % ids.size()]))
			for i in range(sim.pending.size() - 1, -1, -1):
				var e: Dictionary = sim.pending[i]["event"]
				var n: int = e["choices"].size()
				sim.mesai = 3
				_add(str(sim.resolve_decision(i, rng.randi() % n)), "decision result")
			for n in sim.weekly_news:
				_add(sim.news_for_display(str(n)), "news")
			if w % 3 == 0:
				main._refresh()
				_grab(main, "campaign %d week %d" % [seed_i, sim.week])
			sim.end_week()
		if not sim.ended:
			while not sim.ended:
				sim.end_week()
		await process_frame
		main._end_overlay.show_record(sim.record)
		for i in main._end_overlay.tabs.get_tab_count():
			main._end_overlay.tabs.current_tab = i
			_grab(main._end_overlay, "end tab %d" % i)
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	for t in rows:
		f.store_line(str(rows[t]).replace("\t", " ") + "\t" + str(t).replace("\n", " ⏎ ").replace("\t", " "))
	f.close()
	print("DUMP2 ", rows.size())
	quit(0)
