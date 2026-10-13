extends Control
## İlk açılış rehberi; oyun verisine dokunmaz, ilk karar gerçek UI üzerinden verilir.

const UIKit := preload("res://game/ui/ui_kit.gd")
const TITLES := ["Taç sana emanet", "Üst çubuk", "Gündem ve danışmanlar", "İlk kararın", "İzleme listesi ve Divan", "Eylemler", "Bu hafta değişenler ve raporlar", "Dosyalar, günlük ve medya", "Haftayı bitir", "Menü ve ayarlar"]
const BODIES := [
	"Veloria'da amacın 104 hafta tahtta kalmak. Bu turu istediğin an atlayabilirsin.",
	"Hafta ilerlemesi, mesai hakkın ve kişisel servetin burada. Masa çalışma alanını, Medya haber ve yayınları açar; Kaydet ve Menü diğer araçlara götürür.",
	"Bekleyen kararları burada görürsün. Danışmanların çıkarı olabilir; Gerekçeler sana dayanaklarını gösterir.",
	"Bir seçeneğe dokunarak ilk gerçek kararını ver. Karar verilmeden bu adım ilerlemez; Atla seçimi zorlamaz.",
	"İzleme listesi 14 kişiyi takip eder. Şeritten birini seçebilir veya +N Divan ile tüm grupları açabilirsin.",
	"Yedi eylem sekmesi farklı yollar sunar. Eylemler haftalık mesai harcar; açıklamaları düğmelerde bulursun.",
	"Bu hafta değişenler ve Raporlar, kişilerin güçlenmesi veya hoşnutsuzluğu hakkında anlatı sunar; gizli sayılar gösterilmez.",
	"Dosyalar kanıt ve sırları, Günlük yaşananları tutar. Medya'da farklı haber kaynaklarını karşılaştırabilirsin.",
	"Haftayı bitirince zaman ilerler. Ertelenen kararlar kendiliğinden çözülebilir; kriz ve darbe belirtilerini izle.",
	"Menüde kayıt, yükleme, zorluk, dil ve ayarlar var. Buradan turu yeniden başlatabilir veya ilk açılış turunu kapatabilirsin."
]
const IDS := ["tour_welcome", "tour_header", "tour_agenda", "tour_decision", "tour_people", "tour_actions", "tour_reports", "tour_records", "tour_week", "tour_menu"]

var host: Control
var index := 0
var active := false
var _dim: Array[ColorRect] = []
var _frame: Control
var _card: PanelContainer
var _counter: Label
var _title: Label
var _body: Label
var _back: Button
var _next: Button
var _skip: Button
var _previous_hint: bool
var _previous_selection: Array[String] = []
var _auto_selected_id := ""

func _init(main: Control) -> void:
	host = main

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = get_viewport_rect().size
	get_viewport().size_changed.connect(func() -> void: size = get_viewport_rect().size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	for i in 4:
		var shade := ColorRect.new()
		shade.color = Color(UIKit.SHADE, 0.62)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(shade)
		_dim.append(shade)
	_frame = Control.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.draw.connect(_draw_frame)
	add_child(_frame)
	_card = PanelContainer.new()
	_card.add_theme_stylebox_override("panel", UIKit.box(Color(0.08, 0.07, 0.06, 0.98), Color.TRANSPARENT, 4, 16))
	add_child(_card)
	UIKit.ornament(_card, Color(UIKit.GOLD, 0.85), 18, 1)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.custom_minimum_size.x = 560
	content.add_theme_constant_override("separation", 6)
	_card.add_child(content)
	_counter = Label.new()
	_counter.add_theme_font_override("font", UIKit.caps())
	_counter.add_theme_color_override("font_color", UIKit.GOLD)
	_counter.add_theme_font_size_override("font_size", host._fs(13))
	_counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_counter)
	_title = Label.new()
	_title.add_theme_font_override("font", UIKit.caps())
	_title.add_theme_font_size_override("font_size", host._fs(21))
	_title.add_theme_color_override("font_color", UIKit.GOLD)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.custom_minimum_size.x = 540
	content.add_child(_title)
	_body = Label.new()
	_body.add_theme_font_override("font", UIKit.sans(470))
	_body.add_theme_font_size_override("font_size", host._fs(16))
	_body.add_theme_color_override("font_color", Color("e9e4d6"))
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.custom_minimum_size.x = 540
	content.add_child(_body)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	content.add_child(row)
	_back = Button.new()
	_back.text = tr("Geri")
	_back.theme_type_variation = "GhostButton"
	_back.custom_minimum_size.y = 44
	_back.add_theme_font_override("font", UIKit.caps())
	_back.pressed.connect(previous)
	row.add_child(_back)
	_skip = Button.new()
	_skip.text = tr("Atla")
	_skip.theme_type_variation = "GhostButton"
	_skip.custom_minimum_size.y = 44
	_skip.add_theme_font_override("font", UIKit.caps())
	_skip.pressed.connect(finish)
	row.add_child(_skip)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_next = Button.new()
	_next.text = tr("İleri")
	_next.theme_type_variation = "PrimaryButton"
	_next.custom_minimum_size = Vector2(132, 44)
	_next.add_theme_font_override("font", UIKit.caps())
	_next.pressed.connect(next_step)
	row.add_child(_next)
	hide()

func begin() -> void:
	if host._fast() or "--autoplay" in OS.get_cmdline_user_args() or OS.has_feature("headless"):
		return
	active = true
	index = 0
	_previous_selection = host._sel.duplicate()
	_previous_hint = host._hint_label.visible if host._hint_label != null else false
	if host._hint_label != null:
		host._hint_label.hide()
	host._refresh()
	if host._desk != null:
		host._desk.close_view()
	show()
	_render()

