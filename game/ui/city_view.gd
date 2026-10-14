extends Control
## Başkent Haritası: kurumlar birer bina. res://art/city_map_v3.png varsa o kullanılır,
## bina konumları res://game/data/city_map.json ile ayarlanabilir; yoksa şehir kodla çizilir.
## Parmakla / tekerlekle yakınlaştırma-kaydırma, sınırlı alan, sabit yazı boyutu (ters ölçek).

signal request(target: String, arg: String)

const UIKit := preload("res://game/ui/ui_kit.gd")
const TOUCH_SCROLL := preload("res://game/ui/touch_scroll.gd")

const SITES := {
	"saray": {"pos": Vector2(0.50, 0.15), "title": "SARAY", "sub": "Çalışma odası ve taht", "actor": "dorn", "art": "toren", "icon": "tac"},
	"adliye": {"pos": Vector2(0.15, 0.15), "title": "ADLİYE", "sub": "Soruşturmalar ve hukuk", "actor": "falk", "art": "yargic_dosya", "icon": "terazi"},
	"maliye": {"pos": Vector2(0.19, 0.39), "title": "MALİYE BAKANLIĞI", "sub": "Kasa ve vergi defterleri", "actor": "kessler", "art": "butce_acigi", "icon": "para"},
	"parlamento": {"pos": Vector2(0.85, 0.15), "title": "PARLAMENTO", "sub": "Yasalar ve siyasi bloklar", "actor": "brandt", "art": "erken_secim", "icon": "sutun"},
	"genelkurmay": {"pos": Vector2(0.18, 0.59), "title": "GENELKURMAY", "sub": "Ordu ve komuta", "actor": "arden", "art": "general_atamalari", "icon": "kilic"},
	"medya": {"pos": Vector2(0.50, 0.41), "title": "MEDYA MERKEZİ", "sub": "Basın ve kamuoyu", "actor": "lena", "art": "halden_kanal", "icon": "anten"},
	"istihbarat": {"pos": Vector2(0.85, 0.59), "title": "İSTİHBARAT", "sub": "Arşivler ve dosyalar", "actor": "voss", "art": "voss_dosyalar", "icon": "goz"},
	"holding": {"pos": Vector2(0.51, 0.64), "title": "SARNE HOLDİNG", "sub": "Sermaye, ihaleler, borçlar", "actor": "halden", "art": "halden_ihale", "icon": "grafik"},
	"asteria": {"pos": Vector2(0.85, 0.39), "title": "ASTERIA ELÇİLİĞİ", "sub": "Kredi ve hukuk diplomasisi", "actor": "claire", "art": "yabanci_elci", "icon": "pusula"},
	"drakon": {"pos": Vector2(0.30, 0.79), "title": "DRAKON ELÇİLİĞİ", "sub": "Sınır ve güvenlik", "actor": "malenkov", "art": "sinir_krizi", "icon": "ejder"},
	"seravia": {"pos": Vector2(0.75, 0.79), "title": "SERAVIA TEMSİLCİLİĞİ", "sub": "Ticaret ve limanlar", "actor": "lucien", "art": "yabanci_elci", "icon": "defne"},
}

## Telefonda etiketler çakışmasın: 3 sütun x 4 satır düzeni (kentin gerçek dağılımından bağımsız, okunur).
const MOBILE_POS := {
	"adliye": Vector2(0.17, 0.25), "saray": Vector2(0.50, 0.25), "parlamento": Vector2(0.83, 0.25),
	"maliye": Vector2(0.17, 0.45), "medya": Vector2(0.50, 0.45), "asteria": Vector2(0.83, 0.45),
	"genelkurmay": Vector2(0.17, 0.65), "holding": Vector2(0.50, 0.65), "istihbarat": Vector2(0.83, 0.65),
	"drakon": Vector2(0.30, 0.85), "seravia": Vector2(0.70, 0.85),
}
const REGION_POS := {"capital": Vector2(0.05, 0.38), "industry": Vector2(0.95, 0.48), "farmland": Vector2(0.08, 0.88), "border": Vector2(0.92, 0.88)}
const MOBILE_REGION_POS := {"capital": Vector2(0.04, 0.35), "industry": Vector2(0.96, 0.35), "farmland": Vector2(0.04, 0.75), "border": Vector2(0.96, 0.75)}

var mobile := false
var art_fn: Callable
var portrait_fn: Callable

