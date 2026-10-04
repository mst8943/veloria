extends Node
## Veloria simülasyon çekirdeği (autoload: Sim).
## Gerçek dünya durumu burada tutulur; oyuncu yalnızca filtrelenmiş raporları görür.

signal week_advanced(week: int)
signal news(text: String)
signal changed()
signal game_ended(record: Dictionary)

const Actor := preload("res://game/core/actor.gd")
const MAX_WEEKS := 104
const MESAI_PER_WEEK := 4
const KING_NAME := "Adrian IV"
const ACTORS_PATH := "res://game/data/actors.json"
const EVENTS_PATH := "res://game/data/events.json"
const SAVE_PATH := "user://veloria_save.txt"
const GOOD_DOMAINS_HIGH := ["economy"]  # bu alanlarda yüksek değer iyidir

var rng := RandomNumberGenerator.new()
var week := 1
var mesai := MESAI_PER_WEEK
var king_strength := 60.0   # gerçek güç (oyuncu görmez)
var unrest := 30.0
var economy := 55.0
var opposition := 20.0
var private_wealth := 10.0
var actors: Dictionary = {}  # id -> Actor
var facts: Dictionary = {}   # id -> Dictionary
var flags: Dictionary = {}
var fired_events: Dictionary = {}
var history: Array = []
var reports: Array = []
var pending: Array = []      # {event, age}
var truth_log: Array = []
var karne: Dictionary = {}   # kaynak -> {ok, bad}
var stats: Dictionary = {}
var weekly_news: Array = []
var ended := false
var record: Dictionary = {}
var coup_leader := ""

var _events: Array = []


func new_game(seed_value: int = 0) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	week = 1
	mesai = MESAI_PER_WEEK
	king_strength = 60.0
	unrest = 30.0
	economy = 55.0
	opposition = 20.0
	private_wealth = 10.0
	actors.clear()
	facts.clear()
	flags.clear()
	fired_events.clear()
	history.clear()
	reports.clear()
	pending.clear()
	truth_log.clear()
	karne.clear()
	weekly_news.clear()
	stats = {"ops": 0, "bribes": 0, "promotes": 0, "leaks": 0, "dismissals": 0, "written": 0, "hints": 0, "checks": 0}
	ended = false
	record = {}
	coup_leader = ""
	for d in _load_json(ACTORS_PATH):
		var a := Actor.new()
		a.setup(d)
		# Her kampanyada gizli özellikler değişir (tekrar oynanabilirlik).
		a.ambition += rng.randf_range(-12.0, 12.0)
		a.honesty = clampf(a.honesty + rng.randf_range(-0.15, 0.15), 0.05, 1.0)
		a.perceived_king = king_strength + rng.randf_range(-5.0, 5.0)
		actors[a.id] = a
		karne[a.id] = {"ok": 0, "bad": 0}
	_events = _load_json(EVENTS_PATH)
	_fire_events()
	_generate_reports()
	changed.emit()


func _load_json(path: String) -> Array:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Veri dosyası açılamadı: " + path)
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Array else []


# ---------------------------------------------------------------- Kayıt

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	if ended:
		return false
	var a_data := {}
	for id in actors:
		a_data[id] = actors[id].to_save()
	var data := {"week": week, "mesai": mesai, "king": king_strength, "unrest": unrest, "economy": economy,
		"opp": opposition, "wealth": private_wealth, "actors": a_data, "facts": facts, "flags": flags,
		"fired": fired_events, "history": history, "pending": pending, "truth": truth_log, "karne": karne,
		"stats": stats, "rng": rng.state, "seed": rng.seed}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(var_to_str(data))
	return true


func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var d: Variant = str_to_var(f.get_as_text())
	if not d is Dictionary:
		return false
	new_game(int(d.get("seed", 1)))
	week = d["week"]
	mesai = d["mesai"]
	king_strength = d["king"]
	unrest = d["unrest"]
	economy = d["economy"]
	opposition = d["opp"]
	private_wealth = d["wealth"]
	for id in d["actors"]:
		if actors.has(id):
			actors[id].from_save(d["actors"][id])
	for id in actors.keys():
		if not d["actors"].has(id):
			actors.erase(id)  # oyuncunun görevden aldığı kişiler
	facts = d["facts"]
	flags = d["flags"]
	fired_events = d["fired"]
	history = d["history"]
	pending = d["pending"]
	truth_log = d["truth"]
	karne = d["karne"]
	stats = d["stats"]
	rng.state = d["rng"]
	_generate_reports()
	changed.emit()
	return true


