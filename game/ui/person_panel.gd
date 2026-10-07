extends RefCounted

const UIKit := preload("res://game/ui/ui_kit.gd")

var host: Control

const ROLE := {"army": "Ordu", "intel": "İstihbarat", "economy": "Maliye", "media": "Medya", "press": "Basın",
	"gate": "Saray", "royal": "Hanedan", "opposition": "Muhalefet", "court": "Yargı"}

const TIPS := {
	"summon": "Huzura Çağır (1 mesai)\nİz bırakmaz, para istemez. Kişiyi biraz yatıştırır. Komplo kuran çoğu zaman kaçamak konuşur; temiz çıkan birinin hakkındaki dedikodular dağılır. Aynı kişi 4 haftada bir çağrılabilir.",
	"promote": "Terfi Ettir (1 mesai)\nGüç ve minnet verir; ama onun gücü, hırsı ve sana olan borcun da büyür.",
	"bribe": "Gizli Ödeme (1 mesai, 5 servet)\nSadakat satın alır, zamanla aşınır. Bir iz bırakır; iz dosyalara düşer.",
	"cross": "Raporu Doğrula (1 mesai)\nBir kaynağın raporunu başka kaynaklarla kıyaslar. Sonuç gürültülüdür; kaynak karnesine işlenir.",
	"dismiss": "Görevden Al (1 mesai)\nSırlarını çok bilen ya da çok güçlü biri karşı saldırıya geçer. Sessizce gidenler az olur.",
	"o_yaz": "Yazılı Emir: Bastır (1 mesai)\nKesin uygulanır ama kanıt bırakır.",
	"o_soz": "Sözlü Emir: Bastır (1 mesai)\nYarı kesin uygulanır, iz bırakmaz.",
	"o_ima": "İma: 'Halledilsin' (1 mesai)\nİnkâr edilebilir; ama hırslı biri aşırı yorumlar, korkak biri hiç uygulamaz.",
	"o_sor": "Soruşturma (1 mesai)\nİstihbarat gibi güçlü birine verilirse sorunlu isimleri ipucu olarak getirebilir.",
	"investigate": "Araştır (1 mesai)\nSeçilen kişinin önce zayıf noktasını, sonra kırmızı çizgisini öğrenmeye çalışır. İstihbarat güçlüyse şans artar.",
	"blackmail": "Şantaj (1 mesai)\nZayıf noktası bilinen birini korkuyla bağlar, borcunu siler. Ama iz bırakır, hırsını büyütür; dürüst biri ifşa edebilir.",
	"p_0": "Söz: Başbakanlık (1 mesai)\nHemen sadakat getirir. Tutarsan çok güçlenir; senin gücünden de pay alır. Yalnızca bir kişiye verilebilir.",
	"p_1": "Söz: Liman İhalesi (1 mesai)\nHemen sadakat getirir. Tutarsan zenginleşir, sana da komisyon düşer. Yalnızca bir kişiye verilebilir.",
	"p_2": "Söz: Dokunulmazlık (1 mesai)\nHemen sadakat getirir. Tutarsan korkusu azalır. Aynı sözü iki kişiye vermek er geç duyulur.",
	"op_dikkat": "Dikkat Dağıt (2 mesai)\nSahte bir kriz yaratıp huzursuzluğu azaltır. Çember büyüdükçe başarı da, sızıntı riski de artar.",
	"op_bol": "Muhalefeti Böl (2 mesai)\nMuhalefet kanatlarını birbirine düşürür.",
	"op_zayif": "Rakibi Zayıflat (2 mesai)\nEn güçlü kişinin itibarını kırar. Kim yaptığını tahmin eder.",
	"op_dus": "Birbirine Düşür (2 mesai)\nÇoklu seçimle tam iki kişi seç. Başarırsan ikisi de birbiriyle uğraşırken güç ve hırs kaybeder; başarısız olursan kimin yaptığını anlarlar ve bir sır doğar. Aynı çift için 6 hafta bekle.",
	"leak": "Sızdır (1 mesai)\nBir dosyayı basına verir; ortak bilgi artar. Herkesin bildiği şey en tehlikelisidir.",
	"hush": "Bastır (1 mesai)\nDedikoduyu düşürür ama kanıtın kopyaları durur.",
	"destroy": "Kanıtı Yok Et (1 mesai)\nKopyalar bitince gerçekten silinir; girişim fark edilebilir.",
	"appoint_loyal": "Sadık Ata (1 mesai)\nBir kurum başkanı için sadık kadro kararnamesi çıkar. Sonucunu zamanla raporlardan öğrenirsin.",
	"appoint_merit": "Liyakatli Ata (1 mesai)\nBir kurum başkanı için liyakatli kadro kararnamesi çıkar. Sonucunu zamanla raporlardan öğrenirsin.",
	"tender": "İhale Ver (1 mesai)\nHalden'in şirketlerine yeni bir devlet işi ver. Sözleşmenin sonuçları zamanla ortaya çıkar.",
}

