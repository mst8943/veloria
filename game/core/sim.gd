extends Node
## Veloria simülasyon çekirdeği (autoload: Sim).
## Gerçek dünya durumu burada tutulur; oyuncu yalnızca filtrelenmiş raporları görür.

signal week_advanced(week: int)
signal news(text: String)
signal changed()
signal game_ended(record: Dictionary)

const Actor := preload("res://game/core/actor.gd")
const Advice := preload("res://game/core/advice.gd")
const ContentData := preload("res://game/core/content_data.gd")
const Loc := preload("res://game/core/loc.gd")
const Narrative := preload("res://game/core/narrative.gd")
const Press := preload("res://game/core/press.gd")
const MAX_WEEKS := 104
const MESAI_PER_WEEK := 4
const KING_NAME := "Adrian IV"
const ACTORS_PATH := "res://game/data/actors.json"
const EVENTS_PATH := "res://game/data/events.json"
const CHRONICLE_PATH := "user://veloria_chronicle.txt"
const DAILY_PATH := "user://daily.cfg"
const LEGACY_PATH := "res://game/data/legacy.json"
const DYNASTY_PATH := "user://dynasty.cfg"
const DEFAULT_SAVE_PATH := "user://veloria_save.txt"
const EXTENSION_SAVE_PATH := "user://veloria_extension_save.txt"
const EXTENSION_ACHIEVEMENTS_PATH := "user://veloria_extension_achievements.txt"
var save_path := "user://veloria_save.txt"   # testler kendi dosyasını kullanır, oyuncunun kaydına dokunmaz
var dynasty_path := DYNASTY_PATH
var record_chronicle := true                 # testlerde ve otomatik oynatmada arşive yazılmaz
var autosave := true                         # her hafta sonunda otomatik kayıt
var timeline: Array = []                     # haftalık gerçek durum (oyun sonunda gösterilir)
const GOOD_DOMAINS_HIGH := ["economy"]  # bu alanlarda yüksek değer iyidir
## Zorluk: haftalık mesai, darbe koruma süresi, darbe için gereken güç payı, gelir, hazır olma eşiği,
## danışman gürültüsü, krizden kurtulma çarpanı, komplodan çekilme payı.
const DIFFICULTY := [
	{"name": "Kolay", "mesai": 5, "grace": 26, "coup_share": 0.74, "income": 1.2, "ready_drive": 44.0, "advice_noise": 0.9, "crisis_odds": 0.95, "leave_gap": 22.0},
	{"name": "Normal", "mesai": 4, "grace": 12, "coup_share": 0.66, "income": 1.0, "ready_drive": 39.0, "advice_noise": 1.2, "crisis_odds": 0.65, "leave_gap": 14.0},
	{"name": "Zor", "mesai": 4, "grace": 10, "coup_share": 0.63, "income": 0.8, "ready_drive": 36.0, "advice_noise": 1.25, "crisis_odds": 0.55, "leave_gap": 12.0},
]

## Vaat edilebilecek ödüller: her biri yalnızca bir kişiye gerçekten verilebilir.
var PRIZES: Array = []

var difficulty := 1
var mesai_max := MESAI_PER_WEEK
var promises: Array = []     # {id, actor, prize, made, due, delays, state, asked, exposed}
var _extra_msgs: Array[String] = []  # bir kararın yan etkileri (oyuncuya hemen gösterilir)

var rng := RandomNumberGenerator.new()
var week := 1
var mesai := MESAI_PER_WEEK
var king_strength := 60.0   # gerçek güç (oyuncu görmez)
var king_name := KING_NAME
var dynasty_generation := 1
var unrest := 30.0
var economy := 55.0
const REGION_WEIGHTS := {"capital": 0.35, "industry": 0.30, "farmland": 0.22, "border": 0.13}
const REGION_NAMES := {"capital": "Başkent", "industry": "Sanayi Kuşağı", "farmland": "Tarım Ovaları", "border": "Sınır İlleri"}
var regions: Dictionary = {}
var region_rng := RandomNumberGenerator.new()
var region_sync_unrest := 30.0
var region_sync_economy := 55.0
var regional_effects: Array[Dictionary] = []
var last_region_action_week := 0
var last_region_crisis_week := 0
var economy_metrics: Dictionary = {"inflation": 45.0, "jobs": 55.0, "debt": 45.0, "trade": 55.0, "growth": 55.0}
var economy_rng := RandomNumberGenerator.new()
var parliament_rng := RandomNumberGenerator.new()
var government_rng := RandomNumberGenerator.new()
var consent := 70.0
var public_fear := 20.0
var public_rng := RandomNumberGenerator.new()
var public_opinion_active := false
var last_poll_week := 0
var opposition := 20.0
var parliament_base_opposition := 20.0
var parliament_blocs: Dictionary = {}
var parliament_proposals: Array = []
var last_parliament_bill_week := 0
var parliament_laws: Dictionary = {}
var last_parliament_review_week := 0
var government_pm := "kessler"
var government_coalition: Array[String] = ["royal", "nobles"]
var finance_report_source := "kessler"
var last_confidence_week := 0
var private_wealth := 10.0
var capacity: Dictionary = {"maliye": 55.0, "hukuk": 55.0, "ordu": 55.0, "idare": 55.0}
var treasury := 55.0
var budget_stance := 0
var court_share := false
var budget_allocation: Dictionary = {"army": 25.0, "social": 25.0, "industry": 25.0, "palace": 25.0}
var delayed_economy: Array[Dictionary] = []
var capacity_timeline: Array = []
var holding := 40.0
var halden_hostile_until := 0
var halden_demands := 0
var lena_boost_until := 0
var kadro_log: Array = []
var heir_maturity := 30.0
var foreign: Dictionary = {"asteria": 50.0, "drakon": 50.0, "seravia": 50.0}
var foreign_hint_until := 0
var ext_pressure: Dictionary = {"asteria": 0.0, "drakon": 0.0, "seravia": 0.0}
var ext_rng := RandomNumberGenerator.new()
var external_history: Array = []
const ATTRITION := 0.04
const STANCE_CAP := 0.23
const TREASURY_COST := 0.15
const TREASURY_DIFF := [0.8, 1.0, 1.8]
const ARMY_LAW_POWER := [1.0, 2.0, 4.0]
const TAX_LAW_REVENUE := [0.15, 0.02, 0.02]
const TAX_LAW_UPFRONT_UNREST := [0.0, 2.0, 4.0]
const TAX_LAW_UNREST := [0.0, 0.75, 2.4]
const STATE_REPORT_NOISE := 110.0
const STATE_RALLY_DENOM := [400.0, 400.0, 250.0]
const INSTITUTION_HEADS := {"kessler": "maliye", "falk": "hukuk", "arden": "ordu", "dorn": "idare"}
const APPOINT_COOLDOWN := 8
const TENDER_COOLDOWN := 3
const HEIR_COOLDOWN := 6
const DELEGATION_COOLDOWN := 4
const FOREIGN_ENVOYS := {"claire": "asteria", "malenkov": "drakon", "lucien": "seravia"}
const FACT_TEXT_EN := {"ihale_dosyasi": "Secret tender file granted to Sarne", "gazeteci_baskisi": "Pressure put on a journalist",
	"prens_izleniyor": "The Prince placed under secret surveillance", "yargi_baskisi": "Pressure put on a judge",
	"bakan_ihalesi": "Ministerial tender file", "bakan_ihalesi_2": "The ministerial tender file's link to the Palace",
	"falk_mektubu": "The judge's resignation letter", "saglik_yalani": "Operation to deny the King's health rumor",
	"muhalefet_finansmani": "Secret funds used to split the opposition"}
const HALDEN_MEDIA_UNREST := 0.6
const HALDEN_MEDIA_KING := 0.25
const HALDEN_MEDIA_REACH := [71.0, 71.0, 50.0]  # Yayın etkisinin ülke çapına eriştiği holding eşiği.
const STATE_ECON_MALIYE := 0.003
const STATE_ECON_HUKUK := 0.001
const STATE_DIFF := [0.7, 1.0, 1.2]
const LEGAL_DIFF := [0.5, 1.0, 1.5]
const FOREIGN_EFFECT_DIFF := [0.7, 1.0, 1.1]
const EXT_PRESSURE_DECAY := 0.06
const BORDER_WARNING_AT := 38.0
const BORDER_CRISIS_AT := 62.0
const SIEGE_CRISIS_AT := 65.0
const ASSASSINATION_OMEN_CHANCE := 0.035
var actors: Dictionary = {}  # id -> Actor
var facts: Dictionary = {}   # id -> Dictionary
var flags: Dictionary = {}
var fired_events: Dictionary = {}
var history: Array = []
var reports: Array = []
var pending: Array = []      # {event, age}
var truth_log: Array = []
var karne: Dictionary = {}   # kaynak -> {ok, bad}
var advice_log: Array = []   # meclis görüşlerinin sicili (oyun sonunda açılır)
var stats: Dictionary = {}
var regime := ""              # 60. haftadan sonra bir kez biçimlenir; oyuncunun geçmişinin yorumu
var weekly_news: Array = []
var weekly_news_localized: Dictionary = {}
var report_prev: Dictionary = {}   # kaynak -> geçen haftaki raporun SÖYLEDİĞİ band (gerçek değil)
var week_changes: Array = []       # {tone, text, actor}: görünür göstergelerin geçen haftaya göre farkı
var weekly_moves: Array = []       # bu haftanın aktör hamleleri {tone, text, actor} (docs/design/aktor_hamleleri.md)
var ended := false
var record: Dictionary = {}
var scenario_id := ""
var scenario_name := ""
var endless := false
var coup_leader := ""

var _events: Array = []
var _advice: RefCounted
var _narrative: RefCounted
var content_error := ""
var _content_loader: RefCounted
var COUNCIL_CONTENT: Dictionary = {}
var REPORT_CONTENT: Dictionary = {}
var HISTORY_CONTENT: Dictionary = {}
var STATE_CONTENT: Dictionary = {}
var PATRONAGE_CONTENT: Dictionary = {}

func _init() -> void:
	_advice = Advice.new(self)
	_narrative = Narrative.new(self)
	_content_loader = ContentData.new()
	_load_content()


func new_game(seed_value: int = 0, diff: int = -1, scenario := "", legacy: Dictionary = {}) -> void:
	_load_content()
	if content_error != "":
		push_error(content_error)
		return
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	economy_rng.seed = rng.seed ^ 0xEC0A07
	region_rng.seed = rng.seed ^ 0xA4E610
	parliament_rng.seed = rng.seed ^ 0xA77E31
	government_rng.seed = rng.seed ^ 0x60A3E71
	if diff >= 0:
		difficulty = clampi(diff, 0, DIFFICULTY.size() - 1)
	mesai_max = int(_diff("mesai"))
	week = 1
	mesai = mesai_max
	king_strength = 60.0
	king_name = str(legacy.get("next_king", KING_NAME))
	dynasty_generation = maxi(1, int(legacy.get("generation", 1)))
	unrest = 30.0
	economy = 55.0
	regions = _new_regions(unrest, economy)
	region_sync_unrest = unrest
	region_sync_economy = economy
	regional_effects.clear()
	last_region_action_week = 0
	last_region_crisis_week = 0
	economy_metrics = {"inflation": 45.0, "jobs": 55.0, "debt": 45.0, "trade": 55.0, "growth": 55.0}
	consent = 70.0
	public_fear = 20.0
	public_rng.seed = rng.seed ^ 0xC0A5E17
	public_opinion_active = false
	last_poll_week = 0
	opposition = 20.0
	parliament_base_opposition = opposition
	parliament_blocs = _default_parliament_blocs()
	parliament_proposals.clear()
	last_parliament_bill_week = 0
	parliament_laws.clear()
	last_parliament_review_week = 0
	government_pm = "kessler"
	government_coalition = ["royal", "nobles"]
	finance_report_source = "kessler"
	last_confidence_week = 0
	private_wealth = 10.0
	var state_rng := RandomNumberGenerator.new()
	state_rng.seed = rng.seed ^ 0x5A17E
	for institution in capacity:
		capacity[institution] = 55.0 + state_rng.randf_range(-5.0, 5.0)
	treasury = 55.0
	budget_stance = 0
	court_share = false
	budget_allocation = {"army": 25.0, "social": 25.0, "industry": 25.0, "palace": 25.0}
	delayed_economy.clear()
	capacity_timeline.clear()
	holding = 40.0
	halden_hostile_until = 0
	halden_demands = 0
	lena_boost_until = 0
	kadro_log.clear()
	var newcomer_rng := RandomNumberGenerator.new()
	newcomer_rng.seed = rng.seed ^ 0x71E1A
	heir_maturity = 30.0 + newcomer_rng.randf_range(-5.0, 5.0)
	var foreign_rng := RandomNumberGenerator.new()
	foreign_rng.seed = rng.seed ^ 0xF0E19
	for power in foreign:
		foreign[power] = 50.0 + foreign_rng.randf_range(-5.0, 5.0)
	ext_rng.seed = rng.seed ^ 0xB1E710
	ext_pressure = {"asteria": 0.0, "drakon": 0.0, "seravia": 0.0}
	external_history.clear()
	foreign_hint_until = 0
	actors.clear()
	facts.clear()
	flags.clear()
	fired_events.clear()
	history.clear()
	reports.clear()
	pending.clear()
	truth_log.clear()
	karne.clear()
	advice_log.clear()
	plot_log.clear()
	crisis_note = ""
	coup_crisis = {}
	crisis_cooldown = 0
	weekly_news.clear()
	weekly_news_localized.clear()
	report_prev.clear()
	week_changes.clear()
	street_anger = 0.0
	legal_relief = 0.0
	other_crisis = {}
	warned = {}
	promises.clear()
	timeline.clear()
	stats = {"ops": 0, "bribes": 0, "promotes": 0, "leaks": 0, "dismissals": 0, "written": 0, "hints": 0, "checks": 0,
		"investigations": 0, "blackmails": 0, "promises": 0, "kept": 0, "broken": 0,
		"elections": 0, "government_formations": 0, "confidence_offers": 0, "confidence_votes": 0,
		"confidence_supports": 0, "confidence_falls": 0, "confidence_forced": 0,
		"regional_investments": {"capital": 0, "industry": 0, "farmland": 0, "border": 0},
		"regional_garrisons": {"capital": 0, "industry": 0, "farmland": 0, "border": 0},
		"regional_media": {"capital": 0, "industry": 0, "farmland": 0, "border": 0}, "regional_governors": 0, "regional_actions": 0, "regional_events": 0}
	regime = ""
	ended = false
	record = {}
	scenario_id = ""
	scenario_name = ""
	endless = false
	coup_leader = ""
	for d in _content_loader.load_actors():
		var a := Actor.new()
		a.setup(d)
		# Her kampanyada gizli özellikler değişir (tekrar oynanabilirlik).
		var actor_rng: RandomNumberGenerator = region_rng if a.id.begins_with("governor_") else (newcomer_rng if a.supporting else rng)
		a.ambition += actor_rng.randf_range(-12.0, 12.0)
		a.honesty = clampf(a.honesty + actor_rng.randf_range(-0.15, 0.15), 0.05, 1.0)
		a.perceived_king = king_strength + actor_rng.randf_range(-5.0, 5.0)
		actors[a.id] = a
		karne[a.id] = {"ok": 0, "bad": 0}
	_apply_legacy(legacy)
	_events = _content_loader.load_events(EVENTS_PATH)
	_fire_events()
	if scenario != "":
		if not _apply_scenario(scenario):
			push_error("Bilinmeyen senaryo: " + scenario)
			return
	_generate_reports()
	_record_timeline()
	changed.emit()


func _apply_legacy(legacy: Dictionary) -> void:
	if legacy.is_empty():
		return
	var file := FileAccess.open(LEGACY_PATH, FileAccess.READ)
	var rows: Variant = JSON.parse_string(file.get_as_text()) if file else null
	if not rows is Array:
		return
	var selected: Array = legacy.get("effects", [])
	var erosion := maxf(0.25, 1.0 - 0.2 * float(maxi(0, int(legacy.get("generation", 1)) - 1)))
	for effect_id in selected:
		for effect: Dictionary in rows:
			if str(effect.get("id", "")) != str(effect_id):
				continue
			var amount := float(effect.get("amount", 0.0))
			match str(effect.get("type", "")):
				"treasury": treasury = clampf(treasury + amount * erosion, 0.0, 100.0)
				"army":
					if actors.has("arden"):
						var key := str(effect.get("loyalty", "career"))
						actors["arden"].loyalty[key] = clampf(float(actors["arden"].loyalty.get(key, 0.0)) + amount * erosion, 0.0, 100.0)
				"debt":
					treasury = clampf(treasury + amount, 0.0, 100.0)
					foreign["seravia"] = clampf(float(foreign.get("seravia", 50.0)) - 3.0, 0.0, 100.0)
				"open_case": facts["legacy_open_case"] = {"id": "legacy_open_case", "text": "Önceki saltanattan kalan açık dosya", "text_en": Loc.en("Önceki saltanattan kalan açık dosya"), "subject": "king", "severity": 12.0, "public": false, "knowers": ["vale"], "common": 0.0, "copies": 1, "leakiness": 0.5}
				"regime":
					flags["LEGACY_REGIME_SHADOW"] = str(legacy.get("regime", ""))
					treasury = minf(100.0, treasury + 1.0)
				"wear": king_strength = clampf(king_strength + amount * float(maxi(1, int(legacy.get("generation", 1)))), 0.0, 100.0)
			break


func legacy_for_next_reign(generation: int) -> Dictionary:
	var effects: Array[String] = []
	effects.append("treasury_full" if treasury >= 65.0 else "treasury_debt")
	var army_loyalty := float(actors["arden"].loyalty.get("career", 0.0)) if actors.has("arden") else 0.0
	effects.append("army_loyal" if army_loyalty >= 25.0 else "army_resentful")
	var has_open_case := false
	for fact: Dictionary in facts.values():
		if str(fact.get("subject", "")) == "king" and not bool(fact.get("resolved", false)):
			has_open_case = true
			break
	if effects.has("treasury_debt") and effects.has("army_resentful"):
		effects.append("regime_shadow")
	elif has_open_case:
		effects.append("open_case")
	else:
		effects.append("reign_wear")
	return {"generation": generation, "ruler": king_name, "next_king": "Julian Valerius" if flags.has("halef_karari_1") else king_name,
		"effects": effects, "title": str(record.get("title", "")), "regime": regime}


func dynasty_record() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(dynasty_path) != OK:
		return {"generations": 0, "eligible": false, "legacy": {}, "entries": []}
	return {"generations": int(cfg.get_value("dynasty", "generations", 0)),
		"eligible": bool(cfg.get_value("dynasty", "eligible", false)),
		"score": int(cfg.get_value("dynasty", "score", 0)),
		"legacy": cfg.get_value("dynasty", "legacy", {}), "entries": cfg.get_value("dynasty", "entries", [])}


func dynasty_legacy() -> Dictionary:
	return dynasty_record().get("legacy", {})


func legacy_effect(effect_id: String) -> Dictionary:
	var file := FileAccess.open(LEGACY_PATH, FileAccess.READ)
	var rows: Variant = JSON.parse_string(file.get_as_text()) if file else null
	if not rows is Array:
		return {}
	for row: Dictionary in rows:
		if str(row.get("id", "")) == effect_id:
			if Loc.lang == "en":
				var overlay_file := FileAccess.open("res://game/data/en/legacy.json", FileAccess.READ)
				var overlay: Variant = JSON.parse_string(overlay_file.get_as_text()) if overlay_file else null
				if overlay is Dictionary and overlay.has(effect_id):
					row.merge(overlay[effect_id], true)
			return row
	return {}


func can_continue_dynasty() -> bool:
	return bool(dynasty_record().get("eligible", false)) and dynasty_legacy().size() > 0


func _record_dynasty(result: Dictionary) -> void:
	var cfg := ConfigFile.new()
	cfg.load(dynasty_path)
	var entries: Array = cfg.get_value("dynasty", "entries", [])
	var total_score := int(cfg.get_value("dynasty", "score", 0))
	var continue_allowed := bool(result.get("survived", false)) and flags.has("halef_karari_1")
	var generations := dynasty_generation if continue_allowed else 0
	if continue_allowed:
		var title := str(result.get("title", ""))
		var regime_title := str(result.get("regime", ""))
		var score := int(result.get("weeks", 0)) + (20 if result.get("survived", false) else 0)
		entries.append({"generation": dynasty_generation, "king": str(result.get("king", KING_NAME)), "title": title, "title_en": Loc.en(title),
			"regime": regime_title, "regime_en": Loc.en(regime_title), "weeks": int(result.get("weeks", 0)), "score": score})
		total_score += score
	var legacy := legacy_for_next_reign(dynasty_generation + 1) if continue_allowed else {}
	cfg.set_value("dynasty", "generations", generations)
	cfg.set_value("dynasty", "score", total_score if continue_allowed else 0)
	cfg.set_value("dynasty", "eligible", continue_allowed)
	cfg.set_value("dynasty", "legacy", legacy)
	cfg.set_value("dynasty", "entries", entries.slice(maxi(0, entries.size() - 50)))
	cfg.save(dynasty_path)


## Türkçe ek uyumu: özel isme kesme işaretiyle doğru eki ekler.
## kind: "e" (yönelme: Vale'ye, Arden'e), "in" (ilgi: Vale'nin, Voss'un, Arden'in), "i" (belirtme: Vale'yi, Arden'i)
static func ek(name: String, kind: String) -> String:
	if Loc.lang == "en":
		return name
	return ek_tr(name, kind)


static func ek_tr(name: String, kind: String) -> String:
	var word := name.split(" ")[-1].to_lower()
	var last_vowel := "e"
	for i in range(word.length() - 1, -1, -1):
		var ch := word[i]
		if ch in "aıoueiöü":
			last_vowel = ch
			break
	var ends_vowel := word.length() > 0 and word[-1] in "aıoueiöü"
	var back := last_vowel in "aıou"
	if kind == "e":
		return "%s'%s%s" % [name, "y" if ends_vowel else "", "a" if back else "e"]
	var v: String = {"a": "ı", "ı": "ı", "o": "u", "u": "u", "e": "i", "i": "i", "ö": "ü", "ü": "ü"}[last_vowel]
	if kind == "i":  # belirtme: Arden'i, Vale'yi, Leyla'yı
		return "%s'%s%s" % [name, "y" if ends_vowel else "", v]
	return "%s'%s%sn" % [name, "n" if ends_vowel else "", v]


func _load_content() -> void:
	var all: Dictionary = _content_loader.load_all()
	content_error = _content_loader.error
	if content_error != "":
		push_error(content_error)
		return
	var reports: Dictionary = all["reports"]
	REPORT_CONTENT = reports
	COUNCIL_CONTENT = all["council"]
	HISTORY_CONTENT = all["history"]
	ACHIEVEMENTS = all["achievements"]
	var labels: Dictionary = all["labels"]
	STATE_CONTENT = labels["budget"]
	PATRONAGE_CONTENT = labels["patronage"]
	PRIZES = labels["prizes"]
	POWER_TIER_NAMES = labels["power_tiers"]
	REPORT_TONES = labels["report_tones"]
	SUSPICION_NAMES = labels["suspicion_names"]
	REGIME_NAMES = labels["regime_names"]
	REGIME_TITLES = labels["regime_titles"]
	REGIME_THREATS = labels["regime_threats"]
	REGIME_ORDER = labels["regime_order"]


func _diff(key: String) -> float:
	return float(DIFFICULTY[difficulty][key])


func _load_json(path: String) -> Array:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Veri dosyası açılamadı: " + path)
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Array else []


func scenario_options() -> Array:
	var f := FileAccess.open("res://game/data/scenarios.json", FileAccess.READ)
	var data: Variant = JSON.parse_string(f.get_as_text()) if f else null
	if not data is Array:
		return []
	if Loc.lang == "en":
		var en_file := FileAccess.open("res://game/data/en/scenarios.json", FileAccess.READ)
		var english: Variant = JSON.parse_string(en_file.get_as_text()) if en_file else null
		if english is Dictionary:
			for row: Dictionary in data:
				var overlay: Dictionary = english.get(str(row.get("id", "")), {})
				for key in ["name", "desc"]:
					if overlay.has(key):
						row[key] = overlay[key]
	return data


func _apply_scenario(id: String) -> bool:
	for scenario: Dictionary in scenario_options():
		if str(scenario.get("id", "")) != id:
			continue
		scenario_id = id
		scenario_name = str(scenario.get("name", id))
		var overrides: Dictionary = scenario.get("overrides", {})
		for aid: String in overrides.get("actors", {}):
			if not actors.has(aid):
				return false
			var actor: Actor = actors[aid]
			for key in overrides["actors"][aid]:
				if key == "loyalty":
					for kind in overrides["actors"][aid][key]:
						actor.loyalty[kind] = overrides["actors"][aid][key][kind]
				elif key in ["power", "ambition", "fear", "honesty", "threshold"]:
					actor.set(key, overrides["actors"][aid][key])
				else:
					return false
		for key in overrides.get("flags", {}):
			flags[key] = overrides["flags"][key]
		for key in overrides.get("capacity", {}):
			if not capacity.has(key):
				return false
			capacity[key] = overrides["capacity"][key]
		treasury = float(overrides.get("treasury", treasury))
		if overrides.has("debt"):
			economy_metrics["debt"] = float(overrides["debt"])
		private_wealth = float(overrides.get("wealth", private_wealth))
		heir_maturity = float(overrides.get("heir_maturity", heir_maturity))
		mesai_max = int(overrides.get("mesai_max", mesai_max))
		mesai = mesai_max
		for event_id in overrides.get("first_events", []):
			for event: Dictionary in _events:
				if str(event.get("id", "")) == str(event_id) and not fired_events.has(str(event_id)):
					pending.append({"event": event.duplicate(true), "age": 0})
					fired_events[str(event_id)] = week
					break
		return true
	return false


# ---------------------------------------------------------------- Kayıt

func has_save() -> bool:
	return FileAccess.file_exists(_active_save_path()) or (save_path == DEFAULT_SAVE_PATH and FileAccess.file_exists(EXTENSION_SAVE_PATH))


func _active_save_path() -> String:
	if save_path != DEFAULT_SAVE_PATH:
		return save_path
	if not FileAccess.file_exists(EXTENSION_SAVE_PATH):
		return DEFAULT_SAVE_PATH
	if not FileAccess.file_exists(DEFAULT_SAVE_PATH):
		return EXTENSION_SAVE_PATH
	return EXTENSION_SAVE_PATH if FileAccess.get_modified_time(EXTENSION_SAVE_PATH) > FileAccess.get_modified_time(DEFAULT_SAVE_PATH) else DEFAULT_SAVE_PATH


## Menüde "Devam Et" yanında gösterilecek kısa özet: "Hafta 23 · Normal".
func save_summary() -> String:
	if not has_save():
		return ""
	var f := FileAccess.open(_active_save_path(), FileAccess.READ)
	var d: Variant = str_to_var(f.get_as_text())
	if not d is Dictionary:
		return ""
	var diff_i := clampi(int(d.get("diff", 1)), 0, DIFFICULTY.size() - 1)
	return tr("Hafta %d · %s") % [int(d.get("week", 1)), tr(str(DIFFICULTY[diff_i]["name"]))]


## Kayıt şeması sürümü. Kaydın biçimi her değiştiğinde artır ve _migrate_save'e bir adım ekle.
## 1: sürüm yok · 2: rapor farkları · 3: sokak/mahkeme krizi · 4: rejim · 5: devlet · 6: Sarne ve kadro günlüğü
const SAVE_VERSION := 20
const SAVE_REQUIRED := ["week", "mesai", "king", "unrest", "economy", "opp", "wealth", "actors", "facts", "flags",
	"fired", "history", "pending", "truth", "karne", "stats", "rng", "seed", "diff", "regime",
	"capacity", "treasury", "budget_stance", "court_share", "capacity_timeline", "holding",
	"halden_hostile_until", "halden_demands", "lena_boost_until", "kadro_log", "heir_maturity", "foreign", "foreign_hint_until", "lang", "scenario", "endless", "ext_pressure", "ext_rng", "external_history", "king_name", "dynasty_generation", "economy_metrics", "economy_rng", "budget_allocation", "delayed_economy", "consent", "public_fear", "public_rng", "public_opinion_active", "last_poll_week", "parliament_base_opposition", "parliament_blocs", "parliament_proposals", "last_parliament_bill_week", "parliament_rng", "parliament_laws", "last_parliament_review_week", "government_rng", "government_pm", "government_coalition", "finance_report_source", "last_confidence_week", "regions", "region_rng", "regional_effects", "last_region_action_week", "last_region_crisis_week", "region_sync_unrest", "region_sync_economy"]
var load_error := ""   # son başarısız yüklemenin oyuncuya gösterilecek nedeni


static func daily_seed(date: String) -> int:
	var compact := date.replace("-", "")
	return int(compact) if compact.is_valid_int() else 1


func daily_result(date := Time.get_date_string_from_system(true)) -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(DAILY_PATH) != OK or str(cfg.get_value("daily", "date", "")) != date:
		return {}
	return {"title": str(cfg.get_value("daily", "title", "")), "weeks": int(cfg.get_value("daily", "weeks", 0)),
		"survived": bool(cfg.get_value("daily", "survived", false)), "seed": int(cfg.get_value("daily", "seed", 0))}


func save_daily_result(date: String, result: Dictionary, seed: int) -> bool:
	if not daily_result(date).is_empty():
		return false
	var cfg := ConfigFile.new()
	cfg.set_value("daily", "date", date)
	cfg.set_value("daily", "title", str(result.get("title", "")))
	cfg.set_value("daily", "weeks", int(result.get("weeks", 0)))
	cfg.set_value("daily", "survived", bool(result.get("survived", false)))
	cfg.set_value("daily", "seed", seed)
	return cfg.save(DAILY_PATH) == OK


