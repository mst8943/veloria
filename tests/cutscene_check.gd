extends SceneTree
## Ara sahne kontrolü: cutscenes.json geçerli mi, sahne oynuyor mu, görsel dosyalar var mı.
## Pencereli çalıştırılır: godot --path . --script res://tests/cutscene_check.gd [-- --shots=KLASÖR]

var main: Control


func _initialize() -> void:
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	for i in 20:
		await process_frame
	var f := FileAccess.open("res://game/data/cutscenes.json", FileAccess.READ)
	var data: Variant = JSON.parse_string(f.get_as_text())
	if not (data is Array):
		printerr("CUTSCENE: JSON okunamadı")
		quit(1)
		return
	var events := {}
	var ef := FileAccess.open("res://game/data/events.json", FileAccess.READ)
	for e: Dictionary in JSON.parse_string(ef.get_as_text()):
		events[str(e["id"])] = e
	var ok := true
	for c: Dictionary in data:
		if not events.has(str(c["event"])):
			printerr("CUTSCENE: olay yok: ", c["event"])
			ok = false
			continue
		var ch := int(c.get("choice", -1))
		if ch >= events[str(c["event"])]["choices"].size():
			printerr("CUTSCENE: seçenek yok: ", c["id"])
			ok = false
		for s: Dictionary in c["shots"]:
			var path := str(s["art"])
			var res := "res://art/events/%s.png" % path.trim_prefix("events/") if path.begins_with("events/") else "res://art/%s.png" % path
			if not ResourceLoader.exists(res):
				printerr("CUTSCENE: görsel yok: ", res)
				ok = false
	var out := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			out = a.trim_prefix("--shots=")
	if out != "":
		DirAccess.make_dir_recursive_absolute(out)
		main._menu.hide()
		main._play_cutscene("suikast", 2)
		await create_timer(2.2).timeout
		root.get_viewport().get_texture().get_image().save_png(out.path_join("cutscene_1.png"))
		await create_timer(3.0).timeout
		root.get_viewport().get_texture().get_image().save_png(out.path_join("cutscene_2.png"))
	print("CUTSCENE: OK" if ok else "CUTSCENE: FAIL")
	quit(0 if ok else 1)
