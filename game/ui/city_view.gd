extends Control
## Başkent Haritası: kurumlar birer bina. res://art/city_map.png varsa o kullanılır,
## bina konumları res://game/data/city_map.json ile ayarlanabilir; yoksa şehir kodla çizilir.

signal request(target: String, arg: String)

const UIKit := preload("res://game/ui/ui_kit.gd")

const SITES := {
	"saray": {"pos": Vector2(0.5, 0.16), "title": "SARAY", "sub": "Çalışma odası ve taht", "actor": "dorn", "art": "toren"},
	"adliye": {"pos": Vector2(0.22, 0.38), "title": "ADLİYE", "sub": "Soruşturmalar ve hukuk", "actor": "falk", "art": "yargic_dosya"},
	"maliye": {"pos": Vector2(0.32, 0.58), "title": "MALİYE BAKANLIĞI", "sub": "Kasa ve vergi defterleri", "actor": "kessler", "art": "butce_acigi"},
	"parlamento": {"pos": Vector2(0.78, 0.38), "title": "PARLAMENTO", "sub": "Yasalar ve siyasi bloklar", "actor": "brandt", "art": "erken_secim"},
	"genelkurmay": {"pos": Vector2(0.15, 0.7), "title": "GENELKURMAY", "sub": "Ordu ve komuta", "actor": "arden", "art": "general_atamalari"},
	"medya": {"pos": Vector2(0.5, 0.62), "title": "MEDYA MERKEZİ", "sub": "Basın ve kamuoyu", "actor": "lena", "art": "halden_kanal"},
	"istihbarat": {"pos": Vector2(0.85, 0.7), "title": "İSTİHBARAT", "sub": "Arşivler ve dosyalar", "actor": "voss", "art": "voss_dosyalar"},
	"holding": {"pos": Vector2(0.5, 0.88), "title": "SARNE HOLDİNG", "sub": "Sermaye, ihaleler, borçlar", "actor": "halden", "art": "halden_ihale"},
	"asteria": {"pos": Vector2(0.68, 0.17), "title": "ASTERIA ELÇİLİĞİ", "sub": "Kredi ve hukuk diplomasisi", "actor": "claire", "art": "yabanci_elci"},
	"drakon": {"pos": Vector2(0.32, 0.82), "title": "DRAKON ELÇİLİĞİ", "sub": "Sınır ve güvenlik", "actor": "malenkov", "art": "sinir_krizi"},
	"seravia": {"pos": Vector2(0.74, 0.85), "title": "SERAVIA TEMSİLCİLİĞİ", "sub": "Ticaret ve limanlar", "actor": "lucien", "art": "yabanci_elci"},
}

## Telefonda etiketler çakışmasın: 3 sütun x 4 satır düzeni (kentin gerçek dağılımından bağımsız, okunur).
const MOBILE_POS := {
	"adliye": Vector2(0.17, 0.25), "saray": Vector2(0.50, 0.25), "parlamento": Vector2(0.83, 0.25),
	"maliye": Vector2(0.17, 0.45), "medya": Vector2(0.50, 0.45), "asteria": Vector2(0.83, 0.45),
	"genelkurmay": Vector2(0.17, 0.65), "holding": Vector2(0.50, 0.65), "istihbarat": Vector2(0.83, 0.65),
	"drakon": Vector2(0.30, 0.85), "seravia": Vector2(0.70, 0.85),
}
const REGION_POS := {"capital": Vector2(0.06, 0.52), "industry": Vector2(0.94, 0.52), "farmland": Vector2(0.06, 0.88), "border": Vector2(0.94, 0.88)}
const MOBILE_REGION_POS := {"capital": Vector2(0.04, 0.31), "industry": Vector2(0.96, 0.31), "farmland": Vector2(0.038, 0.70), "border": Vector2(0.96, 0.70)}

var mobile := false
var art_fn: Callable
var portrait_fn: Callable
var _drawer: PanelContainer
var _drawer_body: VBoxContainer
var _canvas: Control
var _lights: Array = []
var _sites: Dictionary = {}
var _region_positions: Dictionary = {}
var _mobile_region_positions: Dictionary = {}
var _region_buttons: Dictionary = {}
var _regions_visible := false
var _region_toggle: Button
var _region_action_button: Button
var _region_panel_id := ""
var plates: Dictionary = {}   # kurum id -> etiket (test ve konumlandırma için)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_background_input)
	_sites = SITES.duplicate(true)
	_load_overrides()
	hide()


