extends Control
## Hükümdarlık Arşivi: kayıtları ve 46 başarımı tek süslü çerçevede gösterir.

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")
const ARCHIVE_BG := "res://art/ui/arsiv_arka_plan.png"
const BOOKS_ART := "res://art/ui/arsiv_kitaplar.png"
const SHIELD_LOST := "res://art/ui/arsiv_kalkan_dustu.png"
const SHIELD_SURVIVED := "res://art/ui/arsiv_kalkan_tahtta.png"

var _sim: Node
var _mobile := false
var _close_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_sim = get_node("/root/Sim")
	_mobile = bool(get_parent().get("_mobile")) if get_parent() != null else get_viewport_rect().size.x <= 1100.0
	refresh()


func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_close_button = null
	_build_view()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	visible = false


func _build_view() -> void:
	var viewport := get_viewport_rect().size
	var frame_inset := 7.0 if _mobile else 28.0
	if ResourceLoader.exists(ARCHIVE_BG):
		var background := TextureRect.new()
		background.name = "ArchiveBackground"
		background.texture = load(ARCHIVE_BG)
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_SCALE
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(background)
		move_child(background, 0)
	else:
		var fallback := ColorRect.new()
		fallback.name = "ArchiveFallback"
		fallback.color = Color("0e0b08")
		fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fallback)
		move_child(fallback, 0)
		var frame := ArchiveDrawing.new()
		frame.kind = "frame"
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(frame)
		move_child(frame, 1)

	var shade := ColorRect.new()
	shade.name = "ArchiveInputShield"
	shade.color = Color(0.025, 0.018, 0.012, 0.34 if ResourceLoader.exists(ARCHIVE_BG) else 0.18)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center := HBoxContainer.new()
	center.name = "ArchiveCenter"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_left = frame_inset + (8.0 if _mobile else 22.0)
	center.offset_top = 7.0 if _mobile else 10.0
	center.offset_right = -(frame_inset + (8.0 if _mobile else 22.0))
	center.offset_bottom = -7.0 if _mobile else -10.0
	center.add_theme_constant_override("separation", 0)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var left_space := Control.new()
	left_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(left_space)
	var body := VBoxContainer.new()
	body.name = "ArchiveContent"
	body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	body.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	body.custom_minimum_size.x = minf(1040.0 if _mobile else 980.0, viewport.x - 2.0 * (frame_inset + 30.0))
	body.add_theme_constant_override("separation", 5 if _mobile else 7)
	center.add_child(body)
	var right_space := Control.new()
	right_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(right_space)
	var records: Array = _sim.call("load_chronicle")
	_build_heading(body)
	_build_statistics(body, records)
	body.add_child(_section_band(tr("SON OLAYLAR"), Color("8f332b"), "sword"))
	_build_event_list(body, viewport, records)
	var achievement_band := _section_band(tr("BAŞARIMLAR"), Color("7f8b48"), "laurel")
	var count := Label.new()
	count.name = "ArchiveAchievementCount"
	var achievement_data := _achievement_data()
	var have: Dictionary = _sim.call("load_achievements")
	count.text = "%d / %d" % [have.size(), achievement_data.size()]
	_style_label(count, 15 if _mobile else 18, Color("e5c76e"), true)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	(achievement_band.get_child(0) as HBoxContainer).add_child(count)
	body.add_child(achievement_band)
	var unused_event_space := 0.0
	if records.is_empty():
		unused_event_space = _list_height(viewport, 0.23 if _mobile else (0.25 if viewport.y < 780.0 else 0.32), 115.0 if _mobile else 150.0, 150.0 if _mobile else 288.0) - (58.0 if _mobile else 70.0)
	_build_achievement_list(body, viewport, achievement_data, have, _sim.call("load_achievements", true), unused_event_space)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 1
	body.add_child(spacer)
	_close_button = Button.new()
	_close_button.name = "ArchiveClose"
	_close_button.text = tr("Kapat")
	_close_button.theme_type_variation = "PrimaryButton"
	_close_button.custom_minimum_size = Vector2(190 if _mobile else 220, 44 if _mobile else 48)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_close_button.pressed.connect(_close)
	body.add_child(_close_button)
	close_button_focus()


