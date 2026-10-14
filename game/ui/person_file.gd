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
var _canvas_layer: CanvasLayer
var _actions_slot: Control
var _meta_name: Label
var _meta_title: Label
var _meta_power: Label
var _meta_attitude: Label
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
var _photo_slot: Control
var _photo_frame: TextureRect
var _seal: TextureRect
var _action_scroll_hint: Control
var _paper_scale := 1.0
var _action_lines: Dictionary = {}
var _paper_texture: Texture2D


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
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "PersonFileLayer"
	_canvas_layer.layer = 70
	host.add_child(_canvas_layer)
	_canvas_layer.add_child(overlay)
	var shade := ColorRect.new()
	shade.name = "PersonFileShade"
	shade.color = Color(UIKit.SHADE, 0.5)
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
		sheet.set_anchors_preset(Control.PRESET_TOP_LEFT)
	overlay.add_child(sheet)
	_add_paper_background()

	if host._mobile:
		var margin := MarginContainer.new()
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		for side in ["left", "right", "top", "bottom"]:
			margin.add_theme_constant_override("margin_" + side, 12 if side != "top" else 16)
		sheet.add_child(margin)
		var layout := VBoxContainer.new()
		layout.add_theme_constant_override("separation", 8)
		margin.add_child(layout)
		_build_heading(layout)
		_build_mobile_content(layout)
	else:
		_layout_desktop_sheet()
		host.resized.connect(_layout_desktop_sheet)
		_build_heading(sheet)
		_build_desktop_content(sheet)
		_add_photo_frame()
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
		var paper: Texture2D = load(path)
		if host._mobile:
			var plain := AtlasTexture.new()
			plain.atlas = paper
			plain.region = Rect2(450, 430, 280, 100)
			background.texture = plain
		else:
			_paper_texture = _soft_edge_paper(paper)
			background.texture = _paper_texture
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


func _layout_desktop_sheet() -> void:
	if host._mobile or sheet == null:
		return
	var viewport := host.get_viewport_rect().size
	var height := viewport.y * 0.88
	var width := minf(viewport.x * 0.8, height * 1519.0 / 1036.0)
	sheet.position = Vector2((viewport.x - width) * 0.5, viewport.y * 0.055)
	sheet.size = Vector2(width, height)
	_paper_scale = width / 1519.0
	_layout_desktop_children()


func _paper_rect(x: float, y: float, width: float, height: float) -> Rect2:
	return Rect2(Vector2(x, y) * _paper_scale, Vector2(width, height) * _paper_scale)


func _apply_paper_rect(node: Control, x: float, y: float, width: float, height: float) -> void:
	var r := _paper_rect(x, y, width, height)
	node.position = r.position
	node.size = r.size


func _layout_desktop_children() -> void:
	var heading := sheet.find_child("DossierHeading", true, false) as Control
	if heading != null:
		_apply_paper_rect(heading, 500, 73, 790, 102)
		var crest := heading.get_node_or_null("DossierCrest") as Control
		var title_block := heading.get_node_or_null("DossierTitleBlock") as Control
		if crest != null:
			crest.position = Vector2(0, (heading.size.y - crest.size.y) * 0.5)
		if title_block != null:
			title_block.position = Vector2(108 * _paper_scale, 2 * _paper_scale)
			title_block.size = Vector2(heading.size.x - 112 * _paper_scale, heading.size.y - 4 * _paper_scale)
	if _photo_slot != null:
		_apply_paper_rect(_photo_slot, 214, 91, 207, 278)
		if host._portrait_box != null:
			host._portrait_box.position = Vector2.ZERO
			host._portrait_box.size = _photo_slot.size
			host._portrait_box.custom_minimum_size = _photo_slot.size
	if _photo_frame != null: _apply_paper_rect(_photo_frame, 145, 40, 310, 371)
	if _seal != null: _apply_paper_rect(_seal, 382, 278, 85, 96)
	if _close_button != null: _apply_paper_rect(_close_button, 1320, 42, 58, 58)
	var meta := sheet.find_child("DossierRegister", true, false) as Control
	if meta != null: _apply_paper_rect(meta, 505, 204, 785, 151)
	var left_scroll := sheet.find_child("ObservationsScroll", true, false) as Control
	if left_scroll != null: _apply_paper_rect(left_scroll, 250, 420, 475, 469)
	if _actions_slot != null: _apply_paper_rect(_actions_slot, 780, 355, 500, 545)
	if _person_panel.actions_panel != null:
		_person_panel.actions_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_person_panel.actions_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var last := _last_action
	if last != null: _apply_paper_rect(last, 250, 897, 475, 28)
	_layout_action_scroll_hint()


