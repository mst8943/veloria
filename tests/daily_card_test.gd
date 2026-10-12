extends SceneTree
## Daily runs use a stable date seed and keep their first result outside campaign saves.

var ok := true


func _initialize() -> void:
	_run.call_deferred()


func _expect(value: bool) -> void:
	ok = ok and value


func _run() -> void:
	await process_frame
	var sim: Node = root.get_node("Sim")
	var sfx: Node = root.get_node("Sfx")
	var old_language := str(sfx.language)
	var shot_lang := "en" if "--lang=en" in OS.get_cmdline_user_args() else "tr"
	var mobile := "--mobile" in OS.get_cmdline_user_args()
	DisplayServer.window_set_size(Vector2i(1067, 600) if mobile else Vector2i(1280, 720))
	sfx.set_language(shot_lang)
	sim.daily_path = "user://daily_card_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.daily_path))
	var card_directory := "user://daily_card_test_cards"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(card_directory))
	var date := "2099-02-03"
	var seed: int = sim.daily_seed(date)
	_expect(seed == 20990203 and seed == sim.daily_seed(date))
	_expect(sim.daily_result(date).is_empty())
	var result := {"title": "Harap Devletin Kralı", "weeks": 42, "survived": false}
	_expect(sim.save_daily_result(date, result, seed))
	_expect(sim.daily_result(date)["weeks"] == 42)
	_expect(not sim.save_daily_result(date, {"title": "changed", "weeks": 99, "survived": true}, seed))
	_expect(sim.daily_result(date)["title"] == result["title"])

	var old_short_fx: bool = sfx.short_fx
	sfx.short_fx = true
	sim.autosave = false
	sim.record_chronicle = false
	sim.new_game(42, 1)
	sim._end(true)
	var main := (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	main._end_overlay.show_record(sim.record)
	main._end_overlay.show()
	main._end_overlay.card_output_directory = card_directory
	main._end_overlay._record["daily_date"] = date
	main._end_overlay._record["daily_seed"] = seed
	var share: String = main._end_overlay._share_text()
	_expect(share.contains("Tahtta kaldı") and share.contains("Stayed on the throne"))
	if "--keep-card" in OS.get_cmdline_user_args():
		for i in 3:
			await process_frame
		root.get_texture().get_image().save_png("screenshots/faz6_a3_end_screen_%s_%s.png" % [shot_lang, "mobile" if mobile else "desktop"])
	await main._end_overlay._save_card()
	await process_frame
	var card_path := ProjectSettings.globalize_path(card_directory.path_join("veloria_%s_%d.png" % [date, seed]))
	var image := Image.new()
	if DisplayServer.get_name() == "headless":
		_expect(not FileAccess.file_exists(card_path))
	else:
		_expect(image.load(card_path) == OK and image.get_width() == 1080 and image.get_height() == 1350)
	if "--keep-card" in OS.get_cmdline_user_args() and image.get_width() > 0:
		image.save_png("screenshots/faz6_a3_card_%s.png" % shot_lang)
		main._modal.hide()
		main._end_overlay.show_record(sim.record)
		main._end_overlay._record["daily_date"] = date
		main._end_overlay._record["daily_seed"] = seed
		var other_lang := "tr" if shot_lang == "en" else "en"
		sfx.set_language(other_lang)
		main._end_overlay.card_output_directory = card_directory
		await main._end_overlay._save_card()
		var image_en := Image.new()
		_expect(image_en.load(card_path) == OK and image_en.get_width() == 1080 and image_en.get_height() == 1350)
		image_en.save_png("screenshots/faz6_a3_card_%s.png" % other_lang)
	sfx.short_fx = old_short_fx   # set_language ayarı kaydeder; test bayrağı oyuncunun ayarına sızmasın
	sfx.set_language(old_language)
	if FileAccess.file_exists(card_path):
		DirAccess.remove_absolute(card_path)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.daily_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(card_directory))
	print("DAILY CARD: OK" if ok else "DAILY CARD: FAILED")
	quit(0 if ok else 1)
