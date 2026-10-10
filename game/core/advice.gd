extends RefCounted
## Meclis görüşlerinin davranışı. Sim dış API'yi korur; metin tabloları JSON'dan gelir.
const Actor := preload("res://game/core/actor.gd")
const Loc := preload("res://game/core/loc.gd")
var sim: Node
var content: Dictionary:
	get: return sim.COUNCIL_CONTENT
var actors: Dictionary:
	get: return sim.actors
var pending: Array:
	get: return sim.pending
var week: int:
	get: return sim.week
var rng: RandomNumberGenerator:
	get: return sim.rng
var advice_log: Array:
	get: return sim.advice_log

func _init(host: Node) -> void:
	sim = host

func _as_array(value: Variant) -> Array:
	return sim._as_array(value)

func _find_promise(pid: String) -> Dictionary:
	return sim._find_promise(pid)

func echo_level() -> float:
	return sim.echo_level()

func _diff(key: String) -> float:
	return sim._diff(key)

func ek(name: String, kind: String) -> String:
	return sim.ek(name, kind)

## Tasarım: docs/design/danisman_gorusleri.md
## Her karar kartında iki danışman bir seçenek önerir. Görüş gerçek etkiden türetilir; ama danışmanın
## çıkarı, uzmanlığı, korkusu ve gizli niyeti onu büker. Gerekçe hep doğrudur, yalnızca seçicidir.

const ADVICE_SIGMA := 10.0           # yanılma payı: σ = SIGMA·(1−yetkinlik); seçenek değerlerinin sd'si ~5
const ADVICE_SKILL_EXPERT := 0.5
const ADVICE_SKILL_SECOND := 0.35
const ADVICE_SKILL_GENERAL := 0.15
const ADVICE_W0 := 0.4               # kişisel çıkar ağırlığı: W0 + hırs·(1−dürüstlük)·W1
const ADVICE_W1 := 6.0
const ADVICE_W_MAX := 2.0
const ADVICE_K_READY := -0.4         # darbeye hazır olan kralın zararına önerir
const ADVICE_FEAR_EVASIVE := 60.0    # bu korkunun üstünde kaçamak konuşur
const ADVICE_WARN_GAP := 6.0
const ADVICE_FLAT_GAP := 1.5
const ADVICE_MISLEAD_GAP := 4.0
const ADVICE_STAKE_MIN := 1.0        # "ÇIKARI VAR" için en küçük doğrudan pay
const ADVICE_LOYALTY_VALUE := 0.3    # sadakat isyan eğilimini düşürür: kral için değerlidir
## Uzman eşleşmeleri ve gerekçe söyleyişleri `content_council.json` içindedir.

## Kralın çıkarı açısından bir seçeneğin değeri (tek doğruluk kaynağı; botlar da bunu kullanır).
func choice_value(fx: Dictionary) -> float:
	var s := 0.0
	for v in _value_terms(fx).values():
		s += float(v)
	return s


## choice_value'nun terimleri: boyut -> katkı. Kişi terimleri "actor:<id>" anahtarıyla.
func _value_terms(fx: Dictionary) -> Dictionary:
	var t := {}
	if fx.has("king"):
		t["king"] = 2.0 * float(fx["king"])
	if fx.has("unrest"):
		t["unrest"] = -float(fx["unrest"])
	if fx.has("economy"):
		t["economy"] = 0.7 * float(fx["economy"])
	if fx.has("opp"):
		t["opp"] = -0.5 * float(fx["opp"])
	if fx.has("wealth"):
		t["wealth"] = 0.3 * float(fx["wealth"])
	if fx.has("treasury"):
		t["treasury"] = 0.25 * float(fx["treasury"])
	if fx.has("capacity"):
		for institution in fx["capacity"]:
			t["capacity:" + str(institution)] = 0.3 * float(fx["capacity"][institution])
	if fx.has("holding"):
		t["holding"] = -0.1 * float(fx["holding"])
	if fx.has("budget_stance"):
		# Bir çeyreklik kasa, kurum ve sokak etkisinin kaba karşılığı.
		t["treasury"] = float(t.get("treasury", 0.0)) - 2.9 * float(fx["budget_stance"])
		t["capacity:maliye"] = float(t.get("capacity:maliye", 0.0)) + 3.6 * float(fx["budget_stance"])
	if fx.get("court_share", false):
		t["wealth"] = float(t.get("wealth", 0.0)) + 2.3
		t["treasury"] = float(t.get("treasury", 0.0)) - 2.0
		t["fact"] = -3.0
	var af: Dictionary = fx.get("actors", {})
	for aid in af:
		var d: Dictionary = af[aid]
		var c := -(float(d.get("power", 0)) * 0.3 + float(d.get("ambition", 0)) * 0.4 + float(d.get("obligation", 0)) * 0.3)
		for prop in d:
			if str(prop).begins_with("l_"):
				c += float(d[prop]) * ADVICE_LOYALTY_VALUE
		if c != 0.0:
			t["actor:" + str(aid)] = c
	if fx.has("fact"):
		t["fact"] = -3.0
	if fx.has("promise_break"):
		t["promise"] = -5.0
	return t