func _soft_edge_paper(paper: Texture2D) -> Texture2D:
	var image := paper.get_image()
	image.convert(Image.FORMAT_RGBA8)
	image.clear_mipmaps()
	var width := image.get_width()
	var height := image.get_height()
	var pixels := image.get_data()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var queue := PackedInt32Array()
	for x in width:
		_mark_outer_dark(x, visited, pixels, queue)
		_mark_outer_dark((height - 1) * width + x, visited, pixels, queue)
	for y in height:
		_mark_outer_dark(y * width, visited, pixels, queue)
		_mark_outer_dark(y * width + width - 1, visited, pixels, queue)
	var head := 0
	while head < queue.size():
		var index: int = queue[head]
		head += 1
		var x := index % width
		var y := int(index / width)
		if x > 0: _mark_outer_dark(index - 1, visited, pixels, queue)
		if x + 1 < width: _mark_outer_dark(index + 1, visited, pixels, queue)
		if y > 0: _mark_outer_dark(index - width, visited, pixels, queue)
		if y + 1 < height: _mark_outer_dark(index + width, visited, pixels, queue)
	for index in queue:
		pixels[index * 4 + 3] = 0
		var x := index % width
		var y := int(index / width)
		if x > 0: _soften_edge_pixel(index - 1, visited, pixels)
		if x + 1 < width: _soften_edge_pixel(index + 1, visited, pixels)
		if y > 0: _soften_edge_pixel(index - width, visited, pixels)
		if y + 1 < height: _soften_edge_pixel(index + width, visited, pixels)
	_replace_printed_guides(pixels, width, height)
	image.set_data(width, height, false, Image.FORMAT_RGBA8, pixels)
	var result := ImageTexture.create_from_image(image)
	return result


func _mark_outer_dark(index: int, visited: PackedByteArray, pixels: PackedByteArray, queue: PackedInt32Array) -> void:
	if visited[index] != 0:
		return
	var offset := index * 4
	if maxi(pixels[offset], maxi(pixels[offset + 1], pixels[offset + 2])) >= 48:
		return
	visited[index] = 1
	queue.append(index)


func _soften_edge_pixel(index: int, visited: PackedByteArray, pixels: PackedByteArray) -> void:
	if visited[index] != 0:
		return
	var offset := index * 4
	var light := maxi(pixels[offset], maxi(pixels[offset + 1], pixels[offset + 2]))
	if light < 100:
		pixels[offset + 3] = mini(pixels[offset + 3], roundi(inverse_lerp(48.0, 100.0, float(light)) * 255.0))


func _replace_printed_guides(pixels: PackedByteArray, width: int, height: int) -> void:
	# The printed rules are redrawn by flow controls so scrolling text never crosses them.
	var source := pixels.duplicate()
	var bands := [Vector4i(200, 385, 740, 418), Vector4i(200, 532, 740, 575), Vector4i(200, 699, 740, 738), Vector4i(760, 360, 1290, 395), Vector4i(760, 450, 1290, 490), Vector4i(760, 485, 1290, 520), Vector4i(760, 575, 1290, 620), Vector4i(760, 615, 1290, 650), Vector4i(760, 710, 1290, 755), Vector4i(760, 755, 1290, 785), Vector4i(760, 840, 1290, 892)]
	var sample_offsets := [45, 48, 61, 50, 80, 45, 85, 45, 80, 45, -40]
	for i in bands.size():
		var band: Vector4i = bands[i]
		var sample_offset: int = sample_offsets[i]
		for y in range(band.y, mini(band.w, height)):
			for x in range(band.x, mini(band.z, width)):
				var target := (y * width + x) * 4
				var sample := clampi(y + sample_offset, 0, height - 1) * width + x
				for channel in 3:
					pixels[target + channel] = source[sample * 4 + channel]


