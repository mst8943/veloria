extends Control
## Saray Masası: kararlar, raporlar, kişiler, eylemler. Ham sayılar bilerek gösterilmez.

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")
const ATMOS_SHADER := preload("res://game/ui/atmosphere.gdshader")
const VIBRANCY_SHADER := preload("res://game/ui/vibrancy.gdshader")
const CINEMA := preload("res://game/ui/cinema.gd")
const TOUCH_SCROLL := preload("res://game/ui/touch_scroll.gd")
const MEDIA_VIEW := preload("res://game/ui/media_view.gd")
const DESK_VIEW := preload("res://game/ui/desk_view.gd")
const CITY_VIEW := preload("res://game/ui/city_view.gd")
const TRUTH_CHART := preload("res://game/ui/truth_chart.gd")
const AUTOPLAY := preload("res://game/ui/autoplay.gd")
const END_SCREEN := preload("res://game/ui/end_screen.gd")
const MENU := preload("res://game/ui/menu.gd")
const MODAL := preload("res://game/ui/modal.gd")
const AGENDA_VIEW := preload("res://game/ui/agenda_view.gd")
const PERSON_PANEL := preload("res://game/ui/person_panel.gd")
const DIVAN_VIEW := preload("res://game/ui/divan_view.gd")
const TOUR_VIEW := preload("res://game/ui/tour_view.gd")

var _agenda_view: RefCounted
var _person_panel: RefCounted
var _divan: RefCounted
var _stage: Control
var _header_week: Label
var _header_progress: ProgressBar
var _header_mesai: Label
var _header_wealth: Label
var _headline: Label
var _headline_notice := ""
var _tabs: TabContainer
var _scroll: ScrollContainer
var _agenda: VBoxContainer
var _journal: RichTextLabel
var _grid: GridContainer
var _info: RichTextLabel
var _portrait_box: Control
var _buttons: Dictionary = {}
var _decision_cards: Array[Control] = []
var _decision_buttons: Array[Button] = []
var _end_btn: Button
var _fact_ids: Array[String] = []
var _cards: Dictionary = {}
var _cards_sig := ""
var _week_log: Array[String] = []   # bu haftanın eylem sonuçları (Gündem > BU HAFTA)
var _week_log_week := -1
var _sel: Array[String] = []
var _icons: Dictionary = {}
var _menu: Control    # ana menü (menu.gd)
var _end_overlay: Control   # oyun sonu ekranı (end_screen.gd)
var _fx: CanvasLayer
var _curtain: ColorRect
var _curtain_title: Label
var _curtain_sub: Label
var _mobile := false
var _act_title: Label
var _fact_box: VBoxContainer
var _desk: Control
var _city: Control
var _files_tab: Control
var _mobile_report_tabs: TabContainer
var _mobile_reports_page: VBoxContainer
var _media: Control
var _media_seen_week := 0
var _acted_week := 0              # bu hafta bir kişiye eylem yapıldı mı (yol gösterici için)
var _queued_end := false
var _mesai_box: HBoxContainer
var _curtain_img: TextureRect
var _curtain_skip := false
var _cinema: Control
var _cutscenes: Array = []
var _end_pulse: Tween
var _headline_expanded := false
var _ui_nodes: Array = []   # _build_ui/_build_fx'in eklediği düğümler (dil değişince yeniden kurulur)
var _modal: Control   # bilgi/onay penceresi (modal.gd)
var _promise_list: RichTextLabel
var _multi_btn: Button
var _act_cat := "KAZAN"            # eylem panelinde açık kategori
var _report_box: VBoxContainer     # masaüstünde raporların sağ sütundaki listesi (mobilde null)
var _all_reports_popup: PopupPanel
var _cat_rows: Dictionary = {}     # kategori -> düğme satırı
var _cat_btns: Dictionary = {}     # kategori -> sekme düğmesi
var _hint_label: RichTextLabel
var _flow: HBoxContainer
var _traits: HFlowContainer
var _flow_sig := ""
var _busy := false
var _instant := false
var _reveal := true
var _last_mesai := -1
var _autoplayer: RefCounted   # otomatik oynatma testi (autoplay.gd); await sırasında canlı kalsın
var _last_wealth := -1
var _tour: Control


