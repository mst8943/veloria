extends SceneTree
## Headless simülasyon + denge testi:
##   Godot_console.exe --headless --path . --script res://tests/sim_test.gd

var sim: Node
var rngb := RandomNumberGenerator.new()
var fired_total := 0
var fired_ids := {}


func _init() -> void:
	sim = load("res://game/core/sim.gd").new()
	sim.save_path = "user://test_save.txt"   # oyuncunun kaydına dokunma
	sim.record_chronicle = false
	sim.autosave = false
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

	# Söz defteri: aynı ödülü iki kişiye ver, birini tut -> diğeri bozulur
	sim.new_game(9, 1)
	sim.mesai = 4
	print("Söz: ", sim.promise("arden", "Başbakanlık"))
	print("Söz: ", sim.promise("halden", "Başbakanlık"))
	print("Söz (tekrar): ", sim.promise("arden", "Başbakanlık"))
	var guard_w := 0
	while sim.pending.filter(func(x: Dictionary) -> bool: return str(x["event"]["id"]).begins_with("soz_")).is_empty() and guard_w < 15:
		sim.mesai = 4
		sim.end_week()
		guard_w += 1
	var soz_idx := -1
	for i in sim.pending.size():
		if str(sim.pending[i]["event"]["id"]).begins_with("soz_"):
			soz_idx = i
			break
	if soz_idx == -1:
		push_error("söz kartı gelmedi")
		ok = false
	else:
		sim.mesai = 4
		print("  Kart: ", sim.pending[soz_idx]["event"]["title"], " -> ", sim.resolve_decision(soz_idx, 0))
		var states: Array = sim.promises.map(func(p: Dictionary) -> String: return "%s:%s" % [p["actor"], p["state"]])
		print("  Durumlar: ", states)
		if not (states.has("arden:kept") or states.has("halden:kept")) or not (states.has("arden:broken") or states.has("halden:broken")):
			push_error("söz tut/boz zinciri hatalı")
			ok = false
	sim.save_game()
	sim.load_game()
	print("  Kayıttan sonra söz sayısı: ", sim.promises.size())

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
		for fl in sim._as_array(e.get("needs_flag", [])):
			sim.flags[fl] = 1
		for fl in sim._as_array(e.get("any_flag", [])):
			sim.flags[fl] = 1
		for fid in sim._as_array(e.get("needs_fact", [])):
			sim._add_fact(fid, fid, "king", 10, ["voss"], 1)
		sim.week = maxi(40, int(e.get("min_week", 0)))   # ikinci yıl olayları 40'tan sonra başlar
		var saved_stats: Dictionary = sim.stats.duplicate()
		for st in e.get("min_stat", {}):   # oyuncu geçmişi koşulu (botlar bu eylemleri az kullanır)
			sim.stats[st] = int(e["min_stat"][st])
		# Aktör koşulları (güç, hırs, borç...) zorla sağlanır.
		for aid in e.get("min_power", {}):
			if sim.actors.has(aid):
				sim.actors[aid].power = maxf(sim.actors[aid].power, float(e["min_power"][aid]))
		for aid in e.get("actor_min", {}):
			if sim.actors.has(aid):
				for prop in e["actor_min"][aid]:
					sim.actors[aid].set(prop, maxf(float(sim.actors[aid].get(prop)), float(e["actor_min"][aid][prop])))
		# Dünya değeri koşulları (huzursuzluk, muhalefet, ekonomi) da zorla sağlanır.
		sim.unrest = clampf(30.0, float(e.get("min_unrest", 0)), float(e.get("max_unrest", 100)))
		sim.opposition = maxf(20.0, float(e.get("min_opposition", 0)))
		sim.economy = clampf(55.0, float(e.get("min_economy", 0)), float(e.get("max_economy", 100)))
		var ok_e: bool = sim._eligible(e)
		sim.stats = saved_stats
		print("   ulaşılabilir mi %s: %s" % [e["id"], ok_e])
		if not ok_e:
			ok = false

	# Tarihçiler ve zaman çizelgesi
	sim.new_game(4, 1)
	while not sim.ended:
		sim.end_week()
	var hist: Array = sim.record.get("historians", [])
	print("Tarihçiler: ", hist.size(), " | zaman çizelgesi: ", sim.record.get("timeline", []).size(), " hafta")
	if hist.size() != 2 or sim.record.get("timeline", []).size() < 2:
		push_error("tarihçi/zaman çizelgesi eksik")
		ok = false

	# Türkçe ek uyumu
	var ek_cases := {"Elias Voss|e": "Elias Voss'a", "General Arden|e": "General Arden'e", "Teodor Brandt|in": "Teodor Brandt'ın",
		"Alaric Dorn|in": "Alaric Dorn'un", "Lena Ostrow|e": "Lena Ostrow'a", "Viktor Halden|in": "Viktor Halden'in",
		"Prens Cassian|e": "Prens Cassian'a", "Lena|in": "Lena'nın", "Marta Kessler|e": "Marta Kessler'e"}
	for k in ek_cases:
		var parts: PackedStringArray = k.split("|")
		var got: String = sim.ek(parts[0], parts[1])
		if got != ek_cases[k]:
			push_error("ek hatası: %s -> %s (beklenen %s)" % [k, got, ek_cases[k]])
			ok = false
	print("Ek uyumu: ", "OK" if ok else "HATA")

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

	# Birbirine düşür: tam iki kişi, bekleme, etki yönü.
	ok = _test_rivals() and ok
	ok = _test_arcs() and ok
	ok = _test_regimes() and ok
	# Meclis görüşleri: deterministik, kayıtta korunur, ana rng'ye dokunmaz, hazır aktör kötü önerir.
	ok = _test_advice() and ok
	# Darbe aşamaları: çekilme, kriz kartı, kriz sonuçları, kayıt, huzura çağırma.
	ok = _test_plot() and ok

	# Hakikat dosyası örneği
	sim.new_game(3)
	while not sim.ended:
		sim.end_week()
	print("Örnek final: ", sim.record["title"], " | ", sim.record["cause"])
	for l in sim.record["lies"].slice(0, 3):
		print("  H%d %s: '%s' -> gerçekte '%s'" % [l["week"], l["name"], l["said"], l["truth"]])
	print("TEST: ", "OK" if ok else "FAIL")
	quit(0 if ok else 1)


