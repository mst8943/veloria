extends RefCounted

const UIKit := preload("res://game/ui/ui_kit.gd")
const StripOrder := preload("res://game/ui/strip_order.gd")

const GROUPS := [
	["Hanedan", ["dorn", "prens", "julian"]],
	["Devlet", ["arden", "voss", "kessler", "falk"]],
	["Güç ve kamuoyu", ["halden", "lena", "brandt"]],
	["Dış ilişkiler", ["elena", "claire", "malenkov", "lucien"]],
]

var host: Control
var strip: GridContainer
var tile: Button
var layer: CanvasLayer
var shade: ColorRect
var drawer: PanelContainer
var focus_button: Button
var groups: Array[GridContainer] = []
var parked: Control
var guide_hint: Label
var opened := false
var last_id := ""
var visible_ids: Array = []


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
	strip.add_child(tile)
	guide_hint = Label.new()
	guide_hint.text = tr("Diğer kişiler Divan'da")
	guide_hint.add_theme_color_override("font_color", UIKit.TEXT_DIM)
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
	drawer.anchor_left = 0.55
	drawer.anchor_right = 1.0
	drawer.anchor_bottom = 1.0
	drawer.add_theme_stylebox_override("panel", UIKit.box(UIKit.PANEL, UIKit.GOLD_DIM, UIKit.RADIUS, 14))
	overlay.add_child(drawer)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	drawer.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	scroll.add_child(body)
	var heading := HBoxContainer.new()
	body.add_child(heading)
	var title: Control = host._section(tr("DİVAN"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
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
		var button := Button.new()
		button.text = tr(entry[0])
		button.theme_type_variation = "GhostButton"
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 44
		host._wire(button)
		body.add_child(button)
		var grid := GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 6)
		grid.add_theme_constant_override("v_separation", 6)
		body.add_child(grid)
		groups.append(grid)
		button.pressed.connect(func() -> void: grid.visible = not grid.visible)
		if entry[0] == "Dış ilişkiler":
			var note := Label.new()
			note.text = tr("Dışişleri Bakanı'nın raporu")
			note.add_theme_color_override("font_color", UIKit.TEXT_DIM)
			body.add_child(note)
			button.pressed.connect(func() -> void: note.visible = grid.visible)
	layer.visible = false


func refresh() -> void:
	if host._mobile or host._cards.is_empty():
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
	card.custom_minimum_size = Vector2(76, 76) if target == strip else Vector2(108, 96)


func open() -> void:
	if opened:
		return
	opened = true
	layer.visible = true
	refresh()
	focus_button.call_deferred("grab_focus")
	drawer.position.x = shade.size.x
	if host._fast():
		drawer.position.x = shade.size.x * 0.55
	else:
		drawer.create_tween().tween_property(drawer, "position:x", shade.size.x * 0.55, 0.18)
	Sfx.play("paper")


func close() -> void:
	if not opened:
		return
	opened = false
	if host._fast():
		layer.visible = false
		refresh()
	else:
		var tween := drawer.create_tween()
		tween.tween_property(drawer, "position:x", shade.size.x, 0.18)
		tween.finished.connect(func() -> void:
			layer.visible = false
			refresh())
