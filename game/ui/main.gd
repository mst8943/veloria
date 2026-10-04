extends Control
## Saray Masası: kararlar, raporlar, kişiler, eylemler. Ham sayılar bilerek gösterilmez.

const UIKit := preload("res://game/ui/ui_kit.gd")
const ATMOS_SHADER := preload("res://game/ui/atmosphere.gdshader")
const CINEMA := preload("res://game/ui/cinema.gd")
const SHIMMER_SHADER := preload("res://game/ui/shimmer.gdshader")
const TRUTH_CHART := preload("res://game/ui/truth_chart.gd")

const ROLE := {"army": "Ordu", "intel": "İstihbarat", "economy": "Maliye", "media": "Medya", "press": "Basın",
	"gate": "Saray", "royal": "Hanedan", "opposition": "Muhalefet", "court": "Yargı"}

const TIPS := {
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
	"leak": "Sızdır (1 mesai)\nBir dosyayı basına verir; ortak bilgi artar. Herkesin bildiği şey en tehlikelisidir.",
	"hush": "Bastır (1 mesai)\nDedikoduyu düşürür ama kanıtın kopyaları durur.",
	"destroy": "Kanıtı Yok Et (1 mesai)\nKopyalar bitince gerçekten silinir; girişim fark edilebilir.",
}

## Emeği geçenler ve lisans bildirimleri (Godot MIT ve EB Garamond OFL bildirimi dağıtımda zorunludur).
const CREDITS := """[b][font_size=30][color=#d6b25e]VELORIA[/color][/font_size][/b]
[color=gray]Reaktif bir siyaset ve iktidar simülasyonu[/color]

[b]Yapım[/b]
Mesut Canturk

[b]Tasarım ve geliştirme desteği[/b]
Claude (Anthropic)

[b]Görseller[/b]
Yapay zekâ ile üretilmiş özgün görseller. Tüm karakterler ve kurumlar kurgusaldır; gerçek kişi ve kurumlarla benzerlik tesadüftür.

[b]Yazı tipi[/b]
EB Garamond — Copyright 2017 The EB Garamond Project Authors (github.com/octaviopardo/EBGaramond12).
SIL Open Font License 1.1 altında kullanılmıştır (lisans metni oyun dosyalarında: game/fonts/OFL.txt).

[b]Oyun motoru[/b]
Bu oyun Godot Engine ile yapılmıştır ve aşağıdaki lisans altında kullanılmaktadır:

[color=gray][font_size=13]Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Portions of this software are copyright © The FreeType Project (www.freetype.org). All rights reserved.[/font_size][/color]"""

## İlk haftalarda yeni oyuncuya kısa yol gösterme notları (hafta -> metin).
const ADVICE := {
	1: "Majesteleri, bu masada sayılar yoktur, insanlar vardır. Aşağıdaki kartlar kararınızı bekliyor; her karar, emir ve operasyon sınırlı mesainizden harcar. Raporları da okuyun, ama hepsine inanmayın.",
	2: "Bir kişiyi seçip 'Doğrula' derseniz raporunu başka kaynaklarla karşılaştırırım. Kimin sizi süslediğini, kimin gerçeği söylediğini zamanla görürsünüz.",
	3: "Kararları ertelemek de bir karardır: iki hafta sonra kendi kendine, çoğu zaman en kötü biçimde çözülür.",
	4: "Terfi ve gizli ödeme sadakat getirir. Ama terfi ettirdiğiniz kişi güçlenir, para ise iz bırakır. İzler 'Dosyalar' sekmesinde birikir.",
	6: "Birini gerçekten kontrol etmek istiyorsanız önce 'Araştır' ile zayıf noktasını öğrenin. Şantaj güçlüdür, ama geri tepebilir.",
	8: "Bir güç merkezi fazla büyüyorsa rakibini güçlendirin. Kimse sizi tek başına deviremeyecek kadar zayıf kalmalı.",
	12: "İlk haftaların sessizliği bitiyor. Artık bir koalisyon sizi devirebilir. Raporlar birbirine benzemeye başlarsa, kimsenin size gerçeği söylemediğini bilin.",
}

var _stage: Control
var _header_week: Label
var _header_progress: ProgressBar
var _header_mesai: Label
var _header_wealth: Label
var _headline: Label
var _tabs: TabContainer
var _scroll: ScrollContainer
var _agenda: VBoxContainer
var _journal: RichTextLabel
var _fact_list: ItemList
var _grid: GridContainer
var _info: RichTextLabel
var _portrait_box: Control
var _toast: Label
var _buttons: Dictionary = {}
var _decision_cards: Array[Control] = []
var _decision_buttons: Array[Button] = []
var _end_btn: Button
var _fact_ids: Array[String] = []
var _cards: Dictionary = {}
var _cards_sig := ""
var _sel: Array[String] = []
var _icons: Dictionary = {}
var _menu: Control
var _menu_bg: Control
var _menu_items: Array[Control] = []
var _end_overlay: Control
var _end_text: RichTextLabel
var _end_bg: TextureRect
var _toast_tween: Tween
var _fx: CanvasLayer
var _curtain: ColorRect
var _curtain_title: Label
var _curtain_sub: Label
var _mobile := false
var _curtain_img: TextureRect
var _curtain_skip := false
var _cinema: Control
var _end_chart: Control
var _modal: Control
var _modal_text: RichTextLabel
var _modal_yes: Button
var _modal_close: Button
var _modal_cb := Callable()
var _promise_list: RichTextLabel
var _multi_btn: Button
var _hint_label: RichTextLabel
const HINT_DEFAULT := "[color=#8f7a45]Bir eylemin üzerine gel ya da dokun: ne yaptığını ve bedelini burada görürsün.[/color]"
var _busy := false
var _instant := false
var _reveal := true
var _last_mesai := -1
var _last_wealth := -1


func _ready() -> void:
	_mobile = OS.has_feature("mobile") or ProjectSettings.get_setting("veloria/dev_mobile", false) \
		or "--mobile" in OS.get_cmdline_user_args()
	if _mobile:
		get_tree().root.content_scale_size = Vector2i(1067, 600)
	theme = UIKit.build_theme(_mobile)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	Sim.week_advanced.connect(_on_week)
	Sim.news.connect(_on_news)
	Sim.changed.connect(_refresh)
	Sim.game_ended.connect(_on_end)
	_build_ui()
	_build_fx()
	var dev_run: bool = "--autoplay" in OS.get_cmdline_user_args() or ProjectSettings.get_setting("veloria/dev_autostart", false)
	if dev_run:
		Sim.record_chronicle = false   # test/geliştirme oyunları arşive yazılmaz
		Sim.autosave = false           # ve oyuncunun kaydına dokunmaz
	if "--autoplay" in OS.get_cmdline_user_args():
		_instant = true
		_start_new()
		_autoplay()
	elif ProjectSettings.get_setting("veloria/dev_autostart", false):
		_instant = true
		_start_new()
		for i in int(ProjectSettings.get_setting("veloria/dev_skip_weeks", 0)):
			Sim.end_week()
		if ProjectSettings.get_setting("veloria/dev_end", false):
			while not Sim.ended:
				Sim.end_week()
			_instant = false
			_on_end(Sim.record)
			return
		_instant = false
		Sfx.start_music()
		_tabs.current_tab = clampi(int(ProjectSettings.get_setting("veloria/dev_tab", 0)), 0, _tabs.get_tab_count() - 1)
		var dev_ev := str(ProjectSettings.get_setting("veloria/dev_event", ""))
		for e in Sim._events:
			if e["id"] == dev_ev:
				Sim.pending.insert(0, {"event": e, "age": 0})
				_refresh()
		var ds := str(ProjectSettings.get_setting("veloria/dev_select", ""))
		if ds != "" and Sim.actors.has(ds):
			_sel = [ds]
			_style_cards()
			_update_info()
		if ProjectSettings.get_setting("veloria/dev_press_end", false):
			await get_tree().create_timer(6.0).timeout
			_end_week_pressed()
		if ProjectSettings.get_setting("veloria/dev_choose", false) and not _decision_cards.is_empty():
			await get_tree().create_timer(6.0).timeout
			_choose(0, 0)
	else:
		_show_menu()
		Sfx.start_music()
		if ProjectSettings.get_setting("veloria/dev_intro", false):
			Sim.record_chronicle = false
			Sim.autosave = false
			_start_new()
		match str(ProjectSettings.get_setting("veloria/dev_modal", "")):
			"about":
				_show_modal(CREDITS)
			"chronicle":
				_show_chronicle()