## Eski bir kaydı bugünkü şemaya taşır (adım adım: 1 -> 2 -> ...).
func _migrate_save(d: Dictionary, from: int) -> Dictionary:
	if from < 2:
		d["report_prev"] = d.get("report_prev", {})
		d["week_changes"] = d.get("week_changes", [])
	if from < 3:
		d["street_anger"] = d.get("street_anger", 0.0)
		d["legal_relief"] = d.get("legal_relief", 0.0)
		d["other_crisis"] = d.get("other_crisis", {})
		d["warned"] = d.get("warned", {})
	if from < 4:
		d["regime"] = d.get("regime", "")
	if from < 5:
		d["capacity"] = {"maliye": 55.0, "hukuk": 55.0, "ordu": 55.0, "idare": 55.0}
		d["treasury"] = 55.0
		d["budget_stance"] = 0
		d["court_share"] = false
		d["capacity_timeline"] = []
	if from < 6:
		var old_people: Variant = d.get("actors", {})
		var old_halden: Dictionary = {}
		if old_people is Dictionary and old_people.get("halden") is Dictionary:
			old_halden = old_people["halden"]
		d["holding"] = clampf(float(old_halden.get("power", 50.0)) - 10.0, 0.0, 100.0)
		d["halden_hostile_until"] = 0
		d["halden_demands"] = 0
		d["lena_boost_until"] = 0
		d["kadro_log"] = []
	if from < 7:
		# Eski çizelgede holding yoktu; eldeki değer geçmiş için en dürüst yaklaşık değerdir.
		for point: Dictionary in d.get("capacity_timeline", []):
			point["holding"] = float(d.get("holding", 40.0))
	if from < 8:
		d["heir_maturity"] = 30.0
		var old_actors: Dictionary = d.get("actors", {})
		var old_karne: Dictionary = d.get("karne", {})
		for actor_data: Dictionary in _content_loader.load_actors():
			if actor_data.get("supporting", false) and not old_actors.has(actor_data["id"]):
				var newcomer := Actor.new()
				newcomer.setup(actor_data)
				old_actors[actor_data["id"]] = newcomer.to_save()
				old_karne[actor_data["id"]] = {"ok": 0, "bad": 0}
		d["actors"] = old_actors
		d["karne"] = old_karne
	if from < 9:
		d["lang"] = "tr"
	if from < 10:
		d["scenario"] = ""
		d["endless"] = false
	if from < 11:
		d["ext_pressure"] = {"asteria": 0.0, "drakon": 0.0, "seravia": 0.0}
		var old_ext_rng := RandomNumberGenerator.new()
		old_ext_rng.seed = int(d.get("seed", 1)) ^ 0xB1E710
		d["ext_rng"] = old_ext_rng.state
		d["external_history"] = []
	if from < 12:
		d["king_name"] = KING_NAME
		d["dynasty_generation"] = 1
	if from < 13:
		var old_economy := float(d.get("economy", 55.0))
		d["economy_metrics"] = {"inflation": 100.0 - old_economy, "jobs": old_economy, "debt": 100.0 - float(d.get("treasury", 55.0)),
			"trade": old_economy, "growth": old_economy}
		var old_economy_rng := RandomNumberGenerator.new()
		old_economy_rng.seed = int(d.get("seed", 1)) ^ 0xEC0A07
		d["economy_rng"] = old_economy_rng.state
	if from < 14:
		d["budget_allocation"] = {"army": 25.0, "social": 25.0, "industry": 25.0, "palace": 25.0}
		d["delayed_economy"] = []
	if from < 15:
		d["consent"] = 100.0 - float(d.get("unrest", 30.0))
		d["public_fear"] = 20.0
		var public_rng_migration := RandomNumberGenerator.new()
		public_rng_migration.seed = int(d.get("seed", 1)) ^ 0xC0A5E17
		d["public_rng"] = public_rng_migration.state
		d["public_opinion_active"] = false
		d["last_poll_week"] = 0
	if from < 16:
		d["parliament_base_opposition"] = float(d.get("opp", 20.0))
		d["parliament_blocs"] = _default_parliament_blocs()
		d["parliament_proposals"] = []
		d["last_parliament_bill_week"] = 0
		var parliament_rng_migration := RandomNumberGenerator.new()
		parliament_rng_migration.seed = int(d.get("seed", 1)) ^ 0xA77E31
		d["parliament_rng"] = parliament_rng_migration.state
	if from < 17:
		d["parliament_laws"] = {}
		d["last_parliament_review_week"] = 0
	if from < 18:
		var government_rng_migration := RandomNumberGenerator.new()
		government_rng_migration.seed = int(d.get("seed", 1)) ^ 0x60A3E71
		d["government_rng"] = government_rng_migration.state
		d["government_pm"] = "kessler"
		d["government_coalition"] = ["royal", "nobles"]
		d["finance_report_source"] = "kessler"
		d["last_confidence_week"] = 0
	if from < 19:
		region_rng.seed = int(d.get("seed", 1)) ^ 0xA4E610
		d["regions"] = _new_regions(float(d.get("unrest", 30.0)), float(d.get("economy", 55.0)))
		d["region_rng"] = region_rng.state
	if from < 20:
		d["regional_effects"] = []
		d["last_region_action_week"] = 0
		d["last_region_crisis_week"] = 0
		d["region_sync_unrest"] = float(d.get("unrest", 30.0))
		d["region_sync_economy"] = float(d.get("economy", 55.0))
		var migrated_stats: Dictionary = d.get("stats", {})
		migrated_stats["regional_investments"] = {"capital": 0, "industry": 0, "farmland": 0, "border": 0}
		migrated_stats["regional_garrisons"] = {"capital": 0, "industry": 0, "farmland": 0, "border": 0}
		migrated_stats["regional_media"] = {"capital": 0, "industry": 0, "farmland": 0, "border": 0}
		migrated_stats["regional_governors"] = 0
		migrated_stats["regional_actions"] = 0
		migrated_stats["regional_events"] = 0
		d["stats"] = migrated_stats
		for id in REGION_WEIGHTS:
			d["regions"][id]["garrison"] = 0.0
			d["regions"][id]["media"] = 0.0
	if not d.has("foreign"):
		d["foreign"] = {"asteria": 50.0, "drakon": 50.0, "seravia": 50.0}
	if not d.has("foreign_hint_until"):
		d["foreign_hint_until"] = 0
	# B1'in kısa ömürlü v8 kayıtları dış temsilcileri henüz içermiyordu.
	if d.get("actors") is Dictionary:
		var migrated_actors: Dictionary = d["actors"]
		var migrated_karne: Dictionary = d.get("karne", {})
		for actor_data: Dictionary in _content_loader.load_actors():
			if actor_data.get("supporting", false) and not migrated_actors.has(actor_data["id"]):
				var newcomer := Actor.new()
				newcomer.setup(actor_data)
				migrated_actors[actor_data["id"]] = newcomer.to_save()
				migrated_karne[actor_data["id"]] = {"ok": 0, "bad": 0}
		d["actors"] = migrated_actors
		d["karne"] = migrated_karne
	d["version"] = SAVE_VERSION
	return d


func save_game() -> bool:
	if ended:
		return false
	var a_data := {}
	for id in actors:
		a_data[id] = actors[id].to_save()
	var data := {"week": week, "mesai": mesai, "king": king_strength, "unrest": unrest, "economy": economy,
		"opp": opposition, "wealth": private_wealth, "actors": a_data, "facts": facts, "flags": flags,
		"fired": fired_events, "history": history, "pending": pending, "truth": truth_log, "karne": karne, "advice_log": advice_log,
		"plot_log": plot_log, "coup_crisis": coup_crisis, "crisis_cooldown": crisis_cooldown,
		"stats": stats, "rng": rng.state, "seed": rng.seed, "diff": difficulty, "promises": promises,
		"timeline": timeline, "report_prev": report_prev, "week_changes": week_changes,
		"street_anger": street_anger, "legal_relief": legal_relief, "other_crisis": other_crisis, "warned": warned,
		"regime": regime, "capacity": capacity, "treasury": treasury, "budget_stance": budget_stance,
		"court_share": court_share, "capacity_timeline": capacity_timeline, "holding": holding,
		"halden_hostile_until": halden_hostile_until, "halden_demands": halden_demands,
		"lena_boost_until": lena_boost_until, "kadro_log": kadro_log, "heir_maturity": heir_maturity,
		"foreign": foreign, "foreign_hint_until": foreign_hint_until, "lang": Loc.lang, "scenario": scenario_id,
		"ext_pressure": ext_pressure, "ext_rng": ext_rng.state, "external_history": external_history,
		"endless": endless, "king_name": king_name, "dynasty_generation": dynasty_generation,
		"economy_metrics": economy_metrics, "economy_rng": economy_rng.state, "budget_allocation": budget_allocation,
		"consent": consent, "public_fear": public_fear, "public_rng": public_rng.state,
		"public_opinion_active": public_opinion_active, "last_poll_week": last_poll_week,
		"delayed_economy": delayed_economy, "parliament_base_opposition": parliament_base_opposition,
		"parliament_blocs": parliament_blocs, "parliament_proposals": parliament_proposals,
		"last_parliament_bill_week": last_parliament_bill_week, "parliament_rng": parliament_rng.state,
		"parliament_laws": parliament_laws, "last_parliament_review_week": last_parliament_review_week,
		"government_rng": government_rng.state, "government_pm": government_pm, "government_coalition": government_coalition,
		"finance_report_source": finance_report_source, "last_confidence_week": last_confidence_week,
		"regions": regions, "region_rng": region_rng.state, "regional_effects": regional_effects,
		"last_region_action_week": last_region_action_week, "last_region_crisis_week": last_region_crisis_week,
		"region_sync_unrest": region_sync_unrest, "region_sync_economy": region_sync_economy,
	"version": SAVE_VERSION}
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(var_to_str(data))
	return true


func continue_endless() -> bool:
	if not ended or not record.get("survived", false) or endless:
		return false
	var old_week := week
	var old_mesai := mesai
	var old_record := record
	var old_path := save_path
	endless = true
	ended = false
	week = maxi(MAX_WEEKS + 1, week)
	mesai = mesai_max
	save_path = EXTENSION_SAVE_PATH
	record = {}
	if save_game():
		return true
	endless = false
	ended = true
	week = old_week
	mesai = old_mesai
	record = old_record
	save_path = old_path
	return false


func load_game() -> bool:
	load_error = ""
	if content_error != "":
		load_error = content_error
		return false
	if not has_save():
		load_error = "Kayıtlı oyun bulunamadı."
		return false
	save_path = _active_save_path()
	var f := FileAccess.open(save_path, FileAccess.READ)
	var d: Variant = str_to_var(f.get_as_text()) if f else null
	if not d is Dictionary:
		load_error = "Kayıt dosyası okunamadı; bozulmuş olabilir."
		return false
	var version := int(d.get("version", 1))
	if version > SAVE_VERSION:
		load_error = "Bu kayıt oyunun daha yeni bir sürümüyle yapılmış. Oyunu güncelleyin."
		return false
	d = _migrate_save(d, version)
	Loc.set_lang(str(d.get("lang", "tr")))
	# Eksik alanlı bir kayıt, oyun yarıya kadar kurulduktan sonra hata vermesin: önce denetle.
	for k in SAVE_REQUIRED:
		if not d.has(k):
			load_error = "Kayıt dosyası eksik ya da bozuk ('%s' yok)." % k
			return false
	new_game(int(d.get("seed", 1)), int(d.get("diff", 1)))
	king_name = str(d["king_name"])
	dynasty_generation = maxi(1, int(d["dynasty_generation"]))
	scenario_id = str(d.get("scenario", ""))
	endless = bool(d.get("endless", false))
	if scenario_id != "":
		for option in scenario_options():
			if option["id"] == scenario_id:
				scenario_name = str(option["name"])
				break
	week = d["week"]
	mesai = d["mesai"]
	king_strength = d["king"]
	unrest = d["unrest"]
	economy = d["economy"]
	opposition = d["opp"]
	parliament_base_opposition = float(d.get("parliament_base_opposition", opposition))
	parliament_blocs = d.get("parliament_blocs", _default_parliament_blocs())
	parliament_proposals = d.get("parliament_proposals", [])
	last_parliament_bill_week = int(d.get("last_parliament_bill_week", 0))
	parliament_laws = d.get("parliament_laws", {})
	last_parliament_review_week = int(d.get("last_parliament_review_week", 0))
	private_wealth = d["wealth"]
	capacity = d["capacity"]
	treasury = float(d["treasury"])
	budget_stance = int(d["budget_stance"])
	court_share = bool(d["court_share"])
	capacity_timeline = d["capacity_timeline"]
	holding = float(d["holding"])
	halden_hostile_until = int(d["halden_hostile_until"])
	halden_demands = int(d["halden_demands"])
	lena_boost_until = int(d["lena_boost_until"])
	kadro_log = d["kadro_log"]
	heir_maturity = float(d["heir_maturity"])
	foreign = d["foreign"]
	foreign_hint_until = int(d["foreign_hint_until"])
	ext_pressure = d["ext_pressure"]
	economy_metrics = d.get("economy_metrics", {"inflation": 100.0 - economy, "jobs": economy, "debt": 100.0 - treasury, "trade": economy, "growth": economy})
	consent = float(d.get("consent", 100.0 - unrest))
	public_fear = float(d.get("public_fear", 20.0))
	public_rng.state = int(d.get("public_rng", public_rng.state))
	public_opinion_active = bool(d.get("public_opinion_active", false))
	last_poll_week = int(d.get("last_poll_week", 0))
	economy_rng.state = int(d.get("economy_rng", int(d.get("seed", 1)) ^ 0xEC0A07))
	budget_allocation = d.get("budget_allocation", {"army": 25.0, "social": 25.0, "industry": 25.0, "palace": 25.0})
	delayed_economy.assign(d.get("delayed_economy", []))
	external_history = d["external_history"]
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
	advice_log = d.get("advice_log", [])
	plot_log = d.get("plot_log", [])
	coup_crisis = d.get("coup_crisis", {})
	crisis_cooldown = int(d.get("crisis_cooldown", 0))
	stats = d["stats"]
	promises = d.get("promises", [])
	timeline = d.get("timeline", [])
	rng.state = d["rng"]
	ext_rng.state = d["ext_rng"]
	parliament_rng.state = int(d.get("parliament_rng", int(d.get("seed", 1)) ^ 0xA77E31))
	government_rng.state = int(d.get("government_rng", int(d.get("seed", 1)) ^ 0x60A3E71))
	government_pm = str(d.get("government_pm", "kessler"))
	government_coalition.assign(d.get("government_coalition", ["royal", "nobles"]))
	finance_report_source = str(d.get("finance_report_source", "kessler"))
	last_confidence_week = int(d.get("last_confidence_week", 0))
	regions = d.get("regions", _new_regions(unrest, economy))
	region_sync_unrest = float(d.get("region_sync_unrest", unrest))
	region_sync_economy = float(d.get("region_sync_economy", economy))
	regional_effects.assign(d.get("regional_effects", []))
	last_region_action_week = int(d.get("last_region_action_week", 0))
	last_region_crisis_week = int(d.get("last_region_crisis_week", 0))
	region_rng.state = int(d.get("region_rng", int(d.get("seed", 1)) ^ 0xA4E610))
	_refresh_parliament_opposition()
	_generate_reports()
	report_prev = d.get("report_prev", {})   # _generate_reports'un üzerine yazdığı geçen hafta
	week_changes = d.get("week_changes", [])
	street_anger = float(d.get("street_anger", 0.0))
	legal_relief = float(d.get("legal_relief", 0.0))
	other_crisis = d.get("other_crisis", {})
	warned = d.get("warned", {})
	regime = str(d["regime"])
	if regime == "" and week >= 60:
		regime = _choose_regime()  # eski kayıtta haber tekrarlanmaz
	if regime != "":
		flags["REJIM_" + regime.to_upper()] = 60
	changed.emit()
	return true


# ---------------------------------------------------------------- Oyuncu eylemleri

func spend_mesai(cost: int = 1) -> bool:
	if ended or mesai < cost:
		return false
	mesai -= cost
	return true


func _no_mesai() -> String:
	return tr("Bu hafta mesain kalmadı.")


func news_for_display(source: String) -> String:
	if Loc.lang == "en" and weekly_news_localized.has(source):
		return str(weekly_news_localized[source])
	for prefix in ["KRİZ: ", "ALAMET: ", "SOKAK: ", "MAHKEME: ", "MALİYE: ", "ADLİYE: ", "İDARE: ", "ORDU: ", "DIŞİŞLERİ: ", "MANŞET: ", "ERTELENDİ — ", "KULİS: ", "OLAY: ", "SÖZ: ", "HAMLE: "]:
		if source.begins_with(prefix):
			return tr(prefix) + source.substr(prefix.length())
	return tr(source)


func _add_news(source: String, text_en: String = "") -> void:
	weekly_news.append(source)
	weekly_news_localized[source] = text_en if text_en != "" else Loc.en(source)


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
	if INSTITUTION_HEADS.has(id):
		capacity[INSTITUTION_HEADS[id]] = maxf(5.0, float(capacity[INSTITUTION_HEADS[id]]) - 1.0)
	flags[id.to_upper() + "_GUCLENDI"] = week
	changed.emit()
	return tr("%s terfi etti. Sana minnettar, ama artık daha güçlü.") % a.display_name


func appoint_wait(id: String) -> int:
	if not INSTITUTION_HEADS.has(id):
		return -1
	return maxi(0, APPOINT_COOLDOWN - (week - int(flags.get("KADRO_" + INSTITUTION_HEADS[id], -100))))


func heir_maturity_band() -> String:
	return "Çocuksu" if heir_maturity < 40.0 else ("Gelişiyor" if heir_maturity < 70.0 else "Hazır")


func heir_train_wait() -> int:
	return maxi(0, HEIR_COOLDOWN - (week - int(flags.get("VELIAHT_YETISTI", -100))))


func train_heir(id: String) -> String:
	if id != "julian" or not actors.has(id) or actors[id].moved:
		return tr("Veliaht için bu kararname çıkarılamaz.")
	if heir_train_wait() > 0:
		return tr("Julian'ın yeni dersleri için beklemelisin.")
	if not spend_mesai():
		return _no_mesai()
	var last := int(flags.get("VELIAHT_YETISTI", -100))
	var streak := int(stats.get("heir_streak", 0)) + 1 if week - last <= 8 else 1
	stats["heir_trainings"] = int(stats.get("heir_trainings", 0)) + 1
	stats["heir_streak"] = streak % 3
	flags["VELIAHT_YETISTI"] = week
	heir_maturity = minf(100.0, heir_maturity + 10.0)
	if streak == 3:
		for aid in ["prens", "arden"]:
			if actors.has(aid):
				actors[aid].ambition += 3.0
		changed.emit()
		return tr("Julian derslerini ilerletti. Prens Marcus ile Marcus Arden, veliahdın sarayda fazla öne çıktığını konuşuyor.")
	changed.emit()
	return tr("Julian derslerini ilerletti. Ne öğrendiğini halkın önünde göreceksin.")


func delegation_wait() -> int:
	return maxi(0, DELEGATION_COOLDOWN - (week - int(flags.get("HEYET_GONDER", -100))))


func send_delegation(id: String) -> String:
	if not FOREIGN_ENVOYS.has(id) or not actors.has(id) or actors[id].moved:
		return tr("Heyet gönderilecek elçiyi seçmelisin.")
	if delegation_wait() > 0:
		return tr("Elçilikler önceki heyetin cevabını bekliyor.")
	if not spend_mesai():
		return _no_mesai()
	var target: String = FOREIGN_ENVOYS[id]
	for power in foreign:
		foreign[power] = clampf(float(foreign[power]) + (12.0 if power == target else -3.0), 0.0, 100.0)
		ext_pressure[power] = maxf(0.0, float(ext_pressure.get(power, 0.0)) - (12.0 if power == target else 3.0))
	flags["HEYET_GONDER"] = week
	stats["delegations"] = int(stats.get("delegations", 0)) + 1
	changed.emit()
	return tr("%s heyeti kabul etti. Öteki elçilikler bu yakınlığı dikkatle not etti.") % actors[id].display_name


func appoint(id: String, kind: String) -> String:
	if not INSTITUTION_HEADS.has(id) or not actors.has(id) or actors[id].moved or not kind in ["loyal", "merit"]:
		return tr("Bu kadro kararnamesi çıkarılamaz.")
	if appoint_wait(id) > 0:
		return tr("Bu kurumda yeni bir atama için beklemelisin.")
	if not spend_mesai():
		return _no_mesai()
	var institution: String = INSTITUTION_HEADS[id]
	var a: Actor = actors[id]
	flags["KADRO_" + institution] = week
	kadro_log.append({"week": week, "institution": institution, "kind": kind})
	if kind == "loyal":
		flags["KADRO_SADIK_" + institution.to_upper()] = week
		a.loyalty["career"] += 8.0
		a.ambition -= 3.0
		a.obligation += 3.0
		capacity[institution] = maxf(5.0, float(capacity[institution]) - 8.0)
		stats["sadik_" + institution] = int(stats.get("sadik_" + institution, 0)) + 1
	else:
		flags["KADRO_LIYAKATLI_" + institution.to_upper()] = week
		capacity[institution] = minf(100.0, float(capacity[institution]) + 7.0)
		a.ambition += 3.0
		a.loyalty["career"] = maxf(0.0, float(a.loyalty["career"]) - 3.0)
		a.obligation = maxf(0.0, a.obligation - 2.0)
		stats["liyakatli_" + institution] = int(stats.get("liyakatli_" + institution, 0)) + 1
	changed.emit()
	return tr("%s için %s kadro kararnamesi imzalandı. Sonucu kurumun işinde göreceksin.") % [a.display_name, tr("sadık") if kind == "loyal" else tr("liyakatli")]


func tender_wait() -> int:
	return maxi(0, TENDER_COOLDOWN - (week - int(flags.get("IHALE_VER", -100))))


func give_tender(id: String) -> String:
	if id != "halden" or not actors.has(id) or actors[id].moved:
		return tr("Bu ihale Sarne'ye verilemez.")
	if tender_wait() > 0:
		return tr("İhale komisyonu yeni dosyayı henüz açmıyor.")
	if not spend_mesai():
		return _no_mesai()
	flags["IHALE_VER"] = week
	stats["tenders"] = int(stats.get("tenders", 0)) + 1
	holding = minf(100.0, holding + 10.0)
	private_wealth += 6.0
	treasury = maxf(0.0, treasury - 3.0)
	economy = minf(100.0, economy + 1.0)
	capacity["maliye"] = maxf(5.0, float(capacity["maliye"]) - 2.0)
	actors[id].power += 3.0
	actors[id].loyalty["money"] += 6.0
	_add_fact("ihale_komisyonu_%d" % week, "Sarne ihalesinden saraya aktarılan komisyon", "king", 18.0, ["halden", "kessler"], 1)
	changed.emit()
	return tr("İhale Sarne'ye verildi. Şirketleri işi üstlendi; Veyra sözleşmenin bir kopyasını sakladı.")


func halden_mood() -> String:
	var halden: Actor = actors.get("halden")
	if halden == null or halden.moved or week < halden_hostile_until:
		return "düşmanca"
	if week < int(flags.get("HALDEN_SICAK", -100)) + 10:
		return "sıcak"
	return "sıcak" if halden.total_loyalty() >= 25.0 else "mesafeli"


func halden_influence_band() -> String:
	var seen := holding - 8.0  # Sarne ağının gerçek sınırlarını küçümser.
	return "sınırlı" if seen < 40.0 else ("yaygın" if seen < 70.0 else "her yerde")


func media_dependency() -> float:
	return clampf(0.6 * holding + 20.0 - (0.0 if Press.is_closed(self, "free") else 15.0)
		- (8.0 if week < lena_boost_until else 0.0), 0.0, 100.0)


## Huzura çağır: izsiz, parasız bir yoklama. Kişiyi biraz yatıştırır ve gürültülü bir okuma verir:
## komplocu çoğu zaman kaçamak konuşur; sakin biri temiz çıkarsa hakkındaki dedikodular dağılır.
const SUMMON_COOLDOWN := 4     # aynı kişiyi yeniden çağırmak için hafta
const SUMMON_TELL := 0.6       # komplocunun kendini ele verme olasılığı
const SUMMON_FALSE := 0.1      # sakin birinin yine de tedirgin görünme olasılığı
const SUMMON_CALM := 6.0       # kral dikkatli görünür: perceived_king artışı
const SUMMON_CAREER := 4.0
const SUMMON_CAUGHT_FEAR := 6.0   # ele veren komplocu fark edildiğini anlar: korku sadakati


func summon_wait(id: String) -> int:
	var last := int(flags.get("HUZUR_" + id.to_upper(), -100))
	return maxi(0, last + SUMMON_COOLDOWN - week)


func summon(id: String) -> String:
	var a: Actor = actors[id]
	if a.moved:
		return tr("%s artık çağrına gelmiyor.") % a.display_name
	if summon_wait(id) > 0:
		return tr("%s yakın zamanda huzura çağırdın; tekrar çağırmak telaş gibi görünür.") % ek(a.display_name, "i")
	if not spend_mesai():
		return _no_mesai()
	stats["summons"] = int(stats.get("summons", 0)) + 1
	flags["HUZUR_" + id.to_upper()] = week
	a.perceived_king += SUMMON_CALM
	a.loyalty["career"] = float(a.loyalty["career"]) + SUMMON_CAREER
	changed.emit()
	if a.plot_stage >= 2:
		if rng.randf() < SUMMON_TELL:
			a.loyalty["fear"] = float(a.loyalty["fear"]) + SUMMON_CAUGHT_FEAR
			_add_sign(a, "%s huzurda kaçamak cevaplar verdi; gözlerini kaçırdı." % short_name(a), 2, true,
				"%s gave evasive answers at court and avoided eye contact." % short_name(a))
			return tr("%s huzurunda gergindi. Sorularına kaçamak cevaplar verdi ve erken ayrılmak için izin istedi.") % a.display_name
		return tr("%s sakin ve saygılıydı. Hiçbir şey sezmedin.") % a.display_name
	if rng.randf() < SUMMON_FALSE:
		_add_sign(a, "%s huzurda tedirgin görünüyordu." % short_name(a), 1, false,
			"%s appeared uneasy at court." % short_name(a))
		return tr("%s tedirgindi; neden olduğunu söylemedi.") % a.display_name
	var before := a.signs.size()
	a.signs = a.signs.filter(func(g: Dictionary) -> bool: return g["real"])
	var cleared := before - a.signs.size()
	var out := tr("%s içtenlikle konuştu.") % a.display_name
	if cleared > 0:
		out += tr(" Hakkındaki fısıltıların dedikodu olduğuna kanaat getirdin.")
	if a.plot_stage == 1:
		out += tr(" Yine de saraydan bazı şikâyetleri olduğu belli.")
	return out


## Rüşvet: sadakat satın alır ve kanıt üretir.
const BRIBE_COST := 5.0


func bribe(id: String) -> String:
	var a: Actor = actors[id]
	if private_wealth < BRIBE_COST:
		return tr("Kişisel servetin yetersiz.")
	if not spend_mesai():
		return _no_mesai()
	private_wealth -= BRIBE_COST
	a.loyalty["money"] += 8.0
	a.secrets_on_king += 1
	stats["bribes"] += 1
	_add_fact("transfer_%s_%d" % [id, week], "%s yapılan gizli ödeme" % ek(a.display_name, "e"), "king", 18, [id, "dorn"], 2, 0.5,
		"Secret payment made to %s" % a.display_name)
	changed.emit()
	return tr("%s gizli ödeme yapıldı. Sadakati arttı; ama bir iz kaldı.") % ek(a.display_name, "e")


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
			_add_fact("emir_%s_%d" % [id, week], "%s verilen yazılı emir" % ek(a.display_name, "e"), "king", 35, [id], 1, 0.5,
				"Written order given to %s" % a.display_name)
		"sozlu":
			fidelity = 0.75
		"ima":
			stats["hints"] += 1
			# Hırslı biri imayı aşırı yorumlar, korkak biri hiç uygulamaz.
			fidelity = clampf(0.3 + a.ambition / 100.0 + rng.randf_range(-0.2, 0.4) - a.red_line_penalty(task), 0.0, 1.5)
	# Komplocu emri geciktirir (görünür alamet).
	var delayed := a.plot_stage >= 2
	if delayed:
		fidelity *= PLOT_ORDER_DELAY
		_add_sign(a, "%s emri geciktirdi; uygulamak için 'koşulların olgunlaşmasını' bekliyor." % short_name(a), 2, true,
			"%s delayed the order, waiting for conditions to mature before carrying it out." % short_name(a))
	# Kırmızı çizgi: açık emirle çiğnenirse gönülsüz uygulanır ve küskünlük bırakır.
	var crossed := a.crosses_red_line(task) and channel != "ima"
	if crossed:
		fidelity *= 0.5
		a.ambition += 5.0
		a.loyalty["ideology"] = maxf(0.0, float(a.loyalty["ideology"]) - 6.0)
		a.known_red = true
	fidelity *= 0.85 + float(capacity["idare"]) / 370.0
	if channel == "yazili" or task == "bastir":
		capacity["ordu"] = maxf(5.0, float(capacity["ordu"]) - 0.5)
	var text := ""
	match task:
		"bastir":
			# Bastırmak borçtur: öfke biriktirir, öfke arttıkça bastırma daha az işe yarar (kayip_cesitliligi.md).
			unrest = maxf(0.0, unrest - 14.0 * fidelity * (1.0 - street_anger / 150.0))
			street_anger = minf(100.0, street_anger + STREET_ANGER_GAIN * fidelity)
			a.power += 6.0 * fidelity
			a.obligation += 5.0 * fidelity
			if fidelity > 1.1:
				unrest += 6.0
				text = tr("%s emri fazla sert yorumladı; bastırma kontrolden çıkıyor.") % a.display_name
			elif fidelity < 0.4:
				text = tr("%s emri anlamadı ya da uygulamadı. Hiçbir şey olmadı.") % a.display_name
			else:
				text = tr("%s harekete geçti.") % a.display_name
		"sorustur":
			a.power += 3.0 * fidelity
			a.secrets_on_king += 1 if a.domain == "intel" else 0
			_reveal_hint(a, fidelity)
			text = tr("%s soruşturmayı başlattı.") % a.display_name
		_:
			text = tr("%s emri aldı.") % a.display_name
	if crossed:
		text = tr("%s emri kırmızı çizgisini aştığı için gönülsüzce, yarım yamalak uyguladı. Bunu sana yazdı. (Kırmızı çizgisi: %s)") % [a.display_name, tr(a.red_line)]
	if delayed:
		text += tr(" Ama acele etmedi; emri günlerce bekletti.")
	changed.emit()
	return text


## Araştır: seçilen kişinin önce zayıf noktasını, sonra kırmızı çizgisini öğrenmeye çalışır.
## İstihbarat (Vale) ne kadar güçlüyse şans o kadar yüksek; ama Vale da öğrendiğini saklar.
func investigate(id: String) -> String:
	var a: Actor = actors[id]
	if a.known_weak and a.known_red:
		return tr("%s hakkında öğrenilecek yeni bir şey kalmadı.") % a.display_name
	if not spend_mesai():
		return _no_mesai()
	stats["investigations"] = int(stats.get("investigations", 0)) + 1
	var voss: Actor = actors.get("voss")
	var chance := 0.35
	if voss != null and not voss.moved and voss.id != id:
		chance = 0.45 + voss.power / 200.0
		voss.power += 1.5
	if rng.randf() > chance:
		changed.emit()
		return tr("%s hakkındaki araştırma sonuç vermedi. İzler soğuk.") % a.display_name
	if not a.known_weak:
		a.known_weak = true
		changed.emit()
		return tr("%s zayıf noktası bulundu: %s. Artık şantaj mümkün.") % [ek(a.display_name, "in"), a.weak_point]
	a.known_red = true
	changed.emit()
	return tr("%s asla geçmeyeceği çizgi: %s.") % [ek(a.display_name, "in"), tr(a.red_line)]


## Şantaj: zayıf noktası bilinen birini korkuyla bağlar. Borcunu siler ama hırsını büyütür ve iz bırakır.
## Dürüst ve korkusuz biri ise şantajı ifşa edebilir.
func blackmail(id: String) -> String:
	var a: Actor = actors[id]
	if not a.known_weak:
		return tr("Önce %s zayıf noktasını bulmalısın (Araştır).") % ek(a.display_name, "in")
	if not spend_mesai():
		return _no_mesai()
	stats["blackmails"] = int(stats.get("blackmails", 0)) + 1
	a.blackmailed += 1
	var fid := "santaj_%s_%d" % [id, week]
	_add_fact(fid, "%s yapılan şantaj" % ek(a.display_name, "e"), "king", 30, [id], 1, 0.5,
		"Blackmail of %s" % a.display_name)
	var backfire := a.honesty * 0.35 + (0.25 if a.fear < 20.0 else 0.0) + 0.1 * (a.blackmailed - 1)
	if rng.randf() < backfire:
		facts[fid]["common"] = 0.45
		a.ambition += 10.0
		a.fear = maxf(0.0, a.fear - 5.0)
		changed.emit()
		return tr("%s boyun eğmedi; şantajı ifşa etmekle tehdit ediyor. Konuşulmaya başlandı bile.") % a.display_name
	a.fear += 25.0
	a.loyalty["fear"] = float(a.loyalty["fear"]) + 15.0
	a.obligation = maxf(0.0, a.obligation - 10.0)
	a.ambition += 6.0
	changed.emit()
	return tr("%s ne demek istediğini anladı. Artık senden korkuyor; korku ise sadakatin en kırılgan biçimi.") % a.display_name


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
		_add_news("Soruşturma notu: %s hakkında endişe verici bir ipucu bulundu." % s.display_name,
			tr("Soruşturma notu: %s hakkında endişe verici bir ipucu bulundu.") % s.display_name)
	else:
		var others: Array = actors.values()
		var w: Actor = others[rng.randi() % others.size()]
		_add_news("Soruşturma notu: %s hakkında endişe verici bir ipucu bulundu." % w.display_name,
			tr("Soruşturma notu: %s hakkında endişe verici bir ipucu bulundu.") % w.display_name)