func _on_background_input(event: InputEvent) -> void:
	if not visible or not _drawer or not _drawer.visible:
		return
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		if not _drawer.get_global_rect().has_point(event.position):
			_drawer.hide()


func _load_overrides() -> void:
	var path := "res://game/data/city_map.json"
	if not FileAccess.file_exists(path):
		return
	var d: Variant = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	if d is Dictionary:
		for k in d:
			if _sites.has(k) and d[k] is Array and d[k].size() == 2:
				_sites[k]["pos"] = Vector2(float(d[k][0]), float(d[k][1]))
		_region_positions = _vector_positions(d.get("regions", {}), REGION_POS)
		_mobile_region_positions = _vector_positions(d.get("mobile_regions", {}), MOBILE_REGION_POS)


func _vector_positions(raw: Variant, defaults: Dictionary) -> Dictionary:
	var result := defaults.duplicate(true)
	if raw is Dictionary:
		for id in raw:
			if result.has(id) and raw[id] is Array and raw[id].size() == 2:
				result[id] = Vector2(float(raw[id][0]), float(raw[id][1]))
	return result


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
	_build()
	show()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)


func close_view() -> void:
	hide()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	plates.clear()
	_region_buttons.clear()
	_regions_visible = false
	_region_panel_id = ""
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
	title.text = tr("BAŞKENT")
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_outline_size", 8)
	top.add_child(title)
	var hint := Label.new()
	hint.text = tr("Bir kuruma tıkla")
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hint.add_theme_color_override("font_color", Color("cfc6b0"))
	top.add_child(hint)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	_region_toggle = Button.new()
	_region_toggle.toggle_mode = true
	_region_toggle.text = tr("Bölgeler: Kapalı")
	_region_toggle.tooltip_text = tr("Bölge katmanını aç/kapat")
	_region_toggle.custom_minimum_size = Vector2(132, 44)
	_region_toggle.toggled.connect(_set_region_layer)
	top.add_child(_region_toggle)
	var back := Button.new()
	back.text = tr("Masaya dön  (Esc)") if not mobile else tr("Masaya dön")
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size = Vector2(170, 42)
	back.theme_type_variation = "GhostButton"
	back.pressed.connect(close_view)
	top.add_child(back)
	for id in _sites:
		_make_site(id)
	for id in Sim.REGION_WEIGHTS:
		_make_region_marker(str(id))
	_build_drawer()


func _make_site(id: String) -> void:
	var s: Dictionary = _sites[id]
	var plate := PanelContainer.new()
	var sb := UIKit.box(Color(UIKit.PLATE, 0.86), Color(UIKit.GOLD, 0.55), 6, 14)
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
	t.text = tr(str(s["title"]))
	t.add_theme_font_override("font", UIKit.serif())
	t.add_theme_font_size_override("font_size", 22 if not mobile else 21)
	t.add_theme_color_override("font_color", Color("f1e6c8"))
	row.add_child(t)
	var sub := Label.new()
	sub.text = tr(str(s["sub"]))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13 if not mobile else 15)
	sub.add_theme_color_override("font_color", Color("b9b1a0"))
	v.add_child(sub)
	for c in plate.find_children("*", "Control", true, false):
		(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Konum: yüzdelik nokta etiketin merkezi olur
	var place := func() -> void:
		var p: Vector2 = MOBILE_POS.get(id, s["pos"]) if mobile else s["pos"]
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
		sb.bg_color = Color(UIKit.PLATE, 0.86)
		plate.create_tween().tween_property(plate, "scale", Vector2.ONE, 0.15))
	plate.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			Sfx.play("click")
			if id == "saray":
				close_view()
			else:
				show_site(id))


func _set_region_layer(enabled: bool) -> void:
	_regions_visible = enabled
	_region_toggle.text = tr("Bölgeler: Açık") if enabled else tr("Bölgeler: Kapalı")
	_region_toggle.tooltip_text = tr("Bölge katmanını aç/kapat")
	_sync_region_markers()


func _sync_region_markers() -> void:
	for marker: Button in _region_buttons.values():
		marker.visible = _regions_visible and not (_drawer and _drawer.visible)


