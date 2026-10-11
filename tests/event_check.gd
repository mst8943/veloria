extends SceneTree
## Olay verisi doğrulayıcısı (events.json). Olay motoru bilinmeyen anahtarları ve yanlış yazılmış
## aktör özelliklerini sessizce yok sayar; yanlış bir bayrak adı olayın hiç tetiklenmemesine yol açar.
## Bunları içerik eklenirken yakalar.
##   Godot_console.exe --headless --path . --script res://tests/event_check.gd [-- --file=<yol>]
## Sonda "EVENTS: OK" ya da "EVENTS: FAIL"; hata varsa çıkış kodu 1. Görseli eksik olay yalnızca uyarıdır.

const EVENTS_PATH := "res://game/data/events.json"
const ACTORS_PATH := "res://game/data/actors.json"
const ACTOR := preload("res://game/core/actor.gd")
const ContentData := preload("res://game/core/content_data.gd")
const Loc := preload("res://game/core/loc.gd")

const TOP_KEYS := ["id", "title", "text", "choices", "ignore", "fx", "art", "crisis", "crisis_kind", "banner", "rng_pool", "scripted_only", "advisors",
	"min_week", "max_week", "chance", "once", "cooldown", "min_unrest", "max_unrest", "min_economy", "max_economy",
	"min_opposition", "min_power", "min_cap", "max_cap", "min_treasury", "max_treasury", "min_holding", "max_holding", "min_heir", "max_heir", "min_foreign", "max_foreign", "min_ext_pressure", "needs_hostile", "needs_moved", "needs_flag", "blocks_flag", "any_flag", "flag_age", "actor_min", "actor_max",
	"alive", "needs_fact", "needs_ready", "min_stat", "max_stat", "news", "actor", "tone"]
## Sim.stats anahtarları (min_stat / max_stat koşulları)
const STAT_KEYS := ["ops", "bribes", "promotes", "leaks", "dismissals", "written", "hints", "checks",
	"investigations", "blackmails", "promises", "kept", "broken", "summons", "concessions", "street_concessions", "legal_concessions", "rivalries",
	"sadik_maliye", "sadik_hukuk", "sadik_ordu", "sadik_idare", "liyakatli_maliye", "liyakatli_hukuk", "liyakatli_ordu", "liyakatli_idare"]
const CAP_KEYS := ["maliye", "hukuk", "ordu", "idare"]
const FOREIGN_KEYS := ["asteria", "drakon", "seravia"]
const FX_KEYS := ["king", "unrest", "economy", "opp", "wealth", "treasury", "holding", "foreign", "capacity", "budget_stance", "court_share", "actors", "fact", "flag", "leak", "remove",
	"promise_keep", "promise_break", "promise_delay"]
const FX_NUMBERS := ["king", "unrest", "economy", "opp", "wealth", "treasury", "holding"]
const FACT_KEYS := ["id", "text", "subject", "severity", "knowers"]
## Oyun kodunun (sim.gd) kendisinin koyduğu bayraklar; <AKTÖR>_GITTI, _GUCLENDI, HUZUR_<AKTÖR> kalıpları ayrıca.
const CODE_FLAGS := ["DARBE_BASTIRILDI", "DARBE_HALK", "DARBE_TAVIZ",
	"REJIM_GUVENLIKCI", "REJIM_POPULIST", "REJIM_PATRONAJCI", "REJIM_OLIGARK", "REJIM_MEDYA", "REJIM_ISTIHBARAT",
	"KADRO_SADIK_ORDU", "KADRO_LIYAKATLI_HUKUK", "KADRO_LIYAKATLI_IDARE", "HALDEN_SAVCI_SIZDI", "SARAY_PAYI_BASLADI", "VELIAHT_YETISTI", "DOGRULA_ELENA", "HEYET_GONDER", "SUIKAST_ATLATILDI"]
const PATRONAGE_FLAGS := ["halden_ihale_0", "halden_ihale_1", "halden_ihale_2", "halden_fatura_0", "halden_fatura_1", "halden_fatura_2"]

var errors: Array[String] = []
var warnings: Array[String] = []
var actor_ids: Array = []
var loyalty_keys: Array = []
var actor_props: Array = []
var event_ids := {}       # id -> seçenek sayısı
var set_flags := {}       # fx.flag ile konan bayraklar
var fact_ids := {"liman_komisyonu": true}  # bu sır artık talep kartında üretilir


