extends Control
## Small line icons used by the royal header and section markers.

var kind := ""
var line_color := Color("d6b25e")
var filled := false


func _draw() -> void:
	var r := Rect2(Vector2(3, 3), size - Vector2(6, 6))
	var c := line_color
	var w := 1.6
	match kind:
		"diamond":
			var p := PackedVector2Array([Vector2(size.x / 2, 2), Vector2(size.x - 2, size.y / 2), Vector2(size.x / 2, size.y - 2), Vector2(2, size.y / 2), Vector2(size.x / 2, 2)])
			if filled:
				draw_colored_polygon(p.slice(0, 4), c)
			else:
				draw_polyline(p, c, w, true)
		"envelope":
			draw_rect(r, c, false, w)
			draw_line(r.position, r.position + Vector2(r.size.x / 2, r.size.y * 0.48), c, w, true)
			draw_line(Vector2(r.end.x, r.position.y), r.position + Vector2(r.size.x / 2, r.size.y * 0.48), c, w, true)
		"folder":
			var p := PackedVector2Array([r.position, r.position + Vector2(r.size.x * 0.36, 0), r.position + Vector2(r.size.x * 0.48, r.size.y * 0.2), Vector2(r.end.x, r.position.y + r.size.y * 0.2), r.end, r.position + Vector2(0, r.size.y * 0.2), r.position])
			draw_polyline(p, c, w, true)
		"scroll":
			draw_rect(Rect2(r.position + Vector2(3, 1), r.size - Vector2(6, 2)), c, false, w)
			for i in 3:
				var y := r.position.y + 7 + i * 4
				draw_line(Vector2(r.position.x + 7, y), Vector2(r.end.x - 5, y), c, 1.0, true)
		"building":
			draw_line(Vector2(r.position.x, r.position.y + 5), Vector2(size.x / 2, r.position.y), c, w, true)
			draw_line(Vector2(size.x / 2, r.position.y), Vector2(r.end.x, r.position.y + 5), c, w, true)
			draw_line(Vector2(r.position.x, r.position.y + 6), Vector2(r.end.x, r.position.y + 6), c, w, true)
			for i in 3:
				var x := r.position.x + 4 + i * (r.size.x - 8) / 2
				draw_line(Vector2(x, r.position.y + 7), Vector2(x, r.end.y - 4), c, w, true)
			draw_line(Vector2(r.position.x, r.end.y - 3), Vector2(r.end.x, r.end.y - 3), c, w, true)
		"newspaper":
			draw_rect(r, c, false, w)
			draw_line(r.position + Vector2(3, 5), Vector2(r.end.x - 3, r.position.y + 5), c, 1.0, true)
			draw_rect(Rect2(r.position + Vector2(3, 8), Vector2(r.size.x * 0.3, r.size.y - 11)), c, false, 1.0)
			for i in 2:
				var y := r.position.y + 9 + i * 4
				draw_line(Vector2(r.position.x + r.size.x * 0.42, y), Vector2(r.end.x - 3, y), c, 1.0, true)
		"seal":
			draw_rect(Rect2(r.position.x + 3, r.position.y, r.size.x - 6, r.size.y * 0.72), c, false, w)
			draw_line(Vector2(r.position.x + 6, r.position.y + 4), Vector2(r.end.x - 6, r.position.y + 4), c, 1.0, true)
			var center := Vector2(size.x / 2, r.end.y - 3)
			draw_circle(center, 4, c, false, w, true)
			draw_line(center + Vector2(-2, 3), center + Vector2(-3, 7), c, w, true)
			draw_line(center + Vector2(2, 3), center + Vector2(3, 7), c, w, true)
		"gear":
			var center := size / 2
			draw_circle(center, minf(size.x, size.y) * 0.25, c, false, w, true)
			draw_circle(center, minf(size.x, size.y) * 0.08, c, false, 1.0, true)
			for i in 8:
				var a := TAU * float(i) / 8.0
				draw_line(center + Vector2(cos(a), sin(a)) * 6.5, center + Vector2(cos(a), sin(a)) * 9.0, c, w, true)
		"star":
			var points := PackedVector2Array()
			for i in 10:
				var a := -PI / 2 + TAU * float(i) / 10.0
				var radius := minf(size.x, size.y) * (0.45 if i % 2 == 0 else 0.2)
				points.append(size / 2 + Vector2(cos(a), sin(a)) * radius)
			points.append(points[0])
			if filled:
				draw_colored_polygon(points.slice(0, 10), c)
			else:
				draw_polyline(points, c, w, true)
		"lily":
			if filled:
				_draw_fleur(c)
				return
			var cx := size.x * 0.5
			var base_y := size.y * 0.82
			var center := PackedVector2Array([Vector2(cx, base_y), Vector2(cx - size.x * 0.09, size.y * 0.43), Vector2(cx, size.y * 0.08), Vector2(cx + size.x * 0.09, size.y * 0.43), Vector2(cx, base_y)])
			draw_polyline(center, c, 2.0, true)
			var left := PackedVector2Array([Vector2(cx, size.y * 0.62), Vector2(size.x * 0.08, size.y * 0.25), Vector2(size.x * 0.14, size.y * 0.67), Vector2(cx, size.y * 0.78)])
			var right := PackedVector2Array([Vector2(cx, size.y * 0.62), Vector2(size.x * 0.92, size.y * 0.25), Vector2(size.x * 0.86, size.y * 0.67), Vector2(cx, size.y * 0.78)])
			draw_polyline(left, c, 2.0, true)
			draw_polyline(right, c, 2.0, true)
			draw_line(Vector2(size.x * 0.12, base_y), Vector2(size.x * 0.88, base_y), c, 2.0, true)
		"flourish":
			var cy := size.y / 2.0
			var pts := PackedVector2Array()
			for i in 17:
				var t := float(i) / 16.0
				pts.append(Vector2(1.0 + t * (size.x - 2.0), cy + sin(t * TAU) * size.y * 0.22))
			draw_polyline(pts, c, w, true)
			for side in [-1.0, 1.0]:
				var p := Vector2(size.x * (0.5 + side * 0.2), cy - side * size.y * 0.15)
				draw_arc(p, size.y * 0.22, -PI * 0.1, PI * 1.65, 18, c, w, true)
				draw_line(p + Vector2(-2, size.y * 0.18), p + Vector2(2, size.y * 0.3), c, w, true)
		"endcap":
			var mid_y := size.y * 0.5
			draw_line(Vector2(2, 2), Vector2(2, size.y - 2), c, w, true)
			draw_colored_polygon(PackedVector2Array([Vector2(4, 2), Vector2(size.x - 2, mid_y), Vector2(4, size.y - 2)]), c)