func _test_arcs() -> bool:
	var ok := true
	var ids := ["arden", "voss", "kessler", "halden", "lena", "dorn", "prens", "brandt", "falk"]
	for i in ids.size():
		var id: String = ids[i]
		sim.new_game(123, 1)
		var cards := {}
		for e: Dictionary in sim._events:
			if str(e["id"]).begins_with("yay_" + id + "_"):
				cards[str(e["id"]).trim_prefix("yay_" + id + "_")] = e
		if cards.size() != 4:
			push_error("hikâye yayında sahne eksik: " + id)
			ok = false
			continue
		var start := 20 + 5 * i
		sim.week = start
		if not sim._eligible(cards["yukselis"]) or sim._eligible(cards["sinav"]):
			push_error("hikâye başlangıcı/gecikmesi hatalı: " + id)
			ok = false
		sim.flags["yay_" + id + "_basladi"] = start
		sim.week = start + 3
		if not sim._eligible(cards["sinav"]):
			push_error("hikâye sınavı açılmadı: " + id)
			ok = false
		for route in ["guven", "kopus"]:
			sim.flags["yay_" + id + "_" + route] = start + 3
			sim.week = start + 6
			var wanted: String = "sadakat" if route == "guven" else "kopus"
			var other: String = "kopus" if route == "guven" else "sadakat"
			if not sim._eligible(cards[wanted]) or sim._eligible(cards[other]):
				push_error("hikâye dalı hatalı: %s/%s" % [id, route])
				ok = false
			sim.flags.erase("yay_" + id + "_" + route)
	print("Dokuz hikâye yayı: ", "OK" if ok else "HATA")
	return ok


func _test_regimes() -> bool:
	var ok := true
	var styles := {
		"guvenlikci": "written", "populist": "street_concessions", "patronajci": "promotes",
		"oligark": "bribes", "medya": "", "istihbarat": "investigations"}
	for kind in styles:
		sim.new_game(123, 1)
		sim.week = 59
		sim.king_strength = 90.0
		sim.unrest = 20.0
		if styles[kind] != "":
			sim.stats[styles[kind]] = 5
		if kind == "medya":
			sim.flags["halden_kanal_0"] = 40
			sim.flags["gazeteci_ihale_2"] = 40
		sim.end_week()
		if sim.regime != kind or not sim.flags.has("REJIM_" + kind.to_upper()):
			push_error("rejim seçimi hatalı: %s -> %s" % [kind, sim.regime])
			ok = false
		if sim.week_changes.filter(func(x: Dictionary) -> bool: return str(x["text"]).contains("rejim olarak")).size() != 1:
			push_error("rejim hafta özetinde yok: " + kind)
			ok = false
		sim.end_week()
		if sim.weekly_news.filter(func(x: String) -> bool: return x.begins_with("REJİM:")).size() > 0:
			push_error("rejim haberi ikinci kez çıktı: " + kind)
			ok = false
		sim.week = 82
		var matching := 0
		for e: Dictionary in sim._events:
			if str(e["id"]).begins_with("rejim_") and str(e["id"]).ends_with("_hesap") and sim._eligible(e):
				matching += 1
		if matching != 1:
			push_error("rejim hesabı tek kart seçmedi: %s (%d)" % [kind, matching])
			ok = false
		sim.week = 105
		sim._end(true)
		if str(sim.record["title"]) != str(sim.REGIME_TITLES[kind]) or str(sim.record["threat"]) == "":
			push_error("rejim oyun sonuna geçmedi: " + kind)
			ok = false
	print("Rejim tipleri: ", "OK" if ok else "HATA")
	return ok


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


