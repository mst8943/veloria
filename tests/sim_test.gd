extends SceneTree
## Headless simülasyon + denge testi:
##   Godot_console.exe --headless --path . --script res://tests/sim_test.gd

var sim: Node
var rngb := RandomNumberGenerator.new()
var fired_total := 0
var fired_ids := {}


func _init() -> void:
	sim = load("res://game/core/sim.gd").new()
	var ok := true
	for policy in ["idle", "random", "careful"]:
		var wins := 0
		var weeks_total := 0
		var causes := {}
		var n := 40
		for s in range(1, n + 1):
			sim.new_game(s)
			rngb.seed = s * 7 + 3
			while not sim.ended:
				_play_week(policy)
				sim.end_week()
			fired_total += sim.fired_events.size()
			for k in sim.fired_events:
				fired_ids[k] = int(fired_ids.get(k, 0)) + 1
			if sim.record["survived"]:
				wins += 1
			weeks_total += sim.record["weeks"]
			var key: String = sim.record["title"] if sim.record["survived"] else String(sim.record["cause"]).substr(0, 40)
			causes[key] = int(causes.get(key, 0)) + 1
		print("[%s] kazanma %d/%d, ort. hafta %.1f" % [policy, wins, n, float(weeks_total) / n])
		print("   ", causes)
		print("   olay sayısı/kampanya: %.1f" % (float(fired_total) / n))
		fired_total = 0

	# Zorluk seviyeleri (dikkatli ve rastgele bot)
	for diff in [0, 2]:
		for policy in ["random", "careful"]:
			var w2 := 0
			var wk2 := 0
			for s in range(1, 41):
				sim.new_game(s, diff)
				rngb.seed = s * 7 + 3
				while not sim.ended:
					_play_week(policy)
					sim.end_week()
				w2 += 1 if sim.record["survived"] else 0
				wk2 += sim.record["weeks"]
			print("[%s / %s] kazanma %d/40, ort. hafta %.1f" % [sim.DIFFICULTY[diff]["name"], policy, w2, wk2 / 40.0])
	sim.new_game(1, 1)

	# Araştırma ve şantaj
	sim.new_game(8, 1)
	var tries := 0
	while not sim.actors["halden"].known_weak and tries < 30:
		sim.mesai = 4
		sim.investigate("halden")
		tries += 1
	print("Araştırma: %d denemede zayıf nokta bulundu = %s" % [tries, sim.actors["halden"].known_weak])
	var fear_before: float = sim.actors["halden"].fear
	sim.mesai = 4
	print("  ", sim.blackmail("halden"))
	if not sim.actors["halden"].known_weak or sim.facts.is_empty():
		push_error("şantaj/araştırma çalışmadı")
		ok = false
	print("  Halden korku: %.0f -> %.0f" % [fear_before, sim.actors["halden"].fear])
	sim.mesai = 4
	print("  ", sim.order("arden", "bastir", "yazili"))

	# Hiç tetiklenmeyen olaylar
	var never: Array = []
	for e in sim._events:
		if not fired_ids.has(e["id"]):
			never.append(e["id"])
	print("Hiç tetiklenmeyen olaylar (120 kampanyada): ", never)
	# Ulaşılabilirlik: gerekli kararları zorla verip uygunluğu kontrol et.
	sim.new_game(77)
	sim.week = 40
	for e in sim._events:
		if not never.has(e["id"]):
			continue
		for fl in e.get("flag_age", {}):
			sim.flags[fl] = 1
		for fid in sim._as_array(e.get("needs_fact", [])):
			sim._add_fact(fid, fid, "king", 10, ["voss"], 1)
		var ok_e: bool = sim._eligible(e)
		print("   ulaşılabilir mi %s: %s" % [e["id"], ok_e])
		if not ok_e:
			ok = false

	# Kayıt/yükleme turu
	sim.new_game(5)
	for i in 10:
		sim.end_week()
	var w: int = sim.week
	var wealth: float = sim.private_wealth
	if not sim.save_game():
		push_error("save_game başarısız")
		ok = false
	sim.new_game(99)
	if not sim.load_game() or sim.week != w or absf(sim.private_wealth - wealth) > 0.001:
		push_error("load_game tutarsız")
		ok = false
	print("Kayıt/yükleme: ", "OK" if ok else "HATA", " (hafta %d)" % sim.week)

	# Hakikat dosyası örneği
	sim.new_game(3)
	while not sim.ended:
		sim.end_week()
	print("Örnek final: ", sim.record["title"], " | ", sim.record["cause"])
	for l in sim.record["lies"].slice(0, 3):
		print("  H%d %s: '%s' -> gerçekte '%s'" % [l["week"], l["name"], l["said"], l["truth"]])
	print("TEST: ", "OK" if ok else "FAIL")
	quit(0 if ok else 1)


func _play_week(policy: String) -> void:
	if policy == "idle":
		return
	var ids: Array = sim.actors.keys()
	if ids.is_empty():
		return
	# Kararlar
	var guard := 0
	while not sim.pending.is_empty() and sim.mesai > 0 and guard < 6:
		guard += 1
		var ev: Dictionary = sim.pending[0]["event"]
		var ci: int = rngb.randi() % ev["choices"].size()
		if policy == "careful":
			ci = _careful_choice(ev)
		sim.resolve_decision(0, ci)
	if policy == "random":
		while sim.mesai > 0:
			var id: String = ids[rngb.randi() % ids.size()]
			if not sim.actors.has(id):
				break
			match rngb.randi() % 4:
				0:
					sim.promote(id)
				1:
					sim.bribe(id)
				2:
					sim.cross_check(id)
				_:
					sim.order(id, "bastir", "sozlu")
	else:
		# Dikkatli oyuncu: en güçlü/hırslı kişiyi izle, dosyaları yakından takip et.
		while sim.mesai > 0:
			var dirty := ""
			for fid in sim.facts:
				if sim.facts[fid]["subject"] == "king" and not sim.facts[fid].get("public", false):
					dirty = fid
					break
			if dirty != "":
				sim.destroy_evidence(dirty)
				continue
			var target: Object = null
			for a in sim.actors.values():
				if a.moved or not a.insider:
					continue
				if target == null or a.rebellion_drive() > target.rebellion_drive():
					target = a
			if target == null:
				break
			if target.rebellion_drive() > 0.0 and sim.private_wealth >= 5.0:
				sim.bribe(target.id)
			elif sim.unrest > 45.0:
				sim.order("arden" if sim.actors.has("arden") else target.id, "bastir", "sozlu")
			else:
				sim.cross_check(target.id)


func _careful_choice(ev: Dictionary) -> int:
	# Sezgi: en az "güç/borç" verenleri seç; ceza maliyetleri hesapla.
	var best := 0
	var best_score := -1e9
	for i in ev["choices"].size():
		var fx: Dictionary = ev["choices"][i].get("fx", {})
		var sc := float(fx.get("king", 0)) * 2.0 - float(fx.get("unrest", 0)) * 1.0 + float(fx.get("economy", 0)) * 0.7 - float(fx.get("opp", 0)) * 0.5 + float(fx.get("wealth", 0)) * 0.3
		var af: Dictionary = fx.get("actors", {})
		for aid in af:
			var d: Dictionary = af[aid]
			sc -= float(d.get("power", 0)) * 0.3 + float(d.get("ambition", 0)) * 0.4 + float(d.get("obligation", 0)) * 0.3
		if sc > best_score:
			best_score = sc
			best = i
	return best
