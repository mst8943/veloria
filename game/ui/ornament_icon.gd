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
			# Sütunlu bina (mockup): alınlık, dört sütun, iki basamak.
			var bw := maxf(1.8, size.x / 14.0)
			var L := size.x * 0.1
			var R := size.x * 0.9
			draw_colored_polygon(PackedVector2Array([Vector2(size.x / 2, size.y * 0.1), Vector2(R, size.y * 0.32), Vector2(L, size.y * 0.32)]), c)
			draw_line(Vector2(L, size.y * 0.37), Vector2(R, size.y * 0.37), c, bw, true)
			for i in 4:
				var x := lerpf(size.x * 0.2, size.x * 0.8, float(i) / 3.0)
				draw_line(Vector2(x, size.y * 0.42), Vector2(x, size.y * 0.76), c, bw, true)
			draw_line(Vector2(size.x * 0.06, size.y * 0.81), Vector2(size.x * 0.94, size.y * 0.81), c, bw, true)
			draw_line(Vector2(size.x * 0.02, size.y * 0.9), Vector2(size.x * 0.98, size.y * 0.9), c, bw, true)
		"newspaper":
			# Açık gazete: çerçeve, ortada kat yeri, iki sütun satırı.
			var bw := maxf(1.6, size.x / 16.0)
			var rr := Rect2(size * Vector2(0.06, 0.16), size * Vector2(0.88, 0.68))
			draw_rect(rr, c, false, bw)
			draw_line(Vector2(size.x / 2, rr.position.y), Vector2(size.x / 2, rr.end.y), c, bw * 0.8, true)
			for col in [rr.position.x + rr.size.x * 0.1, size.x / 2 + rr.size.x * 0.08]:
				for i in 3:
					var y := rr.position.y + rr.size.y * (0.25 + 0.25 * float(i))
					draw_line(Vector2(col, y), Vector2(col + rr.size.x * 0.32, y), c, bw * 0.8, true)
		"seal":
			draw_rect(Rect2(r.position.x + 3, r.position.y, r.size.x - 6, r.size.y * 0.72), c, false, w)
			draw_line(Vector2(r.position.x + 6, r.position.y + 4), Vector2(r.end.x - 6, r.position.y + 4), c, 1.0, true)
			var center := Vector2(size.x / 2, r.end.y - 3)
			draw_circle(center, 4, c, false, w, true)
			draw_line(center + Vector2(-2, 3), center + Vector2(-3, 7), c, w, true)
			draw_line(center + Vector2(2, 3), center + Vector2(3, 7), c, w, true)
		"gear":
			var center := size / 2
			var rad := minf(size.x, size.y)
			var bw := maxf(1.8, rad / 14.0)
			var pts := PackedVector2Array()
			for i in 32:
				var a := TAU * float(i) / 32.0
				pts.append(center + Vector2(cos(a), sin(a)) * rad * (0.46 if (i % 4) < 2 else 0.36))
			pts.append(pts[0])
			draw_polyline(pts, c, bw, true)
			draw_circle(center, rad * 0.15, c, false, bw, true)
		"hourglass":
			var bw := maxf(1.8, size.x / 14.0)
			var L := size.x * 0.22
			var R := size.x * 0.78
			draw_line(Vector2(size.x * 0.14, size.y * 0.08), Vector2(size.x * 0.86, size.y * 0.08), c, bw * 1.3, true)
			draw_line(Vector2(size.x * 0.14, size.y * 0.92), Vector2(size.x * 0.86, size.y * 0.92), c, bw * 1.3, true)
			draw_polyline(PackedVector2Array([Vector2(L, size.y * 0.1), Vector2(L, size.y * 0.24), Vector2(size.x / 2, size.y * 0.5), Vector2(L, size.y * 0.76), Vector2(L, size.y * 0.9)]), c, bw, true)
			draw_polyline(PackedVector2Array([Vector2(R, size.y * 0.1), Vector2(R, size.y * 0.24), Vector2(size.x / 2, size.y * 0.5), Vector2(R, size.y * 0.76), Vector2(R, size.y * 0.9)]), c, bw, true)
			draw_colored_polygon(PackedVector2Array([Vector2(size.x * 0.32, size.y * 0.86), Vector2(size.x * 0.68, size.y * 0.86), Vector2(size.x / 2, size.y * 0.66)]), c)
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
			# İnce ok ucu kapanışı (mockup): iki çizgili sivri uç.
			var mid_y := size.y * 0.5
			draw_polyline(PackedVector2Array([Vector2(2, 1), Vector2(size.x - 2, mid_y), Vector2(2, size.y - 1)]), c, 1.6, true)
			draw_polyline(PackedVector2Array([Vector2(1, 6), Vector2(size.x - 7, mid_y), Vector2(1, size.y - 6)]), Color(c, 0.5), 1.0, true)


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
