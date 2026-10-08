extends RefCounted

const UIKit := preload("res://game/ui/ui_kit.gd")

var host: Control

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
	panel.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL, 0.92), Color(UIKit.GOLD, 0.45), 8, 10))
	host._agenda.add_child(panel)
	animated.append(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	panel.add_child(v)
	var head := Label.new()
	head.text = tr("BU HAFTA NE YAPMALI?")
	head.add_theme_font_override("font", UIKit.caps())
	head.add_theme_font_size_override("font_size", host._fs(12))
	head.add_theme_color_override("font_color", UIKit.GOLD)
	v.add_child(head)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	v.add_child(row)
	for i in GUIDE_STEPS.size():
		var b := Button.new()
		b.text = tr("%d   %s") % [i + 1, tr(GUIDE_STEPS[i][0])]
		b.theme_type_variation = "GhostButton"
		b.toggle_mode = true
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", host._fs(13))
		b.tooltip_text = tr(GUIDE_STEPS[i][1])
		var col := UIKit.GOLD if i + 1 == step else (UIKit.OK if i + 1 < step else UIKit.TEXT_DIM)
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
			b.add_theme_color_override(c, col)
		b.set_pressed_no_signal(i + 1 == step)
		b.pressed.connect(_guide_go.bind(i + 1))
		host._wire(b)
		row.add_child(b)
	var tip := Label.new()
	tip.text = tr(GUIDE_STEPS[step - 1][1])
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.add_theme_font_size_override("font_size", host._fs(13))
	tip.add_theme_color_override("font_color", Color("d8cba8"))
	v.add_child(tip)


## Yol göstericideki adıma tıklayınca ilgili yere götürür.
func _guide_go(step: int) -> void:
	match step:
		1:
			host._on_flow("gundem")
		2:
			host._open_media()
		3:
			var saray := host._tabs.get_node_or_null("Saray") as Control
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
	var sb := UIKit.box(Color(col, 0.18), col, 10, 8)
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	p.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", host._fs(11))
	l.add_theme_color_override("font_color", col.lightened(0.25))
	p.add_child(l)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p


func _rebuild_facts() -> void:
	for c in host._fact_box.get_children():
		c.queue_free()
	host._fact_ids.clear()
	if Sim.facts.is_empty():
		var empty := Label.new()
		empty.text = tr("Henüz dosyada bir şey yok. Gizli işler iz bırakır; izler burada birikir.")
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
		card.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL_HI, 0.55), Color(UIKit.DANGER if mine else UIKit.GOLD_DIM, 0.35), 6, 10))
		host._fact_box.add_child(card)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		card.add_child(v)
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		v.add_child(top)
		var t := Label.new()
		t.text = str(f["text"])
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
				b.add_theme_font_size_override("font_size", host._fs(13))
				b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				b.disabled = Sim.mesai < 1
				if kind[0] == "leak" and mine:
					b.theme_type_variation = "DangerButton"
				b.tooltip_text = host._action_tip(kind[0])
				host._wire(b)
				b.pressed.connect(host._fact_act.bind(kind[0], fid))
				br.add_child(b)


