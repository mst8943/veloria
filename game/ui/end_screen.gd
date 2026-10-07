extends Control
## Oyun sonu ekranı (main.gd'den ayrıldı): başlık bandı, sekmeler (Özet, Grafik, Tarihçiler, Hakikat Dosyası,
## Kararlar), Yeniden Oyna / Ana Menü. Kaplamanın kendisi bu düğüm; main.gd onu `_end_overlay` olarak tutar.

const UIKit := preload("res://game/ui/ui_kit.gd")
const TRUTH_CHART := preload("res://game/ui/truth_chart.gd")

var host: Control   # main.gd: _fs, _fast, _art, _wire, _start_new, _show_menu, _mobile
var bg: TextureRect
var head: RichTextLabel
var tabs: TabContainer
var summary: RichTextLabel
var chart   # truth_chart.gd (set_data)
var hist_page: RichTextLabel
var lies_page: RichTextLabel
var log_page: RichTextLabel
var timeline: Array = []
var chart_drawn := false


func _init(main: Control) -> void:
	host = main
	_build()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	bg = TextureRect.new()
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(UIKit.SHADE, 0.82)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var under := ColorRect.new()
	under.color = Color(UIKit.SHADE, 1.0)
	under.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(under)
	move_child(under, 0)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 20 if host._mobile else 50)
	add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	head = RichTextLabel.new()
	head.bbcode_enabled = true
	head.fit_content = true
	head.scroll_active = false
	head.add_theme_font_override("bold_font", UIKit.serif())
	head.add_theme_font_override("normal_font", UIKit.serif())
	var head_band := PanelContainer.new()
	head_band.add_theme_stylebox_override("panel", UIKit.band_style())
	head_band.add_child(head)
	v.add_child(head_band)
	# Sekmeler: Özet / Grafik / Tarihçiler / Hakikat Dosyası / Kararlar
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(tabs)
	summary = _page("Özet")
	summary.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			summary.visible_ratio = 1.0)
	var gbox := VBoxContainer.new()
	gbox.name = "Grafik"
	gbox.add_theme_constant_override("separation", 10)
	tabs.add_child(gbox)
	chart = TRUTH_CHART.new()
	chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chart.custom_minimum_size = Vector2(0, 150 if host._mobile else 200)
	gbox.add_child(chart)
	var gnote := Label.new()
	gnote.text = "Bu çizgileri oyun boyunca hiç görmedin. Gördüğün yalnızca raporlardı; aradaki fark, sana söylenmeyenlerdir."
	gnote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gnote.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	gnote.add_theme_font_size_override("font_size", host._fs(14))
	gbox.add_child(gnote)
	hist_page = _page("Tarihçiler")
	lies_page = _page("Hakikat Dosyası")
	log_page = _page("Kararlar")
	tabs.tab_changed.connect(func(i: int) -> void:
		Sfx.play("paper", -10.0)
		# Grafik ilk açıldığında çizilir (görünmezken boşa oynamasın).
		if tabs.get_tab_control(i) == gbox and not chart_drawn:
			chart_drawn = true
			chart.set_data(timeline, not host._fast()))
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 12)
	v.add_child(brow)
	var again := Button.new()
	again.text = "YENİDEN OYNA"
	again.theme_type_variation = "PrimaryButton"
	again.custom_minimum_size.y = 50
	again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host._wire(again)
	again.pressed.connect(host._start_new)
	brow.add_child(again)
	var to_menu := Button.new()
	to_menu.text = "Ana Menü"
	to_menu.theme_type_variation = "GhostButton"
	to_menu.custom_minimum_size = Vector2(220, 50)
	host._wire(to_menu)
	to_menu.pressed.connect(func() -> void:
		hide()
		host._show_menu())
	brow.add_child(to_menu)
	hide()


