extends RefCounted
## Tema ve animasyon yardımcıları (tüm arayüz buradaki palete ve hareket diline bağlı).

const Loc := preload("res://game/core/loc.gd")

# Nötrler sıcak kömür tonunda (kırmızı >= yeşil >= mavi): altın ve parşömenle çatışmaz (docs/ux/gorsel_dil_v2.md).
const BG := Color("0e0c0a")
const PANEL := Color("171511")
const PANEL_HI := Color("221e18")
const HOVER := Color("2c271e")
const SHADE := Color(0.035, 0.028, 0.022)   # perde, örtü ve kaplamaların koyu is rengi
const PLATE := Color("0c0b09")              # pencere/bildirim zemini
const RADIUS := 3                           # keskin geometri: hiçbir kutu bundan yuvarlak olmaz
const GOLD := Color("d6b25e")
const GOLD_DIM := Color("8f7a45")
const TEXT := Color("e9e4d6")
const TEXT_DIM := Color("9a958a")
const DANGER := Color("c0504a")
const OK := Color("7fae7a")
const AMBER := Color("d08a3d")   # uyarı değil, dikkat: "çıkarı var" gibi
const REPORT_BLUE := Color("6e9fc4") # görünür rapor değişimi

const SERIF_PATH := "res://game/fonts/EBGaramond.ttf"
const SANS_PATH := "res://game/fonts/IBMPlexSans.ttf"
static var _serif: Font
static var _sans := {}


## Gövde fontu: gömülü IBM Plex Sans (değişken ağırlık). Metrikleri Godot'nun eski yedek fontuna
## yakın, bu yüzden yazı boyutları değişmeden kalır. Koyu zeminde ince görünmesin diye varsayılan
## ağırlık Medium. Dosya yoksa Godot'nun yedek fontu.
static func sans(weight := 500, slant := false) -> Font:
	var key := "%d%s" % [weight, "i" if slant else ""]
	if not _sans.has(key):
		if not ResourceLoader.exists(SANS_PATH):
			return ThemeDB.fallback_font
		var fv := FontVariation.new()
		fv.base_font = load(SANS_PATH)
		var ts := TextServerManager.get_primary_interface()
		fv.variation_opentype = {ts.name_to_tag("wght"): weight}
		if slant:
			fv.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
		_sans[key] = fv
	return _sans[key]


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


static var _italic: Font


## Alıntılar için eğik serif (fontun italik kesimi gömülü değil; eğme dönüşümüyle).
static func serif_italic() -> Font:
	if _italic == null:
		var fv := FontVariation.new()
		fv.base_font = serif()
		fv.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
		_italic = fv
	return _italic


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
	# Süs, panelin çocuklarının ÜSTÜNE çizilir (görselin köşelerinde de görünsün); tıklamayı etkilemez.
	var host := c as Control
	var ov := Control.new()
	ov.name = "Ornament"
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	if col.r > col.g * 1.5 and col.g < 0.4:
		ov.modulate = Color(1.1, 0.5, 0.45)   # tehlike çerçevesi: altın doku kırmızıya boyanır
	host.add_child(ov)
	# Doku stili çizim geri çağrısının dışında tutulur (yoksa doku erken serbest kalır ve beyaz çizilir).
	var framed: StyleBoxTexture = null
	if length >= 16.0:
		framed = tex_box("frame_panel" if length >= 24.0 else "frame_card", [44, 44, 44, 44] if length >= 24.0 else [26, 26, 26, 26])
		if framed != null:
			framed.draw_center = false
	ov.draw.connect(func() -> void:
		var s: Vector2 = host.size
		var o: Vector2 = -ov.position
		if framed != null:
			ov.draw_style_box(framed, Rect2(o + Vector2(inset - 3.0, inset - 3.0), s - Vector2(2.0 * inset - 6.0, 2.0 * inset - 6.0)))
			return
		var big := length >= 16.0
		# Çift çerçeve: dışta belirgin altın çizgi, içte ince kıl çizgisi (kaplama pervaz hissi).
		var outer := Rect2(o + Vector2(inset, inset), s - Vector2(2.0 * inset, 2.0 * inset))
		ov.draw_rect(outer, Color(col, col.a * (0.55 if big else 0.2)), false, 1.4 if big else 1.0)
		if big:
			ov.draw_rect(outer.grow(-4.0), Color(col, col.a * 0.2), false, 1.0)
		ov.draw_line(o + Vector2(2, 1), o + Vector2(s.x - 2, 1), Color(1.0, 0.94, 0.8, 0.07), 1.0)
		for corner in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
			var p := o + Vector2(inset + corner.x * (s.x - 2.0 * inset), inset + corner.y * (s.y - 2.0 * inset))
			var sx := 1.0 if corner.x == 0.0 else -1.0
			var sy := 1.0 if corner.y == 0.0 else -1.0
			_corner(ov, p, sx, sy, length, col, big)
		if big and s.x > 220.0:
			# Üst ve alt kenarın ortasında küçük elmas.
			for y in [inset, s.y - inset]:
				_diamond(ov, o + Vector2(s.x * 0.5, y), 3.6, col)
	)
	host.resized.connect(ov.queue_redraw)
	ov.queue_redraw()