func _ready() -> void:
	if OS.has_feature("headless"):
		Loc.set_lang("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	# Telefon: yerel mobil, telefon tarayıcısındaki web sürümü, ya da masaüstünde test bayrağı.
	_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios") \
		or ProjectSettings.get_setting("veloria/dev_mobile", false) or "--mobile" in OS.get_cmdline_user_args()
	if _mobile:
		get_tree().root.content_scale_size = Vector2i(1067, 600)
		add_child(TOUCH_SCROLL.new())
	theme = UIKit.build_theme(_mobile)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	Sim.week_advanced.connect(_on_week)
	Sim.news.connect(_on_news)
	Sim.changed.connect(_refresh)
	Sim.game_ended.connect(_on_end)
	_agenda_view = AGENDA_VIEW.new(self)
	_person_panel = PERSON_PANEL.new(self)
	_divan = DIVAN_VIEW.new(self)
	var pre_ui := get_children()
	_build_ui()
	_build_fx()
	for n in get_children():
		if not pre_ui.has(n):
			_ui_nodes.append(n)
	if Sim.content_error != "":
		_show_menu()
		_show_modal(tr("[b]İçerik yüklenemedi[/b]\n\n%s") % Sim.content_error)
		return
	var dev_run: bool = "--autoplay" in OS.get_cmdline_user_args() or ProjectSettings.get_setting("veloria/dev_autostart", false)
	if dev_run:
		Sim.record_chronicle = false   # test/geliştirme oyunları arşive yazılmaz
		Sim.autosave = false           # ve oyuncunun kaydına dokunmaz
	if "--autoplay" in OS.get_cmdline_user_args():
		_instant = true
		_start_new()
		_autoplayer = AUTOPLAY.new(self)
		_autoplayer.run()
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
		if ProjectSettings.get_setting("veloria/dev_desk", false):
			_desk.open()
		var dev_city := str(ProjectSettings.get_setting("veloria/dev_city", ""))
		if dev_city != "":
			_city.open()
			if dev_city != "map":
				await get_tree().process_frame
				_city.show_site(dev_city)
		var dev_media := str(ProjectSettings.get_setting("veloria/dev_media", ""))
		if dev_media != "":
			_open_media()
			_media.show_tab(dev_media)
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
			_divan.refresh()
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
				_show_modal(MENU.CREDITS)
			"chronicle":
				_show_chronicle()


## Dil değişince arayüzü yeniden kurar: tr() ile bir kez yazılmış bütün metinler yeni dilde yenilenir.
func rebuild_ui() -> void:
	if _tabs == null:
		return
	var menu_open: bool = _menu != null and _menu.visible
	var menu_page: String = _menu.page_now if _menu != null else "main"
	var tab: int = _tabs.current_tab
	var sel := _sel.duplicate()
	var dec_index: int = _agenda_view.decision_index
	for n in _ui_nodes:
		if is_instance_valid(n):
			remove_child(n)
			n.queue_free()
	_ui_nodes.clear()
	_buttons.clear()
	_cards.clear()
	_cards_sig = ""
	_decision_cards.clear()
	_decision_buttons.clear()
	_agenda_view = AGENDA_VIEW.new(self)
	_person_panel = PERSON_PANEL.new(self)
	_divan = DIVAN_VIEW.new(self)
	var pre_ui := get_children()
	_build_ui()
	_build_fx()
	for n in get_children():
		if not pre_ui.has(n):
			_ui_nodes.append(n)
	_agenda_view.decision_index = dec_index
	if not Sim.actors.is_empty():
		_sel.clear()
		for id in sel:
			if Sim.actors.has(id):
				_sel.append(id)
		_refresh()
		_style_cards()
		_update_info()
		_tabs.current_tab = clampi(tab, 0, _tabs.get_tab_count() - 1)
	if menu_open:
		_show_menu()
		_menu.show_page(menu_page)


## Kısayollar: F11 tam ekran, Esc menü/pencere kapat, Boşluk haftayı bitir, Ctrl+S kaydet.
func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	var in_game: bool = not Sim.actors.is_empty() and not Sim.ended
	if in_game and not _mobile and not _divan.opened and not _menu.visible and not _desk.visible and not _city.visible and not _media.visible and not _modal.visible \
			and k.keycode >= KEY_1 and k.keycode <= KEY_5 and not k.ctrl_pressed and not k.alt_pressed:
		var index := k.keycode - KEY_1
		if index < _divan.visible_ids.size():
			_sel.clear()
			_sel.append(str(_divan.visible_ids[index]))
			_style_cards()
			_update_info()
			_divan.refresh()
			get_viewport().set_input_as_handled()
		return
	match k.keycode:
		KEY_F11:
			Sfx.set_fullscreen(not Sfx.fullscreen)
			Sfx.save_settings()
		KEY_ESCAPE:
			if _tour != null and _tour.active:
				_tour.finish()
			elif _modal.visible:
				_modal.hide()
			elif _divan.opened:
				_divan.close()
			elif in_game and not _sel.is_empty() and not _menu.visible and not _desk.visible and not _city.visible and not _media.visible and not _modal.visible:
				_sel.clear()
				_style_cards()
				_update_info()
				_divan.refresh()
			elif _menu.visible and _menu.page_now != "main":
				_menu_show_page("main")
			elif _desk.visible and not _menu.visible:
				_desk.close_view()
			elif _menu.visible and in_game:
				_hide_menu()
			elif not _menu.visible and not _end_overlay.visible:
				_show_menu()
		KEY_SPACE:
			if in_game and not _menu.visible and not _end_overlay.visible and not _media.visible and not _desk.visible and not _city.visible:
				_end_week_pressed()
		KEY_LEFT, KEY_RIGHT:
			if in_game and _tabs.current_tab == 0 and not _menu.visible and not _end_overlay.visible and not _media.visible and not _desk.visible and not _city.visible and not _modal.visible:
				_agenda_view.show_decision(_agenda_view.decision_index + (-1 if k.keycode == KEY_LEFT else 1))
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
		dim.color = Color(UIKit.SHADE, 0.7)
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
		margin.add_theme_constant_override("margin_" + side, (4 if side in ["bottom", "top"] else 10) if _mobile else 18)
	_stage.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 0 if _mobile else 10)
	margin.add_child(root)

	_build_header(root)

	# Alamet/haber şeridi: koyu zemin, solda amber çizgi; boşken gizli (bkz. _refresh).
	_headline = Label.new()
	_headline.add_theme_color_override("font_color", UIKit.AMBER.lightened(0.35))
	_headline.add_theme_font_size_override("font_size", _fs(14))
	_headline.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var hl_sb := UIKit.box(Color(UIKit.PLATE, 0.78), Color(0, 0, 0, 0), 2, 12)
	hl_sb.border_color = UIKit.AMBER
	hl_sb.border_width_left = 3
	hl_sb.content_margin_top = 5
	hl_sb.content_margin_bottom = 5
	_headline.add_theme_stylebox_override("normal", hl_sb)
	_headline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _mobile:
		# Dokununca açılır: uzun haber metni tek satıra sığmıyor.
		_headline.mouse_filter = Control.MOUSE_FILTER_STOP
		_headline.custom_minimum_size.y = 40
		_headline.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_headline.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_headline_expanded = not _headline_expanded
				_apply_headline_mode())
	# Şerit sağ üstteki bildirimlerin altına girmesin.
	var hl_row := HBoxContainer.new()
	hl_row.visible = false
	hl_row.add_child(_headline)
	root.add_child(hl_row)

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
	_tabs.set_tab_title(0, tr("Gündem"))
	_agenda = VBoxContainer.new()
	_agenda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_agenda.add_theme_constant_override("separation", 6 if _mobile else 10)
	_scroll.add_child(_agenda)
	var files := VBoxContainer.new()
	files.name = "Dosyalar"
	_tabs.add_child(files)
	_tabs.set_tab_title(1, tr("Dosyalar"))
	_files_tab = files
	files.add_theme_constant_override("separation", 8)
	files.add_child(_section(tr("SIRLAR VE KANITLAR"), tr("çubuk: sırrın ne kadar yayıldığı · yarısında manşete çıkar")))
	var fscroll := ScrollContainer.new()
	fscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	files.add_child(fscroll)
	_fact_box = VBoxContainer.new()
	_fact_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fact_box.add_theme_constant_override("separation", 6)
	fscroll.add_child(_fact_box)
	files.add_child(_section(tr("SÖZ DEFTERİ")))
	var ppanel := PanelContainer.new()
	ppanel.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL_HI, 0.5), Color(UIKit.GOLD_DIM, 0.2), 6, 10))
	files.add_child(ppanel)
	_promise_list = RichTextLabel.new()
	_promise_list.bbcode_enabled = true
	_promise_list.custom_minimum_size.y = 120
	ppanel.add_child(_promise_list)
	_journal = RichTextLabel.new()
	_journal.name = "Günlük"
	_journal.bbcode_enabled = true
	_journal.scroll_following = true
	_tabs.add_child(_journal)
	_tabs.set_tab_title(2, tr("Günlük"))
	_tabs.tab_changed.connect(func(_i: int) -> void:
		Sfx.play("paper", -10.0)
		_update_headline())
	if _mobile:
		_tabs.remove_child(files)
		_tabs.remove_child(_journal)
		_mobile_report_tabs = TabContainer.new()
		_mobile_report_tabs.name = "Raporlar"
		# İç içe çerçeve olmasın: alt sekme paneli sade kalır, dış panel zaten süslü.
		_mobile_report_tabs.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PANEL, 0.35), Color(UIKit.GOLD_DIM, 0.25), 4, 6))
		_mobile_report_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_mobile_report_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_mobile_reports_page = VBoxContainer.new()
		_mobile_reports_page.name = "Raporlar"
		_mobile_reports_page.add_theme_constant_override("separation", 6)
		_mobile_report_tabs.add_child(_mobile_reports_page)
		_mobile_report_tabs.set_tab_title(0, tr("Raporlar"))
		_mobile_report_tabs.add_child(files)
		_mobile_report_tabs.set_tab_title(1, tr("Dosyalar"))
		_mobile_report_tabs.add_child(_journal)
		_mobile_report_tabs.set_tab_title(2, tr("Günlük"))
		_tabs.add_child(_mobile_report_tabs)
		_tabs.set_tab_title(1, tr("Raporlar"))
	var tab_icons := ["rapor", "dosya", "gunluk"]
	for i in (3 if not _mobile else 0):
		var ti := _art("res://art/icons/%s.png" % tab_icons[i])
		if ti:
			_tabs.set_tab_icon(i, ti)
	if _mobile:
		_tabs.set_tab_title(0, tr("Gündem"))
	_tabs.add_theme_constant_override("icon_max_width", 20)

	_build_person_panel(cols)

	# Alt satır: haftanın akış şeridi (ne kaldı, ne bekliyor) ve Haftayı Bitir.
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	root.add_child(bottom)
	var flow_panel := PanelContainer.new()
	flow_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow_panel.add_theme_stylebox_override("panel", UIKit.box(Color(0, 0, 0, 0.4), Color(UIKit.GOLD_DIM, 0.25), 8, 10))
	flow_panel.clip_contents = true
	bottom.add_child(flow_panel)
	_flow = HBoxContainer.new()
	_flow.add_theme_constant_override("separation", 6)
	_flow.alignment = BoxContainer.ALIGNMENT_BEGIN
	flow_panel.add_child(_flow)
	_end_btn = Button.new()
	_end_btn.text = tr("HAFTAYI BİTİR   »")
	_end_btn.theme_type_variation = "PrimaryButton"
	_end_btn.custom_minimum_size = Vector2(300 if _mobile else 360, 52)
	_wire(_end_btn)
	_end_btn.pressed.connect(_end_week_pressed)
	bottom.add_child(_end_btn)

	_desk = DESK_VIEW.new()
	_desk.mobile = _mobile
	_desk.portrait_fn = func(id: String) -> Texture2D: return _art("res://art/portraits/%s.png" % id)
	_desk.media_fresh_fn = func() -> bool: return _media_seen_week != Sim.week
	_desk.request.connect(_on_desk_request)
	add_child(_desk)
	_city = CITY_VIEW.new()
	_city.mobile = _mobile
	_city.art_fn = func(id: String) -> Texture2D: return _event_art(id) if id != "" else null
	_city.portrait_fn = func(id: String) -> Texture2D: return _art("res://art/portraits/%s.png" % id)
	_city.request.connect(_on_city_request)
	add_child(_city)

	_media = MEDIA_VIEW.new()
	_media.mobile = _mobile
	_media.art_fn = func(id: String) -> Texture2D: return _event_art(id) if id != "" else null
	_media.closed.connect(func() -> void: _refresh())
	add_child(_media)

	_menu = MENU.new(self)
	add_child(_menu)
	_modal = MODAL.new(self)
	add_child(_modal)   # menünün üstünde
	_end_overlay = END_SCREEN.new(self)
	add_child(_end_overlay)
	_tour = TOUR_VIEW.new(self)
	add_child(_tour)