## Danışmanın bu seçenekteki doğrudan payı (rakiplerin güçlenmesi hariç).
func _direct_stake(a: Actor, fx: Dictionary) -> float:
	var s := 0.0
	var mine: Dictionary = fx.get("actors", {}).get(a.id, {})
	for prop in mine:
		var d := float(mine[prop])
		if prop == "power":
			s += d
		elif str(prop).begins_with("l_"):
			s += d * 0.6
		elif prop == "obligation":
			s += d * 0.5
		elif prop == "fear":
			s -= d * 0.6
	if fx.has("fact") and a.id in _as_array(fx["fact"].get("knowers", [])):
		s += 3.0 * a.ambition / 50.0
	if a.id in _as_array(fx.get("remove", [])):
		s -= 40.0
	for key in ["promise_keep", "promise_break"]:
		if fx.has(key):
			var p := _find_promise(str(fx[key]))
			if not p.is_empty() and p["actor"] == a.id:
				s += 12.0 if key == "promise_keep" else -15.0
	return s


func _self_interest(a: Actor, fx: Dictionary) -> float:
	var s := _direct_stake(a, fx)
	var af: Dictionary = fx.get("actors", {})
	for aid in af:
		if aid != a.id and actors.has(aid) and actors[aid].insider:
			s -= maxf(0.0, float(af[aid].get("power", 0))) * 0.25
	return s


## Olayın baskın boyutları, ağırlığa göre azalan sırada.
func _event_dims(e: Dictionary) -> Array:
	var w := {}
	for ch: Dictionary in e["choices"]:
		var t := _value_terms(ch.get("fx", {}))
		for k: String in t:
			var dim := "actors" if k.begins_with("actor:") else ("capacity" if k.begins_with("capacity:") else k)
			w[dim] = float(w.get(dim, 0.0)) + absf(float(t[k]))
	var dims: Array = w.keys().filter(func(k: String) -> bool: return content["experts"].has(k))
	dims.sort_custom(func(x: String, y: String) -> bool: return w[x] > w[y])
	return dims


func _can_advise(aid: String) -> bool:
	return actors.has(aid) and actors[aid].insider and not actors[aid].moved


## İki danışman: biri kararda taraf olan, diğeri olayın baskın alanının uzmanı.
func _pick_advisors(e: Dictionary) -> Array:
	var out: Array = []
	if e.get("crisis", false):
		return out  # krizde meclis susar
	for aid in _as_array(e.get("advisors", [])):
		if _can_advise(aid) and not aid in out:
			out.append(aid)
	var party := ""
	var party_s := 0.0
	for aid: String in actors:
		if not _can_advise(aid) or aid in out:
			continue
		var m := 0.0
		for ch: Dictionary in e["choices"]:
			m = maxf(m, absf(_direct_stake(actors[aid], ch.get("fx", {}))))
		if m >= ADVICE_STAKE_MIN and (party == "" or m > party_s or (m == party_s and actors[aid].power > actors[party].power)):
			party = aid
			party_s = m
	if party != "" and out.size() < 2:
		out.append(party)
	for dim in _event_dims(e):
		for aid in content["experts"][dim]:
			if out.size() < 2 and _can_advise(aid) and not aid in out:
				out.append(aid)
	if out.size() < 2:
		for aid in ["dorn", "kessler", "voss", "falk", "arden", "prens", "halden"]:
			if out.size() < 2 and _can_advise(aid) and not aid in out:
				out.append(aid)
	return out