# ---------------------------------------------------------------- Oyuncu eylemleri

func spend_mesai(cost: int = 1) -> bool:
	if ended or mesai < cost:
		return false
	mesai -= cost
	return true


func _no_mesai() -> String:
	return "Bu hafta mesain kalmadı."


## Terfi: güç ve minnet verir, ama borç ve hırs da büyür.
func promote(id: String) -> String:
	var a: Actor = actors[id]
	if not spend_mesai():
		return _no_mesai()
	a.power += 12.0
	a.loyalty["career"] += 8.0
	a.obligation += 10.0
	a.ambition += 4.0
	stats["promotes"] += 1
	flags[id.to_upper() + "_GUCLENDI"] = week
	changed.emit()
	return "%s terfi etti. Sana minnettar, ama artık daha güçlü." % a.display_name


## Rüşvet: sadakat satın alır ve kanıt üretir.
func bribe(id: String) -> String:
	var a: Actor = actors[id]
	if private_wealth < 5.0:
		return "Kişisel servetin yetersiz."
	if not spend_mesai():
		return _no_mesai()
	private_wealth -= 5.0
	a.loyalty["money"] += 8.0
	a.secrets_on_king += 1
	stats["bribes"] += 1
	_add_fact("transfer_%s_%d" % [id, week], "%s'e yapılan gizli ödeme" % a.display_name, "king", 25, [id, "dorn"], 2)
	changed.emit()
	return "%s'e gizli ödeme yapıldı. Sadakati arttı; ama bir iz kaldı." % a.display_name


## Emir: kanal seçimi sonucu ve inkâr edilebilirliği belirler.
## channel: "yazili" (kesin + kanıt), "sozlu" (yarı kesin), "ima" (belirsiz + inkâr edilebilir)
func order(id: String, task: String, channel: String) -> String:
	var a: Actor = actors[id]
	if not spend_mesai():
		return _no_mesai()
	var fidelity := 1.0
	match channel:
		"yazili":
			fidelity = 1.0
			stats["written"] += 1
			a.secrets_on_king += 1
			_add_fact("emir_%s_%d" % [id, week], "%s'e verilen yazılı emir" % a.display_name, "king", 35, [id], 1)
		"sozlu":
			fidelity = 0.75
		"ima":
			stats["hints"] += 1
			# Hırslı biri imayı aşırı yorumlar, korkak biri hiç uygulamaz.
			fidelity = clampf(0.3 + a.ambition / 100.0 + rng.randf_range(-0.2, 0.4) - a.red_line_penalty(task), 0.0, 1.5)
	var text := ""
	match task:
		"bastir":
			unrest = maxf(0.0, unrest - 14.0 * fidelity)
			a.power += 6.0 * fidelity
			a.obligation += 5.0 * fidelity
			if fidelity > 1.1:
				unrest += 6.0
				text = "%s emri fazla sert yorumladı; bastırma kontrolden çıkıyor." % a.display_name
			elif fidelity < 0.4:
				text = "%s emri anlamadı ya da uygulamadı. Hiçbir şey olmadı." % a.display_name
			else:
				text = "%s harekete geçti." % a.display_name
		"sorustur":
			a.power += 3.0 * fidelity
			a.secrets_on_king += 1 if a.domain == "intel" else 0
			_reveal_hint(a, fidelity)
			text = "%s soruşturmayı başlattı." % a.display_name
		_:
			text = "%s emri aldı." % a.display_name
	changed.emit()
	return text


func _reveal_hint(investigator: Actor, fidelity: float) -> void:
	# Soruşturma bir aktörün hazır olup olmadığına dair bir ipucu verir (bazen yanlış).
	if fidelity < 0.4:
		return
	var suspects: Array = []
	for a: Actor in actors.values():
		if a.ready and a.id != investigator.id and a.insider:
			suspects.append(a)
	if suspects.is_empty():
		return
	var s: Actor = suspects[rng.randi() % suspects.size()]
	if rng.randf() < 0.5 + investigator.honesty * 0.3:
		weekly_news.append("Soruşturma notu: %s hakkında endişe verici bir ipucu bulundu." % s.display_name)
	else:
		var others: Array = actors.values()
		var w: Actor = others[rng.randi() % others.size()]
		weekly_news.append("Soruşturma notu: %s hakkında endişe verici bir ipucu bulundu." % w.display_name)