## Oyun sonu sekmesi: kaydırılabilir zengin metin sayfası.
func _page(title: String) -> RichTextLabel:
	var l := RichTextLabel.new()
	l.name = title
	l.bbcode_enabled = true
	l.add_theme_font_size_override("normal_font_size", host._fs(17))
	l.add_theme_font_override("bold_font", UIKit.serif())
	l.add_theme_font_size_override("bold_font_size", host._fs(20))
	var pad := UIKit.box(Color(0, 0, 0, 0.25), Color(0, 0, 0, 0), 6, 16)
	l.add_theme_stylebox_override("normal", pad)
	tabs.add_child(l)
	return l


## Hakikat Dosyası'nın sonu: komplonun gerçek kronolojisi ve alametlerin kaçının doğru olduğu.
func _append_plot(plot: Array, signs: Dictionary) -> void:
	lies_page.append_text("\n[b][color=#d9b359][font_size=22]KOMPLO DEFTERİ — perde arkasında ne oldu[/font_size][/color][/b]\n")
	var real := int(signs.get("real", 0))
	var rumor := int(signs.get("rumor", 0))
	if real + rumor > 0:
		lies_page.append_text("[color=gray]Son gördüğün alametlerin %d'i gerçekti, %d'i dedikoduydu.[/color]\n\n" % [real, rumor])
	if plot.is_empty():
		lies_page.append_text("Sarayda kimse sana karşı örgütlenmedi.\n")
		return
	for l: Dictionary in plot:
		var t: String = l["text"]
		var col := "#c0504a" if t.contains("komploya") or t.contains("hazırlığına") or t.contains("darbe girişimini") else ("#7fae7a" if t.contains("çekildi") or t.contains("tutuklandı") or t.contains("halk") else "#d08a3d")
		lies_page.append_text("• Hafta %d — [b]%s[/b] [color=%s]%s[/color]\n" % [int(l["w"]), l["name"], col, t])


## Hakikat Dosyası'nın ikinci yarısı: danışmanların önerileri gerçekte ne kadar iyiydi?
func _append_council(council: Array) -> void:
	lies_page.append_text("\n[b][color=#d9b359][font_size=22]MECLİS SİCİLİ — kim seni nereye yönlendirdi[/font_size][/color][/b]\n")
	lies_page.append_text("[color=gray]Öneri · dinlediğin · seni yanılttığı (önerisi en iyi seçenekten belirgin biçimde kötüydü)[/color]\n\n")
	if council.is_empty():
		lies_page.append_text("Meclis bu saltanatta hiç öneride bulunmadı.\n")
		return
	for c: Dictionary in council:
		var misled := int(c["misled"])
		var col := "#c0504a" if misled * 3 >= int(c["given"]) and misled > 0 else ("#d08a3d" if misled > 0 else "#7fae7a")
		lies_page.append_text("[b]%s[/b]   %d öneri · %d kez dinledin · [color=%s]%s[/color]\n" % [
			c["name"], int(c["given"]), int(c["followed"]), col, "%d kez yanılttı" % misled if misled > 0 else "hiç yanıltmadı"])
		var w: Dictionary = c["worst"]
		if not w.is_empty():
			lies_page.append_text("   [color=gray]En pahalısı, hafta %d — %s:[/color] \"%s\" dedi; en iyisi \"%s\" idi.%s\n" % [
				int(w["w"]), w["event"], w["rec"], w["best"], "  [color=#c0504a](dinledin)[/color]" if w["followed"] else ""])
		lies_page.append_text("\n")


func _state_band(value: float) -> String:
	if value < 35.0:
		return "çökmüş"
	if value < 70.0:
		return "zorlanan"
	return "sağlam"


