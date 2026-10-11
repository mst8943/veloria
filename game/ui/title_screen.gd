extends Control
## Giriş ekranı: logo açılışından sonra bir kez gösterilir; "Devam etmek için tıklayın" ile menüye geçilir.

signal dismissed

const UIKit := preload("res://game/ui/ui_kit.gd")
const ART := "res://art/giris.png"

var _host
var _done := false
var _prompt: Label


func _init(host) -> void:
	_host = host


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	var back := ColorRect.new()
	back.color = Color("000a19")
	back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(back)
	var tex: Texture2D = _host._art(ART)
	if tex:
		var img := TextureRect.new()
		img.texture = tex
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(img)
	# Alt kısım: yazıların okunması için yumuşak karartma
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0.02, 0.06, 0.0))
	grad.set_color(1, Color(0, 0.02, 0.06, 0.82))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	var shade := TextureRect.new()
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.anchor_left = 0.0
	shade.anchor_right = 1.0
	shade.anchor_top = 0.62
	shade.anchor_bottom = 1.0
	shade.offset_left = 0
	shade.offset_right = 0
	shade.offset_top = 0
	shade.offset_bottom = 0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var box := VBoxContainer.new()
	box.anchor_left = 0.0
	box.anchor_right = 1.0
	box.anchor_top = 0.80
	box.anchor_bottom = 0.97
	box.offset_left = 0
	box.offset_right = 0
	box.offset_top = 0
	box.offset_bottom = 0
	box.alignment = BoxContainer.ALIGNMENT_END
	box.add_theme_constant_override("separation", 14)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var quote := Label.new()
	quote.text = tr("Tahtı korumak zordur.")
	quote.add_theme_font_override("font", UIKit.serif_italic())
	quote.add_theme_font_size_override("font_size", _host._fs(26 if _host._mobile else 40))
	quote.add_theme_color_override("font_color", UIKit.GOLD)
	quote.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	quote.add_theme_constant_override("shadow_offset_y", 3)
	quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(quote)
	_prompt = Label.new()
	_prompt.text = tr("Devam etmek için dokunun") if _host._mobile else tr("Devam etmek için tıklayın")
	_prompt.add_theme_font_size_override("font_size", _host._fs(18 if _host._mobile else 22))
	_prompt.add_theme_color_override("font_color", Color(UIKit.TEXT, 0.95))
	_prompt.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_prompt.add_theme_constant_override("shadow_offset_y", 2)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_prompt)

	UIKit.fade_in(self, 0.9)
	if UIKit.reduce_motion:
		return
	var blink := _prompt.create_tween().set_loops()   # yanıp sönen "devam" satırı
	blink.tween_property(_prompt, "modulate:a", 0.15, 0.85).set_trans(Tween.TRANS_SINE)
	blink.tween_property(_prompt, "modulate:a", 1.0, 0.85).set_trans(Tween.TRANS_SINE)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_dismiss()
	elif event is InputEventScreenTouch and event.pressed:
		_dismiss()


func _input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo:
		_dismiss()


func _dismiss() -> void:
	if _done:
		return
	_done = true
	get_viewport().set_input_as_handled()
	dismissed.emit()
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.0 if UIKit.reduce_motion else 0.5)
	tw.tween_callback(queue_free)