## Eylem kategorileri (eylem panelindeki sekmeler).
const CAT_TIPS := {
	"KAZAN": "Kazan\nSadakat kazanmanın yolları: Huzura Çağır iz bırakmaz, terfi güç verir, gizli ödeme iz bırakır.",
	"SÖZ VER": "Söz Ver\nHemen sadakat getirir; vadesi gelince ya tutarsın ya bedelini ödersin. Her ödül yalnızca bir kişiye verilebilir.",
	"ÖĞREN": "Öğren\nRaporları doğrula, zayıf noktayı ve kırmızı çizgiyi araştır, soruşturma aç.",
	"EMRET": "Emret\nHuzursuzluğu bastırma emri. Kanal seçimi sonucu ve inkâr edilebilirliği belirler.",
	"BASKI": "Baskı\nŞantaj ve görevden alma. Güçlü araçlar, ama geri tepebilirler.",
	"OPERASYON": "Operasyon (2 mesai)\n1–3 kişiyle gizli iş. Çemberi kurmak için Çoklu seçim'i aç ya da Ctrl ile kişi ekle.",
	"DEVLET": "Devlet\nKurum başkanları için kadro kararnameleri ve Halden için ihale.",
}

const HINT_DEFAULT := "[color=#8f7a45]Bir eylemin üzerine gel ya da dokun: ne yaptığını ve bedelini burada görürsün.[/color]"


func _init(main: Control) -> void:
	host = main

