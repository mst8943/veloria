extends RefCounted

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")

var host: Control
var decision_index := 0
var reasons_button: Button
var nav_buttons: Array[Button] = []

func _init(main: Control) -> void:
	host = main

## İlk haftalarda yeni oyuncuya kısa yol gösterme notları (hafta -> metin).
const ADVICE := {
	1: "Majesteleri, bu masada sayılar yoktur, insanlar vardır. Aşağıdaki kartlar kararınızı bekliyor; her karar, emir ve operasyon sınırlı mesainizden harcar. Raporları da okuyun, ama hepsine inanmayın.",
	2: "Bir kişiyi seçip 'Doğrula' derseniz raporunu başka kaynaklarla karşılaştırırım. Kimin sizi süslediğini, kimin gerçeği söylediğini zamanla görürsünüz.",
	3: "Kararları ertelemek de bir karardır: iki hafta sonra kendi kendine, çoğu zaman en kötü biçimde çözülür.",
	4: "Terfi ve gizli ödeme sadakat getirir. Ama terfi ettirdiğiniz kişi güçlenir, para ise iz bırakır. İzler 'Dosyalar' sekmesinde birikir.",
	6: "Birini gerçekten kontrol etmek istiyorsanız önce 'Araştır' ile zayıf noktasını öğrenin. Şantaj güçlüdür, ama geri tepebilir.",
	8: "Bir güç merkezi fazla büyüyorsa rakibini güçlendirin. Kimse sizi tek başına deviremeyecek kadar zayıf kalmalı.",
	18: "Bıraktığınız izler unutulmaz, sadece bekler. Dosyalar sekmesinde 'dedikodu' olanları bastırın ya da kanıtı yok edin; manşete çıkan her sır hem yargıyı hem de size karşı birleşmek isteyenleri cesaretlendirir.",
	12: "İlk haftaların sessizliği bitiyor. Artık bir koalisyon sizi devirebilir. Raporlar birbirine benzemeye başlarsa, kimsenin size gerçeği söylemediğini bilin.",
}

## İlk haftaların yol göstericisi: haftanın dört adımı ve sıradaki adım.
const GUIDE_STEPS := [
	["Kararını ver", "Aşağıdaki karar kartından bir seçenek seç. Meclisin görüşü yol gösterir; ama herkesin bir çıkarı var."],
	["Raporları oku", "Raporlar bu sayfanın altında, gazeteler Medya'da. Herkes yalan söyleyebilir; çelişkilere bak."],
	["Bir kişiye eylem", "Bir portreye tıkla, Eylemler panelinde bir sekme ve eylem seç. Her eylem mesai harcar."],
	["Haftayı bitir", "Mesain bittiyse ya da yapacak şey kalmadıysa sağ alttaki düğmeye bas; dünya bir hafta ilerler."],
]


func _guide_step() -> int:
	if not Sim.pending.is_empty() and Sim.mesai > 0:
		return 1
	if host._media_seen_week != Sim.week:
		return 2
	if host._acted_week != Sim.week and Sim.mesai > 0:
		return 3
	return 4


