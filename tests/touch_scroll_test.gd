extends SceneTree
## Mobil dokunmatik kaydırma: düğme üstünden sürükleme kaydırır ve düğmeye basmaz; kısa dokunuş basar.
const TouchScroll := preload("res://game/ui/touch_scroll.gd")

var presses := 0
var sc: ScrollContainer


func _initialize() -> void:
	var holder := Control.new()
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(holder)
	sc = ScrollContainer.new()
	sc.position = Vector2(100, 50)
	sc.size = Vector2(300, 300)
	holder.add_child(sc)
	var box := VBoxContainer.new()
	box.custom_minimum_size.x = 280
	sc.add_child(box)
	for i in 40:
		var b := Button.new()
		b.text = "Düğme %d" % i
		b.custom_minimum_size.y = 48
		b.pressed.connect(func() -> void: presses += 1)
		box.add_child(b)
	holder.add_child(TouchScroll.new())
	_run.call_deferred()


## İstenen görüntü alanı konumunu pencere pikseline çevirir (içerik ölçeklemesi için).
func _w(p: Vector2) -> Vector2:
	return p * Vector2(root.size) / root.get_visible_rect().size


func _ev_btn(pos: Vector2, down: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = down
	e.position = _w(pos)
	e.global_position = _w(pos)
	e.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
	Input.parse_input_event(e)


func _ev_move(pos: Vector2, rel: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = _w(pos)
	e.global_position = _w(pos)
	e.relative = rel
	e.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(e)


func _run() -> void:
	for i in 20:
		await process_frame
	var ok := true
	# 1) Düğmenin üstünden başlayan sürükleme kaydırır, düğmeye basmaz.
	var p := Vector2(250, 300)
	_ev_btn(p, true)
	await process_frame
	for i in 10:
		p += Vector2(0, -12)
		_ev_move(p, Vector2(0, -12))
		await process_frame
	_ev_btn(p, false)
	await process_frame
	await process_frame
	if sc.scroll_vertical < 60:
		printerr("TOUCH: sürükleme kaydırmadı: ", sc.scroll_vertical)
		ok = false
	if presses != 0:
		printerr("TOUCH: sürükleme düğmeye bastı: ", presses)
		ok = false
	# 2) Kısa dokunuş düğmeye basar.
	await create_timer(1.2).timeout
	var q := Vector2(250, 100)
	_ev_btn(q, true)
	await process_frame
	_ev_btn(q, false)
	await process_frame
	await process_frame
	if presses != 1:
		printerr("TOUCH: dokunuş düğmeye basmadı: ", presses)
		ok = false
	print("TOUCH: OK" if ok else "TOUCH: FAIL")
	quit(0 if ok else 1)
