extends Control
## Saray Masası: kararlar, raporlar, kişiler, eylemler. Ham sayılar bilerek gösterilmez.

const UIKit := preload("res://game/ui/ui_kit.gd")
const ORNAMENT_ICON := preload("res://game/ui/ornament_icon.gd")
const Loc := preload("res://game/core/loc.gd")
const ATMOS_SHADER := preload("res://game/ui/atmosphere.gdshader")
const VIBRANCY_SHADER := preload("res://game/ui/vibrancy.gdshader")
const CINEMA := preload("res://game/ui/cinema.gd")
const TITLE_SCREEN := preload("res://game/ui/title_screen.gd")
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
const PERSON_FILE := preload("res://game/ui/person_file.gd")
const DIVAN_VIEW := preload("res://game/ui/divan_view.gd")
const TOUR_VIEW := preload("res://game/ui/tour_view.gd")

var _agenda_view: RefCounted
var _person_panel: RefCounted
var _person_file: RefCounted
var _divan: RefCounted
var _stage: Control
var _header_week: Label
var _header_progress: ProgressBar
var _header_mesai: Label
var _header_wealth: Label
var _headline: Label
var _headline_secondary: Label
var _headline_diamond: Control
var _headline_band: PanelContainer
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
var _daily_run := false
var _daily_date := ""
var _daily_seed := 0
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
var _budget_editor: Control
var _budget_editor_spins: Array[SpinBox] = []
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
var _music_mode := ""
var _music_mode_since := 0