func _make_region_marker(id: String) -> void:
	var button := Button.new()
	button.name = "Region_" + id
	button.set_meta("region_id", id)
	button.custom_minimum_size = Vector2(112, 64) if not mobile else Vector2(74, 60)
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = _region_tooltip(id)
	var normal := UIKit.box(Color(UIKit.PLATE, 0.95), Color(UIKit.GOLD, 0.85), 7, 5)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.border_color = Color(UIKit.GOLD, 1.0)
	hover.bg_color = Color(0.1, 0.08, 0.05, 0.98)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.text = ""
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 0)
	button.add_child(column)
	var name := Label.new()
	name.name = "RegionName"
	name.text = ("★ " if id == Sim.featured_region_id() else "") + _region_compact_name(id)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 12 if mobile else 14)
	name.add_theme_color_override("font_color", Color("f1e6c8"))
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(name)
	var symbols := Control.new()
	symbols.name = "StatusSymbols"
	symbols.custom_minimum_size.y = 19
	symbols.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	symbols.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var words: Dictionary = Sim.region_state_words(id)
	var levels := {"unrest": 0 if words["unrest"] == tr("huzurlu") else (1 if words["unrest"] == tr("huzursuz") else 2),
		"economy": 2 if words["economy"] == tr("canlı") else (1 if words["economy"] == tr("durgun") else 0),
		"loyalty": 2 if words["loyalty"] == tr("sağlam") else (1 if words["loyalty"] == tr("tereddütlü") else 0)}
	var has_crisis := Sim.region_has_pending_crisis(id)
	var has_governor := str(Sim.regions[id].get("governor", "")) != ""
	symbols.tooltip_text = tr("Huzursuzluk %s; pazar %s; bağlılık %s") % [words["unrest"], words["economy"], words["loyalty"]]
	symbols.draw.connect(func() -> void: _draw_region_symbols(symbols, levels, has_crisis, has_governor))
	column.add_child(symbols)
	var p: Vector2 = (_mobile_region_positions if mobile else _region_positions).get(id, REGION_POS[id])
	button.position = Vector2(p.x * size.x, p.y * size.y) - button.custom_minimum_size / 2.0
	button.visible = _regions_visible
	button.pressed.connect(func() -> void: show_region(id))
	add_child(button)
	_region_buttons[id] = button
	button.resized.connect(func() -> void: button.position = Vector2(p.x * size.x, p.y * size.y) - button.size / 2.0)
	resized.connect(func() -> void: button.position = Vector2(p.x * size.x, p.y * size.y) - button.size / 2.0)


func _draw_region_symbols(control: Control, levels: Dictionary, has_crisis: bool, has_governor: bool) -> void:
	var w := control.size.x
	var y := 10.0
	var ink := Color("ead7a6")
	# Triangle + hatch count encodes unrest without relying on hue.
	var triangle := PackedVector2Array([Vector2(5, y + 6), Vector2(12, y - 6), Vector2(19, y + 6), Vector2(5, y + 6)])
	control.draw_polyline(triangle, ink, 1.5, true)
	for i in int(levels["unrest"]):
		control.draw_line(Vector2(8 + i * 4, y + 3), Vector2(10 + i * 4, y - 1), ink, 1.5, true)
	# Market columns.
	for i in 3:
		var height := 2.0 + i * 2.0 + float(levels["economy"]) * 2.0
		control.draw_rect(Rect2(Vector2(28 + i * 4, y + 6 - height), Vector2(2, height)), ink)
	# Shield outline + internal hatch count for loyalty.
	var shield := PackedVector2Array([Vector2(43, y - 6), Vector2(54, y - 3), Vector2(53, y + 4), Vector2(48, y + 8), Vector2(43, y + 4), Vector2(43, y - 6)])
	control.draw_polyline(shield, ink, 1.5, true)
	for i in int(levels["loyalty"]):
		control.draw_line(Vector2(45, y - 2 + i * 3), Vector2(51, y - 2 + i * 3), ink, 1.0, true)
	if has_crisis:
		var x := w - (22.0 if has_governor else 12.0)
		var warn := PackedVector2Array([Vector2(x, 1), Vector2(x + 8, 15), Vector2(x - 8, 15), Vector2(x, 1)])
		control.draw_polyline(warn, Color(1.0, 0.78, 0.45), 1.5, true)
		control.draw_line(Vector2(x, 5), Vector2(x, 10), ink, 1.5, true)
		control.draw_circle(Vector2(x, 12), 0.9, ink)
	if has_governor:
		var x := w - 9.0
		control.draw_circle(Vector2(x, y - 2), 3.0, ink)
		control.draw_arc(Vector2(x, y + 7), 5.0, PI, TAU, 12, ink, 1.5, true)