## Kısayollar: F11 tam ekran, Esc menü/pencere kapat, Boşluk haftayı bitir, Ctrl+S kaydet.
func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	var in_game := not Sim.actors.is_empty() and not Sim.ended
	match k.keycode:
		KEY_F11:
			Sfx.set_fullscreen(not Sfx.fullscreen)
			Sfx.save_settings()
		KEY_ESCAPE:
			if _modal.visible:
				_modal.hide()
			elif _menu.visible and in_game:
				_hide_menu()
			elif not _menu.visible and not _end_overlay.visible:
				_show_menu()
		KEY_SPACE:
			if in_game and not _menu.visible and not _end_overlay.visible:
				_end_week_pressed()
		KEY_S:
			if k.ctrl_pressed and in_game:
				_on_save()
		_:
			return
	get_viewport().set_input_as_handled()


func _fast() -> bool:
	return _instant or Sfx.short_fx


## Mobilde yazılar büyür (yatay telefon: ~1067x600 taban).
func _fs(n: int) -> int:
	return int(round(n * 1.22)) if _mobile else n


# ---------------------------------------------------------------- Kurulum

func _build_ui() -> void:
	_stage = Control.new()
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)

	var bg_tex := _art("res://art/bg_desk.png")
	if bg_tex:
		var bg := TextureRect.new()
		bg.texture = bg_tex
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		_stage.add_child(bg)
		# Masa nefes alır gibi çok yavaş yakınlaşıp uzaklaşır.
		bg.resized.connect(func() -> void: bg.pivot_offset = bg.size / 2.0)
		var breathe := bg.create_tween().set_loops()
		breathe.tween_property(bg, "scale", Vector2(1.05, 1.05), 28.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		breathe.tween_property(bg, "scale", Vector2.ONE, 28.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var dim := ColorRect.new()
		dim.color = Color(0.03, 0.02, 0.04, 0.7)
		dim.set_anchors_preset(Control.PRESET_FULL_RECT)
		_stage.add_child(dim)
	else:
		var bgc := ColorRect.new()
		bgc.color = UIKit.BG
		bgc.set_anchors_preset(Control.PRESET_FULL_RECT)
		_stage.add_child(bgc)
	var dust := UIKit.dust(Vector2(1600, 900), 30, 0.22)
	_stage.add_child(dust)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	_stage.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	_build_header(root)

	_headline = Label.new()
	_headline.add_theme_color_override("font_color", Color("ffb15e"))
	_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_headline.custom_minimum_size.y = 22
	root.add_child(_headline)

	var cols := HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 14)
	root.add_child(cols)

	# Sol: sekmeler
	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_stretch_ratio = 1.45
	cols.add_child(_tabs)
	_scroll = ScrollContainer.new()
	_scroll.name = "Gündem"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tabs.add_child(_scroll)
	_agenda = VBoxContainer.new()
	_agenda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_agenda.add_theme_constant_override("separation", 10)
	_scroll.add_child(_agenda)
	var files := VBoxContainer.new()
	files.name = "Dosyalar"
	_tabs.add_child(files)
	_fact_list = ItemList.new()
	_fact_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	files.add_child(_fact_list)
	var frow := HBoxContainer.new()
	files.add_child(frow)
	_add_btn(frow, "leak", "Sızdır", func() -> void: _fact_act("leak"))
	_add_btn(frow, "hush", "Bastır", func() -> void: _fact_act("hush"))
	_add_btn(frow, "destroy", "Kanıtı Yok Et", func() -> void: _fact_act("destroy"))
	files.add_child(_caption("SÖZ DEFTERİ"))
	_promise_list = RichTextLabel.new()
	_promise_list.bbcode_enabled = true
	_promise_list.custom_minimum_size.y = 130
	files.add_child(_promise_list)
	_journal = RichTextLabel.new()
	_journal.name = "Günlük"
	_journal.bbcode_enabled = true
	_journal.scroll_following = true
	_tabs.add_child(_journal)
	_tabs.tab_changed.connect(func(_i: int) -> void: Sfx.play("paper", -10.0))
	var tab_icons := ["rapor", "dosya", "gunluk"]
	for i in tab_icons.size():
		var ti := _art("res://art/icons/%s.png" % tab_icons[i])
		if ti:
			_tabs.set_tab_icon(i, ti)
	_tabs.add_theme_constant_override("icon_max_width", 20)

	# Sağ: kişiler ve eylemler
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	if _mobile:
		# Mobil: kişiler ve eylemler ayrı bir sekme (yatay telefonda iki sütun sığmaz).
		var saray := ScrollContainer.new()
		saray.name = "Saray"
		saray.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_tabs.add_child(saray)
		_tabs.move_child(saray, 1)
		saray.add_child(right)
	else:
		cols.add_child(right)
	var cap_row := HBoxContainer.new()
	right.add_child(cap_row)
	var cap := _caption("GÜÇ MERKEZLERİ")
	cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cap_row.add_child(cap)
	_multi_btn = Button.new()
	_multi_btn.text = "Çoklu seçim"
	_multi_btn.toggle_mode = true
	_multi_btn.add_theme_font_size_override("font_size", _fs(13))
	_multi_btn.tooltip_text = "Açıkken kartlara dokunmak seçime ekler/çıkarır (Ctrl ile aynı). Operasyon çemberi için."
	_wire(_multi_btn)
	_multi_btn.toggled.connect(func(on: bool) -> void:
		_hint("Çoklu seçim %s. Operasyon için 1–3 kişi seç." % ("açık" if on else "kapalı")))
	cap_row.add_child(_multi_btn)
	_grid = GridContainer.new()
	_grid.columns = 5
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	right.add_child(_grid)

	var detail := PanelContainer.new()
	detail.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL, 0.85), Color(UIKit.GOLD_DIM, 0.3), 6, 8))
	right.add_child(detail)
	var irow := HBoxContainer.new()
	irow.add_theme_constant_override("separation", 10)
	detail.add_child(irow)
	_portrait_box = Control.new()
	_portrait_box.custom_minimum_size = Vector2(72, 72)
	irow.add_child(_portrait_box)
	_info = RichTextLabel.new()
	_info.bbcode_enabled = true
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info.custom_minimum_size.y = 72
	irow.add_child(_info)

	right.add_child(_caption("EMİRLER VE EYLEMLER"))
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	right.add_child(grid)
	_add_btn(grid, "promote", "Terfi", func() -> void: _act(func(id: String) -> String: return Sim.promote(id)))
	_add_btn(grid, "bribe", "Gizli Ödeme", func() -> void: _act(func(id: String) -> String: return Sim.bribe(id)))
	_add_btn(grid, "cross", "Doğrula", func() -> void: _act(func(id: String) -> String: return Sim.cross_check(id)))
	_add_btn(grid, "dismiss", "Görevden Al", func() -> void: _act(func(id: String) -> String: return Sim.dismiss(id)))
	_add_btn(grid, "investigate", "Araştır", func() -> void: _act(func(id: String) -> String: return Sim.investigate(id)))
	_add_btn(grid, "o_yaz", "Yazılı Emir", func() -> void: _act(func(id: String) -> String: return Sim.order(id, "bastir", "yazili")))
	_add_btn(grid, "o_soz", "Sözlü Emir", func() -> void: _act(func(id: String) -> String: return Sim.order(id, "bastir", "sozlu")))
	_add_btn(grid, "o_ima", "İma", func() -> void: _act(func(id: String) -> String: return Sim.order(id, "bastir", "ima")))
	_add_btn(grid, "o_sor", "Soruşturma", func() -> void: _act(func(id: String) -> String: return Sim.order(id, "sorustur", "sozlu")))
	_add_btn(grid, "blackmail", "Şantaj", func() -> void: _act(func(id: String) -> String: return Sim.blackmail(id)))
	right.add_child(_caption("GİZLİ OPERASYON   ·   2 mesai, seçili 1–3 kişiyle"))
	var ops := HBoxContainer.new()
	ops.add_theme_constant_override("separation", 6)
	right.add_child(ops)
	_add_btn(ops, "op_dikkat", "Dikkat Dağıt", func() -> void: _op("dikkat"))
	_add_btn(ops, "op_bol", "Muhalefeti Böl", func() -> void: _op("bol"))
	_add_btn(ops, "op_zayif", "Rakibi Zayıflat", func() -> void: _op("zayiflat"))
	right.add_child(_caption("SÖZ VER   ·   seçili kişiye, 1 mesai   ·   vadesi gelince karşılığını ister"))
	var prow := HBoxContainer.new()
	prow.add_theme_constant_override("separation", 6)
	right.add_child(prow)
	var pkeys := ["p_0", "p_1", "p_2"]
	for i in Sim.PRIZES.size():
		var prize: String = Sim.PRIZES[i]
		_add_btn(prow, pkeys[i], prize, func() -> void: _act(func(id: String) -> String: return Sim.promise(id, prize)))
	var hint_panel := PanelContainer.new()
	hint_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hint_panel.custom_minimum_size.y = 48
	hint_panel.add_theme_stylebox_override("panel", UIKit.box(Color(0, 0, 0, 0.35), Color(UIKit.GOLD_DIM, 0.2), 6, 10))
	right.add_child(hint_panel)
	_hint_label = RichTextLabel.new()
	_hint_label.bbcode_enabled = true
	_hint_label.scroll_active = false
	_hint_label.add_theme_color_override("default_color", UIKit.TEXT_DIM)
	_hint_label.add_theme_font_size_override("normal_font_size", _fs(13))
	_hint_label.add_theme_font_size_override("bold_font_size", _fs(13))
	_hint_label.clip_contents = true
	_hint_label.text = HINT_DEFAULT
	hint_panel.add_child(_hint_label)

	_end_btn = Button.new()
	_end_btn.text = "HAFTAYI BİTİR   ▶"
	_end_btn.theme_type_variation = "PrimaryButton"
	_end_btn.custom_minimum_size.y = 52
	_wire(_end_btn)
	_end_btn.pressed.connect(_end_week_pressed)
	root.add_child(_end_btn)

	_toast = Label.new()
	_toast.add_theme_stylebox_override("normal", UIKit.box(Color(0.04, 0.04, 0.06, 0.94), UIKit.GOLD, 6, 14))
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.anchor_left = 0.5
	_toast.anchor_right = 0.5
	_toast.anchor_top = 1.0
	_toast.anchor_bottom = 1.0
	_toast.offset_left = -470
	_toast.offset_right = 470
	_toast.offset_top = -150
	_toast.offset_bottom = -96
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_toast.modulate.a = 0.0
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_toast)

	_build_menu()
	_build_end()


