extends SceneTree
## Accessibility preferences stay in user settings and affect shared UI helpers.

const UIKit := preload("res://game/ui/ui_kit.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var sfx: Node = root.get_node("Sfx")
	var existed := FileAccess.file_exists(Sfx.SETTINGS_PATH)
	var backup := PackedByteArray()
	if existed:
		var old := FileAccess.open(Sfx.SETTINGS_PATH, FileAccess.READ)
		backup = old.get_buffer(old.get_length())
	var main := (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	var ok := true
	var old_values := [sfx.text_size, sfx.colorblind_mode, sfx.reduce_motion, sfx.vibration, sfx.high_contrast]
	sfx.text_size = 2
	sfx.colorblind_mode = true
	sfx.reduce_motion = true
	sfx.vibration = false
	sfx.high_contrast = true
	UIKit.configure_accessibility(sfx.text_size, sfx.high_contrast, sfx.reduce_motion)
	main.theme = UIKit.build_theme(false)
	if main._fs(20) != 26 or main.theme.default_font_size != 19:
		printerr("A11Y: yazı boyutu ölçeklenmedi")
		ok = false
	main._mobile = true
	if main._fs(20) != 31:
		printerr("A11Y: mobil yazı boyutu ölçeklenmedi")
		ok = false
	var border := UIKit.box(Color.BLACK, Color(UIKit.GOLD, 0.2))
	if border.border_color.a < 0.99 or border.border_width_left < 2:
		printerr("A11Y: yüksek kontrast kenarlığı uygulanmadı")
		ok = false
	var chip: Control = main._person_panel._trait("Test", UIKit.DANGER)
	var marker := chip.get_child(0).get_child(0) as Control
	if not is_equal_approx(marker.rotation, PI / 4.0):
		printerr("A11Y: renk körü durum şekli uygulanmadı")
		ok = false
	var dust := UIKit.dust(Vector2(100, 100))
	if dust.emitting:
		printerr("A11Y: azaltılmış harekette toz açık")
		ok = false
	var motion_target := Control.new()
	UIKit.pulse(motion_target)
	if motion_target.scale != Vector2.ONE:
		printerr("A11Y: azaltılmış harekette nabız açık")
		ok = false
	sfx.save_settings()
	var saved := ConfigFile.new()
	if saved.load(Sfx.SETTINGS_PATH) != OK or int(saved.get_value("accessibility", "text_size", -1)) != 2 or bool(saved.get_value("accessibility", "vibration", true)):
		printerr("A11Y: ayarlar kaydedilmedi")
		ok = false
	sfx.text_size = old_values[0]
	sfx.colorblind_mode = old_values[1]
	sfx.reduce_motion = old_values[2]
	sfx.vibration = old_values[3]
	sfx.high_contrast = old_values[4]
	UIKit.configure_accessibility(sfx.text_size, sfx.high_contrast, sfx.reduce_motion)
	if existed:
		var restore := FileAccess.open(Sfx.SETTINGS_PATH, FileAccess.WRITE)
		restore.store_buffer(backup)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Sfx.SETTINGS_PATH))
	main.free()
	print("A11Y: OK" if ok else "A11Y: FAIL")
	quit(0 if ok else 1)