func _build_ui(cols: HBoxContainer) -> void:
	# Sağ: kişiler ve eylemler
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	if host._mobile:
		# Mobil: kişiler ve eylemler ayrı bir sekme (yatay telefonda iki sütun sığmaz).
		var saray := ScrollContainer.new()
		saray.name = "Saray"
		saray.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		host._tabs.add_child(saray)
		host._tabs.move_child(saray, 1)
		saray.add_child(right)
	else:
		cols.add_child(right)
	var cap_row := HBoxContainer.new()
	right.add_child(cap_row)
	var cap: Control = host._section("GÜÇ MERKEZLERİ")
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cap_row.add_child(cap)
	host._multi_btn = Button.new()
	host._multi_btn.text = "Çoklu seçim"
	host._multi_btn.toggle_mode = true
	host._multi_btn.add_theme_font_size_override("font_size", host._fs(13))
	host._multi_btn.tooltip_text = "Açıkken kartlara dokunmak seçime ekler/çıkarır (Ctrl ile aynı). Operasyon çemberi için."
	host._wire(host._multi_btn)
	host._multi_btn.toggled.connect(func(on: bool) -> void:
		_hint("Çoklu seçim %s. Operasyon için 1–3 kişi seç." % ("açık" if on else "kapalı")))
	host._grid = GridContainer.new()
	host._grid.columns = 5
	host._grid.add_theme_constant_override("h_separation", 6)
	host._grid.add_theme_constant_override("v_separation", 6)
	right.add_child(host._grid)

	var detail := PanelContainer.new()
	detail.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL, 0.85), Color(UIKit.GOLD_DIM, 0.3), 6, 8))
	right.add_child(detail)
	UIKit.ornament(detail)
	var irow := HBoxContainer.new()
	irow.add_theme_constant_override("separation", 10)
	detail.add_child(irow)
	host._portrait_box = Control.new()
	host._portrait_box.custom_minimum_size = Vector2(62, 62)
	irow.add_child(host._portrait_box)
	var icol := VBoxContainer.new()
	icol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icol.add_theme_constant_override("separation", 5)
	icol.custom_minimum_size.y = 62
	irow.add_child(icol)
	host._info = RichTextLabel.new()
	host._info.bbcode_enabled = true
	host._info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host._info.fit_content = true
	host._info.scroll_active = false
	host._info.add_theme_font_size_override("normal_font_size", host._fs(13))
	icol.add_child(host._info)
	# Kişinin özellikleri: küçük göstergeler (sayı yok; yalnızca oyuncunun bildiği kadar).
	host._traits = HFlowContainer.new()
	host._traits.add_theme_constant_override("h_separation", 6)
	host._traits.add_theme_constant_override("v_separation", 5)
	icol.add_child(host._traits)

	# Eylem paneli: tek çerçeve, başlıkta seçili kişi, eylemler amaca göre gruplu.
	var act_panel := PanelContainer.new()
	act_panel.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL, 0.8), Color(UIKit.GOLD_DIM, 0.28), 8, 10))
	right.add_child(act_panel)
	UIKit.ornament(act_panel)
	var av := VBoxContainer.new()
	av.add_theme_constant_override("separation", 5)
	act_panel.add_child(av)
	host._act_title = Label.new()
	host._act_title.add_theme_font_override("font", UIKit.serif())
	host._act_title.add_theme_font_size_override("font_size", host._fs(17))
	host._act_title.add_theme_color_override("font_color", UIKit.GOLD)
	av.add_child(host._act_title)
	var groups := [
		["KAZAN", [["summon", "Huzura Çağır"], ["promote", "Terfi"], ["bribe", "Gizli Ödeme"]]],
		["SÖZ VER", [["p_0", "Başbakanlık"], ["p_1", "Liman İhalesi"], ["p_2", "Dokunulmazlık"]]],
		["ÖĞREN", [["cross", "Doğrula"], ["investigate", "Araştır"], ["o_sor", "Soruşturma"]]],
		["EMRET", [["o_yaz", "Yazılı Emir"], ["o_soz", "Sözlü Emir"], ["o_ima", "İma"]]],
		["BASKI", [["blackmail", "Şantaj"], ["dismiss", "Görevden Al"]]],
		["OPERASYON", [["op_dikkat", "Dikkat Dağıt"], ["op_bol", "Muhalefeti Böl"], ["op_zayif", "Rakibi Zayıflat"], ["op_dus", "Birbirine Düşür"]]],
		["DEVLET", [["appoint_loyal", "Sadık Ata"], ["appoint_merit", "Liyakatli Ata"], ["tender", "İhale Ver"]]],
	]
	var actions := {
		"summon": func() -> void: host._act(func(id: String) -> String: return Sim.summon(id)),
		"promote": func() -> void: host._act(func(id: String) -> String: return Sim.promote(id)),
		"bribe": func() -> void: host._act(func(id: String) -> String: return Sim.bribe(id)),
		"cross": func() -> void: host._act(func(id: String) -> String: return Sim.cross_check(id)),
		"investigate": func() -> void: host._act(func(id: String) -> String: return Sim.investigate(id)),
		"o_sor": func() -> void: host._act(func(id: String) -> String: return Sim.order(id, "sorustur", "sozlu")),
		"o_yaz": func() -> void: host._act(func(id: String) -> String: return Sim.order(id, "bastir", "yazili")),
		"o_soz": func() -> void: host._act(func(id: String) -> String: return Sim.order(id, "bastir", "sozlu")),
		"o_ima": func() -> void: host._act(func(id: String) -> String: return Sim.order(id, "bastir", "ima")),
		"blackmail": func() -> void: host._act(func(id: String) -> String: return Sim.blackmail(id)),
		"dismiss": func() -> void: host._act(func(id: String) -> String: return Sim.dismiss(id)),
		"op_dikkat": func() -> void: host._op("dikkat"),
		"op_bol": func() -> void: host._op("bol"),
		"op_zayif": func() -> void: host._op("zayiflat"),
		"op_dus": func() -> void: host._op("dus"),
		"appoint_loyal": func() -> void: host._act(func(id: String) -> String: return Sim.appoint(id, "loyal")),
		"appoint_merit": func() -> void: host._act(func(id: String) -> String: return Sim.appoint(id, "merit")),
		"tender": func() -> void: host._act(func(id: String) -> String: return Sim.give_tender(id)),
	}
	for i in Sim.PRIZES.size():
		var prize: String = Sim.PRIZES[i]
		actions["p_%d" % i] = func() -> void: host._act(func(id: String) -> String: return Sim.promise(id, prize))
	# Kategori sekmeleri: aynı anda yalnızca bir kategorinin eylemleri görünür (aşamalı açılım).
	var cat_row := HBoxContainer.new()
	cat_row.add_theme_constant_override("separation", 4)
	av.add_child(cat_row)
	var cat_group := ButtonGroup.new()
	for g in groups:
		var cb := Button.new()
		cb.text = g[0]
		cb.toggle_mode = true
		cb.button_group = cat_group
		cb.theme_type_variation = "GhostButton"
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.clip_text = true
		cb.add_theme_font_size_override("font_size", host._fs(11))
		if g[0] == "BASKI":
			for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
				cb.add_theme_color_override(c, UIKit.DANGER.lightened(0.15))
		var ctip: String = CAT_TIPS[g[0]]
		cb.tooltip_text = ctip
		cb.mouse_entered.connect(func() -> void: _hint(ctip))
		cb.pressed.connect(_show_act_cat.bind(str(g[0])))
		host._wire(cb)
		cat_row.add_child(cb)
		host._cat_btns[g[0]] = cb
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		av.add_child(row)
		host._cat_rows[g[0]] = row
		for item in g[1]:
			_add_btn(row, item[0], item[1], actions[item[0]])
			var btn := host._buttons[item[0]] as Button
			btn.add_theme_font_size_override("font_size", host._fs(13))
			btn.clip_text = true
			if item[0] in ["blackmail", "dismiss", "op_zayif"]:
				btn.theme_type_variation = "DangerButton"
		if g[0] == "OPERASYON":
			row.add_child(host._multi_btn)
	_show_act_cat(host._act_cat)
	# Eylem açıklaması / son eylemin sonucu: panelin içinde iki satırlık alan (ayrı boş kutu yok).
	var hsep := ColorRect.new()
	hsep.color = Color(UIKit.GOLD_DIM, 0.25)
	hsep.custom_minimum_size.y = 1
	hsep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	av.add_child(hsep)
	host._hint_label = RichTextLabel.new()
	host._hint_label.bbcode_enabled = true
	host._hint_label.scroll_active = false
	host._hint_label.add_theme_color_override("default_color", UIKit.TEXT_DIM)
	host._hint_label.add_theme_font_size_override("normal_font_size", host._fs(13))
	host._hint_label.add_theme_font_size_override("bold_font_size", host._fs(13))
	host._hint_label.clip_contents = true
	host._hint_label.custom_minimum_size.y = 40 if not host._mobile else 54
	host._hint_label.text = HINT_DEFAULT
	av.add_child(host._hint_label)
	if not host._mobile:
		# Masaüstü: raporlar kaynaklarının (güç merkezlerinin) altında, kompakt liste.
		var rscroll := ScrollContainer.new()
		rscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		rscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		right.add_child(rscroll)
		host._report_box = VBoxContainer.new()
		host._report_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		host._report_box.add_theme_constant_override("separation", 4)
		rscroll.add_child(host._report_box)