func _ready() -> void:
	if OS.has_feature("headless"):
		Loc.set_lang("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	# Telefon: yerel mobil, telefon tarayıcısındaki web sürümü, ya da masaüstünde test bayrağı.
	_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios") \
		or ProjectSettings.get_setting("veloria/dev_mobile", false) or "--mobile" in OS.get_cmdline_user_args()
	if _mobile:
		get_tree().root.content_scale_size = Vector2i(1067, 600)
		add_child(TOUCH_SCROLL.new())
	UIKit.configure_accessibility(Sfx.text_size, Sfx.high_contrast, Sfx.reduce_motion)
	theme = UIKit.build_theme(_mobile)
	theme.default_font = UIKit.sans()
	theme.set_font("bold_font", "RichTextLabel", UIKit.sans(680))
	theme.set_font("italics_font", "RichTextLabel", UIKit.serif_italic())
	theme.set_font("bold_italics_font", "RichTextLabel", UIKit.serif_italic())
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
	_update_music()
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
		if not ProjectSettings.get_setting("veloria/dev_intro", false):
			_show_title.call_deferred()
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
	UIKit.configure_accessibility(Sfx.text_size, Sfx.high_contrast, Sfx.reduce_motion)
	var menu_open: bool = _menu != null and _menu.visible
	var menu_page: String = _menu.page_now if _menu != null else "main"
	var tab: int = _tabs.current_tab
	var sel := _sel.duplicate()
	var file_id: String = _person_file.actor_id if _person_file != null and _person_file.is_open() else ""
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
		if file_id != "":
			_open_person_file(file_id)
	if menu_open:
		_show_menu()
		_menu.show_page(menu_page)


## Kısayollar: F11 tam ekran, Esc menü/pencere kapat, Boşluk haftayı bitir, Ctrl+S kaydet.
func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	var in_game: bool = not Sim.actors.is_empty() and not Sim.ended
	if in_game and not _mobile and not _divan.opened and not _menu.visible and not _desk.visible and not _city.visible and not _media.visible and not _modal.visible and (_person_file == null or not _person_file.is_open()) \
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
			elif _person_file != null and _person_file.is_open():
				_person_file.close_file()
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
			if in_game and not _menu.visible and not _end_overlay.visible and not _media.visible and not _desk.visible and not _city.visible and (_person_file == null or not _person_file.is_open()):
				_end_week_pressed()
		KEY_LEFT, KEY_RIGHT:
			if in_game and _tabs.current_tab == 0 and not _menu.visible and not _end_overlay.visible and not _media.visible and not _desk.visible and not _city.visible and not _modal.visible and (_person_file == null or not _person_file.is_open()):
				_agenda_view.show_decision(_agenda_view.decision_index + (-1 if k.keycode == KEY_LEFT else 1))
		KEY_S:
			if k.ctrl_pressed and in_game:
				_on_save()
		_:
			return
	get_viewport().set_input_as_handled()


## Telefonda çentik/kamera ve yuvarlak köşeler için güvenli alan boşlukları (görüntü alanı pikseli).
func _safe_insets() -> Dictionary:
	if not (_mobile and OS.has_feature("mobile")):
		return {}
	var win := Vector2(DisplayServer.window_get_size())
	var safe := DisplayServer.get_display_safe_area()
	var view := get_viewport_rect().size
	if win.x < 1.0 or win.y < 1.0 or safe.size.x < 1:
		return {}
	var fx := view.x / win.x
	var fy := view.y / win.y
	return {
		"left": int(maxf(0.0, safe.position.x * fx)), "top": int(maxf(0.0, safe.position.y * fy)),
		"right": int(maxf(0.0, (win.x - safe.end.x) * fx)), "bottom": int(maxf(0.0, (win.y - safe.end.y) * fy)),
	}


func _fast() -> bool:
	return _instant or Sfx.short_fx


## Mobilde yazılar büyür (yatay telefon: ~1067x600 taban).
func _fs(n: int) -> int:
	var scaled := roundi(n * [1.0, 1.14, 1.28][Sfx.text_size] * (1.22 if _mobile else 1.0))
	return maxi(15, scaled) if _mobile else scaled


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
		if not Sfx.reduce_motion:
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
	var safe := _safe_insets()
	for side in ["left", "right", "top", "bottom"]:
		var base_margin: int = ((4 if side in ["bottom", "top"] else 10) if _mobile else 18)
		if side == "top" and not _mobile:
			base_margin = 0
		margin.add_theme_constant_override("margin_" + side, base_margin + int(safe.get(side, 0)))
	_stage.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 0 if _mobile else 10)
	margin.add_child(root)

	_build_header(root)

	# Haber satırı: çizilmiş kıvrım ve iki başlık arasında çizilmiş baklava.
	_headline_band = PanelContainer.new()
	_headline_band.name = "NewsTicker"
	_headline_band.visible = false
	_headline_band.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_headline_band.custom_minimum_size.y = 32 if _mobile else 30
	var ticker_style := UIKit.box(Color(UIKit.PLATE, 0.82), Color(UIKit.GOLD_DIM, 0.2), 2, 8)
	if not _mobile:
		ticker_style.bg_color = Color(0.03, 0.025, 0.018, 0.9)
		ticker_style.border_color = Color(UIKit.GOLD, 0.42)
		ticker_style.content_margin_left = 14
	ticker_style.content_margin_top = 2 if _mobile else 4
	ticker_style.content_margin_bottom = 2 if _mobile else 4
	_headline_band.add_theme_stylebox_override("panel", ticker_style)
	_headline_band.resized.connect(func() -> void: _fit_headline())
	root.add_child(_headline_band)
	var hl_row := HBoxContainer.new()
	hl_row.add_theme_constant_override("separation", 12)
	_headline_band.add_child(hl_row)
	hl_row.add_child(_header_symbol("flourish", Vector2(18, 18), UIKit.GOLD))
	_headline = Label.new()
	_headline.add_theme_font_override("font", UIKit.serif() if not _mobile else UIKit.sans())
	_headline.add_theme_color_override("font_color", UIKit.TEXT)
	_headline.add_theme_font_size_override("font_size", _fs(16 if _mobile else 15))
	_headline.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_headline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_headline.size_flags_stretch_ratio = 0.68
	_headline.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_headline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hl_row.add_child(_headline)
	_headline_diamond = _header_symbol("diamond", Vector2(8, 8) if _mobile else Vector2(12, 12), UIKit.GOLD, true)
	_headline_diamond.visible = false
	hl_row.add_child(_headline_diamond)
	_headline_secondary = Label.new()
	_headline_secondary.add_theme_font_override("font", UIKit.serif() if not _mobile else UIKit.sans())
	_headline_secondary.add_theme_color_override("font_color", UIKit.TEXT)
	_headline_secondary.add_theme_font_size_override("font_size", _fs(16 if _mobile else 15))
	_headline_secondary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_headline_secondary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_headline_secondary.size_flags_stretch_ratio = 1.32
	_headline_secondary.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_headline_secondary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hl_row.add_child(_headline_secondary)
	_headline_band.mouse_filter = Control.MOUSE_FILTER_STOP if _mobile else Control.MOUSE_FILTER_IGNORE
	_headline_band.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			var mb := ev as InputEventMouseButton
			if (TOUCH_SCROLL.dispatching_touch and not mb.pressed) or (not TOUCH_SCROLL.dispatching_touch and mb.pressed):
				_headline_expanded = not _headline_expanded
				_apply_headline_mode())

	var cols := HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 14)
	root.add_child(cols)

	# Sol: sekmeler
	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_stretch_ratio = 1.42
	if not _mobile:
		# Mockup: sol panelin içeriği süslü çerçeveden belirgin içeride başlar.
		var tab_panel := theme.get_stylebox("panel", "TabContainer").duplicate() as StyleBox
		tab_panel.content_margin_left = 48
		tab_panel.content_margin_right = 44
		tab_panel.content_margin_top = 30
		tab_panel.content_margin_bottom = 24
		_tabs.add_theme_stylebox_override("panel", tab_panel)
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
	var watermark: Texture2D = _art("res://art/ui/watermark_crest.png")
	if watermark:
		_scroll.draw.connect(func() -> void:
			if not _mobile:
				_scroll.draw_rect(Rect2(Vector2.ZERO, _scroll.size), Color(0.045, 0.038, 0.03, 0.75))
			var scale_factor: float = minf(_scroll.size.x / watermark.get_width(), _scroll.size.y / watermark.get_height()) * 0.82
			var watermark_size := Vector2(watermark.get_size()) * scale_factor
			_scroll.draw_texture_rect(watermark, Rect2((_scroll.size - watermark_size) / 2.0, watermark_size), false, Color(1, 1, 1, 0.055)))
		_scroll.resized.connect(_scroll.queue_redraw)
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
	var psb := UIKit.box(Color(UIKit.PANEL, 0.8), Color(0, 0, 0, 0), 6, 12)
	psb.set_border_width_all(0)
	ppanel.add_theme_stylebox_override("panel", psb)
	files.add_child(ppanel)
	UIKit.ornament(ppanel, Color(UIKit.GOLD, 0.8), 16, 1)
	_promise_list = RichTextLabel.new()
	_promise_list.bbcode_enabled = true
	_promise_list.custom_minimum_size.y = 120
	_promise_list.add_theme_font_override("normal_font", UIKit.sans())
	_promise_list.add_theme_font_override("bold_font", UIKit.sans(680))
	_promise_list.add_theme_color_override("default_color", UIKit.TEXT)
	_promise_list.add_theme_constant_override("line_separation", 4)
	ppanel.add_child(_promise_list)
	_journal = RichTextLabel.new()
	_journal.name = "Günlük"
	_journal.bbcode_enabled = true
	_journal.scroll_following = true
	_journal.add_theme_font_override("normal_font", UIKit.sans())
	_journal.add_theme_font_override("bold_font", UIKit.sans(680))
	_journal.add_theme_font_override("italics_font", UIKit.serif_italic())
	_journal.add_theme_color_override("default_color", UIKit.TEXT)
	_journal.add_theme_constant_override("line_separation", 4)
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
	_tabs.add_theme_constant_override("icon_max_width", 22 if _mobile else 24)
	var tab_bar: TabBar = _tabs.get_tab_bar()
	tab_bar.custom_minimum_size.y = 44 if _mobile else 48
	tab_bar.add_theme_font_override("font", UIKit.sans())
	tab_bar.add_theme_font_size_override("font_size", _fs(17 if _mobile else 16))
	if not _mobile:
		tab_bar.add_theme_constant_override("h_separation", 10)

	_build_person_panel(cols)
	_person_file = PERSON_FILE.new(self)
	_person_file.build()

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
	_end_btn.custom_minimum_size = Vector2(300 if _mobile else 360, 52 if _mobile else 44)
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
	if not _mobile and ResourceLoader.exists(HEADER_ART_TR):
		_build_header_art(parent)
		return
	var header := VBoxContainer.new()
	header.name = "RoyalHeader"
	header.add_theme_constant_override("separation", 0)
	parent.add_child(header)
	var scenery := TextureRect.new()
	scenery.name = "HeaderScenery"
	scenery.custom_minimum_size.y = 28 if _mobile else 56
	scenery.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenery.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scenery.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	scenery.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var scenery_tex := _art("res://art/ui/header_bg.png")
	var band_scenery: AtlasTexture = null
	if scenery_tex:
		scenery.texture = scenery_tex
	var strip_tex := _art("res://art/ui/header_strip.png") if not _mobile else null
	if strip_tex:
		# Mockup: sancak, sütun ve şamdan sırası şeridin üst kısmında açık, bandın arkasında koyu sürer.
		var sw := float(strip_tex.get_width())
		var sh := float(strip_tex.get_height())
		var cut := sh * 56.0 / 134.0
		var top_atlas := AtlasTexture.new()
		top_atlas.atlas = strip_tex
		top_atlas.region = Rect2(0, 0, sw, cut)
		scenery.texture = top_atlas
		scenery.stretch_mode = TextureRect.STRETCH_SCALE
		band_scenery = AtlasTexture.new()
		band_scenery.atlas = strip_tex
		band_scenery.region = Rect2(0, cut, sw, sh - cut)
	else:
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color("21170f"), Color("100c09"), Color("2b1711")])
		gradient.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
		var fallback := GradientTexture2D.new()
		fallback.gradient = gradient
		fallback.fill_from = Vector2(0.0, 0.5)
		fallback.fill_to = Vector2(1.0, 0.5)
		scenery.texture = fallback
	header.add_child(scenery)
	var scenery_shade := ColorRect.new()
	scenery_shade.color = Color(UIKit.SHADE, 0.45 if not _mobile else 0.08)
	scenery_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scenery_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	scenery.add_child(scenery_shade)
	var band := PanelContainer.new()
	band.name = "TourTopBar"
	band.custom_minimum_size.y = 48 if _mobile else 70
	var band_style := UIKit.band_style()
	if not _mobile:
		band_style.bg_color = Color(0, 0, 0, 0)
	band_style.border_width_top = 1
	band_style.content_margin_top = 0
	band_style.content_margin_bottom = 0
	band.add_theme_stylebox_override("panel", band_style)
	header.add_child(band)
	if not _mobile:
		var band_bg := TextureRect.new()
		band_bg.name = "BandScenery"
		band_bg.texture = band_scenery
		band_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		band_bg.stretch_mode = TextureRect.STRETCH_SCALE
		band_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.add_child(band_bg)
		var band_tint := ColorRect.new()
		band_tint.color = Color(0.025, 0.018, 0.012, 0.8)
		band_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band_bg.add_child(band_tint)
		band_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	var double_frame := Control.new()
	double_frame.name = "DoubleGoldFrame"
	double_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	double_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	double_frame.draw.connect(func() -> void:
		var fw := double_frame.size.x
		var fh := double_frame.size.y
		if _mobile:
			for y in [1.0, 3.0, fh - 2.0, fh - 4.0]:
				double_frame.draw_line(Vector2(2, y), Vector2(fw - 2, y), Color(UIKit.GOLD, 0.42 if int(y) % 2 == 1 else 0.2), 1.0, true)
			return
		double_frame.draw_line(Vector2(0, 1), Vector2(fw, 1), Color(UIKit.GOLD, 0.85), 2.0)
		double_frame.draw_line(Vector2(0, 4.5), Vector2(fw, 4.5), Color(UIKit.GOLD_DIM, 0.4), 1.0)
		double_frame.draw_line(Vector2(0, fh - 8.5), Vector2(fw, fh - 8.5), Color(UIKit.GOLD_DIM, 0.45), 1.0)
		double_frame.draw_rect(Rect2(0, fh - 5, fw, 4), Color(UIKit.GOLD, 0.78))
		double_frame.draw_line(Vector2(0, fh - 3.5), Vector2(fw, fh - 3.5), Color(1.0, 0.92, 0.66, 0.6), 1.0))
	band.add_child(double_frame)
	var inset := MarginContainer.new()
	inset.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		inset.add_theme_constant_override("margin_" + side, 4 if _mobile else 8)
	for side in ["top", "bottom"]:
		inset.add_theme_constant_override("margin_" + side, 0)
	band.add_child(inset)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 7 if _mobile else 6)
	top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inset.add_child(top)
	if not _mobile:
		top.add_child(_royal_asset_slot("lion", Vector2(66, 52), false))
	var bust_slot := _royal_asset_slot("king_bust", Vector2(42, 44) if _mobile else Vector2(112, 52), false)
	top.add_child(bust_slot)
	if not _mobile:
		var royal_title_gap := Control.new()
		royal_title_gap.custom_minimum_size.x = 4
		royal_title_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top.add_child(royal_title_gap)
		top.add_child(_header_symbol("lily", Vector2(30, 36), UIKit.GOLD, true))
		top.add_child(_header_separator(42))
	var king := Label.new()
	king.text = tr("KRAL ADRİAN IV")
	var title_font := FontVariation.new()
	title_font.base_font = UIKit.serif()
	title_font.spacing_glyph = 1
	king.add_theme_font_override("font", title_font)
	king.add_theme_font_size_override("font_size", _fs(36))
	king.add_theme_color_override("font_color", Color("e8cb86"))
	king.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	king.add_theme_constant_override("shadow_offset_x", 2)
	king.add_theme_constant_override("shadow_offset_y", 2)
	king.visible = not _mobile
	top.add_child(king)
	if not _mobile:
		top.add_child(_header_separator(42))
	var week_plate := PanelContainer.new()
	week_plate.name = "WeekPlate"
	week_plate.custom_minimum_size = Vector2(186 if not _mobile else 138, 44 if _mobile else 46)
	week_plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	week_plate.add_theme_stylebox_override("panel", _week_plate_style() if not _mobile else UIKit.box(Color("100d09"), Color(UIKit.GOLD_DIM, 0.75), 2, 5))
	top.add_child(week_plate)
	if not _mobile:
		week_plate.draw.connect(_draw_week_plate.bind(week_plate))
	var wk := VBoxContainer.new()
	wk.add_theme_constant_override("separation", 1)
	week_plate.add_child(wk)
	var week_label_row := HBoxContainer.new()
	week_label_row.alignment = BoxContainer.ALIGNMENT_CENTER
	week_label_row.add_theme_constant_override("separation", 5)
	wk.add_child(week_label_row)
	week_label_row.add_child(_header_symbol("diamond", Vector2(10, 10) if _mobile else Vector2(20, 20), UIKit.GOLD, true))
	_header_week = Label.new()
	_header_week.add_theme_font_override("font", UIKit.serif())
	_header_week.add_theme_font_size_override("font_size", _fs(17))
	_header_week.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	week_label_row.add_child(_header_week)
	_header_progress = ProgressBar.new()
	_header_progress.max_value = Sim.MAX_WEEKS
	_header_progress.show_percentage = false
	_header_progress.custom_minimum_size = Vector2(150 if not _mobile else 124, 4)
	wk.add_child(_header_progress)
	var crest_slot := _royal_asset_slot("crest", Vector2(60, 58), false)
	top.add_child(crest_slot)
	if not _mobile:
		var crest_gap := Control.new()
		crest_gap.custom_minimum_size.x = 2
		crest_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top.add_child(crest_gap)
	_header_mesai = Label.new()
	_header_mesai.add_theme_font_override("font", UIKit.sans())
	_header_mesai.add_theme_font_size_override("font_size", _fs(20 if _mobile else 17))
	_header_mesai.add_theme_color_override("font_color", UIKit.GOLD)
	_header_mesai.tooltip_text = tr("Mesai: bu hafta kalan eylem hakkın.")
	_header_mesai.mouse_filter = Control.MOUSE_FILTER_STOP
	_header_mesai.visible = false
	var mesai_row := HBoxContainer.new()
	mesai_row.add_theme_constant_override("separation", 7)
	mesai_row.mouse_filter = Control.MOUSE_FILTER_STOP
	mesai_row.tooltip_text = _header_mesai.tooltip_text
	_mesai_box = HBoxContainer.new()
	_mesai_box.add_theme_constant_override("separation", 7)
	_mesai_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mesai_box.tooltip_text = _header_mesai.tooltip_text
	_mesai_box.mouse_filter = Control.MOUSE_FILTER_STOP
	if not _mobile:
		var mesai_gap := Control.new()
		mesai_gap.custom_minimum_size.x = 10
		mesai_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mesai_row.add_child(mesai_gap)
	mesai_row.add_child(_mesai_box)
	top.add_child(mesai_row)
	top.add_child(_header_separator(42))
	_header_wealth = Label.new()
	_header_wealth.add_theme_font_override("font", UIKit.sans())
	_header_wealth.add_theme_font_size_override("font_size", _fs(19 if _mobile else 17))
	_header_wealth.tooltip_text = tr("Kişisel servet: devlet bütçesinden ayrı, gizli işlerin için.")
	_header_wealth.mouse_filter = Control.MOUSE_FILTER_STOP
	top.add_child(_stat("res://art/icons/servet.png", _header_wealth))
	if not _mobile:
		top.add_child(_header_symbol("endcap", Vector2(18, 40), UIKit.GOLD))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	_header_nav(top, "desk", tr("Masa"), "building", _show_desk)
	(_buttons["desk"] as Button).tooltip_text = tr("Çalışma masası: gündem, gazete, kişiler, günlük, dosyalar, hanedan ve başkent haritası.")
	top.add_child(_header_separator(32 if _mobile else 40))
	_header_nav(top, "media", tr("Medya"), "newspaper", _open_media)
	(_buttons["media"] as Button).tooltip_text = tr("Medya Merkezi: Sarne'nin gazetesi, Leyla'nın bağımsız gazetesi ve Sarne TV. İkisini karşılaştır; biri yalan söylüyor olabilir.")
	top.add_child(_header_separator(32 if _mobile else 40))
	var save_nav := _header_nav(top, "save", tr("Kaydet"), "hourglass" if not _mobile else "seal", _on_save)
	var save_separator := _header_separator(32 if _mobile else 40)
	top.add_child(save_separator)
	_header_nav(top, "menu", tr("Menü"), "gear", _show_menu)
	if _mobile:
		# Dar ekranda otomatik kayıt var; kısa gezinme etiketleri ve kral büstü kalır.
		save_nav.visible = false
		save_separator.visible = false
	else:
		var right_lion_slot := _royal_asset_slot("lion", Vector2(66, 52), true)
		right_lion_slot.name = "RightLionSlot"
		top.add_child(right_lion_slot)
	# Reserve heraldic slots even when a platform build omits the optional art.
	var bust := bust_slot.get_child(0) as TextureRect
	if bust.texture != null:
		bust.set_anchors_preset(Control.PRESET_TOP_LEFT)
		bust.position = Vector2(-3, -10) if _mobile else Vector2(-22, -66)
		bust.size = Vector2(52, 60) if _mobile else Vector2(150, 140)
	var crest := crest_slot.get_child(0) as TextureRect
	if crest.texture != null:
		crest.set_anchors_preset(Control.PRESET_TOP_LEFT)
		crest.position = Vector2(-22, -62)
		crest.size = Vector2(104, 116)
	for lion_slot in header.find_children("LionSlot", "Control", true, false) + header.find_children("RightLionSlot", "Control", true, false):
		var lion := lion_slot.get_child(0) as TextureRect
		if lion.texture != null:
			lion.set_anchors_preset(Control.PRESET_TOP_LEFT)
			lion.size = Vector2(100, 132)
			lion.pivot_offset = lion.size / 2.0
			# Aslanlar ekranın kenarına dayanır ve dışa bakar (mockup).
			lion.position = Vector2(-18, -64) if lion_slot.name != "RightLionSlot" else Vector2(lion_slot.custom_minimum_size.x - lion.size.x + 32.0, -64)
	if _mobile:
		# The mobile crest slot stays narrow but the art remains hidden on this size.
		crest_slot.visible = false