func _build_heading(parent: Control) -> void:
	var row: Control = HBoxContainer.new() if host._mobile else Control.new()
	row.name = "DossierHeading"
	if row is HBoxContainer:
		(row as HBoxContainer).add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var crest: Control
	var crest_path := "res://art/ui/dosya_arma.png"
	if ResourceLoader.exists(crest_path):
		crest = TextureRect.new()
		crest.texture = load(crest_path)
		crest.custom_minimum_size = Vector2(92, 78) if not host._mobile else Vector2(54, 48)
		crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crest.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		crest = host._header_symbol("lily", Vector2(42, 42), UIKit.GOLD, true)
	row.add_child(crest)
	crest.name = "DossierCrest"
	var title_block := VBoxContainer.new()
	title_block.name = "DossierTitleBlock"
	title_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_block.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_block.add_theme_constant_override("separation", 1)
	row.add_child(title_block)
	var title := Label.new()
	title.text = UIKit.tr_upper(tr("VELORIA KRALİYET İSTİHBARAT DİVANI"))
	title.add_theme_font_override("font", UIKit.caps())
	title.add_theme_font_size_override("font_size", host._fs(22 if not host._mobile else 18))
	title.add_theme_color_override("font_color", Color("2a1c0e"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_block.add_child(title)
	var serial := Label.new()
	serial.name = "PersonFileNumber"
	serial.add_theme_font_override("font", UIKit.serif())
	serial.add_theme_font_size_override("font_size", host._fs(14 if not host._mobile else 14))
	serial.add_theme_color_override("font_color", Color("2a1c0e"))
	title_block.add_child(serial)
	var close := Button.new()
	_close_button = close
	close.name = "PersonFileClose"
	close.text = ""
	close.tooltip_text = tr("Kişi dosyasını kapat")
	close.custom_minimum_size = Vector2(44, 44)
	close.z_index = 20
	close.theme_type_variation = "GhostButton"
	close.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	close.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	close.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	close.draw.connect(func() -> void:
		var mid := close.size / 2.0
		close.draw_line(mid + Vector2(-7, -7), mid + Vector2(7, 7), Color("2a1c0e"), 2.0, true)
		close.draw_line(mid + Vector2(7, -7), mid + Vector2(-7, 7), Color("2a1c0e"), 2.0, true))
	host._wire(close)
	close.pressed.connect(close_file)
	if host._mobile:
		row.add_child(close)
	else:
		parent.add_child(close)
	if not host._mobile:
		row.set_anchors_preset(Control.PRESET_TOP_LEFT)
		row.clip_contents = true
		# The source artwork leaves this measured header strip free for the title and crest.
		var r := _paper_rect(500, 73, 790, 102)
		row.position = r.position
		row.size = r.size
		crest.custom_minimum_size = _paper_rect(0, 0, 94, 80).size
		crest.size = crest.custom_minimum_size
		close.size = close.custom_minimum_size
		title.add_theme_font_size_override("font_size", maxi(17, roundi(23 * _paper_scale)))
		serial.add_theme_font_size_override("font_size", maxi(13, roundi(15 * _paper_scale)))


func _build_desktop_content(parent: Control) -> void:
	_photo_slot = Control.new()
	_photo_slot.name = "DossierPhotoWindow"
	_photo_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(_photo_slot)
	_reparent(host._portrait_box, _photo_slot)
	var meta := _build_meta(parent)
	meta.position = Vector2.ZERO
	var left_scroll := _scroll("ObservationsScroll")
	parent.add_child(left_scroll)
	var left := VBoxContainer.new()
	left.name = "PaperLeftColumn"
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 10)
	left_scroll.add_child(left)
	_build_read_only_sections(left)
	var right_scroll := _scroll("ActionsScroll")
	right_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var action_column := Control.new()
	action_column.name = "ActionsColumn"
	action_column.clip_contents = true
	parent.add_child(action_column)
	right_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	right_scroll.offset_bottom = -20
	action_column.add_child(right_scroll)
	_actions_slot = action_column
	_reparent(_person_panel.actions_panel, right_scroll)
	_action_scroll_hint = _make_action_scroll_hint()
	_action_scroll_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_action_scroll_hint.position = Vector2(-210, -22)
	_action_scroll_hint.size = Vector2(210, 22)
	action_column.add_child(_action_scroll_hint)
	_build_last_action(parent)
	_layout_desktop_children()


func _add_photo_frame() -> void:
	var frame_path := "res://art/ui/dosya_foto_cercevesi.png"
	if ResourceLoader.exists(frame_path):
		_photo_frame = TextureRect.new()
		_photo_frame.name = "DossierPhotoFrame"
		_photo_frame.texture = load(frame_path)
		_photo_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_photo_frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_photo_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sheet.add_child(_photo_frame)
	var seal_path := "res://art/ui/dosya_muhur.png"
	if ResourceLoader.exists(seal_path):
		_seal = TextureRect.new()
		_seal.name = "DossierSeal"
		_seal.texture = load(seal_path)
		_seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_seal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sheet.add_child(_seal)
	_layout_desktop_children()


func _build_mobile_content(parent: VBoxContainer) -> void:
	var scroll := _scroll("PersonFileScroll")
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)
	var photo_row := HBoxContainer.new()
	photo_row.name = "DossierPhotoRow"
	photo_row.custom_minimum_size.y = 180
	photo_row.add_theme_constant_override("separation", 40)
	content.add_child(photo_row)
	_photo_slot = Control.new()
	_photo_slot.custom_minimum_size = Vector2(130, 164)
	photo_row.add_child(_photo_slot)
	_reparent(host._portrait_box, _photo_slot)
	var meta := _build_meta(photo_row)
	meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_build_read_only_sections(content)
	_actions_slot = content
	_reparent(_person_panel.actions_panel, content)
	_build_last_action(content)
	var frame_path := "res://art/ui/dosya_foto_cercevesi.png"
	if ResourceLoader.exists(frame_path):
		_photo_frame = TextureRect.new()
		_photo_frame.name = "DossierPhotoFrame"
		_photo_frame.texture = load(frame_path)
		_photo_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_photo_frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_photo_frame.custom_minimum_size = Vector2(130, 164)
		_photo_frame.position = Vector2.ZERO
		_photo_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_photo_slot.add_child(_photo_frame)
		_photo_slot.move_child(host._portrait_box, 0)


