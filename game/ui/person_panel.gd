extends RefCounted

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")
const TOUCH_SCROLL := preload("res://game/ui/touch_scroll.gd")

var host: Control
var person_block: VBoxContainer
var selection_hint: Label
var clear_button: Button
var _mobile_card_row: HBoxContainer
var _mobile_group := "dynasty"
var _mobile_group_buttons: Dictionary = {}
var _mobile_person_scroll: ScrollContainer
var _legacy_popup: PopupPanel
const MOBILE_GROUPS := {
	"dynasty": ["dorn", "prens", "julian"],
	"state": ["arden", "voss", "kessler", "falk", "governor_capital", "governor_industry", "governor_farmland", "governor_border", "commander_capital", "commander_border", "commander_security"],
	"power": ["halden", "lena", "brandt"],
	"foreign": ["elena", "claire", "malenkov", "lucien"],
}
const MOBILE_DOMAIN_GROUP := {"gate": "dynasty", "royal": "dynasty", "heir": "dynasty", "army": "state", "intel": "state", "economy": "state", "court": "state", "media": "power", "press": "power", "opposition": "power", "foreign": "foreign"}
const MOBILE_GROUP_LABELS := {"dynasty": "Hanedan", "state": "Devlet", "power": "Güç", "foreign": "Dış"}

const ROLE := {"army": "Ordu", "intel": "İstihbarat", "economy": "Maliye", "media": "Medya", "press": "Basın",
	"gate": "Saray", "royal": "Hanedan", "heir": "Veliaht", "foreign": "Dışişleri", "opposition": "Muhalefet", "court": "Yargı"}

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
	"p_0": "Söz: Naiplik (1 mesai)\nHemen sadakat getirir. Tutarsan çok güçlenir; senin gücünden de pay alır. Yalnızca bir kişiye verilebilir.",
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
	"tender": "İhale Ver (1 mesai)\nSarne'nin şirketlerine yeni bir devlet işi ver. Sözleşmenin sonuçları zamanla ortaya çıkar.",
	"train_heir": "Veliahdı Yetiştir (1 mesai)\nJulian için eğitim ve halkla buluşma programı hazırla. Sürekli öne çıkarmak saraydaki başka isimleri rahatsız edebilir.",
	"delegation": "Heyet Gönder (1 mesai)\nSeçili elçiyi başkente davet et. Yakınlık diğer iki elçiliği tedirgin eder.",
	"tax_raise": "Vergiyi artır (1 mesai)\nHazineye kaynak sağlar; pazar ve sokak bedelini hisseder.",
	"tax_relief": "Vergiyi hafiflet (1 mesai)\nPazara nefes verir; hazine gelirinden vazgeçer.",
	"austerity": "Kemer sık (1 mesai)\nKasayı korur; iş ve huzur üzerindeki bedeli büyür.",
	"incentive": "Teşvik paketi (1 mesai)\nBugün kasaya yük olur; istihdam ve üretime sonra destek verir.",
	"region_management": "Bölge Yönetimi (1 mesai)\nR1 tahsisine göre altyapı yatırımı ya da garnizon seç; yerel medya ve vali kararları da aynı bölgesel sicile işlenir.",
	"army_management": "Ordu Düzeni (1 mesai)\nSubay, garnizon, ikmal ya da komuta zinciri hakkında nitel önizlemeli karar kartı aç.",
	"king_speech": "Halka konuş (1 mesai)\nRıza kazanır, korkuyu hafifletir.",
	"king_visit": "Saha ziyareti (1 mesai)\nİnsanlarla yüz yüze gel; görünürlük riskini göze al.",
	"king_ceremony": "Tören düzenle (1 mesai)\nTahtın görünürlüğünü artır; etkisi sınırlı kalır.",
	"king_hide": "Gizlen (1 mesai)\nKorkuyu artırır; uzun vadede rızayı aşındırır.",
}

## Eylem kategorileri (eylem panelindeki sekmeler).
const CAT_TIPS := {
	"KAZAN": "Kazan\nSadakat kazanmanın yolları: Huzura Çağır iz bırakmaz, terfi güç verir, gizli ödeme iz bırakır.",
	"SÖZ VER": "Söz Ver\nHemen sadakat getirir; vadesi gelince ya tutarsın ya bedelini ödersin. Her ödül yalnızca bir kişiye verilebilir.",
	"ÖĞREN": "Öğren\nRaporları doğrula, zayıf noktayı ve kırmızı çizgiyi araştır, soruşturma aç.",
	"EMRET": "Emret\nHuzursuzluğu bastırma emri. Kanal seçimi sonucu ve inkâr edilebilirliği belirler.",
	"BASKI": "Baskı\nŞantaj ve görevden alma. Güçlü araçlar, ama geri tepebilirler.",
	"OPERASYON": "Operasyon (2 mesai)\n1–3 kişiyle gizli iş. Çemberi kurmak için Çoklu seçim'i aç ya da Ctrl ile kişi ekle.",
	"DEVLET": "Devlet\nMaliye kararları, kadro kararnameleri, ihale ve elçilik heyetleri.",
	"KAMUOYU": "Kamuoyu\nHükümdarın görünürlüğü ve halkın güveni.",
}

const HINT_DEFAULT := "[color=#8f7a45]Bir eylemin üzerine gel ya da dokun: ne yaptığını ve bedelini burada görürsün.[/color]"


func _init(main: Control) -> void:
	host = main

