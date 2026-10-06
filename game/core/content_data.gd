extends RefCounted
## İçerik tablolarının tek yükleme ve şema denetimi.

const FILES := {
	"reports": "res://game/data/content_reports.json",
	"council": "res://game/data/content_council.json",
	"history": "res://game/data/content_history.json",
	"achievements": "res://game/data/content_achievements.json",
	"labels": "res://game/data/content_labels.json"}
const ACTORS := "res://game/data/actors.json"
const REGIMES := ["guvenlikci", "populist", "patronajci", "oligark", "medya", "istihbarat"]

var error := ""


func load_all(overrides: Dictionary = {}) -> Dictionary:
	error = ""
	if not FileAccess.file_exists(ACTORS):
		return _fail(ACTORS, "dosya bulunamadı")
	var people: Variant = _read(ACTORS)
	if not people is Array:
		return _fail(ACTORS, "JSON bozuk veya aktör listesi dizi değil")
	var ids := {}
	var domains := {}
	for a in people:
		if not a is Dictionary or str(a.get("id", "")) == "" or str(a.get("domain", "")) == "":
			return _fail(ACTORS, "aktör kimliği veya alanı eksik")
		ids[str(a["id"])] = true
		domains[str(a["domain"])] = true
	var all := {}
	for key in FILES:
		var path: String = str(overrides.get(key, FILES[key]))
		if not FileAccess.file_exists(path):
			return _fail(path, "dosya bulunamadı")
		var data: Variant = _read(path)
		if not data is Dictionary:
			return _fail(path, "JSON bozuk veya kök sözlük değil")
		var issue := ""
		match key:
			"reports": issue = _reports(data, domains)
			"council": issue = _council(data, ids)
			"history": issue = _history(data)
			"achievements": issue = _achievements(data)
			"labels": issue = _labels(data)
		if issue != "":
			return _fail(path, issue)
		all[key] = data
	return all


