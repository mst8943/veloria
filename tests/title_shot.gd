extends SceneTree
## Giriş ekranı ve menü görüntüsü (pencereli): Godot --path . --script res://tests/title_shot.gd -- --out=klasor [--mobile] [--lang=en]

func _initialize() -> void:
	if "--mobile" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1067, 600))
	else:
		DisplayServer.window_set_size(Vector2i(1600, 900))
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var out := "screenshots/giris"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.substr(6)
	var tag := ("mobile" if "--mobile" in OS.get_cmdline_user_args() else "desktop") + ("_en" if "--lang=en" in OS.get_cmdline_user_args() else "_tr")
	get_root().get_node("Sfx").set_language("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	get_root().get_node("Sim").autosave = false
	var main := (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	current_scene = main
	for i in 60: await process_frame
	root.get_texture().get_image().save_png("%s/title_%s.png" % [out, tag])
	await create_timer(0.9).timeout
	root.get_texture().get_image().save_png("%s/title_blink_%s.png" % [out, tag])
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = Vector2(300, 300)
	Input.parse_input_event(ev)
	for i in 50: await process_frame
	root.get_texture().get_image().save_png("%s/menu_%s.png" % [out, tag])
	quit(0)