## Çapraz doğrulama: bir kaynağın raporunu gerçek durumla kıyaslayan gürültülü ipucu.
func cross_check(id: String) -> String:
	if not spend_mesai():
		return _no_mesai()
	stats["checks"] += 1
	var a: Actor = actors[id]
	if INSTITUTION_HEADS.has(id):
		flags["DOGRULA_" + INSTITUTION_HEADS[id]] = week
	if id == "elena":
		flags["DOGRULA_ELENA"] = week
		foreign_hint_until = week + 6
		karne[id]["ok"] += 1
		changed.emit()
		return tr("Elçilik kayıtları altı hafta için açık: ") + foreign_report(true)
	var gap := _domain_truth(a.domain) - _domain_reported(a)
	var noisy := gap + rng.randf_range(-8.0, 8.0)
	var worse := (a.domain == "economy" and noisy < -6.0) or (a.domain != "economy" and noisy > 6.0)
	changed.emit()
	if absf(noisy) < 6.0:
		karne[id]["ok"] += 1
		return tr("%s raporu diğer kaynaklarla büyük ölçüde örtüşüyor.%s") % [a.display_name if Loc.lang == "en" else ek(a.display_name, "in"), tr(" Kurum defterleri bir süreliğine açıldı.") if INSTITUTION_HEADS.has(id) else ""]
	if worse:
		karne[id]["bad"] += 1
		return tr("Başka kaynaklar durumun %s anlattığından DAHA KÖTÜ olduğunu söylüyor.%s") % [a.display_name if Loc.lang == "en" else ek(a.display_name, "in"), tr(" Kurum defterleri bir süreliğine açıldı.") if INSTITUTION_HEADS.has(id) else ""]
	karne[id]["ok"] += 1
	return tr("Başka kaynaklar durumu %s anlattığından biraz daha iyi görüyor.%s") % [a.display_name if Loc.lang == "en" else ek(a.display_name, "in"), tr(" Kurum defterleri bir süreliğine açıldı.") if INSTITUTION_HEADS.has(id) else ""]


## Gizli operasyon: katılan her kişi sırrı bilir; çember büyüdükçe başarı ve sızıntı riski artar.
func operation(kind: String, ids: Array) -> String:
	if ids.is_empty() or ids.size() > 3:
		return tr("Operasyon için 1–3 kişi seç (Ctrl ile çoklu seçim).")
	if mesai < 2:
		return tr("Operasyon 2 mesai ister.")
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
				text = tr("Sahte kriz işe yaradı; gündem değişti.")
			else:
				unrest += 3.0
				king_strength -= 2.0
				text = tr("Operasyon amatörce kaldı; kimse inanmadı.")
		"bol":
			if ok:
				_set_parliament_base_opposition(parliament_base_opposition - 15.0)
				text = tr("Muhalefet kanatları birbirine düştü.")
			else:
				_set_parliament_base_opposition(parliament_base_opposition + 5.0)
				text = tr("Muhalefet planı fark etti ve birleşme hızlandı.")
		"zayiflat":
			var target: Actor = null
			for a: Actor in actors.values():
				if ids.has(a.id):
					continue
				if target == null or a.power > target.power:
					target = a
			if target == null:
				text = tr("Zayıflatılacak kimse yok.")
			elif ok:
				target.power = maxf(5.0, target.power - 12.0)
				target.ambition += 5.0
				text = tr("%s itibarı sarsıldı. Kim yaptığını tahmin etmesi zor değil.") % ek(target.display_name, "in")
			else:
				text = tr("Operasyon boşa gitti; %s şüphelendi.") % target.display_name
				target.ambition += 5.0
	text += tr(" (Çember: %s)") % ", ".join(names)
	if rng.randf() < leak_chance:
		_add_fact("operasyon_%d_%d" % [stats["ops"], week], "Gizli operasyon (%s)" % kind, "king", 45, ids.duplicate(), 1, 0.9)
		facts["operasyon_%d_%d" % [stats["ops"], week]]["common"] = 0.3
		text += tr(" Ama bir şey sızmış gibi.")
	changed.emit()
	return text


## Birbirine düşür (docs/design/birbirine_dusur.md): tam iki kişi, 2 mesai, aynı çift için bekleme.
const RIVAL_COOLDOWN := 6
const RIVAL_LEAK := 0.15


func rival_wait(ids: Array) -> int:
	if ids.size() != 2:
		return 0
	return maxi(0, int(flags.get(_rival_key(ids), -100)) + RIVAL_COOLDOWN - week)


func economy_policy(policy: String) -> String:
	if ended or mesai < 1 or policy not in ["tax_raise", "tax_relief", "austerity", "incentive"]:
		return _no_mesai() if mesai < 1 else ""
	if not spend_mesai():
		return _no_mesai()
	var key := "economy_policy_" + policy
	var uses := int(stats.get(key, 0))
	var scale := 1.0 / (1.0 + uses * 0.75)
	stats[key] = uses + 1
	match policy:
		"tax_raise":
			treasury = clampf(treasury + 4.0 * scale, 0.0, 100.0)
			economy = clampf(economy - 1.6 * scale, 0.0, 100.0)
			unrest = clampf(unrest + 0.7 * scale, 0.0, 100.0)
		"tax_relief":
			treasury = clampf(treasury - 3.0 * scale, 0.0, 100.0)
			economy = clampf(economy + 1.2 * scale, 0.0, 100.0)
			unrest = clampf(unrest - 0.3 * scale, 0.0, 100.0)
		"austerity":
			treasury = clampf(treasury + 3.5 * scale, 0.0, 100.0)
			economy = clampf(economy - 1.0 * scale, 0.0, 100.0)
			unrest = clampf(unrest + 1.8 * scale, 0.0, 100.0)
		"incentive":
			treasury = clampf(treasury - 4.0 * scale, 0.0, 100.0)
			delayed_economy.append({"due": week + 6, "sector": "industry", "share": 25.0 + 30.0 * scale})
	return tr("Maliye kararının etkisi başladı; aynı yöndeki her yeni hamle daha az sonuç verecek.")


func public_action(action: String) -> String:
	if ended or mesai < 1 or action not in ["speech", "visit", "ceremony", "hide"]:
		return _no_mesai() if mesai < 1 else ""
	if not spend_mesai():
		return _no_mesai()
	public_opinion_active = true
	match action:
		"speech": consent += 5.0; public_fear = maxf(0.0, public_fear - 2.0); unrest = maxf(0.0, unrest - 2.0)
		"visit":
			consent += 4.0
			public_fear = maxf(0.0, public_fear - 3.0)
			unrest = maxf(0.0, unrest - 1.0)
			if public_rng.randf() < 0.1:
				unrest = minf(100.0, unrest + 4.0)
		"ceremony": consent += 2.0; public_fear = maxf(0.0, public_fear - 1.0)
		"hide": consent = maxf(0.0, consent - 1.0); public_fear += 1.0
	consent = clampf(consent, 0.0, 100.0)
	public_fear = clampf(public_fear, 0.0, 100.0)
	changed.emit()
	return tr("Halkla kurduğun mesafe değişti; etkisi haftalara yayılacak.")


func public_opinion_line() -> String:
	if not public_opinion_active:
		return tr("Kamuoyu: Sarayın sesi henüz ölçülmedi.")
	var consent_band := tr("rıza sağlam") if consent >= 62.0 else (tr("rıza dalgalı") if consent >= 38.0 else tr("rıza zayıf"))
	var fear_band := tr("korku belirgin") if public_fear >= 55.0 else (tr("korku hissediliyor") if public_fear >= 30.0 else tr("korku düşük"))
	return tr("Kamuoyu: %s; %s.") % [consent_band, fear_band]


func _default_parliament_blocs() -> Dictionary:
	return {
		"royal": {"loyalty": 96.0, "pressure": 28.0},
		"opposition": {"loyalty": 56.0, "pressure": 18.0},
		"nobles": {"loyalty": 100.0, "pressure": 38.0},
		"independents": {"loyalty": 48.0, "pressure": 12.0}}


func _refresh_parliament_opposition() -> void:
	var weight := {"royal": 0.4, "opposition": 0.3, "nobles": 0.2, "independents": 0.1}
	var loyalty := 0.0
	for bloc in weight:
		loyalty += float(parliament_blocs.get(bloc, {}).get("loyalty", 50.0)) * float(weight[bloc])
	opposition = clampf(parliament_base_opposition + (80.0 - loyalty) * 0.1, 0.0, 100.0)


func _set_parliament_base_opposition(value: float) -> void:
	parliament_base_opposition = clampf(value, 0.0, 100.0)
	_refresh_parliament_opposition()


func parliament_report_line() -> String:
	var nobles: Dictionary = parliament_blocs.get("nobles", {})
	var independents: Dictionary = parliament_blocs.get("independents", {})
	var noble_line := tr("Soyluların desteği sağlam.") if float(nobles.get("loyalty", 50.0)) >= 65.0 else tr("Soyluların desteği pazarlığa açık.")
	var independent_line := tr("Bağımsızlar temkinli.") if float(independents.get("pressure", 0.0)) >= 35.0 else tr("Bağımsızlar kendi kararını verecek.")
	return tr("Meclis: %s %s") % [noble_line, independent_line] + " " + government_status_line()


func government_status_line() -> String:
	var pm_name := str(actors[government_pm].display_name) if actors.has(government_pm) else tr("Başbakanlık boş.")
	var finance_name := str(actors[finance_report_source].display_name) if actors.has(finance_report_source) else tr("Saray hazinesi")
	var coalition_names: Array[String] = []
	for bloc in government_coalition:
		coalition_names.append(_parliament_bloc_name(bloc))
	var coalition := " + ".join(coalition_names) if not coalition_names.is_empty() else tr("geçici yönetim")
	return tr("Hükümet: %s; %s. Maliye raporunu %s üstleniyor.") % [pm_name, coalition, finance_name]


func _parliament_bloc_name(bloc: String) -> String:
	return tr(str({"royal": "Saray listesi", "opposition": "Muhalefet", "nobles": "Soylular", "independents": "Bağımsızlar"}.get(bloc, "Meclis")))


func parliament_laws_line() -> String:
	if parliament_laws.is_empty():
		return tr("Yürürlükteki yasalar: Yok.")
	var names: Array[String] = []
	for law in parliament_laws:
		names.append(tr("%s — %s") % [_parliament_law_name(str(law)), _parliament_law_effect(str(law))])
	return tr("Yürürlükteki yasalar: %s.") % ", ".join(names)


func _parliament_law_name(law: String) -> String:
	var names := {"tax": "Vergi reformu", "press": "Basın yasası", "army": "Ordu bütçesi yasası",
		"election": "Seçim yasası", "amnesty": "Af yasası", "judicial": "Yargı reformu"}
	return tr(str(names.get(law, "Bilinmeyen yasa")))


func _parliament_law_effect(law: String) -> String:
	var effects := {"tax": "Hazine gelir buluyor; sokak yükünü hissediyor.",
		"press": "Leyla'nın sesi daha az yankı buluyor; rıza aşındı.", "army": "Arden'in etkisi ve ordunun payı genişledi.",
		"election": "Erken seçim için daha az meclis desteği yetiyor.", "amnesty": "Yargı baskısı bir miktar hafifledi.",
		"judicial": "Mahkemelerin kapasitesi arttı; dosyalar daha düzenli ilerliyor."}
	return tr(str(effects.get(law, "Etki bilinmiyor.")))


func respond_to_scandal(fid: String, response: String) -> String:
	if not facts.has(fid) or not bool(facts[fid].get("public", false)) or facts[fid].get("subject", "") != "king" or facts[fid].has("response"):
		return ""
	if response not in ["deny", "apologize", "scapegoat", "redirect"] or not spend_mesai():
		return _no_mesai()
	public_opinion_active = true
	var fact: Dictionary = facts[fid]
	fact["response"] = response
	match response:
		"deny":
			consent -= 4.0
			public_fear += 3.0
			fact["leakiness"] = minf(1.0, float(fact.get("leakiness", 0.5)) + 0.2)
		"apologize":
			consent += 5.0
			public_fear = maxf(0.0, public_fear - 2.0)
			_set_parliament_base_opposition(parliament_base_opposition + 2.0)
		"scapegoat":
			consent += 1.0
			for id in fact.get("knowers", []):
				if actors.has(id) and not actors[id].supporting:
					actors[id].power = maxf(5.0, actors[id].power - 8.0)
					flags["SCANDAL_REVENGE_" + str(id)] = week
					break
		"redirect":
			consent -= 1.0
			fact["common"] = maxf(0.5, float(fact.get("common", 0.5)) - 0.1)
	consent = clampf(consent, 0.0, 100.0)
	public_fear = clampf(public_fear, 0.0, 100.0)
	changed.emit()
	return tr("Yanıtın kamuoyundaki yankısı başladı.")


func _tick_public_opinion() -> void:
	if not public_opinion_active:
		return
	consent = clampf(consent + (king_strength - 60.0) * 0.015 - maxf(0.0, unrest - 35.0) * 0.025, 0.0, 100.0)
	public_fear = clampf(public_fear - 0.08 + (echo_level() - 0.5) * 0.06, 0.0, 100.0)
	# The legacy unrest track stays untouched until the player opts into this system.
	unrest = clampf((100.0 - consent) * 0.7 + public_fear * 0.6, 0.0, 100.0)
	# Existing campaigns keep their event schedule until the player opts into public-opinion play.
	if week < maxi(8, last_poll_week + 8) or pending.size() >= 3:
		return
	last_poll_week = week
	var sources := [tr("Sarne'nin anket şirketi"), tr("Leyla'nın gazetesi"), tr("bağımsız bir kurum")]
	var source := str(sources[public_rng.randi_range(0, 2)])
	var estimate := consent + (8.0 if source == sources[0] else (-8.0 if source == sources[1] else public_rng.randf_range(-12.0, 12.0)))
	var band := tr("desteğin güçlü görünüyor") if estimate >= 62.0 else (tr("desteğin dalgalanıyor") if estimate >= 38.0 else tr("desteğin zayıflıyor"))
	var title := tr("Kamuoyu araştırması")
	pending.append({"event": {"id": "public_poll_%d" % week, "title": title, "text": tr("%s: %s. Anketi yayımlamak algıyı etkiler.") % [tr(source), band], "kind": "public_poll",
		"choices": [{"label": tr("Yayımla"), "text": tr("Rapor meydanlara ulaştı."), "fx": {"consent": 3.0, "fear": -1.0}},
			{"label": tr("İçeride tut"), "text": tr("Sonuç yalnızca sarayda kaldı."), "fx": {"consent": 1.0, "fear": 1.0}}], "ignore": {"text": tr("Anket yayımlanmadı."), "fx": {}}}, "age": 0})


func _rival_key(ids: Array) -> String:
	var parts: Array = []
	for i in ids:
		parts.append(str(i).to_upper())
	parts.sort()
	return "DUS_" + "_".join(PackedStringArray(parts))


func divide_rivals(ids: Array) -> String:
	if ids.size() != 2:
		return tr("Birbirine düşürmek için tam iki kişi seç (Çoklu seçim).")
	var a: Actor = actors.get(ids[0])
	var b: Actor = actors.get(ids[1])
	if a == null or b == null:
		return tr("Seçilen kişilerden biri artık sarayda değil.")
	if a.moved or b.moved:
		return tr("Sana karşı harekete geçmiş biriyle oyun oynamak işe yaramaz.")
	var wait := rival_wait(ids)
	if wait > 0:
		return Loc.ntr("%s ile %s'i yakın zamanda birbirine düşürmeyi denedin; %d hafta bekle.", wait) % [a.display_name, b.display_name, wait]
	if mesai < 2:
		return tr("Birbirine düşürmek 2 mesai ister.")
	spend_mesai(2)
	stats["rivalries"] = int(stats.get("rivalries", 0)) + 1
	flags[_rival_key(ids)] = week
	var chance := clampf(0.4 + (a.ambition + b.ambition) / 400.0, 0.25, 0.8)
	var text := ""
	if rng.randf() < chance:
		for x: Actor in [a, b]:
			x.power = maxf(5.0, x.power - 4.0)
			x.ambition = maxf(0.0, x.ambition - 3.0)
			x.fear += 4.0
		text = tr("%s ile %s birbirine girdi. İkisi de artık birbirini izliyor; sana ayıracak zamanları az.") % [a.display_name, b.display_name]
	else:
		for x: Actor in [a, b]:
			x.ambition += 6.0
			x.loyalty["money"] = maxf(0.0, float(x.loyalty["money"]) - 4.0)
		_add_fact("dusurme_%d_%d" % [stats["rivalries"], week], "Kralın danışmanlarını birbirine düşürme girişimi", "king", 30, [a.id, b.id], 1, 0.7)
		text = tr("%s ile %s oyunu anladı: iki taraf da bunun arkasında kimin olduğunu biliyor.") % [a.display_name, b.display_name]
	if rng.randf() < RIVAL_LEAK:
		_add_fact("dusurme_sizinti_%d_%d" % [stats["rivalries"], week], "Saray içi rekabetin kralca kışkırtılması", "king", 20, [a.id, b.id], 1, 0.6)
		text += tr(" Bir şey sızmış gibi.")
	changed.emit()
	return text


## Bir olguyu yay (ortak bilgi artar) ya da bastır.
func leak_fact(fact_id: String) -> String:
	if not facts.has(fact_id) or not spend_mesai():
		return tr("Olmadı (mesai ya da dosya yok).")
	stats["leaks"] += 1
	facts[fact_id]["common"] = minf(1.0, facts[fact_id]["common"] + 0.5)
	changed.emit()
	return tr("'%s' basına sızdırıldı.") % fact_text_for_display(facts[fact_id])


func suppress_fact(fact_id: String) -> String:
	if not facts.has(fact_id) or not spend_mesai():
		return tr("Olmadı (mesai ya da dosya yok).")
	var f: Dictionary = facts[fact_id]
	f["common"] = maxf(0.0, f["common"] - 0.3)
	changed.emit()
	return tr("'%s' için sessizlik sağlandı. Kanıtın kopyaları hâlâ duruyor.") % fact_text_for_display(f)


## Kanıtı yok et: kopya sayısı kadar zor; yok etme girişimi de iz bırakabilir.
func destroy_evidence(fact_id: String) -> String:
	if not facts.has(fact_id):
		return tr("Dosya yok.")
	if not spend_mesai():
		return _no_mesai()
	var f: Dictionary = facts[fact_id]
	if f.get("public", false):
		return tr("Bu artık herkesin bildiği bir şey; kanıtı yok etmek işe yaramaz.")
	if int(f["copies"]) > 1:
		f["copies"] = int(f["copies"]) - 1
		changed.emit()
		return tr("'%s' kanıtının bir kopyası yok edildi; hâlâ kopyaları var.") % fact_text_for_display(f)
	if rng.randf() < 0.7:
		facts.erase(fact_id)
		changed.emit()
		return tr("Kanıt yok edildi.")
	f["common"] = minf(1.0, float(f["common"]) + 0.2)
	changed.emit()
	return tr("Girişim fark edildi; dosya hakkında dedikodu arttı.")


# ---------------------------------------------------------------- Söz defteri

func prize_taken(prize: String) -> bool:
	for p in promises:
		if p["prize"] == prize and p["state"] == "kept":
			return true
	return false


func active_promises_of(id: String) -> Array:
	var out: Array = []
	for p in promises:
		if p["actor"] == id and p["state"] == "active":
			out.append(p)
	return out


## Söz ver: hemen sadakat getirir; vadesi gelince karşılığı istenir.
func promise(id: String, prize: String) -> String:
	var a: Actor = actors[id]
	if prize_taken(prize):
		return tr("%s artık verilemez; zaten birine verildi.") % prize
	for p in active_promises_of(id):
		if p["prize"] == prize:
			return tr("%s bunu zaten vaat ettin.") % ek(a.display_name, "e")
	if not spend_mesai():
		return _no_mesai()
	stats["promises"] = int(stats.get("promises", 0)) + 1
	promises.append({"id": "%s_%d_%d" % [id, PRIZES.find(prize), week], "actor": id, "prize": prize,
		"made": week, "due": week + 6 + rng.randi_range(0, 4), "delays": 0, "state": "active",
		"asked": false, "exposed": false})
	a.loyalty["career"] = float(a.loyalty["career"]) + 12.0
	a.ambition += 2.0
	changed.emit()
	return tr("%s %s sözü verdin. Gözleri parladı; vadesi geldiğinde hatırlatacak.") % [ek(a.display_name, "e"), prize]


func _find_promise(pid: String) -> Dictionary:
	for p in promises:
		if p["id"] == pid:
			return p
	return {}


func _tick_promises() -> void:
	# Aynı ödülü birden çok kişiye vaat etmek: er geç duyulur.
	for prize in PRIZES:
		var group: Array = []
		for p in promises:
			if p["prize"] == prize and p["state"] == "active" and actors.has(p["actor"]):
				group.append(p)
		if group.size() < 2:
			continue
		var all_exposed := true
		for p in group:
			if not p["exposed"]:
				all_exposed = false
		if all_exposed or rng.randf() > 0.12:
			continue
		var names: Array[String] = []
		for p in group:
			p["exposed"] = true
			var a: Actor = actors[p["actor"]]
			names.append(a.display_name)
			a.loyalty["career"] = maxf(0.0, float(a.loyalty["career"]) - 8.0)
			a.ambition += 5.0
		_add_fact("celiski_%s_%d" % [PRIZES.find(prize), week], "Aynı makamın birden çok kişiye vaat edilmesi (%s)" % prize,
			"king", 20, group.map(func(p: Dictionary) -> String: return p["actor"]), 1, 0.5,
			"The same office promised to several people (%s)" % prize)
		_add_news("KULİS: %s aynı sözü aldıklarını öğrendi: %s." % [" ve ".join(names), prize],
			tr("KULİS: %s aynı sözü aldıklarını öğrendi: %s.") % [" ve ".join(names), prize])
	# Vadesi gelen sözler karar kartına dönüşür.
	for p in promises:
		if p["state"] != "active" or p["asked"] or week < int(p["due"]):
			continue
		if not actors.has(p["actor"]) or actors[p["actor"]].moved:
			p["state"] = "void"
			continue
		p["asked"] = true
		var a: Actor = actors[p["actor"]]
		var rival := ""
		for q in promises:
			if q != p and q["prize"] == p["prize"] and q["state"] == "active" and actors.has(q["actor"]):
				rival = actors[q["actor"]].display_name
		var text := tr("%s, %d. haftada verdiğin '%s' sözünü hatırlatıyor. Bekleyişi sabırlı, ama sonsuz değil.") % [a.display_name, p["made"], p["prize"]]
		if rival != "":
			text += tr(" Aynı sözü %s de vermiştin.") % ek(rival, "e")
		pending.append({"age": 0, "event": {"id": "soz_" + str(p["id"]), "title": "%s sözünü hatırlatıyor" % a.display_name, "text": text,
			"choices": [
				{"label": tr("Sözü tut: %s") % p["prize"], "text": tr("%s sözünü aldı. Bunu unutmayacak.") % a.display_name, "fx": {"promise_keep": p["id"]}},
				{"label": tr("Biraz daha zaman iste"), "text": tr("%s bekleyecek. Ama hevesi azaldı.") % a.display_name, "fx": {"promise_delay": p["id"]}},
				{"label": tr("Sözden dön"), "text": tr("%s yüzüne bakmadan çıktı. Saray bunu konuşacak.") % a.display_name, "fx": {"promise_break": p["id"]}}],
			"ignore": {"text": tr("Söz cevapsız kaldı; bozulmuş sayıldı."), "fx": {"promise_break": p["id"]}}}})
		_add_news("SÖZ: %s karşılığını istiyor." % a.display_name,
			tr("SÖZ: %s karşılığını istiyor.") % a.display_name)


func _keep_promise(p: Dictionary) -> void:
	if p.is_empty() or p["state"] != "active":
		return
	p["state"] = "kept"
	stats["kept"] = int(stats.get("kept", 0)) + 1
	var a: Actor = actors.get(p["actor"])
	if a != null:
		a.loyalty["career"] = float(a.loyalty["career"]) + 6.0
		a.obligation = maxf(0.0, a.obligation - 10.0)
		match p["prize"]:
			"Naiplik", "Başbakanlık":
				a.power += 16.0
				king_strength -= 2.0
			"Liman İhalesi":
				a.power += 8.0
				a.loyalty["money"] = float(a.loyalty["money"]) + 8.0
				private_wealth += 4.0
			_:
				a.power += 6.0
				a.fear = maxf(0.0, a.fear - 15.0)
	# Aynı ödülü bekleyen diğerleri ihanete uğramış sayılır.
	for q in promises:
		if q != p and q["prize"] == p["prize"] and q["state"] == "active":
			_break_promise(q, true)


func _break_promise(p: Dictionary, betrayed := false) -> void:
	if p.is_empty() or p["state"] != "active":
		return
	p["state"] = "broken"
	stats["broken"] = int(stats.get("broken", 0)) + 1
	var a: Actor = actors.get(p["actor"])
	if a != null:
		a.loyalty["career"] = maxf(0.0, float(a.loyalty["career"]) - 15.0)
		a.ambition += 12.0 if betrayed else 9.0
		_add_fact("bozulan_soz_%s" % p["id"], "%s verilip tutulmayan söz (%s)" % [ek(a.display_name, "e"), p["prize"]], "king", 15, [a.id], 1, 0.5,
			"Promise made to %s and not kept (%s)" % [a.display_name, p["prize"]])
		facts["bozulan_soz_%s" % p["id"]]["common"] = 0.2
		if betrayed:
			_extra_msgs.append("%s, kendisine vaat edilen %s başkasına verildiği için öfkeli." % [a.display_name, p["prize"]])
	for o: Actor in actors.values():
		o.perceived_king -= 2.0


## Görevden alma: kral hakkında çok şey bilen biri karşı atak yapar.
func dismiss(id: String) -> String:
	var a: Actor = actors[id]
	if not spend_mesai():
		return _no_mesai()
	stats["dismissals"] += 1
	if INSTITUTION_HEADS.has(id):
		var institution: String = INSTITUTION_HEADS[id]
		capacity[institution] = maxf(5.0, float(capacity[institution]) - 12.0)
		flags["KURUM_%s_BOS" % institution] = week
	if a.secrets_on_king >= 2 or a.power >= 60.0:
		a.moved = true
		a.ready = true
		a.plot_stage = 3
		if id == finance_report_source:
			finance_report_source = "dorn" if id != "dorn" and actors.has("dorn") and not actors["dorn"].moved else "kessler"
		king_strength -= 12.0
		_add_fact("sizinti_%s" % id, "%s kralın sırlarını sızdırıyor" % a.display_name, "king", 60, [id], 1, 0.9,
			"%s is leaking the King's secrets" % a.display_name)
		changed.emit()
		return tr("%s görevden alındı ama kralın sırlarını biliyordu ve konuşmaya başladı!") % a.display_name
	actors.erase(id)
	if id == finance_report_source:
		finance_report_source = "dorn" if id != "dorn" and actors.has("dorn") and not actors["dorn"].moved else "kessler"
	if coup_crisis.get("leader", "") == id:
		_close_crisis()
		plot_log.append({"w": week, "name": a.display_name, "text": "darbe gecesi görevden alındı; komplo başsız kaldı"})
	king_strength += 2.0
	changed.emit()
	return tr("%s görevden alındı. Sessizce gitti.") % a.display_name


# ---------------------------------------------------------------- Kararlar

func resolve_decision(pending_index: int, choice_index: int) -> String:
	if ended or pending_index < 0 or pending_index >= pending.size():
		return ""
	var e: Dictionary = pending[pending_index]["event"]
	var ch: Dictionary = e["choices"][choice_index]
	if not ch.get("available", true):
		return tr("Bu kararın gerektirdiği kişi artık sarayda değil.")
	if e.get("kind", "") == "patronage":
		if choice_index == 2 and (not actors.has("lena") or actors["lena"].moved or Press.is_closed(self, "free")):
			return tr("Leyla artık bağımsız yayın kuramıyor.")
		if choice_index == 3 and (not actors.has("falk") or actors["falk"].moved):
			return tr("Renn artık savcılığa başvuramıyor.")
	if e.get("kind", "") == "parliament_bill" and str(ch.get("bill_action", "")) == "force" and not _can_force_parliament():
		return tr("Baskı kurmak için hazine, kişisel servet ve yeterli otorite gerekir.")
	if e.get("kind", "") == "parliament_repeal" and str(ch.get("bill_action", "")) == "repeal" and treasury < -float(ch.get("fx", {}).get("treasury", 0.0)):
		return tr("Yasayı kaldırmak için hazine yetersiz.")
	var fx: Dictionary = ch.get("fx", {})
	if float(fx.get("wealth", 0)) + private_wealth < 0.0:
		return tr("Kişisel servetin yetersiz.")
	if e.get("kind", "") == "regional_action" and str(ch.get("action", "")) == "select_region":
		pending.remove_at(pending_index)
		_queue_region_action_options(str(ch.get("region", "")))
		changed.emit()
		return tr("Bölge seçildi; şimdi tahsis türünü belirle.")
	if e.get("kind", "") != "parliament_bill" and not spend_mesai():
		return _no_mesai()
	if e.get("crisis", false):
		pending.remove_at(pending_index)
		history.append(tr("Hafta %d — %s » %s") % [week, e["title"], ch["label"]])
		var kind := str(e.get("crisis_kind", "coup"))
		var crisis_text := _resolve_crisis(str(ch.get("crisis", ""))) if kind == "coup" else (_resolve_regional_crisis(ch) if kind == "regional" else _resolve_other(str(ch.get("crisis", ""))))
		if coup_crisis.get("failed", false) or other_crisis.get("failed", false):
			end_week()  # kapılar açıldı: kriz bu gece sonuçlanır
		changed.emit()
		return crisis_text
	if e.get("kind", "") == "public_poll":
		pending.remove_at(pending_index)
		_apply_effects(fx)
		history.append(tr("Hafta %d — %s » %s") % [week, e["title"], ch["label"]])
		changed.emit()
		return str(ch.get("text", ""))
	_log_advice(e, advice_for(pending_index), choice_index)
	pending.remove_at(pending_index)
	flags["%s_%d" % [e["id"], choice_index]] = week
	if e.get("kind", "") == "patronage":
		var patronage_text := _resolve_patronage(choice_index, int(e["level"]))
		_adjust_parliament_patronage(choice_index)
		history.append(tr("Hafta %d — %s » %s") % [week, e["title"], ch["label"]])
		changed.emit()
		return patronage_text
	if e.get("kind", "") == "parliament_bill":
		return _resolve_parliament_bill(e, choice_index)
	if e.get("kind", "") == "parliament_repeal":
		return _resolve_parliament_repeal(e, choice_index)
	if e.get("kind", "") == "regional_action":
		var region_result := _resolve_region_action(ch)
		history.append(tr("Hafta %d — %s » %s") % [week, e["title"], ch["label"]])
		changed.emit()
		return region_result
	if e.get("kind", "") in ["election_result", "government_formation", "confidence_vote", "government_appointment"]:
		var government_result := _resolve_r3c_decision(e, choice_index)
		history.append(tr("Hafta %d — %s » %s") % [week, e["title"], ch["label"]])
		changed.emit()
		return government_result
	_extra_msgs.clear()
	_apply_effects(fx)
	history.append(tr("Hafta %d — %s » %s") % [week, e["title"], ch["label"]])
	changed.emit()
	var out := str(ch.get("text", ""))
	if not _extra_msgs.is_empty():
		out += " " + " ".join(_extra_msgs)
	return out


