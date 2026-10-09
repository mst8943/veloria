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
	if "--mobile" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1067, 600))
	DirAccess.make_dir_recursive_absolute(out)
	# Yalnızca bellekte: project.godot'a yazılmaz.
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	# --guide: ilk hafta (yol gösterici görünür); varsayılan: 4. hafta
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 0 if "--guide" in OS.get_cmdline_user_args() else 3)
	_boot.call_deferred()


func _boot() -> void:
	await process_frame
	(get_root().get_node("Sfx")).set_language("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()


func _shot(file_name: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(file_name + ".png"))
	print("SHOT ", file_name)


func _run() -> void:
	# Kişi paneli dolu görünsün: en güçlü kişiyi seç.
	var sim0: Node = root.get_node("Sim")
	if "--state-only" in OS.get_cmdline_user_args():
		sim0.timeline.clear()
		sim0.capacity_timeline.clear()
		for w in range(1, 13):
			sim0.timeline.append({"w": w * 8, "king": 70.0, "unrest": 30.0, "plot": 20.0, "foreign": 72.0, "heir": 75.0})
			sim0.capacity_timeline.append({"w": w * 8, "maliye": 78.0, "hukuk": 78.0, "ordu": 78.0, "idare": 78.0, "holding": 35.0})
		sim0.week = 105
		sim0._end(true)
		await process_frame
		sim0.record["new_achievements"] = ["liyakat_krali", "oligarki_dizginleyen", "uc_bayrak", "hazir_veliaht"]
		main._end_overlay.show_record(sim0.record)
		var state_tabs: TabContainer = main._end_overlay.tabs
		state_tabs.current_tab = 0
		await _shot("5_devlet_son")
		state_tabs.current_tab = 1
		await _shot("5_devlet_grafik")
		state_tabs.current_tab = 3
		await _shot("5_devlet_defteri")
		quit(0)
		return
	var top_id := ""
	for a in sim0.actors.values():
		if top_id == "" or a.power > sim0.actors[top_id].power:
			top_id = a.id
	main._sel.clear()
	main._sel.append(top_id)
	main._style_cards()
	main._update_info()
	await _shot("1_oyun")
	main._sel.clear()
	main._sel.append("kessler")
	main._style_cards()
	main._update_info()
	main._show_act_cat("DEVLET")
	await _shot("1_devlet")
	if "--foreign" in OS.get_cmdline_user_args():
		var foreign_saray: Control = main._tabs.get_node_or_null("Saray")
		if foreign_saray != null:
			main._select_tab(foreign_saray)
		main._sel.clear()
		main._sel.append("claire")
		main._style_cards()
		main._update_info()
		main._show_act_cat("DEVLET")
		await process_frame
		await process_frame
		if foreign_saray != null:
			(foreign_saray as ScrollContainer).scroll_vertical = int((foreign_saray as ScrollContainer).get_v_scroll_bar().max_value)
		await _shot("1_heyet")
		sim0.foreign = {"asteria": 74.0, "drakon": 48.0, "seravia": 27.0}
		sim0.flags["HEYET_GONDER"] = sim0.week
		sim0._generate_reports()
		main._refresh()
		await process_frame
		await process_frame
		if foreign_saray != null:
			main._on_flow("gundem")
			await process_frame
			await process_frame
		if main._report_box != null:
			(main._report_box.get_parent() as ScrollContainer).scroll_vertical = int((main._report_box.get_parent() as ScrollContainer).get_v_scroll_bar().max_value)
		else:
			main._scroll.scroll_vertical = int(main._scroll.get_v_scroll_bar().max_value)
		await _shot("1_elena_disisleri")
		for e in sim0._events:
			if e["id"] == "asteria_kredi_teklifi":
				sim0.pending.insert(0, {"event": e, "age": 0})
				break
		main._refresh()
		main._on_flow("gundem")
		await _shot("1_asteria_olay")
		quit(0)
		return
	if "--newcomers" in OS.get_cmdline_user_args():
		var new_saray: Control = main._tabs.get_node_or_null("Saray")
		if new_saray != null:
			main._select_tab(new_saray)
		for aid in ["julian", "elena"]:
			main._sel.clear()
			main._sel.append(aid)
			main._style_cards()
			main._update_info()
			if new_saray != null:
				(new_saray as ScrollContainer).scroll_vertical = 190
			await _shot("1_" + aid + "_kart")
		if new_saray != null:
			main._on_flow("gundem")
		main._refresh()
		await process_frame
		if main._report_box != null:
			var report_scroll: ScrollContainer = main._report_box.get_parent()
			report_scroll.scroll_vertical = int(report_scroll.get_v_scroll_bar().max_value)
		else:
			main._scroll.scroll_vertical = int(main._scroll.get_v_scroll_bar().max_value)
		await _shot("1_elena_rapor")
		for e in sim0._events:
			if e["id"] == "julian_halka_konusma":
				sim0.pending.insert(0, {"event": e, "age": 0})
				break
		main._refresh()
		main._scroll.scroll_vertical = 0
		await _shot("1_julian_olay")
		quit(0)
		return
	if "--demand" in OS.get_cmdline_user_args():
		sim0.week = 18
		sim0.pending.clear()
		sim0._fire_patronage()
		main._refresh()
		main._on_flow("gundem")
		await _shot("1_halden_talep")
		main._scroll.scroll_vertical = 380 if "--mobile" in OS.get_cmdline_user_args() else 0
		await _shot("1_halden_talep_secimler")
		quit(0)
		return
	main._show_act_cat("KAZAN")
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
		main._show_act_cat("DEVLET")
		(saray as ScrollContainer).scroll_vertical = int((saray as ScrollContainer).get_v_scroll_bar().max_value)
		await _shot("1_saray_devlet")
		main._show_act_cat("KAZAN")
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
	if "--state" in OS.get_cmdline_user_args():
		sim0.foreign = {"asteria": 74.0, "drakon": 48.0, "seravia": 27.0}
		sim0.flags["DOGRULA_elena"] = sim0.week
		main._city.show_site("asteria")
		await _shot("1_asteria_elcilik")
		main._city.show_site("seravia")
		await _shot("1_seravia_elcilik")
		sim0.capacity["maliye"] = 20.0
		sim0.capacity["hukuk"] = 80.0
		sim0.flags["DOGRULA_maliye"] = sim0.week
		sim0.flags["DOGRULA_hukuk"] = sim0.week
		main._city.show_site("maliye")
		await _shot("1_maliye_aksiyor")
		main._city.show_site("adliye")
		await _shot("1_adliye_saglam")
		main._city.close_view()
		sim0.week = 13
		sim0.pending.clear()
		sim0._fire_budget()
		main._refresh()
		main._on_flow("gundem")
		await _shot("1_butce")
		# Finali bilinen bir devlet çizelgesiyle kur: iki yeni grafik çizgisi ve defter okunabilsin.
		main._instant = true
		sim0.pending.clear()
		sim0.capacity_timeline.clear()
		sim0.timeline.clear()
		for w in range(1, 105):
			var cap := 25.0 if w == 50 else 78.0
			sim0.capacity_timeline.append({"w": w, "maliye": cap, "hukuk": cap, "ordu": cap, "idare": cap,
				"holding": 80.0 if w == 50 else 35.0})
			sim0.timeline.append({"w": w, "king": 70.0, "unrest": 30.0, "plot": 20.0,
				"foreign": 24.0 if w == 50 else 72.0, "heir": 75.0})
		sim0.kadro_log = [{"week": 31, "institution": "hukuk", "kind": "merit"}]
		sim0.stats["tenders"] = 3
		sim0.stats["halden_hostile_weeks"] = 8
		sim0.holding = 35.0
		sim0.heir_maturity = 75.0
		sim0.foreign = {"asteria": 74.0, "drakon": 72.0, "seravia": 71.0}
		sim0.week = 105
		sim0._end(true)
		await process_frame
		# Geliştirici kipi başarımları kalıcı yazmaz; yalnızca görüntü için göster.
		sim0.record["new_achievements"] = ["liyakat_krali", "oligarki_dizginleyen", "uc_bayrak", "hazir_veliaht"]
		main._end_overlay.show_record(sim0.record)
		var state_tabs: TabContainer = main._end_overlay.tabs
		state_tabs.current_tab = 0
		await _shot("5_devlet_son")
		state_tabs.current_tab = 1
		await _shot("5_devlet_grafik")
		state_tabs.current_tab = 3
		main._end_overlay.lies_page.scroll_to_line(main._end_overlay.lies_page.get_line_count() - 1)
		await _shot("5_devlet_defteri")
		sim0.new_game(126)
		sim0.capacity_timeline.clear()
		sim0.timeline.clear()
		for w in range(1, 105):
			sim0.capacity_timeline.append({"w": w, "maliye": 25.0, "hukuk": 25.0, "ordu": 25.0, "idare": 25.0, "holding": 40.0})
			sim0.timeline.append({"w": w, "king": 70.0, "unrest": 30.0, "plot": 20.0,
				"foreign": 24.0, "heir": 25.0})
		sim0.heir_maturity = 25.0
		sim0.foreign = {"asteria": 24.0, "drakon": 24.0, "seravia": 24.0}
		sim0.week = 105
		sim0._end(true)
		await process_frame
		sim0.record["new_achievements"] = ["harap_devlet", "yalniz_kral"]
		main._end_overlay.show_record(sim0.record)
		await _shot("5_harap_son")
		quit(0)
		return
	main._city.close_view()
	if "--patron" in OS.get_cmdline_user_args():
		sim0.holding = 85.0
		sim0.halden_hostile_until = sim0.week + 8
		main._sel.clear()
		main._sel.append("halden")
		main._refresh()
		main._style_cards()
		main._update_info()
		main._show_act_cat("DEVLET")
		var patron_saray: Control = main._tabs.get_node_or_null("Saray")
		if patron_saray != null:
			main._select_tab(patron_saray)
		await _shot("1_halden")
		main._city.open()
		main._city.show_site("holding")
		await _shot("1_holding")
		main._city.close_view()
		main._open_media()
		await _shot("1_dusman_gazete")
		main._media.show_tab("tv")
		await _shot("1_dusman_tv")
		quit(0)
		return
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
		var guard := 0
		while not sim.pending.is_empty() and sim.mesai > 0 and guard < 6:
			guard += 1
			var choices: Array = sim.pending[0]["event"]["choices"]
			var choice := -1
			for i in choices.size():
				if choices[i].get("available", true) and sim.private_wealth + float(choices[i].get("fx", {}).get("wealth", 0)) >= 0.0:
					choice = i
					break
			if choice < 0:
				break
			sim.resolve_decision(0, choice)	# meclis sicili dolsun
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
