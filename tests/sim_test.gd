extends SceneTree
## Headless simülasyon + denge testi:
##   Godot_console.exe --headless --path . --script res://tests/sim_test.gd

const Press := preload("res://game/core/press.gd")

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
	sim.capacity["maliye"] = 55.0
	sim.treasury = 55.0
	if not sim._eligible({"id": "test_cap", "min_cap": {"maliye": 55}, "max_treasury": 55}) or sim._eligible({"id": "test_cap", "min_cap": {"maliye": 56}}) or sim._eligible({"id": "test_cap", "max_cap": {"maliye": 54}}) or sim._eligible({"id": "test_cap", "min_treasury": 56}):
		push_error("kapasite/kasa olay koşulları hatalı")
		ok = false
	sim.week = 12
	sim.pending.clear()
	sim.end_week()
	var budget: Dictionary = {}
	for p: Dictionary in sim.pending:
		if p["event"].get("kind", "") == "budget":
			budget = p["event"]
			break
	if budget.is_empty() or budget["choices"].size() != 4:
		push_error("çeyrek bütçe kartı açılmadı")
		ok = false
	else:
		var budget_index := -1
		for i in sim.pending.size():
			if sim.pending[i]["event"].get("kind", "") == "budget":
				budget_index = i
				break
		sim.resolve_decision(budget_index, 0)
		if sim.budget_stance != -1 or sim.court_share:
			push_error("bütçe duruşu uygulanmadı")
			ok = false
		sim.pending = [{"event": budget, "age": 1}]
		sim.end_week()
		if sim.budget_stance != 0 or sim.court_share:
			push_error("ertelenen bütçe dengeli sayılmadı")
			ok = false
	sim.new_game(31, 1)
	var maliye_before: float = sim.capacity["maliye"]
	var career_before: float = sim.actors["kessler"].loyalty["career"]
	sim.appoint("kessler", "loyal")
	if sim.capacity["maliye"] != maliye_before - 8.0 or sim.actors["kessler"].loyalty["career"] != career_before + 8.0 or sim.appoint_wait("kessler") != 8:
		push_error("sadık atama hatalı")
		ok = false
	var after_appoint: float = sim.capacity["maliye"]
	sim.appoint("kessler", "merit")
	if sim.capacity["maliye"] != after_appoint:
		push_error("atama bekleme süresi uygulanmadı")
		ok = false
	sim.week += 8
	sim.appoint("kessler", "merit")
	if sim.capacity["maliye"] != after_appoint + 7.0:
		push_error("liyakatli atama hatalı")
		ok = false
	sim.new_game(31, 1)
	var tender_before := [sim.holding, sim.private_wealth, sim.treasury, sim.economy, sim.capacity["maliye"], sim.actors["halden"].power, sim.actors["halden"].loyalty["money"]]
	sim.give_tender("halden")
	if sim.holding != tender_before[0] + 10.0 or sim.private_wealth != tender_before[1] + 6.0 or sim.treasury != tender_before[2] - 3.0 or sim.economy != tender_before[3] + 1.0 or sim.capacity["maliye"] != tender_before[4] - 2.0 or sim.actors["halden"].power != tender_before[5] + 3.0 or sim.actors["halden"].loyalty["money"] != tender_before[6] + 6.0 or sim.tender_wait() != 3 or not sim.facts.has("ihale_komisyonu_1"):
		push_error("ihale etkileri veya komisyon sırrı hatalı")
		ok = false
	var held: float = sim.holding
	sim.give_tender("halden")
	if sim.holding != held:
		push_error("ihale bekleme süresi uygulanmadı")
		ok = false
	sim.week += 3
	sim.give_tender("halden")
	if sim.holding != held + 10.0:
		push_error("ihale bekleme süresi dolmadı")
		ok = false
	sim.actors["halden"].moved = true
	sim.week += 3
	sim.give_tender("halden")
	if sim.holding != held + 10.0:
		push_error("karşı saftaki Sarne'ye ihale verildi")
		ok = false
	sim.new_game(31, 1)
	sim.facts.clear()
	sim.capacity["hukuk"] = 55.0
	sim._add_fact("ihale_komisyonu_1", "ihale izi", "king", 18, ["halden", "kessler"], 1)
	var one_tender_pressure: float = sim.legal_pressure()
	sim._add_fact("ihale_komisyonu_4", "ikinci ihale izi", "king", 18, ["halden", "kessler"], 1)
	if absf(sim.legal_pressure() - one_tender_pressure) > 0.01:
		push_error("aynı ihale zinciri mahkemede ayrı dosya sayıldı")
		ok = false
	sim._add_fact("transfer_dorn_5", "gizli ödeme", "king", 18, ["dorn"], 1)
	if sim.legal_pressure() <= one_tender_pressure:
		push_error("ihale dışı kanıt yargı baskısını artırmadı")
		ok = false
	sim.difficulty = 0
	var easy_pressure: float = sim.legal_pressure()
	sim.difficulty = 2
	if sim.legal_pressure() <= easy_pressure:
		push_error("zorluk yargı baskısını değiştirmedi")
		ok = false
	sim.new_game(31, 1)
	sim.holding = 80.0
	sim.king_strength = 50.0
	sim.unrest = 30.0
	sim.halden_hostile_until = sim.week + 2
	if sim.halden_mood() != "düşmanca":
		push_error("Sarne düşman yayın durumuna geçmedi")
		ok = false
	sim._tick_holding()
	var hostile_head: String = Press.edition(sim, "state")["headline"]
	if sim.unrest <= 30.0 or sim.king_strength >= 50.0 or int(sim.stats.get("halden_hostile_weeks", 0)) != 1 or not (hostile_head in ["Saray halktan koptu", "Hükümet sözünü tutmadı", "Kraliyet hesap vermeli"]) or Press.broadcast(sim)["headline"] != hostile_head:
		push_error("Sarne'nin düşman yayını veya haftalık etkisi hatalı")
		ok = false
	sim.halden_hostile_until = 0
	for key in sim.actors["halden"].loyalty:
		sim.actors["halden"].loyalty[key] = 0.0
	sim.actors["halden"].loyalty["money"] = 30.0
	if sim.halden_mood() != "sıcak":
		push_error("Sarne sıcak medya durumuna geçmedi")
		ok = false
	var before_mood: Dictionary = sim._visible_snapshot()
	sim.halden_hostile_until = sim.week + 2
	var mood_changes: Array = sim._diff_visible(before_mood, sim._visible_snapshot())
	if not mood_changes.any(func(change: Dictionary) -> bool: return "Sarne'nin yayınlarının havası değişti" in str(change["text"])):
		push_error("Sarne'nin değişen havası haftalık özette yok")
		ok = false
	sim.holding = 40.0
	if sim.halden_influence_band() != "sınırlı":
		push_error("Sarne nüfuz bandı hatalı")
		ok = false
	sim.holding = 60.0
	if sim.halden_influence_band() != "yaygın":
		push_error("Sarne orta nüfuz bandı hatalı")
		ok = false
	sim.holding = 80.0
	if sim.halden_influence_band() != "her yerde":
		push_error("Sarne yüksek nüfuz bandı hatalı")
		ok = false
	sim.new_game(31, 1)
	sim.week = 18
	sim.pending.clear()
	sim._fire_patronage()
	if sim.pending.size() != 1 or sim.pending[0]["event"]["choices"].size() != 4 or sim.halden_demands != 1:
		push_error("Sarne talep kartı açılmadı")
		ok = false
	else:
		sim.actors["lena"].moved = true
		var mesai_before: int = sim.mesai
		sim.resolve_decision(0, 2)
		if sim.mesai != mesai_before or sim.pending.is_empty():
			push_error("Leyla yokken rakip yayın kurulabildi")
			ok = false
		sim.actors["lena"].moved = false
		sim.resolve_decision(0, 1)
		if sim.halden_hostile_until != 24 or sim.stats.get("halden_rejected", 0) != 1:
			push_error("Sarne talebi reddi uygulanmadı")
			ok = false
	sim._fire_patronage()
	if not sim.pending.is_empty():
		push_error("Sarne talebi bekleme süresi uygulanmadı")
		ok = false
	sim.week = 26
	sim.holding = 60.0
	sim._fire_patronage()
	if sim.pending.size() != 1 or sim.pending[0]["event"]["level"] != 1:
		push_error("Sarne ikinci talep eşiği çalışmadı")
		ok = false
	else:
		var prior_holding: float = sim.holding
		sim.resolve_decision(0, 0)
		if sim.holding != prior_holding + 12.0 or sim.halden_mood() != "sıcak" or sim.stats.get("halden_granted", 0) != 1 or not sim.flags.has("halden_ihale_0") or not sim.flags.has("halden_fatura_0") or not sim.facts.has("liman_komisyonu"):
			push_error("Sarne talebini verme etkisi uygulanmadı")
			ok = false
		sim.week += 12
		for old_chain: Dictionary in sim._events:
			if old_chain["id"] == "liman_skandali" and not sim._eligible(old_chain):
				push_error("Sarne talebi liman skandalı zincirini açmadı")
				ok = false
		sim.week -= 12
	if not sim._eligible({"id": "holding_ok", "min_holding": 70, "max_holding": 75}) or sim._eligible({"id": "holding_high", "min_holding": 73}) or sim._eligible({"id": "holding_low", "max_holding": 65}):
		push_error("holding olay eşikleri hatalı")
		ok = false
	var normal_dep: float = sim.media_dependency()
	sim.lena_boost_until = sim.week + 12
	if absf(sim.media_dependency() - normal_dep + 8.0) > 0.001:
		push_error("Rakip yayın bağımlılığı azaltmadı")
		ok = false
	sim.new_game(31, 1)
	sim.capacity["maliye"] = 20.0
	sim.treasury = 20.0
	sim.weekly_news.clear()
	sim._state_warnings()
	var warning_count: int = sim.weekly_news.size()
	sim._state_warnings()
	if warning_count != 2 or sim.weekly_news.size() != 2:
		push_error("kurum/kasa eşik haberi bir kez çıkmalı")
		ok = false
	sim.cross_check("kessler")
	if sim.capacity_band("maliye") != "aksıyor" or sim.treasury_band() != "sıkışık":
		push_error("Doğrula kurum/kasa bandını gürültüsüz göstermeli")
		ok = false

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
	print("  Sarne korku: %.0f -> %.0f" % [fear_before, sim.actors["halden"].fear])
	sim.mesai = 4
	print("  ", sim.order("arden", "bastir", "yazili"))

	# Söz defteri: aynı ödülü iki kişiye ver, birini tut -> diğeri bozulur
	sim.new_game(9, 1)
	sim.mesai = 4
	print("Söz: ", sim.promise("arden", "Naiplik"))
	print("Söz: ", sim.promise("halden", "Naiplik"))
	print("Söz (tekrar): ", sim.promise("arden", "Naiplik"))
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
	sim.holding = 70.0
	if sim._eligible({"id": "test_hostile", "needs_hostile": true}) or sim._eligible({"id": "test_moved", "needs_moved": "halden"}):
		push_error("patronaj olay koşulları erken açıldı")
		ok = false
	sim.halden_hostile_until = 42
	sim.actors["halden"].moved = true
	if not sim._eligible({"id": "test_hostile", "needs_hostile": true}) or not sim._eligible({"id": "test_moved", "needs_moved": "halden"}):
		push_error("patronaj olay koşulları açılmadı")
		ok = false
	sim.actors["halden"].moved = false
	sim.halden_hostile_until = 0
	sim._apply_effects({"court_share": true, "holding": -3})
	if not sim.flags.has("SARAY_PAYI_BASLADI") or sim.holding != 67.0:
		push_error("saray payı izi veya holding etkisi uygulanmadı")
		ok = false
	sim._apply_effects({"court_share": false})
	if sim.flags.has("SARAY_PAYI_BASLADI"):
		push_error("saray payı izi kapatılmadı")
		ok = false
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
		sim.treasury = clampf(55.0, float(e.get("min_treasury", 0)), float(e.get("max_treasury", 100)))
		sim.holding = clampf(55.0, float(e.get("min_holding", 0)), float(e.get("max_holding", 100)))
		if e.get("needs_hostile", false):
			sim.halden_hostile_until = sim.week + 1
		for aid in sim._as_array(e.get("needs_moved", [])):
			sim.actors[aid].moved = true
		for institution in sim.capacity:
			sim.capacity[institution] = clampf(55.0, float(e.get("min_cap", {}).get(institution, 5)), float(e.get("max_cap", {}).get(institution, 100)))
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
	var ek_cases := {"Nadir Vale|e": "Nadir Vale'ye", "General Arden|e": "General Arden'e", "Adrian Voss|in": "Adrian Voss'un",
		"Kraliçe Helena|in": "Kraliçe Helena'nın", "Leyla Sarn|e": "Leyla Sarn'a", "Victor Sarne|in": "Victor Sarne'nin",
		"Prens Marcus|e": "Prens Marcus'a", "Leyla|in": "Leyla'nın", "Selin Veyra|e": "Selin Veyra'ya"}
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
	ok = _test_state_end() and ok
	ok = _test_newcomer_rng() and ok
	ok = _test_heir() and ok
	ok = _test_new_reports() and ok
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


