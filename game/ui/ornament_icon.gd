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
			var mid := Vector2(size.x / 2, size.y * 0.78)
			draw_line(mid, Vector2(size.x / 2, size.y * 0.25), c, w, true)
			draw_line(Vector2(size.x / 2, size.y * 0.58), Vector2(size.x * 0.18, size.y * 0.28), c, w, true)
			draw_line(Vector2(size.x / 2, size.y * 0.58), Vector2(size.x * 0.82, size.y * 0.28), c, w, true)
			draw_arc(Vector2(size.x / 2, size.y * 0.34), size.x * 0.24, PI, TAU, 16, c, w, true)
			draw_line(Vector2(size.x * 0.18, size.y * 0.28), Vector2(size.x * 0.28, size.y * 0.54), c, w, true)
			draw_line(Vector2(size.x * 0.82, size.y * 0.28), Vector2(size.x * 0.72, size.y * 0.54), c, w, true)
		"flourish":
			var cy := size.y / 2.0
			draw_line(Vector2(1, cy), Vector2(size.x * 0.38, cy), c, w, true)
			draw_arc(Vector2(size.x * 0.48, cy - 2), size.y * 0.22, PI * 0.15, PI * 1.7, 18, c, w, true)
			draw_arc(Vector2(size.x * 0.73, cy + 2), size.y * 0.22, -PI * 0.8, PI * 0.75, 18, c, w, true)
