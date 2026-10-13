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
const BOTS := ["idle", "random", "visible", "advice_naive", "advice_weighted", "advice_kessler", "advice_soft", "advice_dirty", "advice_scheme", "advice_loyal", "advice_merit", "advice_austere", "advice_lavish", "advice_patron", "advice_veliaht", "advice_heyet", "advice_bloc", "visible_wise", "omniscient", "public_out", "public_hide", "parliament_force", "parliament_withdraw", "parliament_abstain", "confidence_force", "confidence_fall", "region_invest_one", "region_invest_none", "region_garrison_capital", "army_allowance", "army_split", "army_garrison_capital", "army_garrison_border", "army_none"]
var style := ""   # advice_soft / advice_dirty oyun tarzı
var dynasty_probe := false
var dynasty_cap_ok := true


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
	if "--dynasty-cap" in OS.get_cmdline_user_args():
		for d in diffs:
			_run_dynasty_cap(d, n)
		quit(0 if dynasty_cap_ok else 1)
		return
	for d in diffs:
		print("=== Zorluk: %s ===" % sim.DIFFICULTY[d]["name"])
		for bot in bots:
			_run(bot, d, n)
	quit(0)


func _run_dynasty_cap(diff: int, n: int) -> void:
	var base_wins := 0
	var dynasty_wins := 0
	var carried_runs := 0
	dynasty_probe = true
	for seed in range(1, n + 1):
		var inherited: Dictionary = {}
		for generation in range(1, 4):
			var campaign_seed := seed + (generation - 1) * n
			carried_runs += 1 if not inherited.is_empty() else 0
			sim.new_game(campaign_seed, diff, "", inherited)
			rng.seed = campaign_seed * 131 + 7
			while not sim.ended:
				_play("advice_weighted")
				sim.end_week()
			if sim.record.get("survived", false):
				dynasty_wins += 1
				if sim.flags.has("halef_karari_1"):
					inherited = sim.legacy_for_next_reign(generation + 1)
				else:
					inherited = {}
			else:
				inherited = {}
			# Eşlenmiş taban: aynı tohum, aynı bot, miras parametresi olmadan.
			dynasty_probe = false
			sim.new_game(campaign_seed, diff)
			rng.seed = campaign_seed * 131 + 7
			while not sim.ended:
				_play("advice_weighted")
				sim.end_week()
			if sim.record.get("survived", false):
				base_wins += 1
			dynasty_probe = true
	var base_rate := 100.0 * float(base_wins) / float(n * 3)
	var dynasty_rate := 100.0 * float(dynasty_wins) / float(n * 3)
	dynasty_cap_ok = dynasty_cap_ok and dynasty_rate - base_rate <= 8.0
	print("DYNASTY_CAP %s n=%d base=%d/%d (%.1f%%) dynasty=%d/%d (%.1f%%) delta=%+.1fpp limit=+8pp" % [
		str(sim.DIFFICULTY[diff]["name"]), n * 3, base_wins, n * 3, base_rate, dynasty_wins, n * 3, dynasty_rate, dynasty_rate - base_rate])
	print("  inherited campaigns=%d; three sequential campaigns per seed, failed reign resets the streak" % carried_runs)
	dynasty_probe = false


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
	var confidence_offers := 0
	var confidence_supports := 0
	var confidence_falls := 0
	var confidence_forced := 0
	var army_actions := 0
	var army_allowances := 0
	var army_splits := 0
	var army_redeployments := 0
	var regimes := {}
	for s in range(1, n + 1):
		sim.new_game(s, diff)
		rng.seed = s * 131 + 7
		while not sim.ended:
			_play(bot)
			sim.end_week()
		var r: Dictionary = sim.record
		confidence_offers += int(sim.stats.get("confidence_offers", 0))
		confidence_supports += int(sim.stats.get("confidence_supports", 0))
		confidence_falls += int(sim.stats.get("confidence_falls", 0))
		confidence_forced += int(sim.stats.get("confidence_forced", 0))
		army_actions += int(sim.stats.get("army_actions", 0))
		army_allowances += int(sim.stats.get("army_allowances", 0))
		army_splits += int(sim.stats.get("army_splits", 0))
		army_redeployments += int(sim.stats.get("army_redeployments", 0))
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
	print("  gÃ¼ven oyu: kart %d | destek %d | dÃ¼ÅŸÃ¼ÅŸ %d | baskÄ± %d" % [confidence_offers, confidence_supports, confidence_falls, confidence_forced])
	print("  ordu kararları: toplam %d | ek ödenek %d | komuta bölme %d | yer değiştirme %d" % [army_actions, army_allowances, army_splits, army_redeployments])
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
	if c.contains("Yabancı müdahalesi"):
		return "yabanci_mudahale"
	if c.contains("Mali çöküş"):
		return "mali_cokus"
	if c.contains("Suikast"):
		return "suikast"
	if c.contains("elit"):
		return "elit_koalisyonu"
	return "diger"


