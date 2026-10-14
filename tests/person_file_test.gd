extends SceneTree

var main: Control


func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_mobile", "--mobile" in OS.get_cmdline_user_args())
	if "--mobile" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1067, 600))
	else:
		DisplayServer.window_set_size(Vector2i(1600, 900))
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


func _inside(outer: Rect2, inner: Rect2) -> bool:
	return outer.has_point(inner.position) and outer.has_point(inner.end - Vector2.ONE)


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
	if not main._person_file.sheet.is_ancestor_of(main._portrait_box) or not main._person_file.sheet.is_ancestor_of(main._person_panel.actions_panel):
		_fail("portrait or existing action table was not moved into the shared dossier")
		return
	var sheet_rect: Rect2 = main._person_file.sheet.get_global_rect()
	var close_rect: Rect2 = main._person_file._close_button.get_global_rect()
	if close_rect.position.y > sheet_rect.position.y + sheet_rect.size.y * 0.2 or close_rect.position.x < sheet_rect.position.x + sheet_rect.size.x * 0.65:
		_fail("close control is not in the paper header")
		return
	var register := main._person_file.sheet.find_child("DossierRegister", true, false) as Control
	if not _inside(sheet_rect, register.get_global_rect()):
		_fail("metadata text is outside the paper register")
		return
	var dim_layer := main._person_file.overlay.get_node("PersonFileShade") as ColorRect
	if dim_layer.color.a > 0.55:
		_fail("the background dim layer is too dark")
		return
	if not main._mobile:
		var heading := main._person_file.sheet.find_child("DossierHeading", true, false) as Control
		if not _inside(sheet_rect, heading.get_global_rect()) or heading.size.y > 110.0 * main._person_file._paper_scale:
			_fail("paper heading exceeds its measured header strip")
			return
		var paper := main._person_file.sheet.find_child("PaperTexture", true, false) as TextureRect
		var paper_image := paper.texture.get_image()
		if paper_image.get_pixel(0, 0).a > 0.05 or paper_image.get_pixel(750, 500).a < 0.9:
			_fail("the paper outside edge is opaque or the paper itself was clipped")
			return
		if paper_image.get_pixel(400, 400).get_luminance() < 0.3 or paper_image.get_pixel(400, 550).get_luminance() < 0.3 or paper_image.get_pixel(1000, 375).get_luminance() < 0.3 or paper_image.get_pixel(1000, 500).get_luminance() < 0.55 or paper_image.get_pixel(1000, 630).get_luminance() < 0.55 or paper_image.get_pixel(1000, 770).get_luminance() < 0.55:
			_fail("printed separators or action bars still cross the text area")
			return
		var left_check := main._person_file.sheet.find_child("ObservationsScroll", true, false) as ScrollContainer
		if left_check.position.x < 240.0 * main._person_file._paper_scale:
			_fail("the left column reaches the printed pen and crest margin")
			return
		var left_content := left_check.get_child(0) as VBoxContainer
		for i in left_content.get_child_count():
			var sibling := left_content.get_child(i) as Control
			if sibling.name != "DossierSectionDivider":
				continue
			if i > 0 and sibling.get_global_rect().intersects((left_content.get_child(i - 1) as Control).get_global_rect()):
				_fail("a section divider overlaps the preceding text block")
				return
			if i + 1 < left_content.get_child_count() and sibling.get_global_rect().intersects((left_content.get_child(i + 1) as Control).get_global_rect()):
				_fail("a section divider overlaps the following text block")
				return
	for key in ["A", "B", "C", "D", "E", "F"]:
		var heading := main._person_file.sheet.find_child("DossierGroup" + key, true, false) as Label
		var band := main._person_file.sheet.find_child("DossierActionBand" + key, true, false) as PanelContainer
		var rows := main._person_file.sheet.find_child("DossierRows" + key, true, false) as VBoxContainer
		if heading == null or band == null or rows == null or rows.get_child_count() == 0:
			_fail("dossier action group is missing: " + key)
			return
		if key == "E" and not heading.text.contains("/"):
			_fail("the general action group is not identified in its band")
			return
		if not main._mobile and not (band.get_theme_stylebox("panel") as StyleBoxFlat).bg_color.is_equal_approx(Color("392615")):
			_fail("action group band is not drawn in the paper's brown and cream style: " + key)
			return
		var previous_bottom := -INF
		for action_node in rows.get_children():
			var action_rect: Rect2 = (action_node as Control).get_global_rect()
			if action_rect.position.y < previous_bottom - 1.0:
				_fail("action rows overlap in group " + key)
				return
			previous_bottom = action_rect.end.y
	for field in [main._person_file._meta_name, main._person_file._meta_title, main._person_file._meta_power, main._person_file._meta_attitude]:
		if not _inside(register.get_global_rect(), field.get_global_rect()):
			_fail("metadata text crosses the printed register boundary")
			return
	if main._mobile:
		if register.get_parent().name != "DossierPhotoRow":
			_fail("mobile metadata wastes a separate row beside the portrait")
			return
		var photo: Rect2 = main._person_file._photo_slot.get_global_rect()
		if register.get_global_rect().position.x < photo.end.x + 10.0:
			_fail("mobile portrait overlaps the metadata column: photo=%s register=%s" % [str(photo), str(register.get_global_rect())])
			return
		var scroll := main._person_file.sheet.find_child("PersonFileScroll", true, false) as ScrollContainer
		if scroll == null or main._person_file.sheet.anchor_left != 0.0 or main._person_file.sheet.anchor_top != 0.0 or main._person_file.sheet.anchor_right != 1.0 or main._person_file.sheet.anchor_bottom != 1.0 or scroll.get_global_rect().end.y > root.get_visible_rect().end.y:
			_fail("mobile dossier is not a full-screen single-column page")
			return
		for node in main._person_panel.actions_panel.find_children("*", "Button", true, false):
			if (node as Button).custom_minimum_size.y < 44:
				_fail("mobile dossier action target is smaller than 44 px")
				return
		if main._person_file._close_button.custom_minimum_size.x < 44 or main._person_file._close_button.custom_minimum_size.y < 44:
			_fail("mobile dossier close target is smaller than 44 px")
			return
		for node in main._person_panel.actions_panel.find_children("*", "Button", true, false):
			var action := node as Button
			if action.find_child("DossierActionText", false, false) == null:
				continue
			var title := action.get_node("DossierActionText") as Label
			var effect := action.get_node("DossierActionEffect") as Label
			if title.text.contains("…") or effect.text.contains("…") or effect.text.is_empty():
				_fail("action title or complete effect is truncated: " + action.name)
				return
			if effect.text != main._person_panel._dossier_action_effect(action):
				_fail("action effect differs from its complete source: " + action.name)
				return
			if not scroll.is_ancestor_of(action):
				_fail("mobile action is not reachable in the dossier scroll: " + action.name)
				return
			scroll.ensure_control_visible(action)
			await _frames(3)
			var bottom_gap: float = scroll.get_global_rect().end.y - action.get_global_rect().end.y
			if bottom_gap < 2.0:
				scroll.scroll_vertical += ceili(2.0 - bottom_gap)
				await _frames(3)
			if not _inside(scroll.get_global_rect(), action.get_global_rect()):
				_fail("mobile action row cannot be scrolled into view: %s scroll=%s row=%s value=%d max=%d" % [action.name, str(scroll.get_global_rect()), str(action.get_global_rect()), scroll.scroll_vertical, int(scroll.get_v_scroll_bar().max_value)])
				return
			var action_text := action.get_node("DossierActionText") as Label
			var action_effect := action.get_node("DossierActionEffect") as Label
			if action_text.get_minimum_size().y > action_text.size.y + 1 or action_effect.get_minimum_size().y > action_effect.size.y + 1:
				_fail("mobile action text overflows its reachable row: " + action.name)
				return
		if not main._person_file.sheet.find_child("DossierScrollHint", true, false).visible:
			_fail("mobile action list has no scroll hint")
			return
	else:
		var left := main._person_file.sheet.find_child("ObservationsScroll", true, false) as ScrollContainer
		var right := main._person_file.sheet.find_child("ActionsScroll", true, false) as ScrollContainer
		if right.get_v_scroll_bar().max_value <= 0:
			_fail("desktop action list has no scroll range for groups D–F")
			return
		if not _inside(sheet_rect, left.get_global_rect()) or not _inside(sheet_rect, right.get_global_rect()):
			_fail("paper text columns extend outside the paper surface: sheet=%s left=%s right=%s" % [str(sheet_rect), str(left.get_global_rect()), str(right.get_global_rect())])
			return
		if left.get_global_rect().end.x >= right.get_global_rect().position.x:
			_fail("paper text columns overlap")
			return
		var hint := main._person_file.sheet.find_child("DossierScrollHint", true, false) as Control
		if hint == null or not hint.visible:
			_fail("scrollable action list has no visible scroll hint")
			return
		for node in main._person_panel.actions_panel.find_children("*", "Button", true, false):
			var action := node as Button
			if action.find_child("DossierActionText", false, false) == null:
				continue
			var title := action.get_node("DossierActionText") as Label
			var effect := action.get_node("DossierActionEffect") as Label
			if title.text.contains("…") or effect.text.contains("…") or effect.text.is_empty():
				_fail("action title or complete effect is truncated: " + action.name)
				return
			if effect.text != main._person_panel._dossier_action_effect(action):
				_fail("action effect differs from its complete source: " + action.name)
				return
			if not right.is_ancestor_of(action):
				_fail("action is not reachable in the paper action column: " + action.name)
				return
			right.ensure_control_visible(action)
			await _frames(1)
			if not _inside(right.get_global_rect(), action.get_global_rect()):
				_fail("action row cannot be scrolled into view: " + action.name)
				return
			var action_text := action.get_node("DossierActionText") as Label
			var action_effect := action.get_node("DossierActionEffect") as Label
			if action_text.get_minimum_size().y > action_text.size.y + 1 or action_effect.get_minimum_size().y > action_effect.size.y + 1:
				_fail("paper action text overflows its row: " + action.name)
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
