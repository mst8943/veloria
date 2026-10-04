extends Control
## Başkent Haritası: kurumlar birer bina. res://art/city_map.png varsa o kullanılır,
## bina konumları res://game/data/city_map.json ile ayarlanabilir; yoksa şehir kodla çizilir.

signal request(target: String, arg: String)

const UIKit := preload("res://game/ui/ui_kit.gd")

const SITES := {
	"saray": {"pos": Vector2(0.5, 0.16), "title": "SARAY", "sub": "Çalışma odası ve taht", "actor": "dorn", "art": "toren"},
	"adliye": {"pos": Vector2(0.22, 0.38), "title": "ADLİYE", "sub": "Soruşturmalar ve hukuk", "actor": "falk", "art": "yargic_dosya"},
	"parlamento": {"pos": Vector2(0.78, 0.38), "title": "PARLAMENTO", "sub": "Yasalar ve siyasi bloklar", "actor": "brandt", "art": "erken_secim"},
	"genelkurmay": {"pos": Vector2(0.15, 0.7), "title": "GENELKURMAY", "sub": "Ordu ve komuta", "actor": "arden", "art": "general_atamalari"},
	"medya": {"pos": Vector2(0.5, 0.62), "title": "MEDYA MERKEZİ", "sub": "Basın ve kamuoyu", "actor": "lena", "art": "halden_kanal"},
	"istihbarat": {"pos": Vector2(0.85, 0.7), "title": "İSTİHBARAT", "sub": "Arşivler ve dosyalar", "actor": "voss", "art": "voss_dosyalar"},
	"holding": {"pos": Vector2(0.5, 0.88), "title": "HALDEN HOLDİNG", "sub": "Sermaye, ihaleler, borçlar", "actor": "halden", "art": "halden_ihale"},
}

var mobile := false
var art_fn: Callable
var portrait_fn: Callable
var _drawer: PanelContainer
var _drawer_body: VBoxContainer
var _canvas: Control
var _lights: Array = []
var _sites: Dictionary = {}
var plates: Dictionary = {}   # kurum id -> etiket (test ve konumlandırma için)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_sites = SITES.duplicate(true)
	_load_overrides()
	hide()


func _load_overrides() -> void:
	var path := "res://game/data/city_map.json"
	if not FileAccess.file_exists(path):
		return
	var d: Variant = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	if d is Dictionary:
		for k in d:
			if _sites.has(k) and d[k] is Array and d[k].size() == 2:
				_sites[k]["pos"] = Vector2(float(d[k][0]), float(d[k][1]))


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if visible and k and k.pressed and not k.echo and k.keycode == KEY_ESCAPE:
		if _drawer and _drawer.visible:
			_drawer.hide()
		else:
			close_view()
		get_viewport().set_input_as_handled()


func open() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = get_parent_area_size()
	_build()
	show()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)


func close_view() -> void:
	hide()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	var tex: Texture2D = load("res://art/city_map.png") if ResourceLoader.exists("res://art/city_map.png") else null
	if tex:
		var bg := TextureRect.new()
		bg.texture = tex
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
		bg.resized.connect(func() -> void: bg.pivot_offset = bg.size / 2.0)
		var kb := bg.create_tween().set_loops()
		kb.tween_property(bg, "scale", Vector2(1.04, 1.04), 24.0).set_trans(Tween.TRANS_SINE)
		kb.tween_property(bg, "scale", Vector2.ONE, 24.0).set_trans(Tween.TRANS_SINE)
	else:
		_canvas = Control.new()
		_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
		_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_canvas.draw.connect(_draw_city)
		add_child(_canvas)
		_make_lights()
		var tw := _canvas.create_tween().set_loops()
		tw.tween_interval(0.45)
		tw.tween_callback(_canvas.queue_redraw)
	var vig := ColorRect.new()
	vig.color = Color(0, 0, 0, 0.18)
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vig)
	# Üst başlık ve geri
	var band := PanelContainer.new()
	band.add_theme_stylebox_override("panel", UIKit.band_style())
	band.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 18)
	add_child(band)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	band.add_child(top)
	var title := Label.new()
	title.text = "BAŞKENT"
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_outline_size", 8)
	top.add_child(title)
	var hint := Label.new()
	hint.text = "Bir kuruma tıkla"
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hint.add_theme_color_override("font_color", Color("cfc6b0"))
	top.add_child(hint)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	var back := Button.new()
	back.text = "Masaya dön  (Esc)" if not mobile else "Masaya dön"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size = Vector2(170, 42)
	back.theme_type_variation = "GhostButton"
	back.pressed.connect(close_view)
	top.add_child(back)
	for id in _sites:
		_make_site(id)
	_build_drawer()