func _test_newcomer_rng() -> bool:
	sim.new_game(101, 0)
	var data: Array = JSON.parse_string(FileAccess.open("res://game/data/actors.json", FileAccess.READ).get_as_text())
	var old_rng := RandomNumberGenerator.new()
	old_rng.seed = 101
	var good := true
	for i in 9:
		var d: Dictionary = data[i]
		var a = sim.actors[d["id"]]
		var ambition: float = float(d["ambition"]) + old_rng.randf_range(-12.0, 12.0)
		var honesty: float = clampf(float(d["honesty"]) + old_rng.randf_range(-0.15, 0.15), 0.05, 1.0)
		var perceived: float = 60.0 + old_rng.randf_range(-5.0, 5.0)
		good = good and is_equal_approx(a.ambition, ambition) and is_equal_approx(a.honesty, honesty) and is_equal_approx(a.perceived_king, perceived)
	var heir = sim.actors["julian"]
	good = good and sim.actors.size() == 11 and heir.insider and not heir.royal and heir.supporting and heir.power <= 15.0
	good = good and sim.heir_maturity >= 25.0 and sim.heir_maturity <= 35.0
	if not good:
		push_error("yeni kadro eski aktörlerin RNG sırasını değiştirdi")
	print("Yeni kadro RNG: ", "OK" if good else "HATA")
	return good