# Harita katman ve yakınlaştırma değişkenleri
var _map_layer: Control
var zoom_scale := 1.0
var _reset_zoom_button: Button
var _is_dragging := false
var _drag_distance := 0.0
var _mouse_down_pos := Vector2.ZERO
var _last_tap_time := 0.0
var _last_tap_pos := Vector2.ZERO
var _touch_points: Dictionary = {}
var _touch_gesture_starts: Dictionary = {}
var _touch_gesture_moved := false
var _prev_pinch_dist := 0.0

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
var _legend_button: Button
var _top_band: Control
var _region_action_button: Button
var _region_panel_id := ""
var plates: Dictionary = {}   # kurum id -> etiket (test ve konumlandırma için)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_to_group("touch_map_gesture")
	gui_input.connect(_on_background_input)
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
	zoom_scale = 1.0
	_is_dragging = false
	_drag_distance = 0.0
	_touch_points.clear()

	# Harita Katmanı (Tüm kaydırılan ve yakınlaştırılan nesneler burada yer alır)
	_map_layer = Control.new()
	_map_layer.name = "MapLayer"
	_map_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_map_layer)

	# Arka plan görseli
	var tex: Texture2D = null
	if ResourceLoader.exists("res://art/city_map_v3.png"):
		tex = load("res://art/city_map_v3.png")
	elif ResourceLoader.exists("res://art/city_map.png"):
		tex = load("res://art/city_map.png")

	if tex:
		var bg := TextureRect.new()
		bg.name = "MapBackground"
		bg.texture = tex
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_map_layer.add_child(bg)
		bg.resized.connect(func() -> void: bg.pivot_offset = bg.size / 2.0)
	else:
		_canvas = Control.new()
		_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
		_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_canvas.draw.connect(_draw_city)
		_map_layer.add_child(_canvas)
		_make_lights()
		var tw := _canvas.create_tween().set_loops()
		tw.tween_interval(0.45)
		tw.tween_callback(_canvas.queue_redraw)

	var vig := ColorRect.new()
	vig.color = Color(0, 0, 0, 0.16)
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_layer.add_child(vig)

	# Kurum plakaları ve bölge işaretçileri harita katmanına eklenir
	for id in _sites:
		_make_site(id)
	for id in Sim.REGION_WEIGHTS:
		_make_region_marker(str(id))

	# Üst başlık bandı (Ekran sabiti)
	var band := PanelContainer.new()
	_top_band = band
	band.add_theme_stylebox_override("panel", UIKit.band_style())
	band.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 18)
	add_child(band)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	band.add_child(top)

	var title := Label.new()
	title.text = tr("BAŞKENT")
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_outline_size", 8)
	top.add_child(title)

	var hint := Label.new()
	hint.text = tr("Bir kuruma tıkla")
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hint.add_theme_font_override("font", UIKit.sans(470))
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color("cfc6b0"))
	top.add_child(hint)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)

	# Sıfırla Düğmesi (Yalnızca yakınlaştırılmışken görünür)
	_reset_zoom_button = Button.new()
	_reset_zoom_button.name = "ResetZoomButton"
	_reset_zoom_button.text = tr("Sıfırla")
	_reset_zoom_button.tooltip_text = tr("Harita yakınlaştırmasını ve konumunu sıfırla")
	_reset_zoom_button.custom_minimum_size = Vector2(88, 44)
	_reset_zoom_button.focus_mode = Control.FOCUS_ALL
	var rst_box := UIKit.box(Color(UIKit.PLATE, 0.92), Color(UIKit.GOLD, 0.75), 4, 10)
	var rst_box_h := UIKit.box(Color(0.12, 0.10, 0.08, 0.98), Color("fff3d0"), 4, 10)
	_reset_zoom_button.add_theme_stylebox_override("normal", rst_box)
	_reset_zoom_button.add_theme_stylebox_override("hover", rst_box_h)
	_reset_zoom_button.add_theme_stylebox_override("pressed", rst_box_h)
	_reset_zoom_button.add_theme_stylebox_override("focus", rst_box_h)
	_reset_zoom_button.add_theme_color_override("font_color", UIKit.GOLD)
	_reset_zoom_button.add_theme_font_override("font", UIKit.sans(600))
	_reset_zoom_button.pressed.connect(reset_zoom)
	_reset_zoom_button.visible = false
	top.add_child(_reset_zoom_button)

	# "?" simge açıklaması kare düğme
	_legend_button = Button.new()
	_legend_button.text = "?"
	_legend_button.tooltip_text = tr("Harita simgelerinin açıklamasını aç")
	_legend_button.custom_minimum_size = Vector2(44, 44)
	_legend_button.focus_mode = Control.FOCUS_ALL
	var btn_box := UIKit.box(Color(UIKit.PLATE, 0.92), Color(UIKit.GOLD_DIM, 0.75), 4, 8)
	var btn_box_h := UIKit.box(Color(0.12, 0.10, 0.08, 0.98), UIKit.GOLD, 4, 8)
	_legend_button.add_theme_stylebox_override("normal", btn_box)
	_legend_button.add_theme_stylebox_override("hover", btn_box_h)
	_legend_button.add_theme_stylebox_override("pressed", btn_box_h)
	_legend_button.add_theme_stylebox_override("focus", btn_box_h)
	_legend_button.add_theme_color_override("font_color", UIKit.GOLD)
	_legend_button.add_theme_font_override("font", UIKit.serif_bold())
	_legend_button.add_theme_font_size_override("font_size", 20)
	_legend_button.pressed.connect(_show_map_legend)
	top.add_child(_legend_button)

	# "Bölgeler: Kapalı / Açık" süslü düğme
	_region_toggle = Button.new()
	_region_toggle.toggle_mode = true
	_region_toggle.text = tr("Bölgeler: Kapalı")
	_region_toggle.tooltip_text = tr("Bölge katmanını aç/kapat")
	_region_toggle.custom_minimum_size = Vector2(136, 44)
	var reg_box := UIKit.box(Color(UIKit.PLATE, 0.92), Color(UIKit.GOLD_DIM, 0.75), 4, 12)
	var reg_box_h := UIKit.box(Color(0.12, 0.10, 0.08, 0.98), UIKit.GOLD, 4, 12)
	_region_toggle.add_theme_stylebox_override("normal", reg_box)
	_region_toggle.add_theme_stylebox_override("hover", reg_box_h)
	_region_toggle.add_theme_stylebox_override("pressed", reg_box_h)
	_region_toggle.add_theme_stylebox_override("focus", reg_box_h)
	_region_toggle.add_theme_color_override("font_color", UIKit.TEXT)
	_region_toggle.add_theme_font_override("font", UIKit.sans(500))
	_region_toggle.toggled.connect(_set_region_layer)
	top.add_child(_region_toggle)

	# Masaya dön düğmesi
	var back := Button.new()
	back.text = tr("Masaya dön  (Esc)") if not mobile else tr("Masaya dön")
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size = Vector2(170, 44)
	back.theme_type_variation = "GhostButton"
	back.pressed.connect(close_view)
	top.add_child(back)

	_build_drawer()
	_sync_pins_transform()