## Köşe süsü: iki kenar boyunca çizgi, içeri kıvrılan bir volüt ve köşede elmas.
static func _corner(c: CanvasItem, p: Vector2, sx: float, sy: float, length: float, col: Color, big: bool) -> void:
	c.draw_line(p, p + Vector2(sx * length, 0), col, 1.6, true)
	c.draw_line(p, p + Vector2(0, sy * length), col, 1.6, true)
	if big:
		# Art deco yelpaze: köşeden açılan iki eş merkezli yay, aralarında ışın ve uçlarda nokta.
		for ri in 2:
			var rad := length * (0.45 if ri == 0 else 0.78)
			var pts := PackedVector2Array()
			for i in 13:
				var ang := (float(i) / 12.0) * PI * 0.5
				pts.append(p + Vector2(sx * cos(ang), sy * sin(ang)) * rad)
			c.draw_polyline(pts, Color(col, col.a * (0.95 if ri == 0 else 0.6)), 1.5 if ri == 0 else 1.2, true)
		var d := Vector2(sx, sy).normalized()
		c.draw_line(p + d * length * 0.45, p + d * length * 0.78, Color(col, col.a * 0.8), 1.2, true)
		_diamond(c, p + d * length * 0.78, 2.4, col)
		_diamond(c, p + Vector2(sx * length * 0.78, 0), 1.8, col)
		_diamond(c, p + Vector2(0, sy * length * 0.78), 1.8, col)
	_diamond(c, p, 3.2 if big else 2.2, col)


static func _diamond(c: CanvasItem, center: Vector2, r: float, col: Color) -> void:
	c.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -r), center + Vector2(r, 0), center + Vector2(0, r), center + Vector2(-r, 0)]), col)


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
	if Loc.lang == "en":
		return s.to_upper()
	return s.replace("i", "İ").replace("ı", "I").to_upper()


static func box(bg: Color, border: Color = Color(0, 0, 0, 0), radius := 6, margin := 10, border_w := 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w if border.a > 0.0 else 0)
	s.set_corner_radius_all(mini(radius, RADIUS))
	s.content_margin_left = margin
	s.content_margin_right = margin
	s.content_margin_top = maxi(margin - 2, 4)
	s.content_margin_bottom = maxi(margin - 2, 4)
	s.anti_aliasing = true
	return s


## Düğmeyi zeminden 1 px kaldırır (altta keskin gölge): düz kutu yerine basılabilir yüzey.
static func _lift(s: StyleBoxFlat) -> StyleBoxFlat:
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 1
	s.shadow_offset = Vector2(0, 2)
	return s


## Sekme kutusu: yalnızca üst kenarda çizgi; seçili olan altın, panelle birleşik.
static func _tab(bg: Color, line: Color, w: int) -> StyleBoxFlat:
	var s := box(bg, Color(0, 0, 0, 0), 2, 14)
	s.border_color = line
	s.border_width_top = w
	s.corner_radius_bottom_left = 0
	s.corner_radius_bottom_right = 0
	return s


