extends Control
## Çalışma Masası: haftanın merkez ekranı. Masadaki her nesne bir kapıdır.
## Gerçek nesne görselleri res://art/desk/<id>.png (saydam PNG) olarak eklenirse onlar kullanılır;
## yoksa nesneler kodla çizilir.

signal request(target: String)

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")
const Press := preload("res://game/core/press.gd")

const LIT_SHADER := preload("res://game/ui/desk_lit.gdshader")
const SHADOW_SHADER := preload("res://game/ui/desk_shadow.gdshader")

const PARCH := Color("e6dcc2")
const INK := Color("1b1610")

## id -> [x, y, w, h] (1600x900 tabanında), etiket. Nesne alanın dibine oturur:
## alt kenar, nesnenin masaya değdiği çizgidir (arkadakiler yukarıda, öndekiler aşağıda).
const LAYOUT := {
	"harita": [Rect2(630, 175, 340, 290), "Başkent · Kurumlar"],
	"hanedan": [Rect2(150, 150, 200, 235), "Hanedan"],
	"kisiler": [Rect2(1370, 300, 220, 200), "Kişiler"],
	"gunluk": [Rect2(130, 440, 240, 290), "Saltanat Günlüğü"],
	"gundem": [Rect2(470, 500, 300, 240), "Gündem"],
	"dosyalar": [Rect2(845, 500, 230, 240), "Gizli Dosyalar"],
	"medya": [Rect2(1140, 560, 330, 220), "Medya"],
}

## id -> [dönüş (derece), yükseklik (gölgenin boyu), dikey kısalma (masaya yatan kâğıt)]
const FEEL := {
	"harita": [-3.0, 0.25, 0.82],
	"hanedan": [0.0, 1.3, 1.0],
	"kisiler": [0.0, 1.0, 1.0],
	"gunluk": [4.0, 0.7, 1.0],
	"gundem": [-6.0, 0.6, 1.0],
	"dosyalar": [5.0, 0.5, 1.0],
	"medya": [3.0, 0.45, 1.0],
}

## Masadaki lambanın ekrandaki yeri (arka plan görselinde sağ arka köşe).
const LAMP_UV := Vector2(0.75, 0.35)

var mobile := false
var media_fresh_fn: Callable   # -> bool: bu haftanın gazetesi okunmadı mı
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
	dim.color = Color(UIKit.SHADE.darkened(0.3), 0.35)
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
	_title.text = tr("HAFTA %d   ·   KRAL ADRİAN IV") % Sim.week
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_override("font", UIKit.serif())
	_title.add_theme_font_size_override("font_size", 34)
	_title.add_theme_color_override("font_color", UIKit.GOLD)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_title.add_theme_constant_override("shadow_outline_size", 8)
	top.add_child(_title)
	var div := UIKit.divider(420.0)
	div.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	top.add_child(div)
	_sub = Label.new()
	var news := ""
	if not Sim.weekly_news.is_empty():
		news = Sim.news_for_display(str(Sim.weekly_news[0]))
	_sub.text = news if news != "" else tr("Masada yeni dosyalar var.")
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
	_open_btn.text = (Loc.ntr("%d KARAR BEKLİYOR   ·   GÜNDEMİ AÇ   »", n) % n) if n > 0 else tr("GÜNDEMİ AÇ   »")
	_open_btn.position = Vector2(500, 818)
	_open_btn.size = Vector2(600, 56)
	_open_btn.focus_mode = Control.FOCUS_NONE
	_open_btn.pressed.connect(func() -> void: _go("gundem"))
	_stage.add_child(_open_btn)


func _go(target: String) -> void:
	Sfx.play("paper", -4.0)
	request.emit(target)