func _build_header(parent: Control) -> void:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 26)
	parent.add_child(top)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UIKit.box(Color(0, 0, 0, 0.4), UIKit.GOLD, 4, 2, 2))
	frame.add_child(_initial_art("king", Vector2(46, 46), 24))
	top.add_child(frame)
	var king := Label.new()
	king.text = "KRAL ADRİAN IV"
	king.add_theme_font_override("font", UIKit.serif())
	king.add_theme_font_size_override("font_size", _fs(26))
	king.add_theme_color_override("font_color", UIKit.GOLD)
	king.visible = not _mobile
	top.add_child(king)
	var wk := VBoxContainer.new()
	wk.add_theme_constant_override("separation", 2)
	top.add_child(wk)
	_header_week = Label.new()
	_header_week.add_theme_font_override("font", UIKit.serif())
	_header_week.add_theme_font_size_override("font_size", _fs(18))
	wk.add_child(_header_week)
	_header_progress = ProgressBar.new()
	_header_progress.max_value = Sim.MAX_WEEKS
	_header_progress.show_percentage = false
	_header_progress.custom_minimum_size = Vector2(220, 6)
	wk.add_child(_header_progress)
	_header_mesai = Label.new()
	_header_mesai.add_theme_font_size_override("font_size", _fs(20))
	_header_mesai.add_theme_color_override("font_color", UIKit.GOLD)
	_header_mesai.tooltip_text = "Mesai: bu hafta kalan eylem hakkın."
	_header_mesai.mouse_filter = Control.MOUSE_FILTER_STOP
	top.add_child(_stat("res://art/icons/mesai.png", _header_mesai))
	_header_wealth = Label.new()
	_header_wealth.add_theme_font_size_override("font_size", _fs(19))
	_header_wealth.tooltip_text = "Kişisel servet: devlet bütçesinden ayrı, gizli işlerin için."
	_header_wealth.mouse_filter = Control.MOUSE_FILTER_STOP
	top.add_child(_stat("res://art/icons/servet.png", _header_wealth))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	_add_btn(top, "save", "Kaydet", _on_save)
	_add_btn(top, "menu", "Menü", _show_menu)
	for k in ["save", "menu"]:
		(_buttons[k] as Button).size_flags_horizontal = Control.SIZE_SHRINK_END
		(_buttons[k] as Button).custom_minimum_size.x = 96


func _stat(icon_path: String, label: Label) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var tex := _art(icon_path)
	if tex:
		var ic := TextureRect.new()
		ic.texture = tex
		ic.custom_minimum_size = Vector2(26, 26)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ic.tooltip_text = label.tooltip_text
		row.add_child(ic)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	return row


func _build_fx() -> void:
	_fx = CanvasLayer.new()
	_fx.layer = 50
	add_child(_fx)
	var atmos := ColorRect.new()
	atmos.set_anchors_preset(Control.PRESET_FULL_RECT)
	atmos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = ATMOS_SHADER
	atmos.material = mat
	_fx.add_child(atmos)
	_curtain = ColorRect.new()
	_curtain.color = Color(0.02, 0.015, 0.025, 1.0)
	_curtain.set_anchors_preset(Control.PRESET_FULL_RECT)
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.modulate.a = 0.0
	_fx.add_child(_curtain)
	# Haftanın olay görseli: perdenin arkasında yavaşça yakınlaşır (sinematik geçiş).
	_curtain_img = TextureRect.new()
	_curtain_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	_curtain_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_curtain_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_curtain_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain_img.modulate.a = 0.0
	_curtain.add_child(_curtain_img)
	for top in [true, false]:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.anchor_right = 1.0
		bar.anchor_top = 0.0 if top else 0.9
		bar.anchor_bottom = 0.1 if top else 1.0
		_curtain.add_child(bar)
	_curtain.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_curtain_skip = true)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.add_child(cc)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(1000, 0)
	box.add_theme_constant_override("separation", 14)
	cc.add_child(box)
	_curtain_title = Label.new()
	_curtain_title.add_theme_font_override("font", UIKit.serif())
	_curtain_title.add_theme_font_size_override("font_size", _fs(72))
	_curtain_title.add_theme_color_override("font_color", UIKit.GOLD)
	_curtain_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_curtain_title.add_theme_constant_override("shadow_outline_size", 10)
	_curtain_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_curtain_title)
	_curtain_sub = Label.new()
	_curtain_sub.add_theme_font_size_override("font_size", _fs(20))
	_curtain_sub.add_theme_color_override("font_color", UIKit.TEXT)
	_curtain_sub.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_curtain_sub.add_theme_constant_override("shadow_outline_size", 6)
	_curtain_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_curtain_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_curtain_sub)
	# Sinema katmanı (açılış ve final): atmosfer katmanının altında ki gren ve vinyet üstünde kalsın.
	var cl := CanvasLayer.new()
	cl.layer = 45
	add_child(cl)
	_cinema = CINEMA.new()
	_cinema.theme = theme
	cl.add_child(_cinema)