## Çapraz doğrulama: bir kaynağın raporunu gerçek durumla kıyaslayan gürültülü ipucu.
func cross_check(id: String) -> String:
	if not spend_mesai():
		return _no_mesai()
	stats["checks"] += 1
	var a: Actor = actors[id]
	var gap := _domain_truth(a.domain) - _domain_reported(a)
	var noisy := gap + rng.randf_range(-8.0, 8.0)
	var worse := (a.domain == "economy" and noisy < -6.0) or (a.domain != "economy" and noisy > 6.0)
	changed.emit()
	if absf(noisy) < 6.0:
		karne[id]["ok"] += 1
		return "%s'in raporu diğer kaynaklarla büyük ölçüde örtüşüyor." % a.display_name
	if worse:
		karne[id]["bad"] += 1
		return "Başka kaynaklar durumun %s'in anlattığından DAHA KÖTÜ olduğunu söylüyor." % a.display_name
	karne[id]["ok"] += 1
	return "Başka kaynaklar durumu %s'in anlattığından biraz daha iyi görüyor." % a.display_name


## Gizli operasyon: katılan her kişi sırrı bilir; çember büyüdükçe başarı ve sızıntı riski artar.
func operation(kind: String, ids: Array) -> String:
	if ids.is_empty() or ids.size() > 3:
		return "Operasyon için 1–3 kişi seç (Ctrl ile çoklu seçim)."
	if mesai < 2:
		return "Operasyon 2 mesai ister."
	spend_mesai(2)
	stats["ops"] += 1
	var success_chance := 0.45 + 0.1 * ids.size()
	var leak_chance := 0.0
	var names: Array[String] = []
	for id in ids:
		var a: Actor = actors[id]
		names.append(a.display_name)
		a.secrets_on_king += 1
		a.loyalty["complicity"] += 8.0
		leak_chance += 0.05 + a.ambition / 400.0 + (1.0 - clampf(a.total_loyalty() / 100.0, 0.0, 1.0)) * 0.08
	var ok := rng.randf() < success_chance
	var text := ""
	match kind:
		"dikkat":
			if ok:
				unrest = maxf(0.0, unrest - 12.0)
				text = "Sahte kriz işe yaradı; gündem değişti."
			else:
				unrest += 3.0
				king_strength -= 2.0
				text = "Operasyon amatörce kaldı; kimse inanmadı."
		"bol":
			if ok:
				opposition = maxf(0.0, opposition - 15.0)
				text = "Muhalefet kanatları birbirine düştü."
			else:
				opposition += 5.0
				text = "Muhalefet planı fark etti ve birleşme hızlandı."
		"zayiflat":
			var target: Actor = null
			for a: Actor in actors.values():
				if ids.has(a.id):
					continue
				if target == null or a.power > target.power:
					target = a
			if target == null:
				text = "Zayıflatılacak kimse yok."
			elif ok:
				target.power = maxf(5.0, target.power - 12.0)
				target.ambition += 5.0
				text = "%s'in itibarı sarsıldı. Kim yaptığını tahmin etmesi zor değil." % target.display_name
			else:
				text = "Operasyon boşa gitti; %s şüphelendi." % target.display_name
				target.ambition += 5.0
	text += " (Çember: %s)" % ", ".join(names)
	if rng.randf() < leak_chance:
		_add_fact("operasyon_%d_%d" % [stats["ops"], week], "Gizli operasyon (%s)" % kind, "king", 45, ids.duplicate(), 1, 0.9)
		facts["operasyon_%d_%d" % [stats["ops"], week]]["common"] = 0.3
		text += " Ama bir şey sızmış gibi."
	changed.emit()
	return text


## Bir olguyu yay (ortak bilgi artar) ya da bastır.
func leak_fact(fact_id: String) -> String:
	if not facts.has(fact_id) or not spend_mesai():
		return "Olmadı (mesai ya da dosya yok)."
	stats["leaks"] += 1
	facts[fact_id]["common"] = minf(1.0, facts[fact_id]["common"] + 0.5)
	changed.emit()
	return "'%s' basına sızdırıldı." % facts[fact_id]["text"]


func suppress_fact(fact_id: String) -> String:
	if not facts.has(fact_id) or not spend_mesai():
		return "Olmadı (mesai ya da dosya yok)."
	var f: Dictionary = facts[fact_id]
	f["common"] = maxf(0.0, f["common"] - 0.3)
	changed.emit()
	return "'%s' için sessizlik sağlandı. Kanıtın kopyaları hâlâ duruyor." % f["text"]