## Hafta plakası: uçları sivri, ince çift altın çizgili koyu plaka (mockup).
func _week_plate_style() -> StyleBox:
	var sb := StyleBoxEmpty.new()
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 4
	sb.content_margin_bottom = 5
	return sb


func _draw_week_plate(c: Control) -> void:
	var w := c.size.x
	var h := c.size.y
	var tip := 16.0
	var outer := PackedVector2Array([Vector2(tip, 0), Vector2(w - tip, 0), Vector2(w, h * 0.5), Vector2(w - tip, h), Vector2(tip, h), Vector2(0, h * 0.5), Vector2(tip, 0)])
	c.draw_colored_polygon(outer, Color("0d0a07"))
	c.draw_polyline(outer, Color(UIKit.GOLD, 0.85), 1.4, true)
	var inner := PackedVector2Array([Vector2(tip + 3, 4), Vector2(w - tip - 3, 4), Vector2(w - 6, h * 0.5), Vector2(w - tip - 3, h - 4), Vector2(tip + 3, h - 4), Vector2(6, h * 0.5), Vector2(tip + 3, 4)])
	c.draw_polyline(inner, Color(UIKit.GOLD_DIM, 0.45), 1.0, true)


const HEADER_ART_TR := "res://art/ui/header_tr.png"     # onaylı mockup başlığı (yazısı gömülü)
const HEADER_ART_BASE := "res://art/ui/header_base.png" # aynı resim, unvan yazısı silinmiş (diğer diller)
const HEADER_ART_W := 1492.0
const HEADER_ART_H := 118.0
var _header_art: TextureRect
var _header_title: Label


