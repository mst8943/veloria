extends Control
## Çalışma Masası: haftanın merkez ekranı. Masadaki her nesne bir kapıdır.
## Gerçek nesne görselleri res://art/desk/<id>.png (saydam PNG) olarak eklenirse onlar kullanılır;
## yoksa nesneler kodla çizilir.

signal request(target: String)

const UIKit := preload("res://game/ui/ui_kit.gd")
const Press := preload("res://game/core/press.gd")

const PARCH := Color("e6dcc2")
const INK := Color("1b1610")

## id -> [x, y, w, h] (1600x900 tabanında), etiket
const LAYOUT := {
	"harita": [Rect2(520, 150, 560, 330), "Başkent · Kurumlar"],
	"hanedan": [Rect2(120, 140, 300, 230), "Hanedan"],
	"kisiler": [Rect2(1180, 150, 300, 230), "Kişiler"],
	"gunluk": [Rect2(110, 470, 280, 300), "Saltanat Günlüğü"],
	"gundem": [Rect2(470, 520, 330, 250), "Gündem"],
	"dosyalar": [Rect2(840, 540, 290, 220), "Gizli Dosyalar"],
	"medya": [Rect2(1180, 470, 320, 300), "Medya"],
}

var mobile := false
var portrait_fn: Callable   # id -> Texture2D
var _stage: Control
var _objects: Dictionary = {}
var _badges: Dictionary = {}
var _title: Label
var _sub: Label
var _open_btn: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()


func _fit() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = get_parent_area_size()


func open() -> void:
	_fit()
	_build()
	show()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.35)
	var i := 0
	for id in _objects:
		var o: Control = _objects[id]
		var target_y := o.position.y
		o.position.y += 30.0
		o.modulate.a = 0.0
		var tw := o.create_tween().set_parallel(true)
		tw.tween_property(o, "position:y", target_y, 0.45).set_delay(0.06 * i).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(o, "modulate:a", 1.0, 0.35).set_delay(0.06 * i)
		i += 1


func close_view() -> void:
	hide()


## Test için: bir nesnenin ekran üzerindeki merkezi.
func object_center(id: String) -> Vector2:
	var o: Control = _objects.get(id)
	return o.get_global_rect().get_center() if o else Vector2.ZERO