func _build_header(parent: Control) -> void:
	# Başlık bandı: koyu, alt kenarında ince altın çizgi.
	var band := PanelContainer.new()
	band.name = "TourTopBar"
	band.add_theme_stylebox_override("panel", UIKit.band_style())
	parent.add_child(band)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 26)
	band.add_child(top)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UIKit.box(Color(0, 0, 0, 0.4), UIKit.GOLD, 4, 2, 2))
	frame.add_child(_initial_art("king", Vector2(46, 46), 24))
	top.add_child(frame)
	var king := Label.new()
	king.text = tr("KRAL ADRİAN IV")
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
	_header_mesai.tooltip_text = tr("Mesai: bu hafta kalan eylem hakkın.")
	_header_mesai.mouse_filter = Control.MOUSE_FILTER_STOP
	var mesai_row := _stat("res://art/icons/mesai.png", _header_mesai)
	_header_mesai.visible = false
	# Mesai elmasları çizilir: her fontta ve platformda aynı görünür.
	_mesai_box = HBoxContainer.new()
	_mesai_box.add_theme_constant_override("separation", 9)
	_mesai_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mesai_box.tooltip_text = _header_mesai.tooltip_text
	_mesai_box.mouse_filter = Control.MOUSE_FILTER_STOP
	mesai_row.add_child(_mesai_box)
	top.add_child(mesai_row)
	_header_wealth = Label.new()
	_header_wealth.add_theme_font_size_override("font_size", _fs(19))
	_header_wealth.tooltip_text = tr("Kişisel servet: devlet bütçesinden ayrı, gizli işlerin için.")
	_header_wealth.mouse_filter = Control.MOUSE_FILTER_STOP
	top.add_child(_stat("res://art/icons/servet.png", _header_wealth))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	_add_btn(top, "desk", tr("Masa"), _show_desk)
	(_buttons["desk"] as Button).tooltip_text = tr("Çalışma masası: gündem, gazete, kişiler, günlük, dosyalar, hanedan ve başkent haritası.")
	(_buttons["desk"] as Button).size_flags_horizontal = Control.SIZE_SHRINK_END
	(_buttons["desk"] as Button).custom_minimum_size.x = 96
	_add_btn(top, "media", tr("Medya"), _open_media)
	(_buttons["media"] as Button).tooltip_text = tr("Medya Merkezi: Sarne'nin gazetesi, Leyla'nın bağımsız gazetesi ve Sarne TV. İkisini karşılaştır; biri yalan söylüyor olabilir.")
	_add_btn(top, "save", tr("Kaydet"), _on_save)
	_add_btn(top, "menu", tr("Menü"), _show_menu)
	(_buttons["media"] as Button).size_flags_horizontal = Control.SIZE_SHRINK_END
	(_buttons["media"] as Button).custom_minimum_size.x = 150
	for k in ["save", "menu"]:
		(_buttons[k] as Button).size_flags_horizontal = Control.SIZE_SHRINK_END
		(_buttons[k] as Button).custom_minimum_size.x = 96
	# Gezinme düğmeleri eylem değil: hayalet stil, ince ayraçla gruplu
	for k in ["desk", "media", "save", "menu"]:
		(_buttons[k] as Button).theme_type_variation = "GhostButton"
	var sep := ColorRect.new()
	sep.color = Color(UIKit.GOLD_DIM, 0.35)
	sep.custom_minimum_size = Vector2(1, 30)
	sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(sep)
	top.move_child(sep, (_buttons["save"] as Button).get_index())
	if _mobile:
		# Dar ekran: otomatik kayıt var, Kaydet ve ayraç yer kaplamasın
		(_buttons["save"] as Button).visible = false
		sep.visible = false
		for k in ["desk", "media", "menu"]:
			(_buttons[k] as Button).custom_minimum_size.x = 0


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


