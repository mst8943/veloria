extends Node
## Mobil dokunmatik kaydırma. Parmak bir düğmenin üstünden başlasa bile sürükleme kaydırır, düğmeye basmaz.
## Eşik aşılınca düğmenin basılı durumu iptal edilir (ekran dışı sahte bırakma olayı), olaylar yutulur,
## bırakınca kısa bir ivme (atalet) eklenir. Dokunuş eşiğin altındaysa hiçbir şey yutulmaz: normal tıklama.

const DRAG_START := 9.0
const TAP_MOVE_LIMIT := 11.0
const TAP_TIME_LIMIT_MS := 480
const PRESS_FEEDBACK_MS := 80
const COAST_MIN := 160.0      # px/sn: bunun altında ivme yok
const COAST_DECAY := 4.2
const LONG_PRESS_MS := 480    # uzun basış: ipucu balonu (dokunmatikte "üzerine gelme" yok)
const TIP_SECONDS := 3.6
const TOUCH_GOLD := Color("d6b25e")
const TOUCH_PLATE := Color("0c0b09")
const TOUCH_TEXT := Color("e9e4d6")

var _pressing := false
var _dragging := false
var _start := Vector2.ZERO
var _last := Vector2.ZERO
var _horizontal: Control
var _vertical: Control
var _axis := ""              # "h" | "v" (sürükleme yönü, eşik aşılınca seçilir)
var _vel := Vector2.ZERO
var _acc := Vector2.ZERO     # tam sayıya yuvarlanamayan kalan hareket
var _coast: Vector2 = Vector2.ZERO
var _coast_h: Control
var _coast_v: Control
var _press_ms := 0
var _long_armed := false     # uzun basış bekleniyor
var _long_fired := false     # ipucu gösterildi: bırakma yutulur, düğmeye basılmaz
var _tip_layer: CanvasLayer
var _tip_panel: PanelContainer
var _tip_label: Label
var _tip_timer := 0.0
const SYNTH_POS := Vector2(-4000, -4000)   # iptal için gönderilen sahte bırakma olayının konumu
static var dispatching_touch := false
var _touch_active := false
var _touch_cancelled := false
var _touch_moved := false
var _touch_started_ms := 0
var _touch_start := Vector2.ZERO
var _touch_last := Vector2.ZERO
var _touch_feedback_target: Control
var _touch_feedback_layer: CanvasLayer
var _touch_feedback: Panel


func _ready() -> void:
	process_priority = -100
	Input.emulate_mouse_from_touch = false
	get_tree().node_added.connect(_on_node_added)
	_walk(get_tree().root)


func _walk(n: Node) -> void:
	_on_node_added(n)
	for c in n.get_children():
		_walk(c)


