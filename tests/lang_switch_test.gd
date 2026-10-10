extends SceneTree
## Dil canlı değişiyor mu: TR -> EN -> TR; sekme başlıkları, üst çubuk ve menü yeniden kurulmalı.
var main: Control


func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	ProjectSettings.set_setting("veloria/dev_skip_weeks", 3)
	_boot.call_deferred()


func _boot() -> void:
	await process_frame
	root.get_node("Sfx").set_language("tr")
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()


func _frames(n := 6) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	await _frames(30)
	var ok := true
	if main._tabs.get_tab_title(0) != "Gündem":
		printerr("LANG: TR başlangıç sekmesi: ", main._tabs.get_tab_title(0))
		ok = false
	main._show_menu()
	main._menu_show_page("settings")
	root.get_node("Sfx").set_language("en")
	main.call_deferred("rebuild_ui")
	await _frames(12)
	var t0: String = main._tabs.get_tab_title(0)
	if t0 != "Agenda":
		printerr("LANG: EN sekme başlığı yenilenmedi: ", t0)
		ok = false
	if not main._menu.visible or main._menu.page_now != "settings":
		printerr("LANG: menü ayar sayfası korunmadı: ", main._menu.visible, " ", main._menu.page_now)
		ok = false
	var desk_text: String = (main._buttons["desk"] as Button).text
	if desk_text != "Desk":
		printerr("LANG: üst çubuk düğmesi yenilenmedi: ", desk_text)
		ok = false
	root.get_node("Sfx").set_language("tr")
	main.rebuild_ui()
	await _frames(12)
	if main._tabs.get_tab_title(0) != "Gündem":
		printerr("LANG: TR'ye dönüş yenilenmedi: ", main._tabs.get_tab_title(0))
		ok = false
	print("LANG: OK" if ok else "LANG: FAIL")
	quit(0 if ok else 1)
