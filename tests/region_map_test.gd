extends SceneTree
## Region map layer, panel handoff and original institution hit targets.

var ok := true
var sim: Node


func _initialize() -> void:
	if "--mobile" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1067, 600))
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	_run.call_deferred()


func _expect(value: bool, message: String) -> void:
	if not value:
		printerr("REGION MAP: ", message)
		ok = false


func _run() -> void:
	await process_frame
	sim = root.get_node("Sim")
	var main := (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	sim.new_game(101, 0)
	sim.week = 12
	sim.pending.clear()
	var rng_before: int = sim.rng.state
	var unrest_before: float = sim.unrest
	var economy_before: float = sim.economy
	main._refresh()
	var city = main._city
	city.open()
	for i in 3: await process_frame
	_expect(city.plates.size() == city.SITES.size(), "institution plates were not built")
	_expect(city._region_buttons.size() == 4, "four region markers were not built")
	_expect(city._legend_button.custom_minimum_size == Vector2(44, 44) and city._legend_button.focus_mode == Control.FOCUS_ALL, "map legend control is not touch/keyboard accessible")
	city._legend_button.pressed.emit()
	await process_frame
	_expect(city._drawer.visible and (city._drawer_body.get_child(0) as Label).text == tr("Harita simgeleri"), "map legend did not open")
	_expect(city._drawer_body.get_child_count() == 7, "map legend entries are incomplete")
	city._unhandled_key_input(_escape())
	await process_frame
	for id in city._region_buttons:
		_expect(not city._region_buttons[id].visible, "region markers should start hidden")
	city._region_toggle.button_pressed = true
	city._region_toggle.toggled.emit(true)
	await process_frame
	for id in city._region_buttons:
		var marker: Button = city._region_buttons[id]
		_expect(marker.visible and marker.focus_mode == Control.FOCUS_ALL, "region marker is not visible/focusable: " + str(id))
		_expect(marker.custom_minimum_size.x >= 44.0 and marker.custom_minimum_size.y >= 44.0, "region marker is below 44 px: " + str(id))
		var marker_name: Label = marker.find_child("RegionName", true, false)
		if city.mobile and str(id) == "capital":
			_expect(marker_name.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and marker_name.custom_minimum_size.y >= 28.0,
				"mobile Capital Region marker wraps without clipping")
		_expect(not marker_name.text.contains("★"), "region names must not use a symbol glyph")
		_expect(bool(marker.get_meta("featured")) == (str(id) == sim.featured_region_id()),
			"map does not match the featured region highlight: " + str(id))
		for site_id in city.plates:
			var site: Control = city.plates[site_id]
			_expect(not marker.get_global_rect().intersects(site.get_global_rect()), "region marker occludes institution: " + str(id) + " / " + str(site_id))
	city._region_buttons["industry"].pressed.emit()
	await process_frame
	_expect(city._region_panel_id == "industry" and city._drawer.visible, "region click did not open its panel")
	_expect(city._drawer_body.find_child("GovernorPortrait", true, false) != null, "governor portrait missing")
	_expect(city._region_action_button.visible and city._region_action_button.focus_mode == Control.FOCUS_ALL, "regional action entry is missing")
	for marker: Button in city._region_buttons.values():
		_expect(not marker.visible, "covered region markers remain visible behind the open panel")
	var status_found := false
	for child in city._drawer_body.find_children("*", "RichTextLabel", true, false):
		if (child as RichTextLabel).text.contains("pazar") and (child as RichTextLabel).text.contains("bağlılık"):
			status_found = true
	_expect(status_found, "region panel lacks qualitative market/loyalty status")
	(city._drawer_body.get_child(city._drawer_body.get_child_count() - 1) as Button).pressed.emit()
	await process_frame
	for marker: Button in city._region_buttons.values():
		_expect(marker.visible, "region markers did not return after closing the panel")
	_expect(sim.rng.state == rng_before and sim.unrest == unrest_before and sim.economy == economy_before,
		"map interaction changed simulation state")
	city.show_region("industry")
	await process_frame
	city._region_action_button.pressed.emit()
	await process_frame
	_expect(not city.visible and not sim.pending.is_empty(), "region action did not return to the decision queue")
	if not sim.pending.is_empty():
		var ev: Dictionary = sim.pending[0]["event"]
		var region_matches := false
		for choice: Dictionary in ev.get("choices", []):
			region_matches = region_matches or str(choice.get("region", "")) == "industry"
		_expect(str(ev.get("kind", "")) == "regional_action" and region_matches, "wrong region action decision queued")
		_expect(not sim.region_has_pending_crisis("industry"), "ordinary region decision counted as crisis")
	sim.pending.clear()
	city.open()
	for i in 3: await process_frame
	_click_at(city.plates["parlamento"].get_global_rect().get_center())
	await process_frame
	var site_title := false
	for label in city._drawer_body.find_children("*", "Label", true, false):
		site_title = site_title or (label as Label).text == tr("PARLAMENTO")
	_expect(city._drawer.visible and city._region_panel_id == "" and site_title, "parliament institution click was broken")
	city._unhandled_key_input(_escape())
	_expect(not city._drawer.visible, "Escape did not close the institution panel")
	main.free()
	print("REGION MAP: OK" if ok else "REGION MAP: FAILED")
	quit(0 if ok else 1)


func _escape() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	return event


func _click_at(pos: Vector2) -> void:
	var click := InputEventMouseButton.new()
	click.position = pos
	click.global_position = pos
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	root.push_input(click, true)
	click.pressed = false
	root.push_input(click, true)
