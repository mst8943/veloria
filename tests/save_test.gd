extends SceneTree
## Kayıt sürümü ve göç testi: gidiş-dönüş, eski (sürümsüz) kaydın göçü, yeni sürüm reddi, eksik alan ve bozuk dosya.
##   Godot_console.exe --headless --path . --script res://tests/save_test.gd
## Sonda "SAVE: OK" ya da "SAVE: FAIL". Oyuncunun kaydına dokunmaz (ayrı dosya, sonda silinir).
## Kayıt şeması değişince (Sim.SAVE_VERSION artınca) eski sürümü taklit eden bir adım ekle.

var ok := true


func _init() -> void:
	var sim: Node = load("res://game/core/sim.gd").new()
	sim.save_path = "user://save_version_test.txt"
	sim.record_chronicle = false
	sim.autosave = false
	sim.new_game(5)
	for i in 6:
		sim.end_week()
	var wk: int = sim.week
	var changes: int = sim.week_changes.size()
	_check("kaydet", sim.save_game())
	_check("gidiş-dönüş", sim.load_game() and sim.week == wk and sim.week_changes.size() == changes)
	var f := FileAccess.open(sim.save_path, FileAccess.READ)
	var d: Dictionary = str_to_var(f.get_as_text())
	f.close()
	_check("sürüm yazıldı", int(d.get("version", 0)) == sim.SAVE_VERSION)
	# Sürüm 3: rejim henüz kayıt şemasında yoktu.
	var v3 := d.duplicate(true)
	v3["version"] = 3
	v3["week"] = 62
	v3.erase("regime")
	_write(sim.save_path, v3)
	_check("v3 rejim göçü", sim.load_game() and sim.regime != "" and sim.week == 62)
	_check("göçte haber tekrarı yok", sim.weekly_news.filter(func(x: String) -> bool: return x.begins_with("REJİM:")).is_empty())
	# Sürüm 1: sürüm alanı ve 2'de eklenen alanlar yok.
	var v1 := d.duplicate(true)
	for k in ["version", "report_prev", "week_changes", "regime"]:
		v1.erase(k)
	_write(sim.save_path, v1)
	_check("v1 göçü", sim.load_game() and sim.week == wk)
	sim.end_week()
	_check("v1 sonrası hafta akışı", sim.week == wk + 1 or sim.ended)
	var newer := d.duplicate(true)
	newer["version"] = sim.SAVE_VERSION + 1
	_write(sim.save_path, newer)
	_check("yeni sürüm reddi", not sim.load_game() and sim.load_error != "")
	var broken := d.duplicate(true)
	broken.erase("actors")
	_write(sim.save_path, broken)
	_check("eksik alan reddi", not sim.load_game() and sim.load_error != "")
	_write(sim.save_path, "bozuk dosya")
	_check("bozuk dosya reddi", not sim.load_game() and sim.load_error != "")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	sim.free()
	print("SAVE: OK" if ok else "SAVE: FAIL")
	quit(0 if ok else 1)


func _check(name: String, cond: bool) -> void:
	print("%s  %s" % ["ok  " if cond else "FAIL", name])
	ok = ok and cond


func _write(p: String, v: Variant) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(var_to_str(v) if v is Dictionary else str(v))
	f.close()