func _read(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var parser := JSON.new()
	if parser.parse(f.get_as_text()) != OK:
		return null
	return parser.data


func _fail(path: String, issue: String) -> Dictionary:
	error = "İçerik dosyası hatalı: %s (%s). Oyunu başlatmadan dosyayı düzeltin." % [path, issue]
	return {}


func _text(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()


func _texts(value: Variant, minimum: int = 1) -> bool:
	if not value is Array or value.size() < minimum:
		return false
	for item in value:
		if not _text(item):
			return false
	return true


func _keys(data: Dictionary, expected: Array) -> String:
	for key in expected:
		if not data.has(key):
			return "eksik anahtar: %s" % key
	for key in data:
		if not expected.has(key):
			return "bilinmeyen anahtar: %s" % key
	return ""


func _reports(data: Dictionary, domains: Dictionary) -> String:
	var issue := _keys(data, ["phrases", "sign_texts", "echo", "unknown_phrase", "unknown_partner"])
	if issue != "": return issue
	for key in ["echo", "unknown_phrase", "unknown_partner"]:
		if not _text(data[key]): return "boş rapor metni: %s" % key
	if not data["phrases"] is Dictionary or not data["sign_texts"] is Dictionary:
		return "phrases/sign_texts sözlük olmalı"
	var phrases: Dictionary = data["phrases"]
	for domain in domains:
		if not phrases.has(domain): return "eksik rapor alanı: %s" % domain
	for domain in phrases:
		if not domains.has(domain): return "bilinmeyen rapor alanı: %s" % domain
		var bands: Variant = phrases[domain]
		if not bands is Array or bands.size() != 3: return "%s: üç rapor bandı gerekli" % domain
		for band in bands:
			if not _texts(band): return "%s: boş rapor metni" % domain
	var signs: Dictionary = data["sign_texts"]
	for stage in ["0", "1", "2", "3"]:
		if not signs.has(stage) or not signs[stage] is Dictionary or not _texts(signs[stage].get("_")):
			return "eksik/boş alamet aşaması: %s" % stage
	for stage in signs:
		if not ["0", "1", "2", "3"].has(stage): return "bilinmeyen alamet aşaması: %s" % stage
		for domain in signs[stage]:
			if domain != "_" and not domains.has(domain): return "bilinmeyen alamet alanı: %s" % domain
			if not _texts(signs[stage][domain]): return "boş alamet metni: %s/%s" % [stage, domain]
	return ""


func _history(data: Dictionary) -> String:
	var expected := ["pro_survived", "pro_lost", "pro_economy", "pro_reform", "pro_peace", "pro_kept",
		"pro_public", "pro_constitution", "pro_heir", "pro_default", "con_secrets", "con_bribes",
		"con_blackmail", "con_broken", "con_press", "con_opposition", "con_economy", "con_echo",
		"con_lock", "con_default"]
	var issue := _keys(data, expected)
	if issue != "": return issue
	for key in expected:
		if not _text(data[key]): return "boş tarihçi metni: %s" % key
	for key in ["pro_survived", "pro_lost", "pro_kept", "con_secrets", "con_bribes", "con_broken"]:
		var needed := 2 if key == "pro_lost" else 1
		if str(data[key]).count("%s") + str(data[key]).count("%d") != needed:
			return "tarihçi biçim alanı eksik: %s" % key
	return ""


func _council(data: Dictionary, ids: Dictionary) -> String:
	var issue := _keys(data, ["experts", "reasons", "cover", "evasive", "flat", "roman", "roman_acc",
		"actor_good", "actor_bad", "rec_forms", "cover_default"])
	if issue != "": return issue
	for key in ["experts", "reasons", "cover"]:
		if not data[key] is Dictionary: return "%s sözlük olmalı" % key
	for key in ["evasive", "flat", "roman", "roman_acc", "actor_good", "actor_bad", "rec_forms"]:
		if not _texts(data[key]): return "eksik/boş metin dizisi: %s" % key
	if data["rec_forms"].size() != 3: return "üç öneri kalıbı gerekli"
	if not _text(data["cover_default"]): return "cover_default boş"
	if data["roman"].size() != data["roman_acc"].size() or data["roman"].size() < 4:
		return "Roma seçim etiketleri eşleşmiyor"
	for form in data["rec_forms"]:
		if form.count("%s") != 1: return "öneri kalıbında bir %s gerekli"
	for side in ["actor_good", "actor_bad"]:
		for line in data[side]:
			if not (line.contains("{n_in}") or line.contains("{n_i}")):
				return "aktör gerekçesinde ad eki eksik: %s" % side
	for dim in data["experts"]:
		if not data["experts"][dim] is Array or data["experts"][dim].size() != 2:
			return "uzman çifti eksik: %s" % dim
		for id in data["experts"][dim]:
			if not ids.has(id): return "bilinmeyen uzman aktör: %s" % id
	for id in data["cover"]:
		if not ids.has(id): return "bilinmeyen kılıf aktörü: %s" % id
		if not _text(data["cover"][id]): return "boş kılıf: %s" % id
	for dim in data["reasons"]:
		var pair: Variant = data["reasons"][dim]
		if not pair is Array or pair.size() != 2 or not _texts(pair[0]) or not _texts(pair[1]):
			return "eksik/boş gerekçe: %s" % dim
	for dim in ["king", "unrest", "economy", "opp", "wealth", "treasury", "capacity", "holding", "fact", "promise"]:
		if not data["reasons"].has(dim): return "eksik gerekçe: %s" % dim
	return ""


func _achievements(data: Dictionary) -> String:
	if data.is_empty(): return "başarım listesi boş"
	for id in data:
		if not _text(id) or not _texts(data[id], 2) or data[id].size() != 2:
			return "eksik/boş başarım: %s" % id
	return ""


func _labels(data: Dictionary) -> String:
	var issue := _keys(data, ["prizes", "power_tiers", "report_tones", "suspicion_names",
		"regime_names", "regime_titles", "regime_threats", "regime_order", "budget"])
	if issue != "": return issue
	for key in ["prizes", "report_tones", "suspicion_names", "regime_order"]:
		if not _texts(data[key]): return "eksik/boş etiket: %s" % key
	if data["prizes"].size() != 3: return "üç söz ödülü gerekli"
	if not data["power_tiers"] is Array or data["power_tiers"].size() != 4:
		return "güç kademeleri eksik"
	for i in range(1, 4):
		if not _text(data["power_tiers"][i]): return "boş güç kademesi"
	if data["report_tones"].size() != 3 or data["suspicion_names"].size() != 4:
		return "rapor/tavır kademeleri eksik"
	if data["regime_order"] != REGIMES: return "rejim sırası/kimlikleri değişmiş"
	var budget: Variant = data["budget"]
	if not budget is Dictionary or _keys(budget, ["title", "text", "ignore", "choices"]) != "":
		return "bütçe kartı anahtarları eksik"
	for key in ["title", "text", "ignore"]:
		if not _text(budget[key]): return "boş bütçe metni: %s" % key
	if not budget["choices"] is Array or budget["choices"].size() != 4:
		return "bütçe kartında dört seçenek gerekli"
	for option in budget["choices"]:
		if not option is Dictionary or _keys(option, ["label", "text", "stance", "court_share"]) != "":
			return "bütçe seçeneği eksik"
		if not _text(option["label"]) or not _text(option["text"]) or not (option["stance"] is int or option["stance"] is float) or not float(option["stance"]) in [-1.0, 0.0, 1.0] or not option["court_share"] is bool:
			return "bütçe seçeneği hatalı"
	for key in ["regime_names", "regime_titles", "regime_threats"]:
		if not data[key] is Dictionary: return "%s sözlük olmalı" % key
		issue = _keys(data[key], REGIMES)
		if issue != "": return "%s: %s" % [key, issue]
		for id in REGIMES:
			if not _text(data[key][id]): return "%s: %s boş" % [key, id]
	return ""