func _advisor_skill(aid: String, e: Dictionary) -> float:
	var dims := _event_dims(e)
	if dims.is_empty():
		return ADVICE_SKILL_GENERAL
	var ex: Array = content["experts"][dims[0]]
	if aid == ex[0]:
		return ADVICE_SKILL_EXPERT
	if aid == ex[1]:
		return ADVICE_SKILL_SECOND
	return ADVICE_SKILL_GENERAL


## Kısa hitap adı: "General Arden" -> "Arden", "Prens Marcus" -> "Prens".
func short_name(a: Actor) -> String:
	if a.short != "":
		return a.short
	return tr("Prens") if a.royal else a.display_name.split(" ")[-1]


## Bir kart için meclis görüşleri (tembel üretilir, pending içinde saklanır: kayıtta ve yüklemede değişmez).
## Öğe: {actor, kind: rec|flat|evasive, rec, warn, text, stake}
func advice_for(pending_index: int) -> Array:
	if pending_index < 0 or pending_index >= pending.size():
		return []
	var p: Dictionary = pending[pending_index]
	if p.has("advice"):
		return p["advice"]
	var e: Dictionary = p["event"]
	var out: Array = []
	var born := week - int(p.get("age", 0))
	for aid: String in _pick_advisors(e):
		var a: Actor = actors[aid]
		# Ana rng'ye dokunmaz: görüşe bakmayan oyunun simülasyonu birebir aynı kalır.
		var r := RandomNumberGenerator.new()
		r.seed = hash("%d|%s|%d|%s" % [rng.seed, e["id"], born, aid])
		out.append(_advise(a, e, r))
	p["advice"] = out
	return out


func _advise(a: Actor, e: Dictionary, r: RandomNumberGenerator) -> Dictionary:
	var choices: Array = e["choices"]
	var item := {"actor": a.id, "kind": "rec", "rec": -1, "warn": -1, "text": "", "stake": false}
	for ch: Dictionary in choices:
		if absf(_direct_stake(a, ch.get("fx", {}))) >= ADVICE_STAKE_MIN:
			item["stake"] = true
	if a.fear >= ADVICE_FEAR_EVASIVE or echo_level() > 0.75:
		item["kind"] = "evasive"
		item["text"] = tr(str(content["evasive"][r.randi() % content["evasive"].size()]))
		return item
	var sigma := ADVICE_SIGMA * (1.0 - _advisor_skill(a.id, e)) * _diff("advice_noise")
	var w := clampf(ADVICE_W0 + a.ambition / 100.0 * (1.0 - a.honesty) * ADVICE_W1, 0.0, ADVICE_W_MAX)
	var k := ADVICE_K_READY if a.ready else 1.0
	var scores: Array[float] = []
	var available: Array[int] = []
	for ch: Dictionary in choices:
		var fx: Dictionary = ch.get("fx", {})
		scores.append(k * (choice_value(fx) + r.randfn(0.0, sigma)) + w * _self_interest(a, fx))
		if ch.get("available", true):
			available.append(scores.size() - 1)
	var best := available[0]
	var worst := available[0]
	for i in available:
		if scores[i] > scores[best]:
			best = i
		if scores[i] < scores[worst]:
			worst = i
	if scores[best] - scores[worst] < ADVICE_FLAT_GAP:
		item["kind"] = "flat"
		item["text"] = tr(str(content["flat"][r.randi() % content["flat"].size()]))
		return item
	item["rec"] = best
	var reason := _advice_reason(choices[best].get("fx", {}), true, r, a.id)
	var text := ""
	match r.randi() % 3:
		0:
			text = tr(str(content["rec_forms"][0])) % (content["roman"][mini(best, 3)] if Loc.lang == "en" else content["roman_acc"][mini(best, 3)])
		1:
			text = tr(str(content["rec_forms"][1])) % content["roman"][mini(best, 3)]
		_:
			text = tr(str(content["rec_forms"][2])) % (content["roman"][mini(best, 3)] if Loc.lang == "en" else content["roman_acc"][mini(best, 3)])
	text = tr("%s: %s.") % [text, reason] if reason != "" else tr("%s. %s") % [text, tr(str(content["cover"].get(a.id, content["cover_default"])))]
	if scores[best] - scores[worst] >= ADVICE_WARN_GAP:
		var bad := _advice_reason(choices[worst].get("fx", {}), false, r, a.id)
		if bad != "":
			item["warn"] = worst
			text = tr("%s %s ise %s.") % [text, content["roman"][mini(worst, 3)], bad]
	item["text"] = text
	if e.get("kind", "") == "patronage" and a.id == "dorn":
		item["text"] += " " + tr("Gazeteler ona bağlı, Majesteleri.")
	return item