func _show_act_cat(cat: String) -> void:
	host._act_cat = cat
	for k in host._cat_rows:
		(host._cat_rows[k] as Control).visible = k == cat
	for k in host._cat_btns:
		(host._cat_btns[k] as Button).set_pressed_no_signal(k == cat)   # koddan değişince ButtonGroup diğerini bırakmıyor


func _add_btn(parent: Node, key: String, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(cb)
	if TIPS.has(key):
		var tip: String = TIPS[key]
		b.tooltip_text = tip
		if ACTION_META.has(key):
			b.mouse_entered.connect(_preview.bind(key))
			b.button_down.connect(_preview.bind(key))
		else:
			b.mouse_entered.connect(func() -> void: _hint(tip))
			b.button_down.connect(func() -> void: _hint(tip))
	host._wire(b)
	parent.add_child(b)
	host._buttons[key] = b


## Eylem önizlemesi (docs/design/faz1_okunabilirlik.md): [ad, mesai, servet (-1: Sim'den), iz, temel risk].
## iz: 0 yok, 1 inkâr edilebilir, 2 iz bırakır, 3 kanıt bırakır. Risk yalnızca görünür bilgiden düzeltilir.
const ACTION_META := {
	"summon": ["Huzura Çağır", 1, 0.0, 0, 0],
	"promote": ["Terfi", 1, 0.0, 0, 1],
	"bribe": ["Gizli Ödeme", 1, -1.0, 2, 0],   # -1: servet bedeli Sim.BRIBE_COST
	"cross": ["Raporu Doğrula", 1, 0.0, 0, 0],
	"investigate": ["Araştır", 1, 0.0, 0, 0],
	"o_sor": ["Soruşturma", 1, 0.0, 0, 0],
	"o_yaz": ["Yazılı Emir", 1, 0.0, 3, 1],
	"o_soz": ["Sözlü Emir", 1, 0.0, 0, 1],
	"o_ima": ["İma", 1, 0.0, 1, 2],
	"blackmail": ["Şantaj", 1, 0.0, 2, 2],
	"dismiss": ["Görevden Al", 1, 0.0, 0, 1],
	"p_0": ["Söz: Başbakanlık", 1, 0.0, 0, 1],
	"p_1": ["Söz: Liman İhalesi", 1, 0.0, 0, 1],
	"p_2": ["Söz: Dokunulmazlık", 1, 0.0, 0, 1],
	"op_dikkat": ["Dikkat Dağıt", 2, 0.0, 1, 1],
	"op_bol": ["Muhalefeti Böl", 2, 0.0, 1, 1],
	"op_zayif": ["Rakibi Zayıflat", 2, 0.0, 1, 2],
	"op_dus": ["Birbirine Düşür", 2, 0.0, 1, 1],
	"appoint_loyal": ["Sadık Ata", 1, 0.0, 0, 0],
	"appoint_merit": ["Liyakatli Ata", 1, 0.0, 0, 0],
	"tender": ["İhale Ver", 1, 0.0, 0, 0],
}
const TRACE_NAMES := ["iz yok", "inkâr edilebilir", "iz bırakır", "kanıt bırakır"]
const RISK_NAMES := ["düşük", "orta", "yüksek"]


func _preview(key: String) -> void:
	if host._hint_label == null:
		return
	var m: Array = ACTION_META[key]
	var risk := int(m[4])
	var note := ""
	var id: String = host._selected_primary()
	if key == "op_dus":
		var n: int = host._sel.size()
		if n != 2:
			note = "Çoklu seçimi aç ve tam iki kişi seç."
		elif Sim.rival_wait(host._sel) > 0:
			note = "Bu çifti yakın zamanda denedin; %d hafta bekle." % Sim.rival_wait(host._sel)
		else:
			note = "İkisi de güçlü ve hırslıysa daha çok kapışırlar. Başarısız olursa kimin yaptığını anlarlar."
	elif key.begins_with("op_"):
		var n: int = host._sel.size()
		risk = clampi(risk + maxi(0, n - 2), 0, 2)
		note = "Önce çemberi kur: 1–3 kişi seç." if n == 0 else "Çember büyüdükçe başarı da, sızıntı riski de artar."
	elif id == "":
		note = "Önce bir kişi seç."
	else:
		var a = Sim.actors[id]
		var tier := Sim.power_tier(a.power)
		match key:
			"tender":
				if id != "halden":
					note = "Yalnızca Halden'e ihale verilebilir."
				elif Sim.tender_wait() > 0:
					note = "İhale komisyonu yeni dosyayı henüz açmıyor."
			"appoint_loyal", "appoint_merit":
				if not Sim.INSTITUTION_HEADS.has(id):
					note = "Yalnızca kurum başkanları için kullanılabilir."
				elif Sim.appoint_wait(id) > 0:
					note = "Bu kurumda yeni atama için beklemelisin."
			"summon":
				var wait := Sim.summon_wait(id)
				if wait > 0:
					note = "%s yeniden çağırmak için %d hafta beklemelisin." % [Sim.ek(a.display_name, "i"), wait]
			"promote":
				if tier == 3:
					risk = 2
					note = "%s zaten vazgeçilmez; terfi onu daha da tehlikeli yapar." % a.display_name
			"bribe":
				if Sim.private_wealth < Sim.BRIBE_COST:
					note = "Servetin yetmiyor."
			"investigate":
				if a.known_weak and a.known_red:
					note = "Onun hakkında öğrenilecek bir şey kalmadı."
			"blackmail":
				if not a.known_weak:
					note = "Önce zayıf noktasını öğren (Araştır)."
			"o_yaz", "o_soz", "o_ima":
				if Sim.street_anger >= 40.0:
					risk = maxi(risk, 2)
					note = "Sokak bastırmaya alışıyor: her emir daha az işe yarıyor, öfke birikiyor."
			"dismiss":
				risk = tier - 1
				note = ["", "Sessizce gidebilir.", "Gücü var; karşılık verebilir.", "Vazgeçilmez birini düşürmek ağır bir karşı saldırı getirebilir."][tier]
			"p_0", "p_1", "p_2":
				if Sim.prize_taken(Sim.PRIZES[int(key.substr(2))]):
					note = "Bu ödül zaten birine verildi."
		if a.moved:
			note = "%s artık sana karşı; eylemlerin işe yaramayabilir." % a.display_name
	if Sim.mesai < int(m[1]):
		note = "Mesain yetmiyor."
	if note == "":
		# Bağlam yoksa uzun açıklamanın ilk cümlesi (tamamı ipucu balonunda).
		var desc: String = str(TIPS[key]).split("\n")[1]
		note = desc.split(". ")[0].trim_suffix(".") + "."
	if key in ["appoint_loyal", "appoint_merit", "tender"]:
		host._hint_label.text = "[color=#d6b25e][b]%s[/b][/color]   [color=#9a958a]1 mesai[/color]\n%s" % [m[0], note]
		return
	var cost := "%d mesai" % int(m[1])
	var wealth: float = Sim.BRIBE_COST if float(m[2]) < 0.0 else float(m[2])
	if wealth > 0.0:
		cost += " · %d servet" % int(wealth)
	var trace := int(m[3])
	var tc: String = [UIKit.OK, UIKit.GOLD, UIKit.AMBER, UIKit.DANGER][trace].to_html(false)
	var rc: String = [UIKit.OK, UIKit.AMBER, UIKit.DANGER][risk].to_html(false)
	host._hint_label.text = "[color=#d6b25e][b]%s[/b][/color]   [color=#9a958a]%s  ·  [/color][color=#%s]%s[/color][color=#9a958a]  ·  tahmini risk [/color][color=#%s]%s[/color]\n%s" % [
		m[0], cost, tc, TRACE_NAMES[trace], rc, RISK_NAMES[risk], note]


func _hint(text: String) -> void:
	if host._hint_label == null:
		return
	var lines := text.split("\n", false, 1)
	if lines.size() == 2:
		host._hint_label.text = "[color=#d6b25e][b]%s[/b][/color]\n%s" % [lines[0], lines[1]]
	else:
		host._hint_label.text = text

func _rebuild_cards() -> void:
	var sig := ""
	for a in Sim.actors.values():
		sig += "%s%d," % [a.id, 1 if a.moved else 0]
	if sig != host._cards_sig:
		host._cards_sig = sig
		for c in host._grid.get_children():
			c.queue_free()
		host._cards.clear()
		for a in Sim.actors.values():
			var card := _make_card(a)
			host._grid.add_child(card)
			host._cards[a.id] = card
		var kept: Array[String] = []
		for s in host._sel:
			if Sim.actors.has(s):
				kept.append(s)
		host._sel = kept
	_style_cards()


var _card_fade_tex: Texture2D


func _card_fade() -> Texture2D:
	if _card_fade_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(0.02, 0.015, 0.02, 0.0))
		g.set_color(1, Color(0.02, 0.015, 0.02, 0.92))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill_from = Vector2(0, 0)
		gt.fill_to = Vector2(0, 1)
		gt.width = 4
		gt.height = 64
		_card_fade_tex = gt
	return _card_fade_tex