func _on_node_added(n: Node) -> void:
	if n is ScrollContainer:
		# Yerleşik dokunmatik kaydırma kapatılır: çift kaydırma olmasın, kaydırmayı bu betik yapar.
		(n as ScrollContainer).scroll_deadzone = 100000


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)
		get_viewport().set_input_as_handled()
		return
	if dispatching_touch:
		return
	var mb := event as InputEventMouseButton
	if mb != null and mb.device == -1:
		get_viewport().set_input_as_handled()
		return
	if mb != null and mb.position.x < -1000.0:   # sahte iptal olayı (pencere ölçeğiyle çarpılmış olabilir)
		return
	if mb != null and mb.button_index == MOUSE_BUTTON_LEFT:
		if mb.pressed:
			_coast = Vector2.ZERO
			_pressing = true
			_dragging = false
			_start = mb.position
			_last = mb.position
			_vel = Vector2.ZERO
			_acc = Vector2.ZERO
			_horizontal = null
			_vertical = null
			_press_ms = Time.get_ticks_msec()
			_long_armed = true
			_long_fired = false
			_hide_tip()
		else:
			_long_armed = false
			if _long_fired:
				_long_fired = false
				_pressing = false
				_dragging = false
				get_viewport().set_input_as_handled()
				return
			var was := _dragging
			_pressing = false
			_dragging = false
			if was:
				get_viewport().set_input_as_handled()
				if _vel.length() > COAST_MIN:
					_coast = _vel
					_coast_h = _horizontal if _axis == "h" else null
					_coast_v = _vertical if _axis == "v" else null
		return
	var mm := event as InputEventMouseMotion
	if mm != null and mm.position.x < -1000.0:
		return
	if mm != null and _pressing:
		var from := _last
		_last = mm.position
		if not _dragging:
			var d := mm.position - _start
			if d.length() < DRAG_START:
				return
			_find_targets(_start)
			_axis = "h" if absf(d.x) > absf(d.y) else "v"
			if (_axis == "h" and _horizontal == null) or (_axis == "v" and _vertical == null):
				if _axis == "h" and _vertical != null:
					_axis = "v"
				elif _axis == "v" and _horizontal != null:
					_axis = "h"
				else:
					_pressing = false   # kaydırılacak bir şey yok: normal dokunuş akışı sürsün
					return
			_dragging = true
			_long_armed = false
			_cancel_press()
			from = _start
		var delta := mm.position - from
		var target := _horizontal if _axis == "h" else _vertical
		_scroll(target, _axis == "h", -(delta.x if _axis == "h" else delta.y))
		var dt := maxf(get_process_delta_time(), 0.001)
		_vel = _vel.lerp(delta / dt, 0.35)
		get_viewport().set_input_as_handled()


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_active = true
		_touch_cancelled = false
		_touch_moved = false
		_touch_start = event.position
		_touch_last = event.position
		_touch_started_ms = Time.get_ticks_msec()
		_vel = Vector2.ZERO
		_horizontal = null
		_vertical = null
		_axis = ""
		_touch_feedback_target = _control_at(event.position)
		_hide_touch_feedback()
		return
	if not _touch_active:
		return
	var valid_tap := not _touch_cancelled and not _touch_moved and Time.get_ticks_msec() - _touch_started_ms < TAP_TIME_LIMIT_MS
	var was_dragging := _touch_cancelled and _touch_moved
	_touch_active = false
	_hide_touch_feedback()
	if valid_tap:
		_dispatch_touch_click.call_deferred(event.position)
	elif was_dragging and _vel.length() > COAST_MIN:
		_coast = _vel
		_coast_h = _horizontal if _axis == "h" else null
		_coast_v = _vertical if _axis == "v" else null


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if not _touch_active:
		return
	var delta_from_start := event.position - _touch_start
	if delta_from_start.length() > 3.0:
		_touch_moved = true
		_hide_touch_feedback()
	if not _touch_cancelled and delta_from_start.length() >= TAP_MOVE_LIMIT:
		_touch_cancelled = true
		_find_targets(_touch_start)
		_axis = "h" if absf(delta_from_start.x) > absf(delta_from_start.y) else "v"
		if (_axis == "h" and _horizontal == null) or (_axis == "v" and _vertical == null):
			if _axis == "h" and _vertical != null:
				_axis = "v"
			elif _axis == "v" and _horizontal != null:
				_axis = "h"
		_touch_last = _touch_start
	if _touch_cancelled:
		var delta := event.position - _touch_last
		var target := _horizontal if _axis == "h" else _vertical
		if target != null:
			_scroll(target, _axis == "h", -(delta.x if _axis == "h" else delta.y))
			var dt := maxf(get_process_delta_time(), 0.001)
			_vel = _vel.lerp(delta / dt, 0.35)
		_touch_last = event.position


func _dispatch_touch_click(pos: Vector2) -> void:
	dispatching_touch = true
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.device = 0
	press.position = pos
	press.global_position = pos
	var release := press.duplicate() as InputEventMouseButton
	release.pressed = false
	get_viewport().push_input(press, true)
	get_viewport().push_input(release, true)
	dispatching_touch = false


func _control_at(pos: Vector2) -> Control:
	var found: Array = [-1, -1, null]
	var seq := [0]
	_collect_hit(get_tree().root, pos, 0, seq, found)
	return found[2] as Control


func _collect_hit(n: Node, pos: Vector2, layer: int, seq: Array, found: Array) -> void:
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	var l := layer
	if n is CanvasLayer:
		l = (n as CanvasLayer).layer
	if n is Control:
		seq[0] += 1
		var c := n as Control
		if c.mouse_filter != Control.MOUSE_FILTER_IGNORE and c.get_global_rect().has_point(pos):
			if _better(l, seq[0], found):
				found[0] = l
				found[1] = seq[0]
				found[2] = c
	for ch in n.get_children():
		_collect_hit(ch, pos, l, seq, found)


