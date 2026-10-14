extends RefCounted
## Full-screen dossier surface; action widgets remain owned by PersonPanel.

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")
const TOUCH_SCROLL := preload("res://game/ui/touch_scroll.gd")
const TR_DATA := "res://game/data/person_files.json"
const EN_DATA := "res://game/data/en/person_files.json"

var host: Control
var overlay: Control
var sheet: Control
var actor_id := ""
var data: Dictionary = {}
var _person_panel: RefCounted
var _profile_slot: Control
var _actions_slot: Control
var _meta_name: Label
var _meta_title: Label
var _meta_power: Label
var _meta_attitude: Label
var _power_note: Label
var _attitude_note: Label
var _observations: VBoxContainer
var _observation_note: Label
var _weak_value: Label
var _weak_note: Label
var _red_value: Label
var _red_note: Label
var _record_text: Label
var _relationship_text: Label
var _last_action: Label
var _close_button: Button


func _init(main: Control) -> void:
	host = main
	_person_panel = main._person_panel
	_load_data()


func _load_data() -> void:
	var path := EN_DATA if Loc.lang == "en" else TR_DATA
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		data = parsed


func build() -> void:
	overlay = Control.new()
	overlay.name = "PersonFileOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 50
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	overlay.theme = host.theme
	host.add_child(overlay)
	var shade := ColorRect.new()
	shade.name = "PersonFileShade"
	shade.color = Color(UIKit.SHADE, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	if not host._mobile:
		shade.anchor_top = 0.13
	shade.gui_input.connect(_on_shade_input)
	overlay.add_child(shade)

	sheet = Control.new()
	sheet.name = "PersonFileSheet"
	sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	sheet.clip_contents = true
	if host._mobile:
		sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
	else:
		sheet.anchor_left = 0.125
		sheet.anchor_right = 0.875
		sheet.anchor_top = 0.13
		sheet.anchor_bottom = 1.0
		sheet.offset_top = 0
		sheet.offset_bottom = -16
	overlay.add_child(sheet)
	_add_paper_background()

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, (12 if host._mobile else 34))
	sheet.add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8 if host._mobile else 10)
	margin.add_child(layout)
	_build_heading(layout)
	var separator := ColorRect.new()
	separator.color = Color(UIKit.GOLD_DIM, 0.65)
	separator.custom_minimum_size.y = 1
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(separator)
	if host._mobile:
		_build_mobile_content(layout)
	else:
		_build_desktop_content(layout)
	var seal_path := "res://art/ui/dosya_muhur.png"
	if ResourceLoader.exists(seal_path):
		var seal := TextureRect.new()
		seal.texture = load(seal_path)
		seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		seal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		seal.custom_minimum_size = Vector2(54, 54)
		seal.anchor_left = 0.045
		seal.anchor_top = 0.84
		seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sheet.add_child(seal)
	_person_panel._set_dossier_action_layout()
	_refresh_text()


func _add_paper_background() -> void:
	var background := TextureRect.new()
	background.name = "PaperTexture"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path := "res://art/ui/dosya_kagit.png"
	if ResourceLoader.exists(path):
		background.texture = load(path)
		sheet.add_child(background)
		return
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("624527"), Color("b29a6c"), Color("6c5030")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	background.texture = texture
	sheet.add_child(background)
	var frame := Panel.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheet.add_child(frame)
	UIKit.ornament(frame, Color(UIKit.GOLD, 0.85), 24, 8)