func _apply_effects(fx: Dictionary) -> void:
	unrest = clampf(unrest + float(fx.get("unrest", 0)), 0.0, 100.0)
	economy = clampf(economy + float(fx.get("economy", 0)), 0.0, 100.0)
	king_strength = clampf(king_strength + float(fx.get("king", 0)), 0.0, 100.0)
	_set_parliament_base_opposition(parliament_base_opposition + float(fx.get("opp", 0)))
	consent = clampf(consent + float(fx.get("consent", 0)), 0.0, 100.0)
	public_fear = clampf(public_fear + float(fx.get("fear", 0)), 0.0, 100.0)
	private_wealth = maxf(0.0, private_wealth + float(fx.get("wealth", 0)))
	treasury = clampf(treasury + float(fx.get("treasury", 0)), 0.0, 100.0)
	holding = clampf(holding + float(fx.get("holding", 0)), 0.0, 100.0)
	for power in fx.get("foreign", {}):
		if foreign.has(power):
			foreign[power] = clampf(float(foreign[power]) + float(fx["foreign"][power]), 0.0, 100.0)
	for institution in fx.get("capacity", {}):
		if capacity.has(institution):
			capacity[institution] = clampf(float(capacity[institution]) + float(fx["capacity"][institution]), 5.0, 100.0)
	if fx.has("budget_stance"):
		budget_stance = int(fx["budget_stance"])
	if fx.has("court_share"):
		court_share = bool(fx["court_share"])
		if court_share:
			if not flags.has("SARAY_PAYI_BASLADI"):
				flags["SARAY_PAYI_BASLADI"] = week
			_add_fact("saray_payi_%d" % week, "saray payı devlet kasasından ayrılıyor", "king", 18, ["kessler", "dorn"], 1)
		else:
			flags.erase("SARAY_PAYI_BASLADI")
	if fx.has("budget_allocation"):
		_set_budget_allocation(fx["budget_allocation"])
	elif bool(fx.get("budget_custom", false)):
		_set_budget_allocation(budget_allocation.duplicate())
	var af: Dictionary = fx.get("actors", {})
	for aid in af:
		if actors.has(aid):
			for prop in af[aid]:
				_bump(actors[aid], str(prop), float(af[aid][prop]))
	if fx.has("fact"):
		var fd: Dictionary = fx["fact"]
		var fact_id := str(fd["id"])
		_add_fact(fact_id, fd["text"], fd["subject"], fd["severity"], fd["knowers"], 1, 0.5, _fact_text_en(fact_id, str(fd["text"])))
	if fx.has("flag"):
		flags[fx["flag"]] = week
	# Bir dosyayı herkesin bildiği hâle getir (eski karar geri döner).
	for fid in _as_array(fx.get("leak", [])):
		if facts.has(fid):
			facts[fid]["common"] = 1.0
	# Söz defteri kararları
	if fx.has("promise_keep"):
		_keep_promise(_find_promise(str(fx["promise_keep"])))
	if fx.has("promise_break"):
		_break_promise(_find_promise(str(fx["promise_break"])))
	if fx.has("promise_delay"):
		var pd := _find_promise(str(fx["promise_delay"]))
		if not pd.is_empty() and pd["state"] == "active":
			pd["delays"] = int(pd["delays"]) + 1
			if int(pd["delays"]) > 2:
				_break_promise(pd)
			else:
				pd["due"] = week + 3
				pd["asked"] = false
				var ad: Actor = actors.get(pd["actor"])
				if ad != null:
					ad.loyalty["career"] = maxf(0.0, float(ad.loyalty["career"]) - 4.0)
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


# ---------------------------------------------------------------- Meclis görüşleri
## Meclis görüşlerinin dış API'si (davranış `advice.gd` içinde).
func choice_value(fx: Dictionary) -> float:
	return _advice.choice_value(fx)

func short_name(a: Actor) -> String:
	return _advice.short_name(a)

func advice_for(pending_index: int) -> Array:
	return _advice.advice_for(pending_index)

func _log_advice(e: Dictionary, advice: Array, chosen: int) -> void:
	_advice._log_advice(e, advice, chosen)

## Oyun sonu: gördüğün alametlerin kaçı gerçekti?
func sign_record() -> Dictionary:
	var real := 0
	var rumor := 0
	for a: Actor in actors.values():
		for g: Dictionary in a.signs:
			if g["real"]:
				real += 1
			else:
				rumor += 1
	return {"real": real, "rumor": rumor}


func council_record() -> Array:
	return _advice.council_record()


# ---------------------------------------------------------------- Haftalık tick

func end_week() -> void:
	if ended:
		return
	var before := _visible_snapshot()
	# Haftanın haberleri burada sıfırlanır: ertelenen kararların haberi de oyuncuya ulaşsın
	# (eskiden aşağıda ekleniyor, hemen ardından siliniyordu).
	weekly_news.clear()
	weekly_news_localized.clear()
	weekly_moves.clear()
	# Ertelenen kararlar kendi kendine çözülür (olgunlaşır).
	var keep: Array = []
	var government_fell := false
	for p in pending:
		p["age"] += 1
		if p["age"] >= 2:
			var e: Dictionary = p["event"]
			var ig: Dictionary = e.get("ignore", {"text": "Karar ertelendi.", "fx": {"unrest": 3}})
			if e.get("kind", "") == "parliament_bill":
				var proposal: Dictionary = e.get("proposal", {})
				proposal["status"] = "lapsed"
				proposal["result"] = tr("Teklif oylanmadan gündemden düştü.")
				_fail_parliament_proposal()
			if e.get("kind", "") == "confidence_vote":
				government_pm = ""
				government_coalition.clear()
				finance_report_source = "dorn"
				stats["confidence_falls"] = int(stats.get("confidence_falls", 0)) + 1
				government_fell = true
			elif e.get("kind", "") == "government_appointment":
				_set_government("dorn", ["royal", "independents"])
				_apply_effects({"king": -8.0, "treasury": -5.0, "unrest": 5.0, "opp": 3.0})
			flags[str(e["id"]) + "_ertelendi"] = week
			_apply_effects(ig.get("fx", {}))
			var line := "ERTELENDİ — %s: %s" % [e["title"], ig.get("text", "")]
			history.append(tr("Hafta %d — %s » (ertelendi)") % [week, e["title"]])
			_add_news(line, tr("ERTELENDİ — %s: %s") % [e["title"], ig.get("text", "")])
		else:
			keep.append(p)
	pending = keep
	if government_fell:
		_queue_government_appointment()
	week += 1
	mesai = mesai_max
	_world_tick()
	_tick_public_opinion()
	_tick_budget_effects()
	_tick_region_systems()
	_state_warnings()
	_decay_facts()
	_fire_events()
	_fire_budget()
	_fire_patronage()
	_tick_parliament()
	if regime == "" and week >= 60:
		regime = _choose_regime()
		flags["REJIM_" + regime.to_upper()] = week
		_add_news("REJİM: Saray artık %s bir düzen olarak anılıyor." % regime_name(),
			tr("REJİM: Saray artık %s bir düzen olarak anılıyor.") % tr(regime_name()))
	_tick_promises()
	_run_cascade()
	_check_crises()
	_plot_signs()
	_generate_reports()
	_record_timeline()
	week_changes = _diff_visible(before, _visible_snapshot())
	if week == 60 and regime != "":
		if week_changes.size() >= CHANGES_MAX:
			week_changes.pop_back()
		week_changes.append({"tone": 0, "actor": "", "text": tr("Yönetimin %s bir rejim olarak anılmaya başladı.") % tr(regime_name())})
	_check_end()
	_sync_regions_to_national()
	if autosave and not ended:
		save_game()
	for n in weekly_news:
		news.emit(news_for_display(n))
	week_advanced.emit(week)
	changed.emit()


## Güç kademesi (kişi kartında görünen): 1 ikinci planda, 2 etkili, 3 vazgeçilmez.
static func power_tier(power: float) -> int:
	return 1 if power < 40.0 else (2 if power < 65.0 else 3)


var POWER_TIER_NAMES: Array = []
var REPORT_TONES: Array = []   # raporun söylediği band
const CHANGES_MAX := 6


## "Neler değişti?" için oyuncunun zaten görebildiği göstergelerin fotoğrafı. Gizli değer yok:
## rapor tonu, güç kademesi, tavır (görülen alametler), düşmanlık, sözler. rng tüketmez.
func _visible_snapshot() -> Dictionary:
	var bands := {}
	for r: Dictionary in reports:
		bands[str(r["source"])] = int(r["band"])
	var people := {}
	for a: Actor in actors.values():
		people[a.id] = {"name": a.display_name, "power": power_tier(a.power),
			"susp": suspicion_level(a.id) if a.insider else -1, "moved": a.moved}
	var prom := {}
	for p: Dictionary in promises:
		var nm: String = actors[p["actor"]].display_name if actors.has(p["actor"]) else str(p["actor"])
		prom[str(p["id"])] = {"state": str(p["state"]), "asked": bool(p.get("asked", false)), "name": nm, "prize": str(p["prize"])}
	return {"bands": bands, "people": people, "promises": prom, "halden_mood": halden_mood()}


## İki fotoğrafın farkı + bu haftanın kulis/manşet ve kendiliğinden çözülen kararları.
## tone: -1 kötü, 0 dikkat, +1 iyi. Önce kötüler; en çok CHANGES_MAX satır.
func _diff_visible(b: Dictionary, n: Dictionary) -> Array:
	var out: Array = []
	for line in weekly_news:
		var s := str(line)
		if s.begins_with("ERTELENDİ — "):
			out.append({"tone": 0, "actor": "", "text": tr("Kendiliğinden çözüldü: %s.") % s.substr(12).split(":")[0]})
		elif s.begins_with("MANŞET: "):
			var headline_shown := news_for_display(s)
			out.append({"tone": -1, "actor": "", "text": headline_shown.substr(headline_shown.find(": ") + 2)})
		elif s.begins_with("KULİS: "):
			var backroom_shown := news_for_display(s)
			out.append({"tone": 0, "actor": "", "text": backroom_shown.substr(backroom_shown.find(": ") + 2)})
		elif s.begins_with("SOKAK: ") or s.begins_with("MAHKEME: ") or s.begins_with("MALİYE: ") or s.begins_with("ADLİYE: ") or s.begins_with("İDARE: ") or s.begins_with("ORDU: ") or s.begins_with("DIŞİŞLERİ: "):
			var warning_shown := news_for_display(s)
			out.append({"tone": -1, "actor": "", "text": warning_shown.substr(warning_shown.find(": ") + 2)})
	for mv: Dictionary in weekly_moves:
		out.append(mv.duplicate())
	if b["halden_mood"] != n["halden_mood"]:
		out.append({"tone": -1 if n["halden_mood"] == "düşmanca" else 0, "actor": "halden",
			"text": tr("Sarne'nin yayınlarının havası değişti: artık %s.") % tr(str(n["halden_mood"]))})
	for id in b["people"]:
		var p0: Dictionary = b["people"][id]
		var name: String = p0["name"]
		if not n["people"].has(id):
			out.append({"tone": 0, "actor": "", "text": tr("%s artık sarayda değil.") % name})
			continue
		var p1: Dictionary = n["people"][id]
		if p1["moved"] and not p0["moved"]:
			out.append({"tone": -1, "actor": id, "text": tr("%s sana karşı açıkça harekete geçti.") % name})
			continue
		var s0 := int(p0["susp"])
		var s1 := int(p1["susp"])
		if s0 >= 0 and s1 != s0:
			out.append({"tone": -1 if s1 > s0 else 1, "actor": id,
				"text": tr("%s tavrı %s: artık %s.") % [Loc.poss(name) if Loc.lang == "en" else ek(name, "in"), tr("sertleşti" if s1 > s0 else "yumuşadı"), tr(str(SUSPICION_NAMES[s1]).to_lower())]})
		var t0 := int(p0["power"])
		var t1 := int(p1["power"])
		if t1 != t0:
			out.append({"tone": 0, "actor": id,
				"text": tr("%s %s: artık %s.") % [name, tr("güçlendi" if t1 > t0 else "güç kaybetti"), tr(str(POWER_TIER_NAMES[t1]))]})
	for src in n["bands"]:
		if b["bands"].has(src) and n["people"].has(src):
			var d := int(n["bands"][src]) - int(b["bands"][src])
			if d != 0:
				var report_name := str(n["people"][src]["name"])
				if Loc.lang == "en":
					report_name = Loc.poss(report_name)
				else:
					report_name = ek(report_name, "in")
				out.append({"tone": -1 if d > 0 else 1, "actor": src,
					"text": tr("%s raporu %s: artık %s.") % [report_name, tr("kötüleşti" if d > 0 else "iyileşti"), tr(str(REPORT_TONES[int(n["bands"][src])]))]})
	for pid in n["promises"]:
		if not b["promises"].has(pid):
			continue  # bu hafta verilen sözü oyuncu zaten biliyor
		var q0: Dictionary = b["promises"][pid]
		var q1: Dictionary = n["promises"][pid]
		var who := ek(str(q1["name"]), "e")
		if q1["state"] != q0["state"]:
			match str(q1["state"]):
				"kept":
					out.append({"tone": 1, "actor": "", "text": tr("%s verdiğin %s sözü tutuldu.") % [who, q1["prize"]]})
				"broken":
					out.append({"tone": -1, "actor": "", "text": tr("%s verdiğin %s sözü bozuldu.") % [who, q1["prize"]]})
				_:
					out.append({"tone": 0, "actor": "", "text": tr("%s verdiğin %s sözü geçersiz kaldı.") % [who, q1["prize"]]})
		elif q1["asked"] and not q0["asked"]:
			out.append({"tone": 0, "actor": "", "text": tr("%s %s sözünün karşılığını istiyor.") % [q1["name"], q1["prize"]]})
	out.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return int(x["tone"]) < int(y["tone"]))
	return out.slice(0, CHANGES_MAX)


## Hakikat Dosyası grafiği için gerçek (gizli) durumun haftalık kaydı.
func _record_timeline() -> void:
	timeline.append({"w": week, "king": snappedf(king_strength, 0.1), "unrest": snappedf(unrest, 0.1),
		"economy": snappedf(economy, 0.1), "opp": snappedf(opposition, 0.1), "plot": snappedf(_ready_power_share() * 100.0, 0.1),
		"foreign": snappedf(_foreign_average(), 0.1), "heir": snappedf(heir_maturity, 0.1)})
	capacity_timeline.append({"w": week, "maliye": capacity["maliye"], "hukuk": capacity["hukuk"],
		"ordu": capacity["ordu"], "idare": capacity["idare"], "holding": holding})


func _world_tick() -> void:
	var brandt: Actor = actors.get("brandt")
	for a: Actor in actors.values():
		if a.supporting:
			continue
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
	_set_parliament_base_opposition(parliament_base_opposition + opp_push)
	unrest = clampf(unrest + rng.randf_range(-3.0, 3.0) + (50.0 - economy) * 0.05 + (opposition - 40.0) * 0.01 - (unrest - 30.0) * 0.06, 0.0, 100.0)
	street_anger *= STREET_ANGER_DECAY
	unrest = clampf(unrest + street_anger * STREET_FEED, 0.0, 100.0)
	economy = clampf(economy + rng.randf_range(-2.5, 2.8) - unrest * 0.02 + (55.0 - economy) * 0.03, 0.0, 100.0)
	king_strength = clampf(king_strength - unrest * 0.012 - opposition * 0.004 + (economy - 50.0) * 0.01 + 0.4, 0.0, 100.0)
	private_wealth += _diff("income")  # sivil liste ödeneği
	_tick_state()
	_tick_holding()
	_tick_foreign()
	_tick_external_pressure()
	_update_economy_metrics()
	if heir_maturity >= 70.0 and actors.has("julian") and not actors["julian"].moved:
		unrest = maxf(0.0, unrest - 0.015)
		king_strength = minf(100.0, king_strength + 0.0075)


func _tick_state() -> void:
	for institution in capacity:
		capacity[institution] = clampf(float(capacity[institution]) - ATTRITION * STATE_DIFF[difficulty] + budget_stance * STANCE_CAP, 5.0, 100.0)
		var vacancy := "KURUM_%s_BOS" % institution
		if flags.has(vacancy) and week - int(flags[vacancy]) >= 6:
			capacity[institution] = minf(100.0, float(capacity[institution]) + 5.0)
			flags.erase(vacancy)
	economy = clampf(economy + (float(capacity["maliye"]) - 55.0) * STATE_ECON_MALIYE
		+ (float(capacity["hukuk"]) - 55.0) * STATE_ECON_HUKUK + budget_stance * 0.08, 0.0, 100.0)
	treasury = clampf(treasury + (economy - 50.0) * 0.05 + (float(capacity["maliye"]) - 55.0) * 0.03
		+ (TAX_LAW_REVENUE[difficulty] if parliament_laws.has("tax") else 0.0)
		- TREASURY_COST * TREASURY_DIFF[difficulty] - budget_stance * 0.9 - (0.6 if court_share else 0.0), 0.0, 100.0)
	unrest = clampf(unrest + maxf(0.0, 55.0 - float(capacity["hukuk"])) * 0.01 - budget_stance * 0.15
		+ (TAX_LAW_UNREST[difficulty] if parliament_laws.has("tax") else 0.0), 0.0, 100.0)
	if court_share:
		private_wealth += 0.6


func _tick_holding() -> void:
	var halden: Actor = actors.get("halden")
	if halden == null:
		return
	holding = clampf(holding + (-0.5 if halden.moved else 0.12 + halden.power / 500.0), 0.0, 100.0)
	var mood := halden_mood()
	var sway := holding / 100.0
	if mood == "sıcak" and holding >= HALDEN_MEDIA_REACH[difficulty]:
		unrest = clampf(unrest - HALDEN_MEDIA_UNREST * sway, 0.0, 100.0)
		king_strength = clampf(king_strength + HALDEN_MEDIA_KING * sway, 0.0, 100.0)
	elif mood == "düşmanca":
		if holding >= HALDEN_MEDIA_REACH[difficulty]:
			unrest = clampf(unrest + HALDEN_MEDIA_UNREST * sway, 0.0, 100.0)
			king_strength = clampf(king_strength - HALDEN_MEDIA_KING * sway, 0.0, 100.0)
		stats["halden_hostile_weeks"] = int(stats.get("halden_hostile_weeks", 0)) + 1


func _tick_foreign() -> void:
	var lena_free: bool = actors.has("lena") and not actors["lena"].moved and not Press.is_closed(self, "free")
	var falk_free: bool = actors.has("falk") and not actors["falk"].moved
	var arden: Actor = actors.get("arden")
	var asteria := (0.035 if lena_free else -0.07) + (0.025 if falk_free else -0.05)
	asteria += (float(capacity["hukuk"]) - 55.0) * 0.003
	foreign["asteria"] = clampf(float(foreign["asteria"]) + asteria, 0.0, 100.0)
	var drakon := ((arden.power - 45.0) * 0.003 if arden else -0.05) + (float(capacity["ordu"]) - 55.0) * 0.003
	drakon -= 0.08 if budget_stance < 0 else 0.0
	drakon -= 0.03 * int(stats.get("liyakatli_ordu", 0))
	foreign["drakon"] = clampf(float(foreign["drakon"]) + drakon, 0.0, 100.0)
	var seravia := mini(3, int(stats.get("tenders", 0))) * 0.02 + (holding - 40.0) * 0.002
	seravia += 0.02 if treasury >= 45.0 and treasury <= 65.0 else -0.06
	seravia -= 0.04 if court_share else 0.0
	foreign["seravia"] = clampf(float(foreign["seravia"]) + seravia, 0.0, 100.0)
	var scale: float = FOREIGN_EFFECT_DIFF[difficulty]
	if float(foreign["asteria"]) >= 70.0:
		treasury = minf(100.0, treasury + 0.12 * scale)
	elif float(foreign["asteria"]) <= 30.0:
		economy = maxf(0.0, economy - 0.10 * scale)
	if float(foreign["drakon"]) >= 70.0:
		capacity["ordu"] = minf(100.0, float(capacity["ordu"]) + 0.08 * scale)
	elif float(foreign["drakon"]) <= 30.0:
		unrest = minf(100.0, unrest + 0.10 * scale)
	if float(foreign["seravia"]) >= 70.0:
		economy = minf(100.0, economy + 0.08 * scale)
	elif float(foreign["seravia"]) <= 30.0:
		holding = minf(100.0, holding + 0.08 * scale)
	_foreign_warnings()


func _tick_external_pressure() -> void:
	var arden: Actor = actors.get("arden")
	var drakon_feed := maxf(0.0, 44.0 - float(foreign["drakon"])) * 0.13
	drakon_feed += maxf(0.0, 48.0 - float(capacity["ordu"])) * 0.18
	drakon_feed += maxf(0.0, 38.0 - (arden.total_loyalty() if arden else 50.0)) * 0.04
	drakon_feed += 6.0 if fired_events.has("elena_asteria_sizinti") else 0.0
	var asteria_feed := maxf(0.0, 38.0 - float(foreign["asteria"])) * 0.12
	asteria_feed += maxf(0.0, 24.0 - treasury) * 0.09
	asteria_feed += maxf(0.0, 38.0 - float(capacity["hukuk"])) * 0.05
	var seravia_feed := maxf(0.0, 40.0 - float(foreign["seravia"])) * 0.12
	seravia_feed += maxf(0.0, 25.0 - treasury) * 0.12
	seravia_feed += maxf(0.0, 42.0 - float(capacity["maliye"])) * 0.06
	var debt_rate := 1.2 if float(budget_allocation.get("social", 25.0)) > 25.0 else 0.04
	var debt_stress := maxf(0.0, float(economy_metrics["debt"]) - 85.0) * debt_rate
	asteria_feed += debt_stress
	seravia_feed += debt_stress
	drakon_feed *= 2.6
	asteria_feed *= 1.5
	seravia_feed *= 1.5
	var feed := {"asteria": asteria_feed, "drakon": drakon_feed, "seravia": seravia_feed}
	for power in ext_pressure:
		var noise := ext_rng.randf_range(-0.25, 0.55)
		ext_pressure[power] = clampf(float(ext_pressure[power]) * (1.0 - EXT_PRESSURE_DECAY) + float(feed[power]) + noise, 0.0, 100.0)
	if float(ext_pressure["drakon"]) >= BORDER_WARNING_AT and not warned.get("border_drakon", false):
		warned["border_drakon"] = true
		_add_news("DIŞİŞLERİ: Malenkov sınır hattındaki temasların olağandışı arttığını bildirdi.", tr("DIŞİŞLERİ: Malenkov sınır hattındaki temasların olağandışı arttığını bildirdi."))
	elif float(ext_pressure["drakon"]) < BORDER_WARNING_AT - 10.0:
		warned.erase("border_drakon")
	for power in ["asteria", "seravia"]:
		if float(ext_pressure[power]) >= BORDER_WARNING_AT and not warned.get("siege_" + power, false):
			warned["siege_" + power] = true
			var name := "Asteria" if power == "asteria" else "Seravia"
			_add_news("MALİYE: %s bankaları devlet teminatlarını yeniden inceliyor." % name, tr("MALİYE: %s bankaları devlet teminatlarını yeniden inceliyor.") % tr(name))
		elif float(ext_pressure[power]) < BORDER_WARNING_AT - 10.0:
			warned.erase("siege_" + power)


func external_suspicion_level(envoy_id: String) -> int:
	var power := str(FOREIGN_ENVOYS.get(envoy_id, ""))
	if power == "":
		return 0
	return _external_pressure_level(power)


func _external_pressure_level(power: String) -> int:
	var noise := RandomNumberGenerator.new()
	noise.seed = ext_rng.seed ^ (week * 7919) ^ power.hash()
	var estimate := float(ext_pressure.get(power, 0.0)) + noise.randf_range(-14.0, 14.0)
	return 3 if estimate >= 70.0 else (2 if estimate >= 52.0 else (1 if estimate >= 34.0 else 0))


func _external_report_hint(power: String) -> String:
	var level := _external_pressure_level(power)
	if level < 1:
		return ""
	var names := {"asteria": tr("Asteria"), "drakon": tr("Drakon"), "seravia": tr("Seravia")}
	var messages := [
		tr("%s elçisinin temasları son haftalarda sıklaştı.") % names[power],
		tr("%s elçisi sınır ve ticaret görüşmelerini olağandışı biçimde artırdı.") % names[power],
		tr("%s elçisinin son temasları diplomatik nezaket sınırını aşıyor.") % names[power]]
	return messages[mini(level - 1, messages.size() - 1)]


func _foreign_warnings() -> void:
	for power in ["asteria", "drakon", "seravia"]:
		var name: String = {"asteria": "Asteria", "drakon": "Drakon", "seravia": "Seravia"}[power]
		var value: float = foreign[power]
		if value >= 70.0 and not warned.get("foreign_" + power + "_near", false):
			warned["foreign_" + power + "_near"] = true
			_add_news("DIŞİŞLERİ: %s ile ilişki yakınlaştı; elçilik kapıları açık." % name,
			tr("DIŞİŞLERİ: %s ile ilişki yakınlaştı; elçilik kapıları açık.") % name)
		elif value <= 30.0 and not warned.get("foreign_" + power + "_cold", false):
			warned["foreign_" + power + "_cold"] = true
			_add_news("DIŞİŞLERİ: %s ile ilişki soğudu; elçilikten sert bir nota geldi." % name,
			tr("DIŞİŞLERİ: %s ile ilişki soğudu; elçilikten sert bir nota geldi.") % name)


func foreign_defense_bonus() -> float:
	return 0.03 * FOREIGN_EFFECT_DIFF[difficulty] if float(foreign.get("drakon", 0.0)) >= 70.0 else 0.0


func _state_warnings() -> void:
	var messages := {
		"treasury": [treasury < 30.0, "MALİYE: Kasa daralıyor; maaş defterleri yeniden açıldı."],
		"maliye": [float(capacity["maliye"]) < 30.0, "MALİYE: Vergi defterleri masalarda birikiyor."],
		"hukuk": [float(capacity["hukuk"]) < 30.0, "ADLİYE: Dosyalar takviminden düşüyor; savcılar yetişemiyor."],
		"ordu": [float(capacity["ordu"]) < 40.0, "ORDU: Sınır birliklerinde hazırlık gecikiyor."],
		"idare": [float(capacity["idare"]) < 30.0, "İDARE: Saray emirleri valiliklere geç ulaşıyor."]}
	for key in messages:
		if messages[key][0] and not warned.get("state_" + key, false):
			warned["state_" + key] = true
			_add_news(messages[key][1], tr(messages[key][1]))


func _state_noise(institution: String) -> float:
	var r := RandomNumberGenerator.new()
	r.seed = rng.seed ^ (week * 7919) ^ institution.hash()
	return r.randf_range(-5.0, 5.0)


func capacity_band(institution: String) -> String:
	if not capacity.has(institution):
		return "bilinmiyor"
	var value: float = capacity[institution]
	var verified := week < int(flags.get("DOGRULA_" + institution, -100)) + 6
	if not verified:
		var aid: String = INSTITUTION_HEADS.find_key(institution)
		var chief: Actor = actors.get(aid)
		value += (chief.flattery() * 20.0 if chief else 0.0) + _state_noise(institution)
	return "aksıyor" if value < 40.0 else ("yürüyor" if value < 70.0 else "sağlam")


func treasury_band() -> String:
	var kessler: Actor = actors.get("kessler")
	var value := treasury
	if week >= int(flags.get("DOGRULA_maliye", -100)) + 6:
		value += (kessler.flattery() * 20.0 if kessler else 0.0) + _state_noise("treasury")
	return "sıkışık" if value < 30.0 else ("dengeli" if value < 70.0 else "dolu")


func _decay_facts() -> void:
	for f: Dictionary in facts.values():
		var fact_text := fact_text_for_display(f)
		# Dosyalar sızar: bilen sayısı arttıkça ortak bilgi yavaş yavaş yükselir.
		f["common"] = minf(1.0, f["common"] + 0.0065 * f["knowers"].size() * f.get("leakiness", 0.5))
		if f["common"] >= 0.25 and f["common"] < 0.5 and not f.get("rumor", false):
			f["rumor"] = true
			_add_news("KULİS: '%s' konuşulmaya başladı." % f["text"],
				tr("KULİS: '%s' konuşulmaya başladı.") % fact_text)
		if f["common"] >= 0.5 and not f.get("public", false):
			f["public"] = true
			f["public_week"] = week
			if f["subject"] == "king":
				king_strength = maxf(0.0, king_strength - f["severity"] * 0.15)
				for a: Actor in actors.values():
					a.perceived_king -= f["severity"] * 0.1
			elif actors.has(f["subject"]):
				var s: Actor = actors[f["subject"]]
				s.power = maxf(5.0, s.power - f["severity"] * 0.25)
				s.fear += 8.0
			_add_news("MANŞET: %s herkesin bildiği bir şey oldu." % f["text"],
				tr("MANŞET: %s herkesin bildiği bir şey oldu.") % fact_text)


func _eligible(e: Dictionary) -> bool:
	if e.get("scripted_only", false):
		return false
	var id: String = e["id"]
	var once: bool = e.get("once", true)
	if fired_events.has(id):
		if once and not endless:
			return false
		if week - int(fired_events[id]) < int(e.get("cooldown", 12)):
			return false
	var max_week := int(e.get("max_week", 999))
	if endless:
		max_week = 999999
	if week < int(e.get("min_week", 0)) or week > max_week:
		return false
	if unrest < float(e.get("min_unrest", 0)) or unrest > float(e.get("max_unrest", 100)):
		return false
	if economy < float(e.get("min_economy", 0)) or economy > float(e.get("max_economy", 100)):
		return false
	if treasury < float(e.get("min_treasury", 0)) or treasury > float(e.get("max_treasury", 100)):
		return false
	if holding < float(e.get("min_holding", 0)) or holding > float(e.get("max_holding", 100)):
		return false
	if heir_maturity < float(e.get("min_heir", 0)) or heir_maturity > float(e.get("max_heir", 100)):
		return false
	for power in e.get("min_foreign", {}):
		if not foreign.has(power) or float(foreign[power]) < float(e["min_foreign"][power]):
			return false
	for power in e.get("max_foreign", {}):
		if not foreign.has(power) or float(foreign[power]) > float(e["max_foreign"][power]):
			return false
	for power in e.get("min_ext_pressure", {}):
		if float(ext_pressure.get(power, 0.0)) < float(e["min_ext_pressure"][power]):
			return false
	if e.get("needs_hostile", false) and halden_mood() != "düşmanca":
		return false
	for aid in _as_array(e.get("needs_moved", [])):
		if not actors.has(aid) or not actors[aid].moved:
			return false
	for institution in e.get("min_cap", {}):
		if not capacity.has(institution) or float(capacity[institution]) < float(e["min_cap"][institution]):
			return false
	for institution in e.get("max_cap", {}):
		if not capacity.has(institution) or float(capacity[institution]) > float(e["max_cap"][institution]):
			return false
	var min_opposition := float(e.get("min_opposition", 0))
	if str(e.get("id", "")) == "erken_secim" and parliament_laws.has("election"):
		min_opposition = maxf(0.0, min_opposition - 0.5)
	if opposition < min_opposition:
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
	# Oyuncunun geçmişi (Bedellerin Dönüşü): kaç rüşvet, yazılı emir, şantaj... (stats)
	var smin: Dictionary = e.get("min_stat", {})
	for k in smin:
		if int(stats.get(k, 0)) < int(smin[k]):
			return false
	var smax: Dictionary = e.get("max_stat", {})
	for k in smax:
		if int(stats.get(k, 0)) > int(smax[k]):
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


# Rejim bir siyasi yorumdur: yalnızca oyuncunun yaptığı eylemler, açık sözler ve karttaki güç kademesi.
var REGIME_NAMES: Dictionary = {}
var REGIME_TITLES: Dictionary = {}
var REGIME_THREATS: Dictionary = {}
var REGIME_ORDER: Array = []


func regime_name() -> String:
	return tr(str(REGIME_NAMES.get(regime, "henüz şekillenmemiş")))