func _play(bot: String) -> void:
	if bot == "idle":
		return
	if bot in ["advice_weighted", "army_allowance", "army_split", "army_garrison_capital", "army_garrison_border"] and sim.mesai > 0 and sim.pending.is_empty():
		var ask_army := false
		if bot == "advice_weighted":
			var visible_arden_warning: bool = sim.difficulty == 2 and sim.actors.has("arden") and sim.actors["arden"].plot_stage >= 3
			ask_army = (visible_arden_warning and not sim.army_command_split and sim.treasury >= 8.0) or (sim.week in [20, 52, 84] and float(sim.budget_allocation.get("army", 0.0)) >= 18.0 and sim.treasury >= 8.0 + float(sim.stats.get("army_allowance_uses", 0)) * 4.0)
		elif bot == "army_allowance":
			ask_army = sim.week % 12 == 0 and float(sim.budget_allocation.get("army", 0.0)) >= 18.0 and sim.treasury >= 8.0 + float(sim.stats.get("army_allowance_uses", 0)) * 4.0
		elif bot == "army_split":
			ask_army = sim.week % 12 == 0 and not sim.army_command_split
		elif bot == "army_garrison_capital":
			ask_army = sim.week % 12 == 0 and str(sim.army_units.get("border", {}).get("region", "border")) == "border"
		else:
			ask_army = sim.week % 12 == 0 and str(sim.army_units.get("capital", {}).get("region", "capital")) == "capital"
		if ask_army:
			sim.request_army_decision()
	if bot in ["region_invest_one", "region_garrison_capital"] and sim.mesai > 0 and sim.pending.is_empty() and sim.week - sim.last_region_action_week >= 12:
		sim.request_regional_decision()
	if bot in ["public_out", "public_hide"] and sim.mesai > 0:
		var action: String = "hide" if bot == "public_hide" else ["speech", "visit", "ceremony"][sim.week % 3]
		sim.public_action(action)
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
			var decision_bot := "advice_weighted" if bot in ["parliament_force", "parliament_withdraw", "parliament_abstain", "confidence_force", "confidence_fall", "army_allowance", "army_split", "army_garrison_capital", "army_garrison_border", "army_none"] else bot
			var cycle := 16 if bot == "advice_loyal" else 20
			var start := 16 if bot == "advice_loyal" else 12
			if bot in ["advice_loyal", "advice_merit"] and sim.week >= start and (sim.week - start) % cycle in [0, 1]:
				var ids := ["kessler", "dorn"] if (sim.week - start) % cycle == 0 else ["falk", "arden"]
				for id in ids:
					sim.appoint(id, "loyal" if bot == "advice_loyal" else "merit")
			if bot == "advice_scheme":
				_scheme()
			_act_visible(decision_bot.begins_with("advice_") and decision_bot != "advice_quiet")


# ---------------------------------------------------------------- Kararlar