func _build_heading(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var crest_path := "res://art/ui/dosya_arma.png"
	if ResourceLoader.exists(crest_path):
		var crest := TextureRect.new()
		crest.texture = load(crest_path)
		crest.custom_minimum_size = Vector2(54, 52)
		crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crest.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(crest)
	else:
		row.add_child(host._header_symbol("lily", Vector2(42, 42), UIKit.GOLD, true))
	var title_block := VBoxContainer.new()
	title_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_block.add_theme_constant_override("separation", 1)
	row.add_child(title_block)
	var title := Label.new()
	title.text = UIKit.tr_upper(tr("VELORIA KRALİYET İSTİHBARAT DİVANI"))
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", host._fs(23 if not host._mobile else 18))
	title.add_theme_color_override("font_color", Color("302516"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_block.add_child(title)
	var serial := Label.new()
	serial.name = "PersonFileNumber"
	serial.add_theme_font_override("font", UIKit.serif())
	serial.add_theme_font_size_override("font_size", host._fs(15 if not host._mobile else 14))
	serial.add_theme_color_override("font_color", Color("40301c"))
	title_block.add_child(serial)
	var close := Button.new()
	_close_button = close
	close.name = "PersonFileClose"
	close.text = ""
	close.tooltip_text = tr("Kişi dosyasını kapat")
	close.custom_minimum_size = Vector2(44, 44)
	close.theme_type_variation = "GhostButton"
	close.draw.connect(func() -> void:
		var mid := close.size / 2.0
		close.draw_line(mid + Vector2(-7, -7), mid + Vector2(7, 7), UIKit.GOLD, 2.0, true)
		close.draw_line(mid + Vector2(7, -7), mid + Vector2(-7, 7), UIKit.GOLD, 2.0, true))
	host._wire(close)
	close.pressed.connect(close_file)
	row.add_child(close)


func _build_desktop_content(parent: VBoxContainer) -> void:
	var summary := HBoxContainer.new()
	summary.name = "DossierSummary"
	summary.custom_minimum_size.y = 250
	summary.add_theme_constant_override("separation", 12)
	parent.add_child(summary)
	_profile_slot = VBoxContainer.new()
	_profile_slot.name = "ProfileSlot"
	_profile_slot.custom_minimum_size.x = 450
	_profile_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary.add_child(_profile_slot)
	_build_meta(summary)
	var body := HBoxContainer.new()
	body.name = "PersonFileBody"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	parent.add_child(body)
	var left_scroll := _scroll("ObservationsScroll")
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_stretch_ratio = 0.95
	body.add_child(left_scroll)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left)
	_build_read_only_sections(left)
	var right_scroll := _scroll("ActionsScroll")
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_stretch_ratio = 1.05
	body.add_child(right_scroll)
	_actions_slot = VBoxContainer.new()
	_actions_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_actions_slot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	right_scroll.add_child(_actions_slot)
	_reparent(_person_panel.actions_panel, _actions_slot)
	_build_last_action(parent)
	_reparent(_person_panel.profile_panel, _profile_slot)


func _build_mobile_content(parent: VBoxContainer) -> void:
	var scroll := _scroll("PersonFileScroll")
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	_profile_slot = Control.new()
	_profile_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_profile_slot)
	_reparent(_person_panel.profile_panel, _profile_slot)
	_build_meta(content)
	_build_read_only_sections(content)
	_actions_slot = VBoxContainer.new()
	_actions_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_actions_slot)
	_reparent(_person_panel.actions_panel, _actions_slot)
	_build_last_action(content)


func _build_meta(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.name = "DossierRegister"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := UIKit.box(Color("b99d6c", 0.52), Color("6f542d", 0.42), 3, 10)
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 4)
	panel.add_child(rows)
	_meta_name = _meta_row(rows, "Kişi")
	_meta_title = _meta_row(rows, "Makam")
	_meta_power = _meta_row(rows, "Güç derecesi")
	_meta_attitude = _meta_row(rows, "Güncel tavır")
	_power_note = _body_label()
	rows.add_child(_power_note)
	_attitude_note = _body_label()
	rows.add_child(_attitude_note)


func _meta_row(parent: VBoxContainer, key: String) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var field := Label.new()
	field.text = UIKit.tr_upper(tr(key))
	field.custom_minimum_size.x = 108 if not host._mobile else 92
	field.add_theme_font_override("font", UIKit.caps())
	field.add_theme_font_size_override("font_size", host._fs(13 if not host._mobile else 15))
	field.add_theme_color_override("font_color", Color("564127"))
	row.add_child(field)
	var value := Label.new()
	value.name = key.replace(" ", "")
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_font_override("font", UIKit.serif_bold())
	value.add_theme_font_size_override("font_size", host._fs(15 if not host._mobile else 16))
	value.add_theme_color_override("font_color", Color("302516"))
	row.add_child(value)
	return value


func _build_read_only_sections(parent: VBoxContainer) -> void:
	var observation := _section(parent, "Saray gözlemi ve ruh hâli")
	_observations = observation
	_observation_note = _body_label()
	observation.add_child(_observation_note)
	var secrets := _section(parent, "Hassas ve gizli bilgiler")
	_weak_value = _body_label()
	secrets.add_child(_weak_value)
	_weak_note = _body_label()
	secrets.add_child(_weak_note)
	_red_value = _body_label()
	secrets.add_child(_red_value)
	_red_note = _body_label()
	secrets.add_child(_red_note)
	var record := _section(parent, "Hükümdarla ilişki ve sicil")
	_record_text = _body_label()
	record.add_child(_record_text)
	_relationship_text = _body_label()
	record.add_child(_relationship_text)