func _build_heading(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.name = "ArchiveHeading"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.custom_minimum_size.y = 48 if _mobile else 62
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var book_size := Vector2(62, 52) if not _mobile else Vector2(44, 42)
	_add_art_or_icon(row, BOOKS_ART, "books", book_size)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.alignment = BoxContainer.ALIGNMENT_CENTER
	text_box.add_theme_constant_override("separation", 0)
	row.add_child(text_box)
	var title := Label.new()
	title.name = "ArchiveTitle"
	title.text = tr("Hükümdarlık Arşivi").to_upper()
	_style_label(title, 29 if not _mobile else 21, Color("e5c76e"), true, true)
	title.add_theme_font_override("font", UIKit.caps())
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_box.add_child(title)
	var subtitle := Label.new()
	subtitle.name = "ArchiveSubtitle"
	subtitle.text = tr("Tarih, kararlar ve sonuçlar.").to_upper()
	_style_label(subtitle, 14 if not _mobile else 12, Color("b9a77d"), true)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_box.add_child(subtitle)
	var spacer := Control.new()
	spacer.custom_minimum_size = book_size
	row.add_child(spacer)


func _build_statistics(parent: VBoxContainer, records: Array) -> void:
	var survived := 0
	var longest := 0
	for value in records:
		if value is Dictionary:
			survived += 1 if bool(value.get("survived", false)) else 0
			longest = maxi(longest, int(value.get("weeks", 0)))
	var best_text := tr("%d hafta") % longest if not records.is_empty() else "—"
	var row := HBoxContainer.new()
	row.name = "ArchiveStatistics"
	row.custom_minimum_size.y = 56 if _mobile else 66
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 8 if _mobile else 12)
	parent.add_child(row)
	_add_stat(row, "altin", tr("Saltanat sayısı"), str(records.size()))
	_add_stat(row, "tac", tr("Tahtta kalan"), str(survived))
	_add_stat(row, "parsomen", tr("En uzun saltanat"), best_text)


func _add_stat(parent: HBoxContainer, icon: String, heading: String, value: String) -> void:
	var card := PanelContainer.new()
	card.name = "ArchiveStat" + icon.capitalize()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _stat_style())
	parent.add_child(card)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8 if _mobile else 12)
	margin.add_theme_constant_override("margin_right", 6 if _mobile else 10)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7 if _mobile else 10)
	margin.add_child(row)
	var premium_icon := UIKit.icon(icon, Vector2(27, 30) if _mobile else Vector2(34, 38), Color("e4c46c"))
	row.add_child(premium_icon)
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.alignment = BoxContainer.ALIGNMENT_CENTER
	labels.add_theme_constant_override("separation", 0)
	row.add_child(labels)
	var name := Label.new()
	name.name = "ArchiveStatLabel"
	name.text = heading.to_upper()
	name.add_theme_font_override("font", UIKit.caps())
	name.add_theme_font_size_override("font_size", 10 if _mobile else 11)
	name.add_theme_color_override("font_color", Color("c7ad70"))
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labels.add_child(name)
	var result := Label.new()
	result.name = "ArchiveStatValue"
	result.text = value
	_style_label(result, 15 if _mobile else 18, Color("eee3c8"), true)
	labels.add_child(result)