func _test_heir() -> bool:
	sim.new_game(41, 0)
	var good: bool = sim.heir_maturity_band() == "Çocuksu"
	var first: float = sim.heir_maturity
	var prince: float = sim.actors["prens"].ambition
	var general: float = sim.actors["arden"].ambition
	good = good and sim.train_heir("elena").contains("çıkarılamaz") and sim.mesai == sim.mesai_max
	good = good and sim.train_heir("julian").contains("derslerini ilerletti") and sim.heir_train_wait() == 6
	good = good and sim.train_heir("julian").contains("beklemelisin") and is_equal_approx(sim.heir_maturity, first + 10.0)
	for w in [7, 13]:
		sim.week = w
		sim.mesai = sim.mesai_max
		sim.train_heir("julian")
	good = good and is_equal_approx(sim.heir_maturity, first + 30.0)
	good = good and is_equal_approx(sim.actors["prens"].ambition, prince + 3.0) and is_equal_approx(sim.actors["arden"].ambition, general + 3.0)
	sim.new_game(41, 0)
	sim.heir_maturity = 30.0
	sim._world_tick()
	var base_unrest: float = sim.unrest
	var base_king: float = sim.king_strength
	sim.new_game(41, 0)
	sim.heir_maturity = 70.0
	good = good and sim.heir_maturity_band() == "Hazır"
	sim._world_tick()
	good = good and is_equal_approx(sim.unrest, base_unrest - 0.12) and is_equal_approx(sim.king_strength, base_king + 0.06)
	if not good:
		push_error("veliaht eğitimi, bekleme veya yüksek olgunluk etkisi hatalı")
	print("Veliaht eğitimi: ", "OK" if good else "HATA")
	return good


