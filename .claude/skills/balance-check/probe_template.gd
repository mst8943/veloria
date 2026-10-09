extends SceneTree
## Veloria denge sondajı şablonu (balance-check skill'i).
## Kopyala → scratchpad'e koy → gerekirse botları değiştir → çalıştır:
##   "$G" --headless --path . --script "<mutlak yol>/probe.gd" -- --n=40 --diff=1
## Projeye dokunmaz: arşiv, otomatik kayıt ve kayıt yolu kapatılır.
##
## Botlar:
##   idle        hiçbir şey yapmaz (zemin çizgisi)
##   random      rastgele karar + rastgele eylem
##   visible     yalnızca oyuncunun ekranda gördüğüyle oynar (rapor bantları, DÜŞMAN etiketi,
##               dosyalar, sözler, servet, mesai). Kararlarda seçenek etkilerini GÖRMEZ: rastgele seçer.
##   visible_wise  visible + kararlarda etkileri tahmin eden dikkatli bir insan gibi seçer
##               (fx okur; insanın metinden çıkarım yapabildiğini varsayar — üst sınır gibi düşün)
##   omniscient  gizli değerleri (rebellion_drive) okur — yalnızca karşılaştırma için, hedef DEĞİL
##   advice_naive     visible + kartta ilk danışmanın önerisine uyar
##   advice_weighted  visible + meclis oylarını toplar (öneri +1, uyarı −1, ÇIKARI VAR yarım), kaçamakta rastgele
##   advice_quiet     advice_weighted ama alametlere (şüphe göstergesine) tepki vermez (teşhis için)
##   advice_kessler   visible + Veyra konuşuyorsa ona, yoksa advice_weighted gibi (baskın strateji kontrolü)
##   advice_soft      advice_weighted ama sokağı hiç bastırmaz (huzura çağırır/doğrular): sokak yolunu ölçer
##   advice_dirty     advice_weighted ama yazılı emir, araştırma ve şantaj kullanır: mahkeme yolunu ölçer
##   advice_scheme    advice_weighted ama haftada bir, en şüpheli iki kişiyi birbirine düşürür (Birbirine Düşür'ün gücünü ölçer)

var sim: Node
var rng := RandomNumberGenerator.new()
const BOTS := ["idle", "random", "visible", "advice_naive", "advice_weighted", "advice_kessler", "advice_soft", "advice_dirty", "advice_scheme", "advice_loyal", "advice_merit", "advice_austere", "advice_lavish", "advice_patron", "advice_veliaht", "advice_heyet", "advice_bloc", "visible_wise", "omniscient"]
var style := ""   # advice_soft / advice_dirty oyun tarzı