func _build_event_list(parent: VBoxContainer, viewport: Vector2, records: Array) -> void:
	var scroll := _new_scroll("ArchiveEventsScroll")
	scroll.custom_minimum_size.y = (58.0 if _mobile else 70.0) if records.is_empty() else _list_height(viewport, 0.23 if _mobile else (0.25 if viewport.y < 780.0 else 0.32), 115.0 if _mobile else 150.0, 150.0 if _mobile else 288.0)
	parent.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "ArchiveEventsList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 0)
	scroll.add_child(list)
	if records.is_empty():
		var empty := Label.new()
		empty.name = "ArchiveEmptyEvents"
		empty.text = tr("Henüz tamamlanmış bir saltanat yok.")
		_style_label(empty, 16 if not _mobile else 14, Color("c4b994"), true)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.custom_minimum_size.y = 70 if not _mobile else 54
		list.add_child(empty)
		return
	for index in mini(records.size(), 8):
		var record: Variant = records[records.size() - 1 - index]
		if record is Dictionary:
			list.add_child(_event_row(record, index))


func _event_row(record: Dictionary, index: int) -> Control:
	var survived := bool(record.get("survived", false))
	var accent := Color("91ab6c") if survived else Color("bd4740")
	var row := PanelContainer.new()
	row.name = "ArchiveEventRow_%d" % index
	row.custom_minimum_size.y = 61 if _mobile else 66
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.015, 0.013, 0.01, 0.56)
	style.border_color = Color(UIKit.GOLD, 0.2)
	style.border_width_bottom = 1
	row.add_theme_stylebox_override("panel", style)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 7 if _mobile else 12)
	row.add_child(content)
	var stripe := ColorRect.new()
	stripe.name = "ArchiveEventStripe_%d" % index
	stripe.color = accent
	stripe.custom_minimum_size.x = 4
	content.add_child(stripe)
	var date_box := VBoxContainer.new()
	date_box.custom_minimum_size.x = 106 if _mobile else 124
	date_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	date_box.alignment = BoxContainer.ALIGNMENT_CENTER
	date_box.add_theme_constant_override("separation", 0)
	content.add_child(date_box)
	var date := Label.new()
	date.name = "ArchiveDate_%d" % index
	date.text = str(record.get("date", "—"))
	_style_label(date, 12 if _mobile else 13, Color("d2c7ae"), true)
	date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	date_box.add_child(date)
	var weeks := Label.new()
	weeks.name = "ArchiveWeeks_%d" % index
	weeks.text = tr("%d hafta") % int(record.get("weeks", 0))
	_style_label(weeks, 12 if _mobile else 13, Color("bca77b"), true)
	weeks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	date_box.add_child(weeks)
	var cause_kind := (str(record.get("cause_key", "")) + " " + str(record.get("cause", ""))).to_lower()
	var shield_kind := "shield_alive" if survived else "shield_crown"
	if not survived and (cause_kind.contains("darbe") or cause_kind.contains("coup")):
		shield_kind = "shield_coup"
	_add_art_or_icon(content, SHIELD_SURVIVED if survived else SHIELD_LOST, shield_kind, Vector2(36, 44) if _mobile else Vector2(42, 50))
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	details.add_theme_constant_override("separation", 1)
	content.add_child(details)
	var title_line := HBoxContainer.new()
	title_line.add_theme_constant_override("separation", 8)
	details.add_child(title_line)
	var status := Label.new()
	status.name = "ArchiveStatus_%d" % index
	status.text = tr("TAHTTA") if survived else tr("DÜŞTÜ")
	status.add_theme_font_override("font", UIKit.caps())
	status.add_theme_font_size_override("font_size", 13 if not _mobile else 12)
	status.add_theme_color_override("font_color", accent)
	title_line.add_child(status)
	var title := Label.new()
	title.name = "ArchiveRecordTitle_%d" % index
	title.text = tr(str(record.get("title", "")))
	_style_label(title, 14 if not _mobile else 12, Color("e1d7c2"), true, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_line.add_child(title)
	var cause := Label.new()
	cause.name = "ArchiveCause_%d" % index
	cause.text = str(_sim.call("chronicle_cause", record))
	_style_label(cause, 13 if not _mobile else 11, Color("bdb5a4"), false)
	cause.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cause.max_lines_visible = 2
	if cause.text == "":
		cause.text = tr("Sebep eski arşiv kaydında özgün hâliyle saklanıyor.")
	details.add_child(cause)
	return row


func _build_achievement_list(parent: VBoxContainer, viewport: Vector2, data: Dictionary, have: Dictionary, extension: Dictionary, extra_height: float) -> void:
	var scroll := _new_scroll("ArchiveAchievementsScroll")
	scroll.custom_minimum_size.y = _list_height(viewport, 0.26 if _mobile else (0.18 if viewport.y < 780.0 else 0.27), 145.0 if _mobile else 108.0, 165.0 if _mobile else 244.0) + extra_height
	parent.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "ArchiveAchievementsList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 0)
	scroll.add_child(list)
	var earned: Array = []
	var locked: Array = []
	for id in data:
		if have.has(id) or extension.has(id):
			earned.append(id)
		else:
			locked.append(id)
	for id in earned + locked:
		var info: Array = data[id]
		list.add_child(_achievement_row(str(id), info, have, extension))


func _achievement_row(id: String, info: Array, have: Dictionary, extension: Dictionary) -> Control:
	var unlocked := have.has(id) or extension.has(id)
	var row := PanelContainer.new()
	row.name = "ArchiveAchievement_" + id
	row.custom_minimum_size.y = 48 if _mobile else 38
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.01, 0.008, 0.005, 0.18 if unlocked else 0.07)
	style.border_color = Color(UIKit.GOLD, 0.12)
	style.border_width_bottom = 1
	row.add_theme_stylebox_override("panel", style)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	row.add_child(content)
	var icon := ArchiveDrawing.new()
	icon.name = "ArchiveAchievementIcon_" + id
	icon.kind = _achievement_icon(id)
	icon.muted = not unlocked
	icon.custom_minimum_size = Vector2(28, 28) if _mobile else Vector2(26, 28)
	content.add_child(icon)
	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.alignment = BoxContainer.ALIGNMENT_CENTER
	labels.add_theme_constant_override("separation", 0)
	content.add_child(labels)
	var title := Label.new()
	title.name = "ArchiveAchievementName_" + id
	title.text = tr(str(info[0]))
	_style_label(title, 14 if not _mobile else 13, Color("e1c56d") if unlocked else Color("817861"), true, true)
	labels.add_child(title)
	var description := Label.new()
	description.name = "ArchiveAchievementDescription_" + id
	description.text = tr(str(info[1]))
	_style_label(description, 12 if not _mobile else 11, Color("c9c1ac") if unlocked else Color("817b70"), false)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.max_lines_visible = 1
	labels.add_child(description)
	return row