func _test_advice() -> bool:
	var ok := true
	var acc := {"Arden": "Arden'i", "Voss": "Voss'u", "Lena": "Lena'yı", "Falk": "Falk'ı", "Prens": "Prens'i"}
	for n in acc:
		if sim.ek(n, "i") != acc[n]:
			push_error("ek hatası: %s -> %s" % [n, sim.ek(n, "i")])
			ok = false
	# Aynı tohum -> aynı görüş; görüşe bakmak simülasyonu değiştirmez.
	sim.new_game(11, 1)
	var a1: Array = sim.advice_for(0).duplicate(true)
	var state_before: int = sim.rng.state
	sim.new_game(11, 1)
	var a2: Array = sim.advice_for(0)
	if a1 != a2 or a1.is_empty() or sim.rng.state != state_before:
		push_error("görüş deterministik değil ya da ana rng'yi tüketiyor")
		ok = false
	if not sim.save_game():
		ok = false
	sim.new_game(12, 1)
	sim.load_game()
	if sim.pending[0].get("advice", []) != a2:
		push_error("görüş kayıt/yüklemede korunmadı")
		ok = false
	# Bütün kartlarda: danışman uygun, metin dolu, öneri geçerli; hazır aktörlerin önerisi daha kötü.
	var honest_gap := 0.0
	var honest_n := 0
	var ready_gap := 0.0
	var ready_n := 0
	var kinds := {}
	for s in range(1, 21):
		sim.new_game(s, 1)
		while not sim.ended:
			while not sim.pending.is_empty() and sim.mesai > 0:
				var ev: Dictionary = sim.pending[0]["event"]
				var adv: Array = sim.advice_for(0)
				if adv.size() > 2:
					push_error("ikiden fazla danışman")
					ok = false
				var best := -1e9
				for ch in ev["choices"]:
					best = maxf(best, sim.choice_value(ch.get("fx", {})))
				for it: Dictionary in adv:
					kinds[it["kind"]] = int(kinds.get(it["kind"], 0)) + 1
					if str(it["text"]) == "" or not sim.actors.has(it["actor"]) or not sim.actors[it["actor"]].insider:
						push_error("geçersiz görüş: %s" % it)
						ok = false
					if int(it["rec"]) >= 0:
						var g: float = best - sim.choice_value(ev["choices"][int(it["rec"])].get("fx", {}))
						if sim.actors[it["actor"]].ready:
							ready_gap += g
							ready_n += 1
						else:
							honest_gap += g
							honest_n += 1
				sim.resolve_decision(0, 0)
			sim.end_week()
	var hg := honest_gap / maxf(honest_n, 1)
	var rg := ready_gap / maxf(ready_n, 1)
	print("Meclis: görüş türleri %s | ort. kayıp (V) sadık %.2f (n=%d), hazır %.2f (n=%d)" % [kinds, hg, honest_n, rg, ready_n])
	if ready_n >= 10 and rg <= hg:
		push_error("hazır aktörler daha kötü önermiyor")
		ok = false
	if sim.council_record().is_empty():
		push_error("meclis sicili boş")
		ok = false
	print("Meclis görüşleri: ", "OK" if ok else "HATA")
	return ok


func _all_plotting() -> void:
	for a in sim.actors.values():
		if a.insider:
			a.ambition = 200.0


func _test_rivals() -> bool:
	var good := true
	sim.new_game(11, 1)
	if sim.divide_rivals(["arden"]).find("tam iki") < 0 or sim.divide_rivals(["arden", "voss", "kessler"]).find("tam iki") < 0:
		push_error("düşürme tam iki kişi istemiyor")
		good = false
	var m0: int = sim.mesai
	var pw0: float = sim.actors["arden"].power + sim.actors["voss"].power
	var amb0: float = sim.actors["arden"].ambition + sim.actors["voss"].ambition
	var text: String = sim.divide_rivals(["arden", "voss"])
	var pw1: float = sim.actors["arden"].power + sim.actors["voss"].power
	var amb1: float = sim.actors["arden"].ambition + sim.actors["voss"].ambition
	if sim.mesai != m0 - 2 or int(sim.stats.get("rivalries", 0)) != 1 or (pw1 >= pw0 and amb1 <= amb0):
		push_error("düşürme sonucu hiçbir etki yaratmadı / 2 mesai harcamadı: " + text)
		good = false
	if sim.rival_wait(["voss", "arden"]) <= 0 or sim.divide_rivals(["voss", "arden"]).find("bekle") < 0:
		push_error("aynı çift için bekleme yok (sıra bağımsız olmalı)")
		good = false
	var fresh: int = sim.mesai
	if sim.divide_rivals(["kessler", "halden"]) == "" or fresh == sim.mesai:
		push_error("farklı çift engellendi")
		good = false
	sim.mesai = 1
	if sim.divide_rivals(["dorn", "falk"]).find("2 mesai") < 0:
		push_error("1 mesaiyle düşürme yapıldı")
		good = false
	print("Birbirine düşür: ", "OK" if good else "HATA")
	return good