func _make_card(a) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(108, 96) if not host._mobile else Vector2(150, 132)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.tooltip_text = "%s\n%s" % [a.display_name, a.title]
	# Portre kartı tam doldurur; ad ve rol, portrenin altındaki karartmanın üstünde.
	var card_art: Control = host._initial_art(a.id, Vector2(92, 88) if not host._mobile else Vector2(130, 120), 36)
	card.add_child(card_art)
	var fade := TextureRect.new()
	fade.texture = _card_fade()
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.anchor_top = 0.42
	fade.anchor_right = 1.0
	fade.anchor_bottom = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_art.add_child(fade)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -2)
	v.anchor_top = 1.0
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.offset_top = -40 if not host._mobile else -52
	v.offset_bottom = -3
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_art.add_child(v)
	var n := Label.new()
	n.text = host._short_name(a.display_name)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_theme_font_override("font", UIKit.serif())
	n.add_theme_font_size_override("font_size", host._fs(17))
	n.add_theme_color_override("font_color", Color("f3ead2"))
	n.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	n.add_theme_constant_override("shadow_outline_size", 4)
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(n)
	var r := Label.new()
	r.text = UIKit.tr_upper("Düşman" if a.moved else str(ROLE.get(a.domain, "")))
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	r.add_theme_font_override("font", UIKit.caps())
	r.add_theme_font_size_override("font_size", host._fs(10))
	r.add_theme_color_override("font_color", Color("ff8a7a") if a.moved else Color(UIKit.GOLD, 0.85))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(r)
	card.set_meta("id", a.id)
	card.set_meta("role", r)
	card.gui_input.connect(_on_card_input.bind(a.id))
	# Üzerine gelince portre çerçevesinin içinde hafifçe yakınlaşır.
	var portrait_img: Control = card_art.get_child(0)
	card.mouse_entered.connect(func() -> void:
		Sfx.play("hover", -14.0)
		_style_cards(a.id)
		portrait_img.pivot_offset = portrait_img.size / 2.0
		portrait_img.create_tween().tween_property(portrait_img, "scale", Vector2(1.1, 1.1), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT))
	card.mouse_exited.connect(func() -> void:
		_style_cards()
		portrait_img.create_tween().tween_property(portrait_img, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE))
	return card


