extends RefCounted
## Sabit metinlerden rapor, alamet ve tarihçi anlatısı kurar.
const Actor := preload("res://game/core/actor.gd")
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
		pro.append(HISTORY["pro_survived"] % KING_NAME)
	else:
		pro.append(HISTORY["pro_lost"] % [KING_NAME, weeks])
	if economy >= 55.0:
		pro.append(HISTORY["pro_economy"])
	if flags.has("kessler_reform_0"):
		pro.append(HISTORY["pro_reform"])
	if unrest < 35.0:
		pro.append(HISTORY["pro_peace"])
	if int(stats.get("kept", 0)) > 0:
		pro.append(HISTORY["pro_kept"] % int(stats.get("kept", 0)))
	if flags.has("tac_giyme_2") or flags.has("yildonumu_0"):
		pro.append(HISTORY["pro_public"])
	if flags.has("halef_karari_0"):
		pro.append(HISTORY["pro_constitution"])
	elif flags.has("halef_karari_1"):
		pro.append(HISTORY["pro_heir"])
	if pro.size() == 1:
		pro.append(HISTORY["pro_default"])
	var public_secrets := 0
	for f: Dictionary in facts.values():
		if f["subject"] == "king" and f.get("public", false):
			public_secrets += 1
	if public_secrets > 0:
		con.append(HISTORY["con_secrets"] % public_secrets)
	if int(stats.get("bribes", 0)) >= 2:
		con.append(HISTORY["con_bribes"] % int(stats.get("bribes", 0)))
	if int(stats.get("blackmails", 0)) > 0:
		con.append(HISTORY["con_blackmail"])
	if int(stats.get("broken", 0)) > 0:
		con.append(HISTORY["con_broken"] % int(stats.get("broken", 0)))
	if flags.has("GAZETECI_SUSTURULDU") or flags.has("gazeteci_ihale_1"):
		con.append(HISTORY["con_press"])
	if flags.has("muhalefet_birlesme_2"):
		con.append(HISTORY["con_opposition"])
	if economy < 35.0:
		con.append(HISTORY["con_economy"])
	if echo_level() > 0.7:
		con.append(HISTORY["con_echo"])
	if flags.has("halef_karari_2"):
		con.append(HISTORY["con_lock"])
	if con.is_empty():
		con.append(HISTORY["con_default"])
	return [" ".join(pro), " ".join(con)]


func _sign_text(a: Actor, st: int) -> String:
	var by: Dictionary = SIGN_TEXTS[str(st)]
	var pool: Array = by.get(a.domain, [])
	if pool.is_empty() or rng.randf() < 0.35:
		pool = by["_"]
	var t: String = pool[rng.randi() % pool.size()]
	var nm := short_name(a)
	var partner := ""
	for o: Actor in actors.values():
		if o != a and o.ready and o.insider and not o.moved:
			partner = short_name(o)
	var p_e := ek(partner, "e") if partner != "" else str(REPORT["unknown_partner"])
	return t.replace("{n_in}", ek(nm, "in")).replace("{n_e}", ek(nm, "e")).replace("{n_i}", ek(nm, "i")).replace("{p_e}", p_e).replace("{n}", nm)


func _phrase(a: Actor, value: float, echo: float) -> String:
	if echo > 0.75:
		# Yankı odası: korku herkesin aynı cümleyi kurmasına yol açar. Bu tekdüzelik bir ipucudur.
		return str(REPORT["echo"])
	var band := _band(a, value)
	if not PHRASES.has(a.domain):
		return str(REPORT["unknown_phrase"])
	var variants: Array = PHRASES[a.domain][band]
	return variants[absi(("%s%d" % [a.id, week]).hash()) % variants.size()]
