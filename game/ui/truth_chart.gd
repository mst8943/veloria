extends Control
## Hakikat grafiği: oyun boyunca gizli kalan gerçek durumun haftalık seyri.
## Altın: taht · kırmızı: halk · mor: komplo · yeşil: kurumlar · mavi: Sarne.

const UIKit := preload("res://game/ui/ui_kit.gd")
const SERIES := [
	{"key": "king", "name": "Tahtın gücü", "color": Color("d6b25e")},
	{"key": "unrest", "name": "Halkın öfkesi", "color": Color("c0504a")},
	{"key": "plot", "name": "Komplo", "color": Color("9a6ad6")},
	{"key": "capacity", "name": "Devlet", "color": Color("7fae7a")},
	{"key": "holding", "name": "Sarne'nin payı", "color": Color("66a9bd")},
]

var data: Array = []
var _progress := 1.0   # çizginin ne kadarının çizildiği (animasyon)


func set_data(d: Array, animate := true) -> void:
	data = d
	_progress = 0.0 if animate else 1.0
	if animate:
		var tw := create_tween()
		tw.tween_property(self, "_progress", 1.0, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_callback(queue_redraw)
	queue_redraw()


func _process(_d: float) -> void:
	if _progress < 1.0:
		queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	var r := Rect2(Vector2(44, 48), size - Vector2(60, 72))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	draw_string(UIKit.serif(), Vector2(10, 18), "GERÇEKTE NE OLDU", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UIKit.GOLD)
	# Yatay kılavuz çizgileri
	for i in 5:
		var y := r.position.y + r.size.y * i / 4.0
		draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color(1, 1, 1, 0.06), 1.0)
	if data.size() < 2:
		draw_string(font, r.position + Vector2(10, 30), "Yeterli veri yok.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UIKit.TEXT_DIM)
		return
	var last_w := float(data[-1]["w"])
	var first_w := float(data[0]["w"])
	var span := maxf(last_w - first_w, 1.0)
	# Hafta etiketleri
	for i in 5:
		var w := first_w + span * i / 4.0
		draw_string(font, Vector2(r.position.x + r.size.x * i / 4.0 - 10, r.end.y + 16), "H%d" % int(w), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, UIKit.TEXT_DIM)
	var cut := int(ceil((data.size() - 1) * _progress)) + 1
	for s in SERIES:
		var pts := PackedVector2Array()
		for i in mini(cut, data.size()):
			var d: Dictionary = data[i]
			var x := r.position.x + r.size.x * (float(d["w"]) - first_w) / span
			var y := r.end.y - r.size.y * clampf(float(d.get(s["key"], 0.0)) / 100.0, 0.0, 1.0)
			pts.append(Vector2(x, y))
		if pts.size() >= 2:
			draw_polyline(pts, s["color"], 2.0, true)
	# Lejant
	var lx := maxf(44.0, r.end.x - 675.0)
	for s in SERIES:
		draw_rect(Rect2(Vector2(lx, 32), Vector2(12, 4)), s["color"])
		draw_string(font, Vector2(lx + 16, 38), s["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, UIKit.TEXT)
		lx += 135.0
