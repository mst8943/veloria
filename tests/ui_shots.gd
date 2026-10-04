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
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 3)
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
	while not sim.ended:
		sim.end_week()
	await process_frame
	var tabs: TabContainer = main._end_tabs
	for i in tabs.get_tab_count():
		tabs.current_tab = i
		await _shot("5_son_%d" % i)
	quit(0)