func regime_threat() -> String:
	return tr(str(REGIME_THREATS.get(regime, "belirsiz")))


func _regime_tier(id: String) -> int:
	return maxi(0, power_tier(actors[id].power) - 1) if actors.has(id) else 0


func _regime_stat(id: String) -> int:
	return mini(5, int(stats.get(id, 0)))


func _choose_regime() -> String:
	var debt := 0
	var loyal_appointments := 0
	for p: Dictionary in promises:
		if p.get("state", "") == "active":
			debt += 1
	for institution in capacity:
		loyal_appointments += int(stats.get("sadik_" + institution, 0))
	var scores := {
		"guvenlikci": 2 * _regime_stat("written") + _regime_stat("ops") + _regime_tier("arden")
			+ (2 if flags.has("gida_protestosu_1") or flags.has("yay_arden_kopus") else 0) + 2 * int(stats.get("sadik_ordu", 0)),
		"populist": 2 * _regime_stat("street_concessions") + _regime_stat("legal_concessions") + _regime_tier("brandt")
			+ (2 if flags.has("genel_grev_0") or flags.has("yay_brandt_guven") else 0) + (14 if budget_stance > 0 else 0),
		"patronajci": 2 * _regime_stat("promotes") + _regime_stat("promises") + mini(5, debt) + _regime_tier("dorn")
			+ (2 if flags.has("dorn_filtre_1") or flags.has("yay_dorn_kopus") else 0) + loyal_appointments + (10 if loyal_appointments >= 3 else 0),
		"oligark": _regime_stat("bribes") + _regime_tier("halden") + int(holding / 12.0) + mini(8, int(stats.get("tenders", 0)))
			+ (2 if flags.has("halden_ihale_0") or flags.has("milletvekili_satin_0") else 0),
		"medya": _regime_tier("lena") + _regime_tier("halden")
			+ (3 if flags.has("halden_kanal_0") else 0) + (2 if flags.has("gazeteci_ihale_2") or flags.has("yay_halden_kopus") else 0) + 4 * mini(5, int(stats.get("halden_granted", 0))),
		"istihbarat": _regime_stat("investigations") + 2 * _regime_stat("blackmails") + mini(14, int(stats.get("checks", 0)) / 8)
			+ _regime_tier("voss") + (2 if flags.has("voss_dosyalar_0") or flags.has("yay_voss_kopus") else 0)}
	var best := "guvenlikci"
	for id in REGIME_ORDER:
		if int(scores[id]) > int(scores[best]):
			best = id
	return best


func _prepare_election_result(source: Dictionary) -> Dictionary:
	var e: Dictionary = source.duplicate(true)
	var scandal_load := 0
	for fact: Dictionary in facts.values():
		if fact.get("subject", "") == "king" and bool(fact.get("public", false)):
			scandal_load += 1
	var law_legacy := 0.0
	for proposal: Dictionary in parliament_proposals:
		if str(proposal.get("status", "")) in ["passed", "passed_under_pressure"]:
			law_legacy += 1.0 if str(proposal.get("bill", "")) in ["amnesty", "judicial"] else -0.5
	var score := (consent - 50.0) * 0.32 + (economy - 50.0) * 0.22 + (50.0 - unrest) * 0.18
	score += law_legacy - float(scandal_load) * 3.0 + government_rng.randf_range(-4.0, 4.0)
	var shift := clampf(score * 0.35, -12.0, 12.0)
	parliament_blocs["royal"]["loyalty"] = clampf(float(parliament_blocs["royal"]["loyalty"]) + shift, 0.0, 100.0)
	parliament_blocs["opposition"]["loyalty"] = clampf(float(parliament_blocs["opposition"]["loyalty"]) - shift, 0.0, 100.0)
	parliament_blocs["nobles"]["loyalty"] = clampf(float(parliament_blocs["nobles"]["loyalty"]) + shift * 0.2, 0.0, 100.0)
	parliament_blocs["independents"]["loyalty"] = clampf(float(parliament_blocs["independents"]["loyalty"]) + shift * 0.25 + government_rng.randf_range(-3.0, 3.0), 0.0, 100.0)
	_refresh_parliament_opposition()
	stats["elections"] = int(stats.get("elections", 0)) + 1
	var result := tr("Meclis sonucu Saray listesine alan açtı; Soylular hükümet pazarlığında ağırlık kazandı.") if score >= 12.0 else (
		tr("Muhalefet güç topladı; meclis dengesi hükümet pazarlığını zorlaştırıyor.") if score <= -10.0 else
		tr("Hiçbir blok tek başına öne çıkamadı; hükümet pazarlığı belirleyici olacak."))
	e["kind"] = "election_result"
	e["advisors"] = ["kessler", "dorn"]
	e["text"] = result
	e["choices"] = [{"label": tr("Sonucu kabul et ve hükümet görüşmelerini başlat"), "text": tr("Meclis yeni hükümetin kuruluşu için toplandı."), "fx": {}}]
	return e


func _queue_government_formation(result: String) -> void:
	var e := {"id": "hukumet_kurma_%d" % week, "kind": "government_formation", "title": tr("Yeni hükümeti kur"),
		"text": tr("Seçim sonucu: %s") % result, "advisors": ["kessler", "dorn"], "choices": [
		{"label": tr("Saray ve Soylularla hükümet kur"), "text": tr("Veyra başbakan kalır. Saray hazine ve atama nüfuzundan pay verir."), "formation": "royal_nobles", "fx": {"treasury": -4.0, "wealth": -2.0}},
		{"label": tr("Saray ve Bağımsızlarla uzlaş"), "text": tr("Veyra hükümeti sürer; bağımsızlara söz ve bütçede alan açılır."), "formation": "royal_independents", "fx": {"treasury": -3.0, "consent": 2.0}},
		{"label": tr("Muhalefet ve Bağımsızlara hükümet kurdur"), "text": tr("Brandt başbakan olur; Saray karar alanının bir bölümünü paylaşır."), "formation": "opposition_independents", "available": actors.has("brandt") and not actors["brandt"].moved, "fx": {"king": -5.0, "consent": 5.0, "treasury": -2.0}}],
		"ignore": {"text": tr("Meclis hükümet görüşmelerini erteledi."), "fx": {"opp": 3.0}}}
	pending.append({"event": e, "age": 0})


func _fire_events() -> void:
	var pool: Array = []
	for e: Dictionary in _events:
		var chance: float = e.get("chance", 1.0)
		if e["id"] == "prens_veliaht" and heir_maturity >= 70.0:
			chance *= 0.5
		var event_rng: RandomNumberGenerator = ext_rng if e.get("rng_pool", "") == "external" else rng
		if _eligible(e) and event_rng.randf() <= chance:
			pool.append([event_rng.randf(), e])
	pool.sort_custom(func(x: Array, y: Array) -> bool: return x[0] < y[0])
	var added := 0
	for item in pool:
		var e: Dictionary = item[1]
		if str(e.get("id", "")) == "secim_sonucu":
			if pending.size() >= 3 or added >= 2:
				continue
			e = _prepare_election_result(e)
		if e.has("choices"):
			if pending.size() >= 3 or added >= 2:
				continue
			added += 1
			pending.append({"event": e, "age": 0})
		fired_events[e["id"]] = week
		_apply_effects(e.get("fx", {}))
		if not e.has("choices"):
			history.append(tr("Hafta %d — %s") % [week, e["title"]])
		if e.has("news"):
			# Aktör hamlesi: seçeneksiz, kendiliğinden; haberde ve "Geçen haftadan beri" özetinde görünür.
			weekly_news.append("HAMLE: " + str(e["news"]))
			weekly_moves.append({"tone": int(e.get("tone", 0)), "actor": str(e.get("actor", "")), "text": str(e["news"])})
		else:
			weekly_news.append("OLAY: %s" % e["title"])


func _fire_budget() -> void:
	if not week in [13, 26, 39, 52, 65, 78, 91]:
		return
	if pending.size() >= 3:
		budget_stance = 0
		court_share = false
		_add_news("MALİYE: Meclis bütçeyi görüşemedi; eski dengeli düzen sürdü.")
		return
	var note := ""
	for report: Dictionary in reports:
		if report["source"] == finance_report_source:
			var source_name := str(actors[finance_report_source].display_name) if actors.has(finance_report_source) else tr("Saray hazinesi")
			note = " " + tr("%s'nın son raporu: ") % source_name + str(report["text"])
			break
	var choices: Array = [
		{"label": tr("Sıkı bütçe"), "text": tr("Harcama kısılır; kurumlar ve sokak bunun bedelini gecikmeli hisseder."),
			"fx": {"budget_allocation": {"army": 25.0, "social": 10.0, "industry": 20.0, "palace": 45.0}, "budget_stance": -1, "court_share": false}},
		{"label": tr("Dengeli bütçe"), "text": tr("Dört kaleme eşit pay; belirgin bir öncelik yok."),
			"fx": {"budget_allocation": {"army": 25.0, "social": 25.0, "industry": 25.0, "palace": 25.0}, "budget_stance": 0, "court_share": false}},
		{"label": tr("Cömert bütçe"), "text": tr("Kurumlara ve sokağa nefes verir; kasanın bedeli haftalara yayılır."),
			"fx": {"budget_allocation": {"army": 25.0, "social": 25.0, "industry": 25.0, "palace": 25.0}, "budget_stance": 1, "court_share": false}},
		{"label": tr("Özel tahsis"), "text": tr("Dört kalemin payını kendin belirle; başlangıç dağılımı sosyal harcamayı öne çıkarır."),
			"fx": {"budget_custom": true, "budget_allocation": {"army": 10.0, "social": 70.0, "industry": 10.0, "palace": 10.0}, "budget_stance": 0, "court_share": false}}
	]
	var e := {"id": "ceyrek_butce", "title": STATE_CONTENT["title"], "text": str(STATE_CONTENT["text"]) + note,
		"art": "butce_acigi", "advisors": [finance_report_source, "dorn"], "kind": "budget", "choices": choices,
		"ignore": {"text": STATE_CONTENT["ignore"], "fx": {"budget_stance": 0, "court_share": false}}}
	pending.append({"event": e, "age": 0})
	weekly_news.append("OLAY: " + str(e["title"]))


func _set_budget_allocation(value: Dictionary) -> void:
	var allocation := value.duplicate()
	if parliament_laws.has("army") and float(allocation.get("army", 0.0)) < 26.0:
		var remaining := 26.0 - float(allocation.get("army", 0.0))
		allocation["army"] = 26.0
		for sector in ["palace", "industry", "social"]:
			var cut := minf(remaining, float(allocation.get(sector, 0.0)))
			allocation[sector] = float(allocation.get(sector, 0.0)) - cut
			remaining -= cut
	var total := 0.0
	for sector in ["army", "social", "industry", "palace"]:
		var share := clampf(float(allocation.get(sector, 0.0)), 0.0, 100.0)
		budget_allocation[sector] = share
		total += share
	if not is_equal_approx(total, 100.0):
		return
	for sector in budget_allocation:
		if not is_equal_approx(float(budget_allocation[sector]), 25.0):
			delayed_economy.append({"due": week + {"social": 4, "palace": 6, "army": 8, "industry": 12}[sector],
				"sector": sector, "share": budget_allocation[sector]})


func _tick_budget_effects() -> void:
	var keep: Array[Dictionary] = []
	for item in delayed_economy:
		if int(item["due"]) > week:
			keep.append(item)
			continue
		var amount := float(item["share"]) - 25.0
		match str(item["sector"]):
			"social":
				unrest = clampf(unrest - amount * 0.045, 0.0, 100.0)
				treasury = clampf(treasury - amount * 1.6, 0.0, 100.0)
			"industry":
				economy = clampf(economy + amount * 0.07, 0.0, 100.0)
				treasury = clampf(treasury - maxf(0.0, amount) * 0.02, 0.0, 100.0)
			"army":
				if actors.has("arden"):
					actors["arden"].power = clampf(actors["arden"].power + amount * 0.08, 5.0, 100.0)
				capacity["ordu"] = clampf(float(capacity["ordu"]) + amount * 0.025, 5.0, 100.0)
			"palace":
				private_wealth = maxf(0.0, private_wealth + amount * 0.025)
				if amount >= 12.0 and economy_rng.randf() < 0.08:
					_add_fact("palace_budget_%d" % week, "Saray tahsisi büyüdü", "king", 12, ["kessler", "dorn"], 1)
	delayed_economy = keep


func _fire_patronage() -> void:
	if week < 18 or pending.size() >= 3 or not actors.has("halden") or actors["halden"].moved:
		return
	var last := int(flags.get("HALDEN_TALEP", -100))
	if week - last < 8:
		return
	var reached := false
	for threshold in [40, 55, 70, 85]:
		if holding >= threshold and not flags.has("HALDEN_ESIK_%d" % threshold):
			reached = true
	if not reached and (week - last < 12 or media_dependency() < 50.0):
		return
	for threshold in [40, 55, 70, 85]:
		if holding >= threshold:
			flags["HALDEN_ESIK_%d" % threshold] = week
	flags["HALDEN_TALEP"] = week
	var level := halden_demands
	halden_demands += 1
	var choices: Array = []
	var effects := [
		{"holding": 10 + 2 * level, "wealth": 3, "treasury": -(3 + level), "king": 2},
		{"unrest": 2, "actors": {"halden": {"ambition": 8}}},
		{"wealth": -6, "actors": {"lena": {"power": 6}, "halden": {"ambition": 4}}},
		{"holding": -8, "actors": {"halden": {"ambition": 6}}}
	]
	for i in 4:
		var option: Dictionary = PATRONAGE_CONTENT["choices"][i]
		choices.append({"label": option["label"], "text": option["text"], "fx": effects[i],
			"available": (i != 2 or (actors.has("lena") and not actors["lena"].moved and not Press.is_closed(self, "free")))
				and (i != 3 or (actors.has("falk") and not actors["falk"].moved))})
	var e := {"id": "halden_talep", "kind": "patronage", "level": level, "title": PATRONAGE_CONTENT["title"],
		"text": PATRONAGE_CONTENT["text"][mini(level, 2)], "art": "halden_fatura", "advisors": ["dorn", "kessler"],
		"choices": choices, "ignore": {"text": PATRONAGE_CONTENT["ignore"], "fx": {}}}
	pending.append({"event": e, "age": 0})
	weekly_news.append("OLAY: " + str(e["title"]))


func _tick_parliament() -> void:
	if pending.is_empty() and government_pm == "kessler" and week - last_confidence_week >= 8 and _government_support_lost():
		_queue_confidence_vote()
		return
	if not pending.is_empty():
		return
	if not parliament_laws.is_empty() and week - last_parliament_review_week >= 26:
		_offer_parliament_repeal()
		return
	if week - last_parliament_bill_week < 10:
		return
	last_parliament_bill_week = week
	var bills := [
		["tax", tr("Vergi reformu"), tr("Vergi yükünün dağılımı ve sarayın payı yeniden tartışılıyor.")],
		["press", tr("Basın yasası"), tr("Yayın özgürlüğü ile sarayın denetimi karşı karşıya.")],
		["army", tr("Ordu bütçesi"), tr("Kışla, güvenlik ve sivil harcama arasında yeni bir pay aranıyor.")],
		["election", tr("Seçim yasası"), tr("Sandığın kuralları ve temsilin sınırları mecliste tartışılıyor.")],
		["amnesty", tr("Af yasası"), tr("Siyasi tutuklular ve eski suçlar için af önerisi sunuldu.")],
		["judicial", tr("Yargı reformu"), tr("Mahkemelerin bağımsızlığı ve sarayın yetkisi yeniden masada.")]]
	var available_bills: Array = []
	for bill: Array in bills:
		if not parliament_laws.has(str(bill[0])):
			available_bills.append(bill)
	if available_bills.is_empty():
		return
	var bill: Array = available_bills[parliament_rng.randi_range(0, available_bills.size() - 1)]
	var proposal := {"id": "bill_%d_%s" % [week, bill[0]], "bill": bill[0], "week": week, "status": "pending"}
	var force_costs := _parliament_force_costs()
	var e := {"id": "kanun_teklifi_%d" % week, "kind": "parliament_bill", "proposal": proposal,
		"title": tr("Meclise kanun teklifi sunuldu"), "text": tr("%s: %s") % [str(bill[1]), str(bill[2])],
		"choices": [
			{"label": tr("Destekle"), "text": tr("Teklif oylamaya gitti. Kulislerde çoğunluğun yönü hâlâ belirsiz."), "bill_action": "support", "fx": {"opp": -1.0}},
			{"label": tr("Değiştir"), "text": tr("Uzlaşma için değişiklik yaptın; bazı vekillerin desteği kazanıldı."), "bill_action": "amend", "fx": {"opp": -1.0}},
			{"label": tr("Geri çek"), "text": tr("Teklif geri çekildi. Muhalefet bunu geri adım olarak anlatacak."), "bill_action": "withdraw", "fx": {"opp": 3.0, "unrest": 10.0}},
			{"label": tr("Baskıyla geçir"), "text": tr("Teklif baskıyla kabul edildi. Kulislerde kimin bedel ödediği konuşuluyor."), "bill_action": "force",
				"fx": {"treasury": -float(force_costs["treasury"]), "wealth": -float(force_costs["wealth"]), "unrest": float(force_costs["unrest"]), "king": -14.0},
				"available": _can_force_parliament()}],
		"ignore": {"text": tr("Teklif bu hafta gündemden düştü."), "fx": {}}}
	pending.append({"event": e, "age": 0})
	parliament_proposals.append(proposal)
	var bill_news := tr("Meclis yeni bir kanun teklifini görüşmeye başladı.")
	_add_news("OLAY: " + bill_news, "EVENT: " + Loc.en(bill_news))


func _offer_parliament_repeal() -> void:
	var laws: Array = parliament_laws.keys()
	laws.sort()
	var law := str(laws[parliament_rng.randi_range(0, laws.size() - 1)])
	last_parliament_review_week = week
	var name := _parliament_law_name(law)
	var repeal_cost := 10.0
	var text := tr("Kabine, %s yasasının geri alınmasını tartışıyor. Bedeli hazineden karşılanmalı.") % name
	var e := {"id": "kanun_incelemesi_%d" % week, "kind": "parliament_repeal", "law": law,
		"title": tr("Yürürlükteki yasa gözden geçiriliyor"), "text": text,
		"choices": [
			{"label": tr("Yasayı kaldır: %s") % name, "text": tr("Yasa yürürlükten kaldırıldı; siyasi bedeli ve hazine masrafı kayda geçti."),
				"bill_action": "repeal", "fx": {"treasury": -repeal_cost, "king": -2.0, "opp": 2.0}, "available": treasury >= repeal_cost},
			{"label": tr("Yasayı koru"), "text": tr("Yasa yürürlükte kaldı."), "bill_action": "keep", "fx": {}}],
		"ignore": {"text": tr("Yasa incelemesi ertelendi."), "fx": {}}}
	pending.append({"event": e, "age": 0})
	var news := tr("Meclis yürürlükteki bir yasayı gözden geçiriyor.")
	_add_news("OLAY: " + news, "EVENT: " + Loc.en(news))


func _enact_parliament_law(law: String) -> void:
	if parliament_laws.has(law):
		return
	parliament_laws[law] = week
	last_parliament_review_week = week
	match law:
		"press":
			consent = maxf(0.0, consent - 8.0)
		"army":
			if actors.has("arden"):
				actors["arden"].power = minf(100.0, actors["arden"].power + ARMY_LAW_POWER[difficulty])
			_set_budget_allocation(budget_allocation.duplicate())
		"tax":
			treasury = minf(100.0, treasury + 3.0)
			unrest = minf(100.0, unrest + TAX_LAW_UPFRONT_UNREST[difficulty])
		"amnesty":
			consent = minf(100.0, consent + 0.5)
			unrest = maxf(0.0, unrest - 1.0)
		"judicial":
			capacity["hukuk"] = minf(100.0, float(capacity["hukuk"]) + 1.0)


func _repeal_parliament_law(law: String) -> void:
	if not parliament_laws.has(law):
		return
	parliament_laws.erase(law)
	match law:
		"press":
			consent = minf(100.0, consent + 4.0)
		"army":
			if actors.has("arden"):
				actors["arden"].power = maxf(5.0, actors["arden"].power - ARMY_LAW_POWER[difficulty])
		"tax":
			unrest = maxf(0.0, unrest - 2.0)


func _resolve_parliament_repeal(event: Dictionary, choice: int) -> String:
	var action := str(event["choices"][choice].get("bill_action", "keep"))
	_apply_effects(event["choices"][choice].get("fx", {}))
	if action == "repeal":
		var law := str(event.get("law", ""))
		if not parliament_laws.has(law):
			return tr("Bu yasa zaten yürürlükte değil.")
		_repeal_parliament_law(law)
	var result := str(event["choices"][choice]["text"])
	history.append(tr("Hafta %d — %s » %s") % [week, event["title"], event["choices"][choice]["label"]])
	changed.emit()
	return result


func _bill_support_score(bill: String) -> float:
	var stance := {
		"tax": {"royal": -4.0, "opposition": -8.0, "nobles": -14.0, "independents": 0.0},
		"press": {"royal": -10.0, "opposition": 15.0, "nobles": -4.0, "independents": 8.0},
		"army": {"royal": 8.0, "opposition": -12.0, "nobles": 5.0, "independents": -5.0},
		"election": {"royal": -10.0, "opposition": 12.0, "nobles": -7.0, "independents": 4.0},
		"amnesty": {"royal": 0.0, "opposition": 12.0, "nobles": -10.0, "independents": 5.0},
		"judicial": {"royal": -8.0, "opposition": 10.0, "nobles": -3.0, "independents": 8.0}}
	var weights := {"royal": 0.4, "opposition": 0.3, "nobles": 0.2, "independents": 0.1}
	var score := 0.0
	for bloc in weights:
		var data: Dictionary = parliament_blocs.get(bloc, {})
		var lean: float = float(stance.get(bill, {}).get(bloc, 0.0))
		var pressure_weight := 0.18 if bloc in ["royal", "nobles"] else 0.08
		score += weights[bloc] * clampf(float(data.get("loyalty", 50.0)) + float(data.get("pressure", 0.0)) * pressure_weight + lean, 0.0, 100.0)
	return score


func _parliament_force_costs() -> Dictionary:
	var times := int(stats.get("parliament_forced", 0))
	return {"treasury": 10.0 + times * 6.0, "wealth": 7.0 + times * 3.0, "unrest": 100.0 + times * 30.0}


func _can_force_parliament() -> bool:
	var costs := _parliament_force_costs()
	return treasury >= float(costs["treasury"]) and private_wealth >= float(costs["wealth"]) and king_strength >= 55.0


func _adjust_parliament_patronage(choice: int) -> void:
	match choice:
		0:
			parliament_blocs["royal"]["pressure"] = minf(100.0, float(parliament_blocs["royal"]["pressure"]) + 4.0)
			parliament_blocs["nobles"]["pressure"] = minf(100.0, float(parliament_blocs["nobles"]["pressure"]) + 3.0)
		1:
			parliament_blocs["opposition"]["pressure"] = minf(100.0, float(parliament_blocs["opposition"]["pressure"]) + 3.0)
			parliament_blocs["independents"]["pressure"] = minf(100.0, float(parliament_blocs["independents"]["pressure"]) + 4.0)
		2:
			parliament_blocs["independents"]["loyalty"] = minf(100.0, float(parliament_blocs["independents"]["loyalty"]) + 2.0)
			parliament_blocs["independents"]["pressure"] = maxf(0.0, float(parliament_blocs["independents"]["pressure"]) - 4.0)
		3:
			parliament_blocs["royal"]["loyalty"] = maxf(0.0, float(parliament_blocs["royal"]["loyalty"]) - 2.0)
			parliament_blocs["nobles"]["pressure"] = maxf(0.0, float(parliament_blocs["nobles"]["pressure"]) - 4.0)
	_refresh_parliament_opposition()


func _fail_parliament_proposal() -> void:
	parliament_blocs["opposition"]["loyalty"] = maxf(0.0, float(parliament_blocs["opposition"]["loyalty"]) - 20.0)
	parliament_blocs["royal"]["loyalty"] = maxf(0.0, float(parliament_blocs["royal"]["loyalty"]) - 6.0)
	unrest = clampf(unrest + 10.0, 0.0, 100.0)
	_refresh_parliament_opposition()


func _register_failed_parliament_vote() -> void:
	parliament_blocs["opposition"]["loyalty"] = maxf(0.0, float(parliament_blocs["opposition"]["loyalty"]) - 2.0)
	_refresh_parliament_opposition()


func _government_support_lost() -> bool:
	if government_coalition.is_empty():
		return true
	var support := 0.0
	for bloc in government_coalition:
		var data: Dictionary = parliament_blocs.get(bloc, {})
		support += float(data.get("loyalty", 50.0)) - float(data.get("pressure", 0.0)) * 0.25
	var recent_failures := 0
	for i in range(maxi(0, parliament_proposals.size() - 3), parliament_proposals.size()):
		if str(parliament_proposals[i].get("status", "")) in ["failed", "lapsed", "withdrawn"]:
			recent_failures += 1
	return support / float(government_coalition.size()) < 88.5 or recent_failures >= 2


func _queue_confidence_vote() -> void:
	last_confidence_week = week
	stats["confidence_offers"] = int(stats.get("confidence_offers", 0)) + 1
	var pm_name := str(actors[government_pm].display_name) if actors.has(government_pm) else tr("Başbakan")
	var e := {"id": "guven_oyu_%d" % week, "kind": "confidence_vote", "title": tr("Hükümet güven oylamasında"),
		"text": tr("%s'nın koalisyon desteği çözülüyor. Kararın hükümeti ayakta tutabilir, düşürebilir ya da Saray'a bedel ödetebilir.") % pm_name,
		"advisors": [government_pm if actors.has(government_pm) else "dorn", "dorn"],
		"choices": [
			{"label": tr("Veyra'yı destekle"), "text": tr("Koalisyon şimdilik korunuyor; tavizlerin yükü sürüyor."), "confidence_action": "support", "fx": {"king": 5.0, "treasury": -5.0, "consent": 4.0, "opp": -4.0}},
			{"label": tr("Hükümet düşsün"), "text": tr("Başbakan istifa ediyor. Yeni hükümet için son sözü sen söyleyeceksin."), "confidence_action": "fall", "fx": {"king": -35.0, "treasury": -8.0, "consent": -10.0, "unrest": 20.0, "opp": 12.0}},
			{"label": tr("Baskıyla kurtar"), "text": tr("Hükümet ayakta kalıyor; hazine, meşruiyet ve iz bırakıyor."), "confidence_action": "force",
				"available": king_strength >= 35.0 and treasury >= 25.0 and private_wealth >= 4.0, "fx": {"king": -30.0, "treasury": -20.0, "wealth": -4.0, "consent": -10.0, "unrest": 14.0, "fear": 8.0}}],
		"ignore": {"text": tr("Güven oylaması sonuçsuz kaldı; hükümet desteğini yitirdi."), "fx": {}}}
	pending.append({"event": e, "age": 0})
	weekly_news.append("OLAY: " + str(e["title"]))


func _queue_government_appointment() -> void:
	var e := {"id": "basbakan_atamasi_%d" % week, "kind": "government_appointment", "title": tr("Yeni hükümetin başbakanı"),
		"text": tr("Veyra'nın hükümeti düştü. Maliye raporlarını Kraliçe Helena geçici olarak üstlendi; şimdi yeni başbakanı ve meclis dayanağını seç."),
		"advisors": ["dorn", "brandt"], "choices": [
			{"label": tr("Veyra'ya bir şans daha ver"), "text": tr("Veyra döner; Saray ve Soylular yeniden sorumluluk alır."), "pm": "kessler", "coalition": ["royal", "nobles"], "fx": {"treasury": -3.0}},
			{"label": tr("Helena'yı geçici başbakan yap"), "text": tr("Helena maliye raporlarını da sürdürür; Bağımsızlarla uzlaşma gerekir."), "pm": "dorn", "coalition": ["royal", "independents"], "fx": {"king": -2.0, "consent": 2.0}},
			{"label": tr("Brandt'a hükümeti kurdur"), "text": tr("Muhalefet ve Bağımsızlar hükümete girer; Saray yetkisinden taviz verir."), "pm": "brandt", "coalition": ["opposition", "independents"], "fx": {"king": -5.0, "consent": 5.0, "treasury": -2.0}}],
		"ignore": {"text": tr("Helena geçici başbakan olarak kaldı."), "fx": {}}}
	pending.append({"event": e, "age": 0})


func _set_government(pm: String, coalition: Array) -> void:
	if not actors.has(pm) or actors[pm].moved:
		pm = "dorn" if actors.has("dorn") and not actors["dorn"].moved else "kessler"
	government_pm = pm
	government_coalition.assign(coalition)
	finance_report_source = "kessler" if pm == "kessler" else "dorn"
	if actors.has(finance_report_source) and actors[finance_report_source].moved:
		finance_report_source = "dorn" if actors.has("dorn") and not actors["dorn"].moved else "kessler"
	stats["government_formations"] = int(stats.get("government_formations", 0)) + 1


func _resolve_r3c_decision(event: Dictionary, choice: int) -> String:
	var selected: Dictionary = event["choices"][choice]
	_apply_effects(selected.get("fx", {}))
	match str(event.get("kind", "")):
		"election_result":
			_queue_government_formation(str(event.get("text", "")))
		"government_formation":
			match str(selected.get("formation", "")):
				"royal_nobles": _set_government("kessler", ["royal", "nobles"])
				"royal_independents": _set_government("kessler", ["royal", "independents"])
				"opposition_independents": _set_government("brandt", ["opposition", "independents"])
			_add_news("MECLİS: Yeni hükümet Saray'da kuruldu.", Loc.en("MECLİS: Yeni hükümet Saray'da kuruldu."))
		"confidence_vote":
			stats["confidence_votes"] = int(stats.get("confidence_votes", 0)) + 1
			match str(selected.get("confidence_action", "")):
				"support":
					stats["confidence_supports"] = int(stats.get("confidence_supports", 0)) + 1
					for bloc in government_coalition:
						parliament_blocs[bloc]["loyalty"] = minf(100.0, float(parliament_blocs[bloc]["loyalty"]) + 10.0)
					last_confidence_week = week
				"fall":
					stats["confidence_falls"] = int(stats.get("confidence_falls", 0)) + 1
					government_pm = ""
					government_coalition.clear()
					finance_report_source = "dorn"
					_queue_government_appointment()
				"force":
					stats["confidence_forced"] = int(stats.get("confidence_forced", 0)) + 1
					parliament_blocs["royal"]["loyalty"] = minf(100.0, float(parliament_blocs["royal"]["loyalty"]) + 4.0)
					parliament_blocs["opposition"]["pressure"] = minf(100.0, float(parliament_blocs["opposition"]["pressure"]) + 8.0)
					flags["CONFIDENCE_FORCE_TRACE_%d" % week] = true
					_add_fact("confidence_force_%d" % week, "Hükümet güveni baskıyla korundu", "king", 35.0, ["dorn", "brandt"], 1, 0.5,
						"The government survived a confidence vote by force")
		"government_appointment":
			_set_government(str(selected.get("pm", "dorn")), selected.get("coalition", ["royal", "independents"]))
	return str(selected.get("text", ""))