# ---------------------------------------------------------------- Yakınlaştırma & Kaydırma Motoru

func _on_background_input(event: InputEvent) -> void:
	if not visible:
		return

	# Çekmece açıkken dışarı tıklanırsa çekmece kapanır
	if _drawer and _drawer.visible:
		if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
			if not _drawer.get_global_rect().has_point(event.position):
				_drawer.hide()
				accept_event()
				return

	# 1. Pinch Gesture (Dokunmatik sıkıştırma)
	if event is InputEventMagnifyGesture:
		apply_zoom(zoom_scale * event.factor, event.position)
		accept_event()
		return

	# 2. Fare tekerleği (İmleç merkezli yakınlaştırma)
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			apply_zoom(zoom_scale * 1.15, mb.position)
			accept_event()
			return
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			apply_zoom(zoom_scale / 1.15, mb.position)
			accept_event()
			return
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_mouse_down_pos = mb.position
				_drag_distance = 0.0
				_is_dragging = false
				# Çift tıklama / çift dokunma kontrolü
				var now := Time.get_ticks_msec() / 1000.0
				if not TOUCH_SCROLL.dispatching_touch and now - _last_tap_time < 0.28 and (_mouse_down_pos - _last_tap_pos).length() < 24.0:
					if zoom_scale > 1.1:
						reset_zoom()
					else:
						apply_zoom(1.8, mb.position)
					_last_tap_time = 0.0
					accept_event()
					return
				if not TOUCH_SCROLL.dispatching_touch:
					_last_tap_time = now
					_last_tap_pos = mb.position
			else:
				if _is_dragging:
					_is_dragging = false

	# 3. Fare / Tek Parmak Sürükleme (Pan)
	if event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_drag_distance += mm.relative.length()
			if _drag_distance > 8.0:
				_is_dragging = true
			if _is_dragging:
				pan_map(mm.relative)
				accept_event()
				return

	# 4. Çoklu Dokunma (Multi-touch Pinch & Drag)
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_touch_points[st.index] = st.position
			_touch_gesture_starts[st.index] = st.position
			if _touch_points.size() == 1:
				_mouse_down_pos = st.position
				_drag_distance = 0.0
				_is_dragging = false
				var now := Time.get_ticks_msec() / 1000.0
				if now - _last_tap_time < 0.28 and (_mouse_down_pos - _last_tap_pos).length() < 28.0:
					if zoom_scale > 1.1:
						reset_zoom()
					else:
						apply_zoom(1.8, st.position)
					_last_tap_time = 0.0
					accept_event()
					return
				_last_tap_time = now
				_last_tap_pos = st.position
			elif _touch_points.size() >= 2:
				var pts := _touch_points.values()
				_prev_pinch_dist = pts[0].distance_to(pts[1])
				_is_dragging = true
		else:
			_touch_points.erase(st.index)
			_touch_gesture_starts.erase(st.index)
			if _touch_points.size() < 2:
				_prev_pinch_dist = 0.0

	if event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_touch_points[sd.index] = sd.position
		if _touch_points.size() >= 2:
			var pts := _touch_points.values()
			var dist: float = pts[0].distance_to(pts[1])
			if _prev_pinch_dist > 0.0:
				var factor := dist / _prev_pinch_dist
				var center: Vector2 = (pts[0] + pts[1]) * 0.5
				apply_zoom(zoom_scale * factor, center)
			_prev_pinch_dist = dist
			_is_dragging = true
			accept_event()
			return
		elif _touch_points.size() == 1:
			_drag_distance += sd.relative.length()
			if _drag_distance > 8.0:
				_is_dragging = true
			if _is_dragging:
				pan_map(sd.relative)
				accept_event()
				return