func _initialize() -> void:
	root.get_node("Sfx").set_language("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
	sim = root.get_node("Sim")
	sim.record_chronicle = false
	sim.autosave = false
	sim.save_path = "user://probe_save.txt"
	var n := 40
	var diffs := [1]
	var bots: Array = BOTS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--n="):
			n = int(a.substr(4))
		elif a.begins_with("--diff="):
			diffs = [int(a.substr(7))]
		elif a == "--all-diffs":
			diffs = [0, 1, 2]
		elif a.begins_with("--bots="):
			bots = Array(a.substr(7).split(","))
	for d in diffs:
		print("=== Zorluk: %s ===" % sim.DIFFICULTY[d]["name"])
		for bot in bots:
			_run(bot, d, n)
	quit(0)


func _run(bot: String, diff: int, n: int) -> void:
	var wins := 0
	var weeks := 0
	var causes := {}
	var titles := {}
	var final_cap := 0.0
	var arden_coups := 0
	var arden_prepared := 0
	var arden_attempts := 0
	var prince_attempts := 0
	var hostile_broadcasts := 0
	var hostile_weeks := 0
	var final_wealth := 0.0
	var regimes := {}
	for s in range(1, n + 1):
		sim.new_game(s, diff)
		rng.seed = s * 131 + 7
		while not sim.ended:
			_play(bot)
			sim.end_week()
		var r: Dictionary = sim.record
		hostile_broadcasts += 1 if sim.fired_events.has("halden_yayin_kesti") else 0
		hostile_weeks += int(sim.stats.get("halden_hostile_weeks", 0))
		final_wealth += sim.private_wealth
		regimes[sim.regime] = int(regimes.get(sim.regime, 0)) + 1
		for value in sim.capacity.values():
			final_cap += float(value) / sim.capacity.size()
		if str(r["cause"]).contains("Arden") and str(r["cause"]).contains("Askerî darbe"):
			arden_coups += 1
		var attempted := false
		var prince_attempted := false
		var prepared := false
		for entry: Dictionary in sim.plot_log:
			if str(entry["name"]).contains("Prens Marcus") and entry["text"] == "darbe girişimini başlattı":
				prince_attempted = true
			if str(entry["name"]).contains("Arden") and entry["text"] == "darbe girişimini başlattı":
				attempted = true
			if str(entry["name"]).contains("Arden") and entry["text"] == "darbe hazırlığına geçti":
				prepared = true
		arden_attempts += 1 if attempted else 0
		prince_attempts += 1 if prince_attempted else 0
		arden_prepared += 1 if prepared else 0
		weeks += int(r["weeks"])
		if r["survived"]:
			wins += 1
			titles[r["title"]] = int(titles.get(r["title"], 0)) + 1
		else:
			var c := _cause_kind(str(r["cause"]))
			causes[c] = int(causes.get(c, 0)) + 1
	print("[%-12s] kazanma %2d/%d (%3d%%)  ort. hafta %5.1f  kayıplar %s  ünvanlar %s" % [
		bot, wins, n, int(100.0 * wins / n), float(weeks) / n, causes, titles])
	print("  ort. son kapasite %.1f | Arden girişimi %d/%d | Arden hazırlığı %d/%d | Arden zaferi %d/%d" % [final_cap / n, arden_attempts, n, arden_prepared, n, arden_coups, n])
	print("  Prens Marcus girişimi %d/%d" % [prince_attempts, n])
	print("  düşman yayın olayı %.2f/oyun | düşman yayın haftası %.1f/oyun | ort. son servet %.1f" % [float(hostile_broadcasts) / n, float(hostile_weeks) / n, final_wealth / n])
	print("  rejimler ", regimes)


func _cause_kind(c: String) -> String:
	if c.contains("Askerî darbe"):
		return "askeri_darbe"
	if c.contains("Saray darbe"):
		return "saray_darbesi"
	if c.contains("ayaklanma"):
		return "ayaklanma"
	if c.contains("yetkisiz"):
		return "yetkisiz"
	if c.contains("elit"):
		return "elit_koalisyonu"
	return "diger"


func _play(bot: String) -> void:
	if bot == "idle":
		return
	_decide(bot)
	match bot:
		"random":
			_act_random()
		"omniscient":
			_act_omniscient()
		_:
			style = "soft" if bot == "advice_soft" else ("dirty" if bot == "advice_dirty" else "")
			if bot == "advice_veliaht" and sim.week >= 20 and sim.heir_maturity < 70.0 and sim.heir_train_wait() == 0 and sim.mesai > 0:
				sim.train_heir("julian")
			if bot in ["advice_heyet", "advice_bloc"] and sim.week >= 20 and sim.delegation_wait() == 0 and sim.mesai > 0:
				var envoy: String = "malenkov" if bot == "advice_bloc" else ["claire", "malenkov", "lucien"][(sim.week / 4) % 3]
				sim.send_delegation(envoy)
			if bot == "advice_patron" and sim.week % 3 == 0 and sim.mesai > 0 and sim.tender_wait() == 0 and not sim.actors["halden"].moved:
				sim.give_tender("halden")
			if bot == "advice_patron" and sim.private_wealth > 11.0 and sim.mesai > 0 and sim.actors.has("dorn") and not sim.actors["dorn"].moved:
				sim.bribe("dorn")
			var cycle := 16 if bot == "advice_loyal" else 20
			var start := 16 if bot == "advice_loyal" else 12
			if bot in ["advice_loyal", "advice_merit"] and sim.week >= start and (sim.week - start) % cycle in [0, 1]:
				var ids := ["kessler", "dorn"] if (sim.week - start) % cycle == 0 else ["falk", "arden"]
				for id in ids:
					sim.appoint(id, "loyal" if bot == "advice_loyal" else "merit")
			if bot == "advice_scheme":
				_scheme()
			_act_visible(bot.begins_with("advice_") and bot != "advice_quiet")


# ---------------------------------------------------------------- Kararlar

func _decide(bot: String) -> void:
	var guard := 0
	while not sim.pending.is_empty() and sim.mesai > 0 and guard < 6:
		guard += 1
		var ev: Dictionary = sim.pending[0]["event"]
		var ci: int = rng.randi() % ev["choices"].size()
		if ev.get("crisis", false):
			ci = _crisis_choice(bot, ev, ci)
		elif ev.get("kind", "") == "budget" and bot == "advice_austere" and (sim.difficulty != 2 or sim.week != 91):
			ci = 0
		elif ev.get("kind", "") == "budget" and bot == "advice_lavish" and sim.week in [13, 39, 65, 91]:
			ci = 2
		elif ev.get("kind", "") == "patronage" and bot == "advice_patron":
			ci = 0
		elif bot in ["visible_wise", "omniscient"]:
			ci = _wise_choice(ev)
		elif bot.begins_with("advice_"):
			ci = _advice_choice("advice_weighted" if bot in ["advice_soft", "advice_dirty", "advice_scheme"] else bot, sim.advice_for(0), ci)
		if not ev["choices"][ci].get("available", true) or sim.private_wealth + float(ev["choices"][ci].get("fx", {}).get("wealth", 0)) < 0.0:
			ci = 1 if ev.get("kind", "") == "patronage" else 0
		sim.resolve_decision(0, ci)


## Ekranda görünen meclis görüşüyle seçim (yalnızca rec/warn/stake/kind görünür bilgidir).
func _advice_choice(bot: String, adv: Array, fallback: int) -> int:
	if adv.is_empty():
		return fallback
	if bot == "advice_naive":
		return int(adv[0]["rec"]) if int(adv[0]["rec"]) >= 0 else fallback
	if bot == "advice_quiet":
		bot = "advice_weighted"
	if bot == "advice_kessler":
		for it: Dictionary in adv:
			if it["actor"] == "kessler" and int(it["rec"]) >= 0:
				return int(it["rec"])
	var votes := {}
	for it: Dictionary in adv:
		var wgt := 0.5 if it["stake"] else 1.0
		if int(it["rec"]) >= 0:
			votes[int(it["rec"])] = float(votes.get(int(it["rec"]), 0.0)) + wgt
		if int(it["warn"]) >= 0:
			votes[int(it["warn"])] = float(votes.get(int(it["warn"]), 0.0)) - wgt
	var best := fallback
	var best_v := float(votes.get(fallback, 0.0))
	for k in votes:
		if float(votes[k]) > best_v:
			best_v = float(votes[k])
			best = int(k)
	return best


## Kriz kartı: görüşsüz bot rastgele; danışman botları kart metnindeki ipuçlarına (muhafız/sokak) bakar;
## bilge bot gerçek olasılıklara bakar. Seçenekler: 0 güç kullan, 1 taviz/uzlaş, 2 halka/meclise git.
## (Sokak ve mahkeme krizlerinde bilge bot da ipuçlarını kullanır.)
func _crisis_choice(bot: String, ev: Dictionary, fallback: int) -> int:
	if bot in ["visible_wise", "omniscient"] and str(ev.get("crisis_kind", "coup")) == "coup":
		var r: float = sim.crisis_chance("rally")
		var a: float = sim.crisis_chance("appeal")
		if maxf(r, a) < 0.4:
			return 1
		return 0 if r >= a else 2
	if not bot.begins_with("advice_") and not bot in ["visible_wise", "omniscient"]:
		return fallback
	var cues: Dictionary = ev.get("cues", {})
	if int(cues.get("guard", 0)) >= 2:
		return 0
	if int(cues.get("street", 0)) >= 2:
		return 2
	return 1


func _wise_choice(ev: Dictionary) -> int:
	var best := 0
	for i in ev["choices"].size():
		if sim.choice_value(ev["choices"][i].get("fx", {})) > sim.choice_value(ev["choices"][best].get("fx", {})):
			best = i
	return best


# ---------------------------------------------------------------- Eylemler

func _act_random() -> void:
	var ids: Array = sim.actors.keys()
	while sim.mesai > 0 and not ids.is_empty():
		var id: String = ids[rng.randi() % ids.size()]
		if not sim.actors.has(id):
			return
		match rng.randi() % 4:
			0:
				sim.promote(id)
			1:
				if sim.private_wealth >= 5.0:
					sim.bribe(id)
				else:
					sim.cross_check(id)
			2:
				sim.cross_check(id)
			_:
				sim.order(id, "bastir", "sozlu")


## Görünür bilgi: rapor bantları (0 iyi, 2 kötü), "moved" (DÜŞMAN etiketi), dosyalar, servet.
## alert: kişi kartındaki şüphe göstergesine tepki verir (en şüpheliyi huzura çağırır; Tehlikeli ise gizli ödeme).
func _act_visible(alert := false) -> void:
	var guard := 0
	while sim.mesai > 0 and guard < 8:
		guard += 1
		# 1) Sana dair ve dedikoduya dönmüş bir dosya varsa önce onu bastır/yok et.
		var hot := ""
		for fid in sim.facts:
			var f: Dictionary = sim.facts[fid]
			if f["subject"] == "king" and not f.get("public", false) and float(f["common"]) >= 0.25:
				hot = fid
		if hot != "":
			sim.suppress_fact(hot)
			continue
		# 2) En kötü raporu veren (bant 2) kişiye yönel: ordu kötü → Arden'i gönlünü al; sokak kötü → bastır.
		var worst: Dictionary = {}
		for r: Dictionary in sim.reports:
			if sim.actors.has(str(r["source"])) and sim.actors[str(r["source"])].supporting:
				continue  # eski strateji yeni kadro raporlarını karar girdisi yapmaz
			if worst.is_empty() or int(r["band"]) > int(worst["band"]):
				worst = r
		var src: String = worst.get("source", "")
		if src != "" and sim.actors.has(src) and int(worst.get("band", 0)) >= 1:
			if src in ["press", "lena"] and sim.actors.has("arden") and style == "soft":
				if sim.summon_wait(src) == 0:
					sim.summon(src)
				else:
					sim.cross_check(src)
			elif src in ["press", "lena"] and sim.actors.has("arden"):
				sim.order("arden", "bastir", "yazili" if style == "dirty" else "sozlu")
			elif style == "dirty" and sim.actors[src].known_weak and sim.actors[src].blackmailed == 0:
				sim.blackmail(src)
			elif style == "dirty" and not sim.actors[src].known_weak:
				sim.investigate(src)
			elif sim.private_wealth >= 5.0:
				sim.bribe(src)
			else:
				sim.cross_check(src)
			continue
		# 3) Boş mesai: alametlere tepki (alert) ya da sırayla doğrula (bilgi topla).
		if alert:
			var sus := _most_suspicious()
			if sus != "" and sim.summon_wait(sus) == 0:
				sim.summon(sus)
				continue
			if sus != "" and sim.suspicion_level(sus) >= 3 and sim.private_wealth >= 5.0:
				sim.bribe(sus)
				continue
		var ids: Array = sim.actors.keys().filter(func(id: String) -> bool: return not sim.actors[id].supporting)
		if ids.is_empty():
			return
		sim.cross_check(ids[(sim.week + guard) % ids.size()])


## Darbeyi yalnızca ordu ya da hanedan başlatabilir (oyuncu rehberinde ve kartlarda görünür): önce onları izle.
func _most_suspicious() -> String:
	var sus := ""
	for a in sim.actors.values():
		if a.moved or not a.insider:
			continue
		var lvl: int = sim.suspicion_level(a.id)
		if lvl < 2 or (not (a.military or a.royal) and lvl < 3):
			continue
		if sus == "" or sim.suspicion(a.id) > sim.suspicion(sus):
			sus = a.id
	return sus


func _act_omniscient() -> void:
	while sim.mesai > 0:
		var target: Object = null
		for a in sim.actors.values():
			if a.moved or not a.insider:
				continue
			if target == null or a.rebellion_drive() > target.rebellion_drive():
				target = a
		if target == null:
			return
		if target.rebellion_drive() > 0.0 and sim.private_wealth >= 5.0:
			sim.bribe(target.id)
		else:
			sim.cross_check(target.id)


## Görünür bilgiyle düşürme: tavır göstergesi en yüksek iki içeriden kişi (en az "Huzursuz"), aynı çift bekleme dışındaysa.
func _scheme() -> void:
	if sim.mesai < 3:
		return
	var cand: Array = []
	for a in sim.actors.values():
		if a.moved or not a.insider:
			continue
		if sim.suspicion_level(a.id) >= 1:
			cand.append(a)
	cand.sort_custom(func(x, y) -> bool: return sim.suspicion(x.id) > sim.suspicion(y.id))
	if cand.size() < 2:
		return
	var ids := [cand[0].id, cand[1].id]
	if sim.rival_wait(ids) == 0:
		sim.divide_rivals(ids)