## Kanıtı yok et: kopya sayısı kadar zor; yok etme girişimi de iz bırakabilir.
func destroy_evidence(fact_id: String) -> String:
	if not facts.has(fact_id):
		return "Dosya yok."
	if not spend_mesai():
		return _no_mesai()
	var f: Dictionary = facts[fact_id]
	if f.get("public", false):
		return "Bu artık herkesin bildiği bir şey; kanıtı yok etmek işe yaramaz."
	if int(f["copies"]) > 1:
		f["copies"] = int(f["copies"]) - 1
		changed.emit()
		return "'%s' kanıtının bir kopyası yok edildi; hâlâ kopyaları var." % f["text"]
	if rng.randf() < 0.7:
		facts.erase(fact_id)
		changed.emit()
		return "Kanıt yok edildi."
	f["common"] = minf(1.0, float(f["common"]) + 0.2)
	changed.emit()
	return "Girişim fark edildi; dosya hakkında dedikodu arttı."


## Görevden alma: kral hakkında çok şey bilen biri karşı atak yapar.
func dismiss(id: String) -> String:
	var a: Actor = actors[id]
	if not spend_mesai():
		return _no_mesai()
	stats["dismissals"] += 1
	if a.secrets_on_king >= 2 or a.power >= 60.0:
		a.moved = true
		a.ready = true
		king_strength -= 12.0
		_add_fact("sizinti_%s" % id, "%s kralın sırlarını sızdırıyor" % a.display_name, "king", 60, [id], 1, 0.9)
		changed.emit()
		return "%s görevden alındı ama kralın sırlarını biliyordu ve konuşmaya başladı!" % a.display_name
	actors.erase(id)
	king_strength += 2.0
	changed.emit()
	return "%s görevden alındı. Sessizce gitti." % a.display_name


# ---------------------------------------------------------------- Kararlar

func resolve_decision(pending_index: int, choice_index: int) -> String:
	if ended or pending_index < 0 or pending_index >= pending.size():
		return ""
	var e: Dictionary = pending[pending_index]["event"]
	var ch: Dictionary = e["choices"][choice_index]
	var fx: Dictionary = ch.get("fx", {})
	if float(fx.get("wealth", 0)) + private_wealth < 0.0:
		return "Kişisel servetin yetersiz."
	if not spend_mesai():
		return _no_mesai()
	pending.remove_at(pending_index)
	flags["%s_%d" % [e["id"], choice_index]] = week
	_apply_effects(fx)
	history.append("Hafta %d — %s → %s" % [week, e["title"], ch["label"]])
	changed.emit()
	return str(ch.get("text", ""))


func _apply_effects(fx: Dictionary) -> void:
	unrest = clampf(unrest + float(fx.get("unrest", 0)), 0.0, 100.0)
	economy = clampf(economy + float(fx.get("economy", 0)), 0.0, 100.0)
	king_strength = clampf(king_strength + float(fx.get("king", 0)), 0.0, 100.0)
	opposition = clampf(opposition + float(fx.get("opp", 0)), 0.0, 100.0)
	private_wealth = maxf(0.0, private_wealth + float(fx.get("wealth", 0)))
	var af: Dictionary = fx.get("actors", {})
	for aid in af:
		if actors.has(aid):
			for prop in af[aid]:
				_bump(actors[aid], str(prop), float(af[aid][prop]))
	if fx.has("fact"):
		var fd: Dictionary = fx["fact"]
		_add_fact(fd["id"], fd["text"], fd["subject"], fd["severity"], fd["knowers"], 1)
	if fx.has("flag"):
		flags[fx["flag"]] = week
	# Bir dosyayı herkesin bildiği hâle getir (eski karar geri döner).
	for fid in _as_array(fx.get("leak", [])):
		if facts.has(fid):
			facts[fid]["common"] = 1.0
	# Bir aktörü oyundan çıkar (istifa, sürgün, emeklilik).
	for aid in _as_array(fx.get("remove", [])):
		if actors.has(aid):
			flags[str(aid).to_upper() + "_GITTI"] = week
			actors.erase(aid)


func _bump(a: Actor, prop: String, d: float) -> void:
	if prop.begins_with("l_"):
		var k := prop.substr(2)
		a.loyalty[k] = maxf(0.0, float(a.loyalty.get(k, 0)) + d)
	elif prop == "secrets_on_king":
		a.secrets_on_king = maxi(0, a.secrets_on_king + int(d))
	else:
		a.set(prop, float(a.get(prop)) + d)


# ---------------------------------------------------------------- Haftalık tick