func _art(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_objects.clear()
	_badges.clear()
	var bg := TextureRect.new()
	bg.texture = _art("res://art/bg_desk.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.015, 0.025, 0.35)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	# Nesneler 1600x900 tabanında yerleşir, ekran boyuna göre ölçeklenir.
	_stage = Control.new()
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	var scale_f := minf(size.x / 1600.0, size.y / 900.0)
	_stage.scale = Vector2(scale_f, scale_f)
	_stage.position = (size - Vector2(1600, 900) * scale_f) / 2.0
	_stage.size = Vector2(1600, 900)
	for id in LAYOUT:
		_make_object(id)
	# Başlık
	var top := VBoxContainer.new()
	top.position = Vector2(0, 26)
	top.size = Vector2(1600, 100)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(top)
	_title = Label.new()
	_title.text = "HAFTA %d   ·   KRAL ADRİAN IV" % Sim.week
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_override("font", UIKit.serif())
	_title.add_theme_font_size_override("font_size", 34)
	_title.add_theme_color_override("font_color", UIKit.GOLD)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_title.add_theme_constant_override("shadow_outline_size", 8)
	top.add_child(_title)
	_sub = Label.new()
	var news := ""
	if not Sim.weekly_news.is_empty():
		news = str(Sim.weekly_news[0])
	_sub.text = news if news != "" else "Masada yeni dosyalar var."
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.add_theme_font_size_override("font_size", 17)
	_sub.add_theme_color_override("font_color", Color("e8dcc0"))
	_sub.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_sub.add_theme_constant_override("shadow_outline_size", 6)
	top.add_child(_sub)
	# Alt düğme
	_open_btn = Button.new()
	_open_btn.theme_type_variation = "PrimaryButton"
	var n := Sim.pending.size()
	_open_btn.text = ("%d KARAR BEKLİYOR   ·   GÜNDEMİ AÇ   »" % n) if n > 0 else "GÜNDEMİ AÇ   »"
	_open_btn.position = Vector2(480, 805)
	_open_btn.size = Vector2(640, 62)
	_open_btn.focus_mode = Control.FOCUS_NONE
	_open_btn.pressed.connect(func() -> void: _go("gundem"))
	_stage.add_child(_open_btn)


func _go(target: String) -> void:
	Sfx.play("paper", -4.0)
	request.emit(target)


func _make_object(id: String) -> void:
	var spec: Array = LAYOUT[id]
	var r: Rect2 = spec[0]
	var holder := Control.new()
	holder.position = r.position
	holder.size = r.size
	holder.pivot_offset = r.size / 2.0
	holder.mouse_filter = Control.MOUSE_FILTER_STOP
	holder.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_stage.add_child(holder)
	_objects[id] = holder
	var tex := _art("res://art/desk/%s.png" % id)
	var visual: Control
	if tex:
		var t := TextureRect.new()
		t.texture = tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		visual = t
	else:
		visual = _draw_object(id, r.size)
	visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(visual)
	_ignore_mouse(visual)  # iç parçalar tıklamayı yutmasın; tıklama nesneye (holder) ulaşsın
	# Etiket
	var plate := Label.new()
	plate.text = str(spec[1])
	plate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plate.add_theme_font_override("font", UIKit.serif())
	plate.add_theme_font_size_override("font_size", 22)
	plate.add_theme_color_override("font_color", Color("f1e6c8"))
	plate.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	plate.add_theme_constant_override("shadow_outline_size", 8)
	plate.position = Vector2(0, r.size.y + 4)
	plate.size = Vector2(r.size.x, 30)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(plate)
	# Rozet
	var badge_text := _badge_text(id)
	if badge_text != "":
		var b := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("a3251b")
		sb.border_color = Color("f1d9a0")
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(16)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
		b.add_theme_stylebox_override("panel", sb)
		var bl := Label.new()
		bl.text = badge_text
		bl.add_theme_font_size_override("font_size", 15)
		bl.add_theme_color_override("font_color", Color.WHITE)
		b.add_child(bl)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(b)
		b.position = Vector2(r.size.x - 70, 18)
		var pulse := b.create_tween().set_loops()
		pulse.tween_property(b, "modulate", Color(1.25, 1.25, 1.25), 0.8).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(b, "modulate", Color.WHITE, 0.8).set_trans(Tween.TRANS_SINE)
	holder.mouse_entered.connect(func() -> void:
		Sfx.play("hover", -10.0)
		var tw := holder.create_tween().set_parallel(true)
		tw.tween_property(holder, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_SINE)
		tw.tween_property(holder, "modulate", Color(1.15, 1.1, 1.0), 0.18))
	holder.mouse_exited.connect(func() -> void:
		var tw := holder.create_tween().set_parallel(true)
		tw.tween_property(holder, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE)
		tw.tween_property(holder, "modulate", Color.WHITE, 0.2))
	holder.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			Sfx.play("click")
			_go(id))


func _ignore_mouse(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_ignore_mouse(c)


func _badge_text(id: String) -> String:
	match id:
		"gundem":
			return str(Sim.pending.size()) if not Sim.pending.is_empty() else ""
		"medya":
			return "YENİ"
		"kisiler":
			return "%d mesai" % Sim.mesai
		"gunluk":
			var due := 0
			for p in Sim.promises:
				if p["state"] == "active" and int(p["due"]) - Sim.week <= 2:
					due += 1
			return ("%d söz" % due) if due > 0 else ""
		"dosyalar":
			var rumors := 0
			for f: Dictionary in Sim.facts.values():
				if f.get("rumor", false) and not f.get("public", false):
					rumors += 1
			return ("%d dedikodu" % rumors) if rumors > 0 else ""
	return ""


# ---------------------------------------------------------------- Kodla çizilen nesneler

func _panel(bg: Color, border: Color, radius := 6, bw := 2, shadow := 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, 0.55)
	s.shadow_size = shadow
	s.shadow_offset = Vector2(4, 8)
	s.anti_aliasing = true
	return s


func _draw_object(id: String, sz: Vector2) -> Control:
	var root := Control.new()
	match id:
		"gundem":
			# Mühürlü mektup yığını
			for i in 3:
				var p := Panel.new()
				p.add_theme_stylebox_override("panel", _panel(PARCH.darkened(0.06 * (2 - i)), Color("a89772"), 3, 1))
				p.position = Vector2(20 + i * 6, 30 - i * 8)
				p.size = sz - Vector2(60, 70)
				p.rotation = deg_to_rad(-4 + i * 3)
				root.add_child(p)
			var string_h := ColorRect.new()
			string_h.color = Color("7b5a34")
			string_h.position = Vector2(30, sz.y / 2 - 22)
			string_h.size = Vector2(sz.x - 70, 3)
			root.add_child(string_h)
			root.add_child(_seal(Vector2(sz.x / 2 - 34, sz.y / 2 - 56), 62))
		"medya":
			var paper := PanelContainer.new()
			paper.add_theme_stylebox_override("panel", _panel(Color("e9e0c9"), Color("b9ad90"), 2, 1))
			paper.position = Vector2(10, 10)
			paper.size = sz - Vector2(20, 20)
			paper.rotation = deg_to_rad(3)
			root.add_child(paper)
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 4)
			paper.add_child(v)
			var m := _ink("VELORİA HABER", 26, true)
			m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v.add_child(m)
			var rule := ColorRect.new()
			rule.color = INK
			rule.custom_minimum_size.y = 2
			v.add_child(rule)
			var ed: Dictionary = Press.edition(Sim, "state")
			var h := _ink(str(ed.get("headline", "")), 19, true)
			h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			v.add_child(h)
			var b := _ink(str(ed.get("lead", "")), 11, false)
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			b.size_flags_vertical = Control.SIZE_EXPAND_FILL
			b.clip_text = true
			v.add_child(b)
		"kisiler":
			var phone := PanelContainer.new()
			phone.add_theme_stylebox_override("panel", _panel(Color("15131a"), UIKit.GOLD_DIM, 10, 2))
			phone.set_anchors_preset(Control.PRESET_FULL_RECT)
			root.add_child(phone)
			var grid := GridContainer.new()
			grid.columns = 3
			grid.add_theme_constant_override("h_separation", 6)
			grid.add_theme_constant_override("v_separation", 6)
			phone.add_child(grid)
			for aid in Sim.actors:
				var t := TextureRect.new()
				t.texture = portrait_fn.call(aid) if portrait_fn.is_valid() else null
				t.custom_minimum_size = Vector2(84, 62)
				t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				grid.add_child(t)
		"gunluk":
			var book := Panel.new()
			book.add_theme_stylebox_override("panel", _panel(Color("3b2416"), Color("b08a45"), 8, 3))
			book.position = Vector2(20, 10)
			book.size = sz - Vector2(40, 20)
			book.rotation = deg_to_rad(-3)
			root.add_child(book)
			var spine := ColorRect.new()
			spine.color = Color("2a190f")
			spine.position = Vector2(20, 10)
			spine.size = Vector2(26, sz.y - 20)
			spine.rotation = deg_to_rad(-3)
			root.add_child(spine)
			var crest := _ink("V", 96, true)
			crest.add_theme_color_override("font_color", Color("c9a24f"))
			crest.position = Vector2(sz.x / 2 - 30, sz.y / 2 - 70)
			root.add_child(crest)
		"dosyalar":
			var folder := Panel.new()
			folder.add_theme_stylebox_override("panel", _panel(Color("c9a46a"), Color("8a6a3a"), 4, 2))
			folder.position = Vector2(10, 30)
			folder.size = sz - Vector2(20, 40)
			folder.rotation = deg_to_rad(2)
			root.add_child(folder)
			var tab := Panel.new()
			tab.add_theme_stylebox_override("panel", _panel(Color("c9a46a"), Color("8a6a3a"), 4, 2, 0))
			tab.position = Vector2(24, 12)
			tab.size = Vector2(110, 30)
			root.add_child(tab)
			var thread := ColorRect.new()
			thread.color = Color("a3251b")
			thread.position = Vector2(sz.x / 2, 30)
			thread.size = Vector2(3, sz.y - 40)
			thread.rotation = deg_to_rad(18)
			root.add_child(thread)
			var stamp := _ink("GİZLİ", 30, true)
			stamp.add_theme_color_override("font_color", Color("8e1f17"))
			stamp.position = Vector2(sz.x / 2 - 40, sz.y / 2 - 10)
			stamp.rotation = deg_to_rad(-12)
			root.add_child(stamp)
		"hanedan":
			var frame := PanelContainer.new()
			var fs := _panel(Color("1a1410"), Color("c9a24f"), 4, 8)
			fs.set_content_margin_all(14)
			frame.add_theme_stylebox_override("panel", fs)
			frame.set_anchors_preset(Control.PRESET_FULL_RECT)
			root.add_child(frame)
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 4)
			frame.add_child(row)
			for pid in ["king", "prens"]:
				var t := TextureRect.new()
				t.texture = portrait_fn.call(pid) if portrait_fn.is_valid() else null
				t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				row.add_child(t)
		"harita":
			var map := Panel.new()
			map.add_theme_stylebox_override("panel", _panel(Color("d9c9a3"), Color("8f7a50"), 3, 2))
			map.set_anchors_preset(Control.PRESET_FULL_RECT)
			root.add_child(map)
			var lines := Control.new()
			lines.set_anchors_preset(Control.PRESET_FULL_RECT)
			lines.draw.connect(func() -> void:
				var rng := RandomNumberGenerator.new()
				rng.seed = 42
				var col := Color(0.35, 0.28, 0.18, 0.55)
				# Nehir
				var river := PackedVector2Array()
				for i in 12:
					river.append(Vector2(sz.x * i / 11.0, sz.y * 0.62 + sin(i * 0.9) * 26.0))
				lines.draw_polyline(river, Color(0.3, 0.38, 0.45, 0.6), 10.0, true)
				# Sokaklar
				for i in 26:
					var a := Vector2(rng.randf() * sz.x, rng.randf() * sz.y)
					var b := a + Vector2(rng.randf_range(-120, 120), rng.randf_range(-80, 80))
					lines.draw_line(a, b, col, 1.5)
				# Kurumlar
				for p in [Vector2(0.5, 0.18), Vector2(0.22, 0.42), Vector2(0.78, 0.4), Vector2(0.5, 0.82), Vector2(0.3, 0.75), Vector2(0.72, 0.78)]:
					lines.draw_circle(Vector2(p.x * sz.x, p.y * sz.y), 9.0, Color("7a2a1e"))
					lines.draw_circle(Vector2(p.x * sz.x, p.y * sz.y), 4.0, Color("e6dcc2")))
			map.add_child(lines)
			var t := _ink("BAŞKENT", 34, true)
			t.position = Vector2(20, 12)
			map.add_child(t)
	return root


func _ink(text: String, size: int, serif: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", INK)
	if serif:
		l.add_theme_font_override("font", UIKit.serif())
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _seal(pos: Vector2, d: float) -> Control:
	var seal := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("7a1f1a")
	sb.set_corner_radius_all(int(d / 2))
	sb.border_color = Color("c9a24f")
	sb.set_border_width_all(2)
	sb.anti_aliasing = true
	seal.add_theme_stylebox_override("panel", sb)
	seal.position = pos
	seal.size = Vector2(d, d)
	seal.custom_minimum_size = Vector2(d, d)
	var l := Label.new()
	l.text = "V"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", UIKit.serif())
	l.add_theme_font_size_override("font_size", int(d * 0.55))
	l.add_theme_color_override("font_color", Color("f1d9a0"))
	seal.add_child(l)
	return seal
