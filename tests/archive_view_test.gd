extends SceneTree

const Loc := preload("res://game/core/loc.gd")
var main: Control
var sim: Node
var archive: Control


func _initialize() -> void:
	var mobile := "--mobile" in OS.get_cmdline_user_args()
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_intro", true)
	ProjectSettings.set_setting("veloria/dev_mobile", mobile)
	DisplayServer.window_set_size(Vector2i(1067, 600) if mobile else Vector2i(1600, 900))
	_boot.call_deferred()


func _boot() -> void:
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	sim = root.get_node("Sim")
	sim.set("chronicle_path", "user://archive_view_test.txt")
	await _frames(20)
	_run()


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _fail(reason: String) -> void:
	printerr("ARCHIVE VIEW: ", reason)
	quit(1)


func _write_records(records: Array) -> void:
	var file := FileAccess.open("user://archive_view_test.txt", FileAccess.WRITE)
	file.store_string(var_to_str(records))
	file.close()


func _open() -> void:
	main._show_chronicle()
	archive = main.get_node("ArchiveView")
	await _frames(3)


func _run() -> void:
	_write_records([])
	Loc.set_lang("tr")
	await _open()
	if archive.find_child("ArchiveEmptyEvents", true, false) == null:
		_fail("empty archive has no empty state")
		return
	if archive.find_child("ArchiveStatValue", true, false) == null:
		_fail("empty archive has no statistics")
		return
	if archive.find_child("ArchiveAchievementCount", true, false).text != "0 / 46":
		_fail("empty achievement count is incorrect")
		return
	_close_with_escape()
	if archive.visible:
		_fail("Escape did not close the archive")
		return

	var records: Array = []
	for i in 12:
		records.append({
			"date": "2026-10-%02d" % (i + 1), "title": "Test hükümdar", "weeks": 16 + i,
			"survived": i % 2 == 0, "cause": "Saraydaki kriz sona erdi.", "cause_key": "",
			"difficulty": "Normal", "extension": false
		})
	_write_records(records)
	await _open()
	var event_rows := []
	for child in archive.find_child("ArchiveEventsList", true, false).get_children():
		if child.name.begins_with("ArchiveEventRow_"):
			event_rows.append(child)
	if event_rows.size() != 8:
		_fail("archive does not show the latest eight events")
		return
	if archive.find_child("ArchiveStatus_0", true, false).text == archive.find_child("ArchiveStatus_1", true, false).text:
		_fail("throne and fallen badges are indistinguishable")
		return
	var achievements: Dictionary = sim.get("ACHIEVEMENTS")
	if achievements.size() != 46:
		_fail("expected 46 achievements, got %d" % achievements.size())
		return
	var achievement_list := archive.find_child("ArchiveAchievementsList", true, false)
	if achievement_list.get_child_count() != 46:
		_fail("archive achievement list is incomplete")
		return
	var event_scroll := archive.find_child("ArchiveEventsScroll", true, false) as ScrollContainer
	var achievement_scroll := archive.find_child("ArchiveAchievementsScroll", true, false) as ScrollContainer
	await _frames(3)
	if event_scroll.get_v_scroll_bar().max_value <= event_scroll.get_v_scroll_bar().page:
		_fail("long archive event list cannot scroll")
		return
	if achievement_scroll.get_v_scroll_bar().max_value <= achievement_scroll.get_v_scroll_bar().page:
		_fail("achievement list cannot scroll")
		return
	event_scroll.scroll_vertical = int(event_scroll.get_v_scroll_bar().max_value)
	achievement_scroll.scroll_vertical = int(achievement_scroll.get_v_scroll_bar().max_value)
	await _frames(1)
	if event_scroll.scroll_vertical == 0 or achievement_scroll.scroll_vertical == 0:
		_fail("archive scroll controls did not move")
		return
	if event_scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED or achievement_scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		_fail("archive unexpectedly allows horizontal scrolling")
		return
	var cause: Label = archive.find_child("ArchiveCause_0", true, false)
	if cause.text != sim.call("chronicle_cause", records.back()):
		_fail("event cause bypasses Sim.chronicle_cause")
		return

	Loc.set_lang("en")
	archive.refresh()
	await _frames(2)
	if archive.find_child("ArchiveSubtitle", true, false).text != "HISTORY, DECISIONS AND CONSEQUENCES.":
		_fail("English subtitle is missing")
		return
	var en_cause: Label = archive.find_child("ArchiveCause_0", true, false)
	if en_cause.text != sim.call("chronicle_cause", records.back()):
		_fail("English event cause is not localized by Sim")
		return
	if archive.find_child("ArchiveStatus_0", true, false).text == "TAHTTA":
		_fail("English result badge remained Turkish")
		return
	if archive.find_child("ArchiveAchievementName_ilk_saltanat", true, false).text != "First Reign":
		_fail("English achievement content was not loaded")
		return
	_close_with_escape()
	if archive.visible:
		_fail("Escape did not close the English archive")
		return

	if bool(main.get("_mobile")):
		var close_button := archive.find_child("ArchiveClose", true, false) as Button
		var row: Control = archive.find_child("ArchiveEventRow_0", true, false)
		var achievement_row: Control = archive.find_child("ArchiveAchievement_regional_steward", true, false)
		if close_button.custom_minimum_size.y < 44 or row.custom_minimum_size.y < 44 or achievement_row.custom_minimum_size.y < 44:
			_fail("mobile archive target is below 44 px")
			return
	print("ARCHIVE VIEW: OK")
	main.queue_free()
	await _frames(3)
	quit(0)


func _close_with_escape() -> void:
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	archive._input(key)