func _accepts_touch_position(pos: Vector2) -> bool:
	if not visible or not get_global_rect().has_point(pos):
		return false
	if _top_band and _top_band.get_global_rect().has_point(pos):
		return false
	if _drawer and _drawer.visible and _drawer.get_global_rect().has_point(pos):
		return false
	return true


## TouchScroll keeps tap activation centralized and forwards only map drag/pinch movement here.
func _handle_touch_gesture(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_points[touch.index] = touch.position
			_touch_gesture_starts[touch.index] = touch.position
			if _touch_points.size() >= 2:
				var pts := _touch_points.values()
				_prev_pinch_dist = pts[0].distance_to(pts[1])
				_touch_gesture_moved = true
				_is_dragging = true
				return true
			_touch_gesture_moved = false
			_is_dragging = false
			return false
		var moved := _touch_gesture_moved
		_touch_points.erase(touch.index)
		_touch_gesture_starts.erase(touch.index)
		if _touch_points.size() < 2:
			_prev_pinch_dist = 0.0
		if _touch_points.is_empty():
			_is_dragging = false
			_touch_gesture_moved = false
			if not moved:
				var now := Time.get_ticks_msec() / 1000.0
				if now - _last_tap_time < 0.28 and (touch.position - _last_tap_pos).length() < 28.0:
					if zoom_scale > 1.1:
						reset_zoom()
					else:
						apply_zoom(1.8, touch.position)
					_last_tap_time = 0.0
					return true
				_last_tap_time = now
				_last_tap_pos = touch.position
		return moved
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if not _touch_points.has(drag.index):
			return false
		var previous: Vector2 = _touch_points[drag.index]
		_touch_points[drag.index] = drag.position
		if _touch_points.size() >= 2:
			var pts := _touch_points.values()
			var dist: float = pts[0].distance_to(pts[1])
			if _prev_pinch_dist > 0.0:
				apply_zoom(zoom_scale * dist / _prev_pinch_dist, (pts[0] + pts[1]) * 0.5)
			_prev_pinch_dist = dist
			_touch_gesture_moved = true
			_is_dragging = true
			return true
		var start: Vector2 = _touch_gesture_starts[drag.index]
		if start.distance_to(drag.position) >= 8.0:
			_touch_gesture_moved = true
			_is_dragging = true
			pan_map(drag.position - previous)
			return true
	return false


func apply_zoom(target_scale: float, focus_point: Vector2) -> void:
	var new_scale := clampf(target_scale, 1.0, 2.5)
	if is_equal_approx(new_scale, zoom_scale):
		return

	if not _map_layer:
		return

	# Odak noktasının harita üzerindeki yerel koordinatını koru
	var local_focus := (focus_point - _map_layer.position) / zoom_scale
	zoom_scale = new_scale
	_map_layer.scale = Vector2(zoom_scale, zoom_scale)
	_map_layer.position = focus_point - local_focus * zoom_scale

	_clamp_boundaries()
	_sync_pins_transform()
	_update_reset_button()


func pan_map(delta: Vector2) -> void:
	if not _map_layer or zoom_scale <= 1.001:
		return
	_map_layer.position += delta
	_clamp_boundaries()


func _clamp_boundaries() -> void:
	if not _map_layer:
		return
	var s := size
	if zoom_scale <= 1.001:
		zoom_scale = 1.0
		_map_layer.scale = Vector2.ONE
		_map_layer.position = Vector2.ZERO
		return

	var min_x := s.x * (1.0 - zoom_scale)
	var min_y := s.y * (1.0 - zoom_scale)
	_map_layer.position.x = clampf(_map_layer.position.x, min_x, 0.0)
	_map_layer.position.y = clampf(_map_layer.position.y, min_y, 0.0)


func reset_zoom() -> void:
	if not _map_layer:
		return
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "zoom_scale", 1.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(_map_layer, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(_map_layer, "position", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(func() -> void:
		_clamp_boundaries()
		_sync_pins_transform()
		_update_reset_button()
	)
	var step_tw := create_tween().set_loops(10)
	step_tw.tween_interval(0.025)
	step_tw.tween_callback(_sync_pins_transform)


## Plaka ve bölge işaretçilerinde ters ölçek: yazı ve buton boyutu sabit (1x) kalır, okunur
func _sync_pins_transform() -> void:
	var inv := 1.0 / maxf(zoom_scale, 0.01)
	var inv_v := Vector2(inv, inv)
	for plate: Control in plates.values():
		plate.scale = inv_v
		plate.pivot_offset = plate.size * 0.5
	for btn: Control in _region_buttons.values():
		btn.scale = inv_v
		btn.pivot_offset = btn.size * 0.5


func _update_reset_button() -> void:
	if _reset_zoom_button:
		_reset_zoom_button.visible = zoom_scale > 1.05


# ---------------------------------------------------------------- Kurum Plakaları

## Kurum plakası: map_badge kalıbı (yuvarlak altın çerçeveli simge rozeti + koyu plaka üstünde büyük harf ad + altta küçük altın üçgen)
func _make_site(id: String) -> void:
	var s: Dictionary = _sites[id]
	var plate := PanelContainer.new()
	plate.name = "SitePlate_" + id
	plate.focus_mode = Control.FOCUS_ALL
	plate.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	plate.custom_minimum_size = Vector2(0, 38 if not mobile else 44)
	_map_layer.add_child(plate)
	plates[id] = plate

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.045, 0.038, 0.03, 0.94)
	sb.border_color = Color(UIKit.GOLD, 0.78)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 6
	sb.content_margin_right = 14
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	plate.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(row)

	# Sol yuvarlak altın çerçeveli simge rozeti
	var badge_size := 32.0 if not mobile else 38.0
	var badge := Control.new()
	badge.custom_minimum_size = Vector2(badge_size, badge_size)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_id: String = str(s.get("icon", "tac"))
	var premium_icon := str({
		"terazi": "terazi", "tac": "tac", "sutun": "meclis", "para": "altin",
		"kilic": "kilic", "goz": "goz", "pusula": "pusula", "defne": "defne",
	}.get(icon_id, ""))
	if premium_icon != "":
		var premium := UIKit.icon(premium_icon, Vector2(badge_size * 0.62, badge_size * 0.62), UIKit.GOLD)
		premium.position = Vector2(badge_size * 0.19, badge_size * 0.19)
		premium.size = Vector2(badge_size * 0.62, badge_size * 0.62)
		badge.add_child(premium)
	badge.draw.connect(func() -> void:
		var c := badge.size * 0.5
		var r := minf(c.x, c.y) - 1.0
		badge.draw_circle(c, r, Color(0.035, 0.03, 0.025, 0.98))
		badge.draw_arc(c, r, 0, TAU, 32, UIKit.GOLD, 1.5, true)
		badge.draw_arc(c, r - 2.5, 0, TAU, 32, Color(UIKit.GOLD_DIM, 0.5), 1.0, true)
		if premium_icon == "":
			UIKit.draw_icon(badge, icon_id, c, r * 1.5, UIKit.GOLD)
	)
	row.add_child(badge)

	# Sağ altın büyük harf ad (alt satır açıklama yok)
	var t := Label.new()
	t.text = tr(str(s["title"]))
	t.add_theme_font_override("font", UIKit.caps())
	t.add_theme_font_size_override("font_size", 16 if not mobile else 15)
	t.add_theme_color_override("font_color", Color("fff3d0"))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	t.add_theme_constant_override("shadow_outline_size", 4)
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(t)

	# Altta binayı gösteren küçük altın üçgen
	plate.draw.connect(func() -> void:
		var mid_x := plate.size.x * 0.5
		var y := plate.size.y
		var tri := PackedVector2Array([
			Vector2(mid_x - 5.5, y),
			Vector2(mid_x + 5.5, y),
			Vector2(mid_x, y + 7.0),
		])
		plate.draw_colored_polygon(tri, UIKit.GOLD)
		plate.draw_line(Vector2(mid_x - 5.5, y), Vector2(mid_x, y + 7.0), Color("fff3d0"), 1.0, true)
		plate.draw_line(Vector2(mid_x + 5.5, y), Vector2(mid_x, y + 7.0), Color("fff3d0"), 1.0, true)
	)

	for c in plate.find_children("*", "Control", true, false):
		(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Konum: yüzdelik nokta etiketin merkezi olur
	var place := func() -> void:
		var p: Vector2 = MOBILE_POS.get(id, s["pos"]) if mobile else s["pos"]
		plate.position = Vector2(p.x * size.x, p.y * size.y) - plate.size / 2.0
		plate.pivot_offset = plate.size / 2.0
	plate.resized.connect(place)
	place.call_deferred()

	plate.mouse_entered.connect(func() -> void:
		if TOUCH_SCROLL.dispatching_touch: return
		Sfx.play("hover", -10.0)
		sb.border_color = Color("fff3d0")
		sb.bg_color = Color(0.12, 0.10, 0.08, 0.98))
	plate.mouse_exited.connect(func() -> void:
		if TOUCH_SCROLL.dispatching_touch: return
		sb.border_color = Color(UIKit.GOLD, 0.78)
		sb.bg_color = Color(0.045, 0.038, 0.03, 0.94))

	var press_pos := [Vector2.ZERO]
	plate.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			var mb := ev as InputEventMouseButton
			var activate := false
			if mb.pressed:
				if TOUCH_SCROLL.dispatching_touch:
					press_pos[0] = mb.global_position
				else:
					activate = true
			else:
				activate = TOUCH_SCROLL.dispatching_touch and not _is_dragging and press_pos[0].distance_to(mb.global_position) <= 10.0
			if not activate:
				return
			Sfx.play("click")
			if id == "saray":
				close_view()
			else:
				show_site(id)
		elif ev is InputEventKey and ev.pressed and (ev.keycode == KEY_ENTER or ev.keycode == KEY_SPACE):
			Sfx.play("click")
			if id == "saray":
				close_view()
			else:
				show_site(id)
	)


func _set_region_layer(enabled: bool) -> void:
	_regions_visible = enabled
	_region_toggle.text = tr("Bölgeler: Açık") if enabled else tr("Bölgeler: Kapalı")
	_region_toggle.tooltip_text = tr("Bölge katmanını aç/kapat")
	_sync_region_markers()


func _sync_region_markers() -> void:
	for marker: Button in _region_buttons.values():
		marker.visible = _regions_visible and not (_drawer and _drawer.visible)


## Bölge işaretçisi: map_badge dilinde buton
func _make_region_marker(id: String) -> void:
	var button := Button.new()
	button.name = "Region_" + id
	button.set_meta("region_id", id)
	button.set_meta("featured", id == Sim.featured_region_id())
	button.custom_minimum_size = Vector2(116, 62) if not mobile else Vector2(80, 58)
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = _region_tooltip(id)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.045, 0.038, 0.03, 0.95)
	normal.border_color = Color(UIKit.GOLD, 0.8)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 6
	normal.content_margin_right = 6
	normal.content_margin_top = 4
	normal.content_margin_bottom = 4

	var hover := normal.duplicate() as StyleBoxFlat
	hover.border_color = Color("fff3d0")
	hover.bg_color = Color(0.12, 0.10, 0.08, 0.98)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.text = ""
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 2)
	button.add_child(column)

	var name := Label.new()
	name.name = "RegionName"
	name.text = _region_compact_name(id)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if mobile else TextServer.AUTOWRAP_OFF
	if mobile and id == "capital": name.custom_minimum_size.y = 28
	name.add_theme_font_override("font", UIKit.caps())
	name.add_theme_font_size_override("font_size", 14 if not mobile else 13)
	name.add_theme_color_override("font_color", Color("fff3d0"))
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

	# Altta küçük altın işaret üçgeni
	button.draw.connect(func() -> void:
		var mid_x := button.size.x * 0.5
		var y := button.size.y
		var tri := PackedVector2Array([
			Vector2(mid_x - 5.0, y),
			Vector2(mid_x + 5.0, y),
			Vector2(mid_x, y + 6.0),
		])
		button.draw_colored_polygon(tri, UIKit.GOLD)
		if bool(button.get_meta("featured")):
			var center := Vector2(button.size.x - 9.0, 9.0)
			var star := PackedVector2Array()
			for point in 10:
				var angle := -PI * 0.5 + point * PI / 5.0
				var radius := 4.5 if point % 2 == 0 else 2.0
				star.append(center + Vector2(cos(angle), sin(angle)) * radius)
			button.draw_colored_polygon(star, UIKit.GOLD)
	)

	var p: Vector2 = (_mobile_region_positions if mobile else _region_positions).get(id, REGION_POS[id])
	button.position = Vector2(p.x * size.x, p.y * size.y) - button.custom_minimum_size / 2.0
	button.pivot_offset = button.custom_minimum_size * 0.5
	button.visible = _regions_visible

	button.pressed.connect(func() -> void:
		if not _is_dragging:
			show_region(id)
	)
	_map_layer.add_child(button)
	_region_buttons[id] = button
	button.resized.connect(func() -> void:
		button.position = Vector2(p.x * size.x, p.y * size.y) - button.size / 2.0
		button.pivot_offset = button.size / 2.0
	)
	resized.connect(func() -> void:
		button.position = Vector2(p.x * size.x, p.y * size.y) - button.size / 2.0
		button.pivot_offset = button.size / 2.0
	)