func _make_site(id: String) -> void:
	var s: Dictionary = _sites[id]
	var plate := PanelContainer.new()
	var sb := UIKit.box(Color(0.04, 0.035, 0.05, 0.86), Color(UIKit.GOLD, 0.55), 6, 14)
	plate.add_theme_stylebox_override("panel", sb)
	plate.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_child(plate)
	plates[id] = plate
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 0)
	plate.add_child(v)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(row)
	var dot := Panel.new()
	var ds := StyleBoxFlat.new()
	ds.bg_color = UIKit.GOLD
	ds.set_corner_radius_all(6)
	dot.add_theme_stylebox_override("panel", ds)
	dot.custom_minimum_size = Vector2(11, 11)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dot)
	var t := Label.new()
	t.text = str(s["title"])
	t.add_theme_font_override("font", UIKit.serif())
	t.add_theme_font_size_override("font_size", 22 if not mobile else 26)
	t.add_theme_color_override("font_color", Color("f1e6c8"))
	row.add_child(t)
	var sub := Label.new()
	sub.text = str(s["sub"])
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13 if not mobile else 16)
	sub.add_theme_color_override("font_color", Color("b9b1a0"))
	v.add_child(sub)
	for c in plate.find_children("*", "Control", true, false):
		(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Konum: yüzdelik nokta etiketin merkezi olur
	var place := func() -> void:
		var p: Vector2 = s["pos"]
		plate.position = Vector2(p.x * size.x, p.y * size.y) - plate.size / 2.0
	plate.resized.connect(place)
	place.call_deferred()
	var blink := dot.create_tween().set_loops()
	blink.tween_property(dot, "modulate:a", 0.4, 0.9 + randf() * 0.5)
	blink.tween_property(dot, "modulate:a", 1.0, 0.9)
	plate.mouse_entered.connect(func() -> void:
		Sfx.play("hover", -10.0)
		sb.border_color = UIKit.GOLD
		sb.bg_color = Color(0.1, 0.08, 0.05, 0.92)
		plate.pivot_offset = plate.size / 2.0
		plate.create_tween().tween_property(plate, "scale", Vector2(1.06, 1.06), 0.15))
	plate.mouse_exited.connect(func() -> void:
		sb.border_color = Color(UIKit.GOLD, 0.55)
		sb.bg_color = Color(0.04, 0.035, 0.05, 0.86)
		plate.create_tween().tween_property(plate, "scale", Vector2.ONE, 0.15))
	plate.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			Sfx.play("click")
			if id == "saray":
				close_view()
			else:
				show_site(id))


# ---------------------------------------------------------------- Kurum paneli

func _build_drawer() -> void:
	_drawer = PanelContainer.new()
	_drawer.add_theme_stylebox_override("panel", UIKit.box(Color(0.04, 0.035, 0.05, 0.96), UIKit.GOLD, 10, 20))
	var w := 560.0 if not mobile else 620.0
	_drawer.anchor_left = 1.0
	_drawer.anchor_right = 1.0
	_drawer.anchor_top = 0.0
	_drawer.anchor_bottom = 1.0
	_drawer.offset_left = -w - 20
	_drawer.offset_right = -20
	_drawer.offset_top = 86
	_drawer.offset_bottom = -20
	add_child(_drawer)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_drawer.add_child(scroll)
	_drawer_body = VBoxContainer.new()
	_drawer_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drawer_body.add_theme_constant_override("separation", 12)
	scroll.add_child(_drawer_body)
	_drawer.hide()


func _report_of(actor_id: String) -> String:
	for r: Dictionary in Sim.reports:
		if r["source"] == actor_id:
			return str(r["text"])
	return "Bu hafta bu makamdan rapor gelmedi."


func show_site(id: String) -> void:
	var s: Dictionary = _sites[id]
	for c in _drawer_body.get_children():
		c.queue_free()
	var tex: Texture2D = art_fn.call(str(s["art"])) if art_fn.is_valid() else null
	if tex:
		var frame := Control.new()
		frame.custom_minimum_size = Vector2(0, 220)
		frame.clip_contents = true
		_drawer_body.add_child(frame)
		var img := TextureRect.new()
		img.texture = tex
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		frame.add_child(img)
	var t := Label.new()
	t.text = str(s["title"])
	t.add_theme_font_override("font", UIKit.serif())
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", UIKit.GOLD)
	_drawer_body.add_child(t)
	_drawer_body.add_child(_text("[color=gray]%s[/color]" % s["sub"]))
	var aid: String = s["actor"]
	if Sim.actors.has(aid):
		var a = Sim.actors[aid]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		_drawer_body.add_child(row)
		var pt := TextureRect.new()
		pt.texture = portrait_fn.call(aid) if portrait_fn.is_valid() else null
		pt.custom_minimum_size = Vector2(96, 96)
		pt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		row.add_child(pt)
		var info := _text("[b]%s[/b]\n[color=gray]%s[/color]\n\"%s\"" % [a.display_name, a.title, _report_of(aid)])
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
	else:
		_drawer_body.add_child(_text("[color=#c0504a]Bu makam boş. Sahibi artık sarayda değil.[/color]"))
	_drawer_body.add_child(_text(_site_details(id)))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	_drawer_body.add_child(actions)
	if Sim.actors.has(aid):
		actions.add_child(_btn("Kişiyle ilgilen", func() -> void: request.emit("actor", aid)))
	if id == "medya":
		actions.add_child(_btn("Gazeteleri oku", func() -> void: request.emit("media", "")))
	if id == "adliye" or id == "istihbarat":
		actions.add_child(_btn("Dosyaları aç", func() -> void: request.emit("files", "")))
	actions.add_child(_btn("Kapat", func() -> void: _drawer.hide()))
	_drawer.show()
	_drawer.modulate.a = 0.0
	var tw := _drawer.create_tween().set_parallel(true)
	tw.tween_property(_drawer, "modulate:a", 1.0, 0.25)
	Sfx.play("paper", -6.0)


