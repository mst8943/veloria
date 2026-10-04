extends RefCounted
## Tema ve animasyon yardımcıları (tüm arayüz buradaki palete ve hareket diline bağlı).

const BG := Color("0e0d11")
const PANEL := Color("17161b")
const PANEL_HI := Color("201e27")
const GOLD := Color("d6b25e")
const GOLD_DIM := Color("8f7a45")
const TEXT := Color("e9e4d6")
const TEXT_DIM := Color("9a958a")
const DANGER := Color("c0504a")
const OK := Color("7fae7a")

const SERIF_PATH := "res://game/fonts/EBGaramond.ttf"
static var _serif: Font


## Başlık fontu: oyuna gömülü EB Garamond (her platformda aynı görünüm); yoksa sistem serif fontu.
static func serif() -> Font:
	if _serif == null:
		if ResourceLoader.exists(SERIF_PATH):
			var fv := FontVariation.new()
			fv.base_font = load(SERIF_PATH)
			var ts := TextServerManager.get_primary_interface()
			fv.variation_opentype = {ts.name_to_tag("wght"): 560}
			_serif = fv
		else:
			var sf := SystemFont.new()
			sf.font_names = PackedStringArray(["Palatino Linotype", "Georgia", "Constantia", "Cambria", "Times New Roman"])
			sf.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
			_serif = sf
	return _serif


static var _caps: Font


## Bölüm başlıkları için harf aralığı açık serif (aynı font, daha resmi görünüm).
static func caps() -> Font:
	if _caps == null:
		var fv := FontVariation.new()
		fv.base_font = serif()
		fv.spacing_glyph = 2
		_caps = fv
	return _caps


## Çerçevenin köşelerine ince altın köşebentler çizer (paneli "hazırlanmış" gösterir).
## Panelin kendi çiziminde, çocukların altında kalır; tıklamayı etkilemez.
static func ornament(c: CanvasItem, col: Color = Color(GOLD, 0.75), length := 14.0, inset := 4.0) -> void:
	c.draw.connect(func() -> void:
		var s: Vector2 = (c as Control).size
		var w := 1.5
		for corner in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
			var p := Vector2(inset + corner.x * (s.x - 2.0 * inset), inset + corner.y * (s.y - 2.0 * inset))
			var dx := length * (1.0 if corner.x == 0.0 else -1.0)
			var dy := length * (1.0 if corner.y == 0.0 else -1.0)
			c.draw_line(p, p + Vector2(dx, 0), col, w, true)
			c.draw_line(p, p + Vector2(0, dy), col, w, true)
			c.draw_rect(Rect2(p - Vector2(1.5, 1.5), Vector2(3, 3)), col))
	c.queue_redraw()


## Ekran başlık bandı: koyu, alt kenarında ince altın çizgi. Ana ekran, harita ve medyada aynı.
static func band_style() -> StyleBoxFlat:
	var s := box(Color(0.025, 0.02, 0.03, 0.72), Color(0, 0, 0, 0), 8, 14)
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.border_color = Color(GOLD_DIM, 0.55)
	s.border_width_bottom = 1
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 8
	return s


## Başlık ayracı: ortada küçük altın elmas, iki yana incelerek uzanan çizgiler.
## Masa, menü ve oyun sonu başlıklarında aynı imza.
static func divider(width := 360.0, col: Color = GOLD) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(width, 12)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(_draw_divider.bind(c, width, col))
	return c


static func _draw_divider(c: Control, width: float, col: Color) -> void:
	var mid := c.size / 2.0
	var half := minf(width, c.size.x) / 2.0
	var steps := 24
	for side in [-1.0, 1.0]:
		for i in steps:
			var a := float(i) / steps
			var b := float(i + 1) / steps
			var p0 := mid + Vector2(side * (10.0 + (half - 10.0) * a), 0)
			var p1 := mid + Vector2(side * (10.0 + (half - 10.0) * b), 0)
			c.draw_line(p0, p1, Color(col, 0.8 * (1.0 - a)), 1.2, true)
	var d := PackedVector2Array([mid + Vector2(0, -4.5), mid + Vector2(4.5, 0), mid + Vector2(0, 4.5), mid + Vector2(-4.5, 0)])
	c.draw_colored_polygon(d, col)