func _make_object(id: String) -> void:
	var spec: Array = LAYOUT[id]
	var r: Rect2 = spec[0]
	var feel: Array = FEEL.get(id, [0.0, 0.6])
	var holder := Control.new()
	holder.position = r.position
	holder.size = r.size
	holder.pivot_offset = r.size / 2.0
	holder.mouse_filter = Control.MOUSE_FILTER_STOP
	holder.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_stage.add_child(holder)
	_objects[id] = holder
	var tex := _art("res://art/desk/%s.png" % id)
	var lit: ShaderMaterial = null
	var cast: ShaderMaterial = null
	var body := Control.new()
	if tex:
		# Görselin oranını koruyarak alana yerleştir; nesne alanın dibine otursun (masaya basar).
		var ts := tex.get_size()
		var k := minf(r.size.x / ts.x, r.size.y / ts.y)
		var dsz := ts * k
		body.position = Vector2((r.size.x - dsz.x) / 2.0, r.size.y - dsz.y)
		body.size = dsz
		body.pivot_offset = Vector2(dsz.x / 2.0, dsz.y)
		body.rotation = deg_to_rad(float(feel[0]))
		body.scale.y = float(feel[2]) if feel.size() > 2 else 1.0
		holder.add_child(body)
		var h := float(feel[1])
		# Gölgeler: önce geniş ve yumuşak düşen gölge (lamba sağ üstte, gölge sol alta),
		# sonra nesnenin dibinde koyu, dar temas gölgesi.
		cast = _shadow_layer(body, tex, dsz, Vector2(-20, 16) * h, 0.035 + 0.025 * h, 0.5)
		_shadow_layer(body, tex, dsz, Vector2(-3, 5) * maxf(h, 0.4), 0.012, 0.8)
		var t := TextureRect.new()
		t.texture = tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_SCALE
		t.size = dsz
		lit = ShaderMaterial.new()
		lit.shader = LIT_SHADER
		lit.set_shader_parameter("light_uv", LAMP_UV)
		lit.set_shader_parameter("lift", 0.0)
		t.material = lit
		body.add_child(t)
	else:
		body.set_anchors_preset(Control.PRESET_FULL_RECT)
		holder.add_child(body)
		var drawn := _draw_object(id, r.size)
		drawn.set_anchors_preset(Control.PRESET_FULL_RECT)
		body.add_child(drawn)
	_ignore_mouse(body)  # iç parçalar tıklamayı yutmasın; tıklama nesneye (holder) ulaşsın
	holder.add_child(_plate(id, str(spec[1]), r.size))
	var visual: Control = body.get_child(body.get_child_count() - 1)
	holder.mouse_entered.connect(func() -> void:
		Sfx.play("hover", -10.0)
		# Üzerine gelince nesne masadan hafifçe kalkar: gölgesi uzaklaşır ve yumuşar.
		var tw := holder.create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
		tw.tween_property(visual, "position:y", -10.0, 0.18)
		if lit:
			tw.tween_property(lit, "shader_parameter/lift", 0.22, 0.18)
		if cast:
			tw.tween_property(cast, "shader_parameter/opacity", 0.32, 0.18)
			tw.tween_property(cast, "shader_parameter/blur", 0.07, 0.18))
	holder.mouse_exited.connect(func() -> void:
		var tw := holder.create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
		tw.tween_property(visual, "position:y", 0.0, 0.2)
		if lit:
			tw.tween_property(lit, "shader_parameter/lift", 0.0, 0.2)
		if cast:
			tw.tween_property(cast, "shader_parameter/opacity", 0.5, 0.2)
			tw.tween_property(cast, "shader_parameter/blur", 0.035 + 0.025 * float(feel[1]), 0.2))
	holder.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			Sfx.play("click")
			_go(id))


## Nesnenin silüetinden gölge katmanı (nesnenin altında, aynı dönüşle).
func _shadow_layer(body: Control, tex: Texture2D, dsz: Vector2, offset: Vector2, blur: float, opacity: float) -> ShaderMaterial:
	const PAD := 0.15
	var s := TextureRect.new()
	s.texture = tex
	s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s.stretch_mode = TextureRect.STRETCH_SCALE
	var grow := dsz * PAD / (1.0 - 2.0 * PAD)
	s.position = offset - grow
	s.size = dsz + grow * 2.0
	var m := ShaderMaterial.new()
	m.shader = SHADOW_SHADER
	m.set_shader_parameter("pad", PAD)
	m.set_shader_parameter("blur", blur)
	m.set_shader_parameter("opacity", opacity)
	s.material = m
	body.add_child(s)
	return m


## Nesnenin altındaki etiket: ad, varsa küçük işaret, ve tek satırlık özet.
func _plate(id: String, title: String, area: Vector2) -> Control:
	var w := maxf(area.x + 60.0, 300.0)
	var plate := Control.new()
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.position = Vector2((area.x - w) / 2.0, area.y + 2.0)
	plate.size = Vector2(w, 70 if mobile else 52)
	# Arkada yumuşak, kenarsız bir karanlık: kutu değil, okunurluk için gölge.
	var shade := TextureRect.new()
	shade.texture = _plate_shade()
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.position = Vector2(-20, -16)
	shade.size = Vector2(w + 40, 86)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(shade)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	plate.add_child(box)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	var name_l := Label.new()
	name_l.text = tr(title)
	name_l.add_theme_font_override("font", UIKit.serif())
	name_l.add_theme_font_size_override("font_size", 31 if mobile else 23)
	name_l.add_theme_color_override("font_color", Color("f1e6c8"))
	name_l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	name_l.add_theme_constant_override("shadow_outline_size", 6)
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(name_l)
	var mark := _mark_text(id)
	if mark != "":
		var b := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("8e231a")
		sb.border_color = Color(0.95, 0.8, 0.55, 0.85)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(11)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		sb.content_margin_top = 0
		sb.content_margin_bottom = 1
		sb.shadow_color = Color(0, 0, 0, 0.5)
		sb.shadow_size = 4
		sb.anti_aliasing = true
		b.add_theme_stylebox_override("panel", sb)
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bl := Label.new()
		bl.text = mark
		bl.add_theme_font_size_override("font_size", 14)
		bl.add_theme_color_override("font_color", Color("fff1dc"))
		b.add_child(bl)
		row.add_child(b)
		_badges[id] = b
	var sum := Label.new()
	sum.text = _summary(id)
	sum.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sum.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sum.clip_text = true
	sum.custom_minimum_size.x = w
	sum.add_theme_font_size_override("font_size", 21 if mobile else 15)
	sum.add_theme_color_override("font_color", Color(0.86, 0.8, 0.68, 0.92))
	sum.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	sum.add_theme_constant_override("shadow_outline_size", 5)
	sum.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(sum)
	return plate


