extends SceneTree
## Capital city map zoom, pan gestures, boundaries, inverse badge scale and tap targets test.

var ok := true
var sim: Node


func _initialize() -> void:
	if "--mobile" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1067, 600))
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	_run.call_deferred()


func _expect(value: bool, message: String) -> void:
	if not value:
		printerr("MAP ZOOM: ", message)
		ok = false


func _run() -> void:
	await process_frame
	sim = root.get_node("Sim")
	var main := (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	sim.new_game(101, 0)
	main._refresh()

	var city = main._city
	city.open()
	for i in 3: await process_frame

	# 1. Başlangıç durumu
	_expect(is_equal_approx(city.zoom_scale, 1.0), "initial zoom scale is not 1.0")
	_expect(not city._reset_zoom_button.visible, "reset button should start hidden at 1.0 zoom")
	_expect(city._map_layer != null, "map layer was not built")

	# 2. Sentetik pinch / magnify gesture testi
	var pinch := InputEventMagnifyGesture.new()
	pinch.factor = 1.5
	pinch.position = city.size * 0.5
	city._on_background_input(pinch)
	await process_frame

	_expect(city.zoom_scale > 1.2, "pinch gesture did not increase zoom scale")
	_expect(city._reset_zoom_button.visible, "reset button should be visible when zoomed in")

	# 3. Ters ölçek kontrolü (Plaka ve yazı boyutu haritayla büyümez, 1x kalır)
	var expected_inv: float = 1.0 / float(city.zoom_scale)
	var saray_plate: Control = city.plates["saray"]
	_expect(is_equal_approx(saray_plate.scale.x, expected_inv), "plate did not apply inverse scale for crisp font size")

	# 4. Ölçek sınırları (1.0 - 2.5)
	city.apply_zoom(4.0, city.size * 0.5)
	_expect(is_equal_approx(city.zoom_scale, 2.5), "zoom scale exceeded maximum clamp 2.5")

	city.apply_zoom(0.4, city.size * 0.5)
	_expect(is_equal_approx(city.zoom_scale, 1.0), "zoom scale went below minimum clamp 1.0")

	# 5. Sürükleme ve kenar sınırları (Ekran içine taşmama / siyah boşluk bırakmama)
	city.apply_zoom(2.0, city.size * 0.5)
	var min_bound: Vector2 = city.size * (1.0 - 2.0)

	# Aşırı sağa/aşağı kaydırma denemesi (pozitif olamaz)
	city.pan_map(Vector2(500, 500))
	_expect(city._map_layer.position.x <= 0.001 and city._map_layer.position.y <= 0.001,
		"map layer position exceeded positive boundary limit")

	# Aşırı sola/yukarı kaydırma denemesi (min_bound altına inemez)
	city.pan_map(Vector2(-3000, -3000))
	_expect(city._map_layer.position.x >= min_bound.x - 0.01 and city._map_layer.position.y >= min_bound.y - 0.01,
		"map layer position exceeded negative boundary limit")

	# 6. Sürükleme esnasında kurum açılmaması kuralı
	city._is_dragging = true
	var adliye_plate: Control = city.plates["adliye"]
	var tap_event := InputEventMouseButton.new()
	tap_event.button_index = MOUSE_BUTTON_LEFT
	tap_event.pressed = true
	adliye_plate.gui_input.emit(tap_event)
	await process_frame
	_expect(not city._drawer.visible, "institution should NOT open while dragging")

	# 7. Kısa dokunma kurumu açar
	city._is_dragging = false
	adliye_plate.gui_input.emit(tap_event)
	await process_frame
	_expect(city._drawer.visible, "short tap failed to open institution panel")
	city._drawer.hide()
	await process_frame

	# 8. Sıfırla butonu
	city._reset_zoom_button.pressed.emit()
	await create_tween().tween_interval(0.3).finished
	await process_frame

	_expect(is_equal_approx(city.zoom_scale, 1.0), "reset button failed to return zoom scale to 1.0")
	_expect(is_equal_approx(city._map_layer.position.x, 0.0) and is_equal_approx(city._map_layer.position.y, 0.0),
		"reset button failed to reset map layer position")
	_expect(not city._reset_zoom_button.visible, "reset button should be hidden after reset")

	main.free()
	print("MAP ZOOM: OK" if ok else "MAP ZOOM: FAILED")
	quit(0 if ok else 1)