func _section(parent: VBoxContainer, title_key: String) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 4)
	parent.add_child(section)
	var heading := Label.new()
	heading.text = UIKit.tr_upper(tr(title_key))
	heading.add_theme_font_override("font", UIKit.caps())
	heading.add_theme_font_size_override("font_size", host._fs(16 if not host._mobile else 15))
	heading.add_theme_color_override("font_color", Color("4c381f"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	section.add_child(heading)
	var rule := ColorRect.new()
	rule.color = Color("8d7043", 0.62)
	rule.custom_minimum_size.y = 1
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_child(rule)
	return section


func _build_last_action(parent: Control) -> void:
	_last_action = _body_label()
	_last_action.name = "PersonFileLastAction"
	_last_action.custom_minimum_size.y = 24
	parent.add_child(_last_action)


func _scroll(node_name: String) -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.name = node_name
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var bar := scroll.get_v_scroll_bar()
	bar.custom_minimum_size.x = 8
	bar.modulate = Color(UIKit.GOLD, 0.72)
	return scroll


func _body_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_override("font", UIKit.serif())
	label.add_theme_font_size_override("font_size", host._fs(15 if not host._mobile else 16))
	label.add_theme_color_override("font_color", Color("302516"))
	return label


func open(id: String) -> void:
	if not Sim.actors.has(id):
		return
	if host._sel != [id]:
		host._sel.clear()
		host._sel.append(id)
		host._style_cards()
		host._update_info()
		host._divan.refresh()
	if host._divan.opened:
		host._divan.close()
	actor_id = id
	_person_panel.clear_button.hide()
	if host._mobile:
		host._tabs.current_tab = 1
	_restore_from_staging()
	_person_panel._update_action_states()
	_refresh_text()
	overlay.visible = true
	if not Sfx.reduce_motion and not host._fast():
		var target := sheet.position
		sheet.position = target + Vector2(0, 14)
		sheet.modulate.a = 0.0
		sheet.create_tween().set_parallel(true).tween_property(sheet, "position", target, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		sheet.create_tween().tween_property(sheet, "modulate:a", 1.0, 0.2)
	else:
		sheet.modulate.a = 1.0
	Sfx.play("paper", -8.0)


func close_file() -> void:
	if not is_open():
		return
	overlay.hide()
	_restore_to_staging()
	_person_panel.clear_button.show()
	actor_id = ""


func is_open() -> bool:
	return overlay != null and overlay.visible


func refresh() -> void:
	if is_open():
		_refresh_text()


func _restore_from_staging() -> void:
	if _person_panel.profile_panel.get_parent() != _profile_slot:
		if _person_panel.profile_panel.get_parent() != null:
			_person_panel.profile_panel.get_parent().remove_child(_person_panel.profile_panel)
		_profile_slot.add_child(_person_panel.profile_panel)
	if _person_panel.actions_panel.get_parent() != _actions_slot:
		if _person_panel.actions_panel.get_parent() != null:
			_person_panel.actions_panel.get_parent().remove_child(_person_panel.actions_panel)
		_actions_slot.add_child(_person_panel.actions_panel)


func _reparent(node: Node, parent: Node) -> void:
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	parent.add_child(node)


func _restore_to_staging() -> void:
	var staging: Node = _person_panel.person_block
	for child in [_person_panel.profile_panel, _person_panel.actions_panel]:
		if child.get_parent() != null:
			child.get_parent().remove_child(child)
		staging.add_child(child)
	staging.move_child(_person_panel.profile_panel, 0)
	staging.move_child(_person_panel.actions_panel, staging.get_child_count() - 1)


func _refresh_text() -> void:
	if actor_id == "" or not Sim.actors.has(actor_id) or _meta_name == null:
		return
	var actor = Sim.actors[actor_id]
	var entry: Dictionary = data.get(actor_id, {})
	var serial := str(entry.get("file_no", "RECORD-01"))
	if Loc.lang == "en":
		serial = str(entry.get("file_no_en", serial))
	var number_label := sheet.find_child("PersonFileNumber", true, false) as Label
	if number_label != null:
		number_label.text = UIKit.tr_upper(tr("GİZLİ SİCİL DOSYASI · NO: %s") % serial)
	_meta_name.text = actor.display_name
	_meta_title.text = actor.title
	var tier := Sim.power_tier(actor.power)
	var tier_name: String = Sim.POWER_TIER_NAMES[tier]
	_meta_power.text = tr(tier_name)
	_power_note.text = tr("Makamın ve görünür nüfuzun saraydaki ağırlığını özetler.")
	var suspicion := Sim.suspicion_level(actor_id)
	var attitude: String = Sim.SUSPICION_NAMES[clampi(suspicion, 0, Sim.SUSPICION_NAMES.size() - 1)]
	_meta_attitude.text = tr(attitude)
	_attitude_note.text = _attitude_summary(actor)
	var observations: Array = entry.get("observations", [])
	for child in _observations.get_children():
		if child == _observation_note:
			continue
		_observations.remove_child(child)
		child.queue_free()
	for line in observations.slice(0, 3):
		var bullet := HBoxContainer.new()
		bullet.add_theme_constant_override("separation", 8)
		_observations.add_child(bullet)
		var mark := Control.new()
		mark.custom_minimum_size = Vector2(11, 11)
		mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mark.draw.connect(func() -> void:
			var center := mark.size / 2.0
			mark.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -4), center + Vector2(4, 0), center + Vector2(0, 4), center + Vector2(-4, 0)]), Color("70542c")))
		bullet.add_child(mark)
		var label := _body_label()
		label.text = str(line)
		bullet.add_child(label)
	_observation_note.text = tr("Gözlem notu: %s") % _context_note(actor_id)
	var unknown := tr("Henüz öğrenilmedi. Araştır eylemiyle ortaya çıkarılabilir.")
	_weak_value.text = "%s: %s" % [UIKit.tr_upper(tr("Zayıf nokta")), actor.weak_point if actor.known_weak else "[ ? ]"]
	_weak_note.text = "" if actor.known_weak else unknown
	_red_value.text = "%s: %s" % [UIKit.tr_upper(tr("Kırmızı çizgi")), tr(actor.red_line) if actor.known_red else "[ ? ]"]
	_red_note.text = "" if actor.known_red else unknown
	var record: Dictionary = Sim.karne.get(actor_id, {"ok": 0, "bad": 0})
	if int(record.get("ok", 0)) + int(record.get("bad", 0)) == 0:
		_record_text.text = tr("Henüz çapraz sorgulanmış bir rapor yok.")
	elif int(record.get("ok", 0)) > int(record.get("bad", 0)):
		_record_text.text = tr("Doğrulanmış raporlar çoğunlukla tutarlı.")
	elif int(record.get("bad", 0)) > int(record.get("ok", 0)):
		_record_text.text = tr("Çapraz sorgular çelişkiler ortaya çıkardı.")
	else:
		_record_text.text = tr("Çapraz sorgular karışık bir sicil gösteriyor.")
	var promises: Array = Sim.active_promises_of(actor_id)
	var promise_names: Array[String] = []
	for promise: Dictionary in promises:
		promise_names.append(tr(str(promise["prize"])))
	_relationship_text.text = tr("Kayıttaki bekleyen sözler: %s") % ", ".join(promise_names) if not promise_names.is_empty() else tr("Kayıtta bekleyen bir söz yok.")
	if actor.moved:
		_relationship_text.text += "\n" + tr("Bu kişi açıkça Taç'a karşı döndü.")
	elif float(actor.obligation) >= 8.0:
		_relationship_text.text += "\n" + tr("Bu kişi karşılık bekliyor.")
	else:
		_relationship_text.text += "\n" + tr("Sadakati belirsiz.")
	var last := str(host._week_log.back()) if host._week_log_week == Sim.week and not host._week_log.is_empty() else ""
	_last_action.text = tr("Son eylem: %s") % last if last != "" else ""