func _update_mesai_pips() -> void:
	if _mesai_box == null:
		return
	var want: int = Sim.mesai_max
	while _mesai_box.get_child_count() < want:
		# Kapsayıcılar çocuklarının dönüşünü sıfırlar; elması kapsayıcı olmayan bir tutucuya koy.
		var s := 13 if not _mobile else 16
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(s + 4, s + 4)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pip := Panel.new()
		pip.size = Vector2(s, s)
		pip.position = Vector2(2, 2)
		pip.pivot_offset = Vector2(s, s) / 2.0
		pip.rotation = deg_to_rad(45.0)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(pip)
		_mesai_box.add_child(holder)
	while _mesai_box.get_child_count() > want:
		var last := _mesai_box.get_child(_mesai_box.get_child_count() - 1)
		_mesai_box.remove_child(last)
		last.queue_free()
	for i in want:
		var sb := StyleBoxFlat.new()
		sb.bg_color = UIKit.GOLD if i < Sim.mesai else Color(0, 0, 0, 0.35)
		sb.border_color = UIKit.GOLD
		sb.set_border_width_all(2)
		sb.anti_aliasing = true
		(_mesai_box.get_child(i).get_child(0) as Panel).add_theme_stylebox_override("panel", sb)


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
	_curtain.color = Color(UIKit.SHADE.darkened(0.3), 1.0)
	_curtain.set_anchors_preset(Control.PRESET_FULL_RECT)
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.modulate.a = 0.0
	_curtain.theme = theme   # CanvasLayer temayı devretmez
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
	var grade_layer := CanvasLayer.new()
	grade_layer.name = "Vibrancy"
	grade_layer.layer = 60
	add_child(grade_layer)
	var grade := ColorRect.new()
	grade.set_anchors_preset(Control.PRESET_FULL_RECT)
	grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grade_material := ShaderMaterial.new()
	grade_material.shader = VIBRANCY_SHADER
	grade.material = grade_material
	grade_layer.add_child(grade)
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
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE  # görünmezken alttaki düğmeleri örtmesin
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


## Bilgi penceresi; yes_label verilirse onay penceresi olur (Evet -> yes_cb).
func _show_modal(bbcode: String, yes_label := "", yes_cb := Callable()) -> void:
	_modal.show_text(bbcode, yes_label, yes_cb)


func _menu_show_page(page_name: String) -> void:
	_menu.show_page(page_name)


func _show_chronicle() -> void:
	var list: Array = Sim.load_chronicle()
	var t := tr("[b][font_size=%d][color=#d6b25e]HÜKÜMDARLIK ARŞİVİ[/color][/font_size][/b]\n[color=gray]Tarih, krallarını unutmaz.[/color]\n\n") % _fs(30)
	if list.is_empty():
		t += tr("Henüz tamamlanmış bir saltanat yok. İlk hükümdarlığın burada anılacak.")
	else:
		var wins := 0
		var best := 0
		for r in list:
			wins += 1 if r["survived"] else 0
			best = maxi(best, int(r["weeks"]))
		t += tr("Saltanat sayısı: %d   ·   Tahtta kalan: %d   ·   En uzun saltanat: %d hafta\n\n") % [list.size(), wins, best]
		for i in range(list.size() - 1, -1, -1):
			var r: Dictionary = list[i]
			var mark := "[color=#7fae7a]TAHTTA[/color]" if r["survived"] else "[color=#c0504a]DÜŞTÜ[/color]"
			t += "%s  [b]%s[/b]   [color=gray]%s · %s · %d hafta[/color]\n     %s\n" % [mark, r["title"], r["date"], tr(str(r["difficulty"])), r["weeks"], r["cause"]]
	var have: Dictionary = Sim.load_achievements()
	t += tr("\n[b][font_size=%d][color=#d6b25e]BAŞARIMLAR  ·  %d / %d[/color][/font_size][/b]\n") % [_fs(24), have.size(), Sim.ACHIEVEMENTS.size()]
	for id in Sim.ACHIEVEMENTS:
		var info: Array = Sim.ACHIEVEMENTS[id]
		if have.has(id):
			t += "[color=#d6b25e]»[/color]  [b]%s[/b]  [color=gray]%s · %s[/color]\n" % [info[0], info[1], have[id]]
		else:
			t += "[color=#55524c]·  %s  ·  %s[/color]\n" % [info[0], info[1]]
	_show_modal(t)


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