func _show_touch_feedback() -> void:
	if _touch_feedback_target == null or not is_instance_valid(_touch_feedback_target):
		return
	if _touch_feedback_layer == null:
		_touch_feedback_layer = CanvasLayer.new()
		_touch_feedback_layer.layer = 199
		add_child(_touch_feedback_layer)
		_touch_feedback = Panel.new()
		_touch_feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(TOUCH_GOLD, 0.12)
		style.border_color = TOUCH_GOLD
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		_touch_feedback.add_theme_stylebox_override("panel", style)
		_touch_feedback_layer.add_child(_touch_feedback)
	var rect := _touch_feedback_target.get_global_rect()
	_touch_feedback.position = rect.position
	_touch_feedback.size = rect.size
	_touch_feedback.show()


func _hide_touch_feedback() -> void:
	if _touch_feedback != null:
		_touch_feedback.hide()


func _process(delta: float) -> void:
	if _touch_active and not _touch_cancelled and not _touch_moved and Time.get_ticks_msec() - _touch_started_ms >= TAP_TIME_LIMIT_MS:
		_touch_cancelled = true
		_hide_touch_feedback()
	if _touch_active and not _touch_cancelled and not _touch_moved and Time.get_ticks_msec() - _touch_started_ms >= PRESS_FEEDBACK_MS:
		_show_touch_feedback()
	if _tip_timer > 0.0:
		_tip_timer -= delta
		if _tip_timer <= 0.0:
			_hide_tip()
	if _long_armed and _pressing and not _dragging and Time.get_ticks_msec() - _press_ms >= LONG_PRESS_MS:
		_long_armed = false
		var tip := _find_tip(_start)
		if tip != "":
			_long_fired = true
			_cancel_press()
			_show_tip(tip, _start)
	if _coast == Vector2.ZERO:
		return
	var v := _coast.x if _coast_h != null else _coast.y
	var target := _coast_h if _coast_h != null else _coast_v
	if target == null or absf(v) < 20.0 or not is_instance_valid(target):
		_coast = Vector2.ZERO
		return
	_scroll(target, _coast_h != null, -v * delta)
	_coast *= exp(-COAST_DECAY * delta)


## Basılı düğmeyi iptal eder: ekran dışında bir bırakma olayı gönderilir (basış sinyali çıkmaz).
func _cancel_press() -> void:
	# Önce ekran dışına hareket (düğme "basış içeride" durumunu bırakır), sonra bırakma.
	var mv := InputEventMouseMotion.new()
	mv.position = SYNTH_POS
	mv.global_position = SYNTH_POS
	mv.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(mv)
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	ev.position = SYNTH_POS
	ev.global_position = SYNTH_POS
	Input.parse_input_event(ev)


func _scroll(c: Control, horizontal: bool, amount: float) -> void:
	if c == null or not is_instance_valid(c):
		return
	var a := _acc.x if horizontal else _acc.y
	a += amount
	var whole := int(a)
	a -= whole
	if horizontal:
		_acc.x = a
	else:
		_acc.y = a
	if whole == 0:
		return
	if c is ScrollContainer:
		var sc := c as ScrollContainer
		if horizontal:
			sc.scroll_horizontal += whole
		else:
			sc.scroll_vertical += whole
	elif c is RichTextLabel:
		var bar := (c as RichTextLabel).get_v_scroll_bar()
		bar.value += whole
	elif c is ItemList:
		var bar2 := (c as ItemList).get_v_scroll_bar()
		bar2.value += whole


# ---------------------------------------------------------------- Hedef bulma

func _find_targets(pos: Vector2) -> void:
	_horizontal = null
	_vertical = null
	var best_h := [-1, -1]   # [katman, sıra]
	var best_v := [-1, -1]
	var seq := [0]
	_collect(get_tree().root, pos, 0, seq, best_h, best_v)