func _context_note(id: String) -> String:
	if id.begins_with("governor_"):
		return Sim.region_status_line(id.trim_prefix("governor_"))
	if id.begins_with("commander_"):
		var unit_id := id.trim_prefix("commander_")
		var unit: Dictionary = Sim.army_units.get(unit_id, {})
		return tr("Birlik durumu: %s; bağlılık %s, moral %s, ikmal %s.") % [
			tr(Sim._army_unit_name(unit_id)),
			Sim._army_band(float(unit.get("loyalty", 50.0))),
			Sim._army_band(float(unit.get("morale", 50.0))),
			Sim._army_band(float(unit.get("supply", 50.0)))]
	if Sim.FOREIGN_ENVOYS.has(id):
		var hint := Sim._external_report_hint(str(Sim.FOREIGN_ENVOYS[id]))
		return hint if hint != "" else tr("Dış temaslarda dikkat çeken bir gerilim işareti yok.")
	return tr("Bu hafta için yeni bir gözlem kaydı yok.")


func _attitude_summary(actor) -> String:
	if actor.moved:
		return tr("Bu kişi açıkça Taç'a karşı döndü.")
	match Sim.suspicion_level(actor.id):
		0: return tr("Yakın dönemde belirgin bir alamet kayda geçmedi.")
		1: return tr("Bazı davranışlar dikkat çekiyor; tek başına kanıt sayılmaz.")
		2: return tr("İşaretler güveni zedeliyor; ihtiyatlı hareket et.")
		_: return tr("Belirgin alametler var; güven sarsılmış durumda.")


func _on_shade_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button == null or button.button_index != MOUSE_BUTTON_LEFT:
		return
	if (TOUCH_SCROLL.dispatching_touch and not button.pressed) or (not TOUCH_SCROLL.dispatching_touch and button.pressed):
		close_file()