## Boyanmış 9 dilimli doku stili; dosya yoksa null (çağıran düz stile düşer).
static func tex_box(name: String, margins: Array, content: Array = [], tint: Color = Color.WHITE) -> StyleBoxTexture:
	var path := "res://art/ui/%s.png" % name
	if not ResourceLoader.exists(path):
		return null
	var sb := StyleBoxTexture.new()
	sb.texture = load(path)
	sb.texture_margin_left = margins[0]
	sb.texture_margin_top = margins[1]
	sb.texture_margin_right = margins[2]
	sb.texture_margin_bottom = margins[3]
	sb.modulate_color = tint
	if content.size() == 4:
		sb.content_margin_left = content[0]
		sb.content_margin_top = content[1]
		sb.content_margin_right = content[2]
		sb.content_margin_bottom = content[3]
	return sb


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
	t.default_font = sans()
	t.default_font_size = 18 if mobile else 15
	t.set_font("bold_font", "RichTextLabel", sans(680))
	t.set_font("italics_font", "RichTextLabel", sans(500, true))
	t.set_font("bold_italics_font", "RichTextLabel", sans(680, true))
	var bm := 15 if mobile else 12  # düğme iç boşluğu: mobilde daha büyük dokunma alanı
	# Etiketler ve metin
	t.set_color("font_color", "Label", TEXT)
	t.set_color("default_color", "RichTextLabel", TEXT)
	# Düğmeler
	var n := _lift(box(PANEL_HI, Color(GOLD_DIM, 0.8), 5, bm))
	var h := _lift(box(HOVER, GOLD, 5, bm))
	var p := box(Color("13110d"), GOLD, 5, bm)
	var d := box(Color(PANEL_HI, 0.5), Color(GOLD_DIM, 0.15), 5, bm)
	t.set_stylebox("normal", "Button", n)
	t.set_stylebox("hover", "Button", h)
	t.set_stylebox("pressed", "Button", p)
	t.set_stylebox("disabled", "Button", d)
	var bpad := [bm, maxi(bm - 4, 4), bm, maxi(bm - 4, 4)]
	var tn := tex_box("btn_normal", [16, 9, 16, 9], bpad)
	if tn != null:
		t.set_stylebox("normal", "Button", tn)
		t.set_stylebox("hover", "Button", tex_box("btn_hover", [16, 9, 16, 9], bpad))
		t.set_stylebox("pressed", "Button", tex_box("btn_pressed", [16, 9, 16, 9], bpad))
		t.set_stylebox("disabled", "Button", tex_box("btn_normal", [16, 9, 16, 9], bpad, Color(1, 1, 1, 0.4)))
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
	var ch_n := box(Color("1c1915"), Color(GOLD_DIM, 0.55), 4, bm)
	ch_n.border_width_left = 3
	ch_n.border_color = Color(GOLD_DIM, 0.6)
	var ch_h := box(Color("2d2a1f"), GOLD, 4, bm)
	ch_h.border_width_left = 5
	t.set_stylebox("normal", "ChoiceButton", ch_n)
	t.set_stylebox("hover", "ChoiceButton", ch_h)
	if tn != null:
		t.set_stylebox("normal", "ChoiceButton", tex_box("btn_normal", [16, 9, 16, 9], bpad))
		t.set_stylebox("hover", "ChoiceButton", tex_box("btn_hover", [16, 9, 16, 9], bpad))
		t.set_stylebox("pressed", "ChoiceButton", tex_box("btn_pressed", [16, 9, 16, 9], bpad))
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
	var pr_n := _lift(box(Color("3a301a"), GOLD, 6, 14, 2))
	pr_n.shadow_color = Color(GOLD, 0.28)
	pr_n.shadow_size = 9
	pr_n.shadow_offset = Vector2.ZERO
	var pr_h := _lift(box(Color("5a4a22"), Color("ffe08a"), 6, 14, 2))
	pr_h.shadow_color = Color(GOLD, 0.45)
	pr_h.shadow_size = 12
	pr_h.shadow_offset = Vector2.ZERO
	t.set_stylebox("normal", "PrimaryButton", pr_n)
	t.set_stylebox("hover", "PrimaryButton", pr_h)
	var ppad := [30, 10, 30, 10]
	var pn := tex_box("btn_primary", [34, 14, 34, 14], ppad)
	if pn != null:
		t.set_stylebox("normal", "PrimaryButton", pn)
		t.set_stylebox("hover", "PrimaryButton", tex_box("btn_primary", [34, 14, 34, 14], ppad, Color(1.25, 1.2, 1.1)))
		t.set_stylebox("pressed", "PrimaryButton", tex_box("btn_primary", [34, 14, 34, 14], ppad, Color(0.75, 0.7, 0.65)))
	t.set_stylebox("pressed", "PrimaryButton", box(Color("2a2212"), GOLD, 6, 14, 2))
	t.set_color("font_color", "PrimaryButton", Color("fff3d0"))
	t.set_font("font", "PrimaryButton", caps())
	t.set_font_size("font_size", "PrimaryButton", 20)
	# Sekmeler: seçili sekme panelle birleşir, üstünde altın çizgi taşır; diğerleri zeminsiz.
	t.set_stylebox("panel", "TabContainer", box(Color(PANEL, 0.88), Color(GOLD_DIM, 0.55), 6, 8))
	t.set_stylebox("tab_selected", "TabContainer", _tab(Color(PANEL_HI, 0.95), GOLD, 2))
	t.set_stylebox("tab_unselected", "TabContainer", _tab(Color(0, 0, 0, 0.25), Color(GOLD_DIM, 0.25), 1))
	t.set_stylebox("tab_hovered", "TabContainer", _tab(Color(HOVER, 0.8), GOLD_DIM, 1))
	var tp := tex_box("frame_panel_dark", [44, 44, 44, 44], [18, 16, 18, 16])
	if tp != null:
		t.set_stylebox("panel", "TabContainer", tp)
	var ta := tex_box("tab_active", [24, 20, 24, 8], [16, 8, 16, 6])
	if ta != null:
		t.set_stylebox("tab_selected", "TabContainer", ta)
		t.set_stylebox("tab_unselected", "TabContainer", tex_box("tab_idle", [20, 12, 20, 8], [16, 8, 16, 6]))
		t.set_stylebox("tab_hovered", "TabContainer", tex_box("tab_idle", [20, 12, 20, 8], [16, 8, 16, 6], Color(1.6, 1.5, 1.3)))
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
	t.set_stylebox("panel", "TooltipPanel", box(Color(PLATE, 0.97), GOLD, 5, 10))
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