func _region_compact_name(id: String) -> String:
	match id:
		"capital": return tr("Başkent")
		"industry": return tr("Sanayi")
		"farmland": return tr("Tarım")
		_: return tr("Sınır")


# ---------------------------------------------------------------- Kurum paneli

func _build_drawer() -> void:
	_drawer = PanelContainer.new()
	_drawer.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PLATE, 0.96), UIKit.GOLD, 10, 20))
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
	_drawer.visibility_changed.connect(_sync_region_markers)
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
	return tr("Bu hafta bu makamdan rapor gelmedi.")


func show_site(id: String) -> void:
	_region_panel_id = ""
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
	t.text = tr(str(s["title"]))
	t.add_theme_font_override("font", UIKit.serif())
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", UIKit.GOLD)
	_drawer_body.add_child(t)
	_drawer_body.add_child(_text("[color=gray]%s[/color]" % tr(str(s["sub"]))))
	var institutions := {"maliye": "maliye", "adliye": "hukuk", "genelkurmay": "ordu", "saray": "idare"}
	if institutions.has(id):
		var institution: String = institutions[id]
		var chief: String = str(_sites[id]["actor"])
		var chief_name: String = Sim.actors[chief].display_name if Sim.actors.has(chief) else tr("makam boş")
		_drawer_body.add_child(_text(tr("İşleyiş: [b]%s[/b]\nBaşkan: %s") % [tr(Sim.capacity_band(institution)), chief_name]))
		if id == "maliye":
			_drawer_body.add_child(_text(tr("Kasa: [b]%s[/b]") % tr(Sim.treasury_band())))
	if id == "holding":
		_drawer_body.add_child(_text(tr("Nüfuz: [b]%s[/b]\nMedya: [b]%s[/b]") % [tr(Sim.halden_influence_band()), tr(Sim.halden_mood())]))
	if id in ["asteria", "drakon", "seravia"]:
		_drawer_body.add_child(_text(tr("İlişki: [b]%s[/b]\n[color=gray]Elena'nın anlatımı iyimser olabilir; Doğrula kayıtları altı hafta açar.[/color]") % tr(Sim.foreign_band(id))))
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
		_drawer_body.add_child(_text(tr("[color=#c0504a]Bu makam boş. Sahibi artık sarayda değil.[/color]")))
	_drawer_body.add_child(_text(_site_details(id)))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	_drawer_body.add_child(actions)
	if Sim.actors.has(aid):
		actions.add_child(_btn(tr("Kişiyle ilgilen"), func() -> void: request.emit("actor", aid)))
	if id == "medya":
		actions.add_child(_btn(tr("Gazeteleri oku"), func() -> void: request.emit("media", "")))
	if id == "adliye" or id == "istihbarat":
		actions.add_child(_btn(tr("Dosyaları aç"), func() -> void: request.emit("files", "")))
	if id in ["asteria", "drakon", "seravia"]:
		actions.add_child(_btn(tr("Doğrula"), func() -> void:
			Sim.cross_check("elena")
			show_site(id)))
	actions.add_child(_btn("Kapat", func() -> void: _drawer.hide()))
	_drawer.show()
	_drawer.modulate.a = 0.0
	var tw := _drawer.create_tween().set_parallel(true)
	tw.tween_property(_drawer, "modulate:a", 1.0, 0.25)
	Sfx.play("paper", -6.0)