func end_week() -> void:
	if ended:
		return
	# Ertelenen kararlar kendi kendine çözülür (olgunlaşır).
	var keep: Array = []
	for p in pending:
		p["age"] += 1
		if p["age"] >= 2:
			var e: Dictionary = p["event"]
			var ig: Dictionary = e.get("ignore", {"text": "Karar ertelendi.", "fx": {"unrest": 3}})
			flags[str(e["id"]) + "_ertelendi"] = week
			_apply_effects(ig.get("fx", {}))
			var line := "ERTELENDİ — %s: %s" % [e["title"], ig.get("text", "")]
			history.append("Hafta %d — %s → (ertelendi)" % [week, e["title"]])
			weekly_news.append(line)
		else:
			keep.append(p)
	pending = keep
	week += 1
	mesai = MESAI_PER_WEEK
	weekly_news.clear()
	_world_tick()
	_decay_facts()
	_fire_events()
	_run_cascade()
	_generate_reports()
	_check_end()
	for n in weekly_news:
		news.emit(n)
	week_advanced.emit(week)
	changed.emit()


func _world_tick() -> void:
	var brandt: Actor = actors.get("brandt")
	for a: Actor in actors.values():
		a.power += a.ambition * 0.03 + rng.randf_range(-0.4, 1.0)
		a.ambition += 0.03
		a.perceived_king += (king_strength - a.perceived_king) * 0.2
		a.perceived_king -= unrest * 0.01 + opposition * 0.005
		if a.perceived_king < 45.0:
			a.ambition += 0.5
		# Satın alınan sadakat zamanla aşınır.
		a.loyalty["money"] = maxf(0.0, a.loyalty["money"] - 0.07)
		if a.perceived_king < 50.0:
			a.loyalty["fear"] = maxf(0.0, a.loyalty["fear"] - 0.15)
		a.fear = maxf(0.0, a.fear - 0.2)
	var opp_push := (unrest - 40.0) * 0.05 + (brandt.power * 0.01 if brandt else 0.0) - 0.15
	opposition = clampf(opposition + opp_push, 0.0, 100.0)
	unrest = clampf(unrest + rng.randf_range(-3.0, 3.0) + (50.0 - economy) * 0.05 + (opposition - 40.0) * 0.01 - (unrest - 30.0) * 0.06, 0.0, 100.0)
	economy = clampf(economy + rng.randf_range(-2.5, 2.8) - unrest * 0.02 + (55.0 - economy) * 0.03, 0.0, 100.0)
	king_strength = clampf(king_strength - unrest * 0.012 - opposition * 0.004 + (economy - 50.0) * 0.01 + 0.4, 0.0, 100.0)
	private_wealth += 0.8  # sivil liste ödeneği


func _decay_facts() -> void:
	for f: Dictionary in facts.values():
		# Dosyalar sızar: bilen sayısı arttıkça ortak bilgi yavaş yavaş yükselir.
		f["common"] = minf(1.0, f["common"] + 0.01 * f["knowers"].size() * f.get("leakiness", 0.5))
		if f["common"] >= 0.25 and f["common"] < 0.5 and not f.get("rumor", false):
			f["rumor"] = true
			weekly_news.append("KULİS: '%s' konuşulmaya başladı." % f["text"])
		if f["common"] >= 0.5 and not f.get("public", false):
			f["public"] = true
			if f["subject"] == "king":
				king_strength = maxf(0.0, king_strength - f["severity"] * 0.15)
				for a: Actor in actors.values():
					a.perceived_king -= f["severity"] * 0.1
			elif actors.has(f["subject"]):
				var s: Actor = actors[f["subject"]]
				s.power = maxf(5.0, s.power - f["severity"] * 0.25)
				s.fear += 8.0
			weekly_news.append("MANŞET: %s herkesin bildiği bir şey oldu." % f["text"])