func _test_new_reports() -> bool:
	sim.new_game(101, 0)
	var good := true
	for aid in ["julian", "elena"]:
		var found := false
		for report: Dictionary in sim.reports:
			if report["source"] == aid:
				found = not str(report["text"]).is_empty() and int(report["band"]) in [0, 1, 2]
		good = good and found
	if not good:
		push_error("Julian veya Elena raporu eksik")
	print("Yeni kadro raporları: ", "OK" if good else "HATA")
	return good


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
	sim.new_game(123, 1)
	for actor in sim.actors.values():
		actor.power = 0.0
	sim.stats["investigations"] = 4
	sim.holding = 40.0
	if sim._choose_regime() != "istihbarat":
		push_error("düşük holding rejimi etkilemedi")
		ok = false
	sim.holding = 100.0
	if sim._choose_regime() != "oligark":
		push_error("yüksek holding rejimi etkilemedi")
		ok = false
	sim.stats["investigations"] = 0
	sim.holding = 40.0
	sim.stats["sadik_ordu"] = 2
	if sim._choose_regime() != "guvenlikci":
		push_error("sadık ordu rejimi etkilemedi")
		ok = false
	sim.stats["sadik_ordu"] = 0
	sim.stats["sadik_maliye"] = 4
	if sim._choose_regime() != "patronajci":
		push_error("sadık kadro rejimi etkilemedi")
		ok = false
	print("Rejim tipleri: ", "OK" if ok else "HATA")
	return ok


