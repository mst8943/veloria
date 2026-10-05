extends Control
## Medya Merkezi: okunabilir iki gazete ve bir televizyon kanalı.

signal closed

const UIKit := preload("res://game/ui/ui_kit.gd")
const Press := preload("res://game/core/press.gd")
const NEWSPRINT := preload("res://game/ui/newsprint.gdshader")
const PAPER_SHADER := preload("res://game/ui/paper.gdshader")
const CRT_SHADER := preload("res://game/ui/crt.gdshader")

const INK := Color("16120d")
const INK_SOFT := Color("3b3328")
const PAPER := Color("e9e0c9")
const PAPER_FREE := Color("d9d3c2")   # bağımsız gazetenin ucuz, gri kâğıdı
const RUBRIC := Color("7a2a1e")

var mobile := false
var art_fn: Callable          # id -> Texture2D (olay görseli)
var _content: Control
var _tabs: Dictionary = {}
var _current := "state"
var _ticker_tween: Tween


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(UIKit.SHADE.darkened(0.3), 0.97)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var shade := TextureRect.new()   # gazeteyi masa lambası aydınlatıyormuş gibi: ortası açık, kenarlar karanlık
	var g := Gradient.new()
	g.set_color(0, Color(0.16, 0.12, 0.07, 0.55))
	g.set_color(1, Color(0, 0, 0, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 256
	gt.height = 256
	shade.texture = gt
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 16 if mobile else 26)
	add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	var band := PanelContainer.new()
	band.add_theme_stylebox_override("panel", UIKit.band_style())
	v.add_child(band)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	band.add_child(bar)
	var title := Label.new()
	title.text = "MEDYA MERKEZİ"
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", 30 if mobile else 26)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	bar.add_child(title)
	var sp := Control.new()
	sp.custom_minimum_size.x = 20
	bar.add_child(sp)
	for key in ["state", "free", "tv"]:
		var b := Button.new()
		b.text = {"state": "Veloria Haber", "free": "Serbest Kalem", "tv": "Halden TV"}[key]
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(150, 40)
		b.pressed.connect(show_tab.bind(key))
		bar.add_child(b)
		_tabs[key] = b
	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(sp2)
	var close := Button.new()
	close.text = "Masaya dön  (Esc)" if not mobile else "Kapat"
	close.focus_mode = Control.FOCUS_NONE
	close.custom_minimum_size.y = 40
	close.theme_type_variation = "GhostButton"
	close.pressed.connect(close_view)
	bar.add_child(close)
	_content = Control.new()
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.clip_contents = true
	v.add_child(_content)
	hide()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if visible and k and k.pressed and not k.echo and k.keycode == KEY_ESCAPE:
		close_view()
		get_viewport().set_input_as_handled()


func open(tab := "state") -> void:
	# Gizli kurulan Control'ün boyutu kendiliğinden hesaplanmıyor; açılırken ekrana oturt.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = get_parent_area_size()
	show()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)
	show_tab(tab)


func close_view() -> void:
	if _ticker_tween:
		_ticker_tween.kill()
	hide()
	closed.emit()


func show_tab(key: String) -> void:
	_current = key
	for k in _tabs:
		(_tabs[k] as Button).button_pressed = k == key
	for c in _content.get_children():
		c.queue_free()
	if _ticker_tween:
		_ticker_tween.kill()
	if key == "tv":
		_build_tv()
	else:
		_build_paper(key)
	Sfx.play("paper", -6.0)


# ---------------------------------------------------------------- Gazete
# İki gazete bir bakışta ayrılmalı: Veloria Haber resmî ve temiz, Serbest Kalem ucuz kâğıtlı ve sert
# (docs/ux/medya_merkezi_v2.md).

