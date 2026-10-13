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
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--size="):
			var dims := a.substr(7).split("x")
			DisplayServer.window_set_size(Vector2i(int(dims[0]), int(dims[1])))
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
	if "--no-vibrancy" in OS.get_cmdline_user_args():
		main.get_node("Vibrancy").hide()
	_run.call_deferred()


func _shot(file_name: String) -> void:
	for i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(file_name + ".png"))
	print("SHOT ", file_name)


func _run() -> void:
	# Kişi paneli dolu görünsün: en güçlü kişiyi seç.
	var sim0: Node = root.get_node("Sim")
	if "--main-target" in OS.get_cmdline_user_args() or "--main-people" in OS.get_cmdline_user_args():
		sim0.week = 1
		sim0.pending.clear()
		sim0.mesai = sim0.mesai_max
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--main-target-mesai="):
				sim0.mesai = clampi(int(arg.substr(20)), 0, sim0.mesai_max)
		sim0.private_wealth = 10.0
		sim0.week_changes.clear()
		var news_tr := "OLAY: Taç giyme töreninin ertesi sabahı"
		var news_en := "EVENT: The morning after the coronation"
		sim0.weekly_news = [news_tr]
		sim0.weekly_news_localized = {news_tr: news_en}
		main._media_seen_week = 0
		main._week_log.clear()
		main._week_log_week = 1
		main._sel.clear()
		main._sel.append("voss")
		var is_english := "--lang=en" in OS.get_cmdline_user_args()
		main._headline_notice = "Vale sana bir dosya bıraktı: ‘Kim kimdir, Majesteleri.’ Arden not etti." if not is_english else "Vale left you a file: ‘Who is who, Your Majesty.’ Arden noted it."
		root.get_node("Sfx").tips = true
		main._refresh()
		main._update_headline()
		main._style_cards()
		main._update_info()
		if "--main-people" in OS.get_cmdline_user_args():
			main._tabs.current_tab = 1
		Input.warp_mouse(Vector2(4, 4))
		await process_frame
		await _shot("main_people" if "--main-people" in OS.get_cmdline_user_args() else "main_target")
		quit(0)
		return
	var inspect_state := ""
	var shot_name := "inspect"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--inspect="):
			inspect_state = arg.substr(10)
		if arg.begins_with("--shot-name="):
			shot_name = arg.substr(12)
	if inspect_state != "":
		sim0.week = 1
		sim0.pending.clear()
		sim0.mesai = sim0.mesai_max
		main._media_seen_week = 0
		main._week_log.clear()
		main._week_log_week = 1
		main._sel.clear()
		main._sel.append("voss")
		if inspect_state == "decision" or inspect_state == "decision_reasons":
			for event in sim0._events:
				if event["id"] == "gida_protestosu":
					sim0.pending.append({"event": event, "age": 0})
					break
		elif inspect_state == "decision_noart":
			var found := false
			for event in sim0._events:
				if event["id"] == "gida_protestosu":
					var ev_copy: Dictionary = event.duplicate(true)
					ev_copy["art"] = ""
					sim0.pending.append({"event": ev_copy, "age": 0})
					found = true
					break
			if not found:
				push_error("UI_SHOTS: decision_noart fixture event not found")
				quit(1)
				return
		elif inspect_state == "decision_crisis":
			sim0.week = 20
			sim0._open_crisis()
		elif inspect_state == "decision_multi":
			var found: Array[String] = []
			for event in sim0._events:
				if event["id"] in ["gida_protestosu", "general_atamalari"]:
					sim0.pending.append({"event": event, "age": 0})
					found.append(event["id"])
			if found.size() != 2:
				push_error("UI_SHOTS: decision_multi fixture events missing: " + str(found))
				quit(1)
				return
		elif inspect_state == "files":
			sim0.facts["fact_demo"] = {"id": "fact_demo", "subject": "king", "common": 0.45, "knowers": ["arden", "voss"], "copies": 2, "public": false, "rumor": false, "name": "Gizli Saray Fonu"}
			sim0.promises = [{"actor": "arden", "prize": "Naiplik", "state": "active", "due": 8, "exposed": false}]
		main._refresh()
		main._style_cards()
		main._update_info()
		if inspect_state == "decision_reasons" and main._agenda_view.reasons_button != null:
			main._agenda_view.reasons_button.button_pressed = true
		match inspect_state:
			"agenda", "decision", "decision_noart", "decision_crisis", "decision_multi", "decision_reasons":
				main._tabs.current_tab = 0
			"files": main._select_tab(main._files_tab)
			"journal": main._select_tab(main._journal)
			"divan":
				if main._mobile: main._tabs.current_tab = 1
				main._divan.open()
			"map": main._city.open()
			"map_regions":
				main._city.open()
				main._city._set_region_layer(true)
			"map_site":
				main._city.open()
				main._city.show_site("medya")
			"map_region":
				main._city.open()
				main._city.show_region("industry")
			"media": main._open_media()
			"media_free":
				main._open_media()
				main._media.show_tab("free")
			"media_tv":
				main._open_media()
				main._media.show_tab("tv")
			"desk": main._show_desk()
			"menu": main._show_menu()
			"menu_settings":
				main._show_menu()
				main._menu_show_page("settings")
			"menu_dynasty":
				main._show_menu()
				main._menu_show_page("dynasty")
			"modal_archive":
				main._show_chronicle()
			"end_screen":
				sim0.week = 104
				sim0.king_strength = 90.0
				sim0.unrest = 20.0
				sim0._end(true)
				main._end_overlay.show_record(sim0.record)
			"title": main.add_child(load("res://game/ui/title_screen.gd").new(main))
		Input.warp_mouse(Vector2(4, 4))
		await _shot(shot_name)
		quit(0)
		return
	if "--r5c-coup-signs" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		for actor in sim0.actors.values(): actor.signs.clear()
		sim0.weekly_news.clear()
		sim0.weekly_news_localized.clear()
		for stage in [1, 2, 3]:
			sim0._add_army_plot_sign(sim0.actors["arden"], stage)
		main._tabs.current_tab = 1
		main._person_panel._set_mobile_group("state")
		var tap := InputEventMouseButton.new()
		tap.button_index = MOUSE_BUTTON_LEFT
		tap.pressed = true
		main._person_panel._on_card_input(tap, "arden")
		await process_frame
		for chip in main._traits.get_children():
			if chip.tooltip_text.begins_with(tr("Son alametler")) or chip.tooltip_text.begins_with(tr("Recent signs")):
				Input.warp_mouse(chip.get_global_rect().get_center())
				break
		for i in 45: await process_frame
		await _shot("r5c_coup_signs")
		quit(0)
		return
	if "--r5c-coup-card" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		for actor in sim0.actors.values(): actor.ready = false
		sim0.actors["arden"].ready = true
		sim0.week = 20
		sim0._open_crisis()
		main._tabs.current_tab = 0
		main._refresh()
		await _shot("r5c_coup_card")
		quit(0)
		return
	if "--r5c-divan" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		main._tabs.current_tab = 0
		main._divan.open()
		if "--scroll-divan" in OS.get_cmdline_user_args():
			for i in 35: await process_frame
			var bar: VScrollBar = main._divan.drawer_scroll.get_v_scroll_bar()
			main._divan.drawer_scroll.scroll_vertical = maxi(0, int(bar.max_value - bar.page) - 280)
		await _shot("r5c_divan")
		quit(0)
		return
	if "--border-crisis" in OS.get_cmdline_user_args() or "--siege-crisis" in OS.get_cmdline_user_args() or "--assassination-crisis" in OS.get_cmdline_user_args():
		var crisis_kind := "border" if "--border-crisis" in OS.get_cmdline_user_args() else ("siege" if "--siege-crisis" in OS.get_cmdline_user_args() else "assassination")
		var prefix := "border" if crisis_kind == "border" else ("siege" if crisis_kind == "siege" else "assassination")
		sim0.week = 50
		sim0.crisis_cooldown = 0
		if crisis_kind == "border":
			sim0.ext_pressure["drakon"] = 70.0
		elif crisis_kind == "siege":
			sim0.ext_pressure["asteria"] = 70.0
		sim0._open_other(crisis_kind)
		main._refresh()
		await _shot(prefix + ("_prep" if crisis_kind == "assassination" else "_note"))
		if crisis_kind == "assassination":
			quit(0)
			return
		sim0.resolve_decision(0, 0)
		sim0.week += 1
		sim0.pending.clear()
		sim0._check_crises()
		main._refresh()
		await _shot("border_ultimatum" if crisis_kind == "border" else "siege_credit_cut")
		quit(0)
		return
	if "--r4b-action" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		sim0.week = 12
		sim0._queue_region_action()
		main._refresh()
		await _shot("r4b_region_choice")
		sim0.resolve_decision(0, 0)
		main._refresh()
		await _shot("r4b_investment_choice")
		quit(0)
		return
	if "--r4c-map" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		sim0.week = 12
		main._refresh()
		main._city.open()
		await _shot("r4c_map_layer_off")
		main._city._region_toggle.button_pressed = true
		main._city._region_toggle.toggled.emit(true)
		await _shot("r4c_map_layer_on")
		main._city.show_region("industry")
		await _shot("r4c_region_panel")
		await _shot("r4c_governor_card")
		quit(0)
		return
	if "--r4c-crisis" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		sim0.week = 12
		sim0.regions["industry"]["economy"] = 20.0
		for seed in range(1, 100):
			sim0.region_rng.seed = seed
			sim0._check_regional_crisis()
			if not sim0.pending.is_empty():
				break
		main._refresh()
		await _shot("r4c_region_crisis")
		quit(0)
		return
	if "--r4b-crisis" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		sim0.regions["industry"]["economy"] = 20.0
		for seed in range(1, 50):
			sim0.region_rng.seed = seed
			sim0._check_regional_crisis()
			if not sim0.pending.is_empty(): break
		main._refresh()
		await _shot("r4b_regional_crisis")
		quit(0)
		return
	if "--r4b-governor-dismiss" in OS.get_cmdline_user_args() or "--r4b-governor-appoint" in OS.get_cmdline_user_args():
		sim0.pending.clear()
		var appoint := "--r4b-governor-appoint" in OS.get_cmdline_user_args()
		if appoint: sim0.regions["capital"]["governor"] = ""
		sim0._queue_region_action_options("capital")
		main._refresh()
		await _shot("r4b_governor_%s" % ("appoint" if appoint else "dismiss"))
		quit(0)
		return
	if "--tour" in OS.get_cmdline_user_args():
		var requested_step := 0
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--tour-step="):
				requested_step = clampi(int(arg.substr(12)), 0, 9)
		if requested_step == 3 and sim0.pending.is_empty():
			for event in sim0._events:
				if event["id"] == "gida_protestosu":
					sim0.pending.append({"event": event, "age": 0})
					break
			main._refresh()
		main._tour.begin()
		main._tour.index = requested_step
		main._tour._render()
		await _shot("tour_%02d" % requested_step)
		quit(0)
		return
	if "--economy" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		sim0.week = 13
		sim0._fire_budget()
		main._refresh()
		main._on_flow("gundem")
		if main._mobile:
			for frame in 3:
				await process_frame
			var agenda_bar: VScrollBar = main._scroll.get_v_scroll_bar()
			main._scroll.scroll_vertical = maxi(0, int(agenda_bar.max_value - agenda_bar.page) - 18)
			await process_frame
		await _shot("r1_budget")
		main._decision_buttons[3].pressed.emit()
		await process_frame
		await _shot("r1_custom_budget")
		main._close_budget_editor()
		main._scroll.scroll_vertical = 0
		sim0.pending.clear()
		sim0.reports = [{"source": "kessler", "name": sim0.actors["kessler"].display_name,
			"title": sim0.actors["kessler"].title, "text": sim0.economy_report("kessler"), "band": 1}]
		main._tabs.current_tab = 2
		if main._mobile:
			main._mobile_report_tabs.current_tab = 0
		main._refresh()
		await _shot("r1_finance_report")
		main._tabs.current_tab = 1
		if main._mobile:
			(main._person_panel._mobile_group_buttons["state"] as Button).pressed.emit()
			await process_frame
		main._sel.clear()
		main._sel.append("kessler")
		main._style_cards()
		main._update_info()
		main._show_act_cat("DEVLET")
		if main._mobile:
			await process_frame
			var profile_bar: VScrollBar = main._person_panel._mobile_person_scroll.get_v_scroll_bar()
			main._person_panel._mobile_person_scroll.scroll_vertical = int(profile_bar.max_value - profile_bar.page)
		await _shot("r1_state_actions")
		main._journal.clear()
		main._on_week(sim0.week)
		main._select_tab(main._journal)
		await _shot("r1_daily")
		if not main._mobile:
			main._divan.open()
			await _shot("r1_divan")
		quit(0)
		return
	if "--all-actions" in OS.get_cmdline_user_args():
		main._sel.clear()
		main._sel.append("arden")
		main._refresh()
		main._update_info()
		for category in ["KAZAN", "SÖZ VER", "ÖĞREN", "EMRET", "BASKI", "OPERASYON", "DEVLET", "KAMUOYU"]:
			main._show_act_cat(category)
			await _shot("action_" + category)
		quit(0)
		return
	if "--public-opinion" in OS.get_cmdline_user_args():
		main._sel.clear()
		main._sel.append("arden")
		main._style_cards()
		main._update_info()
		if main._mobile:
			main._tabs.current_tab = 1
			(main._person_panel._mobile_group_buttons["state"] as Button).pressed.emit()
		else:
			main._tabs.current_tab = 0
		main._show_act_cat("KAMUOYU")
		if main._mobile:
			await process_frame
			var action_bar: VScrollBar = main._person_panel._mobile_person_scroll.get_v_scroll_bar()
			main._person_panel._mobile_person_scroll.scroll_vertical = int(action_bar.max_value - action_bar.page)
		await _shot("r2_visibility_actions")
		sim0.public_opinion_active = true
		sim0.week = 8
		sim0.pending.clear()
		sim0._tick_public_opinion()
		main._refresh()
		main._tabs.current_tab = 0
		await _shot("r2_poll_card")
		sim0.pending.clear()
		sim0._add_fact("r2_shot_scandal", "Sarayın gizli ödemesi", "king", 25.0, ["vale"], 1, 0.5, "Secret palace payment")
		sim0.facts["r2_shot_scandal"]["public"] = true
		if main._mobile:
			main._tabs.current_tab = 2
			main._mobile_report_tabs.current_tab = 1
		else:
			main._tabs.current_tab = 1
		main._refresh()
		await _shot("r2_scandal_response")
		if main._mobile:
			var files_scroll := main._mobile_report_tabs.get_child(1).get_child(1) as ScrollContainer
			var report_scroll := files_scroll.get_v_scroll_bar()
			files_scroll.scroll_vertical = int(report_scroll.max_value - report_scroll.page)
			await _shot("r2_scandal_response_lower")
		quit(0)
		return
	if "--parliament" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		sim0.week = 10
		sim0._tick_parliament()
		main._refresh()
		await _shot("r3a_bill_offer")
		sim0.mesai = 4
		sim0.resolve_decision(0, 0)
		main._refresh()
		main._journal.clear()
		main._on_week(sim0.week)
		main._select_tab(main._journal)
		await _shot("r3a_daily_report")
		if main._mobile:
			main._tabs.current_tab = 2
			main._mobile_report_tabs.current_tab = 2
		else:
			main._divan.open()
		await _shot("r3a_divan_report")
		quit(0)
		return
	if "--parliament-laws" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		sim0.week = 10
		sim0._tick_parliament()
		main._refresh()
		await _shot("r3b_law_offer")
		sim0.pending[0]["event"]["proposal"]["bill"] = "press"
		sim0.parliament_proposals.back()["bill"] = "press"
		sim0.treasury = 60.0
		sim0.private_wealth = 60.0
		sim0.mesai = 4
		sim0.resolve_decision(0, 3)
		main._refresh()
		main._journal.clear()
		main._on_week(sim0.week)
		main._select_tab(main._journal)
		await _shot("r3b_laws_daily")
		if main._mobile:
			main._tabs.current_tab = 2
			main._mobile_report_tabs.current_tab = 2
		else:
			main._divan.open()
		await _shot("r3b_laws_divan")
		quit(0)
		return
	if "--election" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		sim0.week = 58
		var source: Dictionary = {}
		for event: Dictionary in sim0._events:
			if str(event.get("id", "")) == "secim_sonucu":
				source = event
				break
		sim0.pending = [{"event": sim0._prepare_election_result(source), "age": 0}]
		main._refresh()
		await _shot("r3c_election_result")
		sim0.mesai = 4
		sim0.resolve_decision(0, 0)
		main._refresh()
		await _shot("r3c_government_formation")
		sim0.pending.clear()
		sim0.government_pm = "kessler"
		sim0.government_coalition.assign(["royal", "nobles"])
		sim0.parliament_blocs["royal"]["loyalty"] = 0.0
		sim0.parliament_blocs["royal"]["pressure"] = 100.0
		sim0.parliament_blocs["nobles"]["loyalty"] = 0.0
		sim0.parliament_blocs["nobles"]["pressure"] = 100.0
		sim0._queue_confidence_vote()
		main._refresh()
		await _shot("r3c_confidence_vote")
		quit(0)
		return
	if "--army" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		main._journal.clear()
		main._on_week(sim0.week)
		main._select_tab(main._journal)
		await _shot("r5a_daily")
		main._tabs.current_tab = 1
		Input.warp_mouse(Vector2(8, 8))
		main._divan.open()
		await _shot("r5a_divan_report")
		var bar: VScrollBar = main._divan.drawer_scroll.get_v_scroll_bar()
		main._divan.drawer_scroll.scroll_vertical = int(bar.max_value - bar.page)
		await _shot("r5a_commanders")
		quit(0)
		return
	if "--r5b-army" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		sim0.request_army_decision()
		sim0.resolve_decision(0, 0)
		main._refresh()
		await _shot("r5b_action_card")
		sim0.resolve_decision(0, 0)
		main._refresh()
		main._journal.clear()
		main._on_week(sim0.week)
		main._select_tab(main._journal)
		await _shot("r5b_daily_report")
		main._divan.open()
		await _shot("r5b_divan_report")
		var army_bar: VScrollBar = main._divan.drawer_scroll.get_v_scroll_bar()
		main._divan.drawer_scroll.scroll_vertical = int(army_bar.max_value - army_bar.page)
		await _shot("r5b_commander_cards")
		quit(0)
		return
	if "--regions" in OS.get_cmdline_user_args():
		main._instant = true
		sim0.pending.clear()
		main._refresh()
		main._journal.clear()
		main._on_week(sim0.week)
		main._select_tab(main._journal)
		await _shot("r4a_regional_daily")
		if main._mobile:
			main._tabs.current_tab = 1
			(main._person_panel._mobile_group_buttons["state"] as Button).pressed.emit()
			await process_frame
			main._person_panel._mobile_person_scroll.scroll_vertical = 0
			await _shot("r4a_mobile_divan_entry")
			main._divan.tile.pressed.emit()
		else:
			main._divan.open()
		if main._mobile:
			main._divan.drawer_scroll.scroll_vertical = 365
		await _shot("r4a_governors_divan")
		quit(0)
		return
	if "--files-journal" in OS.get_cmdline_user_args():
		main._select_tab(main._files_tab)
		await _shot("files")
		main._select_tab(main._journal)
		await _shot("journal")
		quit(0)
		return
	if "--menu-modals" in OS.get_cmdline_user_args():
		var menu_script: Script = main._menu.get_script()
		for name in ["HOW_TO", "CREDITS"]:
			main._show_modal(main._menu._translate_lines(str(menu_script.get_script_constant_map().get(name, ""))))
			await _shot("modal_" + name)
		main._show_chronicle()
		await _shot("chronicle")
		quit(0)
		return
	if "--dynasty-ledger" in OS.get_cmdline_user_args():
		sim0.dynasty_path = "user://dynasty_ui_test.cfg"
		var cfg := ConfigFile.new()
		cfg.set_value("dynasty", "generations", 2)
		cfg.set_value("dynasty", "score", 208)
		cfg.set_value("dynasty", "eligible", true)
		cfg.set_value("dynasty", "legacy", {"generation": 3, "regime": "medya", "effects": ["treasury_full", "army_loyal", "reign_wear"]})
		cfg.set_value("dynasty", "entries", [
			{"generation": 1, "king": "Adrian IV", "title": "Medya Rejimi", "regime": "Medya Rejimi", "weeks": 104, "score": 124},
			{"generation": 2, "king": "Julian Valerius", "title": "Liyakat Kralı", "regime": "Medya Rejimi", "weeks": 84, "score": 84}])
		cfg.save(sim0.dynasty_path)
		sim0.save_path = "user://dynasty_ui_save_test.txt"
		sim0.ended = true
		main._instant = true
		main._show_menu()
		if not (main._menu.get_meta("dynasty") as Button).visible:
			push_error("Hanedan Devam uygun oyuncuya görünmedi")
			quit(1)
			return
		await _shot("dynasty_home")
		main._menu.show_page("dynasty")
		await _shot("dynasty_ledger")
		var ledger_scroll := main._menu.pages["dynasty"].get_child(1) as ScrollContainer
		var back_button := main._menu.pages["dynasty"].get_child(2) as Button
		if back_button.custom_minimum_size.y < 44 or ("--mobile" in OS.get_cmdline_user_args() and ledger_scroll.get_v_scroll_bar().max_value <= ledger_scroll.get_v_scroll_bar().page):
			push_error("Hanedan defteri mobil kaydırma/44px geri düğmesi kapısı başarısız")
			quit(1)
			return
		DirAccess.remove_absolute(ProjectSettings.globalize_path(sim0.dynasty_path))
		quit(0)
		return
	if "--week-curtain" in OS.get_cmdline_user_args():
		root.get_node("Sfx").short_fx = true
		main._end_week_pressed()
		await create_timer(0.65).timeout
		await _shot("week_curtain")
		main._curtain_skip = true
		for frame in 20: await process_frame
		quit(0)
		return
	if "--u4b" in OS.get_cmdline_user_args():
		main._tabs.current_tab = 0
		for count in [1, 2, 3]:
			sim0.pending.clear()
			for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
				for event in sim0._events:
					if event["id"] == id:
						sim0.pending.append({"event": event, "age": 0})
						break
					if sim0.pending.size() == count:
						break
			main._agenda_view.decision_index = 0
			main._refresh()
			main._scroll.scroll_vertical = 0
			await _shot("u4b_agenda_%d" % count)
		main._tabs.current_tab = 1
		for pair in [["dynasty", "dorn"], ["state", "arden"], ["power", "halden"], ["foreign", "elena"]]:
			(main._person_panel._mobile_group_buttons[pair[0]] as Button).pressed.emit()
			var tap := InputEventMouseButton.new()
			tap.button_index = MOUSE_BUTTON_LEFT
			tap.pressed = true
			main._person_panel._on_card_input(tap, pair[1])
			for frame in 4:
				await process_frame
			main._person_panel._mobile_person_scroll.scroll_vertical = 0
			await _shot("u4b_people_%s" % pair[0])
			var profile_scroll: ScrollContainer = main._person_panel._mobile_person_scroll
			var profile_bar := profile_scroll.get_v_scroll_bar()
			profile_scroll.scroll_vertical = maxi(0, int(profile_bar.max_value - profile_bar.page) - 22)
			await _shot("u4b_people_%s_actions" % pair[0])
		main._tabs.current_tab = 2
		main._mobile_report_tabs.current_tab = 0
		await _shot("u4b_reports")
		quit(0)
		return
	if "--u4" in OS.get_cmdline_user_args():
		main._tabs.current_tab = 0
		await _shot("u4_agenda")
		sim0.pending.clear()
		for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
			for event in sim0._events:
				if event["id"] == id:
					sim0.pending.append({"event": event, "age": 0})
					break
		main._agenda_view.decision_index = 0
		main._refresh()
		await _shot("u4_agenda_3")
		main._scroll.scroll_vertical = int(main._scroll.get_v_scroll_bar().max_value)
		await _shot("u4_agenda_queue")
		main._tabs.current_tab = 1
		for key in ["dynasty", "state", "power", "foreign"]:
			(main._person_panel._mobile_group_buttons[key] as Button).pressed.emit()
			for frame in 2:
				await process_frame
			await _shot("u4_people_" + key)
		(main._person_panel._mobile_group_buttons["state"] as Button).pressed.emit()
		await process_frame
		var tap := InputEventMouseButton.new()
		tap.button_index = MOUSE_BUTTON_LEFT
		tap.pressed = true
		main._person_panel._on_card_input(tap, "arden")
		await _shot("u4_people_selected")
		main._person_panel._mobile_person_scroll.scroll_vertical = 85
		await _shot("u4_people_selected_actions")
		main._tabs.current_tab = 2
		main._mobile_report_tabs.current_tab = 0
		await _shot("u4_reports")
		var report_scroll := main._report_box.get_parent() as ScrollContainer
		report_scroll.scroll_vertical = int(report_scroll.get_v_scroll_bar().max_value)
		await _shot("u4_reports_list")
		main._select_tab(main._files_tab)
		await _shot("u4_files")
		main._select_tab(main._journal)
		await _shot("u4_journal")
		quit(0)
		return
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
	if "--u1b" in OS.get_cmdline_user_args():
		main._sel.clear()
		main._sel.append("elena")
		main._style_cards()
		main._update_info()
		main._divan.open()
		await main._divan.motion.finished
		for frame in 8:
			await process_frame
		var screen := main.get_viewport_rect()
		var dr: Rect2 = main._divan.drawer.get_global_rect()
		var cr: Rect2 = main._divan.focus_button.get_global_rect()
		print("U1B BOUNDS window=", DisplayServer.window_get_size(), " viewport=", screen.size, " drawer=", dr, " close=", cr)
		if dr.position.x < -1 or dr.end.x > screen.end.x + 1 or cr.position.x < dr.position.x or cr.end.x > screen.end.x + 1:
			printerr("U1B BOUNDS: FAIL")
			quit(1)
			return
		await _shot("u1b_divan")
		quit(0)
		return
	var u2_count := 0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--u2="):
			u2_count = int(arg.substr(5))
	if u2_count > 0:
		sim0.week = 8
		if "--u2-week-log" in OS.get_cmdline_user_args():
			main._week_log_week = sim0.week
			main._week_log.clear()
			for text in ["The General reviewed the appointment.", "The palace received the signed report.", "The ministers recorded their response.", "The court awaits the next decision."]:
				main._week_log.append(text)
		sim0.pending.clear()
		for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
			for event in sim0._events:
				if event["id"] == id:
					sim0.pending.append({"event": event, "age": 0})
					break
			if sim0.pending.size() == u2_count:
				break
		main._agenda_view.decision_index = 0
		main._refresh()
		main._on_flow("gundem")
		await _shot("u2_%d_karar" % u2_count)
		var bar: VScrollBar = main._scroll.get_v_scroll_bar()
		var overflow := bar.max_value - bar.page
		print("U2 SCROLL ", u2_count, ": ", overflow)
		main._agenda_view.show_decision(u2_count - 1)
		await _shot("u2_%d_son_karar" % u2_count)
		if main._agenda_view.reasons_button != null:
			main._agenda_view.reasons_button.toggled.emit(true)
			await _shot("u2_%d_gerekceler" % u2_count)
		quit(1 if overflow > 2 and not main._mobile else 0)
		return
	var u3_state := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--u3="):
			u3_state = arg.substr(5)
	if u3_state != "":
		sim0.week = 8
		sim0.pending.clear()
		for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
			for event in sim0._events:
				if event["id"] == id:
					sim0.pending.append({"event": event, "age": 0})
		main._agenda_view.decision_index = 0
		if u3_state == "enemy":
			sim0.actors["voss"].moved = true
			main._sel.clear()
			main._sel.append("voss")
		elif u3_state == "selected":
			main._sel.clear()
			main._sel.append("arden")
		main._refresh()
		main._style_cards()
		main._update_info()
		main._on_flow("gundem")
		if u3_state == "reports":
			for child in main._report_box.find_children("*", "Control", true, false):
				if child is Button and ((child as Button).text.begins_with("Tüm raporlar") or (child as Button).text.begins_with("All reports")):
					(child as Button).pressed.emit()
					break
		await _shot("u3_" + u3_state)
		quit(0)
		return
	if "--u1" in OS.get_cmdline_user_args() and "--mobile" not in OS.get_cmdline_user_args():
		main._sel.clear()
		main._refresh()
		await _shot("u1_serit")
		main._divan.open()
		await _shot("u1_divan")
		main._instant = true
		main._divan.close()
		main._instant = false
		main._sel.clear()
		main._sel.append("elena")
		main._style_cards()
		main._update_info()
		main._divan.refresh()
		await _shot("u1_kisi_secili")
		quit(0)
		return
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
		var outside := InputEventMouseButton.new()
		outside.position = Vector2(24, 400)
		outside.global_position = outside.position
		outside.button_index = MOUSE_BUTTON_LEFT
		outside.pressed = true
		root.push_input(outside, true)
		await process_frame
		await _shot("1_adliye_dis_tiklama_kapali")
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