## Türkçe büyük harf: i -> İ, ı -> I (Godot'un to_upper'ı bu kuralı bilmez).
static func tr_upper(s: String) -> String:
	return s.replace("i", "İ").replace("ı", "I").to_upper()


static func box(bg: Color, border: Color = Color(0, 0, 0, 0), radius := 6, margin := 10, border_w := 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w if border.a > 0.0 else 0)
	s.set_corner_radius_all(radius)
	s.content_margin_left = margin
	s.content_margin_right = margin
	s.content_margin_top = maxi(margin - 2, 4)
	s.content_margin_bottom = maxi(margin - 2, 4)
	s.anti_aliasing = true
	return s


static func _check_tex(checked: bool) -> Texture2D:
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0.45))
	for i in 20:
		for w in 2:
			img.set_pixel(i, w, GOLD)
			img.set_pixel(i, 19 - w, GOLD)
			img.set_pixel(w, i, GOLD)
			img.set_pixel(19 - w, i, GOLD)
	if checked:
		for x in range(5, 15):
			for y in range(5, 15):
				img.set_pixel(x, y, GOLD)
	return ImageTexture.create_from_image(img)


static func build_theme(mobile := false) -> Theme:
	var t := Theme.new()
	t.default_font_size = 18 if mobile else 15
	var bm := 15 if mobile else 12  # düğme iç boşluğu: mobilde daha büyük dokunma alanı
	# Etiketler ve metin
	t.set_color("font_color", "Label", TEXT)
	t.set_color("default_color", "RichTextLabel", TEXT)
	# Düğmeler
	var n := box(PANEL_HI, Color(GOLD_DIM, 0.45), 5, bm)
	var h := box(Color("2a2733"), GOLD, 5, bm)
	var p := box(Color("14131a"), GOLD, 5, bm)
	var d := box(Color(PANEL_HI, 0.5), Color(GOLD_DIM, 0.15), 5, bm)
	t.set_stylebox("normal", "Button", n)
	t.set_stylebox("hover", "Button", h)
	t.set_stylebox("pressed", "Button", p)
	t.set_stylebox("disabled", "Button", d)
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), Color(GOLD, 0.6), 5, 12))
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color("fff3d0"))
	t.set_color("font_pressed_color", "Button", GOLD)
	t.set_color("font_disabled_color", "Button", Color(TEXT_DIM, 0.5))
	# Seçenek düğmesi (karar kartı)
	t.add_type("ChoiceButton")
	t.set_type_variation("ChoiceButton", "Button")
	t.set_stylebox("pressed", "ChoiceButton", box(Color("3a331f"), GOLD, 4, bm))
	# Seçenek: sol kenarda altın vurgu çizgisi
	var ch_n := box(Color("1b1a21"), Color(GOLD_DIM, 0.25), 4, bm)
	ch_n.border_width_left = 3
	ch_n.border_color = Color(GOLD_DIM, 0.45)
	var ch_h := box(Color("2d2a1f"), GOLD, 4, bm)
	ch_h.border_width_left = 5
	t.set_stylebox("normal", "ChoiceButton", ch_n)
	t.set_stylebox("hover", "ChoiceButton", ch_h)
	# Tehlikeli eylem: kırmızımsı
	t.add_type("DangerButton")
	t.set_type_variation("DangerButton", "Button")
	t.set_stylebox("normal", "DangerButton", box(Color("2a1617"), Color(DANGER, 0.55), 5, bm))
	t.set_stylebox("hover", "DangerButton", box(Color("3d1b1c"), DANGER, 5, bm))
	t.set_stylebox("pressed", "DangerButton", box(Color("1d0f10"), DANGER, 5, bm))
	t.set_stylebox("disabled", "DangerButton", box(Color(0.16, 0.09, 0.09, 0.45), Color(DANGER, 0.15), 5, bm))
	t.set_color("font_color", "DangerButton", Color("f0c9c4"))
	t.set_color("font_disabled_color", "DangerButton", Color(TEXT_DIM, 0.45))
	# Hayalet düğme: gezinme (üst çubuk)
	t.add_type("GhostButton")
	t.set_type_variation("GhostButton", "Button")
	t.set_stylebox("normal", "GhostButton", box(Color(0, 0, 0, 0.0), Color(GOLD_DIM, 0.0), 5, bm))
	t.set_stylebox("hover", "GhostButton", box(Color(GOLD, 0.08), Color(GOLD_DIM, 0.6), 5, bm))
	t.set_stylebox("pressed", "GhostButton", box(Color(GOLD, 0.15), GOLD, 5, bm))
	t.set_color("font_color", "GhostButton", Color("d9c79a"))
	t.set_color("font_hover_color", "GhostButton", Color("fff3d0"))
	t.set_font("font", "GhostButton", serif())
	t.set_font_size("font_size", "GhostButton", 19 if mobile else 17)
	# Birincil düğme
	t.add_type("PrimaryButton")
	t.set_type_variation("PrimaryButton", "Button")
	t.set_stylebox("normal", "PrimaryButton", box(Color("3a301a"), GOLD, 6, 14, 2))
	t.set_stylebox("hover", "PrimaryButton", box(Color("5a4a22"), Color("ffe08a"), 6, 14, 2))
	t.set_stylebox("pressed", "PrimaryButton", box(Color("2a2212"), GOLD, 6, 14, 2))
	t.set_color("font_color", "PrimaryButton", Color("fff3d0"))
	t.set_font("font", "PrimaryButton", serif())
	t.set_font_size("font_size", "PrimaryButton", 20)
	# Sekmeler
	t.set_stylebox("panel", "TabContainer", box(Color(PANEL, 0.88), Color(GOLD_DIM, 0.3), 6, 8))
	t.set_stylebox("tab_selected", "TabContainer", box(Color(PANEL_HI, 0.95), GOLD, 4, 14))
	t.set_stylebox("tab_unselected", "TabContainer", box(Color(PANEL, 0.7), Color(GOLD_DIM, 0.2), 4, 14))
	t.set_stylebox("tab_hovered", "TabContainer", box(Color("2a2733"), GOLD_DIM, 4, 14))
	t.set_color("font_selected_color", "TabContainer", GOLD)
	t.set_color("font_unselected_color", "TabContainer", TEXT_DIM)
	t.set_color("font_hovered_color", "TabContainer", TEXT)
	t.set_font("font", "TabContainer", serif())
	t.set_font_size("font_size", "TabContainer", 21 if mobile else 17)
	# Listeler
	t.set_stylebox("panel", "ItemList", box(Color(PANEL, 0.6), Color(GOLD_DIM, 0.25), 4, 6))
	t.set_stylebox("selected", "ItemList", box(Color("33291a"), GOLD_DIM, 3, 6))
	t.set_stylebox("selected_focus", "ItemList", box(Color("33291a"), GOLD, 3, 6))
	t.set_color("font_color", "ItemList", TEXT)
	t.set_color("font_selected_color", "ItemList", Color("fff3d0"))
	# Kaydırma çubuğu
	for sb in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", sb, box(Color(0, 0, 0, 0.25), Color(0, 0, 0, 0), 3, 2))
		t.set_stylebox("grabber", sb, box(Color(GOLD_DIM, 0.55), Color(0, 0, 0, 0), 3, 3))
		t.set_stylebox("grabber_highlight", sb, box(GOLD_DIM, Color(0, 0, 0, 0), 3, 3))
		t.set_stylebox("grabber_pressed", sb, box(GOLD, Color(0, 0, 0, 0), 3, 3))
	# İlerleme çubuğu
	t.set_stylebox("background", "ProgressBar", box(Color(0, 0, 0, 0.5), Color(GOLD_DIM, 0.4), 3, 0))
	t.set_stylebox("fill", "ProgressBar", box(GOLD, Color(0, 0, 0, 0), 3, 0))
	# Kaydırıcı / onay kutusu
	t.set_stylebox("slider", "HSlider", box(Color(0, 0, 0, 0.5), Color(GOLD_DIM, 0.4), 3, 0))
	t.set_stylebox("grabber_area", "HSlider", box(GOLD_DIM, Color(0, 0, 0, 0), 3, 0))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(GOLD, Color(0, 0, 0, 0), 3, 0))
	t.set_color("font_color", "CheckBox", TEXT)
	t.set_icon("checked", "CheckBox", _check_tex(true))
	t.set_icon("unchecked", "CheckBox", _check_tex(false))
	for st in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		t.set_stylebox(st, "CheckBox", StyleBoxEmpty.new())
	# İpucu balonu
	t.set_stylebox("panel", "TooltipPanel", box(Color("0a090c", 0.97), GOLD, 5, 10))
	t.set_color("font_color", "TooltipLabel", TEXT)
	t.set_font_size("font_size", "TooltipLabel", 14)
	return t