func _init() -> void:
	var events_path := EVENTS_PATH
	var language := "tr"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--file="):
			events_path = arg.substr(7)   # doğrulayıcının kendisini sınamak için başka bir dosya
		elif arg == "--lang=en":
			language = "en"
	Loc.set_lang(language)
	var loader := ContentData.new()
	var actors: Variant = loader.load_actors()
	var events: Variant = loader.load_events(events_path) if events_path == EVENTS_PATH else _load(events_path)
	if not actors is Array or not events is Array:
		print("EVENTS: FAIL (dosya okunamadı ya da dizi değil)")
		quit(1)
		return
	for a: Dictionary in actors:
		actor_ids.append(str(a["id"]))
		for k in a.get("loyalty", {}):
			if not k in loyalty_keys:
				loyalty_keys.append(k)
	var probe: RefCounted = ACTOR.new()
	for p in probe.get_property_list():
		if p["type"] in [TYPE_FLOAT, TYPE_INT]:
			actor_props.append(str(p["name"]))
	# 1. geçiş: kimlikler, konulan bayraklar, üretilen sırlar
	for e: Dictionary in events:
		var id := str(e.get("id", ""))
		if id == "":
			errors.append("Kimliksiz olay: %s" % str(e.get("title", "?")))
			continue
		if event_ids.has(id):
			errors.append("%s: aynı kimlik iki kez" % id)
		event_ids[id] = (e.get("choices", []) as Array).size()
		for fx in _all_fx(e):
			if fx.has("flag"):
				set_flags[str(fx["flag"])] = true
			if fx.get("fact") is Dictionary:
				fact_ids[str(fx["fact"].get("id", ""))] = true
	# 2. geçiş: her olayı denetle
	for e: Dictionary in events:
		_check_event(e)
	for w in warnings:
		print("UYARI  ", w)
	for x in errors:
		print("HATA   ", x)
	if errors.is_empty():
		print("EVENTS: OK (%d olay, %d uyarı)" % [events.size(), warnings.size()])
		quit(0)
	else:
		print("EVENTS: FAIL (%d hata, %d uyarı)" % [errors.size(), warnings.size()])
		quit(1)