func _build_menu() -> void:
	_menu = Control.new()
	_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu.clip_contents = true
	add_child(_menu)
	_menu_bg = Control.new()
	_menu_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.add_child(_menu_bg)
	var tex := _art("res://art/menu_bg.png")
	if tex:
		var t := TextureRect.new()
		t.texture = tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		_menu_bg.add_child(t)
	else:
		var grad := Gradient.new()
		grad.set_color(0, Color("1a1620"))
		grad.set_color(1, Color("07060a"))
		var gt := GradientTexture2D.new()
		gt.gradient = grad
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.45)
		gt.fill_to = Vector2(1.0, 1.0)
		gt.width = 512
		gt.height = 512
		var t2 := TextureRect.new()
		t2.texture = gt
		t2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t2.stretch_mode = TextureRect.STRETCH_SCALE
		t2.set_anchors_preset(Control.PRESET_FULL_RECT)
		_menu_bg.add_child(t2)
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.02, 0.04, 0.5)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu.add_child(shade)
	_menu.add_child(UIKit.dust(Vector2(1600, 900), 60, 0.4))

	# Menü kaydırılabilir: küçük ekranda taşarsa kaydırılır, büyükte ortada durur.
	var menu_scroll := ScrollContainer.new()
	menu_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_menu.add_child(menu_scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_scroll.add_child(center)
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", UIKit.box(Color(0.03, 0.025, 0.04, 0.72), Color(UIKit.GOLD_DIM, 0.35), 10, 34))
	center.add_child(plate)
	var box := VBoxContainer.new()
	box.custom_minimum_size.x = 680
	box.add_theme_constant_override("separation", 12)
	plate.add_child(box)
	var title := Label.new()
	title.text = "V E L O R İ A"
	var shine := ShaderMaterial.new()
	shine.shader = SHIMMER_SHADER
	shine.set_shader_parameter("screen_w", 1067.0 if _mobile else 1600.0)
	title.material = shine
	title.add_theme_font_override("font", UIKit.serif())
	title.add_theme_font_size_override("font_size", 60 if _mobile else 84)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	title.add_theme_constant_override("shadow_offset_y", 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := Label.new()
	sub.text = "Tahtta kalmak, ülkeyi yönetmekten daha zordur."
	sub.add_theme_font_override("font", UIKit.serif())
	sub.add_theme_font_size_override("font_size", _fs(20))
	sub.add_theme_color_override("font_color", Color(UIKit.TEXT, 0.85))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	var sp := Control.new()
	sp.custom_minimum_size.y = 18
	box.add_child(sp)
	var how := RichTextLabel.new()
	how.bbcode_enabled = true
	how.fit_content = true
	how.scroll_active = false
	how.text = "[b]Nasıl oynanır[/b]\n• 104 hafta tahtta kal. Haftada [b]4 mesain[/b] var; kararlar, emirler ve operasyonlar mesai harcar.\n• Sayıları göremezsin; yalnızca [b]raporlar[/b] vardır ve herkes yalan söyleyebilir. Korktukça insanlar sana gerçeği söylemez; hepsi aynı cümleyi kurmaya başlar.\n• Verdiğin güç sana dönebilir. Terfi, borç ve gizli ödemeler iz bırakır.\n• Söz vermek kolaydır; vadesi gelince ya tutarsın ya da bedelini ödersin. Aynı makamı iki kişiye vaat etmek er geç duyulur.\n• Herkesin bildiği bir sır, gizli bir sırdan çok daha tehlikelidir.\n• Ertelediğin kararlar iki hafta sonra kendi kendine çözülür.\n• Oyun bittiğinde [b]Hakikat Dosyası[/b] sana kimin ne zaman yalan söylediğini gösterir."
	box.add_child(how)
	how.visible = not _mobile  # mobilde ekranı doldurmasın; düğmeyle açılır
	var b_new := _menu_btn("Yeni Oyun", _request_new_game, true)
	var b_diff := _menu_btn("", func() -> void: pass)
	var set_diff_text := func() -> void:
		b_diff.text = "Zorluk: %s" % Sim.DIFFICULTY[Sfx.difficulty]["name"]
	set_diff_text.call()
	b_diff.tooltip_text = "Kolay: 5 mesai, daha uzun koruma süresi.  Normal: dengeli.  Zor: darbeler daha erken ve kolay."
	b_diff.pressed.connect(func() -> void:
		Sfx.difficulty = (Sfx.difficulty + 1) % Sim.DIFFICULTY.size()
		Sfx.save_settings()
		set_diff_text.call())
	var b_cont := _menu_btn("Devam Et", _continue)
	var b_back := _menu_btn("Oyuna Dön", func() -> void: _hide_menu())
	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 10)
	box.add_child(info_row)
	var b_arch := Button.new()
	b_arch.text = "Hükümdarlık Arşivi"
	b_arch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_arch.custom_minimum_size.y = 42
	_wire(b_arch)
	b_arch.pressed.connect(_show_chronicle)
	info_row.add_child(b_arch)
	var b_about := Button.new()
	b_about.text = "Hakkında"
	b_about.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_about.custom_minimum_size.y = 42
	_wire(b_about)
	b_about.pressed.connect(func() -> void: _show_modal(CREDITS))
	info_row.add_child(b_about)
	if _mobile:
		var b_how := _menu_btn("Nasıl Oynanır", func() -> void: how.visible = not how.visible)
		box.move_child(b_how, box.get_child_count() - 1)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	var cb_fs := CheckBox.new()
	cb_fs.text = "Tam ekran (F11)"
	cb_fs.button_pressed = Sfx.fullscreen
	cb_fs.visible = not _mobile
	cb_fs.toggled.connect(func(on: bool) -> void:
		Sfx.set_fullscreen(on)
		Sfx.save_settings())
	row.add_child(cb_fs)
	var cb_fx := CheckBox.new()
	cb_fx.text = "Kısa geçişler"
	cb_fx.button_pressed = Sfx.short_fx
	cb_fx.toggled.connect(func(on: bool) -> void:
		Sfx.short_fx = on
		Sfx.save_settings())
	row.add_child(cb_fx)
	var cb_tips := CheckBox.new()
	cb_tips.text = "Danışman ipuçları"
	cb_tips.button_pressed = Sfx.tips
	cb_tips.toggled.connect(func(on: bool) -> void:
		Sfx.tips = on
		Sfx.save_settings())
	row.add_child(cb_tips)
	var cb_intro := CheckBox.new()
	cb_intro.text = "Açılış sineması"
	cb_intro.button_pressed = Sfx.intro
	cb_intro.toggled.connect(func(on: bool) -> void:
		Sfx.intro = on
		Sfx.save_settings())
	row.add_child(cb_intro)
	var vrow := HBoxContainer.new()
	vrow.add_theme_constant_override("separation", 10)
	vrow.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(vrow)
	vrow.add_child(_label_dim("Müzik"))
	vrow.add_child(_slider(Sfx.music_volume, func(v: float) -> void:
		Sfx.set_music(v)
		Sfx.save_settings()))
	vrow.add_child(_label_dim("Ses efekti"))
	vrow.add_child(_slider(Sfx.sfx_volume, func(v: float) -> void:
		Sfx.set_sfx(v)
		Sfx.play("click")
		Sfx.save_settings()))
	var b_quit := _menu_btn("Çıkış", func() -> void: get_tree().quit())
	_menu_items = [title, sub, how, b_new, b_diff, b_cont, b_back, info_row, row, vrow, b_quit]
	var ver := Label.new()
	ver.text = "v%s   ·   Esc: menü   Boşluk: haftayı bitir   Ctrl+S: kaydet   F11: tam ekran" % str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	if _mobile:
		ver.text = "v%s" % str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	ver.add_theme_color_override("font_color", Color(UIKit.TEXT_DIM, 0.7))
	ver.add_theme_font_size_override("font_size", _fs(12))
	ver.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
	ver.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	ver.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_menu.add_child(ver)
	_build_modal()
	_menu.set_meta("cont", b_cont)
	_menu.set_meta("back", b_back)
	_menu.hide()
	# Yavaş "Ken Burns" kaydırma
	_menu_bg.pivot_offset = Vector2(800, 450)
	var kb := _menu_bg.create_tween().set_loops()
	kb.tween_property(_menu_bg, "scale", Vector2(1.07, 1.07), 22.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	kb.tween_property(_menu_bg, "scale", Vector2(1.0, 1.0), 22.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _build_modal() -> void:
	_modal = Control.new()
	_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu.add_child(_modal)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(dim)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	var gap := 30 if _mobile else 120
	for side in ["left", "right"]:
		m.add_theme_constant_override("margin_" + side, gap)
	for side in ["top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 24 if _mobile else 60)
	_modal.add_child(m)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIKit.box(Color(0.05, 0.045, 0.06, 0.97), UIKit.GOLD, 10, 28))
	m.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)
	_modal_text = RichTextLabel.new()
	_modal_text.bbcode_enabled = true
	_modal_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_modal_text.add_theme_font_override("bold_font", UIKit.serif())
	_modal_text.add_theme_font_size_override("bold_font_size", _fs(20))
	v.add_child(_modal_text)
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 10)
	v.add_child(brow)
	_modal_yes = Button.new()
	_modal_yes.theme_type_variation = "PrimaryButton"
	_modal_yes.custom_minimum_size.y = 44
	_modal_yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wire(_modal_yes)
	_modal_yes.pressed.connect(func() -> void:
		_modal.hide()
		if _modal_cb.is_valid():
			_modal_cb.call())
	brow.add_child(_modal_yes)
	_modal_close = Button.new()
	_modal_close.text = "Kapat"
	_modal_close.custom_minimum_size.y = 44
	_modal_close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wire(_modal_close)
	_modal_close.pressed.connect(func() -> void: _modal.hide())
	brow.add_child(_modal_close)
	_modal.hide()


## Bilgi penceresi; yes_label verilirse onay penceresi olur (Evet -> yes_cb).
func _show_modal(bbcode: String, yes_label := "", yes_cb := Callable()) -> void:
	_modal_text.clear()
	_modal_text.append_text(bbcode)
	_modal_text.scroll_to_line(0)
	_modal_yes.visible = yes_label != ""
	_modal_yes.text = yes_label
	_modal_cb = yes_cb
	_modal_close.text = "Vazgeç" if yes_label != "" else "Kapat"
	_modal.show()
	if not _fast():
		UIKit.fade_in(_modal, 0.25)


func _show_chronicle() -> void:
	var list: Array = Sim.load_chronicle()
	var t := "[b][font_size=%d][color=#d6b25e]HÜKÜMDARLIK ARŞİVİ[/color][/font_size][/b]\n[color=gray]Tarih, krallarını unutmaz.[/color]\n\n" % _fs(30)
	if list.is_empty():
		t += "Henüz tamamlanmış bir saltanat yok. İlk hükümdarlığın burada anılacak."
	else:
		var wins := 0
		var best := 0
		for r in list:
			wins += 1 if r["survived"] else 0
			best = maxi(best, int(r["weeks"]))
		t += "Saltanat sayısı: %d   ·   Tahtta kalan: %d   ·   En uzun saltanat: %d hafta\n\n" % [list.size(), wins, best]
		for i in range(list.size() - 1, -1, -1):
			var r: Dictionary = list[i]
			var mark := "[color=#7fae7a]◆[/color]" if r["survived"] else "[color=#c0504a]◆[/color]"
			t += "%s  [b]%s[/b]   [color=gray]%s · %s · %d hafta[/color]\n     %s\n" % [mark, r["title"], r["date"], r["difficulty"], r["weeks"], r["cause"]]
	_show_modal(t)


func _menu_btn(text: String, cb: Callable, primary := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 46
	if primary:
		b.theme_type_variation = "PrimaryButton"
	_wire(b)
	b.pressed.connect(cb)
	_menu.find_children("*", "VBoxContainer", true, false)[0].add_child(b)
	return b


func _label_dim(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	return l


func _slider(value: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(120, 22)
	s.value_changed.connect(cb)
	return s


func _build_end() -> void:
	_end_overlay = Control.new()
	_end_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_end_overlay)
	_end_bg = TextureRect.new()
	_end_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_end_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_end_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_overlay.add_child(_end_bg)
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.02, 0.04, 0.82)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_overlay.add_child(shade)
	var under := ColorRect.new()
	under.color = Color(0.03, 0.02, 0.04, 1.0)
	under.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_overlay.add_child(under)
	_end_overlay.move_child(under, 0)
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + side, 50)
	_end_overlay.add_child(m)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	_end_chart = TRUTH_CHART.new()
	_end_chart.custom_minimum_size = Vector2(0, 150 if _mobile else 200)
	v.add_child(_end_chart)
	_end_text = RichTextLabel.new()
	_end_text.bbcode_enabled = true
	_end_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_end_text.add_theme_font_size_override("normal_font_size", _fs(17))
	_end_text.add_theme_font_override("bold_font", UIKit.serif())
	_end_text.add_theme_font_size_override("bold_font_size", _fs(20))
	_end_text.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_end_text.visible_ratio = 1.0)
	v.add_child(_end_text)
	var again := Button.new()
	again.text = "YENİDEN OYNA"
	again.theme_type_variation = "PrimaryButton"
	again.custom_minimum_size.y = 50
	_wire(again)
	again.pressed.connect(_start_new)
	v.add_child(again)
	_end_overlay.hide()