## Dolu zambak (fleur-de-lis): mızrak uçlu orta yaprak, dışa ve aşağı kıvrılan yan yapraklar, bağ, kısa ayaklar.
func _draw_fleur(c: Color) -> void:
	var W := size.x
	var H := size.y
	var mid := [[0.5, 0.0], [0.585, 0.15], [0.615, 0.3], [0.585, 0.46], [0.545, 0.6], [0.455, 0.6], [0.415, 0.46], [0.385, 0.3], [0.415, 0.15]]
	draw_colored_polygon(_smooth(mid, W, H, 0.5, 1.0), c)
	var petal := [[0.53, 0.62], [0.57, 0.44], [0.65, 0.29], [0.77, 0.21], [0.9, 0.24], [0.97, 0.36], [0.94, 0.5], [0.86, 0.57], [0.88, 0.47], [0.85, 0.38], [0.77, 0.34], [0.69, 0.41], [0.635, 0.53], [0.6, 0.63]]
	var foot := [[0.55, 0.68], [0.64, 0.73], [0.71, 0.81], [0.73, 0.93], [0.66, 0.88], [0.6, 0.8], [0.54, 0.77]]
	for side in [1.0, -1.0]:
		draw_colored_polygon(_smooth(petal, W, H, side, 1.0), c)
		draw_colored_polygon(_smooth(foot, W, H, side, 1.0), c)
	draw_rect(Rect2(Vector2(0.28 * W, 0.6 * H), Vector2(0.44 * W, 0.085 * H)), c)
	draw_colored_polygon(_smooth([[0.455, 0.68], [0.545, 0.68], [0.525, 0.86], [0.5, 0.98], [0.475, 0.86]], W, H, 1.0, 1.0), c)


func _smooth(pts: Array, W: float, H: float, side: float, _k: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(Vector2((0.5 + side * (float(p[0]) - 0.5)) * W, float(p[1]) * H))
	return out