static var _shade_tex: Texture2D


static func _plate_shade() -> Texture2D:
	if _shade_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(0, 0, 0, 0.62))
		g.set_color(1, Color(0, 0, 0, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5)
		gt.fill_to = Vector2(1.0, 0.5)
		gt.width = 256
		gt.height = 64
		_shade_tex = gt
	return _shade_tex


func _ignore_mouse(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_ignore_mouse(c)


## Etiketin yanındaki küçük kırmızı işaret: yalnızca dikkat isteyen şeyler.
func _mark_text(id: String) -> String:
	match id:
		"gundem":
			return str(Sim.pending.size()) if not Sim.pending.is_empty() else ""
		"medya":
			return tr("YENİ") if (not media_fresh_fn.is_valid() or media_fresh_fn.call()) else ""
		"gunluk":
			var due := _due_promises()
			return (Loc.ntr("%d söz", due) % due) if due > 0 else ""
	return ""


func _due_promises() -> int:
	var due := 0
	for p in Sim.promises:
		if p["state"] == "active" and int(p["due"]) - Sim.week <= 2:
			due += 1
	return due


## Etiketin altındaki tek satır: nesneye tıklamadan neyin beklediğini söyler.
func _summary(id: String) -> String:
	match id:
		"gundem":
			if Sim.pending.is_empty():
				return tr("Bekleyen karar yok")
			var urgent: Dictionary = Sim.pending[0]
			for p in Sim.pending:
				if int(p["age"]) > int(urgent["age"]):
					urgent = p
			var head := Loc.ntr("%d karar", Sim.pending.size()) % Sim.pending.size()
			var lead := tr("en acil") if int(urgent["age"]) > 0 else tr("ilki")
			return tr("%s · %s: %s") % [head, lead, urgent["event"]["title"]]
		"medya":
			var ed: Dictionary = Press.edition(Sim, "state")
			var h := str(ed.get("headline", ""))
			return h if h != "" else tr("Bu haftanın gazeteleri")
		"kisiler":
			var enemies := 0
			for a in Sim.actors.values():
				if a.moved:
					enemies += 1
			var t := Loc.ntr("%d mesai", Sim.mesai) % Sim.mesai if Sim.mesai > 0 else tr("Mesai bitti")
			var sus := 0
			for a in Sim.actors.values():
				if not a.moved and Sim.suspicion_level(a.id) >= 2:
					sus += 1
			if enemies > 0:
				t += " · " + (Loc.ntr("%d düşman", enemies) % enemies)
			if sus > 0:
				t += " · " + (Loc.ntr("%d şüpheli", sus) % sus)
			return t
		"gunluk":
			var due := _due_promises()
			if due > 0:
				return Loc.ntr("%d sözün vadesi yaklaşıyor", due) % due
			return tr("Hafta %d · saltanatın kaydı") % Sim.week
		"dosyalar":
			if Sim.facts.is_empty():
				return tr("Dosya şimdilik boş")
			var rumors := 0
			var mine := 0
			for f: Dictionary in Sim.facts.values():
				if f.get("public", false):
					continue
				if f.get("rumor", false):
					rumors += 1
				if f["subject"] == "king":
					mine += 1
			var t := Loc.ntr("%d kayıt", Sim.facts.size()) % Sim.facts.size()
			if mine > 0:
				t += " · " + (tr("%d tanesi sana dair") % mine)
			if rumors > 0:
				t += " · " + (Loc.ntr("%d dedikodu", rumors) % rumors)
			return t
		"harita":
			return tr("Kurumlar ve sokaklar")
		"hanedan":
			var n: int = Sim.load_chronicle().size()
			var ach: int = Sim.load_achievements().size()
			return tr("%d saltanat · %d / %d başarım") % [n, ach, Sim.ACHIEVEMENTS.size()]
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
			var m := _ink(tr("VELORİA HABER"), 26, true)
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
			phone.add_theme_stylebox_override("panel", _panel(Color("16130f"), UIKit.GOLD_DIM, 10, 2))
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
			var stamp := _ink(tr("GİZLİ"), 30, true)
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
			var t := _ink(tr("BAŞKENT"), 34, true)
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