func _build_meta(parent: Control) -> Control:
	var panel := VBoxContainer.new()
	panel.name = "DossierRegister"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 3)
	parent.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 4)
	panel.add_child(rows)
	_meta_name = _meta_row(rows, "Kişi")
	_meta_title = _meta_row(rows, "Makam")
	_meta_power = _meta_row(rows, "Güç")
	_meta_attitude = _meta_row(rows, "Tavır")
	return panel


func _meta_row(parent: VBoxContainer, key: String) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var field := Label.new()
	field.text = UIKit.tr_upper(tr(key))
	field.custom_minimum_size.x = 112 if not host._mobile else 112
	field.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	field.add_theme_font_override("font", UIKit.caps())
	field.add_theme_font_size_override("font_size", host._fs(13 if not host._mobile else 15))
	field.add_theme_color_override("font_color", Color("2a1c0e"))
	row.add_child(field)
	var value := Label.new()
	value.name = key.replace(" ", "")
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_font_override("font", UIKit.serif_bold())
	value.add_theme_font_size_override("font_size", host._fs(15 if not host._mobile else 16))
	value.add_theme_color_override("font_color", Color("2a1c0e"))
	row.add_child(value)
	return value


func _build_read_only_sections(parent: VBoxContainer) -> void:
	var observation := _section(parent, "Saray gözlemi ve ruh hâli")
	_observations = observation
	_observation_note = _body_label()
	observation.add_child(_observation_note)
	_add_section_separator(parent)
	var secrets := _section(parent, "Hassas ve gizli bilgiler")
	_weak_value = _body_label()
	secrets.add_child(_weak_value)
	_weak_note = _body_label()
	secrets.add_child(_weak_note)
	_red_value = _body_label()
	secrets.add_child(_red_value)
	_red_note = _body_label()
	secrets.add_child(_red_note)
	_add_section_separator(parent)
	var record := _section(parent, "Hükümdarla ilişki ve sicil")
	_record_text = _body_label()
	record.add_child(_record_text)
	_relationship_text = _body_label()
	record.add_child(_relationship_text)