func _target() -> Control:
	match index:
		0: return host._header_week
		1: return host.get_node_or_null("TourTopBar")
		2: return host._decision_cards[0] if not host._decision_cards.is_empty() else host._scroll
		3: return host._decision_cards[0] if not host._decision_cards.is_empty() else host._scroll
		4: return host._person_panel._mobile_card_row if host._mobile else host._grid
		5: return host._person_panel.person_block
		6: return host._mobile_reports_page if host._mobile else (host._report_box if host._report_box != null else host._scroll)
		7: return host._files_tab
		8: return host._end_btn
		_: return host._buttons.get("menu")

func _render() -> void:
	if not is_node_ready(): return
	var screen := get_viewport_rect().size
	if screen.x < 100.0: screen = Vector2(1600, 900)
	if index == 4 or index == 5:
		if host._mobile: host._tabs.current_tab = 1
		if index == 5 and host._sel.is_empty():
			_auto_selected_id = str(host._person_panel.MOBILE_GROUPS[host._person_panel._mobile_group][0])
			host._sel.clear()
			host._sel.append(_auto_selected_id)
			host._style_cards()
			host._update_info()
			host._divan.refresh()
	elif index == 6 and host._mobile:
		host._tabs.current_tab = 2
		host._mobile_report_tabs.current_tab = 0
	elif index == 7:
		host._tabs.current_tab = 1 if not host._mobile else 2
		if host._mobile:
			host._mobile_report_tabs.current_tab = 1
	else:
		host._tabs.current_tab = 0
	await get_tree().process_frame
	_counter.text = tr("Adım %d / %d") % [index + 1, TITLES.size()]
	_title.text = tr(TITLES[index])
	_body.text = tr(BODIES[index])
	_back.disabled = index == 0
	_next.text = tr("Bitir") if index == TITLES.size() - 1 else tr("İleri")
	_next.disabled = index == 3
	var target := _target()
	var raw: Rect2
	if (host._mobile and index >= 6 and index <= 7) or (not host._mobile and index == 7):
		var tabs: TabContainer = host._mobile_report_tabs if host._mobile and index >= 7 else host._tabs
		var tab_index := 2 if index == 6 else 1
		var bar := tabs.get_tab_bar()
		var tab_rect := bar.get_tab_rect(tab_index)
		raw = Rect2(bar.get_global_position() + tab_rect.position, tab_rect.size).grow(7)
	else:
		raw = target.get_global_rect().grow(7) if target != null and target.is_visible_in_tree() else Rect2(Vector2(18, 60), Vector2(screen.x - 36, 100))
	var start := raw.position.clamp(Vector2.ZERO, screen)
	var finish := raw.end.clamp(Vector2.ZERO, screen)
	var rect := Rect2(start, Vector2(maxf(0.0, finish.x - start.x), maxf(0.0, finish.y - start.y)))
	var card_height := clampf(maxf(190 if host._mobile else 174, _card.get_combined_minimum_size().y), 174, screen.y - 16)
	var card_size := Vector2(minf(screen.x - 32, 620), card_height)
	var below := Rect2(Vector2(0, screen.y - card_height - 8), Vector2(screen.x, card_height + 8))
	var above := Rect2(Vector2(0, 8), Vector2(screen.x, card_height))
	var place_above: bool = rect.intersects(below) or (host._mobile and rect.get_center().y > screen.y * 0.5)
	if place_above and above.end.y > rect.position.y: place_above = false
	if not place_above and rect.intersects(below): place_above = true
	var card_y := 8.0 if place_above else screen.y - card_height - 8
	_card.position = Vector2((screen.x - card_size.x) / 2.0, card_y)
	_card.size = card_size
	var r := rect
	_dim[0].position = Vector2.ZERO; _dim[0].size = Vector2(screen.x, maxf(0, r.position.y))
	_dim[1].position = Vector2(0, r.position.y); _dim[1].size = Vector2(maxf(0, r.position.x), r.size.y)
	_dim[2].position = Vector2(r.end.x, r.position.y); _dim[2].size = Vector2(maxf(0, screen.x - r.end.x), r.size.y)
	_dim[3].position = Vector2(0, r.end.y); _dim[3].size = Vector2(screen.x, maxf(0, screen.y - r.end.y))
	_frame.position = r.position
	_frame.size = r.size
	_frame.queue_redraw()

func _draw_frame() -> void:
	_frame.draw_rect(Rect2(Vector2.ZERO, _frame.size), Color(UIKit.GOLD, 0.95), false, 3.0)

func next_step() -> void:
	if index == 3: return
	if index >= IDS.size() - 1:
		finish()
		return
	index += 1
	_render()

func previous() -> void:
	if index > 0:
		index -= 1
		_render()

func decision_made() -> void:
	if active and index == 3:
		index += 1
		_render()

func finish() -> void:
	active = false
	hide()
	Sfx.tour_done = true
	Sfx.save_settings()
	if _auto_selected_id != "" and host._sel == [_auto_selected_id]:
		host._sel = _previous_selection.duplicate()
		host._style_cards()
		host._update_info()
		host._divan.refresh()
	_auto_selected_id = ""
	if host._hint_label != null:
		host._hint_label.visible = _previous_hint and Sfx.tips
	host._refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if active and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		finish()
		get_viewport().set_input_as_handled()
