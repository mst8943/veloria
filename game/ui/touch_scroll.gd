extends Node
## Mobil dokunmatik kaydırma. Parmak bir düğmenin üstünden başlasa bile sürükleme kaydırır, düğmeye basmaz.
## Eşik aşılınca düğmenin basılı durumu iptal edilir (ekran dışı sahte bırakma olayı), olaylar yutulur,
## bırakınca kısa bir ivme (atalet) eklenir. Dokunuş eşiğin altındaysa hiçbir şey yutulmaz: normal tıklama.

const DRAG_START := 9.0
const COAST_MIN := 160.0      # px/sn: bunun altında ivme yok
const COAST_DECAY := 4.2

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
const SYNTH_POS := Vector2(-4000, -4000)   # iptal için gönderilen sahte bırakma olayının konumu


func _ready() -> void:
	process_priority = -100
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
	var mb := event as InputEventMouseButton
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
		else:
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
			_cancel_press()
			from = _start
		var delta := mm.position - from
		var target := _horizontal if _axis == "h" else _vertical
		_scroll(target, _axis == "h", -(delta.x if _axis == "h" else delta.y))
		var dt := maxf(get_process_delta_time(), 0.001)
		_vel = _vel.lerp(delta / dt, 0.35)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
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