## Masaüstü başlığı: mockup'ın kendisi (aslanlar, büst, arma, çerçeveler) resim olarak; değişen bilgiler
## (hafta, mesai, servet, gezinme) resimdeki yerlerine, mockup ölçüleriyle yerleştirilir.
func _build_header_art(parent: Control) -> void:
	var header := Control.new()
	header.name = "RoyalHeader"
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(header)
	_header_art = TextureRect.new()
	_header_art.name = "TourTopBar"
	_header_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_header_art.stretch_mode = TextureRect.STRETCH_SCALE
	_header_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_header_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_header_art)
	var cream := Color("ece3cc")
	_header_title = Label.new()
	_header_title.text = tr("KRAL ADRİAN IV")
	_header_title.add_theme_font_override("font", UIKit.serif())
	_header_title.add_theme_color_override("font_color", Color("e8cb86"))
	_header_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	_header_title.add_theme_constant_override("shadow_offset_y", 2)
	_header_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_header_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header_art.add_child(_header_title)
	_header_week = Label.new()
	_header_week.add_theme_font_override("font", UIKit.serif())
	_header_week.add_theme_color_override("font_color", Color("efe9dc"))
	_header_week.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_header_week.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_header_week.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header_art.add_child(_header_week)
	_header_progress = ProgressBar.new()
	_header_progress.max_value = Sim.MAX_WEEKS
	_header_progress.show_percentage = false
	_header_progress.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("f2d48a")
	_header_progress.add_theme_stylebox_override("fill", fill)
	_header_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header_art.add_child(_header_progress)
	_header_mesai = Label.new()
	_header_mesai.visible = false
	_header_art.add_child(_header_mesai)
	_mesai_box = HBoxContainer.new()
	_mesai_box.add_theme_constant_override("separation", 4)
	_mesai_box.tooltip_text = tr("Mesai: bu hafta kalan eylem hakkın.")
	_mesai_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_header_art.add_child(_mesai_box)
	_header_wealth = Label.new()
	_header_wealth.add_theme_font_override("font", UIKit.sans())
	_header_wealth.add_theme_color_override("font_color", cream)
	_header_wealth.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_header_wealth.tooltip_text = tr("Kişisel servet: devlet bütçesinden ayrı, gizli işlerin için.")
	_header_wealth.mouse_filter = Control.MOUSE_FILTER_STOP
	_header_art.add_child(_header_wealth)
	# Gezinme: resimdeki simge + yazı alanını kaplayan saydam düğmeler; yazı simgenin sağından başlar.
	var nav := [
		["desk", tr("Masa"), _show_desk, 982.0, 1062.0, 1021.0],
		["media", tr("Medya"), _open_media, 1074.0, 1220.0, 1112.0],
		["save", tr("Kaydet"), _on_save, 1230.0, 1320.0, 1268.0],
		["menu", tr("Menü"), _show_menu, 1332.0, 1412.0, 1371.0],
	]
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(UIKit.GOLD, 0.08)
	for item in nav:
		var b := Button.new()
		b.text = item[1]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.flat = true
		b.focus_mode = Control.FOCUS_ALL
		b.add_theme_font_override("font", UIKit.serif())
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(c, cream if c != "font_hover_color" else Color("fff3d0"))
		b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		b.add_theme_stylebox_override("hover", hover)
		b.add_theme_stylebox_override("pressed", hover)
		b.set_meta("art_span", Vector3(item[3], item[4], item[5]))
		_wire(b)
		b.pressed.connect(item[2])
		_header_art.add_child(b)
		_buttons[item[0]] = b
	(_buttons["desk"] as Button).tooltip_text = tr("Çalışma masası: gündem, gazete, kişiler, günlük, dosyalar, hanedan ve başkent haritası.")
	(_buttons["media"] as Button).tooltip_text = tr("Medya Merkezi: Sarne'nin gazetesi, Leyla'nın bağımsız gazetesi ve Sarne TV. İkisini karşılaştır; biri yalan söylüyor olabilir.")
	var place := func() -> void:
		# Başlık sayfa kenar boşluklarını aşar: resim pencere genişliğinde, oranı korunur.
		var side := 18.0
		var art_w := header.size.x + side * 2.0
		var k := art_w / HEADER_ART_W
		header.custom_minimum_size.y = HEADER_ART_H * k - 8.0   # haber şeridi başlığın hemen altına oturur
		_header_art.position = Vector2(-side, 0)
		_header_art.size = Vector2(art_w, HEADER_ART_H * k)
		var tr_title := Sfx.language != "en"
		_header_art.texture = load(HEADER_ART_TR if tr_title else HEADER_ART_BASE)
		_header_title.visible = not tr_title
		_header_title.text = tr("KRAL ADRİAN IV")
		_header_title.add_theme_font_size_override("font_size", roundi(32 * k))
		_header_title.position = Vector2(272, 62) * k
		_header_title.size = Vector2(300, 38) * k
		_header_week.add_theme_font_size_override("font_size", roundi(16 * k))
		_header_week.position = Vector2(582, 72) * k
		_header_week.size = Vector2(112, 22) * k
		_header_progress.position = Vector2(579, 95.2) * k
		_header_progress.size = Vector2(128, 1.6) * k
		_mesai_box.position = Vector2(766, 75) * k
		_header_wealth.add_theme_font_size_override("font_size", roundi(19 * k))
		_header_wealth.position = Vector2(922, 72) * k
		_header_wealth.size = Vector2(40, 26) * k
		for key in ["desk", "media", "save", "menu"]:
			var b := _buttons[key] as Button
			var span: Vector3 = b.get_meta("art_span")
			b.position = Vector2(span.x, 66) * k
			b.size = Vector2(span.y - span.x, 42) * k
			# Yazı simgeden sonraki alana sığmazsa küçülür (ör. "Medya · yeni sayı", İngilizce metinler).
			var room := (span.y - span.z) * k - 4.0
			var fsize := roundi(15.5 * k)
			while fsize > 9 and UIKit.serif().get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x > room:
				fsize -= 1
			b.add_theme_font_size_override("font_size", fsize)
			var pad := StyleBoxEmpty.new()
			pad.content_margin_left = (span.z - span.x) * k
			b.add_theme_stylebox_override("normal", pad)
			var hv := hover.duplicate() as StyleBoxFlat
			hv.content_margin_left = pad.content_margin_left
			b.add_theme_stylebox_override("hover", hv)
			b.add_theme_stylebox_override("pressed", hv)
			b.add_theme_stylebox_override("focus", pad)
	header.resized.connect(place)
	header.set_meta("place", place)
	place.call_deferred()