func _on_card_input(ev: InputEvent, id: String) -> void:
	var mb := ev as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	Sfx.play("click", -4.0)
	if mb.ctrl_pressed or mb.shift_pressed or host._multi_btn.button_pressed:
		if host._sel.has(id):
			host._sel.erase(id)
		else:
			host._sel.append(id)
	else:
		host._sel.clear()
		host._sel.append(id)
	_style_cards()
	_update_info()


func _style_cards(hover_id := "") -> void:
	for id in host._cards:
		var card: PanelContainer = host._cards[id]
		var a = Sim.actors.get(id)
		var selected: bool = host._sel.has(id)
		var primary: bool = not host._sel.is_empty() and host._sel[0] == id
		var border := Color(UIKit.GOLD_DIM, 0.35)
		var bg := Color(UIKit.PANEL, 0.9)
		if a != null and a.moved:
			border = UIKit.DANGER
		elif a != null:
			# Şüphe göstergesi: yalnızca görülen alametlerden (docs/design/darbe_asamalari.md).
			var lvl := Sim.suspicion_level(id)
			var rl := card.get_meta("role", null) as Label
			if rl != null:
				var role := str(ROLE.get(a.domain, ""))
				rl.text = UIKit.tr_upper(role if lvl < 2 else "%s · %s" % [role, Sim.SUSPICION_NAMES[lvl]])
				rl.add_theme_color_override("font_color", [Color(UIKit.GOLD, 0.85), Color(UIKit.GOLD, 0.85), UIKit.AMBER.lightened(0.15), Color("ff8a7a")][lvl])
			if lvl >= 2:
				border = Color(UIKit.AMBER if lvl == 2 else UIKit.DANGER, 0.7)
		if hover_id == id:
			border = UIKit.GOLD
			bg = Color(UIKit.PANEL_HI, 0.98)
		if selected:
			border = Color("ffe08a") if primary else UIKit.GOLD
			bg = Color("2d2616")
		card.add_theme_stylebox_override("panel", UIKit.box(bg, border, 6, 3, 2 if selected else 1))