func _ink_label(text: String, size: int, color: Color = INK, serif := false, wrap := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if serif:
		l.add_theme_font_override("font", UIKit.serif())
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Gazete gövdesi: serif, iki yana yaslı; [b] haber yeri için aralıklı büyük harf.
func _ink_body(bbcode: String, size: int, color: Color = INK_SOFT, justify := true) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_theme_font_override("normal_font", UIKit.serif())
	r.add_theme_font_override("bold_font", UIKit.caps())
	r.add_theme_font_override("italics_font", UIKit.serif_italic())
	for k in ["normal_font_size", "bold_font_size", "italics_font_size"]:
		r.add_theme_font_size_override(k, size)
	r.add_theme_color_override("default_color", color)
	# Dar sütunda iki yana yaslama kelime arasında delik açar; orada sola yaslı.
	r.text = ("[fill]%s[/fill]" if justify else "%s") % bbcode
	return r


## Küçük sütun başlığı (EKONOMİ, SOKAK...): kırmızı, kalın sans.
func _kicker(text: String, color: Color = RUBRIC) -> Label:
	var l := _ink_label(text, 12, color, false, false)
	l.add_theme_font_override("font", UIKit.sans(680))
	return l


func _rule(h := 2, color: Color = INK) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size.y = h
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _vrule() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(INK_SOFT, 0.5)
	r.custom_minimum_size.x = 1
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _boxed(child: Control, border: Color, width := 1, margin := 6, bg: Color = Color(0, 0, 0, 0)) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_content_margin_all(margin)
	sb.anti_aliasing = false   # ince baskı çizgileri keskin kalsın
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(child)
	return p


func _build_paper(outlet: String) -> void:
	var ed: Dictionary = Press.edition(Sim, outlet)
	var free := outlet == "free"
	var paper_col := PAPER_FREE if free else PAPER
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content.add_child(scroll)
	var cc := CenterContainer.new()
	cc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(cc)
	var paper := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = paper_col
	sb.shadow_color = Color(0, 0, 0, 0.65)
	sb.shadow_size = 22
	sb.shadow_offset = Vector2(0, 8)
	paper.add_theme_stylebox_override("panel", sb)
	paper.custom_minimum_size.x = 980 if mobile else 1120
	cc.add_child(paper)
	# Kâğıt dokusu: lif, sararma, katlanma izi (metnin altında).
	var fibre := ColorRect.new()
	fibre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pm := ShaderMaterial.new()
	pm.shader = PAPER_SHADER
	pm.set_shader_parameter("base", paper_col)
	pm.set_shader_parameter("fiber", 0.085 if free else 0.045)
	pm.set_shader_parameter("age", 0.42 if free else 0.24)
	fibre.material = pm
	fibre.resized.connect(func() -> void: pm.set_shader_parameter("px_size", fibre.size))
	paper.add_child(fibre)
	var pad := MarginContainer.new()
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 38)
	for side in ["top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 26)
	paper.add_child(pad)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	pad.add_child(v)
	_masthead(v, ed, free)
	if ed["closed"]:
		_build_closed(v, ed)
		_animate_paper(paper)
		return
	var head := _ink_label(str(ed["headline"]), 50 if free else 44, INK, true)
	if free:
		head.add_theme_constant_override("line_spacing", -8)
	v.add_child(head)
	var lead_row := HBoxContainer.new()
	lead_row.add_theme_constant_override("separation", 24)
	v.add_child(lead_row)
	var tex: Texture2D = art_fn.call(str(ed.get("art", ""))) if art_fn.is_valid() else null
	if tex:
		var photo := VBoxContainer.new()
		photo.add_theme_constant_override("separation", 4)
		lead_row.add_child(photo)
		var frame := Control.new()
		frame.custom_minimum_size = Vector2(480, 270)
		frame.clip_contents = true
		photo.add_child(frame)
		var img := TextureRect.new()
		img.texture = tex
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var mat := ShaderMaterial.new()
		mat.shader = NEWSPRINT
		mat.set_shader_parameter("paper", paper_col)
		mat.set_shader_parameter("contrast", 1.45 if free else 1.3)
		img.material = mat
		frame.add_child(img)
		var cap := _ink_label("Fotoğraf: %s" % ("muhabirimiz, başkent" if free else "Veloria Haber arşivi"), 13, INK_SOFT)
		cap.add_theme_font_override("font", UIKit.serif_italic())
		photo.add_child(cap)
	var story := VBoxContainer.new()
	story.add_theme_constant_override("separation", 8)
	story.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lead_row.add_child(story)
	story.add_child(_ink_body("[b]BAŞKENT —[/b] %s" % str(ed["lead"]), 20))
	var pg := 2 + int(ed["week"]) % 6
	var more := _ink_label("Devamı sayfa %d'%s" % [pg, ["de", "te", "te", "te", "da", "de"][pg - 2]], 15, INK_SOFT)
	more.add_theme_font_override("font", UIKit.serif_italic())
	more.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	story.add_child(more)
	v.add_child(_rule(1, INK_SOFT))
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 16)
	v.add_child(cols)
	var i := 0
	for c: Dictionary in ed["columns"]:
		if i > 0:
			cols.add_child(_vrule())
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 3)
		cols.add_child(col)
		col.add_child(_kicker(UIKit.tr_upper(str(c["title"]))))
		col.add_child(_ink_label(str(c["head"]), 21, INK, true))
		col.add_child(_ink_body(str(c["body"]), 16, INK_SOFT, false))
		i += 1
	v.add_child(_rule(1, INK_SOFT))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 20)
	v.add_child(foot)
	var wx := HBoxContainer.new()
	wx.add_theme_constant_override("separation", 10)
	wx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(wx)
	var wk := _kicker("HAVA DURUMU", INK)
	wk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	wx.add_child(wk)
	var wt := _ink_label(str(ed["weather"]), 16, INK_SOFT, true)
	wt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	wx.add_child(wt)
	# İlan: çift çerçeveli küçük kutu
	var ad_text := _ink_label(str(ed["ad"]), 15, INK, true, false)
	ad_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_child(_boxed(_boxed(ad_text, INK, 2, 8), INK, 1, 3))
	_animate_paper(paper)