func _resolve_parliament_bill(event: Dictionary, choice: int) -> String:
	var proposal: Dictionary = event["proposal"]
	var action := str(event["choices"][choice].get("bill_action", "support"))
	var passed := false
	match action:
		"withdraw":
			_fail_parliament_proposal()
			proposal["status"] = "withdrawn"
			proposal["result"] = tr("Teklif geri çekildi.")
		"force":
			var costs := _parliament_force_costs()
			_apply_effects({"treasury": -float(costs["treasury"]), "wealth": -float(costs["wealth"]), "unrest": float(costs["unrest"]), "king": -60.0})
			parliament_blocs["opposition"]["loyalty"] = maxf(0.0, float(parliament_blocs["opposition"]["loyalty"]) - 12.0)
			parliament_blocs["royal"]["pressure"] = minf(100.0, float(parliament_blocs["royal"]["pressure"]) + 8.0)
			parliament_blocs["nobles"]["pressure"] = minf(100.0, float(parliament_blocs["nobles"]["pressure"]) + 5.0)
			stats["parliament_forced"] = int(stats.get("parliament_forced", 0)) + 1
			flags["PARLIAMENT_FORCE_TRACE_%d" % week] = true
			proposal["status"] = "passed_under_pressure"
			proposal["result"] = tr("Baskıyla geçirildi; hazine, huzur ve kral otoritesinden bedel aldı.")
			passed = true
		_:
			var score := _bill_support_score(str(proposal["bill"])) + (12.0 if action == "amend" else 0.0)
			passed = parliament_rng.randf() < clampf(0.52 + (score - 55.0) / 100.0, 0.12, 0.9)
			if passed:
				parliament_blocs["royal"]["loyalty"] = minf(100.0, float(parliament_blocs["royal"]["loyalty"]) + 1.0)
				parliament_blocs["independents"]["loyalty"] = minf(100.0, float(parliament_blocs["independents"]["loyalty"]) + (2.0 if action == "amend" else 0.0))
				proposal["status"] = "passed"
				proposal["result"] = tr("Teklif kabul edildi; yürürlük etkileri sonraki aşamada uygulanacak.")
			else:
				_register_failed_parliament_vote()
				proposal["status"] = "failed"
				proposal["result"] = tr("Teklif reddedildi; muhalefet safları sıklaştırdı.")
	if passed:
		_enact_parliament_law(str(proposal["bill"]))
		proposal["law_week"] = week
		proposal["law_active"] = true
		proposal["result"] = tr("Teklif kabul edildi ve yasa yürürlüğe girdi.")
	_refresh_parliament_opposition()
	proposal["result"] = str(proposal.get("result", tr("Teklif bu hafta görüşüldü.")))
	proposal["result"] = str(event["choices"][choice]["text"]) + " " + str(proposal["result"])
	proposal["week_resolved"] = week
	history.append(tr("Hafta %d — %s » %s") % [week, event["title"], event["choices"][choice]["label"]])
	var result_news := tr("Teklif kabul edildi; yasa yürürlüğe girdi.") if passed else tr("Meclis teklifinde uzlaşma sağlanamadı.")
	_add_news("OLAY: " + result_news, "EVENT: " + Loc.en(result_news))
	changed.emit()
	return str(proposal["result"])


func _resolve_patronage(choice: int, level: int) -> String:
	var halden: Actor = actors["halden"]
	var option: Dictionary = PATRONAGE_CONTENT["choices"][choice]
	match choice:
		0:
			flags["halden_ihale_0"] = week
			flags["halden_fatura_0"] = week
			holding = minf(100.0, holding + 10.0 + 2.0 * level)
			private_wealth += 3.0
			treasury = maxf(0.0, treasury - 3.0 - level)
			halden_hostile_until = 0
			flags["HALDEN_SICAK"] = week
			stats["halden_granted"] = int(stats.get("halden_granted", 0)) + 1
			_add_fact("halden_talep_%d" % week, "Sarne'ye verilen yeni yayın ve ihale payı", "king", 18.0 + 2.0 * level, ["halden", "kessler"], 1)
			if not facts.has("liman_komisyonu"):
				_add_fact("liman_komisyonu", "Liman ihalesindeki komisyon", "king", 35.0, ["halden"], 1)
		1:
			flags["halden_ihale_1"] = week
			flags["halden_fatura_1"] = week
			halden_hostile_until = week + 6 + 2 * level
			halden.ambition += 8.0
			unrest = minf(100.0, unrest + 2.0)
			stats["halden_rejected"] = int(stats.get("halden_rejected", 0)) + 1
			for fact: Dictionary in facts.values():
				if "halden" in fact["knowers"]:
					fact["common"] = minf(1.0, float(fact["common"]) + 0.25)
		2:
			flags["halden_ihale_2"] = week
			private_wealth -= 6.0
			lena_boost_until = week + 12
			actors["lena"].power += 6.0
			halden.ambition += 4.0
		3:
			flags["halden_fatura_2"] = week
			var chance := clampf(0.25 + (float(capacity["hukuk"]) - 40.0) / 100.0 - holding / 250.0, 0.10, 0.75)
			if rng.randf() < chance:
				holding = maxf(0.0, holding - 25.0)
				halden.fear += 15.0
				halden.ambition += 6.0
				flags["HALDEN_SAVCI_BASARILI"] = week
				return str(option["text"]) + " " + tr("Defterler açıldı; Sarne geri çekiliyor.")
			halden_hostile_until = week + 8
			flags["HALDEN_SAVCI_SIZDI"] = week
			_add_fact("halden_savci_sizinti_%d" % week, "Sarne soruşturmasının saraydan sızması", "king", 25.0, ["halden", "falk"], 1)
			return str(option["text"]) + " " + tr("Dosya sızdı; yayınlar sarayı hedef alıyor.")
	return str(option["text"])


# ---------------------------------------------------------------- Darbe aşamaları (docs/design/darbe_asamalari.md)

const PLOT_UNEASY_GAP := 15.0        # huzursuzluk: drive ≥ ready_drive − bu
const PLOT_CASCADE_MIN := 8.0        # kaskadın tutabilmesi için en düşük öfke (giriş 12)
const PLOT_LEAVE_WEEKS := 2          # çekilme için üst üste hafta
const PLOT_PREP_MARGIN := 0.15       # hazırlık: komplo payı ≥ coup_share − bu
const PLOT_PREP_POWER := 1.0         # hazırlıktaki vurucunun haftalık güç artışı
const PLOT_SIGN_P := [0.04, 0.15, 0.35, 0.6]   # aşama 0..3 için haftalık alamet olasılığı (0 = dedikodu)
const PLOT_SIGN_W := [1, 1, 2, 3]
const PLOT_SUS_WINDOW := 8           # şüphe: son kaç haftanın alametleri sayılır
const PLOT_SUS_BANDS := [2, 4, 7]    # Huzursuz / Şüpheli / Tehlikeli eşikleri
const PLOT_ORDER_DELAY := 0.6        # komplocu emri gönülsüz uygular
const PLOT_SPIN := 0.35              # komplocu kendi alanının raporunu güzeller
const CRISIS_RALLY_BASE := 0.05
const CRISIS_CONCEDE := [1.0, 0.5, 0.2]   # taviz: ilki kesin, sonrakilere inanılmaz
const CRISIS_APPEAL_BASE := 0.6
const CRISIS_COOLDOWN := 6           # çözülen krizden sonra yeni kriz için en az hafta
var SUSPICION_NAMES: Array = []

var coup_crisis: Dictionary = {}   # {leader, week, failed?}: kriz kartı bekliyor
var crisis_cooldown := 0           # bu haftadan önce yeni kriz açılmaz
var plot_log: Array = []           # gerçek komplo kronolojisi {w, name, text} (oyun sonunda açılır)
var crisis_note := ""              # darbe gecesinin özeti (kayıp metnine eklenir)


## Eşik kaskadı: her aktörün "kaç kişi kıpırdarsa ben de kıpırdarım" eşiği vardır.
## Herkesin bildiği bir zayıflık (ortak bilgi) eşikleri düşürür ve koordinasyonu açar.
## Komplo aşamalıdır ve çözülebilir; darbe koşulu oluşunca önce bir kriz kartı gelir (docs/design/darbe_asamalari.md).
func _run_cascade() -> void:
	# Bir hafta önce açılan kriz çözülmediyse darbe olur.
	if not coup_crisis.is_empty() and (coup_crisis.get("failed", false) or week > int(coup_crisis["week"])):
		var lead: Actor = actors.get(coup_crisis["leader"])
		_close_crisis()
		if lead != null:
			if crisis_note == "":
				crisis_note = tr("Darbe kapına dayandığında karar veremedin.")
			_coup_now(lead)
			return
	var drop := _public_weakness()
	var pressure_steps := maxi(0, week - MAX_WEEKS - 1) / 26 if endless else 0
	var rd := _diff("ready_drive") - pressure_steps * 2.0
	for a: Actor in actors.values():
		if a.insider and not a.supporting and not a.ready and a.rebellion_drive() > rd:
			a.ready = true
	var changed_any := true
	while changed_any:
		changed_any = false
		var share := _ready_power_share()
		for a: Actor in actors.values():
			if a.insider and not a.supporting and not a.ready and share >= maxf(0.05, a.threshold - drop) and a.rebellion_drive() > 12.0:
				a.ready = true
				changed_any = true
	# Çekilme: ne kendi öfkesi ne de kaskadın çekimi tutuyorsa komplocu birkaç hafta içinde geri çekilir.
	for a: Actor in actors.values():
		if not a.ready or a.moved or not a.insider or a.supporting:
			continue
		var d := a.rebellion_drive()
		var held := d > rd - _diff("leave_gap") or (_ready_share_without(a) >= maxf(0.05, a.threshold - drop) and d > PLOT_CASCADE_MIN)
		if held:
			a.plot_calm = 0
		else:
			a.plot_calm += 1
			if a.plot_calm >= PLOT_LEAVE_WEEKS:
				a.ready = false
				a.plot_calm = 0
	# Aşamalar: sakin -> huzursuz -> komplocu -> hazırlıkta
	var share_now := _ready_power_share()
	for a: Actor in actors.values():
		if a.moved or not a.insider or a.supporting:
			continue
		var st := 0
		if a.ready:
			st = 3 if share_now >= _diff("coup_share") - pressure_steps * 0.02 - PLOT_PREP_MARGIN else 2
		elif a.rebellion_drive() >= rd - PLOT_UNEASY_GAP:
			st = 1
		if st != a.plot_stage:
			_log_plot(a, a.plot_stage, st)
			a.plot_stage = st
		if st == 3 and (a.military or a.royal):
			a.power += PLOT_PREP_POWER  # kendi adamlarını kritik görevlere getirir
	var striker := false
	for a: Actor in actors.values():
		if a.ready and a.insider and (a.military or a.royal):
			striker = true
	if coup_crisis.is_empty() and week >= int(_diff("grace")) and week >= crisis_cooldown and share_now >= _diff("coup_share") - pressure_steps * 0.02 and striker:
		_open_crisis()


func _ready_share_without(x: Actor) -> float:
	var total := 0.0
	var ready_p := 0.0
	for a: Actor in actors.values():
		if not a.insider or a.supporting:
			continue
		total += a.power
		if a.ready and a != x:
			ready_p += a.power
	return ready_p / maxf(total, 1.0)


func _coup_now(lead: Actor) -> void:
	for a: Actor in actors.values():
		if a.ready and a.insider:
			a.moved = true
	coup_leader = lead.id
	king_strength = 0.0


func _log_plot(a: Actor, from: int, to: int) -> void:
	var text := ""
	if to >= 2 and from < 2:
		text = "komploya katıldı"
	elif to == 3 and from == 2:
		text = "darbe hazırlığına geçti"
	elif from >= 2 and to < 2:
		text = "komplodan çekildi"
	elif to == 1 and from == 0 and not _plot_seen(a, "huzursuzlanmaya başladı"):
		text = "huzursuzlanmaya başladı"
	if text != "":
		plot_log.append({"w": week, "name": a.display_name, "text": text})


func _plot_seen(a: Actor, text: String) -> bool:
	for l: Dictionary in plot_log:
		if l["name"] == a.display_name and l["text"] == text:
			return true
	return false


# ---------------------------------------------------------------- Alametler

## Komplo görünür izler bırakır; sakin aktörler hakkında da dedikodu çıkar (alametlerin bir kısmı yanlıştır).
func _plot_signs() -> void:
	for a: Actor in actors.values():
		if a.moved or not a.insider or a.supporting:
			continue
		var st := clampi(a.plot_stage, 0, 3)
		if rng.randf() < float(PLOT_SIGN_P[st]):
			var pair := _sign_text_pair(a, st)
			_add_sign(a, str(pair["tr"]), int(PLOT_SIGN_W[st]), st > 0, str(pair["en"]))


func _add_sign(a: Actor, text: String, weight: int, real: bool, text_en: String = "") -> void:
	var shown_en := text_en if text_en != "" else Loc.en(text)
	if shown_en != "":
		shown_en = shown_en.substr(0, 1).to_upper() + shown_en.substr(1)   # "the Prince ..." cümle başında büyük harf
	a.signs.append({"w": week, "text": text, "text_en": shown_en, "weight": weight, "real": real})
	if a.signs.size() > 12:
		a.signs.pop_front()
	_add_news("ALAMET: " + text, tr("ALAMET: ") + shown_en)


func _sign_text(a: Actor, st: int) -> String:
	return _narrative._sign_text(a, st)


func _sign_text_pair(a: Actor, st: int) -> Dictionary:
	return _narrative._sign_text_pair(a, st)


## Oyuncunun gördüğü alametlerin son haftalardaki ağırlığı (sayı olarak gösterilmez).
func suspicion(id: String) -> int:
	var a: Actor = actors.get(id)
	if a == null:
		return 0
	var s := 0
	for g: Dictionary in a.signs:
		if int(g["w"]) > week - PLOT_SUS_WINDOW:
			s += int(g["weight"])
	return s


## 0 Sakin, 1 Huzursuz, 2 Şüpheli, 3 Tehlikeli
func suspicion_level(id: String) -> int:
	var s := suspicion(id)
	var lvl := 0
	for b in PLOT_SUS_BANDS:
		if s >= int(b):
			lvl += 1
	return lvl


# ---------------------------------------------------------------- Darbe krizi

func _crisis_guard() -> float:
	var g := 0.0
	for a: Actor in actors.values():
		if a.insider and (a.military or a.royal) and not a.ready:
			g += a.power
	return g / 100.0


func crisis_chance(action: String) -> float:
	var share := _ready_power_share()
	if action == "rally":
		return clampf((CRISIS_RALLY_BASE + (king_strength - 50.0) / 100.0 + _crisis_guard() * 0.3 + (1.0 - share) * 0.5) * _diff("crisis_odds") + (float(capacity["ordu"]) - 55.0) / STATE_RALLY_DENOM[difficulty] + foreign_defense_bonus(), 0.05, 0.85)
	if action == "appeal":
		return clampf((CRISIS_APPEAL_BASE - unrest / 100.0 - opposition / 200.0 + (king_strength - 50.0) / 200.0) * _diff("crisis_odds"), 0.05, 0.8)
	return float(CRISIS_CONCEDE[mini(int(stats.get("concessions", 0)), CRISIS_CONCEDE.size() - 1)])


func _open_crisis() -> void:
	var lead: Actor = null
	for a: Actor in actors.values():
		if a.ready and a.insider and (a.military or a.royal) and (lead == null or a.power > lead.power):
			lead = a
	if lead == null:
		return
	coup_crisis = {"leader": lead.id, "week": week}
	plot_log.append({"w": week, "name": lead.display_name, "text": "darbe girişimini başlattı"})
	pending.insert(0, {"event": _crisis_event(lead), "age": 0})
	_add_news("KRİZ: %s harekete geçti. Saray kuşatılmak üzere." % lead.display_name,
		tr("KRİZ: %s harekete geçti. Saray kuşatılmak üzere.") % lead.display_name)


func _crisis_event(lead: Actor) -> Dictionary:
	var nm := short_name(lead)
	var opening := tr("Prens'in muhafızları sarayın doğu kanadını tuttu. Soylular taht salonunda toplanıyor; kimse seni çağırmadı.")
	if lead.military:
		opening = tr("%s birlikleri başkentin girişlerini tuttu. Saraya mühürlü bir mektup geldi: 'Majestelerinin istirahati için.'") % ek(nm, "in")
	var rally := crisis_chance("rally")
	var appeal := crisis_chance("appeal")
	var guard_b := 2 if rally >= 0.5 else (1 if rally >= 0.3 else 0)
	var street_b := 2 if appeal >= 0.45 else (1 if appeal >= 0.25 else 0)
	var guard_t: String = tr(["Muhafız komutanı çağrılarına cevap vermiyor.", "Muhafızların bir kısmı tereddütte.", "Saray muhafızları sana bağlı görünüyor."][guard_b])
	var street_t: String = tr(["Sokak öfkeli; meydanlar senin için dolmayabilir.", "Sokak tedirgin; kimse kimin kazanacağını bilmiyor.", "Sokaklar sakin; halk sana hâlâ kulak verir."][street_b])
	return {"id": "darbe_krizi", "art": "general_atamalari" if lead.military else "gizli_toplanti", "crisis": true, "advisors": [],
		"crisis_kind": "coup", "banner": tr("DARBE GİRİŞİMİ — bu hafta karar vermezsen saray düşer."),
		"title": tr("Darbe kapıda"),
		"text": tr("%s\n%s %s%s") % [opening, guard_t, street_t,
			"" if int(stats.get("concessions", 0)) == 0 else tr(" Bir kez boyun eğdin; bu kez sözüne inanmayabilirler.")],
		"cues": {"guard": guard_b, "street": street_b},
		"choices": [
			{"label": tr("Sadık birlikleri topla, liderleri tutuklat"), "crisis": "rally", "fx": {}},
			{"label": tr("%s istediğini ver") % ek(nm, "e"), "crisis": "concede", "fx": {}},
			{"label": tr("Balkona çık, halka seslen"), "crisis": "appeal", "fx": {}}],
		"ignore": {"text": tr("Karar verilmedi. Kapılar açıldı."), "fx": {}}}


func _close_crisis() -> void:
	coup_crisis = {}
	for i in range(pending.size() - 1, -1, -1):
		if pending[i]["event"].get("crisis", false) and str(pending[i]["event"].get("crisis_kind", "coup")) == "coup":
			pending.remove_at(i)


func _resolve_crisis(action: String) -> String:
	var lead: Actor = actors.get(coup_crisis.get("leader", ""))
	var conspirators: Array = []
	for a: Actor in actors.values():
		if a.ready and a.insider and a != lead:
			conspirators.append(a)
	crisis_cooldown = week + CRISIS_COOLDOWN
	if lead == null:
		_close_crisis()
		return tr("Darbenin lideri ortada yok; komplo dağıldı.")
	var nm := short_name(lead)
	match action:
		"rally":
			if rng.randf() < crisis_chance("rally"):
				_close_crisis()
				flags["DARBE_BASTIRILDI"] = week
				flags[lead.id.to_upper() + "_GITTI"] = week
				var knowers: Array = [lead.id]
				for a: Actor in conspirators:
					a.fear += 20.0
					a.ambition = maxf(0.0, a.ambition - 10.0)
					a.ready = false
					a.plot_calm = 0
					knowers.append(a.id)
				plot_log.append({"w": week, "name": lead.display_name, "text": "tutuklandı (darbe bastırıldı)"})
				actors.erase(lead.id)
				king_strength = clampf(king_strength + 5.0, 0.0, 100.0)
				unrest = clampf(unrest + 8.0, 0.0, 100.0)
				_add_fact("darbe_bastirma_%d" % week, "Darbe girişiminin gece yarısı sert biçimde bastırılması", "king", 25, knowers, 1)
				return tr("Sadık birlikler gece yarısı karargâhı bastı. %s tutuklandı. Komplocular sindi; ama bu gecenin izi kalacak.") % nm
			coup_crisis["failed"] = true
			crisis_note = tr("Darbe gecesi sadık birlikleri toplamaya çalıştın; muhafızlar silahlarını indirdi.")
			return tr("Muhafızlar silahlarını indirdi. %s kapıdan girdiğinde salonda senden başka kimse yoktu.") % nm
		"concede":
			if rng.randf() >= crisis_chance("concede"):
				coup_crisis["failed"] = true
				crisis_note = tr("Darbe gecesi bir kez daha taviz vermeyi denedin; bu kez kimse sözüne inanmadı.")
				return tr("%s teklifini dinledi, sonra güldü: 'Bunu geçen sefer de söylemiştiniz, Majesteleri.'") % nm
			stats["concessions"] = int(stats.get("concessions", 0)) + 1
			_close_crisis()
			flags["DARBE_TAVIZ"] = week
			lead.power += 15.0
			lead.loyalty["career"] = float(lead.loyalty["career"]) + 30.0
			lead.obligation += 10.0
			lead.ambition += 3.0
			lead.ready = false
			for a: Actor in conspirators:
				a.ready = false
				a.plot_calm = 0
			for a: Actor in actors.values():
				a.perceived_king -= 5.0
			king_strength = clampf(king_strength - 15.0, 0.0, 100.0)
			plot_log.append({"w": week, "name": lead.display_name, "text": "taviz koparıp geri çekildi"})
			return tr("%s istediğini aldı. Tanklar kışlaya döndü; ama artık herkes bu ülkeyi gerçekte kimin yönettiğini biliyor.") % nm
		_:
			if rng.randf() < crisis_chance("appeal"):
				_close_crisis()
				flags["DARBE_HALK"] = week
				for a: Actor in conspirators:
					a.ready = false
					a.plot_calm = 0
					a.fear += 10.0
				king_strength = clampf(king_strength + 3.0, 0.0, 100.0)
				unrest = clampf(unrest - 5.0, 0.0, 100.0)
				plot_log.append({"w": week, "name": lead.display_name, "text": "halk sarayın önüne dolunca yalnız kaldı"})
				return tr("Meydan doldu. Kalabalık adını haykırırken %s yanındakilerin birer birer telefonu kapattığını gördü.") % nm
			unrest = clampf(unrest + 15.0, 0.0, 100.0)
			coup_crisis["failed"] = true
			crisis_note = tr("Darbe gecesi halka seslendin; meydan boş kaldı.")
			return tr("Balkona çıktığında meydan yarı boştu. Gelenler de senin için değil, ne olacağını görmek için gelmişti.")


# ---------------------------------------------------------------- Sokak ve mahkeme krizleri (docs/design/kayip_cesitliligi.md)

const STREET_ANGER_GAIN := 8.0     # bastırma emri başına öfke (× uygulama)
const STREET_ANGER_DECAY := 0.93   # haftalık sönme
const STREET_FEED := 0.03          # öfkenin huzursuzluğu haftalık beslemesi
const UPRISING_AT := 54.0          # ayaklanma krizi eşiği (huzursuzluk); ölçüt botta en yüksek huzursuzluk medyan 38, en kötü 61
const LEGAL_CRISIS_AT := 40.0      # yetki krizi eşiği (yargı baskısı); ölçüt botta en yüksek medyan 28, en kötü 47
const STREET_WARN_AT := 46.0
const LEGAL_WARN_AT := 32.0
const OTHER_CONCEDE := [0.85, 0.5, 0.25]   # kabul/uzlaşma: ilki büyük olasılıkla tutar, sonrakilere daha az inanılır

var street_anger := 0.0            # bastırmanın biriktirdiği öfke (gizli)
var legal_relief := 0.0            # uzlaşma/tasfiye/pazarlıkla düşülen yargı baskısı
var other_crisis: Dictionary = {}  # {kind: street|legal|border|siege|assassination, week, phase?, failed?}
var warned: Dictionary = {}        # işaret satırları bir kez: {"street": true, "legal": true}


func _check_crises() -> void:
	if ended:
		return
	var crisis_pending := false
	for entry: Dictionary in pending:
		if entry.get("event", {}).get("crisis", false):
			crisis_pending = true
	if other_crisis.get("phase", "") == "crisis" and not crisis_pending:
		other_crisis["week"] = week
		pending.insert(0, {"event": _external_event(str(other_crisis["kind"])), "age": 0})
		return
	# Açık kriz bir hafta içinde çözülmediyse ya da seçilen yol başarısız olduysa sonuçlanır.
	if not other_crisis.is_empty() and (other_crisis.get("failed", false) or week > int(other_crisis["week"])):
		var kind := str(other_crisis["kind"])
		if kind in ["border", "siege", "assassination"]:
			flags["external_defeat"] = kind
		_close_other()
		if crisis_note == "":
			crisis_note = tr("Kriz kapına dayandığında karar veremedin.")
		if kind == "street":
			unrest = 100.0
		else:
			flags["YETKI_KAYBI"] = week
		return
	# İşaretler (tohum -> işaret): eşiğe yaklaşınca bir kez haber; geri çekilince yeniden kurulur.
	var lp := legal_pressure()
	var pressure_steps := maxi(0, week - MAX_WEEKS - 1) / 26 if endless else 0
	var uprising_at := UPRISING_AT - pressure_steps * 2.0
	var legal_at := LEGAL_CRISIS_AT - pressure_steps * 2.0
	if unrest >= STREET_WARN_AT and not warned.get("street", false):
		warned["street"] = true
		_add_news("SOKAK: Meydanlardaki kalabalık her gün büyüyor; artık dağılmıyorlar.",
			tr("SOKAK: Meydanlardaki kalabalık her gün büyüyor; artık dağılmıyorlar."))
	elif unrest < STREET_WARN_AT - 10.0:
		warned.erase("street")
	if lp >= LEGAL_WARN_AT and not warned.get("legal", false):
		warned["legal"] = true
		_add_news("MAHKEME: Savcılar saraya dair dosyaları tek bir soruşturmada topluyor.",
			tr("MAHKEME: Savcılar saraya dair dosyaları tek bir soruşturmada topluyor."))
	elif lp < LEGAL_WARN_AT - 10.0:
		warned.erase("legal")
	if not other_crisis.is_empty() or not coup_crisis.is_empty():
		return
	if week < int(_diff("grace")) or week < crisis_cooldown:
		return
	if int(flags.get("SUIKAST_OMEN_DUE", 0)) > 0 and week >= int(flags["SUIKAST_OMEN_DUE"]):
		_open_other("assassination")
	elif unrest >= uprising_at:
		_open_other("street")
	elif lp >= legal_at:
		_open_other("legal")
	elif float(ext_pressure.get("drakon", 0.0)) >= BORDER_CRISIS_AT:
		_open_other("border")
	elif maxf(float(ext_pressure.get("asteria", 0.0)), float(ext_pressure.get("seravia", 0.0))) >= SIEGE_CRISIS_AT and (treasury < 52.0 or float(capacity["maliye"]) < 42.0):
		_open_other("siege")
	elif _assassination_conditions() and not flags.has("SUIKAST_OMEN_DUE") and ext_rng.randf() < ASSASSINATION_OMEN_CHANCE:
		flags["SUIKAST_OMEN_DUE"] = week + 1
		external_history.append({"week": week, "kind": "assassination", "action": "omen"})
		_add_news("GÜVENLİK: Saray nöbetçileri değişti; gece arabaları doğu kapısında bekliyor.", tr("GÜVENLİK: Saray nöbetçileri değişti; gece arabaları doğu kapısında bekliyor."))


func _assassination_conditions() -> bool:
	var conspirators := 0
	for actor: Actor in actors.values():
		if actor.insider and not actor.supporting and not actor.moved and actor.plot_stage >= 2:
			conspirators += 1
	return conspirators >= 2 and _ready_power_share() >= _diff("coup_share") - 0.16 and (unrest >= 38.0 or legal_pressure() >= 26.0)


func other_chance(action: String) -> float:
	if str(other_crisis.get("kind", "")) == "border":
		match action:
			"force": return clampf((float(capacity["ordu"]) + _army_loyalty() + treasury - 120.0) / 200.0, 0.08, 0.78)
			"concede": return clampf(0.85 - float(stats.get("border_concessions", 0)) * 0.35, 0.18, 0.85)
			_: return clampf((float(foreign.get("asteria", 50.0)) + float(capacity["hukuk"]) - ext_pressure["asteria"]) / 200.0, 0.1, 0.8)
	if str(other_crisis.get("kind", "")) == "siege":
		match action:
			"austerity": return clampf((treasury + float(capacity["maliye"]) - 30.0) / 150.0, 0.12, 0.78)
			"capital": return clampf((float(actors["halden"].power if actors.has("halden") else 35.0) + float(capacity["maliye"])) / 160.0, 0.15, 0.82)
			_: return clampf(0.85 - float(stats.get("siege_concessions", 0)) * 0.35, 0.18, 0.85)
	if str(other_crisis.get("kind", "")) == "assassination":
		match action:
			"security": return clampf(0.18 + (actors["voss"].total_loyalty() / 120.0 if actors.has("voss") else 0.25), 0.12, 0.72)
			"route": return clampf(0.48 + king_strength / 300.0, 0.2, 0.78)
			_: return clampf(0.38 + king_strength / 250.0 - unrest / 250.0, 0.12, 0.68)
	var odds := _diff("crisis_odds")
	match action:
		"force":
			return clampf((0.25 + _army_loyalty() / 200.0 - street_anger / 200.0 + (king_strength - 50.0) / 200.0) * odds + (float(capacity["ordu"]) - 55.0) / 250.0, 0.05, 0.85)
		"appeal":
			return clampf((0.5 + (king_strength - 50.0) / 100.0 - street_anger / 150.0 - opposition / 300.0) * odds, 0.05, 0.8)
		"purge":
			return clampf((0.55 - opposition / 200.0 - _public_weakness()) * odds, 0.05, 0.8)
		"bargain":
			return clampf((0.6 - opposition / 100.0) * odds, 0.05, 0.75)
	# concede / testify
	var key := "street_concessions" if action == "concede" else "legal_concessions"
	return float(OTHER_CONCEDE[mini(int(stats.get(key, 0)), OTHER_CONCEDE.size() - 1)])


func _open_other(kind: String) -> void:
	other_crisis = {"kind": kind, "week": week}
	if kind == "assassination":
		other_crisis["phase"] = "prep"
		flags.erase("SUIKAST_OMEN_DUE")
	elif kind in ["border", "siege"]:
		other_crisis["phase"] = "note"
	var e: Dictionary
	if kind == "street":
		e = _street_event()
	elif kind == "legal":
		e = _legal_event()
	else:
		e = _external_event(kind)
	pending.insert(0, {"event": e, "age": 0})
	var crisis_news := "KRİZ: Meydanlar ayakta; sokak sarayın kapısında." if kind == "street" else ("KRİZ: Mahkeme kralın yetkilerini askıya almayı görüşüyor." if kind == "legal" else ("KRİZ: Asteria ve Seravia krediyi kesti; devlet ödeme planı istiyor." if kind == "siege" else ("KRİZ: Kortej planı bu gece uygulanacak." if kind == "assassination" else "KRİZ: Drakon sınır hattında ültimatom verdi.")))
	_add_news(crisis_news, tr(crisis_news))
	if kind in ["border", "siege", "assassination"]:
		external_history.append({"week": week, "kind": kind, "action": "warning"})
		crisis_cooldown = week + CRISIS_COOLDOWN


func _external_event(kind: String) -> Dictionary:
	if kind == "assassination":
		var assassination_template := _event_template("b1c_kortej_plani")
		if not assassination_template.is_empty():
			return assassination_template
	if kind == "siege":
		var siege_id := "b1b_ambargo_notasi" if other_crisis.get("phase", "note") == "note" else "b1b_kredi_kesildi"
		var siege_template := _event_template(siege_id)
		if not siege_template.is_empty():
			return siege_template
	if kind == "border":
		if other_crisis.get("phase", "note") == "note":
			var note_template := _event_template("b1a_drakon_sinir_notasi")
			if not note_template.is_empty():
				return note_template
			return {"id": "b1a_drakon_sinir_notasi", "art": "sinir_hatti", "crisis": true, "crisis_kind": kind, "advisors": [],
				"banner": tr("SINIR NOTASI — Drakon bu hafta yanıt bekliyor."), "title": tr("Drakon sınırda tatbikat başlattı"),
				"text": tr("Malenkov, birliklerin hareketini savundu ve son bir görüşme önerdi. Sınırdaki komutanlar senden açık talimat bekliyor."),
				"choices": [
					{"label": tr("Elçiyi görüşmeye çağır"), "crisis": "talk", "fx": {}},
					{"label": tr("Sınırda tatbikat emri ver"), "crisis": "force", "fx": {}}],
				"ignore": {"text": tr("Drakon yanıt alamadı ve birliklerini sınırda tuttu."), "fx": {}}}
		var template := _event_template("drakon_ultimatom")
		if not template.is_empty():
			return template
		return {"id": "drakon_ultimatom", "art": "sinir_hatti", "crisis": true, "crisis_kind": kind, "advisors": [],
			"banner": tr("SINIR ÜLTİMATOMU — bu hafta karar vermezsen Drakon birlikleri ilerleyecek."),
			"title": tr("Drakon sınır hattına ültimatom verdi"),
			"text": tr("General Malenkov tatbikatı gerçek bir konuşlanmaya çevirdi. Elçi son bir görüşme istedi; Arden sınırda emir bekliyor."),
			"cues": {"guard": _band3(other_chance("force"), 0.5, 0.3), "street": _band3(other_chance("concede"), 0.7, 0.4)},
			"choices": [
				{"label": tr("Orduyu sınıra gönder, taviz verme"), "crisis": "force", "fx": {}},
				{"label": tr("Müzakere et ve sınır tavizi ver"), "crisis": "concede", "fx": {}},
				{"label": tr("Asteria'dan güvence iste"), "crisis": "guarantee", "fx": {}}],
			"ignore": {"text": tr("Drakon birlikleri sınır kapılarına ilerledi."), "fx": {}}}
	return {}