func _eligible(e: Dictionary) -> bool:
	var id: String = e["id"]
	var once: bool = e.get("once", true)
	if fired_events.has(id):
		if once:
			return false
		if week - int(fired_events[id]) < int(e.get("cooldown", 12)):
			return false
	if week < int(e.get("min_week", 0)) or week > int(e.get("max_week", 999)):
		return false
	if unrest < float(e.get("min_unrest", 0)) or unrest > float(e.get("max_unrest", 100)):
		return false
	if economy < float(e.get("min_economy", 0)) or economy > float(e.get("max_economy", 100)):
		return false
	if opposition < float(e.get("min_opposition", 0)):
		return false
	var mp: Dictionary = e.get("min_power", {})
	for aid in mp:
		if not actors.has(aid) or actors[aid].power < float(mp[aid]):
			return false
	for fl in _as_array(e.get("needs_flag", [])):
		if not flags.has(fl):
			return false
	for fl in _as_array(e.get("blocks_flag", [])):
		if flags.has(fl):
			return false
	var any: Array = _as_array(e.get("any_flag", []))
	if not any.is_empty():
		var found := false
		for fl in any:
			if flags.has(fl):
				found = true
		if not found:
			return false
	# Gecikmeli sonuç: karar en az N hafta önce verilmiş olmalı.
	var fa: Dictionary = e.get("flag_age", {})
	for fl in fa:
		if not flags.has(fl) or week - int(flags[fl]) < int(fa[fl]):
			return false
	var amin: Dictionary = e.get("actor_min", {})
	for aid in amin:
		if not actors.has(aid):
			return false
		for prop in amin[aid]:
			if float(actors[aid].get(prop)) < float(amin[aid][prop]):
				return false
	var amax: Dictionary = e.get("actor_max", {})
	for aid in amax:
		if not actors.has(aid):
			return false
		for prop in amax[aid]:
			if float(actors[aid].get(prop)) > float(amax[aid][prop]):
				return false
	for aid in _as_array(e.get("alive", [])):
		if not actors.has(aid):
			return false
	for fid in _as_array(e.get("needs_fact", [])):
		if not facts.has(fid):
			return false
	if e.get("needs_ready", false):
		var any_ready := false
		for a: Actor in actors.values():
			if a.ready and a.insider:
				any_ready = true
		if not any_ready:
			return false
	return true


func _as_array(v: Variant) -> Array:
	if v is Array:
		return v
	if v is String and v != "":
		return [v]
	return []


func _fire_events() -> void:
	var pool: Array = []
	for e: Dictionary in _events:
		if _eligible(e) and rng.randf() <= float(e.get("chance", 1.0)):
			pool.append([rng.randf(), e])
	pool.sort_custom(func(x: Array, y: Array) -> bool: return x[0] < y[0])
	var added := 0
	for item in pool:
		var e: Dictionary = item[1]
		if e.has("choices"):
			if pending.size() >= 3 or added >= 2:
				continue
			added += 1
			pending.append({"event": e, "age": 0})
		fired_events[e["id"]] = week
		_apply_effects(e.get("fx", {}))
		if not e.has("choices"):
			history.append("Hafta %d — %s" % [week, e["title"]])
		weekly_news.append("OLAY: %s" % e["title"])


## Eşik kaskadı: her aktörün "kaç kişi kıpırdarsa ben de kıpırdarım" eşiği vardır.
## Herkesin bildiği bir zayıflık (ortak bilgi) eşikleri düşürür ve koordinasyonu açar.
func _run_cascade() -> void:
	var drop := _public_weakness()
	for a: Actor in actors.values():
		if a.insider and not a.ready and a.rebellion_drive() > 34.0:
			a.ready = true
	var changed_any := true
	while changed_any:
		changed_any = false
		var share := _ready_power_share()
		for a: Actor in actors.values():
			if a.insider and not a.ready and share >= maxf(0.05, a.threshold - drop) and a.rebellion_drive() > 12.0:
				a.ready = true
				changed_any = true
	var striker := false
	for a: Actor in actors.values():
		if a.ready and a.insider and (a.military or a.royal):
			striker = true
	if week >= 12 and _ready_power_share() >= 0.6 and striker:
		var lead: Actor = null
		for a: Actor in actors.values():
			if a.ready and a.insider:
				a.moved = true
				if (a.military or a.royal) and (lead == null or a.power > lead.power):
					lead = a
		coup_leader = lead.id if lead else ""
		king_strength = 0.0


func _public_weakness() -> float:
	var s := 0.0
	for f: Dictionary in facts.values():
		if f.get("public", false) and f["subject"] == "king":
			s += float(f["severity"])
	return minf(0.3, s / 300.0)


func _ready_power_share() -> float:
	var total := 0.0
	var ready_p := 0.0
	for a: Actor in actors.values():
		if not a.insider:
			continue
		total += a.power
		if a.ready:
			ready_p += a.power
	return ready_p / maxf(total, 1.0)


func legal_pressure() -> float:
	var s := 0.0
	for f: Dictionary in facts.values():
		if f["subject"] == "king":
			s += float(f["severity"]) * (1.0 if f.get("public", false) else 0.25)
	return clampf(s / 2.0, 0.0, 100.0)


func _check_end() -> void:
	if king_strength <= 0.0 or unrest >= 100.0 or legal_pressure() >= 100.0:
		_end(false)
	elif week > MAX_WEEKS:
		_end(true)