const PERSON_ACTIONS := ["summon", "promote", "bribe", "p_0", "p_1", "p_2", "cross", "investigate", "o_sor", "o_yaz", "o_soz", "o_ima", "blackmail", "dismiss", "appoint_loyal", "appoint_merit", "tender"]
const OP_ACTIONS := ["op_dikkat", "op_bol", "op_zayif", "op_dus"]


## Eylem düğmelerinin kullanılabilirliği: kişi seçili mi, mesai/servet yetiyor mu.
func _update_action_states() -> void:
	if host._act_title == null:
		return
	var id: String = host._selected_primary()
	var busy := Sim.ended or Sim.actors.is_empty()
	if id == "":
		host._act_title.text = "EYLEMLER   ·   önce bir kişi seç"
	else:
		host._act_title.text = "EYLEMLER   ·   %s" % Sim.actors[id].display_name
		if host._sel.size() > 1:
			host._act_title.text += "  +%d kişi" % (host._sel.size() - 1)
	for k in PERSON_ACTIONS:
		var b := host._buttons.get(k) as Button
		if b:
			var off: bool = busy or id == "" or Sim.mesai < 1
			if k == "bribe" and Sim.private_wealth < 5.0:
				off = true
			if k == "summon" and id != "" and (Sim.summon_wait(id) > 0 or Sim.actors[id].moved):
				off = true
			if k.begins_with("p_") and Sim.prize_taken(Sim.PRIZES[int(k.substr(2))]):
				off = true
			if k == "blackmail" and id != "" and not Sim.actors[id].known_weak:
				off = true
			if k.begins_with("appoint_") and id != "" and (not Sim.INSTITUTION_HEADS.has(id) or Sim.actors[id].moved or Sim.appoint_wait(id) > 0):
				off = true
			if k == "tender" and id != "" and (id != "halden" or Sim.actors[id].moved or Sim.tender_wait() > 0):
				off = true
			b.disabled = off
	for k in OP_ACTIONS:
		var b := host._buttons.get(k) as Button
		if b:
			b.disabled = busy or host._sel.is_empty() or host._sel.size() > 3 or Sim.mesai < 2
			if k == "op_dus":
				b.disabled = busy or host._sel.size() != 2 or Sim.mesai < 2 or Sim.rival_wait(host._sel) > 0