func _add_guide(animated: Array[Control]) -> void:
	var step := _guide_step()
	var panel := PanelContainer.new()
	panel.name = "WeeklyGuide"
	panel.add_theme_stylebox_override("panel", UIKit.box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0))
	host._agenda.add_child(panel)
	animated.append(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	panel.add_child(v)
	var head := Label.new()
	head.text = tr("BU HAFTA NE YAPMALI?")
	head.add_theme_font_override("font", UIKit.caps())
	head.add_theme_font_size_override("font_size", host._fs(15))
	head.add_theme_color_override("font_color", UIKit.GOLD)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	v.add_child(head)
	if host._mobile:
		var guide_divider := UIKit.divider(200, UIKit.GOLD)
		guide_divider.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		v.add_child(guide_divider)
	var step_bar := Control.new()
	step_bar.name = "WeeklySteps"
	step_bar.custom_minimum_size.y = 42 if host._mobile else 36
	step_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	step_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	step_bar.draw.connect(func() -> void:
		var width := step_bar.size.x / float(GUIDE_STEPS.size())
		var h := step_bar.size.y
		var y := h * 0.5
		# Mockup: koyu, ince kenarlı tek bir çubuk; adımlar arasında ince altın bağlantı çizgileri.
		var bar := StyleBoxFlat.new()
		bar.bg_color = Color(0, 0, 0, 0.32)
		bar.border_color = Color(UIKit.GOLD_DIM, 0.28)
		bar.set_border_width_all(1)
		bar.set_corner_radius_all(4)
		step_bar.draw_style_box(bar, Rect2(Vector2.ZERO, step_bar.size))
		var font := UIKit.sans()
		var fs: int = host._fs(14)
		var half: Array[float] = []
		for i in GUIDE_STEPS.size():
			half.append(font.get_string_size(tr("%d   %s") % [i + 1, tr(GUIDE_STEPS[i][0])], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.5 + (26.0 if i + 1 == step else 12.0))
		for i in range(GUIDE_STEPS.size() - 1):
			var from := Vector2((float(i) + 0.5) * width + half[i], y)
			var to := Vector2((float(i) + 1.5) * width - half[i + 1], y)
			if to.x - from.x > 8.0:
				step_bar.draw_line(from, to, UIKit.OK if i + 1 < step else Color(UIKit.GOLD_DIM, 0.55), 1.2, true)
		var cx := (float(step) - 0.5) * width
		var pw := half[step - 1] - 4.0
		var ph := h * 0.5 - 3.0
		var tip := 10.0
		var points := PackedVector2Array([Vector2(cx - pw + tip, y - ph), Vector2(cx + pw - tip, y - ph), Vector2(cx + pw, y), Vector2(cx + pw - tip, y + ph), Vector2(cx - pw + tip, y + ph), Vector2(cx - pw, y), Vector2(cx - pw + tip, y - ph)])
		step_bar.draw_colored_polygon(points, Color(UIKit.GOLD, 0.14))
		step_bar.draw_polyline(points, Color(UIKit.GOLD, 0.9), 1.4, true)
		for sx in [cx - pw, cx + pw]:
			step_bar.draw_colored_polygon(PackedVector2Array([Vector2(sx, y - 3), Vector2(sx + 3, y), Vector2(sx, y + 3), Vector2(sx - 3, y)]), UIKit.GOLD))
	v.add_child(step_bar)
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	step_bar.add_child(row)
	for i in GUIDE_STEPS.size():
		var b := Button.new()
		b.text = tr("%d   %s") % [i + 1, tr(GUIDE_STEPS[i][0])]
		b.theme_type_variation = "GhostButton"
		b.toggle_mode = true
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 44 if host._mobile else 36
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_override("font", UIKit.sans())
		b.add_theme_font_size_override("font_size", host._fs(14))
		b.tooltip_text = tr(GUIDE_STEPS[i][1])
		var col := UIKit.GOLD if i + 1 == step else (UIKit.OK if i + 1 < step else UIKit.TEXT_DIM)
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
			b.add_theme_color_override(c, col)
		b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		b.add_theme_stylebox_override("hover", UIKit.box(Color(UIKit.GOLD, 0.08), Color(0, 0, 0, 0), 0, 2))
		b.add_theme_stylebox_override("pressed", UIKit.box(Color(UIKit.GOLD, 0.12), Color(0, 0, 0, 0), 0, 2) if host._mobile else StyleBoxEmpty.new())
		b.set_pressed_no_signal(i + 1 == step)
		b.pressed.connect(_guide_go.bind(i + 1))
		host._wire(b)
		row.add_child(b)
	var tip := Label.new()
	tip.text = tr(GUIDE_STEPS[step - 1][1])
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.add_theme_font_override("font", UIKit.sans())
	tip.add_theme_font_size_override("font_size", host._fs(13 if host._mobile else 14))
	tip.add_theme_color_override("font_color", Color("d8cba8") if host._mobile else UIKit.TEXT)
	v.add_child(tip)


## Yol göstericideki adıma tıklayınca ilgili yere götürür.
func _guide_go(step: int) -> void:
	match step:
		1:
			host._on_flow("gundem")
		2:
			host._open_media()
		3:
			var saray := host._tabs.get_node_or_null("Kişiler") as Control
			if saray != null:
				host._select_tab(saray)
			host._hint(tr("Bir kişiye eylem\n") + tr(GUIDE_STEPS[2][1]))
			if host._grid != null and not host._fast():
				UIKit.pulse(host._grid, 1.02)
		_:
			if not host._fast():
				UIKit.pulse(host._end_btn, 1.05)
	host._refresh()

func _pill(text: String, col: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := UIKit.box(Color(col, 0.14), Color(col, 0.55), 6, 8 if host._mobile else 7)
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	p.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(row)
	var mark := Control.new()
	mark.custom_minimum_size = Vector2(6, 6)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.draw.connect(func() -> void:
		mark.draw_colored_polygon(PackedVector2Array([Vector2(3, 0), Vector2(6, 3), Vector2(3, 6), Vector2(0, 3)]), col)
	)
	row.add_child(mark)
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", UIKit.sans(680))
	l.add_theme_font_size_override("font_size", host._fs(11))
	l.add_theme_color_override("font_color", col.lightened(0.25))
	row.add_child(l)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p


func _rebuild_facts() -> void:
	for c in host._fact_box.get_children():
		c.queue_free()
	host._fact_ids.clear()
	if Sim.facts.is_empty():
		var empty := Label.new()
		empty.text = tr("Henüz dosyada bir şey yok. Gizli işler iz bırakır; izler burada birikir.")
		empty.add_theme_font_override("font", UIKit.sans())
		empty.add_theme_color_override("font_color", UIKit.TEXT_DIM)
		host._fact_box.add_child(empty)
		return
	# Önce sana dokunan ve manşete en yakın olanlar
	var list: Array = Sim.facts.values()
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ka := (1 if a["subject"] == "king" else 0) * 10.0 + float(a["common"])
		var kb := (1 if b["subject"] == "king" else 0) * 10.0 + float(b["common"])
		return ka > kb)
	for f: Dictionary in list:
		var fid: String = f["id"]
		host._fact_ids.append(fid)
		var mine: bool = f["subject"] == "king"
		var card := PanelContainer.new()
		var card_style := UIKit.box(Color(UIKit.PANEL, 0.88), Color(UIKit.GOLD_DIM, 0.22), UIKit.RADIUS, 10)
		card.add_theme_stylebox_override("panel", card_style)
		host._fact_box.add_child(card)
		var hrow := HBoxContainer.new()
		hrow.add_theme_constant_override("separation", 10)
		card.add_child(hrow)
		var tone_bar := ColorRect.new()
		tone_bar.color = UIKit.DANGER if mine else (Color("d9963e") if f.get("rumor", false) else UIKit.OK)
		tone_bar.custom_minimum_size = Vector2(4, 0)
		tone_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tone_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hrow.add_child(tone_bar)
		var p_id := "king" if mine else str(f.get("subject", "voss"))
		var por: Control = host._initial_art(p_id, Vector2(38, 38), 18)
		por.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var por_edge := Panel.new()
		var pes := StyleBoxFlat.new()
		pes.draw_center = false
		pes.border_color = Color(UIKit.GOLD, 0.6)
		pes.set_border_width_all(1)
		por_edge.add_theme_stylebox_override("panel", pes)
		por_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		por_edge.set_anchors_preset(Control.PRESET_FULL_RECT)
		por.add_child(por_edge)
		hrow.add_child(por)
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_constant_override("separation", 5)
		hrow.add_child(v)
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		v.add_child(top)
		var t := Label.new()
		t.text = Sim.fact_text_for_display(f)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.add_theme_font_override("font", UIKit.sans(680))
		t.add_theme_font_size_override("font_size", host._fs(15))
		top.add_child(t)
		if mine:
			top.add_child(_pill(tr("SANA DAİR"), UIKit.DANGER))
		var state_t := tr("GİZLİ")
		var state_c := UIKit.OK
		if f.get("public", false):
			state_t = tr("KAMUYA AÇIK")
			state_c = UIKit.DANGER
		elif f.get("rumor", false):
			state_t = tr("DEDİKODU")
			state_c = Color("d9963e")
		top.add_child(_pill(state_t, state_c))
		var info := HBoxContainer.new()
		info.add_theme_constant_override("separation", 10)
		v.add_child(info)
		var who := Label.new()
		who.text = tr("%d kişi biliyor  ·  %d kopya") % [f["knowers"].size(), int(f["copies"])]
		who.add_theme_font_override("font", UIKit.sans())
		who.add_theme_font_size_override("font_size", host._fs(12))
		who.add_theme_color_override("font_color", UIKit.TEXT_DIM)
		info.add_child(who)
		var bar := ProgressBar.new()
		bar.max_value = 1.0
		bar.value = float(f["common"])
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 8)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var fill := UIKit.box(state_c, Color(0, 0, 0, 0), 3, 0)
		bar.add_theme_stylebox_override("fill", fill)
		info.add_child(bar)
		if not f.get("public", false):
			var br := HBoxContainer.new()
			br.add_theme_constant_override("separation", 6)
			v.add_child(br)
			for kind in [["leak", tr("Sızdır")], ["hush", tr("Bastır")], ["destroy", tr("Kanıtı Yok Et")]]:
				var b := Button.new()
				b.text = kind[1]
				b.add_theme_font_override("font", UIKit.sans())
				b.add_theme_font_size_override("font_size", host._fs(13))
				b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				b.disabled = Sim.mesai < 1
				if kind[0] == "leak" and mine:
					b.theme_type_variation = "DangerButton"
				b.tooltip_text = host._action_tip(kind[0])
				host._wire(b)
				b.pressed.connect(host._fact_act.bind(kind[0], fid))
				br.add_child(b)
		elif mine and not f.has("response"):
			var response_row := GridContainer.new()
			response_row.columns = 2 if host._mobile else 4
			response_row.add_theme_constant_override("separation", 4)
			v.add_child(response_row)
			for response in [["deny", tr("İnkâr")], ["apologize", tr("Özür Dile")], ["scapegoat", tr("Kurban Bul")], ["redirect", tr("Gündem Değiştir")]]:
				var response_button := Button.new()
				response_button.text = response[1]
				response_button.custom_minimum_size.y = 44 if host._mobile else 0
				response_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				response_button.add_theme_font_override("font", UIKit.sans())
				response_button.add_theme_font_size_override("font_size", host._fs(12))
				response_button.disabled = Sim.mesai < 1
				response_button.pressed.connect(host._fact_act.bind(response[0], fid))
				host._wire(response_button)
				response_row.add_child(response_button)


func _rebuild_agenda() -> void:
	var keep_scroll: int = host._scroll.scroll_vertical
	decision_index = clampi(decision_index, 0, maxi(0, Sim.pending.size() - 1))
	for c in host._agenda.get_children():
		c.queue_free()
	host._decision_buttons.clear()
	host._decision_cards.clear()
	reasons_button = null
	nav_buttons.clear()
	var animated: Array[Control] = []
	if Sfx.tips and Sim.week <= 3:
		_add_guide(animated)
	if not host._mobile and Sfx.tips and ADVICE.has(Sim.week) and (host._tour == null or not host._tour.active):
		# Saray kâtibinin notu (mobilde ilk haftalarda yol gösterici yeterli; kart ekrana sığsın): tek ince satır (gündemin en değerli yerini kaplamasın).
		var note := PanelContainer.new()
		var nsb := UIKit.box(Color(0.11, 0.095, 0.06, 0.85), Color(UIKit.GOLD_DIM, 0.45), 6, 8)
		nsb.content_margin_top = 4
		nsb.content_margin_bottom = 4
		note.add_theme_stylebox_override("panel", nsb)
		note.tooltip_text = tr("Saray kâtibinin notu. İpuçları Ayarlar'dan kapatılabilir.")
		note.mouse_filter = Control.MOUSE_FILTER_PASS
		host._agenda.add_child(note)
		animated.append(note)
		var nh := HBoxContainer.new()
		nh.add_theme_constant_override("separation", 14)
		nh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		note.add_child(nh)
		nsb.content_margin_top = 8
		nsb.content_margin_bottom = 8
		nsb.content_margin_left = 12
		var ic: Control = host._header_symbol("envelope", Vector2(30, 24), UIKit.GOLD)
		nh.add_child(ic)
		var nl := Label.new()
		nl.text = tr(ADVICE[Sim.week])
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nl.add_theme_font_override("font", UIKit.sans())
		nl.add_theme_font_size_override("font_size", host._fs(14))
		nl.add_theme_color_override("font_color", UIKit.TEXT)
		nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nh.add_child(nl)
	if not Sim.pending.is_empty():
		# Yardımcı metin yalnızca ilk haftalarda; sonra tekrar etmesin.
		var section: Control = host._section(tr("KARAR BEKLEYENLER"), tr("her karar 1 mesai · ertelenen karar 2 hafta sonra kendiliğinden çözülür") if Sim.week <= 4 and not host._mobile else "")
		if Sim.pending.size() == 1:
			host._agenda.add_child(section)
		else:
			var nav := HBoxContainer.new()
			host._agenda.add_child(nav)
			section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			nav.add_child(section)
			var previous := _nav_button(-1)
			nav.add_child(previous)
			nav_buttons.append(previous)
			var count := Label.new()
			count.text = Loc.ntr("Karar %d/%d", Sim.pending.size()) % [decision_index + 1, Sim.pending.size()]
			count.add_theme_color_override("font_color", UIKit.GOLD)
			count.add_theme_font_size_override("font_size", host._fs(13))
			count.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			nav.add_child(count)
			for index in Sim.pending.size():
				var dot := Control.new()
				dot.custom_minimum_size = Vector2(12, 12)
				dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
				dot.draw.connect(func() -> void: dot.draw_circle(Vector2(6, 6), 3.5, UIKit.GOLD if index == decision_index else UIKit.GOLD_DIM))
				nav.add_child(dot)
			var following := _nav_button(1)
			nav.add_child(following)
			nav_buttons.append(following)
	else:
		var empty := Label.new()
		empty.text = tr("Bu hafta bekleyen karar yok. Kişilerle ilgilen ya da haftayı bitir.")
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_color_override("font_color", UIKit.TEXT if host._mobile else Color(UIKit.TEXT, 0.82))
		empty.add_theme_font_override("font", UIKit.sans())
		empty.add_theme_font_size_override("font_size", host._fs(15 if host._mobile else 14))
		host._agenda.add_child(empty)
	for pi in Sim.pending.size():
		if pi != decision_index:
			continue
		var p: Dictionary = Sim.pending[pi]
		var e: Dictionary = p["event"]
		var card := PanelContainer.new()
		# Göz önce ilk karta ve süresi dolanlara gitsin; diğerleri sakin çerçeveli.
		var crisis: bool = e.get("crisis", false)
		var lead: bool = pi == 0 or int(p["age"]) > 0 or crisis
		var card_box := UIKit.box(Color(UIKit.PANEL, 0.96), Color(0, 0, 0, 0), UIKit.RADIUS, 12 if host._mobile else 14, 0)
		card_box.set_border_width_all(0)
		if host._mobile:
			card_box.content_margin_top = 10
			card_box.content_margin_bottom = 8
			card_box.content_margin_left = 12
			card_box.content_margin_right = 24
		else:
			card_box.content_margin_top = 12
			card_box.content_margin_bottom = 12
			card_box.content_margin_left = 16
			card_box.content_margin_right = 16
		card_box.shadow_color = Color(0, 0, 0, 0.45)
		card_box.shadow_size = 8 if lead else 4
		card.add_theme_stylebox_override("panel", card_box)
		host._agenda.add_child(card)
		UIKit.ornament(card, Color(UIKit.DANGER if crisis else UIKit.GOLD, 0.8), 14 if host._mobile else 18, 1)
		host._decision_cards.append(card)
		animated.append(card)
		if (p["age"] > 0 or crisis) and not host._fast():
			var ov := card.get_node_or_null("Ornament")
			if ov:
				var pulse := card.create_tween().set_loops()
				var c1 := Color(1.2, 0.4, 0.35) if crisis else Color(1.0, 0.85, 0.45)
				var c2 := Color(0.85, 0.2, 0.15) if crisis else Color(1.2, 0.4, 0.35)
				pulse.tween_property(ov, "modulate", c2, 0.9).set_trans(Tween.TRANS_SINE)
				pulse.tween_property(ov, "modulate", c1, 0.9).set_trans(Tween.TRANS_SINE)
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 6 if host._mobile else 14)
		card.add_child(hb)
		var tex: Texture2D = host._event_art(str(e.get("art", e["id"])))
		if tex == null:
			card_box.content_margin_top = 14 if not host._mobile else 12
		if tex:
			# Görsel kendi çerçevesinde yavaşça hareket eder (yaşayan kart).
			var frame := Control.new()
			frame.custom_minimum_size = Vector2(320, 120) if host._mobile else Vector2(240, 135)
			if host._mobile:
				frame.size_flags_vertical = Control.SIZE_EXPAND_FILL   # görsel kart yüksekliğini doldurur (kırpılarak)
			frame.clip_contents = true
			hb.add_child(frame)
			var img := TextureRect.new()
			img.texture = tex
			img.set_anchors_preset(Control.PRESET_FULL_RECT)
			img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			frame.add_child(img)
			var edge := Panel.new()
			var es := StyleBoxFlat.new()
			es.draw_center = false
			es.border_color = Color(UIKit.GOLD, 0.7)
			es.set_border_width_all(1)
			edge.add_theme_stylebox_override("panel", es)
			edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			edge.set_anchors_preset(Control.PRESET_FULL_RECT)
			frame.add_child(edge)
			if not host._fast():
				img.pivot_offset = frame.custom_minimum_size / 2.0
				var drift := img.create_tween().set_loops()
				drift.tween_property(img, "scale", Vector2(1.08, 1.08), 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				drift.tween_property(img, "scale", Vector2.ONE, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 0 if host._mobile else 3)
		hb.add_child(vb)
		var t := Label.new()
		t.text = str(e["title"])
		t.add_theme_font_override("font", UIKit.serif())
		t.add_theme_font_size_override("font_size", host._fs(17 if host._mobile else 22))
		t.add_theme_color_override("font_color", UIKit.GOLD)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if host._mobile:
			t.custom_minimum_size.y = 44
			t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var late_text := ""
		if p["age"] > 0 or crisis:
			late_text = str(e.get("banner", tr("Bu hafta karar vermezsen saray düşer."))) if crisis else tr("Karar bekliyor — bu hafta çözülmezse kendi kendine çözülecek.")
		vb.add_child(t)
		if late_text != "":
			var late := Label.new()
			late.text = late_text
			late.tooltip_text = late_text
			late.add_theme_color_override("font_color", UIKit.DANGER)
			late.add_theme_font_size_override("font_size", host._fs(11 if host._mobile else 13))
			vb.add_child(late)
		var d := Label.new()
		d.text = str(e.get("mobile_text", e["text"])) if host._mobile and str(e.get("mobile_text", "")) != "" else str(e["text"])
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.add_theme_font_override("font", UIKit.sans())
		if host._mobile:
			d.add_theme_font_size_override("font_size", host._fs(13))
		vb.add_child(d)
		var council: Dictionary = {}
		if e.get("kind", "") != "parliament_bill":
			council = _add_council(vb, pi)
		if crisis and not (host._mobile and str(e.get("mobile_text", "")) != ""):
			var hush := Label.new()
			hush.text = tr("Meclis susuyor. Bu kararı yalnız vereceksin.")
			hush.add_theme_font_override("font", UIKit.serif_italic())
			hush.add_theme_font_size_override("font_size", host._fs(15))
			hush.add_theme_color_override("font_color", UIKit.TEXT_DIM)
			vb.add_child(hush)
		for ci in e["choices"].size():
			var b := Button.new()
			var marker: String = ["I", "II", "III", "IV"][ci] if e["choices"].size() <= 4 else "•"
			b.text = "  %s   %s" % [marker, str(e["choices"][ci]["label"])]
			b.add_theme_font_override("font", UIKit.sans(500))
			var no_action_cost: bool = e.get("kind", "") == "parliament_bill"
			b.disabled = (Sim.mesai < 1 and not no_action_cost) or not e["choices"][ci].get("available", true) or (e.get("kind", "") == "patronage" and ci == 2 and Sim.private_wealth < 6.0)
			b.tooltip_text = tr("Oylama mesai harcamaz; zorla geçirmek bedel ve iz bırakır.") if no_action_cost else (tr("Bu seçenek için gerekli kişi ya da servet yok.") if b.disabled and Sim.mesai >= 1 else (tr("Bu karar 1 mesai harcar.") if Sim.mesai >= 1 else tr("Bu hafta mesain kalmadı. Haftayı bitir; karar bir hafta daha bekleyebilir.")))
			if str(e["choices"][ci].get("preview", "")) != "":
				b.tooltip_text += "\n\n" + tr(str(e["choices"][ci]["preview"]))
			if council.has(ci):
				b.tooltip_text += "\n\n" + "\n".join(council[ci])
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.theme_type_variation = "ChoiceButton"
			if host._mobile:
				b.custom_minimum_size.y = 44
				b.add_theme_font_size_override("font_size", host._fs(13))
			host._wire(b)
			if e["choices"][ci].get("fx", {}).get("budget_custom", false):
				b.pressed.connect(host._open_budget_editor.bind(pi, ci))
			else:
				b.pressed.connect(host._choose.bind(pi, ci))
			vb.add_child(b)
			host._decision_buttons.append(b)
	if Sim.pending.size() > 1:
		for pi in Sim.pending.size():
			if pi == decision_index:
				continue
			var remaining := maxi(1, 2 - int(Sim.pending[pi]["age"]))
			var next := Button.new()
			next.text = "%s: %s  ·  %s" % [tr("Sırada"), str(Sim.pending[pi]["event"]["title"]), Loc.ntr("%d hafta kaldı", remaining) % remaining]
			next.add_theme_font_override("font", UIKit.sans())
			next.alignment = HORIZONTAL_ALIGNMENT_LEFT
			next.theme_type_variation = "GhostButton"
			next.custom_minimum_size.y = 44 if host._mobile else 32
			next.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			next.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			var queue_style := UIKit.box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 4, 8)
			var queue_hover := UIKit.box(UIKit.HOVER, Color(UIKit.GOLD_DIM, 0.65), 4, 8)
			next.add_theme_stylebox_override("normal", queue_style)
			next.add_theme_stylebox_override("hover", queue_hover)
			next.add_theme_stylebox_override("pressed", queue_hover)
			next.draw.connect(func() -> void:
				var mid := Vector2(next.size.x - 13, next.size.y / 2.0)
				next.draw_colored_polygon(PackedVector2Array([mid + Vector2(-3, -5), mid + Vector2(3, 0), mid + Vector2(-3, 5)]), UIKit.GOLD))
			host._wire(next)
			next.pressed.connect(show_decision.bind(pi))
			host._agenda.add_child(next)
	if host._report_box == null:
		_add_changes(animated)
	var texts: Array[RichTextLabel] = []
	if host._report_box != null:
		_fill_reports_compact(animated, texts)
	else:
		host._agenda.add_child(host._section(tr("BU HAFTANIN RAPORLARI"), tr("masana ulaşan: %d") % Sim.reports.size()))
		var rgrid := GridContainer.new()
		rgrid.columns = 1
		rgrid.add_theme_constant_override("v_separation", 8)
		host._agenda.add_child(rgrid)
		for r: Dictionary in Sim.reports:
			var panel := PanelContainer.new()
			panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			panel.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL_HI, 0.55), Color(UIKit.GOLD_DIM, 0.18), 6, 8))
			rgrid.add_child(panel)
			animated.append(panel)
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			panel.add_child(row)
			row.add_child(host._initial_art(str(r["source"]), Vector2(46, 46), 22))
			row.add_child(_trend_mark(r))
			panel.tooltip_text = "%s · %s%s" % [r["name"], r["title"], _trend_tip(r)]
			var l := RichTextLabel.new()
			l.bbcode_enabled = true
			l.fit_content = true
			l.scroll_active = false
			l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			l.text = "[b]%s[/b]  [color=gray]%s[/color]\n%s" % [r["name"], r["title"], r["text"]]
			row.add_child(l)
			texts.append(l)
	_restore_scroll.call_deferred(keep_scroll)
	if host._reveal and not host._fast():
		host._reveal = false
		_play_reveal.call_deferred(animated, texts)
	else:
		host._reveal = false


