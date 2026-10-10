extends RefCounted
## Sabit metinlerden rapor, alamet ve tarihçi anlatısı kurar.
const Actor := preload("res://game/core/actor.gd")
const Loc := preload("res://game/core/loc.gd")
var sim: Node
var week: int:
	get: return sim.week
var economy: float:
	get: return sim.economy
var unrest: float:
	get: return sim.unrest
var flags: Dictionary:
	get: return sim.flags
var stats: Dictionary:
	get: return sim.stats
var facts: Dictionary:
	get: return sim.facts
var actors: Dictionary:
	get: return sim.actors
var rng: RandomNumberGenerator:
	get: return sim.rng
var PHRASES: Dictionary:
	get: return sim.REPORT_CONTENT["phrases"]
var SIGN_TEXTS: Dictionary:
	get: return sim.REPORT_CONTENT["sign_texts"]
var HISTORY: Dictionary:
	get: return sim.HISTORY_CONTENT
var _signs_tr: Dictionary = {}
var _signs_en: Dictionary = {}
var _signs_en_root: Dictionary = {}
var REPORT: Dictionary:
	get: return sim.REPORT_CONTENT
var KING_NAME: String:
	get: return sim.KING_NAME

func _init(host: Node) -> void:
	sim = host

func echo_level() -> float:
	return sim.echo_level()

func _band(a: Actor, value: float) -> int:
	return sim._band(a, value)

func short_name(a: Actor) -> String:
	return sim.short_name(a)

func ek(name: String, kind: String) -> String:
	return sim.ek(name, kind)

## İki taraflı tarih: aynı saltanatı saray tarihçisi ve sürgündeki tarihçi farklı yazar.
func historians(survived: bool) -> Array:
	var weeks := week - 1
	var pro: Array[String] = []
	var con: Array[String] = []
	if survived:
		pro.append(tr(str(HISTORY["pro_survived"])) % KING_NAME)
	else:
		pro.append(tr(str(HISTORY["pro_lost"])) % [KING_NAME, weeks])
	if economy >= 55.0:
		pro.append(tr(str(HISTORY["pro_economy"])))
	if flags.has("kessler_reform_0"):
		pro.append(tr(str(HISTORY["pro_reform"])))
	if unrest < 35.0:
		pro.append(tr(str(HISTORY["pro_peace"])))
	if int(stats.get("kept", 0)) > 0:
		pro.append(tr(str(HISTORY["pro_kept"])) % int(stats.get("kept", 0)))
	if flags.has("tac_giyme_2") or flags.has("yildonumu_0"):
		pro.append(tr(str(HISTORY["pro_public"])))
	if flags.has("halef_karari_0"):
		pro.append(tr(str(HISTORY["pro_constitution"])))
	elif flags.has("halef_karari_1"):
		pro.append(tr(str(HISTORY["pro_heir"])))
	if pro.size() == 1:
		pro.append(tr(str(HISTORY["pro_default"])))
	var public_secrets := 0
	for f: Dictionary in facts.values():
		if f["subject"] == "king" and f.get("public", false):
			public_secrets += 1
	if public_secrets > 0:
		con.append(tr(str(HISTORY["con_secrets"])) % public_secrets)
	if int(stats.get("bribes", 0)) >= 2:
		con.append(tr(str(HISTORY["con_bribes"])) % int(stats.get("bribes", 0)))
	if int(stats.get("blackmails", 0)) > 0:
		con.append(tr(str(HISTORY["con_blackmail"])))
	if int(stats.get("broken", 0)) > 0:
		con.append(tr(str(HISTORY["con_broken"])) % int(stats.get("broken", 0)))
	if flags.has("GAZETECI_SUSTURULDU") or flags.has("gazeteci_ihale_1"):
		con.append(tr(str(HISTORY["con_press"])))
	if flags.has("muhalefet_birlesme_2"):
		con.append(tr(str(HISTORY["con_opposition"])))
	if economy < 35.0:
		con.append(tr(str(HISTORY["con_economy"])))
	if echo_level() > 0.7:
		con.append(tr(str(HISTORY["con_echo"])))
	if flags.has("halef_karari_2"):
		con.append(tr(str(HISTORY["con_lock"])))
	if con.is_empty():
		con.append(tr(str(HISTORY["con_default"])))
	return [" ".join(pro), " ".join(con)]


func _sign_text(a: Actor, st: int) -> String:
	return str(_sign_text_pair(a, st)["en" if Loc.lang == "en" else "tr"])


func _sign_text_pair(a: Actor, st: int) -> Dictionary:
	if _signs_tr.is_empty():
		var base: Variant = sim._content_loader._read("res://game/data/content_reports.json")
		var english: Variant = sim._content_loader._read("res://game/data/en/content_reports.json")
		_signs_tr = base.get("sign_texts", {}) if base is Dictionary else {}
		_signs_en = english.get("sign_texts", {}) if english is Dictionary else {}
		_signs_en_root = english if english is Dictionary else {}
	var by: Dictionary = _signs_tr[str(st)]
	var domain := a.domain
	var pool: Array = by.get(domain, [])
	if pool.is_empty() or rng.randf() < 0.35:
		domain = "_"
		pool = by["_"]
	var index := rng.randi() % pool.size()
	var tr_t: String = pool[index]
	var en_pool: Array = (_signs_en.get(str(st), {}) as Dictionary).get(domain, pool)
	var en_t: String = en_pool[index] if index < en_pool.size() else Loc.en(tr_t)
	var nm := short_name(a)
	var tr_nm := _short_name_tr(a)
	var partner := ""
	var tr_partner := ""
	for o: Actor in actors.values():
		if o != a and o.ready and o.insider and not o.moved:
			partner = short_name(o)
			tr_partner = _short_name_tr(o)
	return {"tr": _fill_sign(tr_t, tr_nm, tr_partner, false), "en": _fill_sign(en_t, nm, partner, true)}


func _fill_sign(text: String, name: String, partner: String, english: bool) -> String:
	var unknown_en := "an unknown delegation"
	if english and _signs_en_root.has("unknown_partner"):
		unknown_en = str(_signs_en_root["unknown_partner"])
	var p_e: String = (partner if partner != "" else unknown_en) if english else (sim.ek_tr(partner, "e") if partner != "" else str(REPORT["unknown_partner"]))
	var n_in: String = Loc.poss(name) if english else sim.ek_tr(name, "in")
	var n_case: String = name if english else ""
	var filled := text.replace("{n_in}", n_in).replace("{n_e}", n_case if english else sim.ek_tr(name, "e")).replace("{n_i}", n_case if english else sim.ek_tr(name, "i")).replace("{p_e}", p_e).replace("{n}", name)
	if english and filled != "":
		filled = filled.substr(0, 1).to_upper() + filled.substr(1)   # "the Prince ..." cümle başında büyük harf
	return filled


func _short_name_tr(a: Actor) -> String:
	if a.id == "prens": return "Prens"
	var names := {"dorn": "Helena", "kessler": "Veyra", "halden": "Sarne", "lena": "Sarn", "brandt": "Voss", "falk": "Renn"}
	return str(names.get(a.id, short_name(a)))


func _phrase(a: Actor, value: float, echo: float) -> String:
	if echo > 0.75:
		# Yankı odası: korku herkesin aynı cümleyi kurmasına yol açar. Bu tekdüzelik bir ipucudur.
		return str(REPORT["echo"])
	var band := _band(a, value)
	if not PHRASES.has(a.domain):
		return str(REPORT["unknown_phrase"])
	var variants: Array = PHRASES[a.domain][band]
	return variants[absi(("%s%d" % [a.id, week]).hash()) % variants.size()]