func _rebuild_agenda() -> void:
	var keep_scroll: int = host._scroll.scroll_vertical
	for c in host._agenda.get_children():
		c.queue_free()
	host._decision_buttons.clear()
	host._decision_cards.clear()
	var animated: Array[Control] = []
	if Sfx.tips and Sim.week <= 3:
		_add_guide(animated)
	if Sfx.tips and ADVICE.has(Sim.week) and not (host._mobile and Sim.week <= 3):
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
		nh.add_theme_constant_override("separation", 8)
		nh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		note.add_child(nh)
		var ic_tex: Texture2D = host._art("res://art/icons/rapor.png")
		if ic_tex:
			var ic := TextureRect.new()
			ic.texture = ic_tex
			ic.custom_minimum_size = Vector2(20, 20)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			nh.add_child(ic)
		var nl := Label.new()
		nl.text = tr(ADVICE[Sim.week])
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nl.add_theme_font_size_override("font_size", host._fs(13))
		nl.add_theme_color_override("font_color", Color("d8cba8"))
		nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nh.add_child(nl)
	if not Sim.pending.is_empty():
		# Yardımcı metin yalnızca ilk haftalarda; sonra tekrar etmesin.
		host._agenda.add_child(host._section(tr("KARAR BEKLEYENLER"), tr("her karar 1 mesai · ertelenen karar 2 hafta sonra kendiliğinden çözülür") if Sim.week <= 4 else ""))
	for pi in Sim.pending.size():
		var p: Dictionary = Sim.pending[pi]
		var e: Dictionary = p["event"]
		var card := PanelContainer.new()
		# Göz önce ilk karta ve süresi dolanlara gitsin; diğerleri sakin çerçeveli.
		var crisis: bool = e.get("crisis", false)
		var lead: bool = pi == 0 or int(p["age"]) > 0 or crisis
		var card_box := UIKit.box(Color(UIKit.PANEL, 0.96), UIKit.DANGER if crisis else (UIKit.GOLD if lead else Color(UIKit.GOLD_DIM, 0.45)), 8, 12, 2 if lead else 1)
		card_box.shadow_color = Color(0, 0, 0, 0.45)
		card_box.shadow_size = 8 if lead else 3
		card.add_theme_stylebox_override("panel", card_box)
		host._agenda.add_child(card)
		if lead:
			UIKit.ornament(card, UIKit.DANGER if crisis else UIKit.GOLD, 18, 5)
		host._decision_cards.append(card)
		animated.append(card)
		if (p["age"] > 0 or crisis) and not host._fast():
			# Süresi dolmak üzere: çerçeve altınla kırmızı arasında nabız gibi atar.
			var pulse := card.create_tween().set_loops()
			pulse.tween_property(card_box, "border_color", UIKit.DANGER, 0.9).set_trans(Tween.TRANS_SINE)
			pulse.tween_property(card_box, "border_color", Color("ff8a7a") if crisis else UIKit.GOLD, 0.9).set_trans(Tween.TRANS_SINE)
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 14)
		card.add_child(hb)
		var tex: Texture2D = host._event_art(str(e.get("art", e["id"])))
		if tex:
			# Görsel kendi çerçevesinde yavaşça hareket eder (yaşayan kart).
			var frame := Control.new()
			frame.custom_minimum_size = Vector2(240, 135)
			frame.clip_contents = true
			hb.add_child(frame)
			var img := TextureRect.new()
			img.texture = tex
			img.set_anchors_preset(Control.PRESET_FULL_RECT)
			img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			frame.add_child(img)
			if not host._fast():
				img.pivot_offset = Vector2(120, 67)
				var drift := img.create_tween().set_loops()
				drift.tween_property(img, "scale", Vector2(1.08, 1.08), 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				drift.tween_property(img, "scale", Vector2.ONE, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.add_theme_constant_override("separation", 6)
		hb.add_child(vb)
		var t := Label.new()
		t.text = str(e["title"])
		t.add_theme_font_override("font", UIKit.serif())
		t.add_theme_font_size_override("font_size", host._fs(22))
		t.add_theme_color_override("font_color", UIKit.GOLD)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(t)
		if p["age"] > 0 or crisis:
			var late := Label.new()
			late.text = str(e.get("banner", tr("Bu hafta karar vermezsen saray düşer."))) if crisis else tr("Karar bekliyor — bu hafta çözülmezse kendi kendine çözülecek.")
			late.add_theme_color_override("font_color", UIKit.DANGER)
			late.add_theme_font_size_override("font_size", host._fs(13))
			vb.add_child(late)
		var d := Label.new()
		d.text = str(e["text"])
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(d)
		var council := _add_council(vb, pi)
		if crisis:
			var hush := Label.new()
			hush.text = tr("Meclis susuyor. Bu kararı yalnız vereceksin.")
			hush.add_theme_font_override("font", UIKit.serif_italic())
			hush.add_theme_font_size_override("font_size", host._fs(15))
			hush.add_theme_color_override("font_color", UIKit.TEXT_DIM)
			vb.add_child(hush)
		for ci in e["choices"].size():
			var b := Button.new()
			b.text = "  %s   %s" % [["I", "II", "III", "IV"][mini(ci, 3)], str(e["choices"][ci]["label"])]
			b.disabled = Sim.mesai < 1 or not e["choices"][ci].get("available", true) or (e.get("kind", "") == "patronage" and ci == 2 and Sim.private_wealth < 6.0)
			b.tooltip_text = tr("Bu seçenek için gerekli kişi ya da servet yok.") if b.disabled and Sim.mesai >= 1 else (tr("Bu karar 1 mesai harcar.") if Sim.mesai >= 1 else tr("Bu hafta mesain kalmadı. Haftayı bitir; karar bir hafta daha bekleyebilir."))
			if council.has(ci):
				b.tooltip_text += "\n\n" + "\n".join(council[ci])
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.theme_type_variation = "ChoiceButton"
			host._wire(b)
			b.pressed.connect(host._choose.bind(pi, ci))
			vb.add_child(b)
			host._decision_buttons.append(b)
	_add_changes(animated)
	if host._report_box != null:
		_add_week_ledger(animated)
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
func _add_changes(animated: Array[Control]) -> void:
	if Sim.week_changes.is_empty():
		return
	host._agenda.add_child(host._section(tr("GEÇEN HAFTADAN BERİ"), tr("görebildiklerinde ne değişti")))
	for ch: Dictionary in Sim.week_changes:
		var row := PanelContainer.new()
		var sb := UIKit.box(Color(UIKit.PANEL_HI, 0.35), Color(0, 0, 0, 0), 2, 8)
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		sb.border_color = [UIKit.DANGER, UIKit.AMBER, UIKit.OK][int(ch["tone"]) + 1]
		sb.border_width_left = 3
		row.add_theme_stylebox_override("panel", sb)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host._agenda.add_child(row)
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
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.add_theme_font_size_override("font_size", host._fs(13))
		h.add_child(l)


## Masaüstü: karar kartlarının altında haftanın defteri. Eylem sonuçları bildirimde kaybolur, ipucu satırı
## yalnızca sonuncuyu tutar; burada hafta boyunca durur. Boşken sıradaki adımı söyler. Yeni bilgi açmaz.
func _add_week_ledger(animated: Array[Control]) -> void:
	if host._week_log_week != Sim.week:
		host._week_log.clear()
		host._week_log_week = Sim.week
	host._agenda.add_child(host._section(tr("BU HAFTA"), tr("yaptıkların ve sonuçları")))
	if host._week_log.is_empty():
		var empty := Label.new()
		empty.text = (tr("Henüz bir şey yapmadın. Bir güç merkezine tıkla, Eylemler panelinden mesai harca.") if Sim.mesai > 0
			else tr("Mesain bitti. Raporlara göz at ve haftayı bitir."))
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_color_override("font_color", UIKit.TEXT_DIM)
		empty.add_theme_font_size_override("font_size", host._fs(13))
		host._agenda.add_child(empty)
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
		host._agenda.add_child(row)
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		l.scroll_active = false
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.add_theme_font_size_override("normal_font_size", host._fs(13))
		l.add_theme_font_size_override("bold_font_size", host._fs(13))
		l.text = "[color=#d6b25e]%d[/color]   %s" % [i + 1, host._week_log[i]]
		row.add_child(l)
	# Yalnızca en son satır canlanır (her eylemde bütün liste yeniden belirmesin).
	animated.append(host._agenda.get_child(host._agenda.get_child_count() - 1))


## Masaüstü: raporlar sağ sütunda, kaynağının altında kompakt bir liste. Satıra tıklamak o kişiyi seçer.
## Sol kenar rengi raporun SÖYLEDİĞİ durumu gösterir (gerçeği değil): iyi / tedirgin / kötü.
func _fill_reports_compact(animated: Array[Control], texts: Array[RichTextLabel]) -> void:
	for c in host._report_box.get_children():
		c.queue_free()
	host._report_box.add_child(host._section(tr("BU HAFTANIN RAPORLARI"), tr("masana ulaşan: %d") % Sim.reports.size()))
	for r: Dictionary in Sim.reports:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var band := clampi(int(r.get("band", 1)), 0, 2)
		# Renk yalnızca sol çizgide: raporun söylediği durum. Kutu kenarı yok, liste sakin kalır.
		var sb := UIKit.box(Color(UIKit.PANEL_HI, 0.42), Color(0, 0, 0, 0), 2, 6)
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
		sb.border_width_left = 3
		sb.border_color = [Color(UIKit.OK, 0.8), Color(UIKit.AMBER, 0.8), Color(UIKit.DANGER, 0.9)][band]
		panel.add_theme_stylebox_override("panel", sb)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.tooltip_text = "%s · %s\nTıkla: kişiyi seç. Kenar rengi raporun söylediğidir, gerçek olmayabilir.%s" % [r["name"], r["title"], _trend_tip(r)]
		var sid := str(r["source"])
		panel.gui_input.connect(func(ev: InputEvent) -> void:
			var mb := ev as InputEventMouseButton
			if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and Sim.actors.has(sid):
				Sfx.play("click", -4.0)
				host._sel.clear()
				host._sel.append(sid)
				host._style_cards()
				host._update_info())
		host._report_box.add_child(panel)
		animated.append(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(row)
		var por: Control = host._initial_art(sid, Vector2(28, 28), 14)
		por.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(por)
		row.add_child(_trend_mark(r))
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		l.scroll_active = false
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.add_theme_font_size_override("normal_font_size", host._fs(13))
		l.add_theme_font_size_override("bold_font_size", host._fs(13))
		l.text = "[b]%s[/b]  %s" % [_short_name(str(r["name"])), r["text"]]
		row.add_child(l)
		texts.append(l)


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
	var sb := UIKit.box(Color(0, 0, 0, 0.22), Color(UIKit.GOLD_DIM, 0.22), 6, 8)
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	var head := Label.new()
	head.text = tr("MECLİSİN GÖRÜŞÜ")
	head.add_theme_font_override("font", UIKit.caps())
	head.add_theme_font_size_override("font_size", host._fs(11))
	head.add_theme_color_override("font_color", UIKit.GOLD_DIM)
	head.mouse_filter = Control.MOUSE_FILTER_PASS
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