func _royal_asset_slot(name: String, slot_size: Vector2, mirrored: bool) -> Control:
	var slot := Control.new()
	slot.name = name.capitalize() + "Slot"
	slot.custom_minimum_size = slot_size
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex := TextureRect.new()
	tex.name = "Art"
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.texture = _art("res://art/ui/%s.png" % name)
	tex.visible = tex.texture != null
	if mirrored:
		tex.scale.x = -1.0
		tex.pivot_offset = slot_size / 2.0
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(tex)
	return slot


func _header_separator(height: int) -> ColorRect:
	var separator := ColorRect.new()
	separator.color = Color(UIKit.GOLD_DIM, 0.42)
	separator.custom_minimum_size = Vector2(1, height)
	separator.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return separator


func _header_symbol(kind: String, icon_size: Vector2, color: Color, filled := false) -> Control:
	if kind == "lily" and filled and ResourceLoader.exists("res://art/ui/fleur.png"):
		var fleur := TextureRect.new()
		fleur.texture = load("res://art/ui/fleur.png")
		fleur.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fleur.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fleur.custom_minimum_size = icon_size
		fleur.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fleur.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fleur.modulate = Color.WHITE if color == UIKit.GOLD else Color(color, 1.0)
		return fleur
	var icon: Control = ORNAMENT_ICON.new()
	icon.set("kind", kind)
	icon.set("line_color", color)
	icon.set("filled", filled)
	icon.custom_minimum_size = icon_size
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _header_nav(parent: Control, key: String, text: String, icon_kind: String, callback: Callable) -> HBoxContainer:
	var group := HBoxContainer.new()
	group.add_theme_constant_override("separation", 5 if _mobile else 8)
	group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	group.add_child(_header_symbol(icon_kind, Vector2(26, 26) if not _mobile else Vector2(24, 24), UIKit.GOLD))
	var button := Button.new()
	button.text = text
	button.theme_type_variation = "GhostButton"
	button.custom_minimum_size = Vector2(44 if _mobile else 0, 44 if _mobile else 36)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_override("font", UIKit.sans())
	button.add_theme_font_size_override("font_size", _fs(14 if not _mobile else 13))
	button.add_theme_color_override("font_color", UIKit.TEXT)
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	var nav_hover := StyleBoxFlat.new()
	nav_hover.bg_color = Color(UIKit.GOLD, 0.08)
	nav_hover.content_margin_left = 2
	nav_hover.content_margin_right = 2
	button.add_theme_stylebox_override("hover", nav_hover)
	button.add_theme_stylebox_override("pressed", nav_hover)
	_wire(button)
	button.pressed.connect(callback)
	group.add_child(button)
	parent.add_child(group)
	_buttons[key] = button
	return group


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
	if not _mobile:
		mat.set_shader_parameter("grain", 0.018)   # mockup: temiz yüzey, belirgin gren yok
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
		t += tr("Saltanat sayısı: %d   ·   Tahtta kalan: %d   ·   En uzun saltanat: %s\n\n") % [list.size(), wins, tr("%d hafta") % best]
		for i in range(list.size() - 1, -1, -1):
			var r: Dictionary = list[i]
			var mark := "[color=#7fae7a]%s[/color]" % tr("TAHTTA") if r["survived"] else "[color=#c0504a]%s[/color]" % tr("DÜŞTÜ")
			t += "%s  [b]%s[/b]   [color=gray]%s · %s · %s[/color]\n     %s\n" % [mark, tr(str(r["title"])), r["date"], tr(str(r["difficulty"])), tr("%d hafta") % int(r["weeks"]), Sim.chronicle_cause(r)]
	var have: Dictionary = Sim.load_achievements()
	t += tr("\n[b][font_size=%d][color=#d6b25e]BAŞARIMLAR  ·  %d / %d[/color][/font_size][/b]\n") % [_fs(24), have.size(), Sim.ACHIEVEMENTS.size()]
	for id in Sim.ACHIEVEMENTS:
		var info: Array = Sim.ACHIEVEMENTS[id]
		if have.has(id):
			t += "[color=#d6b25e]»[/color]  [b]%s[/b]  [color=gray]%s · %s[/color]\n" % [tr(str(info[0])), tr(str(info[1])), have[id]]
		else:
			t += "[color=#55524c]·  %s  ·  %s[/color]\n" % [tr(str(info[0])), tr(str(info[1]))]
	var extension_have: Dictionary = Sim.load_achievements(true)
	if not extension_have.is_empty():
		t += tr("\n[b][font_size=%d][color=#d6b25e]UZATMA BAŞARIMLARI[/color][/font_size][/b]\n") % _fs(24)
		for id in extension_have:
			var info: Array = Sim.ACHIEVEMENTS.get(id, [id, ""])
			t += "[color=#d6b25e]»[/color]  [b]%s[/b]  [color=gray]%s · %s[/color]\n" % [tr(str(info[0])), tr(str(info[1])), extension_have[id]]
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
	b.mouse_entered.connect(func() -> void:
		if not TOUCH_SCROLL.dispatching_touch: Sfx.play("hover", -12.0))
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
	l.add_theme_font_size_override("font_size", _fs(15 if _mobile else 16))
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
		h.add_theme_font_override("font", UIKit.sans())
		h.add_theme_font_size_override("font_size", _fs(13))
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
	if _mobile:
		_hint(tr("Son eylem") + "\n" + text)  # sonuç bildirim kaybolsa da burada kalır (masaüstünde Bu Hafta defterinde)
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
		c.color = Color.from_hsv(hue, 0.12 if (id.begins_with("governor_") or id.begins_with("commander_")) else 0.35, 0.22 if (id.begins_with("governor_") or id.begins_with("commander_")) else 0.34)
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

