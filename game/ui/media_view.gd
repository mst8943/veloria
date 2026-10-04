extends Control
## Medya Merkezi: okunabilir iki gazete ve bir televizyon kanalı.

signal closed

const UIKit := preload("res://game/ui/ui_kit.gd")
const Press := preload("res://game/core/press.gd")
const NEWSPRINT := preload("res://game/ui/newsprint.gdshader")
const SCANLINES := preload("res://game/ui/scanlines.gdshader")

const INK := Color("16120d")
const INK_SOFT := Color("3b3328")
const PAPER := Color("e9e0c9")
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
	dim.color = Color(0.02, 0.015, 0.025, 0.9)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 16 if mobile else 26)
	add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	v.add_child(bar)
	var title := Label.new()
	title.text = "MEDYA MERKEZİ"
	title.add_theme_font_override("font", UIKit.serif())
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


func _rule(h := 2, color: Color = INK) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size.y = h
	return r


func _build_paper(outlet: String) -> void:
	var ed: Dictionary = Press.edition(Sim, outlet)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content.add_child(scroll)
	var cc := CenterContainer.new()
	cc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(cc)
	var paper := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PAPER
	sb.border_color = Color("b9ad90")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	sb.shadow_color = Color(0, 0, 0, 0.6)
	sb.shadow_size = 18
	sb.set_content_margin_all(34)
	paper.add_theme_stylebox_override("panel", sb)
	paper.custom_minimum_size.x = 980 if mobile else 1120
	cc.add_child(paper)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	paper.add_child(v)
	var mast := _ink_label(str(ed["name"]), 70, INK, true, false)
	mast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(mast)
	var info := _ink_label("Hafta %d   ·   Başkent   ·   Sayı %d   ·   Fiyatı 2 kuruş       %s" % [ed["week"], ed["week"], ed["motto"]], 14, INK_SOFT, false, false)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(info)
	v.add_child(_rule(3))
	v.add_child(_rule(1, INK_SOFT))
	if ed["closed"]:
		_build_closed(v, ed)
		_animate_paper(paper)
		return
	var head := _ink_label(str(ed["headline"]), 44, INK, true)
	v.add_child(head)
	var lead_row := HBoxContainer.new()
	lead_row.add_theme_constant_override("separation", 22)
	v.add_child(lead_row)
	var tex: Texture2D = art_fn.call(str(ed.get("art", ""))) if art_fn.is_valid() else null
	if tex:
		var frame := Control.new()
		frame.custom_minimum_size = Vector2(480, 270)
		frame.clip_contents = true
		lead_row.add_child(frame)
		var img := TextureRect.new()
		img.texture = tex
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var mat := ShaderMaterial.new()
		mat.shader = NEWSPRINT
		img.material = mat
		frame.add_child(img)
	var lead := _ink_label(str(ed["lead"]), 19, INK_SOFT)
	lead.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lead_row.add_child(lead)
	v.add_child(_rule(1, INK_SOFT))
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 16)
	v.add_child(cols)
	var i := 0
	for c: Dictionary in ed["columns"]:
		if i > 0:
			var sep := ColorRect.new()
			sep.color = Color(INK_SOFT, 0.5)
			sep.custom_minimum_size.x = 1
			cols.add_child(sep)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 4)
		cols.add_child(col)
		col.add_child(_ink_label(str(c["title"]), 13, RUBRIC, false, false))
		col.add_child(_ink_label(str(c["head"]), 20, INK, true))
		col.add_child(_ink_label(str(c["body"]), 15, INK_SOFT))
		i += 1
	v.add_child(_rule(1, INK_SOFT))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 20)
	v.add_child(foot)
	var wx := _ink_label("HAVA DURUMU  ·  " + str(ed["weather"]), 14, INK_SOFT)
	wx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(wx)
	var ad := PanelContainer.new()
	var asb := StyleBoxFlat.new()
	asb.bg_color = Color(0, 0, 0, 0)
	asb.border_color = INK
	asb.set_border_width_all(2)
	asb.set_content_margin_all(8)
	ad.add_theme_stylebox_override("panel", asb)
	ad.add_child(_ink_label(str(ed["ad"]), 13, INK, false, false))
	foot.add_child(ad)
	_animate_paper(paper)


func _build_closed(v: VBoxContainer, ed: Dictionary) -> void:
	var holder := Control.new()
	holder.custom_minimum_size.y = 360
	v.add_child(holder)
	var faded := _ink_label(str(ed["lead"]), 22, Color(INK_SOFT, 0.55))
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