func _build_ui(cols: HBoxContainer) -> void:
	# Sağ: kişiler ve eylemler
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	if host._mobile:
		var people := VBoxContainer.new()
		people.name = "Kişiler"
		people.size_flags_vertical = Control.SIZE_EXPAND_FILL
		people.add_theme_constant_override("separation", 6)
		host._tabs.add_child(people)
		host._tabs.move_child(people, 1)
		host._tabs.set_tab_title(1, tr("Kişiler"))
		people.add_child(right)
	else:
		cols.add_child(right)
	if not host._mobile:
		var cap_row := HBoxContainer.new()
		right.add_child(cap_row)
		var cap: Control = host._section(tr("İZLEME LİSTESİ"))
		cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cap_row.add_child(cap)
		cap_row.add_child(host._header_symbol("flourish", Vector2(22, 18), UIKit.GOLD))
	host._multi_btn = Button.new()
	host._multi_btn.text = tr("Çoklu seçim")
	host._multi_btn.toggle_mode = true
	if host._mobile:
		host._multi_btn.custom_minimum_size.y = 44
	host._multi_btn.add_theme_font_size_override("font_size", host._fs(13))
	host._multi_btn.tooltip_text = tr("Açıkken kartlara dokunmak seçime ekler/çıkarır (Ctrl ile aynı). Operasyon çemberi için.")
	host._wire(host._multi_btn)
	host._multi_btn.toggled.connect(func(on: bool) -> void:
		_hint(tr("Çoklu seçim %s. Operasyon için 1–3 kişi seç.") % tr("açık" if on else "kapalı")))
	host._grid = GridContainer.new()
	host._grid.columns = 5
	host._grid.add_theme_constant_override("h_separation", 6)
	host._grid.add_theme_constant_override("v_separation", 6)
	right.add_child(host._grid)
	# Mobilde grup sekmeleri, portre şeridi ve kişi bloğu TEK kaydırma sayfasında: parmakla her yer birlikte kayar.
	var page_parent: Control = right
	if host._mobile:
		_mobile_person_scroll = ScrollContainer.new()
		_mobile_person_scroll.name = "Kişiler sayfası"
		_mobile_person_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_mobile_person_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_mobile_person_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		right.add_child(_mobile_person_scroll)
		var page := VBoxContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.add_theme_constant_override("separation", 8)
		_mobile_person_scroll.add_child(page)
		page_parent = page
		host._grid.visible = false
		var group_row := HBoxContainer.new()
		group_row.add_theme_constant_override("separation", 4)
		page_parent.add_child(group_row)
		var group := ButtonGroup.new()
		for key in ["dynasty", "state", "power", "foreign"]:
			var tab := Button.new()
			tab.text = tr(MOBILE_GROUP_LABELS[key])
			tab.toggle_mode = true
			tab.button_group = group
			tab.theme_type_variation = "GhostButton"
			tab.custom_minimum_size = Vector2(44, 44)
			tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tab.pressed.connect(_set_mobile_group.bind(key))
			host._wire(tab)
			group_row.add_child(tab)
			_mobile_group_buttons[key] = tab
		var strip := HBoxContainer.new()
		strip.add_theme_constant_override("separation", 6)
		page_parent.add_child(strip)
		var left := _mobile_arrow(false)
		strip.add_child(left)
		var card_scroll := ScrollContainer.new()
		card_scroll.name = "Kişi şeridi"
		card_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		card_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		strip.add_child(card_scroll)
		_mobile_card_row = HBoxContainer.new()
		_mobile_card_row.add_theme_constant_override("separation", 8)
		card_scroll.add_child(_mobile_card_row)
		var right_arrow := _mobile_arrow(true)
		strip.add_child(right_arrow)
		left.pressed.connect(func() -> void: card_scroll.scroll_horizontal = maxi(0, card_scroll.scroll_horizontal - 220))
		right_arrow.pressed.connect(func() -> void: card_scroll.scroll_horizontal += 220)
		_set_mobile_group("dynasty")
	host._divan.build(right)
	selection_hint = Label.new()
	selection_hint.text = tr("Bir kişi seç. Sayıları göremezsin; yalnızca davranışlarından tahmin edebilirsin.")
	selection_hint.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	selection_hint.add_theme_font_size_override("font_size", host._fs(13))
	selection_hint.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var profile_parent: Control = page_parent
	profile_parent.add_child(selection_hint)
	selection_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	person_block = VBoxContainer.new()
	person_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	person_block.add_theme_constant_override("separation", 6 if host._mobile else 8)
	if host._mobile:
		profile_parent.add_child(person_block)
	else:
		# Transitional access while the person-file view is being built in the next slice.
		_legacy_popup = PopupPanel.new()
		_legacy_popup.name = "LegacyPersonActions"
		_legacy_popup.size = Vector2i(960, 700)
		_legacy_popup.add_child(person_block)
		host.add_child(_legacy_popup)

	var detail := PanelContainer.new()
	var detail_style := UIKit.box(Color(UIKit.PANEL, 0.85), Color(UIKit.GOLD_DIM, 0.3), 6, 8)
	if not host._mobile:
		detail_style.set_border_width_all(0)   # kenarı işlemeli çerçeve çizer; ikinci çizgi olmasın
		detail_style.content_margin_left = 16
		detail_style.content_margin_top = 14
		detail_style.content_margin_bottom = 14
	detail.add_theme_stylebox_override("panel", detail_style)
	person_block.add_child(detail)
	UIKit.ornament(detail, Color(UIKit.GOLD, 0.8), 18 if not host._mobile else 14, 1)
	var irow := HBoxContainer.new()
	irow.add_theme_constant_override("separation", 10)
	detail.add_child(irow)
	host._portrait_box = Control.new()
	host._portrait_box.custom_minimum_size = Vector2(112, 96) if not host._mobile else Vector2(88, 84)
	irow.add_child(host._portrait_box)
	var clear := Button.new()
	clear_button = clear
	clear.custom_minimum_size = Vector2(44 if host._mobile else 28, 44 if host._mobile else 28)
	clear.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	clear.theme_type_variation = "GhostButton"
	clear.tooltip_text = tr("Seçimi kaldır")
	clear.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	clear.draw.connect(func() -> void:
		var mid := clear.size / 2.0
		clear.draw_line(mid + Vector2(-5, -5), mid + Vector2(5, 5), UIKit.GOLD, 2.0, true)
		clear.draw_line(mid + Vector2(5, -5), mid + Vector2(-5, 5), UIKit.GOLD, 2.0, true))
	clear.pressed.connect(func() -> void: host._sel.clear(); _style_cards(); _update_info(); host._divan.refresh())
	host._wire(clear)
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
	host._info.add_theme_font_override("normal_font", UIKit.sans())
	host._info.add_theme_font_override("bold_font", UIKit.sans(680))
	host._info.add_theme_font_size_override("normal_font_size", host._fs(16 if host._mobile else 17))
	icol.add_child(host._info)
	# Kişinin özellikleri: küçük göstergeler (sayı yok; yalnızca oyuncunun bildiği kadar).
	host._traits = HFlowContainer.new()
	host._traits.add_theme_constant_override("h_separation", 6)
	host._traits.add_theme_constant_override("v_separation", 5)
	icol.add_child(host._traits)
	irow.add_child(clear)
	var ornament_row := HBoxContainer.new()
	ornament_row.name = "PersonDivider"
	ornament_row.add_theme_constant_override("separation", 8)
	ornament_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ornament_row.custom_minimum_size.y = 12
	if host._mobile:
		person_block.add_child(ornament_row)
	else:
		_attach_bottom_ornament(detail, ornament_row)
	var left_rule := ColorRect.new()
	left_rule.color = Color(UIKit.GOLD, 0.72)
	left_rule.custom_minimum_size = Vector2(48, 2)
	left_rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ornament_row.add_child(left_rule)
	ornament_row.add_child(host._header_symbol("lily", Vector2(20, 24), UIKit.GOLD, true))
	var right_rule := ColorRect.new()
	right_rule.color = left_rule.color
	right_rule.custom_minimum_size = Vector2(48, 2)
	right_rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ornament_row.add_child(right_rule)

	# Eylem paneli: tek çerçeve, başlıkta seçili kişi, eylemler amaca göre gruplu.
	var act_panel := PanelContainer.new()
	var act_style := UIKit.box(Color(UIKit.PANEL, 0.8), Color(UIKit.GOLD_DIM, 0.28), 8, 8)
	if not host._mobile:
		act_style.set_border_width_all(0)
		act_style.content_margin_top = 10
		act_style.content_margin_bottom = 8
		act_style.content_margin_left = 22
		act_style.content_margin_right = 20
	act_panel.add_theme_stylebox_override("panel", act_style)
	person_block.add_child(act_panel)
	UIKit.ornament(act_panel, Color(UIKit.GOLD, 0.8), 18 if not host._mobile else 14, 1)
	var av := VBoxContainer.new()
	av.add_theme_constant_override("separation", 3)
	act_panel.add_child(av)
	host._act_title = Label.new()
	host._act_title.add_theme_font_override("font", UIKit.serif())
	host._act_title.add_theme_font_size_override("font_size", host._fs(17 if host._mobile else 16))
	if not host._mobile:
		host._act_title.add_theme_constant_override("line_spacing", -6)
	host._act_title.add_theme_color_override("font_color", UIKit.GOLD if host._mobile else Color("e8dcc0"))
	if not host._mobile:
		host._act_title.add_theme_font_override("font", UIKit.caps())
	host._act_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	host._act_title.custom_minimum_size.y = 44 if host._mobile else 0
	av.add_child(host._act_title)
	var groups := [
		["KAZAN", [["summon", "Huzura Çağır"], ["promote", "Terfi"], ["bribe", "Gizli Ödeme"]]],
		["SÖZ VER", [["p_0", "Naiplik"], ["p_1", "Liman İhalesi"], ["p_2", "Dokunulmazlık"]]],
		["ÖĞREN", [["cross", "Doğrula"], ["investigate", "Araştır"], ["o_sor", "Soruşturma"]]],
		["EMRET", [["o_yaz", "Yazılı Emir"], ["o_soz", "Sözlü Emir"], ["o_ima", "İma"]]],
		["BASKI", [["blackmail", "Şantaj"], ["dismiss", "Görevden Al"]]],
		["OPERASYON", [["op_dikkat", "Dikkat Dağıt"], ["op_bol", "Muhalefeti Böl"], ["op_zayif", "Rakibi Zayıflat"], ["op_dus", "Birbirine Düşür"]]],
		["DEVLET", [["tax_raise", "Vergiyi Artır"], ["tax_relief", "Vergiyi Hafiflet"], ["austerity", "Kemer Sık"], ["incentive", "Teşvik Paketi"], ["appoint_loyal", "Sadık Ata"], ["appoint_merit", "Liyakatli Ata"], ["tender", "İhale Ver"], ["train_heir", "Veliahdı Yetiştir"], ["delegation", "Heyet Gönder"], ["region_management", "Bölge Yönetimi"], ["army_management", "Ordu Düzeni"]]],
		["KAMUOYU", [["king_speech", "Halka Konuş"], ["king_visit", "Saha Ziyareti"], ["king_ceremony", "Tören"], ["king_hide", "Gizlen"]]],
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
		"train_heir": func() -> void: host._act(func(id: String) -> String: return Sim.train_heir(id)),
		"delegation": func() -> void: host._act(func(id: String) -> String: return Sim.send_delegation(id)),
		"tax_raise": func() -> void: host._act(func(_id: String) -> String: return Sim.economy_policy("tax_raise")),
		"tax_relief": func() -> void: host._act(func(_id: String) -> String: return Sim.economy_policy("tax_relief")),
		"austerity": func() -> void: host._act(func(_id: String) -> String: return Sim.economy_policy("austerity")),
		"incentive": func() -> void: host._act(func(_id: String) -> String: return Sim.economy_policy("incentive")),
		"region_management": func() -> void: host._act(func(_id: String) -> String: return Sim.request_regional_decision()),
		"army_management": func() -> void:
			host._acted_week = Sim.week
			host._log(Sim.request_army_decision()),
		"king_speech": func() -> void: _public_action("speech"),
		"king_visit": func() -> void: _public_action("visit"),
		"king_ceremony": func() -> void: _public_action("ceremony"),
		"king_hide": func() -> void: _public_action("hide"),
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
		cb.text = UIKit.tr_upper(tr("Halk") if g[0] == "KAMUOYU" else tr(str(g[0])))
		cb.toggle_mode = true
		cb.button_group = cat_group
		cb.theme_type_variation = "GhostButton"
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.custom_minimum_size.y = 44 if host._mobile else 28
		cb.clip_text = false
		cb.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		cb.add_theme_font_override("font", UIKit.sans())
		cb.add_theme_font_size_override("font_size", host._fs(11 if not host._mobile else 15))
		if g[0] == "BASKI":
			for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
				cb.add_theme_color_override(c, UIKit.DANGER.lightened(0.15))
		var ctip: String = tr(CAT_TIPS[g[0]])
		cb.tooltip_text = ctip
		cb.mouse_entered.connect(func() -> void:
			if not TOUCH_SCROLL.dispatching_touch: _hint(ctip))
		cb.pressed.connect(_show_act_cat.bind(str(g[0])))
		host._wire(cb)
		cat_row.add_child(cb)
		host._cat_btns[g[0]] = cb
		var row: Control = VBoxContainer.new() if g[0] == "DEVLET" else HBoxContainer.new()
		row.add_theme_constant_override("separation", 4 if g[0] == "DEVLET" else 6)
		av.add_child(row)
		host._cat_rows[g[0]] = row
		for item_index in g[1].size():
			var item: Array = g[1][item_index]
			var button_row: Control = row
			if g[0] == "DEVLET":
				if item_index % 3 == 0:
					button_row = HBoxContainer.new()
					button_row.add_theme_constant_override("separation", 6)
					row.add_child(button_row)
				else:
					button_row = row.get_child(row.get_child_count() - 1)
			_add_btn(button_row, item[0], item[1], actions[item[0]])
			var btn := host._buttons[item[0]] as Button
			btn.add_theme_font_size_override("font_size", host._fs(13 if host._mobile else 12))
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
	hsep.visible = host._mobile
	host._hint_label = RichTextLabel.new()
	host._hint_label.bbcode_enabled = true
	host._hint_label.scroll_active = false
	host._hint_label.add_theme_color_override("default_color", UIKit.TEXT_DIM if host._mobile else UIKit.TEXT)
	host._hint_label.add_theme_font_override("normal_font", UIKit.sans())
	host._hint_label.add_theme_font_override("bold_font", UIKit.sans(680))
	host._hint_label.add_theme_font_size_override("normal_font_size", host._fs(15 if host._mobile else 13))
	host._hint_label.add_theme_font_size_override("bold_font_size", host._fs(15 if host._mobile else 13))
	host._hint_label.clip_contents = true
	host._hint_label.custom_minimum_size.y = 42 if not host._mobile else 54
	host._hint_label.text = tr(HINT_DEFAULT)
	if not host._mobile:
		_hint(tr(CAT_TIPS.get(host._act_cat, CAT_TIPS["KAZAN"])))
	av.add_child(host._hint_label)
	if not host._mobile:
		var report_view := VBoxContainer.new()
		report_view.name = "WeekAndReports"
		report_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
		report_view.add_theme_constant_override("separation", 10)
		right.add_child(report_view)
		host._report_box = VBoxContainer.new()
		host._report_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		host._report_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		host._report_box.add_theme_constant_override("separation", 10)
		report_view.add_child(host._report_box)
	else:
		var mobile_report_scroll := ScrollContainer.new()
		mobile_report_scroll.name = "Raporlar listesi"
		mobile_report_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		mobile_report_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		host._mobile_reports_page.add_child(mobile_report_scroll)
		host._report_box = VBoxContainer.new()
		host._report_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		host._report_box.add_theme_constant_override("separation", 4)
		mobile_report_scroll.add_child(host._report_box)


## Zambaklı ayraç panelin alt kenarına oturur (mockup): ayrı satır kaplamaz.
func _attach_bottom_ornament(panel: Control, ornament: Control) -> void:
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.top_level = false
	panel.add_child(holder)
	holder.add_child(ornament)
	var place := func() -> void:
		ornament.position = Vector2(panel.size.x * 0.12, panel.size.y - 12.0 - (holder.global_position.y - panel.global_position.y))
		ornament.size = Vector2(panel.size.x * 0.76, 24)
	panel.resized.connect(place)
	holder.resized.connect(place)
	place.call_deferred()


func _mobile_arrow(to_right: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(44, 44)
	button.theme_type_variation = "GhostButton"
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.draw.connect(func() -> void:
		var mid := button.size / 2.0
		var sign := 1.0 if to_right else -1.0
		button.draw_line(mid + Vector2(-4 * sign, -7), mid + Vector2(4 * sign, 0), UIKit.GOLD, 2.5, true)
		button.draw_line(mid + Vector2(4 * sign, 0), mid + Vector2(-4 * sign, 7), UIKit.GOLD, 2.5, true))
	host._wire(button)
	return button


func _set_mobile_group(key: String) -> void:
	_mobile_group = key
	for name in _mobile_group_buttons:
		(_mobile_group_buttons[name] as Button).set_pressed_no_signal(name == key)
	if _mobile_card_row == null:
		return
	for id in host._cards:
		var card: Control = host._cards[id]
		var destination: Node = _mobile_card_row if id in MOBILE_GROUPS[key] else host._grid
		if card.get_parent() != destination:
			if card.get_parent() != null:
				card.get_parent().remove_child(card)
			destination.add_child(card)


func _group_for_actor(id: String) -> String:
	var domain := str(Sim.actors[id].domain)
	return str(MOBILE_DOMAIN_GROUP.get(domain, "dynasty"))


func _role_for_actor(a) -> String:
	if a.id.begins_with("commander_"):
		return tr("Komutan")
	return tr("Vali") if a.id.begins_with("governor_") and Sim._governor_assigned(a.id) else (tr("Atanmamış") if a.id.begins_with("governor_") else tr(str(ROLE.get(a.domain, ""))))


func _show_act_cat(cat: String) -> void:
	host._act_cat = cat
	if not host._mobile and CAT_TIPS.has(cat):
		_hint(tr(CAT_TIPS[cat]))   # mockup: alan seçili sekmenin ne işe yaradığını söyler
	for k in host._cat_rows:
		(host._cat_rows[k] as Control).visible = k == cat
	for k in host._cat_btns:
		var button := host._cat_btns[k] as Button
		var active: bool = k == cat
		button.set_pressed_no_signal(active)   # koddan değişince ButtonGroup diğerini bırakmıyor
		var tone: Color = UIKit.DANGER.lightened(0.15) if k == "BASKI" else (UIKit.GOLD if active else UIKit.TEXT_DIM)
		button.add_theme_color_override("font_color", tone)
		button.add_theme_color_override("font_hover_color", UIKit.GOLD.lightened(0.2))
		button.add_theme_stylebox_override("normal", UIKit.box(Color(UIKit.GOLD, 0.09), Color(UIKit.GOLD, 0.7), 5, 4) if active else StyleBoxEmpty.new())
		button.add_theme_stylebox_override("hover", UIKit.box(Color(UIKit.GOLD, 0.14), Color(UIKit.GOLD, 0.55), 5, 4) if active else StyleBoxEmpty.new())
		button.add_theme_stylebox_override("pressed", UIKit.box(Color(UIKit.GOLD, 0.16), Color(UIKit.GOLD, 0.75), 5, 4) if active else StyleBoxEmpty.new())


func _public_action(action: String) -> void:
	host._acted_week = Sim.week
	host._log(Sim.public_action(action))


func _add_btn(parent: Node, key: String, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = tr(text)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size.y = 44 if host._mobile else 28
	b.pressed.connect(cb)
	if TIPS.has(key):
		var tip: String = tr(TIPS[key])
		b.tooltip_text = tip
		if ACTION_META.has(key):
			b.mouse_entered.connect(func() -> void:
				if not TOUCH_SCROLL.dispatching_touch: _preview(key))
			b.button_down.connect(_preview.bind(key))
		else:
			b.mouse_entered.connect(func() -> void:
				if not TOUCH_SCROLL.dispatching_touch: _hint(tip))
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
	"p_0": ["Söz: Naiplik", 1, 0.0, 0, 1],
	"p_1": ["Söz: Liman İhalesi", 1, 0.0, 0, 1],
	"p_2": ["Söz: Dokunulmazlık", 1, 0.0, 0, 1],
	"op_dikkat": ["Dikkat Dağıt", 2, 0.0, 1, 1],
	"op_bol": ["Muhalefeti Böl", 2, 0.0, 1, 1],
	"op_zayif": ["Rakibi Zayıflat", 2, 0.0, 1, 2],
	"op_dus": ["Birbirine Düşür", 2, 0.0, 1, 1],
	"appoint_loyal": ["Sadık Ata", 1, 0.0, 0, 0],
	"appoint_merit": ["Liyakatli Ata", 1, 0.0, 0, 0],
	"tender": ["İhale Ver", 1, 0.0, 0, 0],
	"train_heir": ["Veliahdı Yetiştir", 1, 0.0, 0, 0],
	"delegation": ["Heyet Gönder", 1, 0.0, 0, 0],
	"tax_raise": ["Vergiyi Artır", 1, 0.0, 0, 1],
	"tax_relief": ["Vergiyi Hafiflet", 1, 0.0, 0, 1],
	"austerity": ["Kemer Sık", 1, 0.0, 0, 2],
	"incentive": ["Teşvik Paketi", 1, 0.0, 0, 1],
	"region_management": ["Bölge Yönetimi", 1, 0.0, 0, 0],
	"army_management": ["Ordu Düzeni", 1, 0.0, 0, 1],
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
			note = tr("Çoklu seçimi aç ve tam iki kişi seç.")
		elif Sim.rival_wait(host._sel) > 0:
			var wait := Sim.rival_wait(host._sel)
			note = Loc.ntr("Bu çifti yakın zamanda denedin; %d hafta bekle.", wait) % wait
		else:
			note = tr("İkisi de güçlü ve hırslıysa daha çok kapışırlar. Başarısız olursa kimin yaptığını anlarlar.")
	elif key.begins_with("op_"):
		var n: int = host._sel.size()
		risk = clampi(risk + maxi(0, n - 2), 0, 2)
		note = tr("Önce çemberi kur: 1–3 kişi seç.") if n == 0 else tr("Çember büyüdükçe başarı da, sızıntı riski de artar.")
	elif id == "":
		note = tr("Önce bir kişi seç.")
	else:
		var a = Sim.actors[id]
		var tier := Sim.power_tier(a.power)
		match key:
			"tender":
				if id != "halden":
					note = tr("Yalnızca Sarne'ye ihale verilebilir.")
				elif Sim.tender_wait() > 0:
					note = tr("İhale komisyonu yeni dosyayı henüz açmıyor.")
			"train_heir":
				if id != "julian":
					note = tr("Yalnızca Julian için kullanılabilir.")
				elif Sim.heir_train_wait() > 0:
					note = tr("Julian yeni derslerine hazırlanıyor.")
			"delegation":
				if not Sim.FOREIGN_ENVOYS.has(id):
					note = tr("Claire, Viktor ya da Lucien seçilmeli.")
				elif Sim.delegation_wait() > 0:
					note = tr("Elçilikler önceki heyetin cevabını bekliyor.")
			"appoint_loyal", "appoint_merit":
				if not Sim.INSTITUTION_HEADS.has(id):
					note = tr("Yalnızca kurum başkanları için kullanılabilir.")
				elif Sim.appoint_wait(id) > 0:
					note = tr("Bu kurumda yeni atama için beklemelisin.")
			"summon":
				var wait := Sim.summon_wait(id)
				if wait > 0:
					note = Loc.ntr("%s yeniden çağırmak için %d hafta beklemelisin.", wait) % [Sim.ek(a.display_name, "i"), wait]
			"promote":
				if tier == 3:
					risk = 2
					note = tr("%s zaten vazgeçilmez; terfi onu daha da tehlikeli yapar.") % a.display_name
			"bribe":
				if Sim.private_wealth < Sim.BRIBE_COST:
					note = tr("Servetin yetmiyor.")
			"investigate":
				if a.known_weak and a.known_red:
					note = tr("Onun hakkında öğrenilecek bir şey kalmadı.")
			"blackmail":
				if not a.known_weak:
					note = tr("Önce zayıf noktasını öğren (Araştır).")
			"o_yaz", "o_soz", "o_ima":
				if Sim.street_anger >= 40.0:
					risk = maxi(risk, 2)
					note = tr("Sokak bastırmaya alışıyor: her emir daha az işe yarıyor, öfke birikiyor.")
			"dismiss":
				risk = tier - 1
				note = ["", tr("Sessizce gidebilir."), tr("Gücü var; karşılık verebilir."), tr("Vazgeçilmez birini düşürmek ağır bir karşı saldırı getirebilir.")][tier]
			"p_0", "p_1", "p_2":
				if Sim.prize_taken(Sim.PRIZES[int(key.substr(2))]):
					note = tr("Bu ödül zaten birine verildi.")
		if a.moved:
			note = tr("%s artık sana karşı; eylemlerin işe yaramayabilir.") % a.display_name
	if Sim.mesai < int(m[1]):
		note = tr("Mesain yetmiyor.")
	if note == "":
		# Bağlam yoksa uzun açıklamanın ilk cümlesi (tamamı ipucu balonunda).
		var desc: String = str(tr(TIPS[key])).split("\n")[1]
		note = desc.split(". ")[0].trim_suffix(".") + "."
	if key in ["appoint_loyal", "appoint_merit", "tender", "train_heir", "delegation"]:
		host._hint_label.text = "[color=#d6b25e][b]%s[/b][/color]   [color=#9a958a]%s[/color]\n%s" % [tr(str(m[0])), tr("1 mesai"), note]
		return
	var cost := Loc.ntr("%d mesai", int(m[1])) % int(m[1])
	var wealth: float = Sim.BRIBE_COST if float(m[2]) < 0.0 else float(m[2])
	if wealth > 0.0:
		cost += " · " + (tr("%d servet") % int(wealth))
	var trace := int(m[3])
	var tc: String = [UIKit.OK, UIKit.GOLD, UIKit.AMBER, UIKit.DANGER][trace].to_html(false)
	var rc: String = [UIKit.OK, UIKit.AMBER, UIKit.DANGER][risk].to_html(false)
	host._hint_label.text = "[color=#d6b25e][b]%s[/b][/color]   [color=#9a958a]%s  ·  [/color][color=#%s]%s[/color][color=#9a958a]  ·  %s [/color][color=#%s]%s[/color]\n%s" % [
		tr(str(m[0])), cost, tc, tr(TRACE_NAMES[trace]), tr("tahmini risk"), rc, tr(RISK_NAMES[risk]), note]


func _hint(text: String) -> void:
	if host._hint_label == null:
		return
	var lines := text.split("\n", false, 1)
	if lines.size() == 2:
		host._hint_label.text = ("[color=#d6b25e][b]%s[/b][/color]\n%s" if host._mobile else "[color=#f3ead2][b]%s[/b][/color]\n%s") % [lines[0], lines[1]]
	else:
		host._hint_label.text = text

func _rebuild_cards() -> void:
	var sig := ""
	for a in Sim.actors.values():
		sig += "%s%d," % [a.id, 1 if a.moved else 0]
	if sig != host._cards_sig:
		host._cards_sig = sig
		for c in host._cards.values():
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
		if host._mobile:
			_set_mobile_group(_group_for_actor(host._sel[0]) if not host._sel.is_empty() else _mobile_group)
	_style_cards()
	if host._mobile:
		_set_mobile_group(_mobile_group)


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
	var compact_governor: bool = str(a.id).begins_with("governor_")
	var compact_state_card: bool = compact_governor or str(a.id).begins_with("commander_")
	card.custom_minimum_size = Vector2(82, 98) if compact_state_card else (Vector2(104, 96) if not host._mobile else Vector2(150, 132))
	card.clip_contents = true
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.tooltip_text = "%s\n%s" % [a.display_name, a.title]
	var compact_body: VBoxContainer
	if compact_state_card:
		compact_body = VBoxContainer.new()
		compact_body.add_theme_constant_override("separation", 0)
		card.add_child(compact_body)
	var card_art: Control = host._initial_art(a.id, Vector2(72, 66) if compact_state_card else (Vector2(100, 86) if not host._mobile else Vector2(130, 120)), 28 if compact_state_card else 36)
	if compact_state_card:
		compact_body.add_child(card_art)
	else:
		card.add_child(card_art)
	var fade := TextureRect.new()
	fade.texture = _card_fade()
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.anchor_top = 0.42
	fade.anchor_right = 1.0
	fade.anchor_bottom = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not compact_state_card:
		card_art.add_child(fade)
	var v := VBoxContainer.new()
	card.set_meta("card_labels", v)
	v.add_theme_constant_override("separation", -2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if compact_state_card:
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.custom_minimum_size.y = 31
		compact_body.add_child(v)
	else:
		v.anchor_top = 1.0
		v.anchor_right = 1.0
		v.anchor_bottom = 1.0
		v.offset_top = -40 if not host._mobile else -52
		v.offset_bottom = -3
		card_art.add_child(v)
	var n := Label.new()
	n.text = host._short_name(a.display_name)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_theme_font_override("font", UIKit.serif())
	n.add_theme_font_size_override("font_size", host._fs(15 if compact_state_card else 18) if host._mobile else (13 if compact_state_card else 17))
	n.add_theme_color_override("font_color", Color("f3ead2"))
	n.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	n.add_theme_constant_override("shadow_outline_size", 4)
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(n)
	var r := Label.new()
	r.text = UIKit.tr_upper(tr("Düşman") if a.moved else _role_for_actor(a))
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	r.add_theme_font_override("font", UIKit.caps())
	r.add_theme_font_size_override("font_size", host._fs(15 if compact_state_card else 12) if host._mobile else (11 if compact_state_card else host._fs(11)))
	r.add_theme_color_override("font_color", Color("ff8a7a") if a.moved else Color(UIKit.GOLD, 1.0))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(r)
	card.set_meta("id", a.id)
	card.set_meta("role", r)
	if not host._mobile:
		var badge := Control.new()
		badge.custom_minimum_size = Vector2(10, 10)
		badge.position = Vector2(5, 5)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.draw.connect(func() -> void: badge.draw_circle(Vector2(5, 5), 4, badge.get_meta("color", UIKit.GOLD)))
		badge.visible = false
		card.add_child(badge)
		card.set_meta("badge", badge)
	card.gui_input.connect(_on_card_input.bind(a.id))
	# Üzerine gelince portre çerçevesinin içinde hafifçe yakınlaşır.
	var portrait_img: Control = card_art.get_child(0)
	card.mouse_entered.connect(func() -> void:
		if TOUCH_SCROLL.dispatching_touch: return
		Sfx.play("hover", -14.0)
		_style_cards(a.id)
		portrait_img.pivot_offset = portrait_img.size / 2.0
		portrait_img.create_tween().tween_property(portrait_img, "scale", Vector2(1.1, 1.1), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT))
	card.mouse_exited.connect(func() -> void:
		if TOUCH_SCROLL.dispatching_touch: return
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
	if not mb.ctrl_pressed and not mb.shift_pressed and not host._multi_btn.button_pressed:
		host._open_person_file(id)
	if not host._mobile:
		if host._divan.opened:
			host._divan.close()
		else:
			host._divan.refresh()


func _style_cards(hover_id := "") -> void:
	for id in host._cards:
		var card: PanelContainer = host._cards[id]
		var compact_state_card: bool = str(id).begins_with("governor_") or str(id).begins_with("commander_")
		if host._mobile:
			var compact: bool = not host._sel.is_empty()
			if compact_state_card:
				card.custom_minimum_size = Vector2(150, 132)
				var body := card.get_child(0) as Control
				var portrait := body.get_child(0) as Control
				portrait.custom_minimum_size = Vector2(120, 88)
			else:
				card.custom_minimum_size = Vector2(140, 112) if compact else Vector2(150, 132)
				var portrait := card.get_child(0) as Control
				portrait.custom_minimum_size = Vector2(120, 100) if compact else Vector2(130, 120)
				var labels := card.get_meta("card_labels") as VBoxContainer
				labels.offset_top = -48 if compact else -52
		var a = Sim.actors.get(id)
		var selected: bool = host._sel.has(id)
		var primary: bool = not host._sel.is_empty() and host._sel[0] == id
		var border := Color(UIKit.GOLD_DIM, 0.35) if host._mobile else Color(UIKit.GOLD, 0.62)
		var bg := Color(UIKit.PANEL, 0.9)
		if a != null and a.moved:
			border = UIKit.DANGER
		elif a != null:
			# Şüphe göstergesi: yalnızca görülen alametlerden (docs/design/darbe_asamalari.md).
			var lvl := Sim.suspicion_level(id)
			var rl := card.get_meta("role", null) as Label
			if rl != null:
				var role := _role_for_actor(a)
				var external_lvl := Sim.external_suspicion_level(id) if Sim.FOREIGN_ENVOYS.has(id) else 0
				var external_hint := external_lvl >= 2
				rl.text = UIKit.tr_upper(tr("Dış temas şüphesi") if external_hint else (role if lvl < 2 else "%s · %s" % [role, Sim.SUSPICION_NAMES[lvl]]))
				rl.add_theme_color_override("font_color", UIKit.AMBER.lightened(0.15) if external_hint else [UIKit.GOLD, UIKit.GOLD, UIKit.AMBER.lightened(0.15), Color("ff8a7a")][lvl])
			if lvl >= 2:
				border = Color(UIKit.AMBER if lvl == 2 else UIKit.DANGER, 0.7)
		if hover_id == id:
			border = UIKit.GOLD
			bg = Color(UIKit.PANEL_HI, 0.98)
		if selected:
			border = Color("ffe08a") if primary else UIKit.GOLD
			bg = Color("2d2616")
		card.add_theme_stylebox_override("panel", UIKit.box(bg, border, 6, 3, 2 if selected else 1))


const PERSON_ACTIONS := ["summon", "promote", "bribe", "p_0", "p_1", "p_2", "cross", "investigate", "o_sor", "o_yaz", "o_soz", "o_ima", "blackmail", "dismiss", "appoint_loyal", "appoint_merit", "tender", "train_heir", "delegation", "tax_raise", "tax_relief", "austerity", "incentive", "region_management", "army_management"]
const OP_ACTIONS := ["op_dikkat", "op_bol", "op_zayif", "op_dus"]


## Eylem düğmelerinin kullanılabilirliği: kişi seçili mi, mesai/servet yetiyor mu.
func _update_action_states() -> void:
	if host._act_title == null:
		return
	var id: String = host._selected_primary()
	var busy := Sim.ended or Sim.actors.is_empty()
	if id == "":
		host._act_title.text = tr("EYLEMLER   ·   önce bir kişi seç")
	else:
		host._act_title.text = tr("EYLEMLER   ·   %s") % Sim.actors[id].display_name
		if host._sel.size() > 1:
			host._act_title.text += tr("  +%d kişi") % (host._sel.size() - 1)
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
			if k == "train_heir" and id != "" and (id != "julian" or Sim.actors[id].moved or Sim.heir_train_wait() > 0):
				off = true
			if k == "delegation" and id != "" and (not Sim.FOREIGN_ENVOYS.has(id) or Sim.actors[id].moved or Sim.delegation_wait() > 0):
				off = true
			if k == "army_management":
				off = busy or Sim.mesai < 1 or not Sim.pending.is_empty()
			b.disabled = off
	for k in OP_ACTIONS:
		var b := host._buttons.get(k) as Button
		if b:
			b.disabled = busy or host._sel.is_empty() or host._sel.size() > 3 or Sim.mesai < 2
			if k == "op_dus":
				b.disabled = busy or host._sel.size() != 2 or Sim.mesai < 2 or Sim.rival_wait(host._sel) > 0


func _update_info() -> void:
	if host._mobile and host._sel.size() == 1 and Sim.actors.has(host._sel[0]):
		_set_mobile_group(_group_for_actor(host._sel[0]))
	_update_action_states()
	host._info.clear()
	for c in host._portrait_box.get_children():
		c.queue_free()
	for c in host._traits.get_children():
		host._traits.remove_child(c)
		c.queue_free()
	var id: String = host._selected_primary()
	host._portrait_box.visible = id != ""
	selection_hint.visible = id == ""
	person_block.visible = id != ""
	if id == "":
		return
	var a = Sim.actors[id]
	var art_size := Vector2(112, 96) if not host._mobile else Vector2(88, 84)
	var art: Control = host._initial_art(a.id, art_size, 38)
	art.size = art_size
	art.position = Vector2.ZERO
	host._portrait_box.add_child(art)
	# Portre: tek ince altın kenar (panelin işlemeli çerçevesiyle üst üste binmesin).
	var edge := Panel.new()
	var es := StyleBoxFlat.new()
	es.draw_center = false
	es.border_color = Color(UIKit.GOLD, 0.7)
	es.set_border_width_all(1)
	edge.add_theme_stylebox_override("panel", es)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	edge.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.add_child(edge)
	host._info.append_text("[b][font_size=%d]%s[/font_size][/b]  [color=#cfc6b0][font_size=%d]%s[/font_size][/color]" % [host._fs(20 if not host._mobile else 20), a.display_name, host._fs(14 if not host._mobile else 16), a.title])
	# Güç: üç kademe (eskiden metinle verilen bilgi; fazlası değil).
	var level := Sim.power_tier(a.power)
	var lvl_name: String = Sim.POWER_TIER_NAMES[level]
	host._traits.add_child(_trait(tr("Güç · ") + tr(lvl_name), UIKit.DANGER if level == 3 else UIKit.GOLD, level, 3,
		tr("Güç merkezi olarak ne kadar ağırlığı var. Vazgeçilmez olanlar tehlikelidir.")))
	if id == "halden":
		var influence := Sim.halden_influence_band()
		host._traits.add_child(_trait(tr("Nüfuz · ") + tr(influence), UIKit.AMBER, -1, 0,
			tr("Sarne'nin anlattığı şirket ağı; gerçek sınırları daha geniş olabilir.")))
		var mood := Sim.halden_mood()
		host._traits.add_child(_trait(tr("Medya · ") + tr(mood), UIKit.DANGER if mood == "düşmanca" else UIKit.GOLD,
			-1, 0, tr("Gazete ve kanalının saraya karşı tutumu.")))
	if id == "julian":
		host._traits.add_child(_trait(tr("Olgunluk · ") + tr(Sim.heir_maturity_band()), UIKit.GOLD, -1, 0,
			tr("Veliahdın sarayda ve halkın önünde kendine yer bulma hâli.")))
	if a.moved:
		host._traits.add_child(_trait(tr("Düşman"), UIKit.DANGER, -1, 0, tr("Sana karşı fiilen harekete geçti.")))
	elif a.insider:
		var sl := Sim.suspicion_level(a.id)
		host._traits.add_child(_trait(tr("Tavır · ") + tr(str(Sim.SUSPICION_NAMES[sl])), [UIKit.OK, UIKit.GOLD, UIKit.AMBER, UIKit.DANGER][sl], sl, 3, _signs_tip(a)))
	if a.obligation >= 8.0:
		host._traits.add_child(_trait(tr("Karşılık bekliyor"), Color("d9963e"), -1, 0, tr("Ona verdiklerinin karşılığını bekliyor.")))
	var dim := Color(UIKit.TEXT_DIM, 0.8)
	host._traits.add_child(_trait(tr("Zayıf nokta: ") + (a.weak_point if a.known_weak else "?"), UIKit.DANGER if a.known_weak else dim, -1, 0,
		tr("Biliniyorsa şantaj mümkün. 'Araştır' ile öğrenilebilir.") if not a.known_weak else tr("Şantaj için kullanılabilir.")))
	host._traits.add_child(_trait(tr("Kırmızı çizgi: ") + (tr(a.red_line) if a.known_red else "?"), Color("d9963e") if a.known_red else dim, -1, 0,
		tr("Bu çizgiyi aşarsan affetmez.")))
	var k: Dictionary = Sim.karne.get(a.id, {"ok": 0, "bad": 0})
	if int(k["ok"]) + int(k["bad"]) > 0:
		var trust_col := UIKit.OK if int(k["ok"]) >= int(k["bad"]) else UIKit.DANGER
		host._traits.add_child(_trait(tr("Doğrulama: %d örtüştü · %d çelişti") % [k["ok"], k["bad"]], trust_col, -1, 0,
			tr("Raporlarının başka kaynaklarla karşılaştırılması.")))
	for p in Sim.active_promises_of(a.id):
		host._traits.add_child(_trait(tr("Söz: %s · hafta %d") % [tr(str(p["prize"])), p["due"]], Color("d9b359"), -1, 0, tr("Ona verdiğin söz ve vadesi.")))
	if host._sel.size() > 1:
		host._traits.add_child(_trait(tr("%d kişi seçili · operasyon çemberi") % host._sel.size(), UIKit.GOLD, -1, 0, ""))


## Tavır göstergesinin ipucu: son haftalarda görülen alametler.
func _signs_tip(a) -> String:
	var lines: Array[String] = []
	for g: Dictionary in a.signs:
		if int(g["w"]) > Sim.week - Sim.PLOT_SUS_WINDOW:
			var text := str(g.get("text_en", g["text"])) if Loc.lang == "en" else str(g["text"])
			lines.append(tr("Hafta %d — %s") % [int(g["w"]), text])
	if lines.is_empty():
		return tr("Son haftalarda hakkında bir alamet görülmedi.\nDarbeyi yalnızca ordu ya da hanedan başlatabilir; ama herkes komploya katılabilir.")
	lines.reverse()
	return tr("Son alametler:\n%s\n\nAlametlerin bir kısmı dedikodudur. Huzura Çağır ile yoklayabilirsin.") % "\n".join(lines.slice(0, 5))


## Kişi göstergesi: renkli nokta ya da kademe noktaları + kısa metin.
func _trait(text: String, col: Color, filled := -1, total := 0, tip := "") -> Control:
	var chip := PanelContainer.new()
	var sb := UIKit.box(Color(col, 0.12), Color(col, 0.5), 6, 8 if host._mobile else 7)
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	chip.add_theme_stylebox_override("panel", sb)
	chip.tooltip_text = tip
	chip.mouse_filter = Control.MOUSE_FILTER_PASS if tip != "" else Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(row)
	if filled >= 0 and not host._mobile:
		for i in maxi(filled, 1):
			row.add_child(_trait_mark(col, true, true))
	else:
		var n := total if filled >= 0 else 1
		for i in n:
			row.add_child(_trait_mark(col, filled >= 0, filled < 0 or i < filled))
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", UIKit.sans())
	l.add_theme_font_size_override("font_size", host._fs(15 if host._mobile else 12))
	l.add_theme_color_override("font_color", (col.lightened(0.25) if col.s > 0.1 else col) if host._mobile else Color("ece3cc"))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	return chip


func _trait_mark(col: Color, star: bool, filled: bool) -> Control:
	var mark := Control.new()
	mark.custom_minimum_size = Vector2(13, 13)
	mark.rotation = PI / 4.0 if Sfx.colorblind_mode and not star else 0.0
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.draw.connect(func() -> void:
		var center := mark.size / 2.0
		var points := PackedVector2Array()
		if star:
			for i in 8:
				var angle: float = -PI / 2.0 + float(i) * PI / 4.0
				var radius: float = mark.size.x * (0.5 if i % 2 == 0 else 0.14)
				points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		else:
			points = PackedVector2Array([center + Vector2(0, -5), center + Vector2(5, 0), center + Vector2(0, 5), center + Vector2(-5, 0)])
		if filled:
			mark.draw_colored_polygon(points, col)
		else:
			points.append(points[0])
			mark.draw_polyline(points, Color(col, 0.55), 1.2, true))
	return mark


## Haber şeridi önceliği: kriz ve alametler önce, aktör hamleleri en sonda (özet bölümünde zaten görünür).


func _action_tip(key: String) -> String:
	return tr(TIPS[key])