func show_decision(index: int) -> void:
	if Sim.pending.is_empty():
		return
	decision_index = clampi(index, 0, Sim.pending.size() - 1)
	host._scroll.scroll_vertical = 0
	_rebuild_agenda()


func _nav_button(step: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(44 if host._mobile else 36, 44 if host._mobile else 36)
	button.theme_type_variation = "GhostButton"
	button.tooltip_text = tr("Önceki karar") if step < 0 else tr("Sonraki karar")
	button.disabled = decision_index == 0 if step < 0 else decision_index == Sim.pending.size() - 1
	host._wire(button)
	button.draw.connect(func() -> void:
		var mid := button.size / 2.0
		var tip := -5.0 if step < 0 else 5.0
		button.draw_colored_polygon(PackedVector2Array([mid + Vector2(tip, 0), mid + Vector2(-tip, -6), mid + Vector2(-tip, 6)]), UIKit.GOLD if not button.disabled else UIKit.GOLD_DIM))
	button.pressed.connect(func() -> void: show_decision(decision_index + step))
	return button


## Raporun geçen haftaya göre yönü: söylenen bandın farkı (gerçek değil). -1 iyimserleşti, +1 karamsarlaştı, 0 aynı/yok.
func _trend(r: Dictionary) -> int:
	var src := str(r["source"])
	if not Sim.report_prev.has(src):
		return 0
	return signi(int(r["band"]) - int(Sim.report_prev[src]))


func _trend_tip(r: Dictionary) -> String:
	match _trend(r):
		1:
			return "\n" + tr("Geçen haftaya göre daha karamsar konuşuyor.")
		-1:
			return "\n" + tr("Geçen haftaya göre daha iyimser konuşuyor.")
	return ""


## Küçük çizilmiş ok: yukarı yeşil (daha iyimser), aşağı kırmızı (daha karamsar); değişim yoksa boş yer tutucu.
func _trend_mark(r: Dictionary) -> Control:
	var t := _trend(r)
	var c := Control.new()
	c.custom_minimum_size = Vector2(10, 10)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if t != 0:
		c.draw.connect(_draw_trend.bind(c, t))
	return c


func _draw_trend(c: Control, t: int) -> void:
	var m := c.size / 2.0
	var pts := PackedVector2Array([m + Vector2(-5, 3), m + Vector2(5, 3), m + Vector2(0, -4)])
	if t > 0:
		pts = PackedVector2Array([m + Vector2(-5, -3), m + Vector2(5, -3), m + Vector2(0, 4)])
	c.draw_colored_polygon(pts, UIKit.OK if t < 0 else UIKit.DANGER)


## Gündem: geçen haftadan bu yana görünür göstergelerde ne değişti (Sim.week_changes). Boşsa bölüm yok.
func _add_changes(animated: Array[Control], target_override: VBoxContainer = null) -> void:
	var target: VBoxContainer = target_override if target_override != null else (host._report_box if host._report_box != null else host._agenda)
	var compact: bool = target_override != null and not host._mobile
	if Sim.week_changes.is_empty() and not host._mobile:
		return   # boş başlık yer kaplamasın
	target.add_child(host._section(tr("BU HAFTA DEĞİŞENLER"), tr("önce değişenler")))
	if Sim.week_changes.is_empty():
		return
	for ch: Dictionary in Sim.week_changes:
		var row := PanelContainer.new()
		var sb := UIKit.box(Color(UIKit.PANEL_HI, 0.35), Color(0, 0, 0, 0), 2, 8)
		sb.content_margin_top = 1 if compact else 2
		sb.content_margin_bottom = 1 if compact else 2
		sb.border_color = [UIKit.DANGER, UIKit.AMBER, UIKit.OK][int(ch["tone"]) + 1]
		sb.border_width_left = 3
		row.add_theme_stylebox_override("panel", sb)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		target.add_child(row)
		animated.append(row)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 8)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(h)
		var who := str(ch.get("actor", ""))
		if who != "" and Sim.actors.has(who):
			var por: Control = host._initial_art(who, Vector2(22, 22), 11)
			por.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			h.add_child(por)
		var l := Label.new()
		l.text = str(ch["text"])
		l.autowrap_mode = TextServer.AUTOWRAP_OFF if compact else TextServer.AUTOWRAP_WORD_SMART
		if compact:
			l.clip_text = true
			l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			l.tooltip_text = l.text
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.add_theme_font_override("font", UIKit.sans())
		l.add_theme_font_size_override("font_size", host._fs(15 if host._mobile else (12 if compact else 14)))
		h.add_child(l)