func _event_template(id: String) -> Dictionary:
	for event: Dictionary in _events:
		if str(event.get("id", "")) == id:
			var result := event.duplicate(true)
			result["crisis"] = true
			result["crisis_kind"] = str(other_crisis.get("kind", ""))
			if id == "b1c_kortej_plani":
				result["banner"] = tr("KORTEJ PLANI — saldırı bu gece bekleniyor.")
			elif id == "b1a_drakon_sinir_notasi":
				result["banner"] = tr("SINIR NOTASI — Drakon bu hafta yanıt bekliyor.")
			elif id == "b1b_ambargo_notasi":
				result["banner"] = tr("AMBARGO NOTASI — alacaklılar bu hafta yanıt bekliyor.")
			elif id == "b1b_kredi_kesildi":
				result["banner"] = tr("KREDİ KESİLDİ — ödeme planını bu hafta belirle.")
			else:
				result["banner"] = tr("SINIR ÜLTİMATOMU — bu hafta karar vermezsen Drakon birlikleri ilerleyecek.")
			return result
	return {}


func _band3(p: float, hi: float, mid: float) -> int:
	return 2 if p >= hi else (1 if p >= mid else 0)


func _street_event() -> Dictionary:
	var force_b := _band3(other_chance("force"), 0.5, 0.3)
	var appeal_b := _band3(other_chance("appeal"), 0.45, 0.25)
	var army_t: String = tr(["Komutanlar halka ateş açma emrini tartışıyor; kimse ilk adımı atmak istemiyor.", "Ordu emir bekliyor, ama emri kimin vereceğini merak ediyor.", "Birlikler hazır; sana bağlı görünüyorlar."][force_b])
	var street_t: String = tr(["Kalabalık artık senin adını değil, sloganlarını haykırıyor.", "Kalabalık öfkeli ama dinlemeye hazır görünenler var.", "Kalabalığın çoğu hâlâ senden bir söz bekliyor."][appeal_b])
	return {"id": "ayaklanma_krizi", "art": "genel_grev", "crisis": true, "crisis_kind": "street", "advisors": [],
		"banner": tr("AYAKLANMA — bu hafta karar vermezsen saray düşer."),
		"title": tr("Sokaklar ayakta"),
		"text": tr("Başkentin bütün meydanları dolu. Barikatlar sarayın üç sokak ötesinde. Leyla'nın gazetesi tek kelimelik bir manşet attı: 'Yeter.'\n%s %s%s") % [army_t, street_t,
			"" if int(stats.get("street_concessions", 0)) == 0 else tr(" Daha önce taleplerini kabul ettiğini söylemiştin; bu kez sözüne inanmayabilirler.")],
		"cues": {"guard": force_b, "street": appeal_b},
		"choices": [
			{"label": tr("Orduyu sokağa sür"), "crisis": "force", "fx": {}},
			{"label": tr("Taleplerini kabul et"), "crisis": "concede", "fx": {}},
			{"label": tr("Meydana in, halkla konuş"), "crisis": "appeal", "fx": {}}],
		"ignore": {"text": tr("Karar verilmedi. Barikatlar sarayın kapısına ulaştı."), "fx": {}}}


func _legal_event() -> Dictionary:
	var purge_b := _band3(other_chance("purge"), 0.45, 0.25)
	var bargain_b := _band3(other_chance("bargain"), 0.45, 0.25)
	var judge := tr("Başsavcı Renn") if actors.has("falk") else tr("Başsavcı")
	var court_t: String = tr(["Mahkemenin arkasında meclis ve sokak var; tasfiyeye kimse seyirci kalmaz.", "Mahkeme bölünmüş; bazı yargıçlar senden bir işaret bekliyor.", "Mahkeme yalnız; arkasında duran pek kimse yok."][purge_b])
	var house_t: String = tr(["Muhalefet meclisi elinde tutuyor; pazarlığa ihtiyacı yok.", "Mecliste kararsız sıralar var.", "Meclis bölünmüş; bir dokunulmazlık yasası geçebilir."][bargain_b])
	return {"id": "yetki_krizi", "art": "yargic_dosya", "crisis": true, "crisis_kind": "legal", "advisors": [],
		"banner": tr("YETKİ KRİZİ — bu hafta karar vermezsen yetkilerin elinden alınır."),
		"title": tr("Mahkeme yetkilerini askıya almayı görüşüyor"),
		"text": tr("%s biriken dosyaları tek bir kararla birleştirdi: kralın yetkileri, soruşturma bitene kadar meclise devredilecek. Karar yarın okunacak.\n%s %s%s") % [judge, court_t, house_t,
			"" if int(stats.get("legal_concessions", 0)) == 0 else tr(" Daha önce mahkemeyle uzlaştın; bu kez yalnızca sözünle yetinmeyebilirler.")],
		"cues": {"guard": purge_b, "street": bargain_b},
		"choices": [
			{"label": tr("Mahkemeyi tasfiye et"), "crisis": "purge", "fx": {}},
			{"label": tr("İfade ver, mahkemeyle uzlaş"), "crisis": "testify", "fx": {}},
			{"label": tr("Meclisle dokunulmazlık pazarlığı yap"), "crisis": "bargain", "fx": {}}],
		"ignore": {"text": tr("Karar verilmedi. Mahkeme kararını okudu."), "fx": {}}}


func _close_other() -> void:
	other_crisis = {}
	for i in range(pending.size() - 1, -1, -1):
		var k := str(pending[i]["event"].get("crisis_kind", ""))
		if pending[i]["event"].get("crisis", false) and k != "coup" and k != "":
			pending.remove_at(i)


func _fail_other(note: String) -> void:
	other_crisis["failed"] = true
	crisis_note = note


func _resolve_other(action: String) -> String:
	crisis_cooldown = week + CRISIS_COOLDOWN
	var kind := str(other_crisis.get("kind", ""))
	var ok := (ext_rng if kind in ["border", "siege", "assassination"] else rng).randf() < other_chance(action)
	if kind == "border":
		if other_crisis.get("phase", "") == "note":
			external_history.append({"week": week, "kind": kind, "action": action, "success": ok, "phase": "note"})
			if action == "talk":
				ext_pressure["drakon"] = maxf(0.0, float(ext_pressure["drakon"]) - 10.0)
			else:
				ext_pressure["drakon"] = minf(100.0, float(ext_pressure["drakon"]) + 6.0)
			other_crisis["phase"] = "crisis"
			other_crisis["week"] = week + 1
			return tr("Drakon yanıtı aldı; Malenkov ültimatomu için son bir hafta tanıdı.")
		external_history.append({"week": week, "kind": kind, "action": action, "success": ok})
		if not ok:
			flags["external_defeat"] = kind
			_fail_other(tr("Drakon birlikleri sınırı geçti; elit koalisyonu seni teslim etti."))
			return tr("Tatbikat gerçek bir ilerleyişe dönüştü. Başkentten gelen raporlar artık emir değil, mazeret taşıyor.")
		_close_other()
		var relief := 34.0 if action == "concede" else (26.0 if action == "guarantee" else 20.0)
		ext_pressure["drakon"] = maxf(0.0, float(ext_pressure["drakon"]) - relief)
		if action == "force":
			if actors.has("arden"):
				actors["arden"].power += 8.0
			treasury = maxf(0.0, treasury - 8.0)
		elif action == "concede":
			stats["border_concessions"] = int(stats.get("border_concessions", 0)) + 1
			king_strength = maxf(0.0, king_strength - 6.0)
			unrest = minf(100.0, unrest + 5.0)
			foreign["drakon"] = minf(100.0, float(foreign["drakon"]) + 8.0)
		else:
			foreign["asteria"] = minf(100.0, float(foreign["asteria"]) + 6.0)
			private_wealth = maxf(0.0, private_wealth - 5.0)
		return tr("Drakon geri çekildi; saray bu tavrın bedelini ve kime borçlandığını unutmayacak.")
	if kind == "siege":
		if other_crisis.get("phase", "") == "note":
			external_history.append({"week": week, "kind": kind, "action": action, "phase": "note"})
			other_crisis["phase"] = "crisis"
			other_crisis["week"] = week + 1
			return tr("Kredi görüşmeleri kesildi; alacaklılar haftaya ödeme planını bekliyor.")
		external_history.append({"week": week, "kind": kind, "action": action, "success": ok})
		if not ok:
			flags["external_defeat"] = kind
			_fail_other(tr("Devlet maaş ödeyemedi. Kredi kesildi ve maliye çöktü; elitler seni desteklemeyi bıraktı."))
			return tr("Bankalar teminatlarını çekti. Başkentte memurların maaş kuyruğu uzarken, meclis saraya sırtını döndü.")
		_close_other()
		for power in ["asteria", "seravia"]:
			ext_pressure[power] = maxf(0.0, float(ext_pressure[power]) - (32.0 if action == "concede" else 20.0))
		if action == "austerity":
			treasury = minf(100.0, treasury + 18.0)
			economy = maxf(0.0, economy - 10.0)
			unrest = minf(100.0, unrest + 12.0)
		elif action == "capital":
			treasury = minf(100.0, treasury + 22.0)
			holding = minf(100.0, holding + 10.0)
			if actors.has("halden"):
				actors["halden"].power = minf(100.0, actors["halden"].power + 8.0)
		else:
			stats["siege_concessions"] = int(stats.get("siege_concessions", 0)) + 1
			foreign["asteria"] = maxf(0.0, float(foreign["asteria"]) - 8.0)
			foreign["seravia"] = maxf(0.0, float(foreign["seravia"]) - 8.0)
			capacity["maliye"] = maxf(0.0, float(capacity["maliye"]) - 8.0)
		return tr("Ödeme krizi ertelendi; devletin nefesi açıldı, fakat seçtiğin yol yeni bir bedel bıraktı.")
	if kind == "assassination":
		external_history.append({"week": week, "kind": kind, "action": action, "success": ok})
		if not ok:
			flags["external_defeat"] = kind
			_fail_other(tr("Saldırganlar korteji buldu; muhafızlar seni koruyamadı."))
			return tr("Gece yarısı kapılar kapandı. Sabah olduğunda saray, hükümdarsız kaldı.")
		_close_other()
		flags["SUIKAST_ATLATILDI"] = week
		flags["ASSASSINATION_SURVIVED"] = week
		king_strength = maxf(0.0, king_strength - 12.0)
		_add_fact("saldiri_gecesi_%d" % week, "Hükümdar saldırı gecesinden yaralı kurtuldu", "king", 35, ["voss", "arden", "elena"], 1)
		plot_log.append({"w": week, "name": king_name, "text": "suikast girişiminden yaralı kurtuldu"})
		if action == "security" and actors.has("voss"):
			actors["voss"].power = maxf(0.0, actors["voss"].power - 5.0)
		elif action == "route":
			private_wealth = maxf(0.0, private_wealth - 4.0)
		else:
			king_strength = minf(100.0, king_strength + 5.0)
			unrest = maxf(0.0, unrest - 5.0)
		return tr("Saldırı gecesi yaralı kurtuldun. Sarayda artık kimin gece arabalarını gönderdiğine dair bir sır var.")
	match action:
		"force":
			if not ok:
				_fail_other(tr("Ayaklanma gecesi orduyu sokağa sürdün; askerler kalabalığa katıldı."))
				return tr("Askerler barikata vardı ve durdu. Biri miğferini çıkardı; sonra hepsi.")
			_close_other()
			unrest = clampf(unrest - 30.0, 0.0, 100.0)
			street_anger = minf(100.0, street_anger + 20.0)
			if actors.has("arden"):
				actors["arden"].power += 8.0
			_add_fact("kanli_gece_%d" % week, "Ayaklanmanın ordu eliyle kanlı bastırılması", "king", 45, ["arden", "lena", "brandt"], 1)
			return tr("Meydanlar sabaha temizlendi. Kimse sayıyı söylemiyor; herkes biliyor.")
		"concede":
			if not ok:
				_fail_other(tr("Ayaklanma gecesi yine söz verdin; kimse inanmadı."))
				return tr("Talepleri kabul ettiğini duyurdun. Meydandan gelen cevap bir kahkahaydı.")
			_close_other()
			stats["street_concessions"] = int(stats.get("street_concessions", 0)) + 1
			unrest = clampf(unrest - 25.0, 0.0, 100.0)
			street_anger = maxf(0.0, street_anger - 30.0)
			economy = clampf(economy - 10.0, 0.0, 100.0)
			king_strength = clampf(king_strength - 6.0, 0.0, 100.0)
			_set_parliament_base_opposition(parliament_base_opposition + 6.0)
			return tr("Fiyatlar donduruldu, iki bakan istifa etti. Barikatlar söküldü; muhalefet bu geceyi zafer sayıyor.")
		"appeal":
			if not ok:
				_fail_other(tr("Ayaklanma gecesi meydana indin; kalabalık seni dinlemedi."))
				return tr("Meydana indiğinde sesin uğultuda kayboldu. Muhafızların seni geri çekmesi gerekti.")
			_close_other()
			unrest = clampf(unrest - 18.0, 0.0, 100.0)
			street_anger = maxf(0.0, street_anger - 10.0)
			king_strength = clampf(king_strength + 3.0, 0.0, 100.0)
			return tr("Meydanda konuştun. Kalabalık önce sustu, sonra dağıldı. Bu gece kimse kazanmadı; kimse de kaybetmedi.")
		"purge":
			if not ok:
				_fail_other(tr("Yetki krizinde mahkemeyi tasfiye etmeye kalktın; meclis ve sokak mahkemenin arkasında durdu."))
				return tr("Tasfiye kararnamesini meclis bir saat içinde iptal etti. Yargıçlar kürsüde, sen saraydasın; ama ne kadar?")
			_close_other()
			legal_relief += 45.0
			if actors.has("falk"):
				flags["FALK_GITTI"] = week
				actors.erase("falk")
			_set_parliament_base_opposition(parliament_base_opposition + 8.0)
			unrest = clampf(unrest + 6.0, 0.0, 100.0)
			_add_fact("yargi_tasfiyesi_%d" % week, "Yüksek Mahkemenin tasfiye edilmesi", "king", 40, ["brandt", "lena"], 1)
			return tr("Yeni yargıçlar yemin etti. Dosyalar rafa kalktı; ama rafın nerede olduğunu herkes biliyor.")
		"testify":
			if not ok:
				_fail_other(tr("Yetki krizinde mahkemeyle yeniden uzlaşmaya çalıştın; bu kez sözüne itibar edilmedi."))
				return tr("İfade verdin. Yargıçlar dinledi, not aldı ve kararı yine de okudu.")
			_close_other()
			stats["legal_concessions"] = int(stats.get("legal_concessions", 0)) + 1
			legal_relief += 30.0
			king_strength = clampf(king_strength - 12.0, 0.0, 100.0)
			return tr("Mahkemede saatlerce ifade verdin. Karar ertelendi; tacın ağırlığı bir parça hafifledi, bir parça da azaldı.")
		_:  # bargain
			if not ok:
				_fail_other(tr("Yetki krizinde meclisle dokunulmazlık pazarlığına girdin; meclis pazarlığı reddetti."))
				return tr("Dokunulmazlık yasası oylamada düştü. Muhalefet sıralarında alkış vardı.")
			_close_other()
			legal_relief += 35.0
			private_wealth = maxf(0.0, private_wealth - 5.0)
			_set_parliament_base_opposition(parliament_base_opposition + 5.0)
			return tr("Dokunulmazlık yasası birkaç oy farkla geçti. Bazı vekiller bu hafta yeni arabalarla geldi.")
	return ""


## Ekranda gösterilecek açık kriz şeridi ("" yoksa).
func active_crisis_label() -> String:
	if not coup_crisis.is_empty():
		return tr("DARBE GİRİŞİMİ")
	match str(other_crisis.get("kind", "")):
		"street":
			return tr("AYAKLANMA")
		"legal":
			return tr("YETKİ KRİZİ")
		"border": return tr("DIŞ MÜDAHALE")
		"siege": return tr("MALİ KUŞATMA")
		"assassination": return tr("SUİKAST")
	return ""


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
		if not a.insider or a.supporting:
			continue
		total += a.power
		if a.ready:
			ready_p += a.power
	return ready_p / maxf(total, 1.0)


## Yargının saraya yaklaşması. Kamuya açılan skandal en çok o hafta acıtır; halk zamanla unutur
## (30 haftada ağırlığın %40'ına iner). Gizli kanıtlar az da olsa baskı yaratır.
func legal_pressure() -> float:
	var s := 0.0
	var tender_case := 0.0
	for f: Dictionary in facts.values():
		if f["subject"] != "king":
			continue
		var w := 0.15
		if f.get("public", false):
			w = maxf(0.4, 1.0 - float(week - int(f.get("public_week", week))) / 50.0)
		var weight: float = float(f["severity"]) * w
		if str(f["id"]).begins_with("ihale_komisyonu_"):
			tender_case = maxf(tender_case, weight)
		else:
			s += weight
	s += tender_case
	var relief := legal_relief + (0.5 if parliament_laws.has("amnesty") else 0.0)
	if parliament_laws.has("judicial"):
		relief += 0.5
	return clampf((s / 2.4 - relief) * (1.0 + (float(capacity["hukuk"]) - 55.0) / 100.0) * LEGAL_DIFF[difficulty], 0.0, 100.0)


func _check_end() -> void:
	if king_strength <= 0.0 or unrest >= 100.0 or legal_pressure() >= 100.0 or flags.has("YETKI_KAYBI") or flags.has("external_defeat"):
		_end(false)
	elif week > MAX_WEEKS and not endless:
		_end(true)


func _end(survived: bool) -> void:
	ended = true
	mesai = 0  # biten oyunda harcanacak mesai kalmaz (kriz hafta ortasında bitirebilir)
	var top: Actor = null
	for a: Actor in actors.values():
		if top == null or a.power > top.power:
			top = a
	var cause := ""
	var cause_display := ""
	var title := ""
	if not survived:
		title = "Devrilen Kral"
		var external_cause := str(flags.get("external_defeat", ""))
		if external_cause == "border":
			title = "Çöken Egemen"
			cause = "Saltanatının %d. haftasında Drakon sınırı geçti; elit koalisyonu seni teslim etti. Yabancı müdahalesi başkentin yönetimini sona erdirdi." % (week - 1)
			cause_display = tr("Saltanatının %d. haftasında Drakon sınırı geçti; elit koalisyonu seni teslim etti. Yabancı müdahalesi başkentin yönetimini sona erdirdi.") % (week - 1)
		elif external_cause == "siege":
			title = "Mali Çöküş"
			cause = "Saltanatının %d. haftasında kredi kesildi ve devlet maaş ödeyemedi. Mali çöküş elit koalisyonunu dağıttı." % (week - 1)
			cause_display = tr("Saltanatının %d. haftasında kredi kesildi ve devlet maaş ödeyemedi. Mali çöküş elit koalisyonunu dağıttı.") % (week - 1)
		elif external_cause == "assassination":
			title = "Suikast"
			cause = "Saltanatının %d. haftasında saldırganlar korteji buldu; muhafızlar seni koruyamadı. Suikast sarayı başsız bıraktı." % (week - 1)
			cause_display = tr("Saltanatının %d. haftasında saldırganlar korteji buldu; muhafızlar seni koruyamadı. Suikast sarayı başsız bıraktı.") % (week - 1)
		elif coup_leader != "" and actors.has(coup_leader):
			var l: Actor = actors[coup_leader]
			var promo_week: int = flags.get(l.id.to_upper() + "_GUCLENDI", 0)
			if promo_week > 0:
				var promo_gap := week - promo_week
				cause = "Saltanatının %d. haftasında %s görevden alındı. Darbenin lideri %s, yalnızca %d hafta önce kendisi tarafından terfi ettirilmişti." % [week - 1, "Askerî darbeyle" if l.military else "Saray darbesiyle", l.display_name, week - promo_week]
				cause_display = Loc.ntr("Saltanatının %d. haftasında Askerî darbeyle görevden alındı. Darbenin lideri %s, yalnızca %d hafta önce kendisi tarafından terfi ettirilmişti.", promo_gap) % [week - 1, l.display_name, promo_gap] if l.military else Loc.ntr("Saltanatının %d. haftasında Saray darbesiyle görevden alındı. Darbenin lideri %s, yalnızca %d hafta önce kendisi tarafından terfi ettirilmişti.", promo_gap) % [week - 1, l.display_name, promo_gap]
			else:
				cause = "Saltanatının %d. haftasında %s görevden alındı. Darbenin lideri %s. Onu hiç terfi ettirmemiştin; gücünü sen başka işlerle uğraşırken kendi başına topladı." % [week - 1, "Askerî darbeyle" if l.military else "Saray darbesiyle", l.display_name]
				cause_display = tr("Saltanatının %d. haftasında Askerî darbeyle görevden alındı. Darbenin lideri %s. Onu hiç terfi ettirmemiştin; gücünü sen başka işlerle uğraşırken kendi başına topladı.") % [week - 1, l.display_name] if l.military else tr("Saltanatının %d. haftasında Saray darbesiyle görevden alındı. Darbenin lideri %s. Onu hiç terfi ettirmemiştin; gücünü sen başka işlerle uğraşırken kendi başına topladı.") % [week - 1, l.display_name]
			if crisis_note != "":
				cause += " " + crisis_note
				cause_display += " " + crisis_note
		elif unrest >= 100.0:
			cause = "Saltanatının %d. haftasında halk ayaklanması sarayı kuşattı." % (week - 1)
			cause_display = tr("Saltanatının %d. haftasında halk ayaklanması sarayı kuşattı.") % (week - 1)
			if crisis_note != "":
				cause += " " + crisis_note
				cause_display += " " + crisis_note
		elif legal_pressure() >= 100.0 or flags.has("YETKI_KAYBI"):
			cause = "Saltanatının %d. haftasında Meclis ve yüksek mahkeme, biriken skandallar nedeniyle seni yetkisiz bıraktı." % (week - 1)
			cause_display = tr("Saltanatının %d. haftasında Meclis ve yüksek mahkeme, biriken skandallar nedeniyle seni yetkisiz bıraktı.") % (week - 1)
			if crisis_note != "":
				cause += " " + crisis_note
				cause_display += " " + crisis_note
		else:
			cause = "Saltanatının %d. haftasında elit koalisyonu desteğini çekti; tahtta kimse seni savunmadı." % (week - 1)
			cause_display = tr("Saltanatının %d. haftasında elit koalisyonu desteğini çekti; tahtta kimse seni savunmadı.") % (week - 1)
	else:
		cause = "104 haftalık saltanatın sonunda tahtını korudun."
		cause_display = tr("104 haftalık saltanatın sonunda tahtını korudun.")
		var state_title := _survivor_title(top)
		title = state_title if state_title in ["Harap Devletin Kralı", "Liyakat Kralı"] else str(REGIME_TITLES.get(regime, state_title))
		if flags.has("ASSASSINATION_SURVIVED"):
			title = "Yaralı Egemen"
			cause = "104 haftalık saltanatın sonunda tahtını korudun; suikast gecesinden yaralı kurtuldun."
			cause_display = tr("104 haftalık saltanatın sonunda tahtını korudun; suikast gecesinden yaralı kurtuldun.")
	record = {"survived": survived, "title": title, "weeks": week - 1, "cause": cause,
		"top_actor": top.display_name if top else "", "history": history.duplicate(), "cause_display": cause_display,
		"lies": _top_lies(), "king": king_name,
		"regime": str(REGIME_NAMES.get(regime, "")) if regime != "" else "", "threat": str(REGIME_THREATS.get(regime, "")) if regime != "" else "",
		"promises": "%d söz verdin: %d tutuldu, %d bozuldu." % [int(stats.get("promises", 0)), int(stats.get("kept", 0)), int(stats.get("broken", 0))],
		"promises_display": Loc.ntr("%d söz verdin: %d tutuldu, %d bozuldu.", int(stats.get("promises", 0))) % [int(stats.get("promises", 0)), int(stats.get("kept", 0)), int(stats.get("broken", 0))],
		"historians": historians(survived), "timeline": timeline.duplicate(), "council": council_record(),
		"plot": plot_log.duplicate(), "signs": sign_record(), "state": _state_record(),
		"scenario": scenario_id, "scenario_name": scenario_name, "endless": endless, "external_history": external_history.duplicate(true)}
	record["new_achievements"] = _award_achievements(survived, title, cause) if record_chronicle else []
	if record_chronicle:
		_record_dynasty(record)
		_append_chronicle(record)
	# Biten saltanata kayıttan geri dönülmez: tarih tek yönlüdür.
	if autosave and FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	game_ended.emit(record)


func _capacity_average() -> float:
	if capacity_timeline.is_empty():
		return (float(capacity["maliye"]) + float(capacity["hukuk"]) + float(capacity["ordu"]) + float(capacity["idare"])) / 4.0
	var total := 0.0
	for point: Dictionary in capacity_timeline:
		total += (float(point["maliye"]) + float(point["hukuk"]) + float(point["ordu"]) + float(point["idare"])) / 4.0
	return total / capacity_timeline.size()


func _state_record() -> Dictionary:
	var chart: Array = timeline.duplicate(true)
	var lowest := 101.0
	var low_week := 0
	var peak := holding
	for i in mini(chart.size(), capacity_timeline.size()):
		var point: Dictionary = capacity_timeline[i]
		var mean := (float(point["maliye"]) + float(point["hukuk"]) + float(point["ordu"]) + float(point["idare"])) / 4.0
		chart[i]["capacity"] = mean
		chart[i]["holding"] = float(point.get("holding", holding))
		peak = maxf(peak, float(chart[i]["holding"]))
		if mean < lowest:
			lowest = mean
			low_week = int(point["w"])
	var low_event := tr("O hafta kayda geçen bir olay yok.")
	for entry in history:
		if str(entry).begins_with("Hafta %d " % low_week):
			low_event = str(entry)
			break
	var coldest := 101.0
	var cold_week := 0
	for point: Dictionary in chart:
		if float(point.get("foreign", 50.0)) < coldest:
			coldest = float(point.get("foreign", 50.0))
			cold_week = int(point["w"])
	return {"timeline": chart, "average": _capacity_average(), "lowest": lowest, "low_week": low_week,
		"low_event": low_event, "appointments": kadro_log.duplicate(true), "tenders": int(stats.get("tenders", 0)),
		"hostile_weeks": int(stats.get("halden_hostile_weeks", 0)), "holding_peak": peak, "holding_final": holding,
		"delegations": int(stats.get("delegations", 0)), "foreign_coldest": coldest, "foreign_cold_week": cold_week, "heir_final": heir_maturity}


func historians(survived: bool) -> Array:
	return _narrative.historians(survived)


## Başarımlar: id -> [ad, açıklama]. Kalıcıdır, saltanatlar arası birikir.
const ACHIEVEMENTS_PATH := "user://veloria_achievements.txt"
var ACHIEVEMENTS: Dictionary = {}


func load_achievements(extension := false) -> Dictionary:
	var path := EXTENSION_ACHIEVEMENTS_PATH if extension else ACHIEVEMENTS_PATH
	if not FileAccess.file_exists(path):
		return {}
	var d: Variant = str_to_var(FileAccess.open(path, FileAccess.READ).get_as_text())
	return d if d is Dictionary else {}


## Saltanat sonunda kazanılan yeni başarımları kaydeder ve döndürür.
func _award_achievements(survived: bool, title: String, cause: String) -> Array:
	var earned: Array = ["ilk_saltanat"]
	if int(stats.get("elections", 0)) > 0:
		earned.append("sandik_mandati")
	if int(stats.get("government_formations", 0)) > 0:
		earned.append("koalisyon_mimari")
	if int(stats.get("confidence_votes", 0)) > 0:
		earned.append("guven_oyunu")
	if survived:
		earned.append("tahtta_kal")
		earned.append_array(_economy_achievement_ids())
		earned.append_array(_region_achievement_ids())
		if dynasty_generation >= 2:
			earned.append("kusaklar")
		if dynasty_generation >= 3:
			earned.append("uc_nesil")
		if dynasty_generation >= 5:
			earned.append("bes_nesil")
		if difficulty == 2:
			earned.append("zor_zafer")
		if int(stats.get("bribes", 0)) == 0 and int(stats.get("blackmails", 0)) == 0 and int(stats.get("written", 0)) == 0:
			earned.append("temiz_eller")
		if int(stats.get("kept", 0)) >= 2 and int(stats.get("broken", 0)) == 0:
			earned.append("sozunun_eri")
		if flags.has("halef_karari_0"):
			earned.append("anayasal")
		if flags.has("halef_karari_1"):
			earned.append("hanedan")
		if title.contains("Kukla") or title.contains("Tutsağı"):
			earned.append("kukla")
	else:
		if str(flags.get("external_defeat", "")) == "border":
			earned.append("yabanci_mudahale")
		elif str(flags.get("external_defeat", "")) == "siege":
			earned.append("mali_kusatma")
		elif str(flags.get("external_defeat", "")) == "assassination":
			earned.append("suikast")
		elif coup_leader != "" and actors.has(coup_leader):
			earned.append("darbe")
		elif unrest >= 100.0:
			earned.append("ayaklanma")
		elif legal_pressure() >= 100.0 or flags.has("YETKI_KAYBI"):
			earned.append("yetkisiz")
	if int(stats.get("blackmails", 0)) >= 3:
		earned.append("sirlar")
	if int(stats.get("ops", 0)) >= 5:
		earned.append("operator")
	if int(stats.get("checks", 0)) >= 10:
		earned.append("gercegi_goren")
	if fired_events.has("reform_meyve"):
		earned.append("reformcu")
	if survived and _capacity_average() < 35.0:
		earned.append("harap_devlet")
	if survived and _capacity_average() > 70.0:
		earned.append("liyakat_krali")
	if holding >= 90.0:
		earned.append("oligarkin_esiri")
	if float(record["state"]["holding_peak"]) >= 70.0 and holding < 40.0:
		earned.append("oligarki_dizginleyen")
	var all_near := true
	var all_cold := true
	for power in ["asteria", "drakon", "seravia"]:
		all_near = all_near and float(foreign.get(power, 0.0)) >= 70.0
		all_cold = all_cold and float(foreign.get(power, 100.0)) <= 30.0
	if all_near:
		earned.append("uc_bayrak")
	if survived and all_cold:
		earned.append("yalniz_kral")
	if heir_maturity >= 70.0:
		earned.append("hazir_veliaht")
	if survived and flags.has("ASSASSINATION_SURVIVED"):
		earned.append("yarali_egemen")
	match scenario_id:
		"darbe": earned.append("senaryo_darbe")
		"naiplik": earned.append("senaryo_naiplik")
		"bos_kasa": earned.append("senaryo_bos_kasa")
	var have := load_achievements(endless)
	var fresh: Array = []
	for id in earned:
		if not have.has(id):
			have[id] = Time.get_date_string_from_system()
			fresh.append(id)
	if record_chronicle and not fresh.is_empty():
		var path := EXTENSION_ACHIEVEMENTS_PATH if endless else ACHIEVEMENTS_PATH
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string(var_to_str(have))
	return fresh


