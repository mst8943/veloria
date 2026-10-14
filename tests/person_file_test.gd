extends SceneTree

var main: Control


func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_mobile", "--mobile" in OS.get_cmdline_user_args())
	if "--mobile" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1067, 600))
	_boot.call_deferred()


func _boot() -> void:
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await _frames(24)
	_run()


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _fail(reason: String) -> void:
	printerr("PERSON FILE: ", reason)
	quit(1)


func _run() -> void:
	var sim := root.get_node("Sim")
	var tr_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/person_files.json"))
	var en_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/en/person_files.json"))
	if tr_data.size() < 22 or en_data.size() < 22:
		_fail("localized dossier coverage is below 22 entries")
		return
	for id in sim.actors:
		if not tr_data.has(id) or not en_data.has(id) or tr_data[id].get("observations", []).is_empty() or en_data[id].get("observations", []).is_empty():
			_fail("missing localized observation for " + str(id))
			return
	main._open_person_file("voss")
	await _frames(2)
	if not main._person_file.is_open() or main._sel != ["voss"]:
		_fail("person card did not open the selected dossier")
		return
	if not main._person_file.sheet.is_ancestor_of(main._person_panel.profile_panel) or not main._person_file.sheet.is_ancestor_of(main._person_panel.actions_panel):
		_fail("profile or action table was not moved into the shared dossier")
		return
	if main._mobile:
		var scroll := main._person_file.sheet.find_child("PersonFileScroll", true, false) as ScrollContainer
		if scroll == null or main._person_file.sheet.anchor_left != 0.0 or main._person_file.sheet.anchor_top != 0.0 or main._person_file.sheet.anchor_right != 1.0 or main._person_file.sheet.anchor_bottom != 1.0 or scroll.get_global_rect().end.y > root.get_visible_rect().end.y:
			_fail("mobile dossier is not a full-screen single-column page")
			return
		for node in main._person_panel.actions_panel.find_children("*", "Button", true, false):
			if (node as Button).custom_minimum_size.y < 44:
				_fail("mobile dossier action target is smaller than 44 px")
				return
	var actor = sim.actors["voss"]
	actor.known_weak = false
	actor.known_red = false
	main._person_panel._update_info()
	var blackmail := main._buttons["blackmail"] as Button
	if not blackmail.disabled or main._person_file._weak_value.text.contains(actor.weak_point) or main._person_file._red_value.text.contains(actor.red_line):
		_fail("hidden information leaked or locked action stayed active")
		return
	sim.mesai = 3
	main._person_panel._update_action_states()
	var summon := main._buttons["summon"] as Button
	if summon.disabled:
		_fail("available action was unexpectedly locked")
		return
	var time_before: int = sim.mesai
	summon.pressed.emit()
	await _frames(2)
	if sim.mesai >= time_before or not main._person_file.is_open():
		_fail("action did not spend court time or closed the dossier")
		return
	var tap := InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = true
	main._person_file._close_button.pressed.emit()
	main._multi_btn.button_pressed = true
	main._sel.clear()
	main._sel.append("voss")
	main._on_card_input(tap, "elena")
	if main._person_file.is_open() or main._sel.size() != 2 or not main._person_panel.operation_bar.visible:
		_fail("multi-select opened a dossier or hid operation controls")
		return
	main._sel.clear()
	main._multi_btn.button_pressed = false
	main._person_panel._sync_operation_bar()
	main._open_person_file("elena")
	var shade := main._person_file.overlay.get_node("PersonFileShade") as ColorRect
	var outside := InputEventMouseButton.new()
	outside.button_index = MOUSE_BUTTON_LEFT
	outside.pressed = true
	shade.gui_input.emit(outside)
	if main._person_file.is_open():
		_fail("outside click did not close the dossier")
		return
	main._open_person_file("elena")
	main._person_file._close_button.pressed.emit()
	if main._person_file.is_open():
		_fail("close button did not close the dossier")
		return
	print("PERSON FILE: OK (mobile)" if main._mobile else "PERSON FILE: OK")
	quit(0)