func _add_section_separator(parent: VBoxContainer) -> void:
	var separator := Control.new()
	separator.name = "DossierSectionDivider"
	separator.custom_minimum_size.y = 12
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	separator.draw.connect(func() -> void:
		var center_y := separator.size.y * 0.5
		var center_x := separator.size.x * 0.5
		var ink := Color("80643b", 0.72)
		separator.draw_line(Vector2(0, center_y), Vector2(center_x - 7, center_y), ink, 1.0, true)
		separator.draw_line(Vector2(center_x + 7, center_y), Vector2(separator.size.x, center_y), ink, 1.0, true)
		separator.draw_colored_polygon(PackedVector2Array([Vector2(center_x, center_y - 3), Vector2(center_x + 3, center_y), Vector2(center_x, center_y + 3), Vector2(center_x - 3, center_y)]), ink))
	parent.add_child(separator)


func _section(parent: VBoxContainer, title_key: String) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 4)
	parent.add_child(section)
	var heading := Label.new()
	heading.text = UIKit.tr_upper(tr(title_key))
	heading.add_theme_font_override("font", UIKit.caps())
	heading.add_theme_font_size_override("font_size", host._fs(16 if not host._mobile else 15))
	heading.add_theme_color_override("font_color", Color("2a1c0e"))
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	section.add_child(heading)
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
	bar.custom_minimum_size.x = 4
	bar.modulate = Color("6b4b20", 0.52)
	return scroll


func _make_action_scroll_hint() -> HBoxContainer:
	var hint := HBoxContainer.new()
	hint.name = "DossierScrollHint"
	hint.custom_minimum_size.y = 18
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.alignment = BoxContainer.ALIGNMENT_END
	hint.add_theme_constant_override("separation", 4)
	var arrow := Control.new()
	arrow.custom_minimum_size = Vector2(10, 12)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow.draw.connect(func() -> void:
		var color := Color("80643b", 0.8)
		var mid := arrow.size.x * 0.5
		arrow.draw_line(Vector2(mid, 1), Vector2(mid, arrow.size.y - 3), color, 1.0, true)
		arrow.draw_line(Vector2(mid - 3, arrow.size.y - 6), Vector2(mid, arrow.size.y - 3), color, 1.0, true)
		arrow.draw_line(Vector2(mid + 3, arrow.size.y - 6), Vector2(mid, arrow.size.y - 3), color, 1.0, true))
	hint.add_child(arrow)
	var label := Label.new()
	label.text = tr("Daha fazla eylem")
	label.add_theme_font_override("font", UIKit.sans())
	label.add_theme_font_size_override("font_size", host._fs(12 if not host._mobile else 13))
	label.add_theme_color_override("font_color", Color("2a1c0e"))
	hint.add_child(label)
	return hint


func _update_action_scroll_hint() -> void:
	if _action_scroll_hint == null:
		return
	if host._mobile:
		_action_scroll_hint.visible = true
		return
	_action_scroll_hint.visible = true


func _layout_action_scroll_hint() -> void:
	_update_action_scroll_hint()


func _body_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_override("font", UIKit.serif())
	label.add_theme_font_size_override("font_size", host._fs(13 if not host._mobile else 15))
	label.add_theme_color_override("font_color", Color("2a1c0e"))
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
	actor_id = ""
	_restore_to_staging()
	_person_panel.clear_button.show()
	_person_panel._update_info()