## Bölüm başlığı: küçük altın elmas, aralıklı büyük harf, ince çizgi ve isteğe bağlı açıklama.
func _section(title: String, helper := "") -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(10, 10)
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gem := Panel.new()
	var gs := StyleBoxFlat.new()
	gs.bg_color = UIKit.GOLD
	gem.add_theme_stylebox_override("panel", gs)
	gem.size = Vector2(6, 6)
	gem.position = Vector2(2, 2)
	gem.pivot_offset = Vector2(3, 3)
	gem.rotation = deg_to_rad(45.0)
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(gem)
	row.add_child(holder)
	var l := Label.new()
	l.text = title
	l.add_theme_font_override("font", UIKit.caps())
	l.add_theme_font_size_override("font_size", _fs(15))
	l.add_theme_color_override("font_color", UIKit.GOLD)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var line := ColorRect.new()
	line.color = Color(UIKit.GOLD_DIM, 0.35)
	line.custom_minimum_size = Vector2(28, 1)
	# Açıklama yoksa çizgi satırı doldurur; varsa kısa bir ayraç olur, açıklama yanından akar.
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL if helper == "" else Control.SIZE_SHRINK_BEGIN
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(line)
	if helper != "":
		var h := Label.new()
		h.text = helper
		h.add_theme_font_size_override("font_size", _fs(12))
		h.add_theme_color_override("font_color", Color(UIKit.TEXT_DIM, 0.85))
		h.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		# Dar ekranda açıklama kısalır, başlık kaymaz.
		h.clip_text = true
		h.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(h)
	return row


## Eylem panelinde bir kategori aç: yalnızca onun düğmeleri görünür.
func _toast_msg(text: String) -> void:
	if _headline == null or text == "":
		return
	_headline_notice = text
	_update_headline()


func _log(text: String) -> void:
	_journal.append_text("• %s\n" % text)
	_toast_msg(text)
	_hint(tr("Son eylem") + "\n" + text)  # sonuç bildirim kaybolsa da burada kalır
	if _week_log_week != Sim.week:
		_week_log.clear()
		_week_log_week = Sim.week
	if text != "":
		_week_log.append(text)


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
	_menu_show_page("main")
	# İlk düğme duruma göre: oyun sürüyorsa "Oyuna Dön", yoksa kayıttan "Devam Et".
	var b_first := _menu.get_meta("first") as Button
	var b_new := _menu.get_meta("new") as Button
	var in_game: bool = not Sim.ended and not Sim.actors.is_empty()
	if in_game:
		b_first.text = tr("Oyuna Dön")
		b_first.disabled = false
	else:
		b_first.disabled = not Sim.has_save()
		b_first.text = tr("Devam Et") if not Sim.has_save() else tr("Devam Et  ·  %s") % Sim.save_summary()
	var first_primary: bool = in_game or Sim.has_save()
	b_first.theme_type_variation = "PrimaryButton" if first_primary else ""
	b_new.theme_type_variation = "" if first_primary else "PrimaryButton"
	if not _instant:
		var i := 0
		for it in _menu.items:
			UIKit.fade_in(it, 0.55, 0.12 * i)
			i += 1
		var title := _menu.items[0] as Control
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
	var in_progress: bool = not Sim.actors.is_empty() and not Sim.ended and Sim.week > 1
	if in_progress or (Sim.actors.is_empty() and Sim.has_save()):
		_show_modal(tr("[b][font_size=%d][color=#d6b25e]Yeni saltanat[/color][/font_size][/b]\n\nSüren ya da kayıtlı bir saltanat var. Yeni bir oyuna başlarsan otomatik kayıt da üzerine yazılacak.\n\nDevam etmek istiyor musun?") % _fs(26),
			tr("Yeni oyuna başla"), _start_new)
	else:
		_start_new()


func _start_new() -> void:
	Sim.new_game(0, Sfx.difficulty)
	if Sim.content_error != "":
		_show_modal(tr("[b]İçerik yüklenemedi[/b]\n\n%s") % Sim.content_error)
		return
	if not _fast() and Sfx.intro:
		_menu.hide()
		_end_overlay.hide()
		await _cinema.play(_intro_shots())
	_after_load(tr("Taç sana emanet edildi. Güç merkezleri seni test edecek."))
	var start_tour := not _fast() and Sfx.tour_enabled and not Sfx.tour_done
	if start_tour:
		_tour.begin()
	elif Sfx.desk_start:
		_show_desk()


func _replay_tour() -> void:
	if Sim.actors.is_empty() or Sim.ended:
		Sfx.tour_enabled = true
		Sfx.tour_done = false
		_start_new()
		return
	_menu.hide()
	_tour.begin()