## Logo açılışından sonra gelen giriş ekranı; tıklanınca menüye düşer.
func _show_title() -> void:
	if get_tree().current_scene != self:
		return   # yalnızca uygulama açılışında; testler ve geliştirme akışları atlar
	var title := TITLE_SCREEN.new(self)
	add_child(title)
	title.grab_focus()


func _show_menu() -> void:
	_menu.show()
	_update_music()
	_menu_show_page("main")
	# İlk düğme duruma göre: oyun sürüyorsa "Oyuna Dön", yoksa kayıttan "Devam Et".
	var b_first := _menu.get_meta("first") as Button
	var b_new := _menu.get_meta("new") as Button
	var b_dynasty := _menu.get_meta("dynasty") as Button
	var in_game: bool = not Sim.ended and not Sim.actors.is_empty()
	b_dynasty.visible = not in_game and Sim.can_continue_dynasty()
	if in_game:
		b_first.text = tr("Oyuna Dön")
		b_first.disabled = false
	else:
		b_first.disabled = not Sim.has_save()
		b_first.text = tr("Devam Et") if not Sim.has_save() else tr("Devam Et  ·  %s") % Sim.save_summary()
	var first_primary: bool = in_game or Sim.has_save()
	b_first.theme_type_variation = "PrimaryButton" if first_primary else ""
	b_new.theme_type_variation = "" if first_primary else "PrimaryButton"
	if not _instant and not Sfx.reduce_motion:
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
		_update_music()
		return
	var tw := _menu.create_tween()
	tw.tween_property(_menu, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func() -> void:
		_menu.hide()
		_menu.modulate.a = 1.0
		_update_music())


func _request_new_game() -> void:
	var in_progress: bool = not Sim.actors.is_empty() and not Sim.ended and Sim.week > 1
	var selected_scenario := str(_menu.scenario_id)
	if in_progress or (Sim.actors.is_empty() and Sim.has_save()):
		_show_modal(tr("[b][font_size=%d][color=#d6b25e]Yeni saltanat[/color][/font_size][/b]\n\nSüren ya da kayıtlı bir saltanat var. Yeni bir oyuna başlarsan otomatik kayıt da üzerine yazılacak.\n\nDevam etmek istiyor musun?") % _fs(26),
			tr("Yeni oyuna başla"), _start_new.bind(0, -1, false, selected_scenario))
	else:
		_start_new(0, -1, false, selected_scenario)


func _request_dynasty_game() -> void:
	if not Sim.can_continue_dynasty():
		return
	var legacy := Sim.dynasty_legacy()
	var in_progress: bool = not Sim.actors.is_empty() and not Sim.ended and Sim.week > 1
	if in_progress or (Sim.actors.is_empty() and Sim.has_save()):
		_show_modal(tr("Süren ya da kayıtlı bir saltanat var. Hanedan devam ederse bu kayıt üzerine yazılacak."),
			tr("Hanedan Devam"), _start_new.bind(0, Sfx.difficulty, false, "", legacy))
	else:
		_start_new(0, Sfx.difficulty, false, "", legacy)


func _request_daily_game() -> void:
	var in_progress: bool = not Sim.actors.is_empty() and not Sim.ended and Sim.week > 1
	if in_progress or (Sim.actors.is_empty() and Sim.has_save()):
		_show_modal(tr("Süren ya da kayıtlı bir saltanat var. Günlük oyuna başlarsan otomatik kayıt üzerine yazılacak."),
			tr("Günlük oyuna başla"), _begin_daily_game)
	else:
		_begin_daily_game()


func _begin_daily_game() -> void:
	_daily_date = Time.get_date_string_from_system(true)
	_daily_seed = Sim.daily_seed(_daily_date)
	_start_new(_daily_seed, 1, true)