func _site_details(id: String) -> String:
	match id:
		"adliye":
			var total := 0
			var public := 0
			for f: Dictionary in Sim.facts.values():
				if f["subject"] == "king":
					total += 1
					public += 1 if f.get("public", false) else 0
			return "Saraya uzanan dosyalar: [b]%d[/b] (kamuya açık: %d).\nHer dosya, yargının sana yaklaşan bir adımıdır." % [total, public]
		"parlamento":
			var active := 0
			for p in Sim.promises:
				if p["state"] == "active":
					active += 1
			return "Meclis kulislerinde verilmiş ve henüz tutulmamış sözlerin: [b]%d[/b].\nMuhalefet her sözü sayar." % active
		"genelkurmay":
			return "Ordunun kime sadık olduğu, ne kadar güçlü olduğundan daha önemlidir."
		"istihbarat":
			return "Araştırma yaptırırsan zayıf noktaları bulur. Ama öğrendiği her şeyi saklar."
		"medya":
			return "Halden'in kanalları ve Lena'nın gazetesi aynı haftayı farklı anlatır. Karşılaştır."
		"holding":
			if Sim.actors.has("halden") and Sim.actors["halden"].obligation >= 8.0:
				return "Halden sana yaptıklarının karşılığını bekliyor. Borç defterin onun masasında."
			return "Halden Holding enerji, inşaat ve medyada faaliyet gösteriyor."
	return ""


func _text(bb: String) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.text = bb
	return r


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size.y = 42
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(func() -> void:
		Sfx.play("click")
		cb.call())
	return b


# ---------------------------------------------------------------- Kodla çizilen gece şehri

func _make_lights() -> void:
	_lights.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 1400:
		# Işıklar kurum çevrelerinde ve nehir boyunda yoğunlaşır
		var p := Vector2(rng.randf(), rng.randf())
		if rng.randf() < 0.55:
			var keys := SITES.keys()
			var c: Vector2 = SITES[keys[rng.randi() % keys.size()]]["pos"]
			p = c + Vector2(rng.randfn(0, 0.07), rng.randfn(0, 0.06))
		_lights.append([p, rng.randf_range(0.6, 2.2), rng.randf()])


func _draw_city() -> void:
	var s := _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, s), Color("07080d"))
	# Nehir
	var river := PackedVector2Array()
	for i in 30:
		var x := s.x * i / 29.0
		river.append(Vector2(x, s.y * 0.53 + sin(i * 0.45) * s.y * 0.05))
	_canvas.draw_polyline(river, Color("0d1a2a"), s.y * 0.05, true)
	_canvas.draw_polyline(river, Color(0.25, 0.35, 0.5, 0.25), 2.0, true)
	# Bulvarlar: saraydan kurumlara
	var palace: Vector2 = SITES["saray"]["pos"] * s
	for id in SITES:
		var p: Vector2 = SITES[id]["pos"] * s
		_canvas.draw_line(palace, p, Color(0.85, 0.62, 0.3, 0.22), 3.0, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 70:
		var a := Vector2(rng.randf() * s.x, rng.randf() * s.y)
		var b := a + Vector2(rng.randf_range(-260, 260), rng.randf_range(-140, 140))
		_canvas.draw_line(a, b, Color(0.8, 0.6, 0.35, 0.08), 1.5, true)
	# Kurum ışık halkaları
	for id in SITES:
		var p: Vector2 = SITES[id]["pos"] * s
		for k in 6:
			_canvas.draw_circle(p, 90.0 - k * 14.0, Color(0.95, 0.7, 0.35, 0.025 + k * 0.012))
	# Pencere ışıkları (hafif titreşim)
	var t := Time.get_ticks_msec() / 1000.0
	for l in _lights:
		var p: Vector2 = l[0] * s
		var flick := 0.55 + 0.45 * sin(t * 1.3 + float(l[2]) * 40.0)
		_canvas.draw_circle(p, float(l[1]), Color(1.0, 0.78, 0.45, 0.35 + 0.4 * flick))