func _section_band(text: String, tint: Color, icon_kind: String) -> PanelContainer:
	var band := PanelContainer.new()
	band.name = "ArchiveBand" + ("Events" if icon_kind == "sword" else "Achievements")
	band.custom_minimum_size.y = 30 if _mobile else 34
	band.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = Color(tint.r * 0.28, tint.g * 0.22, tint.b * 0.18, 0.82)
	style.border_color = Color(tint, 0.56)
	style.border_width_bottom = 1
	style.content_margin_left = 10
	style.content_margin_right = 10
	band.add_theme_stylebox_override("panel", style)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	band.add_child(content)
	var icon: Control
	if icon_kind == "laurel":
		icon = UIKit.icon("defne", Vector2(23, 24), Color("e4c46c"))
	else:
		var drawing := ArchiveDrawing.new()
		drawing.kind = icon_kind
		drawing.custom_minimum_size = Vector2(23, 24)
		icon = drawing
	content.add_child(icon)
	var heading := Label.new()
	heading.name = "ArchiveSectionTitle"
	heading.text = text
	_style_label(heading, 18 if not _mobile else 14, Color("e5cc82"), true, true)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(heading)
	return band


func _new_scroll(node_name: String) -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = node_name
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	scroll.clip_contents = true
	var bar := scroll.get_v_scroll_bar()
	bar.custom_minimum_size.x = 8 if not _mobile else 10
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0, 0, 0, 0)
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(UIKit.GOLD, 0.7)
	grabber.corner_radius_top_left = 4
	grabber.corner_radius_top_right = 4
	grabber.corner_radius_bottom_left = 4
	grabber.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grabber)
	bar.add_theme_stylebox_override("grabber_highlight", grabber)
	return scroll