## Seçeneğin kral için en olumlu (good=true) ya da en olumsuz gerçek etkisini anlatan parça. Yoksa "".
## Danışman kendinden söz etmez (self).
func _advice_reason(fx: Dictionary, good: bool, r: RandomNumberGenerator, self_id: String) -> String:
	var t := _value_terms(fx)
	t.erase("actor:" + self_id)
	var key := ""
	var val := 0.0
	for k: String in t:
		var v := float(t[k])
		if (good and v > val) or (not good and v < val):
			key = k
			val = v
	if key == "":
		return ""
	if key.begins_with("actor:"):
		var aid := key.substr(6)
		var nm: String = short_name(actors[aid]) if actors.has(aid) else _missing_actor_name(aid)
		var forms: Array = content["actor_good"] if good else content["actor_bad"]
		var line: String = tr(str(forms[r.randi() % forms.size()]))
		return line.replace("{n_in}", Loc.poss(nm) if Loc.lang == "en" else ek(nm, "in")).replace("{n_i}", nm if Loc.lang == "en" else ek(nm, "i"))
	if key.begins_with("capacity:"):
		key = "capacity"
	var opts: Array = content["reasons"][key][0 if good else 1]
	return tr(str(opts[r.randi() % opts.size()]))


func _missing_actor_name(aid: String) -> String:
	var names := {"falk": "Sophia Renn", "kessler": "Selin Veyra", "halden": "Victor Sarne", "brandt": "Adrian Voss", "lena": "Leyla Sarn", "dorn": "Queen Helena"}
	return str(names.get(aid, aid.capitalize()))


func _log_advice(e: Dictionary, advice: Array, chosen: int) -> void:
	var choices: Array = e["choices"]
	var best := 0
	for i in choices.size():
		if choices[i].get("available", true) and (not choices[best].get("available", true) or choice_value(choices[i].get("fx", {})) > choice_value(choices[best].get("fx", {}))):
			best = i
	for it: Dictionary in advice:
		var rec := int(it["rec"])
		if rec < 0:
			continue
		var a: Actor = actors.get(it["actor"])
		advice_log.append({"w": week, "event": e["title"], "actor": it["actor"],
			"name": a.display_name if a else str(it["actor"]), "followed": rec == chosen,
			"rec": str(choices[rec]["label"]), "best": str(choices[best]["label"]),
			"gap": snappedf(choice_value(choices[best].get("fx", {})) - choice_value(choices[rec].get("fx", {})), 0.1)})


## Oyun sonu: her danışmanın sicili, en çok yanıltandan başlayarak.
func council_record() -> Array:
	var per := {}
	for l: Dictionary in advice_log:
		var c: Dictionary = per.get(l["actor"], {"name": l["name"], "given": 0, "followed": 0, "misled": 0, "cost": 0.0, "worst": {}})
		c["given"] += 1
		if l["followed"]:
			c["followed"] += 1
		if float(l["gap"]) >= ADVICE_MISLEAD_GAP:
			c["misled"] += 1
			if l["followed"]:
				c["cost"] += float(l["gap"])
			if c["worst"].is_empty() or float(l["gap"]) > float(c["worst"]["gap"]):
				c["worst"] = l
		per[l["actor"]] = c
	var out: Array = per.values()
	out.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		if x["misled"] != y["misled"]:
			return x["misled"] > y["misled"]
		return x["given"] > y["given"])
	return out
