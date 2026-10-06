extends SceneTree
## Arayüz ekran görüntüleri: oyun ekranı (akış şeridi), menü sayfaları, oyun sonu sekmeleri.
## Pencereli çalıştır (headless çizim yapmaz):
##   Godot --path . --script res://tests/ui_shots.gd -- --out=C:/klasor [--mobile]
## Oyuncu kaydına ve arşive dokunmaz (dev_autostart: autosave ve arşiv kapalı).

var out := "user://shots"
var main: Control


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out)
	# Yalnızca bellekte: project.godot'a yazılmaz.
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	# --guide: ilk hafta (yol gösterici görünür); varsayılan: 4. hafta
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 0 if "--guide" in OS.get_cmdline_user_args() else 3)
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()


func _shot(file_name: String) -> void:
	for i in 120:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(file_name + ".png"))
	print("SHOT ", file_name)


func _run() -> void:
	# Kişi paneli dolu görünsün: en güçlü kişiyi seç.
	var sim0: Node = root.get_node("Sim")
	var top_id := ""
	for a in sim0.actors.values():
		if top_id == "" or a.power > sim0.actors[top_id].power:
			top_id = a.id
	main._sel.clear()
	main._sel.append(top_id)
	main._style_cards()
	main._update_info()
	await _shot("1_oyun")
	# Karar kartı + meclis görüşü: taraf olan danışmanı olan bir olayı başa koy.
	for e in sim0._events:
		if e["id"] == "gida_protestosu":
			sim0.pending.insert(0, {"event": e, "age": 0})
	main._refresh()
	main._on_flow("gundem")
	await _shot("1_karar")
	# Mobilde kişiler ve eylemler ayrı "Saray" sekmesinde.
	var saray: Control = main._tabs.get_node_or_null("Saray")
	if saray != null:
		main._select_tab(saray)
		await _shot("1_saray")
		main._on_flow("gundem")
	if "--only-decision" in OS.get_cmdline_user_args():
		# Darbe krizi kartı + şüphe göstergesi (yalnızca bu kipte: sonraki ekranların durumunu bozmasın).
		sim0.week = maxi(sim0.week, 20)
		var ar = sim0.actors.get("arden")
		if ar != null:
			ar.signs.append({"w": sim0.week, "text": "Arden'in subayları geç saatlere kadar karargâhta toplanıyor.", "weight": 3, "real": true})
			ar.signs.append({"w": sim0.week, "text": "Arden kendi adamlarını başkentteki kritik birliklere atadı.", "weight": 3, "real": true})
			main._sel.clear()
			main._sel.append("arden")
		sim0.week = maxi(sim0.week, 20)
		for a in sim0.actors.values():
			if a.insider:
				a.ambition = 200.0
		sim0._run_cascade()
		main._refresh()
		main._style_cards()
		main._update_info()
		main._on_flow("gundem")
		await _shot("1_kriz")
		quit(0)
		return
	main._desk.open()
	await _shot("1_masa")
	main._desk.close_view()
	if "--only-desk" in OS.get_cmdline_user_args():
		quit(0)
		return
	main._city.open()
	await _shot("1_harita")
	main._city.close_view()
	main._open_media()
	await _shot("1_medya")
	main._media.show_tab("free")
	await _shot("1_medya_serbest")
	main._media.show_tab("tv")
	await _shot("1_medya_tv")
	main._media.close_view()
	if "--only-world" in OS.get_cmdline_user_args():
		quit(0)
		return
	main._show_menu()
	await _shot("2_menu")
	main._menu_show_page("new")
	await _shot("3_menu_yeni")
	main._menu_show_page("settings")
	await _shot("4_menu_ayarlar")
	main._menu.hide()
	main._instant = true
	var sim: Node = root.get_node("Sim")
	if "--regime" in OS.get_cmdline_user_args():
		sim.week = 59
		sim.king_strength = 90.0
		sim.unrest = 20.0
		sim.stats["bribes"] = 5
		sim.end_week()
		main._on_flow("gundem")
		await _shot("5_rejim_hafta")
		main._scroll.scroll_vertical = int(main._scroll.get_v_scroll_bar().max_value)
		await _shot("5_rejim_ozet")
		sim.week = 105
		sim._end(true)
		await _shot("5_rejim_son")
		quit(0)
		return
	while not sim.ended:
		while not sim.pending.is_empty() and sim.mesai > 0:
			sim.resolve_decision(0, 0)   # meclis sicili dolsun
		sim.end_week()
	await process_frame
	var tabs: TabContainer = main._end_overlay.tabs
	for i in tabs.get_tab_count():
		tabs.current_tab = i
		await _shot("5_son_%d" % i)
	# Hakikat Dosyası'nın sonu: meclis sicili
	tabs.current_tab = 3
	main._end_overlay.lies_page.scroll_to_line(main._end_overlay.lies_page.get_line_count() - 1)
	await _shot("5_son_3_meclis")
	quit(0)