func _add_art_or_icon(parent: Control, path: String, kind: String, size: Vector2) -> Control:
	if path != "" and ResourceLoader.exists(path):
		var image := TextureRect.new()
		image.texture = load(path)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = size
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(image)
		return image
	var icon := ArchiveDrawing.new()
	icon.kind = kind
	icon.custom_minimum_size = size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)
	return icon


func _style_label(label: Label, size: int, color: Color, serif := false, bold := false) -> void:
	label.add_theme_font_override("font", UIKit.serif_bold() if serif and bold else UIKit.serif() if serif else UIKit.sans(680 if bold else 500))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _stat_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.028, 0.017, 0.88)
	style.border_color = Color(UIKit.GOLD, 0.62)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style


func _list_height(viewport: Vector2, ratio: float, minimum: float, maximum: float) -> float:
	return clampf(viewport.y * ratio, minimum, maximum)


func _achievement_data() -> Dictionary:
	var path := "res://game/data/en/content_achievements.json" if Loc.lang == "en" else "res://game/data/content_achievements.json"
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value if value is Dictionary else _sim.get("ACHIEVEMENTS")


func _achievement_icon(id: String) -> String:
	for pair in [["regional", "flag"], ["sandik", "scale"], ["koalisyon", "hands"], ["komuta", "sword"], ["garnizon", "shield"], ["ordu", "banner"], ["butce", "coin"], ["taht", "crown"]]:
		if id.contains(pair[0]):
			return pair[1]
	return "medal"


func close_button_focus() -> void:
	if _close_button != null:
		_close_button.focus_mode = Control.FOCUS_ALL