# ---------------------------------------------------------------- Yardımcılar

func _art(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null


## Olayın görseli; "_b" versiyonu varsa kampanyaya göre ikisinden biri (kampanya içinde sabit).
func _event_art(id: String) -> Texture2D:
	var a := _art("res://art/events/%s.png" % id)
	var b := _art("res://art/events/%s_b.png" % id)
	if a == null or b == null:
		return a if a else b
	return b if (absi(("%s%d" % [id, Sim.rng.seed]).hash()) % 2) == 1 else a


func _wire(b: BaseButton) -> void:
	b.mouse_entered.connect(func() -> void: Sfx.play("hover", -12.0))
	b.pressed.connect(func() -> void: Sfx.play("click"))
	b.focus_mode = Control.FOCUS_NONE


func _caption(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", UIKit.GOLD)
	l.add_theme_font_size_override("font_size", _fs(13))
	return l


func _add_btn(parent: Node, key: String, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(cb)
	if TIPS.has(key):
		var tip: String = TIPS[key]
		b.tooltip_text = tip
		b.mouse_entered.connect(func() -> void: _hint(tip))
		b.button_down.connect(func() -> void: _hint(tip))
	_wire(b)
	parent.add_child(b)
	_buttons[key] = b


func _hint(text: String) -> void:
	if _hint_label == null:
		return
	var lines := text.split("\n", false, 1)
	if lines.size() == 2:
		_hint_label.text = "[color=#d6b25e][b]%s[/b][/color]\n%s" % [lines[0], lines[1]]
	else:
		_hint_label.text = text


func _toast_msg(text: String) -> void:
	_toast.text = text
	if _toast_tween:
		_toast_tween.kill()
	_toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(3.4)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.8)


func _log(text: String) -> void:
	_journal.append_text("• %s\n" % text)
	_toast_msg(text)


func _initial_art(id: String, size: Vector2, letter_size := 40) -> Control:
	## Portre varsa gösterir; yoksa degrade + baş harf.
	var box := Control.new()
	box.custom_minimum_size = size
	box.clip_contents = true
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex := _art("res://art/portraits/%s.png" % id)
	if tex:
		var t := TextureRect.new()
		t.texture = tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(t)
	else:
		var hue := float(absi(id.hash()) % 360) / 360.0
		var c := ColorRect.new()
		c.color = Color.from_hsv(hue, 0.35, 0.34)
		c.set_anchors_preset(Control.PRESET_FULL_RECT)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(c)
		var name_text: String = Sim.actors[id].display_name if Sim.actors.has(id) else id
		var l := Label.new()
		l.text = name_text.split(" ")[-1].substr(0, 1).to_upper()
		l.add_theme_font_override("font", UIKit.serif())
		l.add_theme_font_size_override("font_size", letter_size)
		l.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.set_anchors_preset(Control.PRESET_FULL_RECT)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(l)
	return box


# ---------------------------------------------------------------- Akış

func _show_menu() -> void:
	_menu.show()
	var b_cont := _menu.get_meta("cont") as Button
	b_cont.disabled = not Sim.has_save()
	b_cont.text = "Devam Et" if not Sim.has_save() else "Devam Et  ·  %s" % Sim.save_summary()
	(_menu.get_meta("back") as Button).visible = not Sim.ended and not Sim.actors.is_empty()
	if not _instant:
		var i := 0
		for it in _menu_items:
			UIKit.fade_in(it, 0.55, 0.12 * i)
			i += 1
		var title := _menu_items[0] as Control
		title.pivot_offset = title.size / 2.0
		title.scale = Vector2(1.08, 1.08)
		title.create_tween().tween_property(title, "scale", Vector2.ONE, 1.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _hide_menu() -> void:
	if _fast():
		_menu.hide()
		return
	var tw := _menu.create_tween()
	tw.tween_property(_menu, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func() -> void:
		_menu.hide()
		_menu.modulate.a = 1.0)


func _request_new_game() -> void:
	var in_progress := not Sim.actors.is_empty() and not Sim.ended and Sim.week > 1
	if in_progress or (Sim.actors.is_empty() and Sim.has_save()):
		_show_modal("[b][font_size=%d][color=#d6b25e]Yeni saltanat[/color][/font_size][/b]\n\nSüren ya da kayıtlı bir saltanat var. Yeni bir oyuna başlarsan otomatik kayıt da üzerine yazılacak.\n\nDevam etmek istiyor musun?" % _fs(26),
			"Yeni oyuna başla", _start_new)
	else:
		_start_new()


func _start_new() -> void:
	Sim.new_game(0, Sfx.difficulty)
	if not _fast() and Sfx.intro:
		_menu.hide()
		_end_overlay.hide()
		await _cinema.play(_intro_shots())
	_after_load("Taç sana emanet edildi. Güç merkezleri seni test edecek.")


## Açılış sineması: krallık, taç, güç merkezleri ve oyunun sorusu.
func _intro_shots() -> Array:
	var p := func(id: String) -> Texture2D: return _art("res://art/portraits/%s.png" % id)
	return [
		{"tex": _art("res://art/menu_bg.png"), "line": "Veloria Krallığı.", "sub": "Modern kurumlar. Eski bir taç.", "hold": 2.8, "zoom_from": 1.0, "zoom_to": 1.12},
		{"tex": _art("res://art/end_victory.png"), "line": "Babanın cenazesinin üçüncü günü.", "sub": "Taç artık senin başında: Kral Adrian IV.", "hold": 2.8, "zoom_from": 1.1, "zoom_to": 1.0},
		{"tex": p.call("arden"), "fit": "center", "line": "Generaller sana selam veriyor.", "hold": 1.7, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": p.call("voss"), "fit": "center", "line": "Casuslar senin için dinliyor.", "hold": 1.7, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": p.call("halden"), "fit": "center", "line": "Patronlar sana ekranlarını açıyor.", "hold": 1.7, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": p.call("prens"), "fit": "center", "line": "Ve kendi kanından olanlar, sırasını bekliyor.", "hold": 2.1, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": _art("res://art/bg_desk.png"), "line": "Hepsi sana sadık olduğunu söylüyor.", "sub": "Bazıları yalan söylüyor.", "hold": 3.0, "zoom_from": 1.15, "zoom_to": 1.0},
		{"tex": null, "line": "104 hafta.", "sub": "Tahtta kal.", "hold": 2.2},
	]


func _continue() -> void:
	if Sim.load_game():
		_after_load("Kayıtlı oyun yüklendi (hafta %d)." % Sim.week)


func _after_load(message: String) -> void:
	_end_overlay.hide()
	_hide_menu()
	_journal.clear()
	_headline.text = ""
	_sel.clear()
	_cards_sig = ""
	_last_mesai = -1
	_last_wealth = -1
	_reveal = true
	_log(message)
	_refresh()
	if not _fast():
		UIKit.fade_in(_stage, 0.8)


func _on_save() -> void:
	_toast_msg("Oyun kaydedildi." if Sim.save_game() else "Kaydedilemedi.")


func _end_week_pressed() -> void:
	if _busy or Sim.ended:
		return
	if _instant:
		Sim.end_week()
		return
	_busy = true
	_curtain_skip = false
	Sfx.play("bell", -4.0)
	var short := Sfx.short_fx
	_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	_curtain_img.modulate.a = 0.0
	await create_tween().tween_property(_curtain, "modulate:a", 1.0, 0.2 if short else 0.4).finished
	var old_week := Sim.week
	Sim.end_week()
	if not Sim.ended:
		_curtain_title.text = "HAFTA %d" % Sim.week
		var headline := ""
		if not Sim.weekly_news.is_empty():
			headline = str(Sim.weekly_news[0])
		_curtain_sub.text = headline if headline != "" else "Hafta %d sessiz geçti." % old_week
		# Haftanın yeni olayının görseli arkada belirip yavaşça yakınlaşır.
		var tex: Texture2D = null
		for p in Sim.pending:
			if int(p["age"]) == 0:
				tex = _event_art(str(p["event"].get("art", p["event"]["id"])))
				if tex:
					break
		# Sessiz haftada da sahne boş kalmasın: saray görsellerinden biri soluk biçimde akar.
		var img_alpha := 0.5
		var shown := tex
		if shown == null:
			shown = _art(["res://art/bg_desk.png", "res://art/menu_bg.png"][Sim.week % 2])
			img_alpha = 0.25
		_curtain_img.texture = shown
		if shown and not short:
			_curtain_img.pivot_offset = _curtain_img.size / 2.0
			_curtain_img.scale = Vector2.ONE
			var kb := create_tween().set_parallel(true)
			kb.tween_property(_curtain_img, "modulate:a", img_alpha, 0.7)
			kb.tween_property(_curtain_img, "scale", Vector2(1.1, 1.1), 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_curtain_title.modulate.a = 0.0
		_curtain_sub.modulate.a = 0.0
		var tw := create_tween().set_parallel(true)
		tw.tween_property(_curtain_title, "modulate:a", 1.0, 0.35)
		tw.tween_property(_curtain_sub, "modulate:a", 1.0, 0.5).set_delay(0.25)
		await tw.finished
		await _wait_skip(0.25 if short else (1.6 if tex else 1.0))
	else:
		_curtain_title.text = ""
		_curtain_sub.text = ""
	_reveal = true
	_refresh()
	await create_tween().tween_property(_curtain, "modulate:a", 0.0, 0.25 if short else 0.5).finished
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


## Perdeye tıklanınca kısalan bekleme.
func _wait_skip(t: float) -> void:
	var left := t
	while left > 0.0 and not _curtain_skip:
		await get_tree().process_frame
		left -= get_process_delta_time()


## Karar mühürü: kartın üstüne kırmızı balmumu mühür basılır.
func _stamp_seal(card: Control) -> void:
	var sz := 96.0 if not _mobile else 110.0
	var seal := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("7a1f1a")
	sb.set_corner_radius_all(int(sz / 2.0))
	sb.border_color = Color("c9a24f")
	sb.set_border_width_all(3)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 10
	sb.anti_aliasing = true
	seal.add_theme_stylebox_override("panel", sb)
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.text = "V"
	l.add_theme_font_override("font", UIKit.serif())
	l.add_theme_font_size_override("font_size", int(sz * 0.55))
	l.add_theme_color_override("font_color", Color("f1d9a0"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	seal.add_child(l)
	_stage.add_child(seal)
	seal.size = Vector2(sz, sz)
	var rect := card.get_global_rect()
	seal.global_position = rect.position + Vector2(rect.size.x - sz - 40.0, rect.size.y / 2.0 - sz / 2.0)
	seal.pivot_offset = Vector2(sz, sz) / 2.0
	seal.rotation = deg_to_rad(-14.0)
	seal.scale = Vector2(2.6, 2.6)
	seal.modulate.a = 0.0
	var tw := seal.create_tween()
	tw.set_parallel(true)
	tw.tween_property(seal, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(seal, "modulate:a", 1.0, 0.1)
	tw.chain().tween_callback(func() -> void:
		Sfx.play("seal")
		UIKit.shake(card, 4.0, 0.18))
	tw.chain().tween_interval(0.55)
	tw.chain().tween_property(seal, "modulate:a", 0.0, 0.3)
	tw.chain().tween_callback(seal.queue_free)


func _selected_primary() -> String:
	if _sel.is_empty() or not Sim.actors.has(_sel[0]):
		return ""
	return _sel[0]


func _act(fn: Callable) -> void:
	var id := _selected_primary()
	if id == "":
		_toast_msg("Önce bir kişi seç.")
		return
	_log(fn.call(id))


func _op(kind: String) -> void:
	var ids: Array = []
	for s in _sel:
		if Sim.actors.has(s):
			ids.append(s)
	_log(Sim.operation(kind, ids))


func _fact_act(kind: String) -> void:
	var sel := _fact_list.get_selected_items()
	if sel.is_empty():
		_toast_msg("Önce bir dosya seç.")
		return
	var fid := _fact_ids[sel[0]]
	match kind:
		"leak":
			_log(Sim.leak_fact(fid))
		"hush":
			_log(Sim.suppress_fact(fid))
		_:
			_log(Sim.destroy_evidence(fid))


func _choose(pending_index: int, choice_index: int) -> void:
	if _busy:
		return
	if not _fast() and pending_index < _decision_cards.size():
		_busy = true
		var card := _decision_cards[pending_index]
		_stamp_seal(card)
		await get_tree().create_timer(0.55).timeout
		await create_tween().tween_property(card, "modulate:a", 0.0, 0.22).finished
		_busy = false
	var text := Sim.resolve_decision(pending_index, choice_index)
	if text != "":
		_log(text)


# ---------------------------------------------------------------- Görünüm

func _refresh() -> void:
	if _header_week == null or Sim.actors.is_empty():
		return
	_header_week.text = "HAFTA %d / %d" % [Sim.week, Sim.MAX_WEEKS]
	if _fast() or _header_progress.value > Sim.week:
		_header_progress.value = Sim.week
	elif _header_progress.value < Sim.week:
		create_tween().tween_property(_header_progress, "value", float(Sim.week), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_header_mesai.text = "◆".repeat(Sim.mesai) + "◇".repeat(maxi(Sim.mesai_max - Sim.mesai, 0))
	_header_wealth.text = str(int(Sim.private_wealth))
	if _last_mesai != Sim.mesai and _last_mesai != -1 and not _fast():
		UIKit.pulse(_header_mesai, 1.2)
	if _last_wealth != int(Sim.private_wealth) and _last_wealth != -1 and not _fast():
		UIKit.pulse(_header_wealth, 1.18)
	_last_mesai = Sim.mesai
	_last_wealth = int(Sim.private_wealth)
	_rebuild_agenda()
	_rebuild_cards()
	_fact_list.clear()
	_fact_ids.clear()
	for f: Dictionary in Sim.facts.values():
		_fact_ids.append(f["id"])
		var state := "KAMUYA AÇIK" if f.get("public", false) else ("dedikodu" if f.get("rumor", false) else "gizli — %d kişi biliyor" % f["knowers"].size())
		_fact_list.add_item("%s   [%s]" % [f["text"], state])
	_promise_list.clear()
	if Sim.promises.is_empty():
		_promise_list.append_text("[color=gray]Henüz kimseye söz vermedin. Saray sekmesinde/sağda bir kişi seçip 'Söz Ver' kullanabilirsin.[/color]")
	for p in Sim.promises:
		var nm: String = Sim.actors[p["actor"]].display_name if Sim.actors.has(p["actor"]) else str(p["actor"])
		var st := ""
		match str(p["state"]):
			"active":
				st = "bekliyor (vade: hafta %d)" % p["due"]
			"kept":
				st = "[color=#7fae7a]tutuldu[/color]"
			"broken":
				st = "[color=#c0504a]bozuldu[/color]"
			_:
				st = "[color=gray]geçersiz[/color]"
		var warn := "  [color=#c0504a]· çelişki duyuldu[/color]" if p["exposed"] and p["state"] == "active" else ""
		_promise_list.append_text("• [b]%s[/b] — %s: %s%s\n" % [nm, p["prize"], st, warn])
	_update_info()


func _rebuild_agenda() -> void:
	var keep_scroll := _scroll.scroll_vertical
	for c in _agenda.get_children():
		c.queue_free()
	_decision_buttons.clear()
	_decision_cards.clear()
	var animated: Array[Control] = []
	if Sfx.tips and ADVICE.has(Sim.week):
		var note := PanelContainer.new()
		note.add_theme_stylebox_override("panel", UIKit.box(Color(0.11, 0.095, 0.06, 0.92), Color(UIKit.GOLD_DIM, 0.6), 8, 12))
		_agenda.add_child(note)
		animated.append(note)
		var nh := HBoxContainer.new()
		nh.add_theme_constant_override("separation", 12)
		note.add_child(nh)
		var ic_tex := _art("res://art/icons/rapor.png")
		if ic_tex:
			var ic := TextureRect.new()
			ic.texture = ic_tex
			ic.custom_minimum_size = Vector2(36, 36)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			nh.add_child(ic)
		var nv := VBoxContainer.new()
		nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nh.add_child(nv)
		nv.add_child(_caption("SARAY KÂTİBİNİN NOTU   ·   menüden kapatılabilir"))
		var nl := Label.new()
		nl.text = ADVICE[Sim.week]
		nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nl.add_theme_color_override("font_color", Color("e8dcc0"))
		nv.add_child(nl)
	if not Sim.pending.is_empty():
		_agenda.add_child(_caption("KARAR BEKLEYENLER   ·   her karar 1 mesai   ·   ertelersen 2 hafta sonra kendi kendine çözülür"))
	for pi in Sim.pending.size():
		var p: Dictionary = Sim.pending[pi]
		var e: Dictionary = p["event"]
		var card := PanelContainer.new()
		var card_box := UIKit.box(Color(UIKit.PANEL, 0.96), UIKit.GOLD, 8, 12, 2)
		card.add_theme_stylebox_override("panel", card_box)
		_agenda.add_child(card)
		_decision_cards.append(card)
		animated.append(card)
		if p["age"] > 0 and not _fast():
			# Süresi dolmak üzere: çerçeve altınla kırmızı arasında nabız gibi atar.
			var pulse := card.create_tween().set_loops()
			pulse.tween_property(card_box, "border_color", UIKit.DANGER, 0.9).set_trans(Tween.TRANS_SINE)
			pulse.tween_property(card_box, "border_color", UIKit.GOLD, 0.9).set_trans(Tween.TRANS_SINE)
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 14)
		card.add_child(hb)
		var tex := _event_art(str(e.get("art", e["id"])))
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
			if not _fast():
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
		t.add_theme_font_size_override("font_size", _fs(22))
		t.add_theme_color_override("font_color", UIKit.GOLD)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(t)
		if p["age"] > 0:
			var late := Label.new()
			late.text = "⏳ Karar bekliyor — bu hafta çözülmezse kendi kendine çözülecek."
			late.add_theme_color_override("font_color", UIKit.DANGER)
			late.add_theme_font_size_override("font_size", _fs(13))
			vb.add_child(late)
		var d := Label.new()
		d.text = str(e["text"])
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(d)
		for ci in e["choices"].size():
			var b := Button.new()
			b.text = "  " + str(e["choices"][ci]["label"])
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.theme_type_variation = "ChoiceButton"
			_wire(b)
			b.pressed.connect(_choose.bind(pi, ci))
			vb.add_child(b)
			_decision_buttons.append(b)
	_agenda.add_child(_caption("BU HAFTANIN RAPORLARI"))
	var texts: Array[RichTextLabel] = []
	for r: Dictionary in Sim.reports:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL_HI, 0.55), Color(UIKit.GOLD_DIM, 0.18), 6, 8))
		_agenda.add_child(panel)
		animated.append(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		panel.add_child(row)
		row.add_child(_initial_art(str(r["source"]), Vector2(46, 46), 22))
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		l.scroll_active = false
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.text = "[b]%s[/b]  [color=gray]%s[/color]\n%s" % [r["name"], r["title"], r["text"]]
		row.add_child(l)
		texts.append(l)
	var count := Label.new()
	count.text = "Masana ulaşan rapor sayısı: %d" % Sim.reports.size()
	count.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	_agenda.add_child(count)
	_restore_scroll.call_deferred(keep_scroll)
	if _reveal and not _fast():
		_reveal = false
		_play_reveal.call_deferred(animated, texts)
	else:
		_reveal = false


func _restore_scroll(v: int) -> void:
	_scroll.scroll_vertical = v


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
	return full.split(" ")[-1]


func _rebuild_cards() -> void:
	var sig := ""
	for a in Sim.actors.values():
		sig += "%s%d," % [a.id, 1 if a.moved else 0]
	if sig != _cards_sig:
		_cards_sig = sig
		for c in _grid.get_children():
			c.queue_free()
		_cards.clear()
		for a in Sim.actors.values():
			var card := _make_card(a)
			_grid.add_child(card)
			_cards[a.id] = card
		var kept: Array[String] = []
		for s in _sel:
			if Sim.actors.has(s):
				kept.append(s)
		_sel = kept
	_style_cards()


func _make_card(a) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(108, 124) if not _mobile else Vector2(150, 190)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.tooltip_text = "%s\n%s" % [a.display_name, a.title]
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var card_art := _initial_art(a.id, Vector2(92, 80) if not _mobile else Vector2(130, 128), 40)
	card_art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(card_art)
	var n := Label.new()
	n.text = _short_name(a.display_name)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_theme_font_size_override("font_size", _fs(14))
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(n)
	var r := Label.new()
	r.text = "DÜŞMAN" if a.moved else str(ROLE.get(a.domain, ""))
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	r.add_theme_font_size_override("font_size", _fs(11))
	r.add_theme_color_override("font_color", UIKit.DANGER if a.moved else UIKit.TEXT_DIM)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(r)
	card.set_meta("id", a.id)
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
	if mb.ctrl_pressed or mb.shift_pressed or _multi_btn.button_pressed:
		if _sel.has(id):
			_sel.erase(id)
		else:
			_sel.append(id)
	else:
		_sel = [id]
	_style_cards()
	_update_info()


func _style_cards(hover_id := "") -> void:
	for id in _cards:
		var card: PanelContainer = _cards[id]
		var a = Sim.actors.get(id)
		var selected := _sel.has(id)
		var primary: bool = not _sel.is_empty() and _sel[0] == id
		var border := Color(UIKit.GOLD_DIM, 0.35)
		var bg := Color(UIKit.PANEL, 0.9)
		if a != null and a.moved:
			border = UIKit.DANGER
		if hover_id == id:
			border = UIKit.GOLD
			bg = Color(UIKit.PANEL_HI, 0.98)
		if selected:
			border = Color("ffe08a") if primary else UIKit.GOLD
			bg = Color("2d2616")
		card.add_theme_stylebox_override("panel", UIKit.box(bg, border, 6, 6, 2 if selected else 1))


func _update_info() -> void:
	_info.clear()
	for c in _portrait_box.get_children():
		c.queue_free()
	var id := _selected_primary()
	_portrait_box.visible = id != ""
	if id == "":
		_info.append_text("[color=gray]Bir kişi seç. Sayıları göremezsin; yalnızca davranışlarından tahmin edebilirsin.[/color]")
		return
	var a = Sim.actors[id]
	var art := _initial_art(a.id, Vector2(72, 72), 36)
	_portrait_box.add_child(art)
	var weight := "ikinci planda" if a.power < 40.0 else ("etkili" if a.power < 65.0 else "vazgeçilmez ve tehlikeli")
	var debt := "" if a.obligation < 8.0 else "\nSana verdiklerinin karşılığını bekliyor."
	var k: Dictionary = Sim.karne.get(a.id, {"ok": 0, "bad": 0})
	var notes := "" if k["ok"] + k["bad"] == 0 else "\n[color=gray]Doğrulama notu: %d kez örtüştü, %d kez çelişti.[/color]" % [k["ok"], k["bad"]]
	var more := "" if _sel.size() < 2 else "\n[color=#d9b359]%d kişi seçili (operasyon çemberi).[/color]" % _sel.size()
	var plist: Array[String] = []
	for p in Sim.active_promises_of(a.id):
		plist.append("%s (vade: hafta %d)" % [p["prize"], p["due"]])
	if not plist.is_empty():
		more += "\n[color=#d9b359]Ona verdiğin sözler:[/color] " + ", ".join(plist)
	var weak: String = a.weak_point if a.known_weak else "[color=gray]bilinmiyor[/color]"
	var red: String = a.red_line if a.known_red else "[color=gray]bilinmiyor[/color]"
	var secrets := "\n[color=#c0504a]Zayıf noktası:[/color] %s   [color=#c0504a]Kırmızı çizgisi:[/color] %s" % [weak, red]
	_info.append_text("[b][font_size=%d]%s[/font_size][/b]  [color=gray]%s[/color]\nGüç merkezi olarak %s.%s%s%s%s" % [_fs(18), a.display_name, a.title, weight, debt, secrets, notes, more])


func _on_week(_w: int) -> void:
	_headline.text = "  ·  ".join(Sim.weekly_news.slice(0, 3)) if not Sim.weekly_news.is_empty() else ""
	if not Sim.weekly_news.is_empty():
		_journal.append_text("[color=orange]Hafta %d: %s[/color]\n" % [Sim.week, "; ".join(Sim.weekly_news)])
		for n in Sim.weekly_news:
			if str(n).begins_with("MANŞET"):
				if not _fast():
					UIKit.shake(_stage, 7.0, 0.45)
				break
	_tabs.current_tab = 0


func _on_news(_text: String) -> void:
	pass


func _on_end(record: Dictionary) -> void:
	var bg_path := "res://art/end_victory.png"
	if not record["survived"]:
		var c: String = record["cause"]
		bg_path = "res://art/end_coup.png"
		if c.contains("ayaklanma"):
			bg_path = "res://art/end_uprising.png"
		elif c.contains("yetkisiz"):
			bg_path = "res://art/end_scandal.png"
	_end_bg.texture = _art(bg_path)
	_end_text.clear()
	var verdict := "Tahtını korudun." if record["survived"] else "Tahtını kaybettin."
	_end_text.append_text("[b][font_size=38]Kral %s[/font_size][/b]\n[font_size=22]%s[/font_size]\n\n[b]Ünvanın:[/b] [color=#d9b359]%s[/color]\n%s\n[b]En güçlü isim:[/b] %s\n[b]Söz sicili:[/b] %s\n\n" % [record["king"], verdict, record["title"], record["cause"], record["top_actor"], record.get("promises", "")])
	var hist: Array = record.get("historians", [])
	if hist.size() == 2:
		_end_text.append_text("[b][color=#d9b359][font_size=22]TARİH NE YAZACAK?[/font_size][/color][/b]\n")
		_end_text.append_text("[color=#d6b25e]Saray tarihçisi:[/color] [i]\"%s\"[/i]\n" % hist[0])
		_end_text.append_text("[color=#c0504a]Sürgündeki tarihçi:[/color] [i]\"%s\"[/i]\n\n" % hist[1])
	_end_text.append_text("[b][color=#d9b359][font_size=22]HAKİKAT DOSYASI — sana söylenmeyenler[/font_size][/color][/b]\n")
	if record["lies"].is_empty():
		_end_text.append_text("Kimse sana belirgin biçimde yalan söylemedi. Ya da hepsini fark ettin.\n")
	for l: Dictionary in record["lies"]:
		_end_text.append_text("• Hafta %d — [b]%s[/b] sana şunu söyledi: \"%s\"\n   [color=gray]Gerçekte:[/color] %s\n" % [l["week"], l["name"], l["said"], l["truth"]])
	_end_text.append_text("\n[b][color=#d9b359][font_size=22]Son kararların[/font_size][/color][/b]\n")
	for h in record["history"].slice(maxi(0, record["history"].size() - 14)):
		_end_text.append_text("• %s\n" % h)
	_menu.hide()
	if _fast():
		_end_chart.set_data(record.get("timeline", []), false)
		_end_overlay.show()
		return
	# Final sineması: sonuç görseli tam ekran, bantlı; ardından hakikat paneli.
	Sfx.play("stinger_win" if record["survived"] else "stinger_loss", -2.0)
	var big := "TAHTINI KORUDUN" if record["survived"] else "TAHTINI KAYBETTİN"
	await _cinema.play([{"tex": _art(bg_path), "line": big, "sub": "Ünvanın: %s" % record["title"], "hold": 4.2, "zoom_from": 1.0, "zoom_to": 1.14}])
	_end_overlay.show()
	UIKit.fade_in(_end_overlay, 1.0)
	_end_chart.set_data(record.get("timeline", []), true)
	if not record["survived"]:
		UIKit.shake(_stage, 10.0, 0.6)
	var dur := clampf(float(_end_text.get_total_character_count()) * 0.012, 4.0, 14.0)
	UIKit.typewrite(_end_text, dur, 0.8)


# ---------------------------------------------------------------- Otomatik oynatma (test)

func _autoplay() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var pressed := 0
	while not Sim.ended:
		await get_tree().process_frame
		var guard := 0
		while not _decision_buttons.is_empty() and Sim.mesai > 0 and guard < 3:
			guard += 1
			var b: Button = _decision_buttons[rng.randi() % _decision_buttons.size()]
			b.pressed.emit()
			pressed += 1
			await get_tree().process_frame
		if not _cards.is_empty():
			var ids: Array = _cards.keys()
			var pick: String = ids[rng.randi() % ids.size()]
			_sel = [pick]
			if rng.randf() < 0.3:
				_sel.append(ids[rng.randi() % ids.size()])
			_update_info()
		var keys := ["promote", "bribe", "cross", "o_soz", "o_ima", "o_sor", "op_dikkat", "op_bol"]
		while Sim.mesai > 0 and not Sim.ended:
			var k: String = keys[rng.randi() % keys.size()]
			(_buttons[k] as Button).pressed.emit()
			pressed += 1
			if Sim.mesai > 0 and rng.randf() < 0.3:
				break
		if not _fact_ids.is_empty():
			_fact_list.select(0)
			(_buttons["destroy"] as Button).pressed.emit()
		_end_btn.pressed.emit()
	print("AUTOPLAY DONE: hafta=%d basılan=%d sonuç=%s" % [Sim.week, pressed, Sim.record.get("title", "?")])
	get_tree().quit(0)