## Künye: başlık, iki yanda kulakçık kutuları, altında tarih satırı ve çift çizgi.
func _masthead(v: VBoxContainer, ed: Dictionary, free: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	v.add_child(row)
	var week := int(ed["week"])
	if free:
		var tag := _ink_label("BAĞIMSIZ\nHAFTALIK", 13, Color("f3ead6"), false, false)
		tag.add_theme_font_override("font", UIKit.sans(700))
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var tagbox := _boxed(tag, RUBRIC, 0, 10, RUBRIC)
		tagbox.custom_minimum_size.x = 118
		tagbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(tagbox)
	else:
		row.add_child(_ear("HAFTA %d" % week, "Sayı %d" % week))
	var title := _ink_label(str(ed["name"]), 70, INK, false, false)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if free:
		var fv := FontVariation.new()
		fv.base_font = UIKit.sans(760)
		fv.spacing_glyph = -2
		title.add_theme_font_override("font", fv)
		title.add_theme_font_size_override("font_size", 64)
		# Plex en fazla 700 ağırlıkta; büyük boyda kalın tabloid logosu için mürekkep taşması.
		title.add_theme_constant_override("outline_size", 3)
		title.add_theme_color_override("font_outline_color", INK)
	else:
		title.add_theme_font_override("font", UIKit.caps())
	row.add_child(title)
	row.add_child(_ear("FİYATI", "1 kuruş" if free else "2 kuruş"))
	# Tarih satırı: serbest gazetede kırmızı kalın çizgi, resmîde ince çizgi; altında kalın-ince çift çizgi.
	v.add_child(_rule(4, RUBRIC) if free else _rule(1, INK))
	var dl := HBoxContainer.new()
	v.add_child(dl)
	var parts := ["BAŞKENT", UIKit.tr_upper(str(ed["motto"])), "HAFTA %d BASKISI" % week]
	for k in parts.size():
		var l := _kicker(parts[k], INK_SOFT)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.horizontal_alignment = [HORIZONTAL_ALIGNMENT_LEFT, HORIZONTAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_RIGHT][k]
		dl.add_child(l)
	var dbl := VBoxContainer.new()
	dbl.add_theme_constant_override("separation", 2)
	dbl.add_child(_rule(3, INK))
	dbl.add_child(_rule(1, INK))
	v.add_child(dbl)


## Künye kulakçığı: ince çerçeveli iki satırlık kutu.
func _ear(top: String, bottom: String) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	var t := _kicker(top, INK)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var b := _ink_label(bottom, 15, INK_SOFT, true, false)
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(b)
	var box := _boxed(col, INK, 2, 7)   # 1 px çizgi ölçekli çözünürlükte kayboluyor
	box.custom_minimum_size.x = 118
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return box


func _build_closed(v: VBoxContainer, ed: Dictionary) -> void:
	var holder := Control.new()
	holder.custom_minimum_size.y = 360
	v.add_child(holder)
	var faded := _ink_label(str(ed["lead"]), 22, Color(INK_SOFT, 0.55), true)
	faded.set_anchors_preset(Control.PRESET_FULL_RECT)
	faded.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	faded.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	holder.add_child(faded)
	var stamp := PanelContainer.new()
	var ssb := StyleBoxFlat.new()
	ssb.bg_color = Color(0, 0, 0, 0)
	ssb.border_color = Color("a3251b")
	ssb.set_border_width_all(6)
	ssb.set_corner_radius_all(8)
	ssb.set_content_margin_all(18)
	stamp.add_theme_stylebox_override("panel", ssb)
	var sl := _ink_label("YAYIN DURDURULDU", 64, Color("a3251b"), true, false)
	stamp.add_child(sl)
	holder.add_child(stamp)
	stamp.position = Vector2(150, 120)
	stamp.rotation = deg_to_rad(-9.0)
	stamp.modulate.a = 0.0
	var tw := stamp.create_tween()
	tw.tween_interval(0.35)
	tw.tween_property(stamp, "modulate:a", 0.92, 0.12)
	tw.tween_callback(func() -> void: Sfx.play("seal"))


func _animate_paper(paper: Control) -> void:
	# Kâğıt aşağıdan kayarak gelir (eğik bırakılınca ince çizgiler kesik görünüyordu).
	paper.modulate.a = 0.0
	paper.pivot_offset = Vector2(560, 300)
	paper.scale = Vector2(0.97, 0.97)
	var tw := paper.create_tween().set_parallel(true)
	tw.tween_property(paper, "modulate:a", 1.0, 0.35)
	tw.tween_property(paper, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- Televizyon
# Cihaz: ceviz kasalı tüplü televizyon, sağda kontrol paneli; hepsi çizilir. Ekranın en üstündeki
# cam katmanı (crt.gdshader) görüntüyü ve kanal grafiklerini birlikte eğer.

const TV_L := 44.0      # kasa + çerçeve kalınlığı (sol, üst, alt)
const TV_R := 176.0     # sağ: çerçeve + kontrol paneli
const TV_RED := Color("c4271c")
const TV_DARK := Color("141210")


func _tv_label(text: String, size: int, color: Color, weight := 650) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", UIKit.sans(weight))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _build_tv() -> void:
	var b: Dictionary = Press.broadcast(Sim)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content.add_child(cc)
	# Ekran eldeki alana sığar (mobilde yükseklik dar). Alan görünümün kendi boyutundan hesaplanır:
	# gizliyken kurulan _content'in boyutu henüz güncel değil.
	var mg := 16.0 if mobile else 26.0
	var avail := size - Vector2(2.0 * mg, 2.0 * mg + 84.0)
	var w := minf(960.0, minf((avail.y - 2.0 * TV_L) * 16.0 / 9.0, avail.x - TV_L - TV_R))
	var h := w * 9.0 / 16.0
	var tv := Control.new()
	tv.custom_minimum_size = Vector2(TV_L + w + TV_R, 2.0 * TV_L + h)
	tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.add_child(tv)
	tv.draw.connect(_draw_tv.bind(tv, Rect2(TV_L, TV_L, w, h)))
	var screen := Control.new()
	screen.position = Vector2(TV_L, TV_L)
	screen.size = Vector2(w, h)
	screen.clip_contents = true
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tv.add_child(screen)
	var tex: Texture2D = null
	if art_fn.is_valid():
		tex = art_fn.call(str(b.get("art", "")))
		if tex == null:
			tex = art_fn.call("halden_kanal")
	var img := TextureRect.new()
	img.texture = tex
	img.set_anchors_preset(Control.PRESET_FULL_RECT)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(img)
	img.pivot_offset = Vector2(w, h) / 2.0
	var kb := img.create_tween().set_loops()
	kb.tween_property(img, "scale", Vector2(1.08, 1.08), 10.0).set_trans(Tween.TRANS_SINE)
	kb.tween_property(img, "scale", Vector2.ONE, 10.0).set_trans(Tween.TRANS_SINE)
	# Kanal logosu + CANLI (sol üst), bülten adı (sağ üst)
	var bug := HBoxContainer.new()
	bug.position = Vector2(26, 22)
	bug.add_theme_constant_override("separation", 0)
	bug.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(bug)
	bug.add_child(_boxed(_tv_label(str(b["channel"]), 17, TV_DARK, 760), UIKit.GOLD, 0, 7, UIKit.GOLD))
	var live := _boxed(_tv_label("CANLI", 13, Color.WHITE, 700), TV_RED, 0, 7, TV_RED)
	bug.add_child(live)
	var blink := live.create_tween().set_loops()
	blink.tween_property(live, "modulate:a", 0.45, 0.7)
	blink.tween_property(live, "modulate:a", 1.0, 0.7)
	var slot := _tv_label("ANA HABER  20:00", 15, Color.WHITE, 600)
	slot.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	slot.add_theme_constant_override("shadow_outline_size", 5)
	slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slot.position = Vector2(w - 226, 26)
	slot.size = Vector2(200, 24)
	screen.add_child(slot)
	# Alt üçlü bant: kategori etiketi, beyaz manşet şeridi, koyu spot şeridi
	var lower := VBoxContainer.new()
	lower.add_theme_constant_override("separation", 0)
	lower.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lower.anchor_right = 1.0
	lower.anchor_top = 1.0
	lower.anchor_bottom = 1.0
	lower.offset_left = 30
	lower.offset_right = -30
	lower.offset_bottom = -52
	lower.grow_vertical = Control.GROW_DIRECTION_BEGIN
	screen.add_child(lower)
	var tag := _boxed(_tv_label("GÜNDEM", 13, TV_DARK, 720), UIKit.GOLD, 0, 8, UIKit.GOLD)
	tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	lower.add_child(tag)
	var hl := _tv_label(UIKit.tr_upper(str(b["headline"])), 25 if w > 800 else 21, TV_DARK, 700)
	hl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	hl.clip_text = true
	lower.add_child(_boxed(hl, Color(0, 0, 0, 0), 0, 12, Color("f2efe8")))
	var sl := _tv_label(str(b["sub"]), 15, Color("dcd6ca"), 500)
	sl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sl.clip_text = true
	lower.add_child(_boxed(sl, Color(0, 0, 0, 0), 0, 12, Color(TV_DARK, 0.9)))
	# Kayan haber şeridi: solda sabit kırmızı blok, haberler arasında çizilmiş kare ayraç.
	var strip := ColorRect.new()
	strip.color = UIKit.GOLD
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.anchor_right = 1.0
	strip.anchor_top = 1.0
	strip.anchor_bottom = 1.0
	strip.offset_top = -38
	screen.add_child(strip)
	var clip := Control.new()
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.anchor_right = 1.0
	clip.anchor_bottom = 1.0
	clip.offset_left = 128
	strip.add_child(clip)
	var bl := _tv_label("HABERLER", 14, Color.WHITE, 720)
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var block := _boxed(bl, TV_RED, 0, 4, TV_RED)
	block.anchor_bottom = 1.0
	block.offset_right = 128
	strip.add_child(block)
	var tick := HBoxContainer.new()
	tick.add_theme_constant_override("separation", 16)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(tick)
	for item in b["ticker"]:
		tick.add_child(_tv_label(str(item), 17, TV_DARK, 600))
		var sq := ColorRect.new()
		sq.color = TV_RED
		sq.custom_minimum_size = Vector2(7, 7)
		sq.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		sq.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tick.add_child(sq)
	tick.position = Vector2(w, 6)
	_start_ticker.call_deferred(tick, w - 128.0)
	# Cam: en üstte, altındakilerin hepsini eğer
	var glass := ColorRect.new()
	glass.set_anchors_preset(Control.PRESET_FULL_RECT)
	glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gm := ShaderMaterial.new()
	gm.shader = CRT_SHADER
	glass.material = gm
	screen.add_child(glass)


func _start_ticker(tick: Control, w: float) -> void:
	if not is_instance_valid(tick):
		return
	var tw_len := tick.get_minimum_size().x
	var dur := (tw_len + w) / 90.0
	_ticker_tween = tick.create_tween().set_loops()
	_ticker_tween.tween_property(tick, "position:x", -tw_len, dur).from(w)


## Televizyon kasası: ceviz kaplama, ekran çevresinde içe eğimli siyah çerçeve, sağda kontrol paneli.
func _draw_tv(tv: Control, sr: Rect2) -> void:
	var full := Rect2(Vector2.ZERO, tv.size)
	var cab := StyleBoxFlat.new()
	cab.bg_color = Color("3b2618")
	cab.border_color = Color("1c1209")
	cab.set_border_width_all(2)
	cab.set_corner_radius_all(18)
	cab.shadow_color = Color(0, 0, 0, 0.7)
	cab.shadow_size = 30
	cab.shadow_offset = Vector2(0, 12)
	cab.anti_aliasing = true
	tv.draw_style_box(cab, full)
	# Ceviz damarları: sabit tohumla, hafif dalgalı yatay çizgiler
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 46:
		var y := rng.randf_range(10.0, full.size.y - 10.0)
		var amp := rng.randf_range(1.0, 4.0)
		var ph := rng.randf() * TAU
		var col := Color("5a3b24") if rng.randf() < 0.5 else Color("24170d")
		col.a = rng.randf_range(0.12, 0.3)
		var pts := PackedVector2Array()
		for sx in 25:
			var x := 14.0 + (full.size.x - 28.0) * sx / 24.0
			pts.append(Vector2(x, y + sin(x * 0.012 + ph) * amp))
		tv.draw_polyline(pts, col, rng.randf_range(1.0, 2.2), true)
	tv.draw_line(Vector2(18, 2), Vector2(full.size.x - 18, 2), Color(1, 0.9, 0.75, 0.12), 1.0)
	# Ekran çerçevesi: dışta koyu plastik, içte daha koyu eğimli halka
	for ring in [[24.0, Color("15120f"), 20], [12.0, Color("070606"), 14]]:
		var bz := StyleBoxFlat.new()
		bz.bg_color = ring[1]
		bz.set_corner_radius_all(ring[2])
		bz.anti_aliasing = true
		tv.draw_style_box(bz, sr.grow(ring[0]))
	tv.draw_rect(sr, Color(0.01, 0.01, 0.012))
	# Kontrol paneli
	var px := sr.end.x + 34.0
	var pw := TV_R - 34.0 - 22.0
	var panel := Rect2(px, sr.position.y - 10.0, pw, sr.size.y + 20.0)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color("16110c")
	ps.border_color = Color("0a0705")
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(8)
	tv.draw_style_box(ps, panel)
	var cx := px + pw / 2.0
	var brass := Color("c9b27a")
	tv.draw_string(UIKit.sans(720), Vector2(px, panel.position.y + 30.0), "VELTRON", HORIZONTAL_ALIGNMENT_CENTER, pw, 15, brass)
	tv.draw_line(Vector2(px + 14.0, panel.position.y + 42.0), Vector2(px + pw - 14.0, panel.position.y + 42.0), Color(brass, 0.35), 1.0)
	var small := UIKit.sans(600)
	var ky := panel.position.y + 86.0
	for kn in [["KANAL", -0.6], ["SES", 0.9]]:
		tv.draw_circle(Vector2(cx, ky), 22.0, Color("0b0907"))
		tv.draw_circle(Vector2(cx, ky), 18.0, Color("2b231b"))
		tv.draw_arc(Vector2(cx, ky), 18.0, PI * 1.1, PI * 1.6, 12, Color(1, 0.9, 0.7, 0.18), 2.0, true)
		var ang: float = float(kn[1]) - PI / 2.0
		tv.draw_line(Vector2(cx, ky), Vector2(cx, ky) + Vector2(cos(ang), sin(ang)) * 14.0, Color("d8cba8"), 2.0, true)
		tv.draw_string(small, Vector2(px, ky + 38.0), str(kn[0]), HORIZONTAL_ALIGNMENT_CENTER, pw, 10, Color("8f8573"))
		ky += 84.0
	# Hoparlör ızgarası
	var gy := ky - 10.0
	while gy < panel.end.y - 56.0:
		tv.draw_rect(Rect2(px + 16.0, gy, pw - 32.0, 3.0), Color("070504"))
		gy += 8.0
	# Güç düğmesi ve ışığı
	var by := panel.end.y - 30.0
	tv.draw_rect(Rect2(cx - 18.0, by - 7.0, 26.0, 14.0), Color("0b0907"))
	tv.draw_circle(Vector2(cx + 20.0, by), 7.0, Color(1, 0.25, 0.2, 0.18))
	tv.draw_circle(Vector2(cx + 20.0, by), 3.0, Color("ff4a3a"))