func show_region(id: String) -> void:
	if not Sim.regions.has(id):
		return
	_region_panel_id = id
	for c in _drawer_body.get_children():
		c.queue_free()
	var name := tr(str(Sim.REGION_NAMES[id]))
	var title := Label.new()
	title.text = name
	title.add_theme_font_override("font", UIKit.serif())
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	_drawer_body.add_child(title)
	var state := _text(Sim.region_status_line(id))
	_drawer_body.add_child(state)
	_drawer_body.add_child(_text(tr("Simgeler: üçgen huzursuzluğu, sütunlar pazarı, kalkan bağlılığı gösterir; ünlem kriz, kişi vali demektir.")))
	if Sim.featured_region_id() == id:
		_drawer_body.add_child(_text("[b]%s[/b]" % tr("Öne çıkan bölge")))
	if Sim.region_has_pending_crisis(id):
		_drawer_body.add_child(_text("[color=#f0c36a][b]%s[/b][/color]" % tr("Bölgede karar bekleyen kriz var.")))
	else:
		_drawer_body.add_child(_text(tr("Bölgede bekleyen kriz yok.")))
	var governor_id := str(Sim.regions[id].get("governor", ""))
	var governor_row := HBoxContainer.new()
	governor_row.add_theme_constant_override("separation", 12)
	_drawer_body.add_child(governor_row)
	if governor_id != "" and Sim.actors.has(governor_id):
		var portrait := TextureRect.new()
		portrait.name = "GovernorPortrait"
		portrait.texture = portrait_fn.call(governor_id) if portrait_fn.is_valid() else null
		portrait.custom_minimum_size = Vector2(72, 72)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		governor_row.add_child(portrait)
		var actor = Sim.actors[governor_id]
		var governor_name := Label.new()
		governor_name.text = "%s\n%s" % [actor.display_name, tr("Vali")]
		governor_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		governor_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		governor_row.add_child(governor_name)
	else:
		governor_row.add_child(_text("[b]%s[/b]" % tr("Vali atanmamış")))
	_drawer_body.add_child(_text("[b]%s[/b]" % tr("Açık bölge eylemleri")))
	_region_action_button = _btn(tr("Bölge kararlarını aç"), func() -> void: request.emit("region", id))
	_region_action_button.custom_minimum_size.y = 48
	_region_action_button.focus_mode = Control.FOCUS_ALL
	_region_action_button.tooltip_text = tr("Bu bölge için R1 bütçesi ve mesai kullanan kararları aç")
	_drawer_body.add_child(_region_action_button)
	for option: Dictionary in Sim.region_action_choices(id):
		var label := str(option["label"])
		if not bool(option.get("available", true)):
			label += " — " + tr("bütçe payı veya hazine yetersiz")
		_drawer_body.add_child(_text(label))
	var close := _btn(tr("Kapat"), func() -> void: _drawer.hide())
	close.custom_minimum_size.y = 48
	close.focus_mode = Control.FOCUS_ALL
	_drawer_body.add_child(close)
	_drawer.show()
	_drawer.modulate.a = 0.0
	_drawer.create_tween().tween_property(_drawer, "modulate:a", 1.0, 0.25)
	Sfx.play("paper", -6.0)


func _region_tooltip(id: String) -> String:
	var state := Sim.region_status_line(id)
	var crisis := tr("Kriz bekliyor") if Sim.region_has_pending_crisis(id) else tr("Kriz yok")
	var governor := tr("Vali atanmış") if str(Sim.regions[id].get("governor", "")) != "" else tr("Vali atanmamış")
	var feature := " · " + tr("Öne çıkan bölge") if Sim.featured_region_id() == id else ""
	return "%s\n%s\n%s · %s%s\n%s" % [tr("Bölgeyi aç: %s") % tr(str(Sim.REGION_NAMES[id])), state, crisis, governor, feature,
		tr("Simgeler: üçgen huzursuzluğu, sütunlar pazarı, kalkan bağlılığı gösterir; ünlem kriz, kişi vali demektir.")]


func _site_details(id: String) -> String:
	match id:
		"adliye":
			var total := 0
			var public := 0
			for f: Dictionary in Sim.facts.values():
				if f["subject"] == "king":
					total += 1
					public += 1 if f.get("public", false) else 0
			return tr("Saraya uzanan dosyalar: [b]%d[/b] (kamuya açık: %d).\nHer dosya, yargının sana yaklaşan bir adımıdır.") % [total, public]
		"maliye":
			return tr("Veyra bütçe defterlerini tutuyor. Saray harcamalarıyla devlet kasasını karıştırma.")
		"parlamento":
			var active := 0
			for p in Sim.promises:
				if p["state"] == "active":
					active += 1
			return tr("Meclis kulislerinde verilmiş ve henüz tutulmamış sözlerin: [b]%d[/b].\nMuhalefet her sözü sayar.") % active
		"genelkurmay":
			return tr("Ordunun kime sadık olduğu, ne kadar güçlü olduğundan daha önemlidir.")
		"istihbarat":
			return tr("Araştırma yaptırırsan zayıf noktaları bulur. Ama öğrendiği her şeyi saklar.")
		"medya":
			return tr("Sarne'nin kanalları ve Leyla'nın gazetesi aynı haftayı farklı anlatır. Karşılaştır.")
		"holding":
			if Sim.actors.has("halden") and Sim.actors["halden"].obligation >= 8.0:
				return tr("Sarne sana yaptıklarının karşılığını bekliyor. Borç defterin onun masasında.")
			return tr("Sarne Holding enerji, inşaat ve medyada faaliyet gösteriyor.")
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
	b.text = tr(text)
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