func _end(survived: bool) -> void:
	ended = true
	var top: Actor = null
	for a: Actor in actors.values():
		if top == null or a.power > top.power:
			top = a
	var cause := ""
	var title := ""
	if not survived:
		title = "Devrilen Kral"
		if coup_leader != "" and actors.has(coup_leader):
			var l: Actor = actors[coup_leader]
			var promo_week: int = flags.get(l.id.to_upper() + "_GUCLENDI", 0)
			var how := "Askerî darbeyle" if l.military else "Saray darbesiyle"
			cause = "Saltanatının %d. haftasında %s görevden alındı. Darbenin lideri %s" % [week - 1, how, l.display_name]
			if promo_week > 0:
				cause += ", yalnızca %d hafta önce kendisi tarafından terfi ettirilmişti." % (week - promo_week)
			else:
				cause += ". Onu hiç terfi ettirmemiştin; gücünü sen başka işlerle uğraşırken kendi başına topladı."
		elif unrest >= 100.0:
			cause = "Saltanatının %d. haftasında halk ayaklanması sarayı kuşattı." % (week - 1)
		elif legal_pressure() >= 100.0:
			cause = "Saltanatının %d. haftasında Meclis ve yüksek mahkeme, biriken skandallar nedeniyle seni yetkisiz bıraktı." % (week - 1)
		else:
			cause = "Saltanatının %d. haftasında elit koalisyonu desteğini çekti; tahtta kimse seni savunmadı." % (week - 1)
	else:
		cause = "104 haftalık saltanatın sonunda tahtını korudun."
		title = _survivor_title(top)
	record = {"survived": survived, "title": title, "weeks": week - 1, "cause": cause,
		"top_actor": top.display_name if top else "", "history": history.duplicate(),
		"lies": _top_lies(), "king": KING_NAME}
	game_ended.emit(record)


func _survivor_title(top: Actor) -> String:
	if top != null and top.power > 85.0:
		if top.military:
			return "Generallerin Kuklası"
		if top.domain == "media":
			return "Medya İmparatorunun Kuklası"
		if top.domain == "intel":
			return "Gölge Devletin Tutsağı"
		return "%s'in Kuklası" % top.display_name
	if private_wealth >= 50.0:
		return "Altın Kral"
	if economy < 25.0:
		return "Devleti Tüketen"
	if stats["ops"] >= 4:
		return "Büyük Manipülatör"
	if echo_level() > 0.85:
		return "Sessiz Otokrat"
	if stats["written"] == 0 and stats["bribes"] <= 1:
		return "Hanedanı Kurtaran"
	if unrest < 25.0:
		return "Demir Taç"
	return "Sarayın Tilkisi"


func _top_lies() -> Array:
	var lies := truth_log.duplicate()
	lies.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		if x["diff"] != y["diff"]:
			return x["diff"] > y["diff"]
		return x["week"] < y["week"])
	# Çeşitlilik: aynı kişiden en fazla 2 kayıt, toplam 8.
	var out: Array = []
	var per: Dictionary = {}
	for l: Dictionary in lies:
		var n: String = l["name"]
		if int(per.get(n, 0)) >= 2:
			continue
		per[n] = int(per.get(n, 0)) + 1
		out.append(l)
		if out.size() >= 8:
			break
	out.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return x["week"] < y["week"])
	return out


# ---------------------------------------------------------------- Raporlar (bilgi filtresi)

func echo_level() -> float:
	var s := 0.0
	for a: Actor in actors.values():
		s += a.fear
	return clampf(s / maxf(actors.size(), 1) / 60.0, 0.0, 1.0)


func _domain_truth(domain: String) -> float:
	match domain:
		"economy":
			return economy
		"army":
			return clampf(unrest * 0.5 + maxf(0.0, 55.0 - _army_loyalty()), 0.0, 100.0)
		"gate":
			return 100.0 - king_strength
		"opposition":
			return opposition
		"court":
			return legal_pressure()
		"royal":
			var p: Actor = actors.get("prens")
			return clampf(p.ambition + (100.0 - king_strength) * 0.3, 0.0, 100.0) if p else 0.0
		_:
			return unrest


func _army_loyalty() -> float:
	var a: Actor = actors.get("arden")
	return a.total_loyalty() if a else 50.0


func _domain_reported(a: Actor) -> float:
	var t := _domain_truth(a.domain)
	var good := 100.0 if a.domain in GOOD_DOMAINS_HIGH else 0.0
	return lerpf(t, good, a.flattery() * 0.6)