func _draw_region_symbols(control: Control, levels: Dictionary, has_crisis: bool, has_governor: bool) -> void:
	var w := control.size.x
	var y := 10.0
	var ink := Color("ead7a6")
	var triangle := PackedVector2Array([Vector2(5, y + 6), Vector2(12, y - 6), Vector2(19, y + 6), Vector2(5, y + 6)])
	control.draw_polyline(triangle, ink, 1.5, true)
	for i in int(levels["unrest"]):
		control.draw_line(Vector2(8 + i * 4, y + 3), Vector2(10 + i * 4, y - 1), ink, 1.5, true)
	for i in 3:
		var height := 2.0 + i * 2.0 + float(levels["economy"]) * 2.0
		control.draw_rect(Rect2(Vector2(28 + i * 4, y + 6 - height), Vector2(2, height)), ink)
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
		"capital": return tr("Başkent Bölgesi")
		"industry": return tr("Sanayi")
		"farmland": return tr("Tarım")
		_: return tr("Sınır")


# ---------------------------------------------------------------- Kurum & Bölge çekmecesi

func _build_drawer() -> void:
	_drawer = PanelContainer.new()
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.07, 0.06, 0.05, 1.0)
	psb.set_border_width_all(0)
	psb.set_corner_radius_all(3)
	psb.content_margin_left = 22
	psb.content_margin_right = 22
	psb.content_margin_top = 22
	psb.content_margin_bottom = 22
	_drawer.add_theme_stylebox_override("panel", psb)
	UIKit.ornament(_drawer, Color(UIKit.GOLD, 0.8), 22, 1)

	if ResourceLoader.exists("res://art/ui/watermark_crest.png"):
		var wm := TextureRect.new()
		wm.texture = load("res://art/ui/watermark_crest.png")
		wm.set_anchors_preset(Control.PRESET_FULL_RECT)
		wm.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wm.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wm.modulate = Color(1, 1, 1, 0.06)
		wm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_drawer.add_child(wm)

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
	_drawer_body.add_theme_constant_override("separation", 14)
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
		var frame := PanelContainer.new()
		frame.custom_minimum_size = Vector2(0, 210)
		var fsb := StyleBoxFlat.new()
		fsb.bg_color = Color(0, 0, 0, 0.4)
		fsb.border_color = Color(UIKit.GOLD, 0.7)
		fsb.set_border_width_all(1)
		fsb.set_corner_radius_all(2)
		frame.add_theme_stylebox_override("panel", fsb)
		_drawer_body.add_child(frame)

		var img := TextureRect.new()
		img.texture = tex
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		frame.add_child(img)

	var title_box := HBoxContainer.new()
	title_box.add_theme_constant_override("separation", 10)
	_drawer_body.add_child(title_box)

	var dia := Control.new()
	dia.custom_minimum_size = Vector2(14, 14)
	dia.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dia.draw.connect(func() -> void:
		var c := dia.size * 0.5
		dia.draw_colored_polygon(PackedVector2Array([
			c + Vector2(0, -6), c + Vector2(6, 0), c + Vector2(0, 6), c + Vector2(-6, 0)
		]), UIKit.GOLD)
	)
	title_box.add_child(dia)

	var t := Label.new()
	t.text = tr(str(s["title"]))
	t.add_theme_font_override("font", UIKit.caps())
	t.add_theme_font_size_override("font_size", 26)
	t.add_theme_color_override("font_color", UIKit.GOLD)
	title_box.add_child(t)

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
		var row := PanelContainer.new()
		var rsb := StyleBoxFlat.new()
		rsb.bg_color = Color(0.08, 0.07, 0.06, 0.88)
		rsb.border_color = Color(UIKit.GOLD, 0.8)
		rsb.set_border_width_all(1)
		rsb.border_width_left = 3
		rsb.set_corner_radius_all(3)
		rsb.content_margin_left = 12
		rsb.content_margin_right = 12
		rsb.content_margin_top = 10
		rsb.content_margin_bottom = 10
		row.add_theme_stylebox_override("panel", rsb)
		_drawer_body.add_child(row)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		row.add_child(hbox)

		var pt_frame := PanelContainer.new()
		var ptsb := StyleBoxFlat.new()
		ptsb.bg_color = Color.TRANSPARENT
		ptsb.border_color = Color(UIKit.GOLD, 0.7)
		ptsb.set_border_width_all(1)
		ptsb.set_corner_radius_all(2)
		pt_frame.add_theme_stylebox_override("panel", ptsb)
		hbox.add_child(pt_frame)

		var pt := TextureRect.new()
		pt.texture = portrait_fn.call(aid) if portrait_fn.is_valid() else null
		pt.custom_minimum_size = Vector2(84, 84)
		pt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		pt_frame.add_child(pt)

		var info := _text("[b]%s[/b]\n[color=gray]%s[/color]\n\"%s\"" % [a.display_name, a.title, _report_of(aid)])
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info)
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
	actions.add_child(_btn(tr("Kapat"), func() -> void: _drawer.hide()))

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

	var title_box := HBoxContainer.new()
	title_box.add_theme_constant_override("separation", 10)
	_drawer_body.add_child(title_box)

	var dia := Control.new()
	dia.custom_minimum_size = Vector2(14, 14)
	dia.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dia.draw.connect(func() -> void:
		var c := dia.size * 0.5
		dia.draw_colored_polygon(PackedVector2Array([
			c + Vector2(0, -6), c + Vector2(6, 0), c + Vector2(0, 6), c + Vector2(-6, 0)
		]), UIKit.GOLD)
	)
	title_box.add_child(dia)

	var name := tr(str(Sim.REGION_NAMES[id]))
	var title := Label.new()
	title.text = name
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	title_box.add_child(title)

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
	var governor_row := PanelContainer.new()
	var gr_sb := StyleBoxFlat.new()
	gr_sb.bg_color = Color(0.08, 0.07, 0.06, 0.88)
	gr_sb.border_color = Color(UIKit.GOLD, 0.8)
	gr_sb.set_border_width_all(1)
	gr_sb.border_width_left = 3
	gr_sb.set_corner_radius_all(3)
	gr_sb.content_margin_left = 12
	gr_sb.content_margin_right = 12
	gr_sb.content_margin_top = 10
	gr_sb.content_margin_bottom = 10
	governor_row.add_theme_stylebox_override("panel", gr_sb)
	_drawer_body.add_child(governor_row)

	var ghbox := HBoxContainer.new()
	ghbox.add_theme_constant_override("separation", 12)
	governor_row.add_child(ghbox)

	if governor_id != "" and Sim.actors.has(governor_id):
		var pt_frame := PanelContainer.new()
		var ptsb := StyleBoxFlat.new()
		ptsb.bg_color = Color.TRANSPARENT
		ptsb.border_color = Color(UIKit.GOLD, 0.7)
		ptsb.set_border_width_all(1)
		ptsb.set_corner_radius_all(2)
		pt_frame.add_theme_stylebox_override("panel", ptsb)
		ghbox.add_child(pt_frame)

		var portrait := TextureRect.new()
		portrait.name = "GovernorPortrait"
		portrait.texture = portrait_fn.call(governor_id) if portrait_fn.is_valid() else null
		portrait.custom_minimum_size = Vector2(72, 72)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pt_frame.add_child(portrait)

		var actor = Sim.actors[governor_id]
		var governor_name := Label.new()
		governor_name.text = "%s\n%s" % [actor.display_name, tr("Vali")]
		governor_name.add_theme_font_override("font", UIKit.sans(680))
		governor_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		governor_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ghbox.add_child(governor_name)
	else:
		ghbox.add_child(_text("[b]%s[/b]" % tr("Vali atanmamış")))

	_drawer_body.add_child(_text("[b]%s[/b]" % tr("Açık bölge eylemleri")))
	_region_action_button = _btn(tr("Bölge kararlarını aç"), func() -> void: request.emit("region", id))
	_region_action_button.custom_minimum_size.y = 48
	_region_action_button.focus_mode = Control.FOCUS_ALL
	_region_action_button.tooltip_text = tr("Bu bölge için R1 bütçesi ve mesai kullanan kararları aç")
	_drawer_body.add_child(_region_action_button)

	_drawer_body.add_child(_text(tr("Aşağıdaki liste bilgi amaçlıdır; seçimler karar kartında yapılır.")))
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


