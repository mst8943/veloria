extends SceneTree
## Capital city map zoom, pan gestures, boundaries, inverse badge scale and tap targets test.

const TOUCH_SCROLL := preload("res://game/ui/touch_scroll.gd")

var ok := true
var sim: Node
var touch_gate: Node


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
	touch_gate = TOUCH_SCROLL.new()
	root.add_child(touch_gate)
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
	_expect(not city._is_dragging, "zoom gesture left site taps disabled")
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

	# 6. A real touch tap opens a site only on release.
	city.apply_zoom(1.0, city.size * 0.5)
	var adliye_plate: Control = city.plates["adliye"]
	var site_point := adliye_plate.get_global_rect().get_center()
	var mouse_press := InputEventMouseButton.new()
	mouse_press.button_index = MOUSE_BUTTON_LEFT
	mouse_press.pressed = true
	mouse_press.global_position = site_point
	mouse_press.position = site_point - adliye_plate.global_position
	adliye_plate.gui_input.emit(mouse_press)
	_expect(city._drawer.visible, "desktop mouse activation no longer occurs on press")
	city._drawer.hide()
	await process_frame
	await _screen_touch(site_point, true, 0)
	_expect(not city._drawer.visible, "site opened on touch-down")
	await _screen_touch(site_point, false, 0)
	_expect(city._drawer.visible, "short touch failed to open site on release")
	city._drawer.hide()
	await process_frame

	# 7. Dragging from a site pans the map without opening the site.
	city.apply_zoom(2.0, site_point)
	var before_pan: Vector2 = city._map_layer.position
	site_point = adliye_plate.get_global_rect().get_center()
	await _screen_touch(site_point, true, 0)
	await _screen_drag(site_point + Vector2(34, 0), 0)
	await _screen_touch(site_point + Vector2(34, 0), false, 0)
	_expect(not city._drawer.visible, "dragging over a site opened its panel")
	_expect(not city._map_layer.position.is_equal_approx(before_pan), "touch drag did not pan the map")

	# 8. Pinch via screen-touch events zooms and suppresses the site tap.
	city._drawer.hide()
	city.apply_zoom(1.0, city.size * 0.5)
	var pinch_center: Vector2 = city.get_global_rect().get_center()
	await _screen_touch(pinch_center + Vector2(-30, 0), true, 0)
	await _screen_touch(pinch_center + Vector2(30, 0), true, 1)
	await _screen_drag(pinch_center + Vector2(48, 0), 1)
	await _screen_touch(pinch_center + Vector2(48, 0), false, 1)
	await _screen_touch(pinch_center + Vector2(-30, 0), false, 0)
	_expect(city.zoom_scale > 1.2, "screen-touch pinch did not zoom the map")
	_expect(not city._drawer.visible, "pinch gesture opened a map panel")

	# 9. Reset button
	city._reset_zoom_button.pressed.emit()
	await create_tween().tween_interval(0.3).finished
	await process_frame

	_expect(is_equal_approx(city.zoom_scale, 1.0), "reset button failed to return zoom scale to 1.0")
	_expect(is_equal_approx(city._map_layer.position.x, 0.0) and is_equal_approx(city._map_layer.position.y, 0.0),
		"reset button failed to reset map layer position")
	_expect(not city._reset_zoom_button.visible, "reset button should be hidden after reset")

	main.free()
	touch_gate.free()
	print("MAP ZOOM: OK" if ok else "MAP ZOOM: FAILED")
	quit(0 if ok else 1)


func _screen_touch(pos: Vector2, down: bool, index: int) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = pos
	event.pressed = down
	touch_gate._handle_screen_touch(event)
	await process_frame
	if not down:
		await process_frame


func _screen_drag(pos: Vector2, index: int) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = pos
	touch_gate._handle_screen_drag(event)
	await process_frame