func _start_new(seed_value := 0, diff := -1, daily := false, scenario := "", legacy: Dictionary = {}) -> void:
	_daily_run = daily
	Sim.save_path = Sim.DEFAULT_SAVE_PATH
	Sim.new_game(seed_value, diff if diff >= 0 else Sfx.difficulty, scenario, legacy)
	if Sim.content_error != "":
		_show_modal(tr("[b]İçerik yüklenemedi[/b]\n\n%s") % Sim.content_error)
		return
	if not _instant and Sfx.intro:   # kısa geçişlerde de oynar; sahne "Geç" ile atlanır
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


func _continue_endless() -> void:
	if Sim.continue_endless():
		_after_load(tr("Uzatma başladı. Saltanatın artık ayrı kaydediliyor."))
	else:
		_show_modal(tr("Uzatma kaydedilemedi."))


func _after_load(message: String) -> void:
	_end_overlay.hide()
	_hide_menu()
	_journal.clear()
	_headline.text = ""
	_headline_secondary.text = ""
	_headline_diamond.visible = false
	_headline_band.visible = false
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
		"region":
			var pending_before := Sim.pending.size()
			_toast_msg(Sim.request_regional_decision(arg))
			if Sim.pending.size() > pending_before:
				_city.close_view()
				_refresh()
		"media":
			_open_media()
		"files":
			_city.close_view()
			_desk.close_view()
			_select_tab(_files_tab)
		"actor":
			_city.close_view()
			_desk.close_view()
			_open_person_file(arg)


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
		_vibrate()
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
	_vibrate()
	if not had_crisis and not Sim.ended and Sim.active_crisis_label() != "":
		Sfx.play("alert", -3.0)
		_vibrate(150)
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
			if not Sfx.reduce_motion:
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
	var seal: Control
	var seal_tex: Texture2D = _art("res://art/damga.png")
	if seal_tex:
		sz *= 1.7   # damga halkası ve yazısıyla daha büyük görünür
		var img := TextureRect.new()
		img.texture = seal_tex
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		seal = img
	else:
		var disk := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("7a1f1a")
		sb.set_corner_radius_all(int(sz / 2.0))
		sb.border_color = Color("c9a24f")
		sb.set_border_width_all(3)
		sb.shadow_color = Color(0, 0, 0, 0.55)
		sb.shadow_size = 10
		sb.anti_aliasing = true
		disk.add_theme_stylebox_override("panel", sb)
		disk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var l := Label.new()
		l.text = "V"
		l.add_theme_font_override("font", UIKit.serif())
		l.add_theme_font_size_override("font_size", int(sz * 0.55))
		l.add_theme_color_override("font_color", Color("f1d9a0"))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		disk.add_child(l)
		seal = disk
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


func _open_person_file(id: String) -> void:
	if not Sim.actors.has(id):
		return
	if _person_file != null:
		_person_file.open(id)
		return
	_sel = [id]
	_style_cards()
	_update_info()
	_divan.refresh()
	if _mobile:
		_tabs.current_tab = 1


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
		"deny", "apologize", "scapegoat", "redirect":
			_acted_week = Sim.week
			_log(Sim.respond_to_scandal(fid, kind))
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


func _open_budget_editor(pending_index: int, choice_index: int) -> void:
	if _budget_editor != null or pending_index < 0 or pending_index >= Sim.pending.size():
		return
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24 if _mobile else 120)
	margin.add_theme_constant_override("margin_right", 24 if _mobile else 120)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	center.add_child(margin)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIKit.box(Color(0.08, 0.07, 0.06, 0.98), Color.TRANSPARENT, 4, 22))
	margin.add_child(panel)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	panel.add_child(body)
	UIKit.ornament(panel, Color(UIKit.GOLD, 0.85), 18, 1)
	var title := Label.new()
	title.text = tr("Özel bütçe dağılımı")
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", _fs(21))
	title.add_theme_color_override("font_color", UIKit.GOLD)
	body.add_child(title)
	var sectors := ["army", "social", "industry", "palace"]
	var labels := [tr("Ordu ve güvenlik"), tr("Sosyal harcama"), tr("Altyapı ve sanayi"), tr("Saray ve vakıf")]
	var fx: Dictionary = Sim.pending[pending_index]["event"]["choices"][choice_index].get("fx", {})
	var starting: Dictionary = fx.get("budget_allocation", Sim.budget_allocation)
	_budget_editor_spins.clear()
	for i in sectors.size():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.custom_minimum_size.y = 44
		body.add_child(row)
		var label := Label.new()
		label.text = labels[i]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_override("font", UIKit.sans(470))
		label.add_theme_font_size_override("font_size", _fs(15))
		row.add_child(label)
		var share := SpinBox.new()
		share.min_value = 0
		share.max_value = 100
		share.step = 1
		share.rounded = true
		share.custom_minimum_size = Vector2(112, 44)
		share.value = float(starting.get(sectors[i], 25.0))
		share.add_theme_font_size_override("font_size", _fs(15))
		row.add_child(share)
		_budget_editor_spins.append(share)
	var total := Label.new()
	total.add_theme_font_override("font", UIKit.sans(470))
	total.add_theme_font_size_override("font_size", _fs(14))
	body.add_child(total)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	body.add_child(buttons)
	var apply := Button.new()
	apply.text = tr("Dağılımı uygula")
	apply.custom_minimum_size.y = 44
	apply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	apply.theme_type_variation = "PrimaryButton"
	apply.add_theme_font_override("font", UIKit.caps())
	_wire(apply)
	buttons.add_child(apply)
	var cancel := Button.new()
	cancel.text = tr("Vazgeç")
	cancel.custom_minimum_size.y = 44
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel.theme_type_variation = "GhostButton"
	cancel.add_theme_font_override("font", UIKit.caps())
	_wire(cancel)
	buttons.add_child(cancel)
	for share in _budget_editor_spins:
		share.value_changed.connect(func(_value: float) -> void: _update_budget_editor_total(total, apply))
	apply.pressed.connect(func() -> void: _apply_budget_editor(pending_index, choice_index, sectors))
	cancel.pressed.connect(_close_budget_editor)
	_budget_editor = overlay
	add_child(overlay)
	_update_budget_editor_total(total, apply)


func _update_budget_editor_total(total: Label, apply: Button) -> void:
	var sum := 0
	for share in _budget_editor_spins:
		sum += int(share.value)
	total.text = tr("Toplam: %d") % sum if sum == 100 else tr("Dört kalemin toplamı 100 olmalı.") + "  (%d)" % sum
	apply.disabled = sum != 100


func _apply_budget_editor(pending_index: int, choice_index: int, sectors: Array) -> void:
	if pending_index >= Sim.pending.size() or _budget_editor_spins.size() != sectors.size():
		return
	var allocation := {}
	for i in sectors.size():
		allocation[sectors[i]] = float(_budget_editor_spins[i].value)
	var event: Dictionary = Sim.pending[pending_index]["event"]
	var choice: Dictionary = event["choices"][choice_index]
	var fx: Dictionary = choice.get("fx", {}).duplicate(true)
	fx["budget_allocation"] = allocation
	fx.erase("budget_custom")
	choice["fx"] = fx
	event["choices"][choice_index] = choice
	_close_budget_editor()
	_choose(pending_index, choice_index)