## Açılış sineması: krallık, taç, güç merkezleri ve oyunun sorusu.
func _intro_shots() -> Array:
	var p := func(id: String) -> Texture2D: return _art("res://art/portraits/%s.png" % id)
	return [
		{"tex": _art("res://art/menu_bg.png"), "line": tr("Veloria Krallığı."), "sub": tr("Modern kurumlar. Eski bir taç."), "hold": 2.8, "zoom_from": 1.0, "zoom_to": 1.12},
		{"tex": _art("res://art/end_victory.png"), "line": tr("Babanın cenazesinin üçüncü günü."), "sub": tr("Taç artık senin başında: Kral Adrian IV."), "hold": 2.8, "zoom_from": 1.1, "zoom_to": 1.0},
		{"tex": p.call("arden"), "fit": "center", "line": tr("Generaller sana selam veriyor."), "hold": 1.7, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": p.call("voss"), "fit": "center", "line": tr("Casuslar senin için dinliyor."), "hold": 1.7, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": p.call("halden"), "fit": "center", "line": tr("Patronlar sana ekranlarını açıyor."), "hold": 1.7, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": p.call("prens"), "fit": "center", "line": tr("Ve kendi kanından olanlar, sırasını bekliyor."), "hold": 2.1, "zoom_from": 1.0, "zoom_to": 1.08},
		{"tex": _art("res://art/bg_desk.png"), "line": tr("Hepsi sana sadık olduğunu söylüyor."), "sub": tr("Bazıları yalan söylüyor."), "hold": 3.0, "zoom_from": 1.15, "zoom_to": 1.0},
		{"tex": null, "line": tr("104 hafta."), "sub": tr("Tahtta kal."), "hold": 2.2},
	]


func _continue() -> void:
	if Sim.load_game():
		_after_load(tr("Kayıtlı oyun yüklendi (hafta %d).") % Sim.week)
	else:
		_show_modal(tr("[b]Kayıt yüklenemedi[/b]\n\n%s\n\nYeni bir saltanat başlatabilirsin.") % Sim.load_error)


func _after_load(message: String) -> void:
	_end_overlay.hide()
	_hide_menu()
	_journal.clear()
	_headline.text = ""
	_headline.get_parent().visible = false
	_sel.clear()
	_divan.last_id = ""
	_agenda_view.decision_index = 0
	_cards_sig = ""
	_last_mesai = -1
	_last_wealth = -1
	_reveal = true
	_queued_end = false
	_media_seen_week = 0
	_log(message)
	_week_log.clear()   # açılış/yükleme mesajı eylem değil; haftanın defterine girmesin
	_refresh()
	if not _fast():
		UIKit.fade_in(_stage, 0.8)


func _show_desk() -> void:
	if Sim.actors.is_empty() or Sim.ended or _instant:
		return
	_desk.open()


func _select_tab(ctrl: Control) -> void:
	if _mobile and _mobile_report_tabs != null and ctrl.get_parent() == _mobile_report_tabs:
		_tabs.current_tab = _tabs.get_tab_idx_from_control(_mobile_report_tabs)
		_mobile_report_tabs.current_tab = _mobile_report_tabs.get_tab_idx_from_control(ctrl)
		return
	var idx := _tabs.get_tab_idx_from_control(ctrl)
	if idx >= 0:
		_tabs.current_tab = idx


func _on_desk_request(target: String) -> void:
	match target:
		"medya":
			_open_media()
			return
		"harita":
			_city.open()
			return
		"hanedan":
			_show_chronicle()
			return
	_desk.close_view()
	match target:
		"gundem":
			_select_tab(_scroll)
		"kisiler":
			if _mobile:
				_tabs.current_tab = 1
			else:
				_hint(tr("[color=#d6b25e][b]Kişiler[/b][/color]\nSağdaki portrelerden birini seç; eylemler ve sözler altta."))
				UIKit.pulse(_grid, 1.03)
		"gunluk":
			_select_tab(_journal)
		"dosyalar":
			_select_tab(_files_tab)


func _on_city_request(target: String, arg: String) -> void:
	match target:
		"media":
			_open_media()
		"files":
			_city.close_view()
			_desk.close_view()
			_select_tab(_files_tab)
		"actor":
			_city.close_view()
			_desk.close_view()
			if Sim.actors.has(arg):
				_sel = [arg]
				_style_cards()
				_update_info()
				_divan.refresh()
			if _mobile:
				_tabs.current_tab = 1


func _open_media() -> void:
	if Sim.actors.is_empty() or Sim.ended:
		return
	_media_seen_week = Sim.week
	_media.open("state")


func _on_save() -> void:
	_toast_msg(tr("Oyun kaydedildi.") if Sim.save_game() else tr("Kaydedilemedi."))


func _end_week_pressed() -> void:
	if Sim.ended:
		return
	if _busy:
		# Bir animasyon sürerken basıldı: yok sayma, animasyon bitince uygula.
		_queued_end = true
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
	var old_week: int = Sim.week
	var had_crisis: bool = Sim.active_crisis_label() != ""
	Sim.end_week()
	if not had_crisis and not Sim.ended and Sim.active_crisis_label() != "":
		Sfx.play("alert", -3.0)
	if not Sim.ended:
		_curtain_title.text = tr("HAFTA %d") % Sim.week
		var headline := ""
		if not Sim.weekly_news.is_empty():
			headline = Sim.news_for_display(str(Sim.weekly_news[0]))
		_curtain_sub.text = headline if headline != "" else tr("Hafta %d sessiz geçti.") % old_week
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
	if not Sim.ended and Sfx.desk_start:
		_desk.open()   # perde açılınca masa görünür
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
		_toast_msg(tr("Önce bir kişi seç."))
		return
	_acted_week = Sim.week
	_divan.last_id = id
	_log(fn.call(id))


func _op(kind: String) -> void:
	var ids: Array = []
	for s in _sel:
		if Sim.actors.has(s):
			ids.append(s)
	_acted_week = Sim.week
	if not ids.is_empty():
		_divan.last_id = str(ids[0])
	_log(Sim.divide_rivals(ids) if kind == "dus" else Sim.operation(kind, ids))


func _fact_act(kind: String, fid: String) -> void:
	match kind:
		"leak":
			_log(Sim.leak_fact(fid))
		"hush":
			_log(Sim.suppress_fact(fid))
		_:
			_log(Sim.destroy_evidence(fid))


## Karardan sonra ara sahne: game/data/cutscenes.json'daki eşleşen kayıt (choice -1 = her seçenek).
func _play_cutscene(event_id: String, choice_index: int) -> void:
	if _fast() or event_id == "":
		return
	if _cutscenes.is_empty():
		var f := FileAccess.open("res://game/data/cutscenes.json", FileAccess.READ)
		if f != null:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			if parsed is Array:
				_cutscenes = parsed
	for c: Dictionary in _cutscenes:
		if str(c.get("event", "")) != event_id:
			continue
		var want := int(c.get("choice", -1))
		if want != -1 and want != choice_index:
			continue
		var shots: Array = []
		for s: Dictionary in c.get("shots", []):
			var path := str(s.get("art", ""))
			var tex: Texture2D = null
			if path.begins_with("events/"):
				tex = _event_art(path.trim_prefix("events/"))
			elif path != "":
				tex = _art("res://art/%s.png" % path)
			shots.append({"tex": tex, "line": tr(str(s.get("line", ""))) if str(s.get("line", "")) != "" else "",
				"sub": tr(str(s.get("sub", ""))) if str(s.get("sub", "")) != "" else "",
				"hold": float(s.get("hold", 3.0)), "zoom_from": float(s.get("zoom_from", 1.0)),
				"zoom_to": float(s.get("zoom_to", 1.12)), "fit": str(s.get("fit", "cover")), "video": str(s.get("video", ""))})
		if shots.is_empty():
			return
		_busy = true
		await _cinema.play(shots)
		_busy = false
		return


func _choose(pending_index: int, choice_index: int) -> void:
	if _busy:
		return
	if not _fast() and not _decision_cards.is_empty():
		_busy = true
		var card := _decision_cards[0]
		_stamp_seal(card)
		await get_tree().create_timer(0.55).timeout
		await create_tween().tween_property(card, "modulate:a", 0.0, 0.22).finished
		_busy = false
	var ev_id := ""
	if pending_index >= 0 and pending_index < Sim.pending.size():
		ev_id = str(Sim.pending[pending_index]["event"].get("id", ""))
	var before: int = Sim.pending.size()
	var text: String = Sim.resolve_decision(pending_index, choice_index)
	if _tour != null and _tour.has_method("decision_made"):
		_tour.decision_made()
	if text != "":
		_log(text)
	if Sim.pending.size() < before and not Sim.ended:
		await _play_cutscene(ev_id, choice_index)
	if _queued_end:
		_queued_end = false
		_end_week_pressed()


# ---------------------------------------------------------------- Görünüm

func _refresh() -> void:
	if _header_week == null or Sim.actors.is_empty():
		return
	_header_week.text = tr("HAFTA %d / %d") % [Sim.week, Sim.MAX_WEEKS]
	if _fast() or _header_progress.value > Sim.week:
		_header_progress.value = Sim.week
	elif _header_progress.value < Sim.week:
		create_tween().tween_property(_header_progress, "value", float(Sim.week), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_update_mesai_pips()
	_pulse_end_button()
	if _tabs != null:
		var waiting := Sim.pending.size()
		_tabs.set_tab_title(0, tr("Gündem") + ("  ·  %d" % waiting if waiting > 0 else ""))
	var mb := _buttons.get("media") as Button
	if mb:
		var fresh_issue: bool = _media_seen_week != Sim.week
		mb.text = (tr("Medya •") if _mobile else tr("Medya  ·  yeni sayı")) if fresh_issue else tr("Medya")
	_header_wealth.text = str(int(Sim.private_wealth))
	if _last_mesai != Sim.mesai and _last_mesai != -1 and not _fast():
		UIKit.pulse(_mesai_box, 1.2)
	if _last_wealth != int(Sim.private_wealth) and _last_wealth != -1 and not _fast():
		UIKit.pulse(_header_wealth, 1.18)
	_last_mesai = Sim.mesai
	_last_wealth = int(Sim.private_wealth)
	_rebuild_agenda()
	_rebuild_cards()
	_divan.refresh()
	_rebuild_facts()
	_promise_list.clear()
	if Sim.promises.is_empty():
		_promise_list.append_text(tr("[color=gray]Henüz kimseye söz vermedin. Kişiler sekmesinde/sağda bir kişi seçip 'Söz Ver' kullanabilirsin.[/color]"))
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
	_rebuild_flow()


## Akış şeridi: haftanın durumu tek bakışta. Her parça tıklanınca ilgili yere götürür.
func _rebuild_flow() -> void:
	if _flow == null:
		return
	var items: Array = []   # [metin, renk, hedef]
	if Sim.mesai > 0:
		items.append([tr("Mesai %d / %d") % [Sim.mesai, Sim.mesai_max], UIKit.GOLD, ""])
	else:
		items.append([tr("Mesai bitti"), UIKit.TEXT_DIM, ""])
	var crisis_label: String = Sim.active_crisis_label()
	if crisis_label != "":
		items.append([tr(crisis_label if not _mobile else crisis_label.split(" ")[0]), UIKit.DANGER, "gundem"])
	var late := 0
	for p in Sim.pending:
		if int(p["age"]) > 0:
			late += 1
	if not Sim.pending.is_empty():
		var t := Loc.ntr("%d karar bekliyor", Sim.pending.size()) % Sim.pending.size()
		if late > 0:
			t += (tr(" · %d acil") if _mobile else tr("  ·  %d tanesi bu hafta düşer")) % late
		items.append([t, UIKit.DANGER if late > 0 else UIKit.GOLD, "gundem"])
	if _media_seen_week != Sim.week:
		items.append([tr("Medya okunmadı") if not _mobile else tr("Medya"), Color("d9963e"), "medya"])
	var due := 0
	for p in Sim.promises:
		if str(p["state"]) == "active" and int(p["due"]) <= Sim.week + 1:
			due += 1
	if due > 0:
		items.append([Loc.ntr("%d sözün vadesi geldi", due) % due if not _mobile else tr("Söz vadesi"), Color("d9b359"), "dosyalar"])
	var spreading := 0
	for f: Dictionary in Sim.facts.values():
		if f["subject"] == "king" and not f.get("public", false) and float(f["common"]) >= 0.3:
			spreading += 1
	if spreading > 0:
		items.append([Loc.ntr("%d sırrın yayılıyor", spreading) % spreading, UIKit.DANGER, "dosyalar"])
	if Sim.mesai == 0 and Sim.pending.is_empty():
		items.append([tr("Hazırsın: haftayı bitir") if not _mobile else tr("Hazır"), UIKit.OK, ""])
	var sig := str(items)
	if sig == _flow_sig:
		return
	_flow_sig = sig
	for c in _flow.get_children():
		_flow.remove_child(c)
		c.queue_free()
	for i in items.size():
		var it: Array = items[i]
		if i > 0:
			var dot := ColorRect.new()
			dot.color = Color(UIKit.GOLD_DIM, 0.5)
			dot.custom_minimum_size = Vector2(4, 4)
			dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_flow.add_child(dot)
		_flow.add_child(_flow_chip(it[0], it[1], it[2]))


func _flow_chip(text: String, col: Color, target: String) -> Control:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.add_theme_font_size_override("font_size", _fs(14))
	for st in ["font_color", "font_disabled_color"]:
		b.add_theme_color_override(st, col)
	b.add_theme_color_override("font_hover_color", col.lightened(0.3))
	b.add_theme_color_override("font_pressed_color", col.lightened(0.3))
	var normal := UIKit.box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 6, 8)
	normal.content_margin_top = 4
	normal.content_margin_bottom = 4
	var hover := UIKit.box(Color(col, 0.12), Color(col, 0.5), 6, 8)
	hover.content_margin_top = 4
	hover.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("disabled", normal)
	b.add_theme_stylebox_override("hover", hover if target != "" else normal)
	b.add_theme_stylebox_override("pressed", hover if target != "" else normal)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if _mobile and target != "":
		b.custom_minimum_size.y = 44   # dokunma hedefi
	if target == "":
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return b
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.tooltip_text = tr({"gundem": "Gündeme git", "medya": "Medya Merkezi'ni aç", "dosyalar": "Dosyalar sekmesine git"}.get(target, ""))
	_wire(b)
	b.pressed.connect(_on_flow.bind(target))
	return b


## Yapılacak başka bir şey kalmadıysa (karar yok, mesai bitti) "Haftayı bitir" yumuşakça nabız gibi parlar:
## oyuncunun gözü bir sonraki adıma gider.
func _pulse_end_button() -> void:
	if _end_btn == null:
		return
	var ready: bool = Sim.pending.is_empty() and Sim.mesai == 0 and not Sim.ended and not _fast()
	if ready and (_end_pulse == null or not _end_pulse.is_valid()):
		_end_pulse = _end_btn.create_tween().set_loops()
		_end_pulse.tween_property(_end_btn, "modulate", Color(1.25, 1.2, 1.05), 0.9).set_trans(Tween.TRANS_SINE)
		_end_pulse.tween_property(_end_btn, "modulate", Color.WHITE, 0.9).set_trans(Tween.TRANS_SINE)
	elif not ready and _end_pulse != null:
		_end_pulse.kill()
		_end_pulse = null
		_end_btn.modulate = Color.WHITE


func _on_flow(target: String) -> void:
	if target == "medya":
		_open_media()
		return
	_desk.close_view()
	_city.close_view()
	if target == "gundem":
		_select_tab(_scroll)
		_scroll.scroll_vertical = 0
		if not _decision_cards.is_empty():
			UIKit.pulse(_decision_cards[0], 1.02)
	else:
		_select_tab(_files_tab)


func _headline_items() -> Array:
	var order := ["KRİZ", "ALAMET", "SOKAK", "MAHKEME", "MALİYE", "ADLİYE", "İDARE", "ORDU", "MANŞET", "ERTELENDİ", "KULİS", "OLAY", "SÖZ", "HAMLE"]
	var items: Array = Sim.weekly_news.duplicate()
	items.sort_custom(func(x, y) -> bool:
		var ix := order.size()
		var iy := order.size()
		for i in order.size():
			if str(x).begins_with(order[i]) and ix == order.size():
				ix = i
			if str(y).begins_with(order[i]) and iy == order.size():
				iy = i
		return ix < iy)
	return items


func _on_week(_w: int) -> void:
	_headline_notice = ""
	_update_headline()
	if not Sim.weekly_news.is_empty():
		var news_text: Array[String] = []
		for item in Sim.weekly_news:
			news_text.append(Sim.news_for_display(str(item)))
		_journal.append_text(tr("[color=orange]Hafta %d: %s[/color]\n") % [Sim.week, "; ".join(news_text)])
		for n in Sim.weekly_news:
			if str(n).begins_with("MANŞET"):
				if not _fast():
					UIKit.shake(_stage, 7.0, 0.45)
				break
	_tabs.current_tab = 0


func _apply_headline_mode() -> void:
	if _headline == null:
		return
	if _headline_expanded:
		_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_headline.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	else:
		_headline.autowrap_mode = TextServer.AUTOWRAP_OFF
		_headline.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


func _update_headline() -> void:
	var items: Array[String] = []
	if _headline_notice != "":
		items.append(_headline_notice)
	for item in _headline_items().slice(0, 1):
		items.append(Sim.news_for_display(str(item)))
	if items.size() < 2 and Sfx.tips and AGENDA_VIEW.ADVICE.has(Sim.week):
		items.append(tr(str(AGENDA_VIEW.ADVICE[Sim.week])))
	_headline.text = "  ·  ".join(items.slice(0, 2))
	_apply_headline_mode()
	# Mobilde dikey alan kıt: haber şeridi yalnızca Gündem sekmesinde görünür.
	_headline.get_parent().visible = _headline.text != "" and (not _mobile or _tabs.current_tab == 0)


func _on_news(_text: String) -> void:
	pass


func _on_end(record: Dictionary) -> void:
	var bg_path: String = _end_overlay.show_record(record)
	_menu.hide()
	if _fast():
		_end_overlay.show()
		return
	# Final sineması: sonuç görseli tam ekran, bantlı; ardından hakikat paneli.
	Sfx.play("stinger_win" if record["survived"] else "stinger_loss", -2.0)
	var big := tr("TAHTINI KORUDUN") if record["survived"] else tr("TAHTINI KAYBETTİN")
	await _cinema.play([{"tex": _art(bg_path), "line": big, "sub": tr("Ünvanın: %s") % record["title"], "hold": 4.2, "zoom_from": 1.0, "zoom_to": 1.14}])
	_end_overlay.show()
	UIKit.fade_in(_end_overlay, 1.0)
	if not record["survived"]:
		UIKit.shake(_stage, 10.0, 0.6)
	var dur := clampf(float(_end_overlay.summary.get_total_character_count()) * 0.012, 2.5, 6.0)
	UIKit.typewrite(_end_overlay.summary, dur, 0.8)

func _rebuild_facts() -> void:
	_agenda_view._rebuild_facts()

func _rebuild_agenda() -> void:
	_agenda_view._rebuild_agenda()

func _short_name(full: String) -> String:
	return _agenda_view._short_name(full)

func _action_tip(key: String) -> String:
	return _person_panel._action_tip(key)

func _build_person_panel(cols: HBoxContainer) -> void:
	_person_panel._build_ui(cols)

func _show_act_cat(cat: String) -> void:
	_person_panel._show_act_cat(cat)

func _add_btn(parent: Node, key: String, text: String, cb: Callable) -> void:
	_person_panel._add_btn(parent, key, text, cb)

func _preview(key: String) -> void:
	_person_panel._preview(key)

func _hint(text: String) -> void:
	_person_panel._hint(text)

func _rebuild_cards() -> void:
	_person_panel._rebuild_cards()

func _card_fade() -> Texture2D:
	return _person_panel._card_fade()

func _make_card(a) -> PanelContainer:
	return _person_panel._make_card(a)

func _on_card_input(ev: InputEvent, id: String) -> void:
	_person_panel._on_card_input(ev, id)

func _style_cards(hover_id := "") -> void:
	_person_panel._style_cards(hover_id)

func _update_action_states() -> void:
	_person_panel._update_action_states()

func _update_info() -> void:
	_person_panel._update_info()

func _signs_tip(a) -> String:
	return _person_panel._signs_tip(a)

func _trait(text: String, col: Color, filled := -1, total := 0, tip := "") -> Control:
	return _person_panel._trait(text, col, filled, total, tip)