func _economy_achievement_ids() -> Array[String]:
	var earned: Array[String] = []
	if treasury >= 60.0 and float(economy_metrics.get("debt", 100.0)) <= 40.0:
		earned.append("butce_dengesi")
	if float(economy_metrics.get("jobs", 0.0)) >= 70.0 and float(economy_metrics.get("growth", 0.0)) >= 65.0:
		earned.append("uretim_atilimi")
	if float(economy_metrics.get("trade", 0.0)) >= 70.0 and float(economy_metrics.get("inflation", 100.0)) <= 35.0:
		earned.append("fiyat_istikrari")
	return earned


func _region_achievement_ids() -> Array[String]:
	var earned: Array[String] = []
	if int(stats.get("regional_actions", 0)) >= 4:
		earned.append("regional_steward")
	var spread := 0
	var voice := 0
	for id in REGION_WEIGHTS:
		if int(stats.get("regional_investments", {}).get(id, 0)) > 0 or int(stats.get("regional_garrisons", {}).get(id, 0)) > 0:
			spread += 1
		if int(stats.get("regional_media", {}).get(id, 0)) > 0:
			voice += 1
	if spread >= 3:
		earned.append("regional_balance")
	if voice >= 3:
		earned.append("regional_voice")
	return earned


## Hükümdarlık arşivi: biten her saltanat kalıcı olarak kaydedilir.
func load_chronicle() -> Array:
	if not FileAccess.file_exists(CHRONICLE_PATH):
		return []
	var f := FileAccess.open(CHRONICLE_PATH, FileAccess.READ)
	var d: Variant = str_to_var(f.get_as_text())
	return d if d is Array else []


func _append_chronicle(r: Dictionary) -> void:
	var list := load_chronicle()
	list.append({"date": Time.get_date_string_from_system(), "title": r["title"], "weeks": r["weeks"],
		"survived": r["survived"], "cause": r["cause"], "difficulty": tr("Uzatma") if endless else DIFFICULTY[difficulty]["name"],
		"extension": endless, "scenario": scenario_id})
	var f := FileAccess.open(CHRONICLE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(var_to_str(list.slice(maxi(0, list.size() - 50))))


func _survivor_title(top: Actor) -> String:
	if _capacity_average() < 35.0:
		return "Harap Devletin Kralı"
	if _capacity_average() > 70.0:
		return "Liyakat Kralı"
	if top != null and top.power > 85.0:
		if top.military:
			return "Generallerin Kuklası"
		if top.domain == "media":
			return "Medya İmparatorunun Kuklası"
		if top.domain == "intel":
			return "Gölge Devletin Tutsağı"
		return "%s Kuklası" % ek(top.display_name, "in")
	if private_wealth >= 50.0:
		return "Altın Kral"
	if economy < 25.0:
		return "Devleti Tüketen"
	if int(stats.get("broken", 0)) >= 3:
		return "Vaatler Kralı"
	if int(stats.get("kept", 0)) >= 2 and int(stats.get("broken", 0)) == 0:
		return "Sözünün Eri"
	if int(stats.get("blackmails", 0)) >= 3:
		return "Sırların Efendisi"
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
	var count := 0
	for a: Actor in actors.values():
		if not a.supporting:
			s += a.fear
			count += 1
	return clampf(s / maxf(count, 1) / 60.0, 0.0, 1.0)


func _domain_truth(domain: String) -> float:
	match domain:
		"economy":
			return _economy_health() * 0.7 + treasury * 0.3
		"army":
			return clampf(unrest * 0.5 + maxf(0.0, 55.0 - _army_loyalty()), 0.0, 100.0)
		"gate":
			return 100.0 - king_strength
		"opposition":
			return opposition
		"intel":
			# İstihbarat hem sokağı hem saraydaki komployu izler.
			return clampf(maxf(unrest * 0.6, _ready_power_share() * 120.0), 0.0, 100.0)
		"court":
			return legal_pressure()
		"royal":
			var p: Actor = actors.get("prens")
			return clampf(p.ambition + (100.0 - king_strength) * 0.3, 0.0, 100.0) if p else 0.0
		"heir":
			return 100.0 - heir_maturity
		"foreign":
			return 100.0 - _foreign_average()
		_:
			return unrest


func _economy_health() -> float:
	return clampf((100.0 - float(economy_metrics.get("inflation", 45.0))) * 0.18
		+ float(economy_metrics.get("jobs", economy)) * 0.25
		+ (100.0 - float(economy_metrics.get("debt", 45.0))) * 0.15
		+ float(economy_metrics.get("trade", economy)) * 0.12
		+ float(economy_metrics.get("growth", economy)) * 0.30, 0.0, 100.0)


func _update_economy_metrics() -> void:
	# Keep the old summary as the weighted target while the separate RNG supplies noisy detail.
	var target := economy
	var jitter := economy_rng.randf_range(-3.0, 3.0)
	economy_metrics["inflation"] = clampf(lerpf(float(economy_metrics["inflation"]), 100.0 - target + unrest * 0.16 + jitter, 0.35), 0.0, 100.0)
	economy_metrics["jobs"] = clampf(lerpf(float(economy_metrics["jobs"]), target - unrest * 0.12 + jitter, 0.3), 0.0, 100.0)
	economy_metrics["debt"] = clampf(lerpf(float(economy_metrics["debt"]), 100.0 - treasury + jitter, 0.3), 0.0, 100.0)
	economy_metrics["trade"] = clampf(lerpf(float(economy_metrics["trade"]), (float(foreign["asteria"]) + float(foreign["seravia"])) * 0.5 + jitter, 0.3), 0.0, 100.0)
	var known := ((100.0 - float(economy_metrics["inflation"])) * 0.18 + float(economy_metrics["jobs"]) * 0.25
		+ (100.0 - float(economy_metrics["debt"])) * 0.15 + float(economy_metrics["trade"]) * 0.12)
	economy_metrics["growth"] = clampf((target - known) / 0.30, 0.0, 100.0)
	economy = _economy_health()


func economy_report(source: String) -> String:
	var flattering: float = actors[source].flattery() * 0.35 if source == "kessler" and actors.has(source) else 0.0
	var noise: float = economy_rng.randf_range(-9.0, 9.0)
	var prices: float = float(economy_metrics["inflation"]) - flattering * 12.0 + noise
	var jobs_value: float = float(economy_metrics["jobs"]) + flattering * 8.0 + noise * 0.5
	var debt_value: float = float(economy_metrics["debt"]) - flattering * 10.0 - noise * 0.4
	var trade_value: float = float(economy_metrics["trade"]) + noise * (0.35 if source == "halden" else 0.15)
	var growth_value: float = float(economy_metrics["growth"]) + noise * 0.5
	var lines: Array[String] = [
		tr("Fiyatlar %s.") % tr("tırmanıyor" if prices >= 65.0 else ("oynak" if prices >= 42.0 else "sakin")),
		tr("İş piyasası %s.") % tr("daralıyor" if jobs_value < 38.0 else ("yavaşlıyor" if jobs_value < 58.0 else "canlı")),
		tr("Borç yükü %s.") % tr("ağır" if debt_value >= 68.0 else ("hissediliyor" if debt_value >= 42.0 else "hafif")),
		tr("Ticaret %s, üretim %s.") % [tr("geriliyor" if trade_value < 40.0 else ("temkinli" if trade_value < 60.0 else "akıyor")), tr("yavaş" if growth_value < 40.0 else ("ılımlı" if growth_value < 60.0 else "genişliyor"))]
	]
	return " ".join(lines)


func economy_journal_line() -> String:
	for report: Dictionary in reports:
		if str(report.get("source", "")) == finance_report_source:
			return tr("Maliye: ") + str(report.get("text", ""))
	return tr("Maliye raporu bu hafta masaya ulaşmadı.")


func _army_loyalty() -> float:
	var a: Actor = actors.get("arden")
	return a.total_loyalty() if a else 50.0


func _domain_reported(a: Actor) -> float:
	var t := _domain_truth(a.domain)
	var good := 100.0 if a.domain in GOOD_DOMAINS_HIGH else 0.0
	# Komplocu kendi alanını olduğundan iyi gösterir.
	return lerpf(t, good, minf(1.0, a.flattery() * 0.6 + (PLOT_SPIN if a.ready else 0.0)))


func _band(a: Actor, value: float) -> int:
	if a.domain in GOOD_DOMAINS_HIGH:
		return 0 if value > 62.0 else (1 if value > 40.0 else 2)
	return 0 if value < 30.0 else (1 if value < 55.0 else 2)


func _foreign_average() -> float:
	var total := 0.0
	for power in ["asteria", "drakon", "seravia"]:
		total += float(foreign.get(power, 50.0))
	return total / 3.0


func _new_regions(start_unrest: float, start_economy: float) -> Dictionary:
	var result := {}
	var unrest_offsets := {}
	var economy_offsets := {}
	var mean_unrest := 0.0
	var mean_economy := 0.0
	for id in REGION_WEIGHTS:
		unrest_offsets[id] = region_rng.randf_range(-4.0, 4.0)
		economy_offsets[id] = region_rng.randf_range(-6.0, 6.0)
		mean_unrest += float(unrest_offsets[id]) * float(REGION_WEIGHTS[id])
		mean_economy += float(economy_offsets[id]) * float(REGION_WEIGHTS[id])
	var unrest_scale := _regional_offset_scale(unrest_offsets, mean_unrest, start_unrest)
	var economy_scale := _regional_offset_scale(economy_offsets, mean_economy, start_economy)
	for id in REGION_WEIGHTS:
		var governor := "governor_" + str(id)
		result[id] = {"unrest": clampf(start_unrest + (float(unrest_offsets[id]) - mean_unrest) * unrest_scale, 0.0, 100.0),
			"loyalty": clampf(55.0 + region_rng.randf_range(-8.0, 8.0), 0.0, 100.0),
			"economy": clampf(start_economy + (float(economy_offsets[id]) - mean_economy) * economy_scale, 0.0, 100.0),
			"governor": governor, "garrison": 0.0, "media": 0.0}
	return result


func _regional_offset_scale(offsets: Dictionary, mean: float, center: float) -> float:
	var largest := 0.0
	for id in REGION_WEIGHTS:
		largest = maxf(largest, absf(float(offsets[id]) - mean))
	return minf(1.0, minf(center, 100.0 - center) / largest) if largest > 0.0 else 1.0


func _sync_regions_to_national() -> void:
	# National changes apply across regions; local changes return through the weighted summary.
	var local_unrest_mean := 0.0
	var local_economy_mean := 0.0
	for id in REGION_WEIGHTS:
		local_unrest_mean += float(regions[id]["unrest"]) * float(REGION_WEIGHTS[id])
		local_economy_mean += float(regions[id]["economy"]) * float(REGION_WEIGHTS[id])
	_set_region_mean("unrest", local_unrest_mean + unrest - region_sync_unrest)
	_set_region_mean("economy", local_economy_mean + economy - region_sync_economy)
	var weighted_unrest := 0.0
	var weighted_economy := 0.0
	for id in REGION_WEIGHTS:
		weighted_unrest += float(regions[id]["unrest"]) * float(REGION_WEIGHTS[id])
		weighted_economy += float(regions[id]["economy"]) * float(REGION_WEIGHTS[id])
	unrest = weighted_unrest
	economy = weighted_economy
	region_sync_unrest = unrest
	region_sync_economy = economy


func _set_region_mean(field: String, target: float) -> void:
	var low := -100.0
	var high := 100.0
	for _step in 24:
		var offset := (low + high) * 0.5
		var mean := 0.0
		for id in REGION_WEIGHTS:
			mean += clampf(float(regions[id].get(field, target)) + offset, 0.0, 100.0) * float(REGION_WEIGHTS[id])
		if mean < target:
			low = offset
		else:
			high = offset
	var final_offset := (low + high) * 0.5
	for id in REGION_WEIGHTS:
		regions[id][field] = clampf(float(regions[id].get(field, target)) + final_offset, 0.0, 100.0)


func region_report_line() -> String:
	var lead := "capital"
	for id in REGION_WEIGHTS:
		if float(regions.get(id, {}).get("unrest", 0.0)) > float(regions.get(lead, {}).get("unrest", 0.0)):
			lead = id
	var region: Dictionary = regions.get(lead, {})
	var unrest_tone := tr("huzurlu") if float(region.get("unrest", 0.0)) < 35.0 else (tr("huzursuz") if float(region.get("unrest", 0.0)) < 65.0 else tr("gergin"))
	var economy_tone := tr("canlı") if float(region.get("economy", 0.0)) >= 60.0 else (tr("durgun") if float(region.get("economy", 0.0)) >= 40.0 else tr("daralmış"))
	var loyalty := float(region.get("loyalty", 50.0))
	var loyalty_tone := tr("sağlam") if loyalty >= 62.0 else (tr("tereddütlü") if loyalty >= 42.0 else tr("zayıf"))
	return tr("Bölgeler: %s öne çıkıyor — %s, pazar %s, bağlılık %s; diğer bölgeler izleniyor.") % [tr(str(REGION_NAMES[lead])), unrest_tone, economy_tone, loyalty_tone]


func _tick_region_systems() -> void:
	var keep: Array[Dictionary] = []
	for effect: Dictionary in regional_effects:
		if int(effect["due"]) > week:
			keep.append(effect)
			continue
		var region: Dictionary = regions[str(effect["region"])]
		match str(effect["field"]):
			"economy": region["economy"] = clampf(float(region["economy"]) + float(effect["amount"]), 0.0, 100.0)
			"loyalty": region["loyalty"] = clampf(float(region["loyalty"]) + float(effect["amount"]), 0.0, 100.0)
			"unrest": region["unrest"] = clampf(float(region["unrest"]) + float(effect["amount"]), 0.0, 100.0)
	regional_effects = keep
	if other_crisis.is_empty() and coup_crisis.is_empty() and week - last_region_crisis_week >= 6 and pending.is_empty():
		_check_regional_crisis()


func request_regional_decision() -> String:
	if mesai < 1 or not pending.is_empty() or week - last_region_action_week < 12:
		return tr("Yeni bölgesel tahsis için karar sırası ve hazineyi beklemelisin.")
	_queue_region_action()
	return tr("Bölgesel tahsis gündeme alındı; bir bölge seç.")


func _queue_region_action() -> void:
	var choices: Array = []
	for id in REGION_WEIGHTS:
		choices.append({"label": tr(str(REGION_NAMES[id])), "action": "select_region", "region": id, "fx": {}})
	last_region_action_week = week
	stats["regional_events"] = int(stats.get("regional_events", 0)) + 1
	pending.append({"event": {"id": "region_action_%d" % week, "kind": "regional_action", "title": tr("Bölgesel tahsis ve atama kararı"),
		"text": tr("R1 bütçe payları hangi bölgeye ulaşsın? Yatırımlar ve garnizonlar gecikmeli sonuç verir; yerel yayın desteği R2 rızasını etkiler."),
		"advisors": ["kessler", "dorn"], "choices": choices, "ignore": {"text": tr("Bu hafta bölgesel tahsis yapılmadı."), "fx": {}}}, "age": 0})
	_add_news("OLAY: Bölgesel tahsis ve atama kararı.", Loc.en("OLAY: Bölgesel tahsis ve atama kararı."))


func _queue_region_action_options(id: String) -> void:
	if not regions.has(id): return
	var choices: Array = [
		{"label": tr("Altyapı yatırımı"), "action": "invest", "region": id, "available": float(budget_allocation.get("industry", 25.0)) >= 15.0 and treasury >= 8.0, "fx": {}},
		{"label": tr("Garnizon takviyesi"), "action": "garrison", "region": id, "available": float(budget_allocation.get("army", 25.0)) >= 15.0 and treasury >= 6.0, "fx": {}},
		{"label": tr("Yerel yayın desteği"), "action": "media", "region": id, "available": float(budget_allocation.get("social", 25.0)) >= 15.0 and treasury >= 5.0, "fx": {}}]
	var governor := str(regions[id].get("governor", ""))
	if governor != "":
		choices.append({"label": tr("Valiyi azlet"), "action": "dismiss", "region": id, "available": treasury >= 5.0, "fx": {}})
	else:
		for actor_id in actors:
			if str(actor_id).begins_with("governor_") and not _governor_assigned(str(actor_id)):
				choices.append({"label": tr("%s'i vali ata") % actors[actor_id].display_name, "action": "appoint", "region": id, "actor": actor_id, "available": treasury >= 8.0, "fx": {}})
	pending.append({"event": {"id": "region_options_%d" % week, "kind": "regional_action", "title": tr("%s için karar") % tr(str(REGION_NAMES[id])),
		"text": tr("Bütçe tahsisi, yerel rıza ya da vali ataması arasında seçim yap."), "advisors": ["kessler", "dorn"], "choices": choices,
		"ignore": {"text": tr("Bölge için bu hafta karar alınmadı."), "fx": {}}}, "age": 0})


func _governor_assigned(actor_id: String) -> bool:
	for region: Dictionary in regions.values():
		if str(region.get("governor", "")) == actor_id:
			return true
	return false


func _resolve_region_action(choice: Dictionary) -> String:
	var id := str(choice.get("region", ""))
	if not regions.has(id):
		return ""
	var region: Dictionary = regions[id]
	match str(choice.get("action", "")):
		"invest":
			if float(budget_allocation.get("industry", 25.0)) < 15.0 or treasury < 8.0:
				return tr("Sanayi tahsisi ya da hazine bu yatırımı karşılayamadı.")
			treasury -= 8.0
			regional_effects.append({"due": week + 4, "region": id, "field": "economy", "amount": 3.0 + float(budget_allocation["industry"]) * 0.05})
			stats["regional_investments"][id] = int(stats["regional_investments"][id]) + 1
			stats["regional_actions"] = int(stats.get("regional_actions", 0)) + 1
			return tr("%s için altyapı ödeneği ayrıldı; pazar etkisi birkaç hafta sonra görülecek.") % tr(str(REGION_NAMES[id]))
		"garrison":
			if float(budget_allocation.get("army", 25.0)) < 15.0 or treasury < 6.0:
				return tr("Ordu tahsisi ya da hazine bu takviyeyi karşılayamadı.")
			treasury -= 6.0
			region["garrison"] = minf(100.0, float(region.get("garrison", 0.0)) + 15.0 + float(budget_allocation["army"]) * 0.1)
			regional_effects.append({"due": week + 3, "region": id, "field": "unrest", "amount": -2.5})
			stats["regional_garrisons"][id] = int(stats["regional_garrisons"][id]) + 1
			stats["regional_actions"] = int(stats.get("regional_actions", 0)) + 1
			return tr("Garnizon %s iline konuşlandı; kısa vadede sükûnet, uzun vadede askerî nüfuz getirir.") % tr(str(REGION_NAMES[id]))
		"media":
			if float(budget_allocation.get("social", 25.0)) < 15.0 or treasury < 5.0:
				return tr("Sosyal tahsis ya da hazine yerel yayını destekleyemedi.")
			treasury -= 5.0
			region["media"] = minf(100.0, float(region.get("media", 0.0)) + 12.0)
			regional_effects.append({"due": week + 2, "region": id, "field": "loyalty", "amount": 3.0 + float(budget_allocation["social"]) * 0.03})
			consent = clampf(consent + 1.0, 0.0, 100.0)
			stats["regional_media"][id] = int(stats["regional_media"][id]) + 1
			stats["regional_actions"] = int(stats.get("regional_actions", 0)) + 1
			return tr("Yerel yayın desteği %s'de duyuruldu; rıza artarken editoryal bağımsızlık daralıyor.") % tr(str(REGION_NAMES[id]))
		"dismiss":
			if str(region.get("governor", "")) == "" or treasury < 5.0:
				return tr("Vali görevde değil ya da azil bedeli karşılanamıyor.")
			region["governor"] = ""
			treasury -= 5.0
			holding = maxf(0.0, holding - 2.0)
			parliament_blocs["royal"]["loyalty"] = maxf(0.0, float(parliament_blocs["royal"]["loyalty"]) - 4.0)
			parliament_blocs["nobles"]["pressure"] = minf(100.0, float(parliament_blocs["nobles"]["pressure"]) + 6.0)
			_refresh_parliament_opposition()
			stats["regional_governors"] = int(stats.get("regional_governors", 0)) + 1
			stats["regional_actions"] = int(stats.get("regional_actions", 0)) + 1
			return tr("%s valisi azledildi. Saray listesi desteğini yitirdi; soylular karşılık bekliyor.") % tr(str(REGION_NAMES[id]))
		"appoint":
			var actor_id := str(choice.get("actor", ""))
			if str(region.get("governor", "")) != "" or not actors.has(actor_id) or _governor_assigned(actor_id) or treasury < 8.0:
				return tr("Vali ataması için boş makam, aday ve hazine gerekir.")
			region["governor"] = actor_id
			treasury -= 8.0
			holding = minf(100.0, holding + 2.0)
			parliament_blocs["royal"]["loyalty"] = minf(100.0, float(parliament_blocs["royal"]["loyalty"]) + 2.0)
			parliament_blocs["nobles"]["pressure"] = minf(100.0, float(parliament_blocs["nobles"]["pressure"]) + 2.0)
			_refresh_parliament_opposition()
			stats["regional_governors"] = int(stats.get("regional_governors", 0)) + 1
			stats["regional_actions"] = int(stats.get("regional_actions", 0)) + 1
			return tr("%s, %s valisi oldu; atama bedeli patronaj defterine işlendi.") % [actors[actor_id].display_name, tr(str(REGION_NAMES[id]))]
	return ""


func _check_regional_crisis() -> void:
	var candidates: Array[String] = []
	for id in REGION_WEIGHTS:
		var region: Dictionary = regions[id]
		if id == "industry" and (float(region["unrest"]) >= 72.0 or float(region["economy"]) <= 30.0): candidates.append("strike")
		elif id == "farmland" and float(region["economy"]) <= 27.0: candidates.append("famine")
		elif id == "border" and float(region["unrest"]) >= 68.0: candidates.append("border")
		elif id == "capital" and float(region["unrest"]) >= 78.0: candidates.append("disorder")
	if candidates.is_empty() or region_rng.randf() > 0.2:
		return
	var kind: String = str(candidates[region_rng.randi_range(0, candidates.size() - 1)])
	var id: String = str({"strike": "industry", "famine": "farmland", "border": "border", "disorder": "capital"}[kind])
	last_region_crisis_week = week
	stats["regional_events"] = int(stats.get("regional_events", 0)) + 1
	if kind == "border":
		ext_pressure["drakon"] = minf(100.0, float(ext_pressure["drakon"]) + 12.0)
	var title: String = str({"strike": tr("Sanayi Kuşağı'nda grev"), "famine": tr("Tarım Ovaları'nda kıtlık"), "border": tr("Sınır İlleri'nde gerilim"), "disorder": tr("Başkent'te karışıklık")}[kind])
	var choices := [
		{"label": tr("Yerel talepleri karşıla"), "regional_crisis_action": "concede", "region": id, "regional_kind": kind},
		{"label": tr("Garnizona ve yönetime dayan"), "regional_crisis_action": "force", "region": id, "regional_kind": kind}]
	var e := {"id": "regional_crisis_%d" % week, "kind": "regional_crisis", "crisis": true, "crisis_kind": "regional",
		"title": title, "text": tr("Vali, yerel kurumların desteğinin çözülmekte olduğunu bildirdi. Ulusal baskı ve bölgenin koşulları krizi büyütebilir."),
		"advisors": [str(regions[id].get("governor", "dorn")), "kessler"], "choices": choices,
		"ignore": {"text": tr("Bölgedeki talepler yanıtsız kaldı."), "fx": {"unrest": 4.0}}}
	pending.insert(0, {"event": e, "age": 0})
	_add_news("KRİZ: " + str(title), "CRISIS: " + Loc.en(str(title)))


func _resolve_regional_crisis(choice: Dictionary) -> String:
	var id := str(choice.get("region", ""))
	if not regions.has(id): return ""
	var region: Dictionary = regions[id]
	var action := str(choice.get("regional_crisis_action", ""))
	var kind := str(choice.get("regional_kind", ""))
	var ok := region_rng.randf() < (0.55 + float(region.get("loyalty", 50.0)) / 300.0 if action == "concede" else 0.35 + float(region.get("garrison", 0.0)) / 200.0 + float(budget_allocation.get("army", 25.0)) / 250.0)
	if action == "concede":
		treasury = maxf(0.0, treasury - (9.0 if kind == "famine" else 6.0))
		region["unrest"] = maxf(0.0, float(region["unrest"]) - (12.0 if ok else 3.0))
		region["loyalty"] = minf(100.0, float(region["loyalty"]) + (7.0 if kind == "famine" and ok else (5.0 if ok else 1.0)))
	else:
		region["unrest"] = clampf(float(region["unrest"]) + (4.0 if ok else 15.0), 0.0, 100.0)
		if id == "border": ext_pressure["drakon"] = minf(100.0, float(ext_pressure["drakon"]) + 8.0)
		if kind == "strike" and actors.has("arden"): actors["arden"].power = minf(100.0, actors["arden"].power + 2.0)
	if kind == "disorder": unrest = clampf(unrest + (2.0 if action == "force" and not ok else -2.0), 0.0, 100.0)
	if not ok: region["economy"] = maxf(0.0, float(region["economy"]) - 5.0)
	if id == "border" and other_crisis.is_empty() and float(ext_pressure["drakon"]) >= BORDER_CRISIS_AT:
		other_crisis = {"kind": "border", "week": week, "phase": "crisis"}
	return tr("Bölgesel kriz yatıştı; %s etkisini birkaç hafta daha hissettirecek.") % tr(str(REGION_NAMES[id])) if ok else tr("Bölgedeki düzen bozuldu; ulusal yönetim ve yerel pazar baskı altında.")


func _foreign_report_value(power: String, verified: bool) -> float:
	var value: float = foreign.get(power, 50.0)
	if not verified:
		var elena: Actor = actors.get("elena")
		var noise := RandomNumberGenerator.new()
		noise.seed = rng.seed ^ (week * 11939) ^ power.hash()
		value += (elena.flattery() * 20.0 if elena else 0.0) + noise.randf_range(-4.0, 4.0)
	return clampf(value, 0.0, 100.0)


func foreign_band(power: String, verified: bool = false) -> String:
	var value := _foreign_report_value(power, verified)
	return tr("Soğuk") if value < 40.0 else (tr("Mesafeli") if value < 65.0 else tr("Yakın"))


func foreign_report(verified: bool = false) -> String:
	var report := tr("Asteria %s; Drakon %s; Seravia %s.") % [foreign_band("asteria", verified), foreign_band("drakon", verified), foreign_band("seravia", verified)]
	var hints: Array[String] = []
	for power in ["asteria", "drakon", "seravia"]:
		var hint := _external_report_hint(power)
		if hint != "":
			hints.append(hint)
	if not hints.is_empty():
		report += " " + " ".join(hints)
	return report


func _generate_reports() -> void:
	report_prev.clear()
	for r: Dictionary in reports:
		report_prev[str(r["source"])] = int(r["band"])
	reports.clear()
	var echo := echo_level()
	var dorn: Actor = actors.get("dorn")
	var worst_idx := -1
	var worst_band := -1
	for a: Actor in actors.values():
		if a.moved or a.supporting:
			continue
		var reported := _domain_reported(a) + rng.randf_range(-6.0, 6.0) * (1.0 - a.honesty * 0.5) * (1.0 + (55.0 - float(capacity["idare"])) / STATE_REPORT_NOISE)
		var rb := _band(a, reported)
		var tb := _band(a, _domain_truth(a.domain))
		var line: String = _phrase(a, reported, echo)
		if a.id == finance_report_source:
			line += " " + economy_report(a.id)
		if echo <= 0.75 and INSTITUTION_HEADS.has(a.id):
			var institution: String = INSTITUTION_HEADS[a.id]
			var variants: Array = REPORT_CONTENT["state"][institution][capacity_band(institution)]
			line += " " + str(variants[absi(("%s%d" % [a.id, week]).hash()) % variants.size()])
		if rb < tb:
			truth_log.append({"week": week, "name": a.display_name, "said": line,
				"truth": _phrase(a, _domain_truth(a.domain), 0.0), "diff": tb - rb})
		reports.append({"source": a.id, "name": a.display_name, "title": a.title, "text": line, "band": rb})
		if rb > worst_band and a.id != "dorn":
			worst_band = rb
			worst_idx = reports.size() - 1
	# Kraliçe (saray kapısı): güçlüyse kötü haberi odana ulaştırmayabilir.
	if dorn != null and not dorn.moved and worst_band >= 1 and worst_idx >= 0:
		if rng.randf() < clampf(0.15 + dorn.power / 250.0 + dorn.ambition / 400.0, 0.0, 0.7):
			var dropped: Dictionary = reports[worst_idx]
			reports.remove_at(worst_idx)
			truth_log.append({"week": week, "name": "Kraliçe Helena", "said": "(kötü haberi sana iletmedi)",
				"truth": "%s: %s" % [dropped["name"], dropped["text"]], "diff": 2})
	# Yeni kadro kendi raporunu ayrı üreteçle hazırlar; eski dokuz kaynağın ana RNG çekilişleri sabit kalır.
	for aid in ["julian", "elena"]:
		var a: Actor = actors.get(aid)
		if a == null or a.moved:
			continue
		var report_rng := RandomNumberGenerator.new()
		report_rng.seed = rng.seed ^ (week * 11939) ^ aid.hash()
		var reported := _domain_reported(a) + report_rng.randf_range(-6.0, 6.0) * (1.0 - a.honesty * 0.5)
		var line: String = _phrase(a, reported, echo)
		if aid == "elena":
			reported = 100.0 - (_foreign_report_value("asteria", week <= foreign_hint_until) + _foreign_report_value("drakon", week <= foreign_hint_until) + _foreign_report_value("seravia", week <= foreign_hint_until)) / 3.0
			line = foreign_report(week <= foreign_hint_until)
		var rb := _band(a, reported)
		var tb := _band(a, _domain_truth(a.domain))
		if rb < tb:
			truth_log.append({"week": week, "name": a.display_name, "said": line,
				"truth": _phrase(a, _domain_truth(a.domain), 0.0), "diff": tb - rb})
		reports.append({"source": a.id, "name": a.display_name, "title": a.title, "text": line, "band": rb})




func _phrase(a: Actor, value: float, echo: float) -> String:
	return _narrative._phrase(a, value, echo)


func _add_fact(id: String, text: String, subject: String, severity: float, knowers: Array, copies: int, leakiness: float = 0.5, text_en: String = "") -> void:
	facts[id] = {"id": id, "text": text, "subject": subject, "severity": severity,
		"text_en": text_en if text_en != "" else _fact_text_en(id, text), "knowers": knowers.duplicate(), "common": 0.0, "copies": copies, "leakiness": leakiness}


func _fact_text_en(id: String, text: String) -> String:
	return str(FACT_TEXT_EN.get(id, Loc.en(text)))


func fact_text_for_display(fact: Variant) -> String:
	var text := str(fact.get("text", "")) if fact is Dictionary else str(fact)
	if Loc.lang == "en" and fact is Dictionary and fact.has("text_en"):
		return str(fact["text_en"])
	if Loc.lang != "en": return text
	if text.ends_with(" yapılan gizli ödeme"):
		var apostrophe := text.find("'")
		if apostrophe > 0:
			return tr("Gizli ödeme %s") % text.substr(0, apostrophe)
	if text.begins_with("Aynı makamın birden çok kişiye vaat edilmesi (") and text.ends_with(")"):
		var start := text.rfind("(") + 1
		return tr("Aynı makamın birden çok kişiye vaat edilmesi (%s)") % tr(text.substr(start, text.length() - start - 1))
	return tr(text)