func _build_tv() -> void:
	var b: Dictionary = Press.broadcast(Sim)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content.add_child(cc)
	var bezel := PanelContainer.new()
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color("0b0b0d")
	bsb.border_color = Color("2b2a31")
	bsb.set_border_width_all(3)
	bsb.set_corner_radius_all(22)
	bsb.set_content_margin_all(18)
	bsb.shadow_color = Color(0, 0, 0, 0.7)
	bsb.shadow_size = 24
	bezel.add_theme_stylebox_override("panel", bsb)
	cc.add_child(bezel)
	var screen := Control.new()
	var w := 960.0 if not mobile else 900.0
	screen.custom_minimum_size = Vector2(w, w * 9.0 / 16.0)
	screen.clip_contents = true
	bezel.add_child(screen)
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
	var mat := ShaderMaterial.new()
	mat.shader = SCANLINES
	img.material = mat
	screen.add_child(img)
	img.pivot_offset = Vector2(w, w * 9.0 / 16.0) / 2.0
	var kb := img.create_tween().set_loops()
	kb.tween_property(img, "scale", Vector2(1.08, 1.08), 10.0).set_trans(Tween.TRANS_SINE)
	kb.tween_property(img, "scale", Vector2.ONE, 10.0).set_trans(Tween.TRANS_SINE)
	# Kanal logosu ve CANLI rozeti
	var logo := HBoxContainer.new()
	logo.position = Vector2(20, 18)
	logo.add_theme_constant_override("separation", 10)
	screen.add_child(logo)
	var ch := Label.new()
	ch.text = str(b["channel"])
	ch.add_theme_font_override("font", UIKit.serif())
	ch.add_theme_font_size_override("font_size", 26)
	ch.add_theme_color_override("font_color", Color.WHITE)
	ch.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	ch.add_theme_constant_override("shadow_outline_size", 6)
	logo.add_child(ch)
	var live := PanelContainer.new()
	var lsb := StyleBoxFlat.new()
	lsb.bg_color = Color("c4271c")
	lsb.set_corner_radius_all(4)
	lsb.content_margin_left = 8
	lsb.content_margin_right = 8
	lsb.content_margin_top = 2
	lsb.content_margin_bottom = 2
	live.add_theme_stylebox_override("panel", lsb)
	var ll := Label.new()
	ll.text = "CANLI"
	ll.add_theme_font_size_override("font_size", 14)
	ll.add_theme_color_override("font_color", Color.WHITE)
	live.add_child(ll)
	live.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	logo.add_child(live)
	var blink := live.create_tween().set_loops()
	blink.tween_property(live, "modulate:a", 0.35, 0.6)
	blink.tween_property(live, "modulate:a", 1.0, 0.6)
	# Alt bant: manşet
	var lower := PanelContainer.new()
	var lowsb := StyleBoxFlat.new()
	lowsb.bg_color = Color(0.04, 0.04, 0.06, 0.88)
	lowsb.border_color = UIKit.GOLD
	lowsb.border_width_top = 3
	lowsb.content_margin_left = 18
	lowsb.content_margin_right = 18
	lowsb.content_margin_top = 10
	lowsb.content_margin_bottom = 10
	lower.add_theme_stylebox_override("panel", lowsb)
	lower.anchor_left = 0.0
	lower.anchor_right = 1.0
	lower.anchor_top = 1.0
	lower.anchor_bottom = 1.0
	lower.offset_top = -150
	lower.offset_bottom = -44
	screen.add_child(lower)
	var lv := VBoxContainer.new()
	lower.add_child(lv)
	var hl := Label.new()
	hl.text = UIKit.tr_upper(str(b["headline"]))
	hl.add_theme_font_override("font", UIKit.serif())
	hl.add_theme_font_size_override("font_size", 28)
	hl.add_theme_color_override("font_color", Color.WHITE)
	hl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lv.add_child(hl)
	var sl := Label.new()
	sl.text = str(b["sub"])
	sl.add_theme_font_size_override("font_size", 15)
	sl.add_theme_color_override("font_color", Color("cfcac0"))
	sl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lv.add_child(sl)
	# Kayan haber şeridi
	var strip := ColorRect.new()
	strip.color = UIKit.GOLD
	strip.anchor_left = 0.0
	strip.anchor_right = 1.0
	strip.anchor_top = 1.0
	strip.anchor_bottom = 1.0
	strip.offset_top = -44
	strip.clip_contents = true
	screen.add_child(strip)
	var tick := Label.new()
	tick.text = "     ".join(b["ticker"]) + "     "
	tick.add_theme_font_size_override("font_size", 18)
	tick.add_theme_color_override("font_color", Color("120f0b"))
	tick.position = Vector2(w, 8)
	strip.add_child(tick)
	_start_ticker.call_deferred(tick, w)


func _start_ticker(tick: Label, w: float) -> void:
	if not is_instance_valid(tick):
		return
	var tw_len := tick.get_minimum_size().x
	var dur := (tw_len + w) / 90.0
	_ticker_tween = tick.create_tween().set_loops()
	_ticker_tween.tween_property(tick, "position:x", -tw_len, dur).from(w)