## Masaüstü: karar kartlarının altında haftanın defteri. Eylem sonuçları bildirimde kaybolur, ipucu satırı
## yalnızca sonuncuyu tutar; burada hafta boyunca durur. Boşken sıradaki adımı söyler. Yeni bilgi açmaz.
func _add_week_ledger(animated: Array[Control], target_override: VBoxContainer = null) -> void:
	var target: VBoxContainer = target_override if target_override != null else (host._report_box if host._report_box != null else host._agenda)
	if host._week_log_week != Sim.week:
		host._week_log.clear()
		host._week_log_week = Sim.week
	target.add_child(host._section(tr("BU HAFTA"), tr("yaptıkların ve sonuçları")))
	var assembly := Label.new()
	assembly.text = Sim.parliament_report_line()
	assembly.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	assembly.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	assembly.add_theme_font_override("font", UIKit.sans())
	assembly.add_theme_font_size_override("font_size", host._fs(15 if host._mobile else 13))
	assembly.add_theme_color_override("font_color", UIKit.TEXT if not host._mobile else UIKit.TEXT_DIM)
	if not host._mobile:
		assembly.add_theme_constant_override("line_spacing", 1)
	target.add_child(assembly)
	if host._week_log.is_empty():
		var empty := Label.new()
		empty.text = (tr("Henüz bir şey yapmadın. Bir güç merkezine tıkla, Eylemler panelinden mesai harca.") if Sim.mesai > 0
			else tr("Mesain bitti. Raporlara göz at ve haftayı bitir."))
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_color_override("font_color", UIKit.TEXT_DIM)
		empty.add_theme_font_override("font", UIKit.sans())
		empty.add_theme_font_size_override("font_size", host._fs(15 if host._mobile else 13))
		if not host._mobile:
			empty.add_theme_color_override("font_color", UIKit.TEXT)
			empty.add_theme_constant_override("line_spacing", 1)
		target.add_child(empty)
		return
	for i in host._week_log.size():
		var row := PanelContainer.new()
		var sb := UIKit.box(Color(UIKit.PANEL_HI, 0.35), Color(0, 0, 0, 0), 2, 8)
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		sb.border_color = Color(UIKit.GOLD_DIM, 0.7)
		sb.border_width_left = 2
		row.add_theme_stylebox_override("panel", sb)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		target.add_child(row)
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		l.scroll_active = false
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.add_theme_font_size_override("normal_font_size", host._fs(12))
		l.add_theme_font_size_override("bold_font_size", host._fs(12))
		l.add_theme_font_override("normal_font", UIKit.sans())
		l.add_theme_font_override("bold_font", UIKit.sans(680))
		l.text = "[color=#d6b25e]%d[/color]   %s" % [i + 1, host._week_log[i]]
		row.add_child(l)
	# Yalnızca en son satır canlanır (her eylemde bütün liste yeniden belirmesin).
	animated.append(target.get_child(target.get_child_count() - 1))