func _decide(bot: String) -> void:
	var guard := 0
	while not sim.pending.is_empty() and (sim.mesai > 0 or sim.pending[0]["event"].get("kind", "") == "parliament_bill") and guard < 6:
		guard += 1
		var ev: Dictionary = sim.pending[0]["event"]
		var ci: int = 0 if str(ev.get("kind", "")) == "parliament_bill" else rng.randi() % ev["choices"].size()
		if str(ev.get("kind", "")) == "army_action":
			if ev["choices"].size() > 0 and ev["choices"][0].get("action", "") == "open_army_action":
				var visible_arden_warning: bool = sim.difficulty == 2 and sim.actors.has("arden") and sim.actors["arden"].plot_stage >= 3
				var wanted := ("split" if visible_arden_warning else "allowance") if bot == "advice_weighted" else ("allowance" if bot == "army_allowance" else ("split" if bot == "army_split" else "redeploy"))
				for i in ev["choices"].size():
					if str(ev["choices"][i].get("army_action", "")) == wanted:
						ci = i
						break
			else:
				match bot:
					"army_allowance", "advice_weighted":
						for i in ev["choices"].size():
							if str(ev["choices"][i].get("action", "")) == "allowance": ci = i; break
					"army_split":
						for i in ev["choices"].size():
							if str(ev["choices"][i].get("action", "")) == "split": ci = i; break
					"army_garrison_capital", "army_garrison_border":
						for i in ev["choices"].size():
							var wanted_region := "capital" if bot == "army_garrison_capital" else "border"
							if str(ev["choices"][i].get("action", "")) == "redeploy" and str(ev["choices"][i].get("destination", "")) == wanted_region: ci = i; break
		if ev.get("kind", "") == "regional_action" and bot == "region_invest_none":
			break
		if ev.get("kind", "") == "regional_action" and bot in ["region_invest_one", "region_garrison_capital"]:
			if ev["choices"][0].get("action", "") == "select_region":
				for i in ev["choices"].size():
					if str(ev["choices"][i].get("region", "")) == ("capital" if bot == "region_garrison_capital" else "industry"):
						ci = i
						break
			else:
				ci = 1 if bot == "region_garrison_capital" else 0
		var parliament_bot := bot in ["parliament_force", "parliament_withdraw", "parliament_abstain"]
		if parliament_bot and str(ev.get("kind", "")) == "parliament_bill":
			if bot == "parliament_abstain":
				break
			ci = 3 if bot == "parliament_force" else 2
			if not ev["choices"][ci].get("available", true):
				ci = 0
		if str(ev.get("kind", "")) == "confidence_vote":
			if bot == "parliament_abstain":
				break
			elif bot == "confidence_force":
				ci = 2
			elif bot == "confidence_fall":
				ci = 1
		var decision_bot := "advice_weighted" if parliament_bot or bot in ["confidence_force", "confidence_fall"] else bot
		if str(ev.get("kind", "")) == "public_poll" and bot in ["public_out", "public_hide"]:
			ci = 0 if bot == "public_out" else 1
		if dynasty_probe and str(ev.get("id", "")) == "halef_karari":
			ci = 1
		elif ev.get("crisis", false):
			ci = _crisis_choice(bot, ev, ci)
		elif ev.get("kind", "") == "budget" and bot == "advice_austere" and (sim.difficulty != 2 or sim.week != 91):
			ci = 0
		elif ev.get("kind", "") == "budget" and bot == "advice_lavish" and sim.week in [13, 39, 65, 91]:
			ci = 3
		elif ev.get("kind", "") == "patronage" and bot == "advice_patron":
			ci = 0
		elif decision_bot in ["visible_wise", "omniscient"]:
			ci = _wise_choice(ev)
		elif decision_bot.begins_with("advice_") and str(ev.get("kind", "")) != "army_action":
			ci = _advice_choice("advice_weighted" if decision_bot in ["advice_soft", "advice_dirty", "advice_scheme"] else decision_bot, sim.advice_for(0), ci)
		if parliament_bot and str(ev.get("kind", "")) == "parliament_bill":
			ci = 3 if bot == "parliament_force" else 2
		if str(ev.get("kind", "")) == "confidence_vote":
			if bot == "confidence_force":
				ci = 2
			elif bot == "confidence_fall":
				ci = 1
		if str(ev.get("kind", "")) == "confidence_vote" and bot == "confidence_force" and not ev["choices"][2].get("available", true):
			ci = 1
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
		var wgt := 0.5 if bool(it.get("stake", false)) else 1.0
		if int(it.get("rec", -1)) >= 0:
			votes[int(it["rec"])] = float(votes.get(int(it["rec"]), 0.0)) + wgt
		if int(it.get("warn", -1)) >= 0:
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
		if ev.get("choices", []).size() > 0 and str(ev["choices"][0].get("crisis", "")) == "army_suppress":
			var unit_id: String = str(ev["choices"][0].get("unit", ""))
			var suppress: float = sim.crisis_chance("army_suppress", unit_id)
			var bargain: float = sim.crisis_chance("concede")
			return 0 if suppress >= bargain else 1
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
		return 1 if ev.get("choices", []).size() > 2 and str(ev["choices"][2].get("crisis", "")) == "army_switch" else 2
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