class ArchiveDrawing extends Control:
	var kind := "medal"
	var muted := false

	func _draw() -> void:
		var gold := Color("e4c46c")
		if muted:
			gold.a = 0.38
		var cx := size.x * 0.5
		var cy := size.y * 0.5
		match kind:
			"frame":
				_draw_frame(gold)
			"books":
				_draw_books(gold)
			"calendar":
				_draw_calendar(gold)
			"hourglass":
				_draw_hourglass(gold)
			"scroll":
				_draw_scroll(gold)
			"shield_alive", "shield_coup", "shield_crown", "shield":
				_draw_shield(gold, kind)
			"sword":
				_draw_sword(gold)
			"laurel":
				_draw_laurel(gold)
			"flag", "banner":
				_draw_flag(gold)
			"scale":
				_draw_scale(gold)
			"hands":
				_draw_hands(gold)
			"coin":
				_draw_coin(gold)
			"crown":
				_draw_crown(gold)
			_:
				_draw_medal(gold)

	func _draw_frame(color: Color) -> void:
		var inset := minf(26.0, minf(size.x, size.y) * 0.045)
		var outer := Rect2(Vector2(inset, 10), size - Vector2(inset * 2, 20))
		draw_rect(outer, Color(color, 0.75), false, 2.0)
		draw_rect(outer.grow(-5), Color(color, 0.3), false, 1.0)
		for corner in [Vector2(inset + 3, 13), Vector2(size.x - inset - 3, 13), Vector2(inset + 3, size.y - 13), Vector2(size.x - inset - 3, size.y - 13)]:
			var direction := Vector2(1, 1)
			if corner.x > size.x * 0.5:
				direction.x = -1
			if corner.y > size.y * 0.5:
				direction.y = -1
			var points := PackedVector2Array([corner, corner + Vector2(18 * direction.x, 0), corner + Vector2(18 * direction.x, 6 * direction.y), corner + Vector2(6 * direction.x, 6 * direction.y), corner + Vector2(6 * direction.x, 18 * direction.y), corner])
			draw_polyline(points, Color(color, 0.65), 1.5, true)

	func _draw_books(color: Color) -> void:
		var w := size.x
		var h := size.y
		for i in 3:
			var x := 5.0 + i * w * 0.27
			var rect := Rect2(x, h * 0.18 + (i % 2) * 2.0, w * 0.24, h * 0.68 - (i % 2) * 2.0)
			draw_rect(rect, Color(color, 0.1), true)
			draw_rect(rect, color, false, 1.7)
			draw_line(Vector2(x + rect.size.x * 0.25, rect.position.y + 3), Vector2(x + rect.size.x * 0.25, rect.end.y - 3), color, 1.0)
			draw_line(Vector2(x + 2, rect.position.y + rect.size.y * 0.22), Vector2(rect.end.x - 2, rect.position.y + rect.size.y * 0.22), Color(color, 0.55), 1.0)

	func _draw_calendar(color: Color) -> void:
		var r := Rect2(4, 5, size.x - 8, size.y - 10)
		draw_rect(r, Color(color, 0.08), true)
		draw_rect(r, color, false, 1.7)
		draw_line(Vector2(r.position.x, r.position.y + r.size.y * 0.28), Vector2(r.end.x, r.position.y + r.size.y * 0.28), color, 1.5)
		for x in [r.position.x + r.size.x * 0.28, r.position.x + r.size.x * 0.56, r.position.x + r.size.x * 0.82]:
			draw_circle(Vector2(x, r.position.y + r.size.y * 0.56), 1.2, color)
			draw_circle(Vector2(x, r.position.y + r.size.y * 0.78), 1.2, color)
		draw_line(Vector2(r.position.x + 6, 2), Vector2(r.position.x + 6, r.position.y + 3), color, 1.7)
		draw_line(Vector2(r.end.x - 6, 2), Vector2(r.end.x - 6, r.position.y + 3), color, 1.7)

	func _draw_hourglass(color: Color) -> void:
		var left := 5.0
		var right := size.x - 5.0
		var top := 4.0
		var bottom := size.y - 4.0
		draw_line(Vector2(left, top), Vector2(right, top), color, 2.0)
		draw_line(Vector2(left, bottom), Vector2(right, bottom), color, 2.0)
		draw_line(Vector2(left + 2, top + 2), Vector2(right - 2, top + 2), color, 1.0)
		draw_line(Vector2(left + 2, top + 2), Vector2(size.x * 0.5, size.y * 0.48), color, 1.5)
		draw_line(Vector2(right - 2, top + 2), Vector2(size.x * 0.5, size.y * 0.48), color, 1.5)
		draw_line(Vector2(size.x * 0.5, size.y * 0.48), Vector2(left + 2, bottom - 2), color, 1.5)
		draw_line(Vector2(size.x * 0.5, size.y * 0.48), Vector2(right - 2, bottom - 2), color, 1.5)
		draw_line(Vector2(left + 2, bottom - 2), Vector2(right - 2, bottom - 2), color, 1.0)

	func _draw_scroll(color: Color) -> void:
		var r := Rect2(6, 4, size.x - 12, size.y - 8)
		draw_rect(r, Color(color, 0.05), true)
		draw_rect(r, color, false, 1.6)
		for i in 3:
			var y := r.position.y + 8 + i * maxf(5.0, (r.size.y - 16) / 3.0)
			draw_line(Vector2(r.position.x + 5, y), Vector2(r.end.x - 5, y), color, 1.0)
		draw_circle(Vector2(r.position.x + 2, r.position.y + 2), 2.0, color)
		draw_circle(Vector2(r.end.x - 2, r.end.y - 2), 2.0, color)

	func _draw_shield(color: Color, variant: String) -> void:
		var lost := variant != "shield_alive"
		var points := PackedVector2Array([Vector2(size.x * 0.5, 3), Vector2(size.x - 4, 8), Vector2(size.x - 5, size.y * 0.62), Vector2(size.x * 0.5, size.y - 3), Vector2(5, size.y * 0.62), Vector2(4, 8), Vector2(size.x * 0.5, 3)])
		draw_colored_polygon(PackedVector2Array(points.slice(0, 6)), Color(0.12, 0.055, 0.03, 0.9))
		draw_polyline(points, Color("bc5143") if lost else Color(color, 0.9), 1.8, true)
		if variant == "shield_coup":
			draw_line(Vector2(size.x * 0.5, 12), Vector2(size.x * 0.5, size.y * 0.72), Color("e0c676"), 2.0)
			draw_line(Vector2(size.x * 0.32, 17), Vector2(size.x * 0.68, size.y * 0.6), Color("e0c676"), 1.4)
		elif variant == "shield_crown":
			draw_line(Vector2(size.x * 0.28, size.y * 0.43), Vector2(size.x * 0.72, size.y * 0.43), Color("e0c676"), 1.5)
			draw_polyline(PackedVector2Array([Vector2(size.x * 0.28, size.y * 0.43), Vector2(size.x * 0.32, size.y * 0.25), Vector2(size.x * 0.5, size.y * 0.39), Vector2(size.x * 0.68, size.y * 0.25), Vector2(size.x * 0.72, size.y * 0.43)]), Color("e0c676"), 1.5, true)
		else:
			draw_line(Vector2(size.x * 0.5, 12), Vector2(size.x * 0.5, size.y * 0.72), color, 1.5)
			draw_line(Vector2(size.x * 0.31, 18), Vector2(size.x * 0.69, 18), color, 1.5)
			draw_line(Vector2(size.x * 0.5, 13), Vector2(size.x * 0.31, 24), color, 1.5)
			draw_line(Vector2(size.x * 0.5, 13), Vector2(size.x * 0.69, 24), color, 1.5)

	func _draw_sword(color: Color) -> void:
		draw_line(Vector2(5, size.y - 4), Vector2(size.x - 5, 4), color, 2.0)
		draw_line(Vector2(size.x * 0.25, size.y * 0.45), Vector2(size.x * 0.55, size.y * 0.75), color, 1.8)
		draw_line(Vector2(size.x * 0.7, 3), Vector2(size.x - 3, size.y * 0.3), color, 1.7)

	func _draw_laurel(color: Color) -> void:
		for i in 4:
			var y := size.y * 0.25 + i * size.y * 0.13
			draw_line(Vector2(size.x * 0.48, y), Vector2(size.x * 0.2 - i * 1.3, y - 4), color, 1.3)
			draw_line(Vector2(size.x * 0.52, y), Vector2(size.x * 0.8 + i * 1.3, y - 4), color, 1.3)
		draw_line(Vector2(size.x * 0.28, size.y * 0.82), Vector2(size.x * 0.5, size.y * 0.94), color, 1.4)
		draw_line(Vector2(size.x * 0.72, size.y * 0.82), Vector2(size.x * 0.5, size.y * 0.94), color, 1.4)

	func _draw_flag(color: Color) -> void:
		draw_line(Vector2(6, 3), Vector2(6, size.y - 3), color, 1.7)
		draw_colored_polygon(PackedVector2Array([Vector2(7, 4), Vector2(size.x - 4, 7), Vector2(size.x - 8, size.y * 0.48), Vector2(7, size.y * 0.4)]), Color(color, 0.25))
		draw_polyline(PackedVector2Array([Vector2(7, 4), Vector2(size.x - 4, 7), Vector2(size.x - 8, size.y * 0.48), Vector2(7, size.y * 0.4), Vector2(7, 4)]), color, 1.2, true)

	func _draw_scale(color: Color) -> void:
		draw_line(Vector2(size.x * 0.5, 4), Vector2(size.x * 0.5, size.y - 4), color, 1.8)
		draw_line(Vector2(size.x * 0.2, 10), Vector2(size.x * 0.8, 10), color, 1.8)
		draw_line(Vector2(size.x * 0.5, 6), Vector2(size.x * 0.2, 13), color, 1.2)
		draw_line(Vector2(size.x * 0.5, 6), Vector2(size.x * 0.8, 13), color, 1.2)
		draw_line(Vector2(size.x * 0.2, 10), Vector2(size.x * 0.15, size.y * 0.55), color, 1.2)
		draw_line(Vector2(size.x * 0.8, 10), Vector2(size.x * 0.85, size.y * 0.55), color, 1.2)
		draw_arc(Vector2(size.x * 0.15, size.y * 0.57), size.x * 0.15, 0, PI, 16, color, 1.4, true)
		draw_arc(Vector2(size.x * 0.85, size.y * 0.57), size.x * 0.15, 0, PI, 16, color, 1.4, true)
		draw_line(Vector2(size.x * 0.32, size.y - 4), Vector2(size.x * 0.68, size.y - 4), color, 1.7)

	func _draw_hands(color: Color) -> void:
		draw_line(Vector2(3, size.y * 0.38), Vector2(size.x * 0.3, size.y * 0.7), color, 2.0)
		draw_line(Vector2(size.x - 3, size.y * 0.38), Vector2(size.x * 0.7, size.y * 0.7), color, 2.0)
		draw_line(Vector2(size.x * 0.3, size.y * 0.7), Vector2(size.x * 0.5, size.y * 0.88), color, 2.0)
		draw_line(Vector2(size.x * 0.7, size.y * 0.7), Vector2(size.x * 0.5, size.y * 0.88), color, 2.0)

	func _draw_coin(color: Color) -> void:
		draw_arc(Vector2(size.x * 0.5, size.y * 0.5), minf(size.x, size.y) * 0.38, 0, TAU, 24, color, 1.5, true)
		draw_arc(Vector2(size.x * 0.5, size.y * 0.5), minf(size.x, size.y) * 0.25, 0, TAU, 24, color, 1.0, true)
		draw_line(Vector2(size.x * 0.5, size.y * 0.3), Vector2(size.x * 0.5, size.y * 0.7), color, 1.3)

	func _draw_crown(color: Color) -> void:
		var points := PackedVector2Array([Vector2(4, size.y * 0.28), Vector2(size.x * 0.26, size.y * 0.57), Vector2(size.x * 0.5, size.y * 0.24), Vector2(size.x * 0.74, size.y * 0.57), Vector2(size.x - 4, size.y * 0.28), Vector2(size.x - 7, size.y * 0.78), Vector2(7, size.y * 0.78), Vector2(4, size.y * 0.28)])
		draw_polyline(points, color, 1.6, true)
		draw_line(Vector2(7, size.y * 0.88), Vector2(size.x - 7, size.y * 0.88), color, 1.5)

	func _draw_medal(color: Color) -> void:
		draw_arc(Vector2(size.x * 0.5, size.y * 0.43), minf(size.x, size.y) * 0.29, 0, TAU, 24, color, 1.5, true)
		draw_colored_polygon(PackedVector2Array([Vector2(size.x * 0.36, size.y * 0.68), Vector2(size.x * 0.45, size.y * 0.68), Vector2(size.x * 0.38, size.y - 3), Vector2(size.x * 0.29, size.y * 0.82)]), Color(color, 0.5))
		draw_colored_polygon(PackedVector2Array([Vector2(size.x * 0.55, size.y * 0.68), Vector2(size.x * 0.64, size.y * 0.68), Vector2(size.x * 0.71, size.y * 0.82), Vector2(size.x * 0.62, size.y - 3)]), Color(color, 0.5))