func _append_state(state: Dictionary) -> void:
	if state.is_empty():
		return
	lies_page.append_text("\n[b][color=#d9b359][font_size=22]DEVLET DEFTERİ — ne pahasına[/font_size][/color][/b]\n")
	lies_page.append_text("[color=gray]Kurumların ortalama hâli:[/color] %s. En zayıf an: %d. hafta, %s.\n" % [
		_state_band(float(state.get("average", 55.0))), int(state.get("low_week", 0)), _state_band(float(state.get("lowest", 55.0)))])
	lies_page.append_text("[color=gray]O haftanın kaydı:[/color] %s\n" % state.get("low_event", ""))
	var appointments: Array = state.get("appointments", [])
	var institutions := {"maliye": "Maliye", "hukuk": "Adliye", "ordu": "Ordu", "idare": "İdare"}
	if appointments.is_empty():
		lies_page.append_text("Kadroda yeni bir atama yapmadın.\n")
	else:
		for item: Dictionary in appointments:
			lies_page.append_text("• %d. hafta — %s: %s\n" % [int(item["week"]),
				institutions.get(str(item["institution"]), str(item["institution"])), "Sadık Ata" if item["kind"] == "loyal" else "Liyakatli Ata"])
	lies_page.append_text("[color=gray]İhale:[/color] %d kez. [color=gray]Halden'in düşman yayını:[/color] %d hafta.\n" % [
		int(state.get("tenders", 0)), int(state.get("hostile_weeks", 0))])