func _update_info() -> void:
	_update_action_states()
	host._info.clear()
	for c in host._portrait_box.get_children():
		c.queue_free()
	for c in host._traits.get_children():
		host._traits.remove_child(c)
		c.queue_free()
	var id: String = host._selected_primary()
	host._portrait_box.visible = id != ""
	if id == "":
		host._info.append_text("[color=gray]Bir kişi seç. Sayıları göremezsin; yalnızca davranışlarından tahmin edebilirsin.[/color]")
		return
	var a = Sim.actors[id]
	var art: Control = host._initial_art(a.id, Vector2(62, 62), 32)
	host._portrait_box.add_child(art)
	host._info.append_text("[b][font_size=%d]%s[/font_size][/b]  [color=gray]%s[/color]" % [host._fs(18), a.display_name, a.title])
	# Güç: üç kademe (eskiden metinle verilen bilgi; fazlası değil).
	var level := Sim.power_tier(a.power)
	var lvl_name: String = Sim.POWER_TIER_NAMES[level]
	host._traits.add_child(_trait("Güç · " + lvl_name, UIKit.DANGER if level == 3 else UIKit.GOLD, level, 3,
		"Güç merkezi olarak ne kadar ağırlığı var. Vazgeçilmez olanlar tehlikelidir."))
	if a.moved:
		host._traits.add_child(_trait("Düşman", UIKit.DANGER, -1, 0, "Sana karşı fiilen harekete geçti."))
	elif a.insider:
		var sl := Sim.suspicion_level(a.id)
		host._traits.add_child(_trait("Tavır · " + str(Sim.SUSPICION_NAMES[sl]), [UIKit.OK, UIKit.GOLD, UIKit.AMBER, UIKit.DANGER][sl], sl, 3, _signs_tip(a)))
	if a.obligation >= 8.0:
		host._traits.add_child(_trait("Karşılık bekliyor", Color("d9963e"), -1, 0, "Ona verdiklerinin karşılığını bekliyor."))
	var dim := Color(UIKit.TEXT_DIM, 0.8)
	host._traits.add_child(_trait("Zayıf nokta: " + (a.weak_point if a.known_weak else "?"), UIKit.DANGER if a.known_weak else dim, -1, 0,
		"Biliniyorsa şantaj mümkün. 'Araştır' ile öğrenilebilir." if not a.known_weak else "Şantaj için kullanılabilir."))
	host._traits.add_child(_trait("Kırmızı çizgi: " + (a.red_line if a.known_red else "?"), Color("d9963e") if a.known_red else dim, -1, 0,
		"Bu çizgiyi aşarsan affetmez."))
	var k: Dictionary = Sim.karne.get(a.id, {"ok": 0, "bad": 0})
	if int(k["ok"]) + int(k["bad"]) > 0:
		var trust_col := UIKit.OK if int(k["ok"]) >= int(k["bad"]) else UIKit.DANGER
		host._traits.add_child(_trait("Doğrulama: %d örtüştü · %d çelişti" % [k["ok"], k["bad"]], trust_col, -1, 0,
			"Raporlarının başka kaynaklarla karşılaştırılması."))
	for p in Sim.active_promises_of(a.id):
		host._traits.add_child(_trait("Söz: %s · hafta %d" % [p["prize"], p["due"]], Color("d9b359"), -1, 0, "Ona verdiğin söz ve vadesi."))
	if host._sel.size() > 1:
		host._traits.add_child(_trait("%d kişi seçili · operasyon çemberi" % host._sel.size(), UIKit.GOLD, -1, 0, ""))


## Tavır göstergesinin ipucu: son haftalarda görülen alametler.
func _signs_tip(a) -> String:
	var lines: Array[String] = []
	for g: Dictionary in a.signs:
		if int(g["w"]) > Sim.week - Sim.PLOT_SUS_WINDOW:
			lines.append("Hafta %d — %s" % [int(g["w"]), g["text"]])
	if lines.is_empty():
		return "Son haftalarda hakkında bir alamet görülmedi.\nDarbeyi yalnızca ordu ya da hanedan başlatabilir; ama herkes komploya katılabilir."
	lines.reverse()
	return "Son alametler:\n%s\n\nAlametlerin bir kısmı dedikodudur. Huzura Çağır ile yoklayabilirsin." % "\n".join(lines.slice(0, 5))


## Kişi göstergesi: renkli nokta ya da kademe noktaları + kısa metin.
func _trait(text: String, col: Color, filled := -1, total := 0, tip := "") -> Control:
	var chip := PanelContainer.new()
	var sb := UIKit.box(Color(col, 0.1), Color(col, 0.38), 10, 8)
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	chip.add_theme_stylebox_override("panel", sb)
	chip.tooltip_text = tip
	chip.mouse_filter = Control.MOUSE_FILTER_PASS if tip != "" else Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(row)
	var n := total if filled >= 0 else 1
	for i in n:
		var dot := Panel.new()
		var ds := StyleBoxFlat.new()
		ds.set_corner_radius_all(4)
		ds.anti_aliasing = true
		ds.bg_color = col if (filled < 0 or i < filled) else Color(col, 0.18)
		dot.add_theme_stylebox_override("panel", ds)
		dot.custom_minimum_size = Vector2(7, 7)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(dot)
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", host._fs(12))
	l.add_theme_color_override("font_color", col.lightened(0.25) if col.s > 0.1 else col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	return chip


## Haber şeridi önceliği: kriz ve alametler önce, aktör hamleleri en sonda (özet bölümünde zaten görünür).


func _action_tip(key: String) -> String:
	return TIPS[key]