func _load(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(f.get_as_text()) if f else null


func _all_fx(e: Dictionary) -> Array:
	var out: Array = []
	if e.get("fx") is Dictionary:
		out.append(e["fx"])
	for c in e.get("choices", []):
		if c is Dictionary and c.get("fx") is Dictionary:
			out.append(c["fx"])
	if e.get("ignore") is Dictionary and e["ignore"].get("fx") is Dictionary:
		out.append(e["ignore"]["fx"])
	return out


func _check_event(e: Dictionary) -> void:
	var id := str(e.get("id", "?"))
	for k in e:
		if not k in TOP_KEYS:
			errors.append("%s: bilinmeyen anahtar '%s' (motor yok sayar)" % [id, k])
	for k in (["title", "text"] if e.has("choices") else ["title"]):
		if str(e.get(k, "")).strip_edges() == "":
			errors.append("%s: '%s' boş" % [id, k])
	if not e.has("choices"):
		# Seçeneksiz olay = aktör hamlesi: haber metni ve etki gerekir; seçenek/ignore/görsel yok.
		if str(e.get("news", "")).strip_edges() == "":
			errors.append("%s: seçeneksiz olayın 'news' metni yok (oyuncu hiç görmez)" % id)
		if not e.get("fx") is Dictionary:
			errors.append("%s: seçeneksiz olayın 'fx' etkisi yok" % id)
		else:
			_check_fx(id, e["fx"])
		if e.has("actor"):
			_check_actor(id, "actor", str(e["actor"]))
		if bool(e.get("once", true)) == false and not e.has("cooldown"):
			warnings.append("%s: tekrarlanan hamlenin cooldown'u yok (varsayılan 12)" % id)
		_check_conditions(e)
		return
	var choices: Array = e.get("choices", [])
	if choices.size() < 2:
		errors.append("%s: en az iki seçenek olmalı (%d var)" % [id, choices.size()])
	for i in choices.size():
		var c: Variant = choices[i]
		if not c is Dictionary:
			errors.append("%s: seçenek %d sözlük değil" % [id, i])
			continue
		for k in ["label", "text", "fx"]:
			if not c.has(k):
				errors.append("%s: seçenek %d '%s' eksik" % [id, i, k])
		for k in c:
			if not k in ["label", "text", "fx", "crisis"]:
				errors.append("%s: seçenek %d bilinmeyen anahtar '%s'" % [id, i, k])
	var ig: Variant = e.get("ignore")
	if not ig is Dictionary or not ig.has("text") or not ig.has("fx"):
		errors.append("%s: 'ignore' {text, fx} olmalı" % id)
	for fx in _all_fx(e):
		_check_fx(id, fx)
	_check_conditions(e)
	var art := "res://art/events/%s.png" % str(e.get("art", id))
	if not ResourceLoader.exists(art) and not FileAccess.file_exists(art):
		warnings.append("%s: görsel yok (%s), yer tutucu gösterilir" % [id, art.get_file()])


func _check_conditions(e: Dictionary) -> void:
	var id := str(e.get("id", "?"))
	if e.has("needs_hostile") and not e["needs_hostile"] is bool:
		errors.append("%s: needs_hostile doğru/yanlış olmalı" % id)
	for aid in _arr(e.get("needs_moved", [])):
		_check_actor(id, "needs_moved", str(aid))
	for k in ["min_treasury", "max_treasury", "min_holding", "max_holding", "min_heir", "max_heir"]:
		if e.has(k) and (not (e[k] is int or e[k] is float) or float(e[k]) < 0.0 or float(e[k]) > 100.0):
			errors.append("%s: %s 0–100 arası sayı olmalı" % [id, k])
	if e.has("min_heir") and e.has("max_heir") and float(e["min_heir"]) > float(e["max_heir"]):
		errors.append("%s: min_heir > max_heir, hiç tetiklenmez" % id)
	for k in ["min_foreign", "max_foreign"]:
		if not e.has(k):
			continue
		if not e[k] is Dictionary:
			errors.append("%s: %s dış güç sözlüğü olmalı" % [id, k])
			continue
		for power in e[k]:
			if not power in FOREIGN_KEYS:
				errors.append("%s: %s bilinmeyen dış güç '%s'" % [id, k, power])
			if not (e[k][power] is int or e[k][power] is float) or float(e[k][power]) < 0.0 or float(e[k][power]) > 100.0:
				errors.append("%s: %s.%s 0–100 arası sayı olmalı" % [id, k, power])
	for k in ["min_cap", "max_cap"]:
		if not e.has(k):
			continue
		if not e[k] is Dictionary:
			errors.append("%s: %s kurum sözlüğü olmalı" % [id, k])
			continue
		for institution in e[k]:
			if not institution in CAP_KEYS:
				errors.append("%s: %s bilinmeyen kurum '%s'" % [id, k, institution])
			if not (e[k][institution] is int or e[k][institution] is float) or float(e[k][institution]) < 5.0 or float(e[k][institution]) > 100.0:
				errors.append("%s: %s.%s 5–100 arası sayı olmalı" % [id, k, institution])
	if e.has("min_week") and e.has("max_week") and int(e["min_week"]) > int(e["max_week"]):
		errors.append("%s: min_week (%d) > max_week (%d), hiç tetiklenmez" % [id, int(e["min_week"]), int(e["max_week"])])
	if e.has("chance") and (float(e["chance"]) <= 0.0 or float(e["chance"]) > 1.0):
		errors.append("%s: chance 0 ile 1 arasında olmalı (%s)" % [id, str(e["chance"])])
	for k in ["min_power", "actor_min", "actor_max"]:
		for aid in e.get(k, {}):
			_check_actor(id, k, str(aid))
			if k != "min_power":
				for prop in e[k][aid]:
					_check_prop(id, k, str(prop))
	for aid in _arr(e.get("alive", [])):
		_check_actor(id, "alive", str(aid))
	for k in ["min_stat", "max_stat"]:
		for st in e.get(k, {}):
			if not st in STAT_KEYS:
				errors.append("%s: %s bilinmeyen istatistik '%s'" % [id, k, st])
	for fid in _arr(e.get("needs_fact", [])):
		if not fact_ids.has(str(fid)):
			errors.append("%s: needs_fact '%s' hiçbir olayda üretilmiyor, olay tetiklenmez" % [id, fid])
	var refs: Array = []
	for k in ["needs_flag", "blocks_flag", "any_flag"]:
		refs.append_array(_arr(e.get(k, [])))
	refs.append_array((e.get("flag_age", {}) as Dictionary).keys())
	for f in refs:
		if not _flag_known(str(f)):
			errors.append("%s: '%s' bayrağını hiçbir şey koymuyor (yazım hatası?)" % [id, f])


func _check_fx(id: String, fx: Dictionary) -> void:
	for k in fx:
		if not k in FX_KEYS:
			errors.append("%s: bilinmeyen etki '%s' (motor yok sayar)" % [id, k])
	for k in FX_NUMBERS:
		if fx.has(k) and not (fx[k] is float or fx[k] is int):
			errors.append("%s: etki '%s' sayı olmalı" % [id, k])
	if fx.has("capacity"):
		if not fx["capacity"] is Dictionary:
			errors.append("%s: capacity kurum sözlüğü olmalı" % id)
		else:
			for institution in fx["capacity"]:
				if not institution in CAP_KEYS or not (fx["capacity"][institution] is int or fx["capacity"][institution] is float):
					errors.append("%s: bilinmeyen kapasite etkisi '%s'" % [id, institution])
	if fx.has("foreign"):
		if not fx["foreign"] is Dictionary:
			errors.append("%s: foreign dış güç sözlüğü olmalı" % id)
		else:
			for power in fx["foreign"]:
				if not power in FOREIGN_KEYS or not (fx["foreign"][power] is int or fx["foreign"][power] is float):
					errors.append("%s: bilinmeyen dış ilişki etkisi '%s'" % [id, power])
	for aid in fx.get("actors", {}):
		_check_actor(id, "fx.actors", str(aid))
		for prop in fx["actors"][aid]:
			_check_prop(id, "fx.actors." + str(aid), str(prop))
	for aid in _arr(fx.get("remove", [])):
		_check_actor(id, "fx.remove", str(aid))
	if fx.has("fact"):
		var fd: Variant = fx["fact"]
		if not fd is Dictionary:
			errors.append("%s: fx.fact sözlük olmalı" % id)
			return
		for k in FACT_KEYS:
			if not fd.has(k):
				errors.append("%s: fx.fact '%s' eksik" % [id, k])
		var subj := str(fd.get("subject", ""))
		if subj != "king" and not subj in actor_ids:
			errors.append("%s: fx.fact.subject '%s' bilinmiyor" % [id, subj])
		for aid in _arr(fd.get("knowers", [])):
			_check_actor(id, "fx.fact.knowers", str(aid))
	for fid in _arr(fx.get("leak", [])):
		if not fact_ids.has(str(fid)):
			warnings.append("%s: fx.leak '%s' olaylarda üretilmiyor (kodda üretiliyorsa sorun yok)" % [id, fid])


func _check_actor(id: String, where: String, aid: String) -> void:
	if not aid in actor_ids:
		errors.append("%s: %s içinde bilinmeyen aktör '%s'" % [id, where, aid])


func _check_prop(id: String, where: String, prop: String) -> void:
	if prop.begins_with("l_"):
		if not prop.substr(2) in loyalty_keys:
			errors.append("%s: %s bilinmeyen sadakat türü '%s'" % [id, where, prop])
	elif not prop in actor_props:
		errors.append("%s: %s bilinmeyen aktör özelliği '%s' (motor sessizce yok sayar)" % [id, where, prop])


func _flag_known(f: String) -> bool:
	if set_flags.has(f) or f in CODE_FLAGS or f in PATRONAGE_FLAGS:
		return true
	if f.ends_with("_ertelendi") and event_ids.has(f.trim_suffix("_ertelendi")):
		return true
	for suffix in ["_GITTI", "_GUCLENDI"]:
		if f.ends_with(suffix) and f.trim_suffix(suffix).to_lower() in actor_ids:
			return true
	if f.begins_with("HUZUR_") and f.substr(6).to_lower() in actor_ids:
		return true
	# Seçim bayrağı: <olay_id>_<seçenek>
	var cut := f.rfind("_")
	if cut > 0 and f.substr(cut + 1).is_valid_int():
		var eid := f.substr(0, cut)
		return event_ids.has(eid) and int(f.substr(cut + 1)) < int(event_ids[eid])
	return false


func _arr(v: Variant) -> Array:
	if v is Array:
		return v
	return [] if v == null or str(v) == "" else [v]