func _show_map_legend() -> void:
	_region_panel_id = ""
	for c in _drawer_body.get_children():
		c.queue_free()

	var title := Label.new()
	title.text = tr("Harita simgeleri")
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	_drawer_body.add_child(title)

	for line in [tr("Üçgen: huzursuzluk"), tr("Sütunlar: pazar"), tr("Kalkan: bağlılık"), tr("Ünlem: bekleyen kriz"), tr("Kişi simgesi: vali")]:
		_drawer_body.add_child(_text(line))

	var close := _btn(tr("Kapat"), func() -> void: _drawer.hide())
	close.custom_minimum_size.y = 48
	close.focus_mode = Control.FOCUS_ALL
	_drawer_body.add_child(close)

	_drawer.show()
	_drawer.modulate.a = 1.0
	close.grab_focus.call_deferred()
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
	r.add_theme_font_override("normal_font", UIKit.sans(500))
	r.add_theme_font_override("bold_font", UIKit.sans(680))
	r.add_theme_font_size_override("normal_font_size", 16 if not mobile else 15)
	r.add_theme_font_size_override("bold_font_size", 16 if not mobile else 15)
	return r


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = tr(text)
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size.y = 44
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", UIKit.sans(500))
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
		var p := Vector2(rng.randf(), rng.randf())
		if rng.randf() < 0.55:
			var keys := SITES.keys()
			var c: Vector2 = SITES[keys[rng.randi() % keys.size()]]["pos"]
			p = c + Vector2(rng.randfn(0, 0.07), rng.randfn(0, 0.06))
		_lights.append([p, rng.randf_range(0.6, 2.2), rng.randf()])


func _draw_city() -> void:
	var s := _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, s), Color("07080d"))
	var river := PackedVector2Array()
	for i in 30:
		var x := s.x * i / 29.0
		river.append(Vector2(x, s.y * 0.53 + sin(i * 0.45) * s.y * 0.05))
	_canvas.draw_polyline(river, Color("0d1a2a"), s.y * 0.05, true)
	_canvas.draw_polyline(river, Color(0.25, 0.35, 0.5, 0.25), 2.0, true)
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
	for id in SITES:
		var p: Vector2 = SITES[id]["pos"] * s
		for k in 6:
			_canvas.draw_circle(p, 90.0 - k * 14.0, Color(0.95, 0.7, 0.35, 0.025 + k * 0.012))
	var t := Time.get_ticks_msec() / 1000.0
	for l in _lights:
		var p: Vector2 = l[0] * s
		var flick := 0.55 + 0.45 * sin(t * 1.3 + float(l[2]) * 40.0)
		_canvas.draw_circle(p, float(l[1]), Color(1.0, 0.78, 0.45, 0.35 + 0.4 * flick))