## Kaydı sekmelere yazar (Özet, Tarihçiler, Hakikat Dosyası, Kararlar) ve final görselinin yolunu döndürür.
## Gösterme/sinema main.gd::_on_end'de kalır.
func show_record(record: Dictionary) -> String:
	var bg_path := "res://art/end_victory.png"
	if not record["survived"]:
		var c: String = record["cause"]
		bg_path = "res://art/end_coup.png"
		if c.contains("ayaklanma"):
			bg_path = "res://art/end_uprising.png"
		elif c.contains("yetkisiz"):
			bg_path = "res://art/end_scandal.png"
	bg.texture = host._art(bg_path)
	var verdict := "Tahtını korudun." if record["survived"] else "Tahtını kaybettin."
	head.clear()
	head.append_text("[b][font_size=%d]Kral %s[/font_size][/b]   [font_size=%d][color=%s]%s[/color][/font_size]\n[font_size=%d][color=gray]Ünvanın:[/color] [color=#d9b359]%s[/color][/font_size]" % [
		host._fs(34), record["king"], host._fs(22), "#7fae7a" if record["survived"] else "#c0504a", verdict, host._fs(19), record["title"]])
	var lies: Array = record["lies"]
	var hist_log: Array = record["history"]
	# Özet
	summary.clear()
	summary.append_text("%s\n\n" % record["cause"])
	summary.append_text("[b]Saltanat:[/b] %d hafta  ·  [b]En güçlü isim:[/b] %s\n[b]Söz sicili:[/b] %s\n[b]Karar defteri:[/b] %d kayıt\n" % [
		int(record["weeks"]), record["top_actor"], record.get("promises", ""), hist_log.size()])
	if str(record.get("regime", "")) != "":
		summary.append_text("[b]Rejimin:[/b] %s. [b]Son sınavı:[/b] %s.\n" % [record["regime"], record["threat"]])
	var state: Dictionary = record.get("state", {})
	if not state.is_empty():
		summary.append_text("[b]Devletin:[/b] %s. Bedeli Hakikat Dosyası'ndaki Devlet Defteri'nde.\n" % _state_band(float(state.get("average", 55.0))))
	if lies.is_empty():
		summary.append_text("[b]Hakikat Dosyası:[/b] kimse sana belirgin biçimde yalan söylemedi.\n")
	else:
		var liars: Dictionary = {}
		for l: Dictionary in lies:
			liars[l["name"]] = true
		summary.append_text("[b]Hakikat Dosyası:[/b] [color=#c0504a]%d kişi sana yalan söyledi.[/color] Kim olduklarını Hakikat Dosyası sekmesinde gör.\n" % liars.size())
	var council: Array = record.get("council", [])
	if not council.is_empty() and int(council[0]["misled"]) > 0:
		summary.append_text("[b]Meclis:[/b] seni en çok [color=#d08a3d]%s[/color] yanılttı (%d kez). Ayrıntısı Hakikat Dosyası'nda.\n" % [
			council[0]["name"], int(council[0]["misled"])])
	for l: Dictionary in record.get("plot", []):
		if l["text"] == "komploya katıldı":
			summary.append_text("[b]Komplo:[/b] ilk kıvılcım %d. haftada, [color=#c0504a]%s[/color]. Kronolojisi Hakikat Dosyası'nda.\n" % [int(l["w"]), l["name"]])
			break
	var fresh: Array = record.get("new_achievements", [])
	if not fresh.is_empty():
		summary.append_text("\n[b][color=#d9b359][font_size=22]YENİ BAŞARIM[/font_size][/color][/b]\n")
		for id in fresh:
			var info: Array = Sim.ACHIEVEMENTS.get(id, [id, ""])
			summary.append_text("[color=#d6b25e]»[/color]  [b]%s[/b] — %s\n" % [info[0], info[1]])
	if not hist_log.is_empty():
		summary.append_text("\n[b][color=#d9b359][font_size=22]Son kararların[/font_size][/color][/b]   [color=gray]tamamı Kararlar sekmesinde[/color]\n")
		for h in hist_log.slice(maxi(0, hist_log.size() - 6)):
			summary.append_text("• %s\n" % h)
	# Tarihçiler
	hist_page.clear()
	hist_page.append_text("[b][color=#d9b359][font_size=22]TARİH NE YAZACAK?[/font_size][/color][/b]\n[color=gray]Aynı saltanat, iki ayrı kalemden.[/color]\n\n")
	var hist: Array = record.get("historians", [])
	if hist.size() == 2:
		hist_page.append_text("[color=#d6b25e][b]Saray tarihçisi[/b][/color]\n[i]\"%s\"[/i]\n\n" % hist[0])
		hist_page.append_text("[color=#c0504a][b]Sürgündeki tarihçi[/b][/color]\n[i]\"%s\"[/i]\n" % hist[1])
	else:
		hist_page.append_text("Tarihçiler bu saltanat hakkında sessiz kaldı.")
	# Hakikat Dosyası
	lies_page.clear()
	lies_page.append_text("[b][color=#d9b359][font_size=22]HAKİKAT DOSYASI — sana söylenmeyenler[/font_size][/color][/b]\n\n")
	if lies.is_empty():
		lies_page.append_text("Kimse sana belirgin biçimde yalan söylemedi. Ya da hepsini fark ettin.\n")
	for l: Dictionary in lies:
		lies_page.append_text("• Hafta %d — [b]%s[/b] sana şunu söyledi: \"%s\"\n   [color=gray]Gerçekte:[/color] %s\n\n" % [l["week"], l["name"], l["said"], l["truth"]])
	_append_council(record.get("council", []))
	_append_plot(record.get("plot", []), record.get("signs", {}))
	_append_state(state)
	# Kararlar: hepsi, sondan başa
	log_page.clear()
	log_page.append_text("[b][color=#d9b359][font_size=22]KARARLARIN[/font_size][/color][/b]   [color=gray]%d kayıt · en yenisi üstte[/color]\n\n" % hist_log.size())
	if hist_log.is_empty():
		log_page.append_text("Hiç karar vermedin. Tarih bunu da yazar.")
	for i in range(hist_log.size() - 1, -1, -1):
		log_page.append_text("• %s\n" % hist_log[i])
	tabs.set_tab_title(3, "Hakikat Dosyası (%d)" % lies.size() if not lies.is_empty() else "Hakikat Dosyası")
	tabs.current_tab = 0
	for page in [summary, hist_page, lies_page, log_page]:
		page.scroll_to_line(0)
	timeline = state.get("timeline", record.get("timeline", []))
	chart_drawn = false
	chart.set_data([], false)
	return bg_path