func _close_budget_editor() -> void:
	if is_instance_valid(_budget_editor):
		_budget_editor.queue_free()
	_budget_editor = null
	_budget_editor_spins.clear()


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
	_vibrate()
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
	_update_music()
	if _header_week == null or Sim.actors.is_empty():
		return
	_header_week.text = tr("HAFTA %d / %d") % [Sim.week, Sim.MAX_WEEKS]
	if _header_art != null and _header_art.texture != load(HEADER_ART_TR if Sfx.language != "en" else HEADER_ART_BASE):
		(_header_art.get_parent().get_meta("place") as Callable).call()   # dil değişti: unvan resmi/yazısı
	if _fast() or _header_progress.value > Sim.week:
		_header_progress.value = Sim.week
	elif _header_progress.value < Sim.week:
		create_tween().tween_property(_header_progress, "value", float(Sim.week), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_update_mesai_pips()
	_pulse_end_button()
	if _tabs != null:
		var waiting: int = Sim.pending.size()
		_tabs.set_tab_title(0, tr("Gündem") + ("  ·  %d" % waiting if waiting > 0 else ""))
	var mb := _buttons.get("media") as Button
	if mb:
		var fresh_issue: bool = _media_seen_week != Sim.week
		mb.text = (tr("Medya •") if _mobile else tr("Medya  ·  yeni sayı")) if fresh_issue else tr("Medya")
		if _header_art != null and mb.has_meta("art_span"):
			(_header_art.get_parent().get_meta("place") as Callable).call()
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
	if not items.is_empty():
		_flow.add_child(_header_symbol("flourish", Vector2(14, 14), UIKit.GOLD))
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
	b.add_theme_font_override("font", UIKit.sans())
	b.add_theme_font_size_override("font_size", _fs(15))
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
	var ready: bool = Sim.pending.is_empty() and Sim.mesai == 0 and not Sim.ended and not _fast() and not Sfx.reduce_motion
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
	_journal.append_text("• %s\n" % Sim.economy_journal_line())
	_journal.append_text("• %s\n" % Sim.parliament_report_line())
	_journal.append_text("• %s\n" % Sim.parliament_laws_line())
	_journal.append_text("• %s\n" % Sim.region_report_line())
	_journal.append_text("• %s\n" % Sim.army_report_line())
	_tabs.current_tab = 0


func _apply_headline_mode() -> void:
	if _headline == null:
		return
	if _headline_expanded:
		_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_headline.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		_headline_secondary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_headline_secondary.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		_headline_band.custom_minimum_size.y = 48 if _mobile else 30
	else:
		_headline.autowrap_mode = TextServer.AUTOWRAP_OFF
		_headline.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_headline_secondary.autowrap_mode = TextServer.AUTOWRAP_OFF
		_headline_secondary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_headline_band.custom_minimum_size.y = 32 if _mobile else 30


## Haber öğeleri satırda art arda akar: ilk öğe metni kadar yer alır (en çok satırın %62'si), ikincisi kalanı doldurur.
func _fit_headline() -> void:
	if _headline == null or _headline_secondary == null:
		return
	if _headline_expanded:
		_headline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		return
	var font := _headline.get_theme_font("font")
	var fs := _headline.get_theme_font_size("font_size")
	var want := font.get_string_size(_headline.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 6.0
	var room := maxf(_headline_band.size.x - 60.0, 200.0)
	_headline.size_flags_horizontal = Control.SIZE_FILL
	_headline.custom_minimum_size.x = minf(want, room * (0.62 if _headline_secondary.text != "" else 1.0))
	_headline_secondary.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _update_headline() -> void:
	var items: Array[String] = []
	if _headline_notice != "":
		items.append(_headline_notice)
	for item in _headline_items().slice(0, 1):
		items.append(Sim.news_for_display(str(item)))
	if items.size() < 2 and Sfx.tips and AGENDA_VIEW.ADVICE.has(Sim.week):
		items.append(tr(str(AGENDA_VIEW.ADVICE[Sim.week])))
	_headline.text = items[0] if not items.is_empty() else ""
	_headline_secondary.text = items[1] if items.size() > 1 else ""
	_headline.tooltip_text = _headline.text
	_headline_secondary.tooltip_text = _headline_secondary.text
	_headline_diamond.visible = _headline_secondary.text != ""
	_apply_headline_mode()
	_fit_headline()
	# Mobilde dikey alan kıt: haber şeridi yalnızca Gündem sekmesinde görünür.
	_headline_band.visible = _headline.text != "" and (not _mobile or _tabs.current_tab == 0)


func _on_news(_text: String) -> void:
	pass


func _on_end(record: Dictionary) -> void:
	if _daily_run:
		record["daily_date"] = _daily_date
		record["daily_seed"] = _daily_seed
		Sim.save_daily_result(_daily_date, record, _daily_seed)
		_menu.refresh_daily_result()
		_daily_run = false
	Sfx.crossfade_to("")
	var bg_path: String = _end_overlay.show_record(record)
	_menu.hide()
	if _fast():
		_end_overlay.show()
		return
	# Final sineması: sonuç görseli tam ekran, bantlı; ardından hakikat paneli.
	Sfx.play("stinger_win" if record["survived"] else "stinger_loss", -2.0)
	var big := tr("TAHTINI KORUDUN") if record["survived"] else tr("TAHTINI KAYBETTİN")
	var title := Loc.en(str(record["title"])) if Loc.lang == "en" else tr(str(record["title"]))
	await _cinema.play([{"tex": _art(bg_path), "line": big, "sub": tr("Ünvanın: %s") % title, "hold": 4.2, "zoom_from": 1.0, "zoom_to": 1.14}])
	_end_overlay.show()
	UIKit.fade_in(_end_overlay, 1.0)
	if not record["survived"]:
		UIKit.shake(_stage, 10.0, 0.6)
	var dur := clampf(float(_end_overlay.summary.get_total_character_count()) * 0.012, 2.5, 6.0)
	UIKit.typewrite(_end_overlay.summary, dur, 0.8)


func _update_music() -> void:
	if _menu == null:
		return
	var desired := "menu" if _menu.visible else "ambient"
	if not _menu.visible and not Sim.actors.is_empty() and not Sim.ended:
		if Sim.active_crisis_label() != "":
			desired = "crisis"
		else:
			for item: Dictionary in Sim.pending:
				if int(item.get("age", 0)) > 0:
					desired = "tension"
					break
	if desired == _music_mode:
		return
	var now := Time.get_ticks_msec()
	if _music_mode != "" and now - _music_mode_since < 8000:
		return
	_music_mode = desired
	_music_mode_since = now
	Sfx.crossfade_to(desired)


func _vibrate(duration := 55) -> void:
	if Sfx.vibration and OS.get_name() == "Android":
		Input.vibrate_handheld(duration)

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
	if _person_file != null:
		_person_file.refresh()

func _signs_tip(a) -> String:
	return _person_panel._signs_tip(a)

func _trait(text: String, col: Color, filled := -1, total := 0, tip := "") -> Control:
	return _person_panel._trait(text, col, filled, total, tip)