# ---------------------------------------------------------------- Hareket yardımcıları

static func fade_in(n: CanvasItem, dur := 0.35, delay := 0.0) -> Tween:
	n.modulate.a = 0.0
	var tw := n.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(n, "modulate:a", 1.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tw


static func pop_in(c: Control, dur := 0.32, delay := 0.0) -> Tween:
	c.modulate.a = 0.0
	c.scale = Vector2(0.96, 0.96)
	c.pivot_offset = c.size / 2.0
	var tw := c.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tw


static func pulse(c: Control, amount := 1.25, color: Color = GOLD) -> void:
	c.pivot_offset = c.size / 2.0
	var tw := c.create_tween()
	tw.set_parallel(true)
	c.scale = Vector2(amount, amount)
	c.modulate = Color(color.r * 1.4, color.g * 1.4, color.b * 1.4, 1.0)
	tw.tween_property(c, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "modulate", Color.WHITE, 0.5)


static func typewrite(l: RichTextLabel, dur := 0.9, delay := 0.0) -> Tween:
	l.visible_ratio = 0.0
	var tw := l.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(l, "visible_ratio", 1.0, dur)
	return tw


static func hover_pop(c: Control, amount := 1.03) -> void:
	c.mouse_entered.connect(func() -> void:
		c.pivot_offset = c.size / 2.0
		var tw := c.create_tween()
		tw.tween_property(c, "scale", Vector2(amount, amount), 0.12).set_trans(Tween.TRANS_SINE))
	c.mouse_exited.connect(func() -> void:
		var tw := c.create_tween()
		tw.tween_property(c, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_SINE))


static func shake(c: Control, strength := 6.0, dur := 0.35) -> void:
	var origin := c.position
	var tw := c.create_tween()
	var steps := int(dur / 0.04)
	for i in steps:
		var k := 1.0 - float(i) / steps
		tw.tween_property(c, "position", origin + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * k, 0.04)
	tw.tween_property(c, "position", origin, 0.05)


static func soft_dot() -> Texture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 0.9))
	g.set_color(1, Color(1, 1, 1, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 24
	tex.height = 24
	return tex


static func dust(area: Vector2, amount := 36, alpha := 0.35) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = soft_dot()
	p.amount = amount
	p.lifetime = 11.0
	p.preprocess = 11.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = area / 2.0
	p.position = area / 2.0
	p.direction = Vector2(0.3, -1)
	p.spread = 40.0
	p.initial_velocity_min = 3.0
	p.initial_velocity_max = 11.0
	p.gravity = Vector2.ZERO
	p.scale_amount_min = 0.15
	p.scale_amount_max = 0.55
	p.color = Color(1.0, 0.9, 0.7, alpha)
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.25, Color(1, 1, 1, 1))
	fade.add_point(0.75, Color(1, 1, 1, 1))
	fade.set_color(fade.get_point_count() - 1, Color(1, 1, 1, 0))
	p.color_ramp = fade
	return p
