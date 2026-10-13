extends RefCounted

const UIKit := preload("res://game/ui/ui_kit.gd")
const StripOrder := preload("res://game/ui/strip_order.gd")

const GROUPS := [
	["Hanedan", ["dorn", "prens", "julian"]],
	["Devlet", ["arden", "voss", "kessler", "falk", "governor_capital", "governor_industry", "governor_farmland", "governor_border", "commander_capital", "commander_border", "commander_security"]],
	["Güç ve kamuoyu", ["halden", "lena", "brandt"]],
	["Dış ilişkiler", ["elena", "claire", "malenkov", "lucien"]],
]

var host: Control
var strip: GridContainer
var tile: Button
var layer: CanvasLayer
var shade: ColorRect
var drawer: PanelContainer
var drawer_scroll: ScrollContainer
var motion: Tween
var focus_button: Button
var groups: Array[GridContainer] = []
var group_buttons: Array[Button] = []
var parked: Control
var guide_hint: Label
var finance_label: Label
var public_label: Label
var parliament_label: Label
var laws_label: Label
var regions_label: Label
var army_label: Label
var opened := false
var last_id := ""
var visible_ids: Array = []
var folded: Dictionary = {}


func _init(main: Control) -> void:
	host = main


func build(right: VBoxContainer) -> void:
	strip = host._grid
	strip.columns = 6
	tile = Button.new()
	tile.theme_type_variation = "GhostButton"
	tile.custom_minimum_size = Vector2(76, 76)
	tile.pressed.connect(open)
	host._wire(tile)
	if host._mobile:
		tile.text = tr("Divan'ı aç")
		tile.theme_type_variation = "Button"
		tile.custom_minimum_size = Vector2(0, 44)
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right.add_child(tile)
	else:
		strip.add_child(tile)
	guide_hint = Label.new()
	guide_hint.text = tr("Diğer kişiler Divan'da")
	guide_hint.add_theme_color_override("font_color", Color(UIKit.TEXT, 0.88))
	guide_hint.add_theme_font_override("font", UIKit.serif())
	guide_hint.add_theme_font_size_override("font_size", host._fs(15))
	if not host._mobile:
		right.add_child(guide_hint)
	parked = Control.new()
	parked.visible = false
	parked.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(parked)
	layer = CanvasLayer.new()
	layer.layer = 45
	host.add_child(layer)
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.theme = host.theme
	layer.add_child(overlay)
	shade = ColorRect.new()
	shade.color = Color(UIKit.SHADE, 0.8)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			close())
	overlay.add_child(shade)
	drawer = PanelContainer.new()
	drawer.anchor_left = 0.08 if host._mobile else (0.51 if DisplayServer.window_get_size().x < 1200 else 0.55)
	drawer.anchor_right = 1.0
	drawer.anchor_bottom = 1.0
	drawer.add_theme_stylebox_override("panel", UIKit.box(UIKit.PANEL, UIKit.GOLD_DIM, UIKit.RADIUS, 14))
	overlay.add_child(drawer)
	drawer_scroll = ScrollContainer.new()
	drawer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	drawer.add_child(drawer_scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	drawer_scroll.add_child(body)
	var heading := HBoxContainer.new()
	body.add_child(heading)
	var title: Control = host._section(tr("DİVAN"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	finance_label = Label.new()
	finance_label.text = Sim.economy_journal_line()
	finance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	finance_label.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	finance_label.add_theme_font_size_override("font_size", host._fs(12))
	body.add_child(finance_label)
	public_label = Label.new()
	public_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	public_label.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	public_label.add_theme_font_size_override("font_size", host._fs(12))
	body.add_child(public_label)
	parliament_label = Label.new()
	parliament_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parliament_label.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	parliament_label.add_theme_font_size_override("font_size", host._fs(12))
	body.add_child(parliament_label)
	laws_label = Label.new()
	laws_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	laws_label.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	laws_label.add_theme_font_size_override("font_size", host._fs(12))
	body.add_child(laws_label)
	army_label = Label.new()
	army_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	army_label.add_theme_font_size_override("font_size", host._fs(12))
	army_label.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	body.add_child(army_label)
	regions_label = Label.new()
	regions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	regions_label.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	regions_label.add_theme_font_size_override("font_size", host._fs(12))
	body.add_child(regions_label)
	var close_button := Button.new()
	close_button.text = tr("Kapat")
	close_button.theme_type_variation = "GhostButton"
	close_button.custom_minimum_size.x = 80
	close_button.pressed.connect(close)
	host._wire(close_button)
	close_button.focus_mode = Control.FOCUS_ALL
	heading.add_child(close_button)
	focus_button = close_button
	for entry in GROUPS:
		var row := HBoxContainer.new()
		body.add_child(row)
		var button := Button.new()
		button.text = tr(entry[0])
		button.theme_type_variation = "GhostButton"
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 44
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		host._wire(button)
		row.add_child(button)
		group_buttons.append(button)
		var arrow := Control.new()
		arrow.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		arrow.position = Vector2(-19, 16)
		arrow.custom_minimum_size = Vector2(12, 12)
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(arrow)
		var grid := GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 6)
		grid.add_theme_constant_override("v_separation", 6)
		body.add_child(grid)
		groups.append(grid)
		grid.visible = not bool(folded.get(entry[0], false))
		arrow.draw.connect(func() -> void:
			var points := PackedVector2Array([Vector2(1, 3), Vector2(11, 3), Vector2(6, 9)]) if grid.visible else PackedVector2Array([Vector2(1, 9), Vector2(11, 9), Vector2(6, 3)])
			arrow.draw_colored_polygon(points, UIKit.GOLD))
		button.pressed.connect(func() -> void:
			grid.visible = not grid.visible
			folded[entry[0]] = not grid.visible
			arrow.queue_redraw())
		if entry[0] == "Dış ilişkiler":
			var note := Label.new()
			note.text = tr("Dışişleri Bakanı'nın raporu")
			note.add_theme_color_override("font_color", UIKit.TEXT_DIM)
			note.add_theme_font_size_override("font_size", host._fs(11))
			row.add_child(note)
	layer.visible = false


func refresh() -> void:
	if is_instance_valid(finance_label):
		finance_label.text = Sim.economy_journal_line()
	if is_instance_valid(public_label):
		public_label.text = Sim.public_opinion_line()
	if is_instance_valid(parliament_label):
		parliament_label.text = Sim.parliament_report_line()
	if is_instance_valid(laws_label):
		laws_label.text = Sim.parliament_laws_line()
	if is_instance_valid(regions_label):
		regions_label.text = Sim.region_report_line()
	if is_instance_valid(army_label):
		army_label.text = Sim.army_report_line()
	if host._mobile:
		if opened:
			for i in GROUPS.size():
				for id in GROUPS[i][1]:
					if host._cards.has(id):
						_place(host._cards[id], groups[i])
		else:
			for id in host._cards:
				_place(host._cards[id], host._person_panel._mobile_card_row)
			host._person_panel._set_mobile_group(host._person_panel._mobile_group)
		return
	if host._cards.is_empty():
		return
	var advisors := []
	for i in Sim.pending.size():
		for opinion in Sim.advice_for(i):
			advisors.append(str(opinion["actor"]))
	var changes := []
	for change in Sim.week_changes:
		var id := str(change.get("actor", ""))
		if id != "":
			changes.append(id)
	var danger := []
	for id in Sim.actors:
		if Sim.actors[id].moved or Sim.suspicion_level(id) >= 2:
			danger.append(id)
	var selected: String = host._selected_primary()
	var guide: bool = Sfx.tips and Sim.week <= 3
	guide_hint.visible = guide
	var ids := StripOrder.strip_ids(Sim.week, guide, advisors, changes, danger, selected, last_id)
	ids = ids.filter(func(id: String) -> bool: return host._cards.has(id))
	for id in host._cards:
		if ids.size() >= 5:
			break
		if not ids.has(id):
			ids.append(id)
	visible_ids = ids
	if opened:
		for i in GROUPS.size():
			for id in GROUPS[i][1]:
				if host._cards.has(id):
					_place(host._cards[id], groups[i])
	else:
		for id in host._cards:
			_place(host._cards[id], strip if ids.has(id) else parked)
		for i in ids.size():
			strip.move_child(host._cards[ids[i]], i)
		strip.move_child(tile, strip.get_child_count() - 1)
	tile.text = "+%d\n%s" % [host._cards.size() - ids.size(), tr("Divan")]
	for id in host._cards:
		var badge: Control = host._cards[id].get_meta("badge")
		var color := Color.TRANSPARENT
		if danger.has(id):
			color = UIKit.DANGER
		elif advisors.has(id):
			color = UIKit.GOLD
		elif changes.has(id):
			color = UIKit.REPORT_BLUE
		badge.visible = color.a > 0.0
		badge.set_meta("color", color)
		badge.queue_redraw()


func _place(card: Control, target: Node) -> void:
	if card.get_parent() == target:
		return
	if card.get_parent() != null:
		card.get_parent().remove_child(card)
	target.add_child(card)
	var compact_card: bool = not host._mobile and (str(card.get_meta("id", "")).begins_with("governor_") or str(card.get_meta("id", "")).begins_with("commander_"))
	card.custom_minimum_size = Vector2(76, 76) if target == strip else (Vector2(78, 82) if compact_card else Vector2(108, 96))


func open() -> void:
	if opened:
		return
	opened = true
	layer.visible = true
	refresh()
	host._style_cards()
	focus_button.call_deferred("grab_focus")
	drawer.offset_left = drawer.size.x
	drawer.offset_right = drawer.size.x
	if host._fast():
		drawer.offset_left = 0
		drawer.offset_right = 0
	else:
		var tween := drawer.create_tween().set_parallel()
		motion = tween
		tween.tween_property(drawer, "offset_left", 0.0, 0.18)
		tween.tween_property(drawer, "offset_right", 0.0, 0.18)
	Sfx.play("paper")


func close() -> void:
	if not opened:
		return
	opened = false
	if host._fast():
		layer.visible = false
		refresh()
	else:
		var tween := drawer.create_tween().set_parallel()
		tween.tween_property(drawer, "offset_left", drawer.size.x, 0.18)
		tween.tween_property(drawer, "offset_right", drawer.size.x, 0.18)
		tween.finished.connect(func() -> void:
			layer.visible = false
			refresh())