func _test_plot() -> bool:
	var ok := true
	# 1) Çekilme: öfkesi sönen ve kaskadın tutmadığı komplocu birkaç haftada geri çekilir.
	sim.new_game(3, 1)
	var arden = sim.actors["arden"]
	arden.ready = true
	arden.loyalty["career"] = 300.0
	for i in sim.PLOT_LEAVE_WEEKS:
		sim._run_cascade()
	if arden.ready:
		push_error("komplocu çekilmedi")
		ok = false
	# 2) Kriz: koşul oluşunca darbe hemen olmaz, kriz kartı gelir; çözülmezse hafta sonunda darbe.
	sim.new_game(4, 1)
	sim.week = 20
	_all_plotting()
	sim._run_cascade()
	if sim.coup_crisis.is_empty() or sim.pending.is_empty() or not sim.pending[0]["event"].get("crisis", false) or sim.king_strength <= 0.0:
		push_error("kriz kartı açılmadı ya da darbe hemen oldu")
		ok = false
	if not sim.save_game():
		ok = false
	sim.new_game(5, 1)
	sim.load_game()
	if sim.coup_crisis.is_empty() or not sim.pending[0]["event"].get("crisis", false):
		push_error("kriz kayıt/yüklemede kayboldu")
		ok = false
	sim.end_week()
	if not sim.ended or sim.record["survived"]:
		push_error("çözülmeyen kriz darbeyle bitmedi")
		ok = false
	# 3) Taviz: ilki kesin işe yarar, komplo dağılır, lider güçlenir.
	sim.new_game(6, 1)
	sim.week = 20
	_all_plotting()
	sim._run_cascade()
	var lead_id: String = sim.coup_crisis.get("leader", "")
	var p0: float = sim.actors[lead_id].power if lead_id != "" else 0.0
	sim.resolve_decision(0, 1)
	if not sim.coup_crisis.is_empty() or sim.ended or sim.actors[lead_id].power <= p0 or sim.actors[lead_id].ready:
		push_error("taviz beklendiği gibi çalışmadı")
		ok = false
	# 4) Krizde meclis susar.
	sim.new_game(7, 1)
	sim.week = 20
	_all_plotting()
	sim._run_cascade()
	if not sim.advice_for(0).is_empty():
		push_error("krizde meclis konuştu")
		ok = false
	# 5) Huzura çağırma: sakin biri temiz çıkınca dedikodular silinir; bekleme süresi işler.
	sim.new_game(8, 1)
	var k = sim.actors["kessler"]
	k.plot_stage = 0
	k.signs = [{"w": sim.week, "text": "dedikodu", "weight": 1, "real": false}]
	var cleared := false
	for i in 20:
		sim.flags.erase("HUZUR_KESSLER")
		sim.mesai = 4
		k.signs = [{"w": sim.week, "text": "dedikodu", "weight": 1, "real": false}]
		sim.summon("kessler")
		if k.signs.is_empty():
			cleared = true
	sim.mesai = 4
	var msg: String = sim.summon("kessler")
	if not cleared or sim.mesai != 4 or not msg.contains("yakın zamanda"):
		push_error("huzura çağırma beklendiği gibi çalışmadı")
		ok = false
	# 6) Gerçek oyunlarda: alametlerin çoğu gerçek ama hepsi değil; aynı hafta darbe nadir.
	var real := 0
	var rumor := 0
	var crises := 0
	for s in range(1, 21):
		sim.new_game(s, 1)
		rngb.seed = s
		while not sim.ended:
			_play_week("random")
			sim.end_week()
		real += int(sim.record["signs"]["real"])
		rumor += int(sim.record["signs"]["rumor"])
		for l in sim.record["plot"]:
			if l["text"] == "darbe girişimini başlattı":
				crises += 1
	print("Komplo: alamet gerçek %d / dedikodu %d, 20 oyunda %d kriz" % [real, rumor, crises])
	if real <= rumor or rumor == 0 or crises == 0:
		push_error("alamet/kriz dağılımı beklenmedik")
		ok = false
	print("Darbe aşamaları: ", "OK" if ok else "HATA")
	return ok


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