func is_open() -> bool:
	return overlay != null and overlay.visible


func refresh() -> void:
	if is_open():
		_refresh_text()


func _restore_from_staging() -> void:
	if host._portrait_box.get_parent() != _photo_slot:
		if host._portrait_box.get_parent() != null:
			host._portrait_box.get_parent().remove_child(host._portrait_box)
		_photo_slot.add_child(host._portrait_box)
	if host._mobile:
		host._portrait_box.custom_minimum_size = Vector2(130, 164)
		host._portrait_box.size = Vector2(130, 164)
	var action_parent: Control = _actions_slot
	if not host._mobile:
		var desktop_scroll := _actions_slot.find_child("ActionsScroll", true, false) as Control
		if desktop_scroll != null:
			action_parent = desktop_scroll
	if _person_panel.actions_panel.get_parent() != action_parent:
		if _person_panel.actions_panel.get_parent() != null:
			_person_panel.actions_panel.get_parent().remove_child(_person_panel.actions_panel)
		action_parent.add_child(_person_panel.actions_panel)
	if not host._mobile:
		_layout_desktop_children()
	_person_panel._update_info()


func _reparent(node: Node, parent: Node) -> void:
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	parent.add_child(node)


func _restore_to_staging() -> void:
	var staging: Node = _person_panel.person_block
	if host._portrait_box.get_parent() != _person_panel.profile_panel:
		if host._portrait_box.get_parent() != null:
			host._portrait_box.get_parent().remove_child(host._portrait_box)
		_person_panel.profile_panel.add_child(host._portrait_box)
	host._portrait_box.custom_minimum_size = Vector2(190, 214) if not host._mobile else Vector2(150, 166)
	host._portrait_box.size = host._portrait_box.custom_minimum_size
	for child in [_person_panel.actions_panel]:
		if child.get_parent() != null:
			child.get_parent().remove_child(child)
		staging.add_child(child)
	staging.move_child(_person_panel.actions_panel, staging.get_child_count() - 1)


func _refresh_text() -> void:
	if actor_id == "" or not Sim.actors.has(actor_id) or _meta_name == null:
		return
	var actor = Sim.actors[actor_id]
	var entry: Dictionary = data.get(actor_id, {})
	var serial := str(entry.get("file_no", "RECORD-01"))
	var number_label := sheet.find_child("PersonFileNumber", true, false) as Label
	if number_label != null:
		number_label.text = UIKit.tr_upper(tr("GİZLİ SİCİL DOSYASI · NO: %s") % serial)
	_meta_name.text = actor.display_name
	_meta_title.text = actor.title
	var tier := Sim.power_tier(actor.power)
	var tier_name: String = Sim.POWER_TIER_NAMES[tier]
	_meta_power.text = "%s — %s" % [tr(tier_name), tr("Saraydaki ağırlığı belirgin.")]
	var suspicion := Sim.suspicion_level(actor_id)
	var attitude: String = Sim.SUSPICION_NAMES[clampi(suspicion, 0, Sim.SUSPICION_NAMES.size() - 1)]
	_meta_attitude.text = "%s — %s" % [tr(attitude), _attitude_summary(actor)]
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
	_refresh_action_lines()


func _refresh_action_lines() -> void:
	for key in _action_lines:
		var button := host._buttons.get(key) as Button
		var labels: Dictionary = _action_lines[key]
		var title := labels.get("title") as Label
		var effect := labels.get("effect") as Label
		if button == null or title == null or effect == null:
			continue
		button.text = _person_panel._dossier_action_title(button)
		title.text = button.text
		effect.text = _person_panel._dossier_action_effect(button)
		button.custom_minimum_size.y = _person_panel._dossier_action_height(button)
		title.add_theme_color_override("font_color", Color("806b4e") if button.disabled else Color("2a1c0e"))
		effect.add_theme_color_override("font_color", Color("806b4e") if button.disabled else Color("4e3a24"))
	_update_action_scroll_hint()


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