func _test_state_end() -> bool:
	sim.new_game(124, 1)
	sim.capacity_timeline = [
		{"w": 1, "maliye": 25.0, "hukuk": 25.0, "ordu": 25.0, "idare": 25.0, "holding": 75.0},
		{"w": 2, "maliye": 30.0, "hukuk": 30.0, "ordu": 30.0, "idare": 30.0, "holding": 35.0}]
	sim.timeline = [{"w": 1, "king": 60.0}, {"w": 2, "king": 61.0}]
	sim.holding = 35.0
	sim.week = 105
	sim._end(true)
	var state: Dictionary = sim.record.get("state", {})
	var ok: bool = sim.record["title"] == "Harap Devletin Kralı" and state.get("holding_peak", 0.0) == 75.0
	ok = ok and state.get("low_week", 0) == 1 and state.get("timeline", []).size() == 2
	ok = ok and float(state["timeline"][0].get("capacity", 0.0)) == 25.0
	sim.new_game(125, 1)
	sim.capacity_timeline = [{"w": 1, "maliye": 75.0, "hukuk": 75.0, "ordu": 75.0, "idare": 75.0, "holding": 40.0}]
	ok = ok and sim._survivor_title(null) == "Liyakat Kralı"
	if not ok:
		push_error("devlet final verisi veya yeni unvan hatalı")
	print("Devlet finali: ", "OK" if ok else "HATA")
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
	var acc := {"Arden": "Arden'i", "Vale": "Vale'yi", "Leyla": "Leyla'yı", "Renn": "Renn'i", "Prens": "Prens'i"}
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