## Masaüstü: raporlar sağ sütunda, kaynağının altında kompakt bir liste. Satıra tıklamak o kişiyi seçer.
## Sol kenar rengi raporun SÖYLEDİĞİ durumu gösterir (gerçeği değil): iyi / tedirgin / kötü.
func _fill_reports_compact(animated: Array[Control], texts: Array[RichTextLabel]) -> void:
	for c in host._report_box.get_children():
		c.queue_free()
	var week_frame := PanelContainer.new()
	week_frame.name = "BuHaftaPaneli"
	week_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	week_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	week_frame.size_flags_stretch_ratio = 0.7
	var week_style := UIKit.box(Color(UIKit.PANEL, 0.7), Color(UIKit.GOLD_DIM, 0.25), 8, 12)
	week_style.set_border_width_all(0)
	week_style.content_margin_top = 6
	week_style.content_margin_bottom = 4
	week_style.content_margin_left = 16
	week_style.content_margin_right = 16
	week_frame.add_theme_stylebox_override("panel", week_style)
	UIKit.ornament(week_frame, Color(UIKit.GOLD, 0.8), 18, 1)
	host._report_box.add_child(week_frame)
	var week_contents := VBoxContainer.new()
	week_contents.size_flags_vertical = Control.SIZE_EXPAND_FILL
	week_contents.add_theme_constant_override("separation", 4)
	week_frame.add_child(week_contents)
	_add_changes(animated, week_contents)
	_add_week_ledger(animated, week_contents)
	if not host._mobile:
		var banner_path := "res://art/ui/bu_hafta_banner.png"
		var banner := TextureRect.new()
		banner.name = "WeekBanner"
		banner.custom_minimum_size.y = 100 if host.get_viewport_rect().size.y < 780 else 140
		banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		banner.size_flags_vertical = Control.SIZE_EXPAND_FILL
		banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if ResourceLoader.exists(banner_path):
			banner.texture = load(banner_path)
		else:
			var gradient := Gradient.new()
			gradient.colors = PackedColorArray([Color("332514"), Color("100d0a")])
			var texture := GradientTexture2D.new()
			texture.gradient = gradient
			banner.texture = texture
		week_contents.add_child(banner)

	var report_frame := PanelContainer.new()
	report_frame.name = "RaporlarPaneli"
	report_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	report_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	report_frame.size_flags_stretch_ratio = 1.3
	var report_style := UIKit.box(Color(UIKit.PANEL, 0.7), Color(UIKit.GOLD_DIM, 0.25), 8, 12)
	report_style.set_border_width_all(0)
	report_style.content_margin_top = 4
	report_style.content_margin_bottom = 2
	report_style.content_margin_left = 16
	report_style.content_margin_right = 16
	report_frame.add_theme_stylebox_override("panel", report_style)
	UIKit.ornament(report_frame, Color(UIKit.GOLD, 0.8), 18, 1)
	host._report_box.add_child(report_frame)
	var contents := VBoxContainer.new()
	contents.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contents.add_theme_constant_override("separation", 2)
	report_frame.add_child(contents)
	var reports_heading: Control = host._section(tr("Raporlar"))
	var reports_label := reports_heading.get_child(1) as Label
	reports_label.add_theme_font_override("font", UIKit.serif())
	reports_label.add_theme_font_size_override("font_size", host._fs(16))
	contents.add_child(reports_heading)
	var report_rows := VBoxContainer.new()
	report_rows.name = "ReportRows"
	report_rows.add_theme_constant_override("separation", 1)
	contents.add_child(report_rows)
	var full_reports := PopupPanel.new()
	host.add_child(full_reports)
	var popup_scroll := ScrollContainer.new()
	popup_scroll.custom_minimum_size = Vector2(900, 420) if host._mobile else Vector2(900, 680)
	full_reports.add_child(popup_scroll)
	var popup_list := VBoxContainer.new()
	popup_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	popup_scroll.add_child(popup_list)
	var all_reports := Button.new()
	all_reports.name = "AllReportsButton"
	all_reports.text = tr("Tüm raporlar (%d)") % Sim.reports.size()
	all_reports.theme_type_variation = "GhostButton"
	all_reports.custom_minimum_size.y = 44 if host._mobile else 0
	all_reports.pressed.connect(func() -> void: host._all_reports_popup.popup_centered(Vector2i(1000, 500) if host._mobile else Vector2i(920, 700)))
	host._wire(all_reports)
	if is_instance_valid(host._all_reports_popup):
		host._all_reports_popup.free()
	host._all_reports_popup = full_reports
	for i in Sim.reports.size():
		var r: Dictionary = Sim.reports[i]
		var entry := Button.new()
		entry.text = "%s · %s\n%s" % [r["name"], r["title"], r["text"]]
		entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		entry.custom_minimum_size.y = 56
		popup_list.add_child(entry)
		var source := str(r["source"])
		entry.pressed.connect(func() -> void:
			if Sim.actors.has(source): host._open_person_file(source)
			host._all_reports_popup.hide())
		host._wire(entry)
	var visible_count := 4 if host.get_viewport_rect().size.y >= 780 else 2
	for report_index in mini(visible_count, Sim.reports.size()):
		var r: Dictionary = Sim.reports[report_index]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var band := clampi(int(r.get("band", 1)), 0, 2)
		# Renk yalnızca sol çizgide: raporun söylediği durum. Kutu kenarı yok, liste sakin kalır.
		var sb := UIKit.box(Color(UIKit.PANEL_HI, 0.42), Color(0, 0, 0, 0), 2, 6)
		sb.content_margin_top = 1
		sb.content_margin_bottom = 1
		if not host._mobile:
			sb.bg_color = Color(0, 0, 0, 0.32)
		sb.border_width_left = 3
		sb.border_color = [Color(UIKit.OK, 0.8), Color(UIKit.AMBER, 0.8), Color(UIKit.DANGER, 0.9)][band]
		panel.add_theme_stylebox_override("panel", sb)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.tooltip_text = tr("%s · %s\nTıkla: kişiyi seç. Kenar rengi raporun söylediğidir, gerçek olmayabilir.%s") % [r["name"], r["title"], _trend_tip(r)]
		var sid := str(r["source"])
		panel.set_meta("report_id", sid)
		panel.gui_input.connect(func(ev: InputEvent) -> void:
			var mb := ev as InputEventMouseButton
			if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and Sim.actors.has(sid):
				Sfx.play("click", -4.0)
				host._open_person_file(sid)
				host._all_reports_popup.hide())
		report_rows.add_child(panel)
		animated.append(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(row)
		var por: Control = host._initial_art(sid, Vector2(40, 40) if host._mobile else Vector2(44, 44), 24)
		por.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(por)
		if not host._mobile:
			# Mockup: ad ayrı, kalın bir sütunda; metin hizalı akar.
			var name_col := Label.new()
			name_col.text = _short_name(str(r["name"]))
			name_col.custom_minimum_size.x = 52
			name_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			name_col.add_theme_font_override("font", UIKit.sans(680))
			name_col.add_theme_font_size_override("font_size", host._fs(13))
			name_col.add_theme_color_override("font_color", UIKit.TEXT)
			name_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(name_col)
		row.add_child(_trend_mark(r))
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		l.scroll_active = false
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.add_theme_font_override("normal_font", UIKit.sans())
		l.add_theme_font_override("bold_font", UIKit.sans(680))
		l.add_theme_font_size_override("normal_font_size", host._fs(15 if host._mobile else 13))
		l.add_theme_font_size_override("bold_font_size", host._fs(15 if host._mobile else 13))
		l.add_theme_color_override("default_color", UIKit.TEXT)
		l.text = ("[b]%s[/b]  %s" % [_short_name(str(r["name"])), r["text"]]) if host._mobile else str(r["text"])
		if not host._mobile:
			l.add_theme_constant_override("line_separation", 2)
		row.add_child(l)
		texts.append(l)
	all_reports.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contents.add_child(all_reports)
	if host._person_panel != null:
		host._person_panel.call_deferred("_sync_operation_bar")


## Meclisin görüşü: iki danışmanın kısa önerisi (docs/design/danisman_gorusleri.md).
## Döndürür: seçenek -> düğme ipucuna eklenecek satırlar ("Veyra: öneriyor").
func _add_council(parent: VBoxContainer, pending_index: int) -> Dictionary:
	var notes := {}
	var items: Array = []
	for it: Dictionary in Sim.advice_for(pending_index):
		if Sim.actors.has(it["actor"]) and not Sim.actors[it["actor"]].moved:
			items.append(it)
	if items.is_empty():
		return notes
	var panel := PanelContainer.new()
	var sb := UIKit.box(Color(UIKit.PANEL, 0.75), Color(0, 0, 0, 0), 4, 8)
	sb.set_border_width_all(0)
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(panel)
	var shell := VBoxContainer.new()
	shell.add_theme_constant_override("separation", 4)
	panel.add_child(shell)
	var summary := HBoxContainer.new()
	summary.add_theme_constant_override("separation", 5)
	shell.add_child(summary)
	for it: Dictionary in items:
		var actor = Sim.actors[it["actor"]]
		var portrait: Control = host._initial_art(actor.id, Vector2(22, 22), 11)
		portrait.tooltip_text = "%s · %s" % [actor.display_name, actor.title]
		summary.add_child(portrait)
		var brief := tr("Kaçamak") if it["kind"] == "evasive" else tr("Kararsız")
		if int(it["rec"]) >= 0:
			brief = tr("%s'yi öneririm") % ["I", "II", "III", "IV"][mini(int(it["rec"]), 3)]
		elif int(it["warn"]) >= 0:
			brief = tr("%s'ye karşı") % ["I", "II", "III", "IV"][mini(int(it["warn"]), 3)]
		if it["stake"]:
			brief += tr(" (çıkarı var)")
		var short := Label.new()
		short.text = brief
		short.tooltip_text = "%s: %s" % [actor.display_name, it["text"]]
		short.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		short.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		short.add_theme_font_override("font", UIKit.sans())
		short.add_theme_font_size_override("font_size", host._fs(12))
		summary.add_child(short)
	var why := Button.new()
	why.text = tr("Gerekçeler")
	why.theme_type_variation = "GhostButton"
	why.toggle_mode = true
	why.custom_minimum_size = Vector2(104, 44 if host._mobile else 32)
	host._wire(why)
	summary.add_child(why)
	reasons_button = why
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	col.visible = false
	shell.add_child(col)
	var arrow := Control.new()
	arrow.position = Vector2(why.custom_minimum_size.x - 18, 16)
	arrow.custom_minimum_size = Vector2(12, 12)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	why.add_child(arrow)
	arrow.draw.connect(func() -> void:
		var pts := PackedVector2Array([Vector2(1, 3), Vector2(11, 3), Vector2(6, 9)]) if not why.button_pressed else PackedVector2Array([Vector2(1, 9), Vector2(11, 9), Vector2(6, 3)])
		arrow.draw_colored_polygon(pts, UIKit.GOLD))
	why.toggled.connect(func(on: bool) -> void:
		col.visible = on
		arrow.queue_redraw())
	var head: Control = host._section(tr("MECLİSİN GÖRÜŞÜ"))
	head.tooltip_text = tr("Danışmanların kararlara dair görüşü. Gerekçeleri doğrudur ama seçicidir:\nherkes işine gelen tarafı anlatır. Kime güveneceğin senin kararın.")
	col.add_child(head)
	for it: Dictionary in items:
		var a = Sim.actors[it["actor"]]
		var nm: String = Sim.short_name(a)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		row.tooltip_text = "%s · %s" % [a.display_name, a.title]
		if it["stake"]:
			row.tooltip_text += "\n" + tr("Seçeneklerden en az biri onu doğrudan etkiliyor. Önerisi tarafsız olmayabilir.")
		if Sim.suspicion_level(a.id) >= 2:
			row.tooltip_text += "\n" + tr("Son zamanlarda hakkında alametler var.")
		match str(it["kind"]):
			"evasive":
				row.tooltip_text += "\n" + tr("Kaçamak konuşuyor. Korkan bir meclis kralına gerçeği söylemez.")
			"flat":
				row.tooltip_text += "\n" + tr("Seçenekler arasında belirgin bir fark görmüyor.")
		var por: Control = host._initial_art(a.id, Vector2(30, 30), 15)
		por.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		var por_edge := Panel.new()
		var pes := StyleBoxFlat.new()
		pes.draw_center = false
		pes.border_color = Color(UIKit.GOLD, 0.6)
		pes.set_border_width_all(1)
		por_edge.add_theme_stylebox_override("panel", pes)
		por_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		por_edge.set_anchors_preset(Control.PRESET_FULL_RECT)
		por.add_child(por_edge)
		row.add_child(por)
		var txt := VBoxContainer.new()
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		txt.add_theme_constant_override("separation", 1)
		txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(txt)
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		txt.add_child(top)
		var nl := Label.new()
		nl.text = UIKit.tr_upper(nm)
		nl.add_theme_font_override("font", UIKit.caps())
		nl.add_theme_font_size_override("font_size", host._fs(12))
		nl.add_theme_color_override("font_color", UIKit.GOLD)
		nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top.add_child(nl)
		if it["stake"]:
			var pill := _pill(tr("ÇIKARI VAR"), UIKit.AMBER)
			pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			top.add_child(pill)
		var q := Label.new()
		q.text = "“%s”" % it["text"]
		q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		q.add_theme_font_override("font", UIKit.serif_italic())
		q.add_theme_font_size_override("font_size", host._fs(15))
		q.add_theme_color_override("font_color", UIKit.TEXT if it["kind"] == "rec" else UIKit.TEXT_DIM)
		q.mouse_filter = Control.MOUSE_FILTER_IGNORE
		txt.add_child(q)
		col.add_child(row)
		if int(it["rec"]) >= 0:
			notes[int(it["rec"])] = notes.get(int(it["rec"]), []) + [tr("%s: öneriyor") % nm]
		if int(it["warn"]) >= 0:
			notes[int(it["warn"])] = notes.get(int(it["warn"]), []) + [tr("%s: karşı") % nm]
	return notes


func _restore_scroll(v: int) -> void:
	host._scroll.scroll_vertical = v


func _play_reveal(animated: Array[Control], texts: Array[RichTextLabel]) -> void:
	var i := 0
	for c in animated:
		if is_instance_valid(c):
			UIKit.pop_in(c, 0.3, 0.07 * i)
		i += 1
	i = 0
	for l in texts:
		if is_instance_valid(l):
			l.visible_ratio = 0.0
			UIKit.typewrite(l, 0.55, 0.25 + 0.07 * i)
		i += 1
	if not animated.is_empty():
		Sfx.play("paper", -6.0)


func _short_name(full: String) -> String:
	for a in Sim.actors.values():
		if a.display_name == full and a.short != "":
			return a.short
	return full.split(" ")[-1]
