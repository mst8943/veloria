extends SceneTree
## Synthetic touch taps activate on release; movement/holds cancel without changing mouse timing.

const TOUCH_SCROLL := preload("res://game/ui/touch_scroll.gd")

var ok := true
var gate: Node
var button_presses := 0
var custom_taps := 0
var custom_mouse_downs := 0
var hover_events := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(ui)
	gate = TOUCH_SCROLL.new()
	root.add_child(gate)
	var button := Button.new()
	button.position = Vector2(40, 40)
	button.size = Vector2(160, 54)
	button.text = "button"
	ui.add_child(button)
	button.pressed.connect(func() -> void: button_presses += 1)
	button.mouse_entered.connect(func() -> void:
		if not TOUCH_SCROLL.dispatching_touch: hover_events += 1
	)
	var desk_object := _custom_surface(ui, Vector2(240, 40))
	var map_plate := _custom_surface(ui, Vector2(440, 40))
	var news_strip := _custom_surface(ui, Vector2(640, 40))
	var person_card := _custom_surface(ui, Vector2(840, 40))
	var volume := HSlider.new()
	volume.position = Vector2(40, 150)
	volume.size = Vector2(220, 44)
	volume.max_value = 100.0
	ui.add_child(volume)
	for frame in 2: await process_frame
	await _check_button_tap(button)
	await _send_screen_touch(Vector2(300, 60), true)
	_check(custom_taps == 0, "custom surface does not trigger on touch-down")
	await _send_screen_touch(Vector2(300, 60), false)
	_check(custom_taps == 1, "desk-like surface triggers on release")
	for target in [map_plate, news_strip, person_card]:
		var before := custom_taps
		await _send_screen_touch(target.get_global_rect().get_center(), true)
		await _send_screen_touch(target.get_global_rect().get_center(), false)
		_check(custom_taps == before + 1, "map/news/card surface uses release activation")
	var before_hold := custom_taps
	var feedback_pos := desk_object.get_global_rect().get_center()
	await _send_screen_touch(feedback_pos, true)
	await create_timer(0.1).timeout
	_check(gate._touch_feedback != null and gate._touch_feedback.visible, "pressed feedback appears after a short delay")
	await _send_screen_drag(feedback_pos + Vector2(20, 0))
	_check(not gate._touch_feedback.visible, "movement cancels pressed feedback")
	await _send_screen_touch(feedback_pos + Vector2(20, 0), false)
	_check(custom_taps == before_hold, "drag after feedback still cancels activation")
	var before_drag := button_presses
	var drag_pos := button.get_global_rect().get_center()
	await _send_screen_touch(drag_pos, true)
	await _send_screen_drag(drag_pos + Vector2(20, 0))
	await _send_screen_drag(drag_pos + Vector2(40, 0))
	await _send_screen_touch(drag_pos + Vector2(40, 0), false)
	_check(button_presses == before_drag, "dragging across a button cancels the touch")
	_check(hover_events == 0, "touch does not trigger pointer hover")
	await _send_screen_touch(volume.get_global_rect().position + Vector2(12, 22), true)
	await _send_screen_drag(volume.get_global_rect().position + Vector2(205, 22))
	await _send_screen_touch(volume.get_global_rect().position + Vector2(205, 22), false)
	_check(volume.value >= 75.0, "touch drag adjusts volume sliders instead of being treated as a scroll")
	var before_mouse := custom_mouse_downs
	var mouse_pos := desk_object.get_global_rect().get_center()
	await _send_mouse(mouse_pos, true)
	_check(custom_mouse_downs == before_mouse + 1, "desktop custom control still activates on mouse-down")
	await _send_mouse(mouse_pos, false)
	ui.queue_free()
	print("TOUCH TAP: OK" if ok else "TOUCH TAP: FAILED")
	quit(0 if ok else 1)


func _check_button_tap(button: Button) -> void:
	var pos := button.get_global_rect().get_center()
	var before := button_presses
	await _send_screen_touch(pos, true)
	_check(button_presses == before and hover_events == 0, "touch-down does not activate or hover the button")
	await _send_screen_touch(pos, false)
	_check(button_presses == before + 1, "short touch activates on release")


func _custom_surface(parent: Control, pos: Vector2) -> Control:
	var surface := Control.new()
	surface.position = pos
	surface.size = Vector2(160, 60)
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(surface)
	surface.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				if TOUCH_SCROLL.dispatching_touch: custom_taps += 1
				else: custom_mouse_downs += 1
	)
	return surface


func _send_screen_touch(pos: Vector2, down: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = pos
	event.pressed = down
	gate._handle_screen_touch(event)
	await process_frame
	if not down: await process_frame


func _send_screen_drag(pos: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = pos
	gate._handle_screen_drag(event)
	await process_frame


func _send_mouse(pos: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	event.position = _screen_position(pos)
	event.global_position = event.position
	Input.parse_input_event(event)
	await process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		ok = false
		printerr("TOUCH TAP: ", message)


func _screen_position(pos: Vector2) -> Vector2:
	return get_root().get_viewport().get_screen_transform() * pos
