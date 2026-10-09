extends SceneTree

var main: Control

func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()

func _run() -> void:
	if "--mobile" in OS.get_cmdline_user_args():
		await _run_mobile()
		return
	for i in 20:
		await process_frame
	main._on_flow("gundem")
	for i in 5:
		await process_frame
	var card: Control = main._cards.values()[0]
	var pos := card.get_global_rect().get_center()
	_click_at(pos)
	await process_frame
	if main._sel != ["arden"]:
		printerr("UI INPUT: kişi kartı seçilemedi: ", main._sel)
		quit(1)
		return
	main._sel.clear()
	var expected := str(root.get_node("Sim").reports[0]["source"])
	var report: Control
	for child in main._report_box.get_children():
		if child is PanelContainer and child.has_meta("report_id"):
			report = child
			break
	_click_at(report.get_global_rect().get_center())
	await process_frame
	if main._sel != [expected]:
		printerr("UI INPUT: rapordan kişi seçilemedi: ", main._sel)
		quit(1)
		return
	for child in main._report_box.get_children():
		if child is Button and ((child as Button).text.begins_with("Tüm raporlar") or (child as Button).text.begins_with("All reports")):
			(child as Button).pressed.emit()
			break
	await process_frame
	if not main._all_reports_popup.visible:
		printerr("UI INPUT: tüm raporlar kaplaması açılmadı")
		quit(1)
		return
	var full_list := main._all_reports_popup.get_child(0).get_child(0) as VBoxContainer
	if full_list.get_child_count() != root.get_node("Sim").reports.size():
		printerr("UI INPUT: tüm raporlar listesi eksik")
		quit(1)
		return
	(full_list.get_child(0) as Button).pressed.emit()
	await process_frame
	if main._all_reports_popup.visible or main._sel != [expected]:
		printerr("UI INPUT: kaplamadan rapor seçilemedi")
		quit(1)
		return
	_click_at(main._person_panel.clear_button.get_global_rect().get_center())
	await process_frame
	if not main._sel.is_empty() or main._person_panel.person_block.visible or not main._person_panel.selection_hint.visible:
		printerr("UI INPUT: X seçimi kaldıramadı")
		quit(1)
		return
	_click_at(main._cards["arden"].get_global_rect().get_center())
	var selection_escape := InputEventKey.new()
	selection_escape.keycode = KEY_ESCAPE
	selection_escape.pressed = true
	root.push_input(selection_escape, true)
	await process_frame
	if not main._sel.is_empty() or main._person_panel.person_block.visible:
		printerr("UI INPUT: Esc seçimi kaldıramadı")
		quit(1)
		return
	main._instant = true
	main._divan.open()
	await process_frame
	_click_at(main._cards["elena"].get_global_rect().get_center())
	await process_frame
	if main._divan.opened or main._sel != ["elena"]:
		printerr("UI INPUT: Divan'dan kişi seçilemedi")
		quit(1)
		return
	main._divan.open()
	_click_at(Vector2(20, 300))
	await process_frame
	if main._divan.opened:
		printerr("UI INPUT: dış tıklama Divan'ı kapatmadı")
		quit(1)
		return
	main._divan.open()
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape, true)
	await process_frame
	if main._divan.opened:
		printerr("UI INPUT: Esc Divan'ı kapatmadı")
		quit(1)
		return
	var first := str(main._divan.visible_ids[0])
	var one := InputEventKey.new()
	one.keycode = KEY_1
	one.pressed = true
	root.push_input(one, true)
	await process_frame
	if main._sel != [first]:
		printerr("UI INPUT: şerit kısayolu seçemedi")
		quit(1)
		return
	main._divan.open()
	await process_frame
	_click_at(main._divan.group_buttons[0].get_global_rect().get_center())
	await process_frame
	if main._divan.groups[0].visible:
		printerr("UI INPUT: Divan grubu katlanmadı")
		quit(1)
		return
	main._divan.close()
	main._divan.open()
	if main._divan.groups[0].visible:
		printerr("UI INPUT: Divan grup durumu korunmadı")
		quit(1)
		return
	main._divan.close()
	var sim: Node = root.get_node("Sim")
	sim.pending.clear()
	for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
		for event in sim._events:
			if event["id"] == id:
				sim.pending.append({"event": event, "age": 0})
				break
	main._agenda_view.decision_index = 0
	main._refresh()
	main._tabs.current_tab = 0
	await process_frame
	if main._decision_cards.size() != 1 or main._decision_buttons.size() != sim.pending[0]["event"]["choices"].size():
		printerr("UI INPUT: tek karar kartı kurulmadı")
		quit(1)
		return
	for child in main._agenda.get_children():
		if child is Button and child.text.begins_with("Sırada"):
			child.pressed.emit()
			break
	await process_frame
	if main._agenda_view.decision_index != 1:
		printerr("UI INPUT: Sırada satırı kararı değiştirmedi")
		quit(1)
		return
	_click_at(main._agenda_view.reasons_button.get_global_rect().get_center())
	await process_frame
	if not main._agenda_view.reasons_button.button_pressed:
		printerr("UI INPUT: Gerekçeler açılmadı")
		quit(1)
		return
	var right := InputEventKey.new()
	right.keycode = KEY_RIGHT
	right.pressed = true
	root.push_input(right, true)
	await process_frame
	if main._agenda_view.decision_index != 2:
		printerr("UI INPUT: sağ ok kararı değiştirmedi")
		quit(1)
		return
	_click_at(main._agenda_view.nav_buttons[0].get_global_rect().get_center())
	await process_frame
	if main._agenda_view.decision_index != 1:
		printerr("UI INPUT: sol düğme kararı değiştirmedi")
		quit(1)
		return
	main._decision_buttons[0].pressed.emit()
	await process_frame
	if sim.pending.size() != 2:
		printerr("UI INPUT: seçili karar çözülmedi")
		quit(1)
		return
	print("UI INPUT: OK")
	quit(0)


