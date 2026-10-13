extends Control
## Bilgi / onay penceresi (main.gd'den ayrıldı). Menüden bağımsız: masadan (hanedan fotoğrafı) ve oyundan da açılır.
## main.gd onu `_modal` olarak tutar; çağıranlar main.gd::_show_modal'ı kullanır.

const UIKit := preload("res://game/ui/ui_kit.gd")

var host: Control   # main.gd
var text: RichTextLabel
var yes: Button
var close: Button
var cb := Callable()


func _init(main: Control) -> void:
	host = main
	_build()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	var gap := 30 if host._mobile else 120
	for side in ["left", "right"]:
		m.add_theme_constant_override("margin_" + side, gap)
	for side in ["top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 24 if host._mobile else 60)
	add_child(m)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIKit.box(Color(0.08, 0.07, 0.06, 0.98), Color.TRANSPARENT, 4, 28))
	m.add_child(panel)
	UIKit.ornament(panel, Color(UIKit.GOLD, 0.85), 20, 1)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)
	text = RichTextLabel.new()
	text.bbcode_enabled = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.add_theme_font_override("normal_font", UIKit.sans(470))
	text.add_theme_font_override("bold_font", UIKit.serif())
	text.add_theme_font_size_override("normal_font_size", host._fs(16))
	text.add_theme_font_size_override("bold_font_size", host._fs(20))
	text.add_theme_color_override("default_color", Color("e9e4d6"))
	v.add_child(text)
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 10)
	v.add_child(brow)
	yes = Button.new()
	yes.theme_type_variation = "PrimaryButton"
	yes.custom_minimum_size.y = 44
	yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes.add_theme_font_override("font", UIKit.caps())
	host._wire(yes)
	yes.pressed.connect(func() -> void:
		hide()
		if cb.is_valid():
			cb.call())
	brow.add_child(yes)
	close = Button.new()
	close.text = tr("Kapat")
	close.custom_minimum_size.y = 44
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.add_theme_font_override("font", UIKit.caps())
	host._wire(close)
	close.pressed.connect(func() -> void: hide())
	brow.add_child(close)
	hide()


## Bilgi penceresi; yes_label verilirse onay penceresi olur (Evet -> yes_cb).
func show_text(bbcode: String, yes_label := "", yes_cb := Callable()) -> void:
	text.clear()
	text.append_text(bbcode)
	text.scroll_to_line(0)
	yes.visible = yes_label != ""
	yes.text = yes_label
	cb = yes_cb
	close.text = tr("Vazgeç") if yes_label != "" else tr("Kapat")
	show()
	if not host._fast():
		UIKit.fade_in(self, 0.25)