func _band(a: Actor, value: float) -> int:
	if a.domain in GOOD_DOMAINS_HIGH:
		return 0 if value > 62.0 else (1 if value > 40.0 else 2)
	return 0 if value < 30.0 else (1 if value < 55.0 else 2)


func _generate_reports() -> void:
	reports.clear()
	var echo := echo_level()
	var dorn: Actor = actors.get("dorn")
	var worst_idx := -1
	var worst_band := -1
	for a: Actor in actors.values():
		if a.moved:
			continue
		var reported := _domain_reported(a) + rng.randf_range(-6.0, 6.0) * (1.0 - a.honesty * 0.5)
		var rb := _band(a, reported)
		var tb := _band(a, _domain_truth(a.domain))
		if rb < tb:
			truth_log.append({"week": week, "name": a.display_name, "said": _phrase(a, reported, echo),
				"truth": _phrase(a, _domain_truth(a.domain), 0.0), "diff": tb - rb})
		reports.append({"source": a.id, "name": a.display_name, "title": a.title, "text": _phrase(a, reported, echo), "band": rb})
		if rb > worst_band and a.id != "dorn":
			worst_band = rb
			worst_idx = reports.size() - 1
	# Kâhya: güçlüyse kötü haberi odana ulaştırmayabilir.
	if dorn != null and not dorn.moved and worst_band >= 1 and worst_idx >= 0:
		if rng.randf() < clampf(0.15 + dorn.power / 250.0 + dorn.ambition / 400.0, 0.0, 0.7):
			var dropped: Dictionary = reports[worst_idx]
			reports.remove_at(worst_idx)
			truth_log.append({"week": week, "name": "Alaric Dorn", "said": "(kötü haberi sana iletmedi)",
				"truth": "%s: %s" % [dropped["name"], dropped["text"]], "diff": 2})


func _phrase(a: Actor, value: float, echo: float) -> String:
	if echo > 0.75:
		return "Majesteleri, her şey kontrol altında ve sizin liderliğinizde yolunda gidiyor."
	var band := _band(a, value)
	match a.domain:
		"army":
			return ["Birlikler emirlere hazır, moral yüksek.", "Subaylar arasında huzursuz mırıltılar var, ama disiplin sürüyor.", "Bazı birlikler emirleri geciktiriyor. Gençler konuşuyor."][band]
		"intel":
			return ["Dosyalarda olağanüstü bir şey yok.", "Sokakta ve muhalefette hareketlenme izliyoruz.", "Gizli görüşmeler artıyor. Tehdit gerçek olabilir."][band]
		"economy":
			return ["Büyüme sağlıklı, enflasyon kontrolde.", "Fiyatlar yükseliyor; bazı sektörler zorlanıyor.", "Bütçe açığı büyüyor. Müdahale gerekebilir."][band]
		"media":
			return ["Halk sizden memnun, manşetler olumlu.", "Kamuoyu kararsız; doğru haber akışı gerekir.", "Anlatıyı kaybediyoruz. Bana güvenmeniz gerek."][band]
		"press":
			return ["Sokakta sakin bir hava var.", "İnsanlar daha çok soru soruyor.", "Halk öfkeli ve artık korkmuyor."][band]
		"gate":
			return ["Saray sakin; kimse sizi rahatsız etmek istemiyor.", "Bazı heyetler randevu istiyor, ben ertelemeyi tercih ettim.", "Bazı haberleri size ulaştırmamayı doğru buldum."][band]
		"royal":
			return ["Prens törenlerde sessiz ve uyumlu.", "Prens soylularla sık yemek yiyor; sebebini bilmiyoruz.", "Prensin çevresinde hazırlık var. Taht konuşuluyor."][band]
		"opposition":
			return ["Muhalefet dağınık, sesi cılız.", "Muhalefet kanatları arasında gizli görüşmeler sürüyor.", "Muhalefet birleşiyor; sokakla koordinasyon başladı."][band]
		"court":
			return ["Mahkemeler olağan işleyişinde.", "Bazı dosyalar yargıda beklenenden hızlı ilerliyor.", "Yargı saraya yaklaşıyor; savcılar sabırsız."][band]
	return "…"


func _add_fact(id: String, text: String, subject: String, severity: float, knowers: Array, copies: int, leakiness: float = 0.5) -> void:
	facts[id] = {"id": id, "text": text, "subject": subject, "severity": severity,
		"knowers": knowers.duplicate(), "common": 0.0, "copies": copies, "leakiness": leakiness}