func _run_mobile() -> void:
	for i in 20:
		await process_frame
	if main._tabs.get_tab_count() != 3 or main._tabs.get_tab_title(0) != tr("Gündem") or main._tabs.get_tab_title(1) != tr("Kişiler") or main._tabs.get_tab_title(2) != tr("Raporlar"):
		printerr("UI INPUT: mobil ana sekmeler hatalı")
		quit(1)
		return
	var expected := {"dynasty": ["dorn", "prens", "julian"], "state": ["arden", "voss", "kessler", "falk"], "power": ["halden", "lena", "brandt"], "foreign": ["elena", "claire", "malenkov", "lucien"]}
	main._tabs.current_tab = 1
	for key in expected:
		(main._person_panel._mobile_group_buttons[key] as Button).pressed.emit()
		await process_frame
		for id in expected[key]:
			if not main._cards.has(id) or main._cards[id].get_parent() != main._person_panel._mobile_card_row:
				printerr("UI INPUT: mobil grup kişiyi göstermedi: ", key, " / ", id)
				quit(1)
				return
	if main._cards.size() != 14:
		printerr("UI INPUT: mobil kişi erişimi eksik: ", main._cards.size())
		quit(1)
		return
	for tab in main._person_panel._mobile_group_buttons.values():
		if (tab as Button).custom_minimum_size.x < 44 or (tab as Button).custom_minimum_size.y < 44:
			printerr("UI INPUT: mobil grup sekmesi hedefi 44 px altında")
			quit(1)
			return
	for button in main._cat_btns.values():
		if (button as Button).custom_minimum_size.y < 44:
			printerr("UI INPUT: mobil eylem sekmesi hedefi 44 px altında")
			quit(1)
			return
	for button in main._buttons.values():
		if (button as Button).custom_minimum_size.y < 44:
			printerr("UI INPUT: mobil eylem düğmesi hedefi 44 px altında")
			quit(1)
			return
	if main._person_panel.clear_button.custom_minimum_size.x < 44 or main._person_panel.clear_button.custom_minimum_size.y < 44:
		printerr("UI INPUT: mobil seçim temizleme hedefi 44 px altında")
		quit(1)
		return
	var scroll := main._person_panel._mobile_card_row.get_parent() as ScrollContainer
	if scroll == null or scroll.get_parent().get_child_count() != 3:
		printerr("UI INPUT: yatay kişi şeridi/okları kurulmadı")
		quit(1)
		return
	var strip := scroll.get_parent() as HBoxContainer
	var left_arrow := strip.get_child(0) as Button
	var right_arrow := strip.get_child(2) as Button
	if left_arrow.custom_minimum_size.x < 44 or right_arrow.custom_minimum_size.x < 44:
		printerr("UI INPUT: mobil şerit oku hedefi 44 px altında")
		quit(1)
		return
	main._cards["elena"].custom_minimum_size.x = 1000
	for i in 2:
		await process_frame
	right_arrow.pressed.emit()
	await process_frame
	if scroll.scroll_horizontal <= 0:
		printerr("UI INPUT: mobil şerit sağ oku kaydırmadı")
		quit(1)
		return
	left_arrow.pressed.emit()
	await process_frame
	if scroll.scroll_horizontal != 0:
		printerr("UI INPUT: mobil şerit sol oku başa dönmedi")
		quit(1)
		return
	main._cards["elena"].custom_minimum_size.x = 150
	var tap := InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = true
	main._person_panel._on_card_input(tap, "elena")
	if main._sel != ["elena"] or not main._person_panel.person_block.visible or main._person_panel._mobile_group != "foreign":
		printerr("UI INPUT: mobil kişi seçimi bloğu açmadı")
		quit(1)
		return
	main._person_panel.clear_button.pressed.emit()
	await process_frame
	if not main._sel.is_empty() or main._person_panel.person_block.visible:
		printerr("UI INPUT: mobil seçim temizlenmedi")
		quit(1)
		return
	var sim: Node = root.get_node("Sim")
	sim.pending.clear()
	for id in ["gida_protestosu", "general_atamalari", "gazeteci_ihale"]:
		for event in sim._events:
			if event["id"] == id:
				sim.pending.append({"event": event, "age": 0})
				break
	main._agenda_view.decision_index = 0
	main._refresh()
	main._tabs.current_tab = 0
	await process_frame
	var queued := 0
	var queue_button: Button
	for child in main._agenda.get_children():
		if child is Button and (child as Button).text.begins_with("Sırada"):
			queued += 1
			if queue_button == null:
				queue_button = child
	if main._decision_cards.size() != 1 or queued != 2:
		printerr("UI INPUT: mobil karar sırası tek kart/iki satır değil: ", main._decision_cards.size(), " / ", queued)
		quit(1)
		return
	queue_button.pressed.emit()
	await process_frame
	if main._agenda_view.decision_index != 1:
		printerr("UI INPUT: mobil Sırada satırı karar değiştirmedi")
		quit(1)
		return
	main._agenda_view.reasons_button.button_pressed = true
	main._agenda_view.reasons_button.toggled.emit(true)
	await process_frame
	if not main._agenda_view.reasons_button.button_pressed:
		printerr("UI INPUT: mobil Gerekçeler açılmadı")
		quit(1)
		return
	main._select_tab(main._files_tab)
	if main._tabs.current_tab != 2 or main._mobile_report_tabs.current_tab != 1:
		printerr("UI INPUT: Dosyalar sekmesine ulaşılamadı")
		quit(1)
		return
	main._select_tab(main._journal)
	if main._tabs.current_tab != 2 or main._mobile_report_tabs.current_tab != 2:
		printerr("UI INPUT: Günlük sekmesine ulaşılamadı")
		quit(1)
		return
	main._select_tab(main._mobile_reports_page)
	var all_reports: Button
	for child in main._report_box.get_children():
		if child is Button and ((child as Button).text.begins_with("Tüm raporlar") or (child as Button).text.begins_with("All reports")):
			all_reports = child
			break
	if all_reports == null or all_reports.custom_minimum_size.y < 44:
		printerr("UI INPUT: mobil tam rapor listesi düğmesi yok ya da küçük")
		quit(1)
		return
	all_reports.pressed.emit()
	await process_frame
	var full_list := main._all_reports_popup.get_child(0).get_child(0) as VBoxContainer
	if not main._all_reports_popup.visible or full_list.get_child_count() != sim.reports.size():
		printerr("UI INPUT: mobil tam rapor listesi açılamadı ya da eksik")
		quit(1)
		return
	main._all_reports_popup.hide()
	print("UI INPUT: OK (mobile)")
	quit(0)

func _click_at(pos: Vector2) -> void:
	var move := InputEventMouseMotion.new()
	move.position = pos
	move.global_position = pos
	root.push_input(move, true)
	var click := InputEventMouseButton.new()
	click.position = pos
	click.global_position = pos
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	root.push_input(click, true)
	click.pressed = false
	root.push_input(click, true)