func _collect(n: Node, pos: Vector2, layer: int, seq: Array, best_h: Array, best_v: Array) -> void:
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	var l := layer
	if n is CanvasLayer:
		l = (n as CanvasLayer).layer
	if n is Control:
		seq[0] += 1
		var c := n as Control
		if c.get_global_rect().has_point(pos):
			if _can(c, true) and _better(l, seq[0], best_h):
				_horizontal = c
				best_h[0] = l
				best_h[1] = seq[0]
			if _can(c, false) and _better(l, seq[0], best_v):
				_vertical = c
				best_v[0] = l
				best_v[1] = seq[0]
	for ch in n.get_children():
		_collect(ch, pos, l, seq, best_h, best_v)


func _better(layer: int, order: int, best: Array) -> bool:
	return layer > best[0] or (layer == best[0] and order > best[1])


func _can(c: Control, horizontal: bool) -> bool:
	if c is ScrollContainer:
		var sc := c as ScrollContainer
		var mode := sc.horizontal_scroll_mode if horizontal else sc.vertical_scroll_mode
		if mode == ScrollContainer.SCROLL_MODE_DISABLED:
			return false
		var bar: ScrollBar = sc.get_h_scroll_bar() if horizontal else sc.get_v_scroll_bar()
		return bar.max_value - bar.page > 1.0
	if horizontal:
		return false
	if c is RichTextLabel:
		var rl := c as RichTextLabel
		var b := rl.get_v_scroll_bar()
		return rl.scroll_active and b.max_value - b.page > 1.0
	if c is ItemList:
		var b2 := (c as ItemList).get_v_scroll_bar()
		return b2.max_value - b2.page > 1.0
	return false


# ---------------------------------------------------------------- Uzun basış ipucu

func _find_tip(pos: Vector2) -> String:
	var best: Array = [""]   # (lambda dış değişkeni değiştiremez; dizi taşıyıcı)
	var best_rank := [-1, -1]
	var seq := [0]
	_collect_tip(get_tree().root, pos, 0, seq, best_rank, best)
	return str(best[0])


func _collect_tip(n: Node, pos: Vector2, layer: int, seq: Array, best_rank: Array, best: Array) -> void:
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	var l := layer
	if n is CanvasLayer:
		if n == _tip_layer:
			return
		l = (n as CanvasLayer).layer
	if n is Control:
		seq[0] += 1
		var c := n as Control
		if c.tooltip_text != "" and c.get_global_rect().has_point(pos):
			if _better(l, seq[0], best_rank):
				best_rank[0] = l
				best_rank[1] = seq[0]
				best[0] = c.tooltip_text
	for ch in n.get_children():
		_collect_tip(ch, pos, l, seq, best_rank, best)


func _show_tip(text: String, at: Vector2) -> void:
	if _tip_layer == null:
		_tip_layer = CanvasLayer.new()
		_tip_layer.layer = 200
		add_child(_tip_layer)
		_tip_panel = PanelContainer.new()
		_tip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(TOUCH_PLATE, 0.97)
		style.border_color = TOUCH_GOLD
		style.set_border_width_all(2)
		style.set_corner_radius_all(5)
		style.set_content_margin_all(12)
		_tip_panel.add_theme_stylebox_override("panel", style)
		_tip_layer.add_child(_tip_panel)
		_tip_label = Label.new()
		_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_tip_label.custom_minimum_size.x = 340
		_tip_label.add_theme_font_size_override("font_size", 18)
		_tip_label.add_theme_color_override("font_color", TOUCH_TEXT)
		_tip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tip_panel.add_child(_tip_label)
	_tip_label.text = text
	_tip_panel.reset_size()
	var vp := get_viewport().get_visible_rect().size
	var sz := _tip_panel.get_combined_minimum_size()
	var pos := at + Vector2(-sz.x * 0.5, -sz.y - 22.0)
	if pos.y < 6.0:
		pos.y = at.y + 30.0
	pos.x = clampf(pos.x, 6.0, maxf(6.0, vp.x - sz.x - 6.0))
	pos.y = clampf(pos.y, 6.0, maxf(6.0, vp.y - sz.y - 6.0))
	_tip_panel.position = pos
	_tip_panel.show()
	_tip_timer = TIP_SECONDS


func _hide_tip() -> void:
	_tip_timer = 0.0
	if _tip_panel != null:
		_tip_panel.hide()
