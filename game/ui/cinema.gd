extends Control
## Sinematik katman: siyah bantlar, Ken Burns kamera hareketi, satır satır anlatım.
## Her sahne tıklama, Esc ya da Boşluk ile atlanabilir.

signal finished

const UIKit := preload("res://game/ui/ui_kit.gd")
const BAR_H := 0.11   # ekran yüksekliğinin oranı olarak bant kalınlığı

var _img_a: TextureRect
var _img_b: TextureRect
var _top_bar: ColorRect
var _bot_bar: ColorRect
var _line: Label
var _sub: Label
var _skip_btn: Button
var _skipped := false
var _playing := false
var _front_is_a := true


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var black := ColorRect.new()
	black.color = Color(0.01, 0.008, 0.012)
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	_img_a = _make_img()
	_img_b = _make_img()
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.18)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_top_bar = _make_bar(true)
	_bot_bar = _make_bar(false)
	# Altyazı alanı: alt bandın hemen üstünde, sinema altyazısı gibi.
	var mc := MarginContainer.new()
	mc.set_anchors_preset(Control.PRESET_FULL_RECT)
	mc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mc.add_theme_constant_override("margin_left", 140)
	mc.add_theme_constant_override("margin_right", 140)
	mc.add_theme_constant_override("margin_bottom", 140)
	add_child(mc)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 10)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mc.add_child(v)
	_line = Label.new()
	_line.add_theme_font_override("font", UIKit.serif())
	_line.add_theme_font_size_override("font_size", 46)
	_line.add_theme_color_override("font_color", Color("f1e6c8"))
	_line.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_line.add_theme_constant_override("shadow_offset_y", 3)
	_line.add_theme_constant_override("shadow_outline_size", 8)
	_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_line)
	_sub = Label.new()
	_sub.add_theme_font_size_override("font_size", 20)
	_sub.add_theme_color_override("font_color", UIKit.GOLD)
	_sub.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_sub.add_theme_constant_override("shadow_outline_size", 6)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_sub)
	_skip_btn = Button.new()
	_skip_btn.text = "Geç  ▸▸"
	_skip_btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	_skip_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_skip_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_skip_btn.focus_mode = Control.FOCUS_NONE
	_skip_btn.pressed.connect(skip)
	add_child(_skip_btn)
	hide()


func _make_img() -> TextureRect:
	var t := TextureRect.new()
	t.set_anchors_preset(Control.PRESET_FULL_RECT)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.modulate.a = 0.0
	add_child(t)
	return t


func _make_bar(top: bool) -> ColorRect:
	var b := ColorRect.new()
	b.color = Color.BLACK
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.anchor_left = 0.0
	b.anchor_right = 1.0
	if top:
		b.anchor_top = 0.0
		b.anchor_bottom = 0.0
	else:
		b.anchor_top = 1.0
		b.anchor_bottom = 1.0
	add_child(b)
	return b


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		skip()
		accept_event()


func _unhandled_key_input(event: InputEvent) -> void:
	if not _playing:
		return
	var k := event as InputEventKey
	if k and k.pressed and (k.keycode == KEY_ESCAPE or k.keycode == KEY_SPACE or k.keycode == KEY_ENTER):
		skip()
		get_viewport().set_input_as_handled()


func skip() -> void:
	_skipped = true


func _set_bars(amount: float, dur: float) -> void:
	var h := size.y * BAR_H * amount
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_top_bar, "offset_bottom", h, dur).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_bot_bar, "offset_top", -h, dur).set_trans(Tween.TRANS_SINE)


## Atlanabilir bekleme: süre dolana ya da oyuncu geçene kadar.
func _wait(t: float) -> void:
	var left := t
	while left > 0.0 and not _skipped:
		await get_tree().process_frame
		left -= get_process_delta_time()


## Bir sahne: görsel çapraz geçişle gelir ve yavaşça yakınlaşır/kayar, üstüne satır yazılır.
func _shot(tex: Texture2D, line: String, sub: String, hold: float, zoom_from := 1.0, zoom_to := 1.12, pan := Vector2.ZERO, fit := "cover") -> void:
	if _skipped:
		return
	var front := _img_a if _front_is_a else _img_b
	var back := _img_b if _front_is_a else _img_a
	_front_is_a = not _front_is_a
	if tex == null:
		# Görselsiz sahne: önceki görsel kararır, yalnızca yazı kalır.
		create_tween().tween_property(front, "modulate:a", 0.0, 0.9)
	if tex:
		back.texture = tex
		# Portreler kırpılmadan karanlığın ortasında; sahneler ekranı kaplar.
		back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if fit == "center" else TextureRect.STRETCH_KEEP_ASPECT_COVERED
		back.pivot_offset = size / 2.0
		back.scale = Vector2(zoom_from, zoom_from)
		back.position = Vector2.ZERO
		var cam := create_tween().set_parallel(true)
		cam.tween_property(back, "scale", Vector2(zoom_to, zoom_to), hold + 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		cam.tween_property(back, "position", pan, hold + 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var fade := create_tween().set_parallel(true)
		fade.tween_property(back, "modulate:a", 1.0, 0.9)
		fade.tween_property(front, "modulate:a", 0.0, 0.9)
	_line.text = line
	_sub.text = sub
	_line.modulate.a = 0.0
	_sub.modulate.a = 0.0
	var tt := create_tween()
	tt.tween_interval(0.35)
	tt.tween_property(_line, "modulate:a", 1.0, 0.7)
	tt.parallel().tween_property(_sub, "modulate:a", 1.0, 0.9).set_delay(0.3)
	await _wait(hold)
	if _skipped:
		return
	var out := create_tween().set_parallel(true)
	out.tween_property(_line, "modulate:a", 0.0, 0.4)
	out.tween_property(_sub, "modulate:a", 0.0, 0.4)
	await _wait(0.4)


## Sahne listesini oynatır. Her sahne: {tex, line, sub, hold, zoom_from, zoom_to, pan}
func _fit_to_screen() -> void:
	# CanvasLayer altında gizli kurulan Control'ün boyutu kendiliğinden hesaplanmıyor; açıkça ekrana eşitle.
	position = Vector2.ZERO
	size = get_viewport_rect().size


func play(shots: Array) -> void:
	_fit_to_screen()
	if not get_viewport().size_changed.is_connected(_fit_to_screen):
		get_viewport().size_changed.connect(_fit_to_screen)
	_skipped = false
	_playing = true
	modulate.a = 1.0
	show()
	_top_bar.offset_bottom = 0.0
	_bot_bar.offset_top = 0.0
	_set_bars(1.0, 0.8)
	for s: Dictionary in shots:
		await _shot(s.get("tex"), str(s.get("line", "")), str(s.get("sub", "")), float(s.get("hold", 2.5)),
			float(s.get("zoom_from", 1.0)), float(s.get("zoom_to", 1.12)), s.get("pan", Vector2.ZERO), str(s.get("fit", "cover")))
		if _skipped:
			break
	_playing = false
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	await tw.finished
	hide()
	_img_a.modulate.a = 0.0
	_img_b.modulate.a = 0.0
	finished.emit()
