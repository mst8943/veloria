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
	_check("başlangıç kurum aralığı", sim.capacity.size() == 4 and sim.capacity.values().all(func(v: float) -> bool: return v >= 50.0 and v <= 60.0))
	_check("başlangıç holdingi", sim.holding == 40.0 and sim.kadro_log.is_empty())
	sim.appoint("kessler", "merit")
	sim.holding = 47.0
	sim.halden_hostile_until = 21
	sim.halden_demands = 2
	sim.lena_boost_until = 15
	for i in 6:
		sim.end_week()
	var wk: int = sim.week
	var changes: int = sim.week_changes.size()
	var cap: Dictionary = sim.capacity.duplicate()
	var holding_before: float = sim.holding
	var heir_before: float = sim.heir_maturity
	_check("kaydet", sim.save_game())
	var loaded: bool = sim.load_game()
	var same_cap := true
	for k in cap:
		same_cap = same_cap and absf(float(sim.capacity[k]) - float(cap[k])) < 0.001
	_check("gidiş-dönüş", loaded and sim.week == wk and sim.week_changes.size() == changes and same_cap and sim.capacity_timeline.size() == sim.timeline.size()
		and not sim.capacity_timeline.is_empty() and sim.capacity_timeline[-1].has("holding")
		and absf(sim.holding - holding_before) < 0.001 and sim.halden_hostile_until == 21 and sim.halden_demands == 2 and sim.lena_boost_until == 15 and sim.kadro_log.size() == 1
		and absf(sim.heir_maturity - heir_before) < 0.001 and sim.actors.has("julian") and sim.actors.has("elena"))
	var f := FileAccess.open(sim.save_path, FileAccess.READ)
	var d: Dictionary = str_to_var(f.get_as_text())
	f.close()
	_check("sürüm yazıldı", int(d.get("version", 0)) == sim.SAVE_VERSION)
	# Sürüm 7: yeni kadro ve veliaht olgunluğu yoktu.
	var v7 := d.duplicate(true)
	v7["version"] = 7
	v7.erase("heir_maturity")
	for id in ["julian", "elena"]:
		v7["actors"].erase(id)
		v7["karne"].erase(id)
	_write(sim.save_path, v7)
	_check("v7 yeni kadro göçü", sim.load_game() and sim.actors.has("julian") and sim.actors.has("elena")
		and sim.heir_maturity == 30.0 and sim.karne.has("julian") and sim.karne.has("elena"))
	# Sürüm 6: kurum çizelgesinde Sarne'nin haftalık payı tutulmuyordu.
	var v6 := d.duplicate(true)
	v6["version"] = 6
	for point: Dictionary in v6["capacity_timeline"]:
		point.erase("holding")
	_write(sim.save_path, v6)
	_check("v6 holding çizelgesi göçü", sim.load_game() and not sim.capacity_timeline.is_empty()
		and absf(float(sim.capacity_timeline[-1].get("holding", -1.0)) - holding_before) < 0.001)
	# Sürüm 5: Sarne holdingi ve kadro günlüğü henüz kayıtlı değildi.
	var v5 := d.duplicate(true)
	v5["version"] = 5
	for k in ["holding", "halden_hostile_until", "halden_demands", "lena_boost_until", "kadro_log"]:
		v5.erase(k)
	_write(sim.save_path, v5)
	var old_holding := clampf(float(d["actors"]["halden"]["power"]) - 10.0, 0.0, 100.0)
	_check("v5 Sarne göçü", sim.load_game() and absf(sim.holding - old_holding) < 0.001 and sim.kadro_log.is_empty() and sim.halden_demands == 0)
	# Sürüm 4: devlet alanları yoktu.
	var v4 := d.duplicate(true)
	v4["version"] = 4
	for k in ["capacity", "treasury", "budget_stance", "court_share", "capacity_timeline", "holding", "halden_hostile_until", "halden_demands", "lena_boost_until", "kadro_log"]:
		v4.erase(k)
	_write(sim.save_path, v4)
	_check("v4 devlet göçü", sim.load_game() and sim.capacity["maliye"] == 55.0 and sim.treasury == 55.0 and sim.capacity_timeline.is_empty())
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
	for k in ["version", "report_prev", "week_changes", "regime", "capacity", "treasury", "budget_stance", "court_share", "capacity_timeline", "holding", "halden_hostile_until", "halden_demands", "lena_boost_until", "kadro_log"]:
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
