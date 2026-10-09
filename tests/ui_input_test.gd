extends SceneTree

var main: Control

func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()

func _run() -> void:
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
	var report: Control = main._report_box.get_child(1)
	var expected := str(root.get_node("Sim").reports[0]["source"])
	_click_at(report.get_global_rect().get_center())
	await process_frame
	if main._sel != [expected]:
		printerr("UI INPUT: rapordan kişi seçilemedi: ", main._sel)
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
