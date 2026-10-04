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
const CHRONICLE_PATH := "user://veloria_chronicle.txt"
var save_path := "user://veloria_save.txt"   # testler kendi dosyasını kullanır, oyuncunun kaydına dokunmaz
var record_chronicle := true                 # testlerde ve otomatik oynatmada arşive yazılmaz
var autosave := true                         # her hafta sonunda otomatik kayıt
var timeline: Array = []                     # haftalık gerçek durum (oyun sonunda gösterilir)
const GOOD_DOMAINS_HIGH := ["economy"]  # bu alanlarda yüksek değer iyidir
## Zorluk: haftalık mesai, darbe koruma süresi, darbe için gereken güç payı, gelir, hazır olma eşiği.
const DIFFICULTY := [
	{"name": "Kolay", "mesai": 5, "grace": 26, "coup_share": 0.74, "income": 1.2, "ready_drive": 48.0, "advice_noise": 0.8},
	{"name": "Normal", "mesai": 4, "grace": 12, "coup_share": 0.68, "income": 1.0, "ready_drive": 43.0, "advice_noise": 1.0},
	{"name": "Zor", "mesai": 4, "grace": 10, "coup_share": 0.63, "income": 0.8, "ready_drive": 38.0, "advice_noise": 1.25},
]

## Vaat edilebilecek ödüller: her biri yalnızca bir kişiye gerçekten verilebilir.
const PRIZES := ["Başbakanlık", "Liman İhalesi", "Dokunulmazlık"]

var difficulty := 1
var mesai_max := MESAI_PER_WEEK
var promises: Array = []     # {id, actor, prize, made, due, delays, state, asked, exposed}
var _extra_msgs: Array[String] = []  # bir kararın yan etkileri (oyuncuya hemen gösterilir)

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
var advice_log: Array = []   # meclis görüşlerinin sicili (oyun sonunda açılır)
var stats: Dictionary = {}
var weekly_news: Array = []
var ended := false
var record: Dictionary = {}
var coup_leader := ""

var _events: Array = []


func new_game(seed_value: int = 0, diff: int = -1) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	if diff >= 0:
		difficulty = clampi(diff, 0, DIFFICULTY.size() - 1)
	mesai_max = int(_diff("mesai"))
	week = 1
	mesai = mesai_max
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
	advice_log.clear()
	weekly_news.clear()
	promises.clear()
	timeline.clear()
	stats = {"ops": 0, "bribes": 0, "promotes": 0, "leaks": 0, "dismissals": 0, "written": 0, "hints": 0, "checks": 0,
		"investigations": 0, "blackmails": 0, "promises": 0, "kept": 0, "broken": 0}
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
	_record_timeline()
	changed.emit()


## Türkçe ek uyumu: özel isme kesme işaretiyle doğru eki ekler.
## kind: "e" (yönelme: Voss'a, Arden'e), "in" (ilgi: Voss'un, Brandt'ın, Arden'in), "i" (belirtme: Voss'u, Arden'i)
static func ek(name: String, kind: String) -> String:
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
	if kind == "i":  # belirtme: Arden'i, Voss'u, Lena'yı
		return "%s'%s%s" % [name, "y" if ends_vowel else "", v]
	return "%s'%s%sn" % [name, "n" if ends_vowel else "", v]


func _diff(key: String) -> float:
	return float(DIFFICULTY[difficulty][key])


func _load_json(path: String) -> Array:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Veri dosyası açılamadı: " + path)
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Array else []


# ---------------------------------------------------------------- Kayıt

func has_save() -> bool:
	return FileAccess.file_exists(save_path)


## Menüde "Devam Et" yanında gösterilecek kısa özet: "Hafta 23 · Normal".
func save_summary() -> String:
	if not has_save():
		return ""
	var f := FileAccess.open(save_path, FileAccess.READ)
	var d: Variant = str_to_var(f.get_as_text())
	if not d is Dictionary:
		return ""
	var diff_i := clampi(int(d.get("diff", 1)), 0, DIFFICULTY.size() - 1)
	return "Hafta %d · %s" % [int(d.get("week", 1)), DIFFICULTY[diff_i]["name"]]


func save_game() -> bool:
	if ended:
		return false
	var a_data := {}
	for id in actors:
		a_data[id] = actors[id].to_save()
	var data := {"week": week, "mesai": mesai, "king": king_strength, "unrest": unrest, "economy": economy,
		"opp": opposition, "wealth": private_wealth, "actors": a_data, "facts": facts, "flags": flags,
		"fired": fired_events, "history": history, "pending": pending, "truth": truth_log, "karne": karne, "advice_log": advice_log,
		"stats": stats, "rng": rng.state, "seed": rng.seed, "diff": difficulty, "promises": promises,
		"timeline": timeline}
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(var_to_str(data))
	return true


func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(save_path, FileAccess.READ)
	var d: Variant = str_to_var(f.get_as_text())
	if not d is Dictionary:
		return false
	new_game(int(d.get("seed", 1)), int(d.get("diff", 1)))
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
	advice_log = d.get("advice_log", [])
	stats = d["stats"]
	promises = d.get("promises", [])
	timeline = d.get("timeline", [])
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
	_add_fact("transfer_%s_%d" % [id, week], "%s yapılan gizli ödeme" % ek(a.display_name, "e"), "king", 18, [id, "dorn"], 2)
	changed.emit()
	return "%s gizli ödeme yapıldı. Sadakati arttı; ama bir iz kaldı." % ek(a.display_name, "e")


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
			_add_fact("emir_%s_%d" % [id, week], "%s verilen yazılı emir" % ek(a.display_name, "e"), "king", 35, [id], 1)
		"sozlu":
			fidelity = 0.75
		"ima":
			stats["hints"] += 1
			# Hırslı biri imayı aşırı yorumlar, korkak biri hiç uygulamaz.
			fidelity = clampf(0.3 + a.ambition / 100.0 + rng.randf_range(-0.2, 0.4) - a.red_line_penalty(task), 0.0, 1.5)
	# Kırmızı çizgi: açık emirle çiğnenirse gönülsüz uygulanır ve küskünlük bırakır.
	var crossed := a.crosses_red_line(task) and channel != "ima"
	if crossed:
		fidelity *= 0.5
		a.ambition += 5.0
		a.loyalty["ideology"] = maxf(0.0, float(a.loyalty["ideology"]) - 6.0)
		a.known_red = true
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
	if crossed:
		text = "%s emri kırmızı çizgisini aştığı için gönülsüzce, yarım yamalak uyguladı. Bunu sana yazdı. (Kırmızı çizgisi: %s)" % [a.display_name, a.red_line]
	changed.emit()
	return text


## Araştır: seçilen kişinin önce zayıf noktasını, sonra kırmızı çizgisini öğrenmeye çalışır.
## İstihbarat (Voss) ne kadar güçlüyse şans o kadar yüksek; ama Voss da öğrendiğini saklar.
func investigate(id: String) -> String:
	var a: Actor = actors[id]
	if a.known_weak and a.known_red:
		return "%s hakkında öğrenilecek yeni bir şey kalmadı." % a.display_name
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
		return "%s hakkındaki araştırma sonuç vermedi. İzler soğuk." % a.display_name
	if not a.known_weak:
		a.known_weak = true
		changed.emit()
		return "%s zayıf noktası bulundu: %s. Artık şantaj mümkün." % [ek(a.display_name, "in"), a.weak_point]
	a.known_red = true
	changed.emit()
	return "%s asla geçmeyeceği çizgi: %s." % [ek(a.display_name, "in"), a.red_line]


## Şantaj: zayıf noktası bilinen birini korkuyla bağlar. Borcunu siler ama hırsını büyütür ve iz bırakır.
## Dürüst ve korkusuz biri ise şantajı ifşa edebilir.
func blackmail(id: String) -> String:
	var a: Actor = actors[id]
	if not a.known_weak:
		return "Önce %s zayıf noktasını bulmalısın (Araştır)." % ek(a.display_name, "in")
	if not spend_mesai():
		return _no_mesai()
	stats["blackmails"] = int(stats.get("blackmails", 0)) + 1
	a.blackmailed += 1
	var fid := "santaj_%s_%d" % [id, week]
	_add_fact(fid, "%s yapılan şantaj" % ek(a.display_name, "e"), "king", 30, [id], 1)
	var backfire := a.honesty * 0.35 + (0.25 if a.fear < 20.0 else 0.0) + 0.1 * (a.blackmailed - 1)
	if rng.randf() < backfire:
		facts[fid]["common"] = 0.45
		a.ambition += 10.0
		a.fear = maxf(0.0, a.fear - 5.0)
		changed.emit()
		return "%s boyun eğmedi; şantajı ifşa etmekle tehdit ediyor. Konuşulmaya başlandı bile." % a.display_name
	a.fear += 25.0
	a.loyalty["fear"] = float(a.loyalty["fear"]) + 15.0
	a.obligation = maxf(0.0, a.obligation - 10.0)
	a.ambition += 6.0
	changed.emit()
	return "%s ne demek istediğini anladı. Artık senden korkuyor; korku ise sadakatin en kırılgan biçimi." % a.display_name


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
		return "%s raporu diğer kaynaklarla büyük ölçüde örtüşüyor." % ek(a.display_name, "in")
	if worse:
		karne[id]["bad"] += 1
		return "Başka kaynaklar durumun %s anlattığından DAHA KÖTÜ olduğunu söylüyor." % ek(a.display_name, "in")
	karne[id]["ok"] += 1
	return "Başka kaynaklar durumu %s anlattığından biraz daha iyi görüyor." % ek(a.display_name, "in")


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
				text = "%s itibarı sarsıldı. Kim yaptığını tahmin etmesi zor değil." % ek(target.display_name, "in")
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
		return "%s artık verilemez; zaten birine verildi." % prize
	for p in active_promises_of(id):
		if p["prize"] == prize:
			return "%s bunu zaten vaat ettin." % ek(a.display_name, "e")
	if not spend_mesai():
		return _no_mesai()
	stats["promises"] = int(stats.get("promises", 0)) + 1
	promises.append({"id": "%s_%d_%d" % [id, PRIZES.find(prize), week], "actor": id, "prize": prize,
		"made": week, "due": week + 6 + rng.randi_range(0, 4), "delays": 0, "state": "active",
		"asked": false, "exposed": false})
	a.loyalty["career"] = float(a.loyalty["career"]) + 12.0
	a.ambition += 2.0
	changed.emit()
	return "%s %s sözü verdin. Gözleri parladı; vadesi geldiğinde hatırlatacak." % [ek(a.display_name, "e"), prize]


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
			"king", 20, group.map(func(p: Dictionary) -> String: return p["actor"]), 1)
		weekly_news.append("KULİS: %s aynı sözü aldıklarını öğrendi: %s." % [" ve ".join(names), prize])
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
		var text := "%s, %d. haftada verdiğin '%s' sözünü hatırlatıyor. Bekleyişi sabırlı, ama sonsuz değil." % [a.display_name, p["made"], p["prize"]]
		if rival != "":
			text += " Aynı sözü %s de vermiştin." % ek(rival, "e")
		pending.append({"age": 0, "event": {"id": "soz_" + str(p["id"]), "title": "%s sözünü hatırlatıyor" % a.display_name, "text": text,
			"choices": [
				{"label": "Sözü tut: %s" % p["prize"], "text": "%s sözünü aldı. Bunu unutmayacak." % a.display_name, "fx": {"promise_keep": p["id"]}},
				{"label": "Biraz daha zaman iste", "text": "%s bekleyecek. Ama hevesi azaldı." % a.display_name, "fx": {"promise_delay": p["id"]}},
				{"label": "Sözden dön", "text": "%s yüzüne bakmadan çıktı. Saray bunu konuşacak." % a.display_name, "fx": {"promise_break": p["id"]}}],
			"ignore": {"text": "Söz cevapsız kaldı; bozulmuş sayıldı.", "fx": {"promise_break": p["id"]}}}})
		weekly_news.append("SÖZ: %s karşılığını istiyor." % a.display_name)


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
			"Başbakanlık":
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
		_add_fact("bozulan_soz_%s" % p["id"], "%s verilip tutulmayan söz (%s)" % [ek(a.display_name, "e"), p["prize"]], "king", 15, [a.id], 1)
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
	_log_advice(e, advice_for(pending_index), choice_index)
	pending.remove_at(pending_index)
	flags["%s_%d" % [e["id"], choice_index]] = week
	_extra_msgs.clear()
	_apply_effects(fx)
	history.append("Hafta %d — %s » %s" % [week, e["title"], ch["label"]])
	changed.emit()
	var out := str(ch.get("text", ""))
	if not _extra_msgs.is_empty():
		out += " " + " ".join(_extra_msgs)
	return out


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
const ROMAN := ["I", "II", "III", "IV"]
const ROMAN_ACC := ["I'i", "II'yi", "III'ü", "IV'ü"]
## Olayın baskın boyutu -> [birincil uzman, ikincil uzman]
const ADVICE_EXPERTS := {
	"economy": ["kessler", "halden"], "wealth": ["kessler", "halden"], "unrest": ["arden", "halden"],
	"opp": ["voss", "halden"], "fact": ["falk", "voss"], "king": ["dorn", "prens"], "actors": ["voss", "dorn"],
}
## Gerekçe parçaları: boyut -> [kral için olumlu söyleyişler, olumsuz söyleyişler]. "%s" = kişi adı (eki eklenmiş).
const ADVICE_REASONS := {
	"king": [["tahtınızı güçlendirir", "otoritenizi pekiştirir"], ["otoritenizi zedeler", "sizi zayıf gösterir"]],
	"unrest": [["sokağı yatıştırır", "meydanları sakinleştirir"], ["sokağı kızdırır", "halkı öfkelendirir"]],
	"economy": [["hazineyi rahatlatır", "piyasaya nefes aldırır"], ["hazineyi zorlar", "bütçeyi deler"]],
	"opp": [["muhalefeti susturur", "Brandt'ın elini zayıflatır"], ["muhalefete koz verir", "Brandt'a malzeme olur"]],
	"wealth": [["kişisel kasanızı doldurur", "kasanıza para koyar"], ["kasanızı boşaltır", "cebinizden çıkar"]],
	"fact": [["iz bırakmaz"], ["iz bırakır", "bir gün önünüze dosya olarak gelir"]],
	"promise": [["sözünüzü korur"], ["verdiğiniz sözü bozar", "sözünüzü çiğner"]],
}
## Önerdiği seçeneğin kral için hiçbir iyi yanı yoksa danışman kendi kılıfını kurar (dikkatli oyuncu için ele veriş).
const ADVICE_COVER := {
	"arden": "Ordu güçlüyse taht da güçlüdür.", "voss": "Bazı şeyleri size anlatamam; bana güvenin.",
	"kessler": "Hesabı ben tutarım; en az zararlısı bu.", "halden": "Kamuoyunu ben hallederim.",
	"dorn": "Sarayın huzuru için en iyisi bu.", "prens": "Hanedanın onuru bunu gerektirir.",
	"falk": "Hukuka en uygun yol bu.",
}
const ADVICE_EVASIVE := ["Takdir sizindir, Majesteleri.", "Hangisini seçerseniz doğru olan odur, Majesteleri.",
	"Sizin bileceğiniz iş, Majesteleri."]
const ADVICE_FLAT := ["Bence hepsi aynı kapıya çıkar.", "Aralarında büyük bir fark görmüyorum, Majesteleri."]


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
			var dim := "actors" if k.begins_with("actor:") else k
			w[dim] = float(w.get(dim, 0.0)) + absf(float(t[k]))
	var dims: Array = w.keys().filter(func(k: String) -> bool: return ADVICE_EXPERTS.has(k))
	dims.sort_custom(func(x: String, y: String) -> bool: return w[x] > w[y])
	return dims


func _can_advise(aid: String) -> bool:
	return actors.has(aid) and actors[aid].insider and not actors[aid].moved


## İki danışman: biri kararda taraf olan, diğeri olayın baskın alanının uzmanı.
func _pick_advisors(e: Dictionary) -> Array:
	var out: Array = []
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
		for aid in ADVICE_EXPERTS[dim]:
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
	var ex: Array = ADVICE_EXPERTS[dims[0]]
	if aid == ex[0]:
		return ADVICE_SKILL_EXPERT
	if aid == ex[1]:
		return ADVICE_SKILL_SECOND
	return ADVICE_SKILL_GENERAL


## Kısa hitap adı: "General Arden" -> "Arden", "Prens Cassian" -> "Prens".
func short_name(a: Actor) -> String:
	return "Prens" if a.royal else a.display_name.split(" ")[-1]


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
		item["text"] = ADVICE_EVASIVE[r.randi() % ADVICE_EVASIVE.size()]
		return item
	var sigma := ADVICE_SIGMA * (1.0 - _advisor_skill(a.id, e)) * _diff("advice_noise")
	var w := clampf(ADVICE_W0 + a.ambition / 100.0 * (1.0 - a.honesty) * ADVICE_W1, 0.0, ADVICE_W_MAX)
	var k := ADVICE_K_READY if a.ready else 1.0
	var scores: Array[float] = []
	for ch: Dictionary in choices:
		var fx: Dictionary = ch.get("fx", {})
		scores.append(k * (choice_value(fx) + r.randfn(0.0, sigma)) + w * _self_interest(a, fx))
	var best := 0
	var worst := 0
	for i in scores.size():
		if scores[i] > scores[best]:
			best = i
		if scores[i] < scores[worst]:
			worst = i
	if scores[best] - scores[worst] < ADVICE_FLAT_GAP:
		item["kind"] = "flat"
		item["text"] = ADVICE_FLAT[r.randi() % ADVICE_FLAT.size()]
		return item
	item["rec"] = best
	var reason := _advice_reason(choices[best].get("fx", {}), true, r, a.id)
	var text := ""
	match r.randi() % 3:
		0:
			text = "%s öneririm" % ROMAN_ACC[mini(best, 3)]
		1:
			text = "Bence %s, Majesteleri" % ROMAN[mini(best, 3)]
		_:
			text = "%s seçin" % ROMAN_ACC[mini(best, 3)]
	text = "%s: %s." % [text, reason] if reason != "" else "%s. %s" % [text, ADVICE_COVER.get(a.id, "Bana güvenin.")]
	if scores[best] - scores[worst] >= ADVICE_WARN_GAP:
		var bad := _advice_reason(choices[worst].get("fx", {}), false, r, a.id)
		if bad != "":
			item["warn"] = worst
			text += " %s ise %s." % [ROMAN[mini(worst, 3)], bad]
	item["text"] = text
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
		var nm: String = short_name(actors[aid]) if actors.has(aid) else aid.capitalize()
		if good:
			return [ek(nm, "in") + " gücünü kırpar", ek(nm, "i") + " dizginler"][r.randi() % 2]
		return [ek(nm, "i") + " fazla güçlendirir", ek(nm, "in") + " elini güçlendirir"][r.randi() % 2]
	var opts: Array = ADVICE_REASONS[key][0 if good else 1]
	return opts[r.randi() % opts.size()]


func _log_advice(e: Dictionary, advice: Array, chosen: int) -> void:
	var choices: Array = e["choices"]
	var best := 0
	for i in choices.size():
		if choice_value(choices[i].get("fx", {})) > choice_value(choices[best].get("fx", {})):
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
			history.append("Hafta %d — %s » (ertelendi)" % [week, e["title"]])
			weekly_news.append(line)
		else:
			keep.append(p)
	pending = keep
	week += 1
	mesai = mesai_max
	weekly_news.clear()
	_world_tick()
	_decay_facts()
	_fire_events()
	_tick_promises()
	_run_cascade()
	_generate_reports()
	_record_timeline()
	_check_end()
	if autosave and not ended:
		save_game()
	for n in weekly_news:
		news.emit(n)
	week_advanced.emit(week)
	changed.emit()


## Hakikat Dosyası grafiği için gerçek (gizli) durumun haftalık kaydı.
func _record_timeline() -> void:
	timeline.append({"w": week, "king": snappedf(king_strength, 0.1), "unrest": snappedf(unrest, 0.1),
		"economy": snappedf(economy, 0.1), "opp": snappedf(opposition, 0.1), "plot": snappedf(_ready_power_share() * 100.0, 0.1)})


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
	private_wealth += _diff("income")  # sivil liste ödeneği


func _decay_facts() -> void:
	for f: Dictionary in facts.values():
		# Dosyalar sızar: bilen sayısı arttıkça ortak bilgi yavaş yavaş yükselir.
		f["common"] = minf(1.0, f["common"] + 0.0065 * f["knowers"].size() * f.get("leakiness", 0.5))
		if f["common"] >= 0.25 and f["common"] < 0.5 and not f.get("rumor", false):
			f["rumor"] = true
			weekly_news.append("KULİS: '%s' konuşulmaya başladı." % f["text"])
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
		if a.insider and not a.ready and a.rebellion_drive() > _diff("ready_drive"):
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
	if week >= int(_diff("grace")) and _ready_power_share() >= _diff("coup_share") and striker:
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


## Yargının saraya yaklaşması. Kamuya açılan skandal en çok o hafta acıtır; halk zamanla unutur
## (30 haftada ağırlığın %40'ına iner). Gizli kanıtlar az da olsa baskı yaratır.
func legal_pressure() -> float:
	var s := 0.0
	for f: Dictionary in facts.values():
		if f["subject"] != "king":
			continue
		var w := 0.15
		if f.get("public", false):
			w = maxf(0.4, 1.0 - float(week - int(f.get("public_week", week))) / 50.0)
		s += float(f["severity"]) * w
	return clampf(s / 2.4, 0.0, 100.0)


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
		"lies": _top_lies(), "king": KING_NAME,
		"promises": "%d söz verdin: %d tutuldu, %d bozuldu." % [int(stats.get("promises", 0)), int(stats.get("kept", 0)), int(stats.get("broken", 0))],
		"historians": historians(survived), "timeline": timeline.duplicate(), "council": council_record()}
	record["new_achievements"] = _award_achievements(survived, title, cause) if record_chronicle else []
	if record_chronicle:
		_append_chronicle(record)
	# Biten saltanata kayıttan geri dönülmez: tarih tek yönlüdür.
	if autosave and FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	game_ended.emit(record)


## İki taraflı tarih: aynı saltanatı saray tarihçisi ve sürgündeki tarihçi farklı yazar.
func historians(survived: bool) -> Array:
	var weeks := week - 1
	var pro: Array[String] = []
	var con: Array[String] = []
	if survived:
		pro.append("Kral %s, iki yıl boyunca sayısız fırtınaya rağmen tahtını korudu." % KING_NAME)
	else:
		pro.append("Kral %s, %d hafta boyunca imkânsız bir krallığı ayakta tutmaya çalıştı; düşüşü, ihanetin eseriydi." % [KING_NAME, weeks])
	if economy >= 55.0:
		pro.append("Saltanatında hazine doldu, pazarlar canlandı.")
	if flags.has("kessler_reform_0"):
		pro.append("Vergi reformu, ondan sonra gelenlerin de övündüğü bir miras oldu.")
	if unrest < 35.0:
		pro.append("Sokaklarda huzur vardı.")
	if int(stats.get("kept", 0)) > 0:
		pro.append("Verdiği sözlerin %d tanesini tuttu." % int(stats.get("kept", 0)))
	if flags.has("tac_giyme_2") or flags.has("yildonumu_0"):
		pro.append("Halkın karşısına çıkmaktan çekinmeyen bir hükümdardı.")
	if flags.has("halef_karari_0"):
		pro.append("Saltanatının sonunda Meclise gerçek yetki vererek anayasal monarşinin kurucusu oldu.")
	elif flags.has("halef_karari_1"):
		pro.append("Hanedanın devamını güvence altına aldı.")
	if pro.size() == 1:
		pro.append("Zor zamanlarda, zor kararlar vermek zorunda kaldı.")
	var public_secrets := 0
	for f: Dictionary in facts.values():
		if f["subject"] == "king" and f.get("public", false):
			public_secrets += 1
	if public_secrets > 0:
		con.append("Saltanatı, ortaya saçılan %d sırla hatırlanır." % public_secrets)
	if int(stats.get("bribes", 0)) >= 2:
		con.append("Sadakati parayla satın aldı; %d gizli ödeme kayıtlara geçti." % int(stats.get("bribes", 0)))
	if int(stats.get("blackmails", 0)) > 0:
		con.append("Yakın çevresini şantajla yönetti.")
	if int(stats.get("broken", 0)) > 0:
		con.append("%d sözünü tutmadı." % int(stats.get("broken", 0)))
	if flags.has("GAZETECI_SUSTURULDU") or flags.has("gazeteci_ihale_1"):
		con.append("Basını susturdu.")
	if flags.has("muhalefet_birlesme_2"):
		con.append("Muhalefet liderini hapse attı.")
	if economy < 35.0:
		con.append("Ekonomiyi harabeye çevirdi.")
	if echo_level() > 0.7:
		con.append("Son aylarında artık kimse ona gerçeği söylemiyordu.")
	if flags.has("halef_karari_2"):
		con.append("Ve gitmeden önce yetkiyi kimseyle paylaşmayacak biçimde kilitledi.")
	if con.is_empty():
		con.append("Sürgündeki tarihçiler bile bu saltanata ağır bir suçlama bulmakta zorlandı.")
	return [" ".join(pro), " ".join(con)]


## Başarımlar: id -> [ad, açıklama]. Kalıcıdır, saltanatlar arası birikir.
const ACHIEVEMENTS_PATH := "user://veloria_achievements.txt"
const ACHIEVEMENTS := {
	"ilk_saltanat": ["İlk Saltanat", "Bir saltanatı sonuna kadar götür (ya da düş)."],
	"tahtta_kal": ["İki Yıl", "104 haftayı tahtta tamamla."],
	"zor_zafer": ["Demir İrade", "Zor seviyede tahtta kal."],
	"temiz_eller": ["Temiz Eller", "Hiç gizli ödeme, şantaj ya da yazılı emir kullanmadan tahtta kal."],
	"sozunun_eri": ["Sözünün Eri", "En az 2 söz tut, hiçbirini bozma ve tahtta kal."],
	"sirlar": ["Sırların Efendisi", "Bir saltanatta 3 kez şantaj yap."],
	"operator": ["Gölgelerin Kralı", "Bir saltanatta 5 gizli operasyon yürüt."],
	"gercegi_goren": ["Gerçeği Gören", "Bir saltanatta 10 raporu doğrula."],
	"reformcu": ["Reformcu", "Kessler'in reformunun meyvelerini gör."],
	"anayasal": ["Anayasal Kral", "Anayasal monarşiye geçişi ilan et ve tahtta kal."],
	"hanedan": ["Hanedanın Bekçisi", "Prensi halef ilan et ve tahtta kal."],
	"kukla": ["İpler Başkasında", "Tahtta kal, ama birinin kuklası olarak."],
	"darbe": ["Tanklar Kapıda", "Bir darbeyle devril."],
	"ayaklanma": ["Meydanların Öfkesi", "Halk ayaklanmasıyla devril."],
	"yetkisiz": ["Skandal", "Biriken skandallar yüzünden yetkisiz bırakıl."],
}


func load_achievements() -> Dictionary:
	if not FileAccess.file_exists(ACHIEVEMENTS_PATH):
		return {}
	var d: Variant = str_to_var(FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.READ).get_as_text())
	return d if d is Dictionary else {}


## Saltanat sonunda kazanılan yeni başarımları kaydeder ve döndürür.
func _award_achievements(survived: bool, title: String, cause: String) -> Array:
	var earned: Array = ["ilk_saltanat"]
	if survived:
		earned.append("tahtta_kal")
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
		if cause.contains("darbe"):
			earned.append("darbe")
		elif cause.contains("ayaklanma"):
			earned.append("ayaklanma")
		elif cause.contains("yetkisiz"):
			earned.append("yetkisiz")
	if int(stats.get("blackmails", 0)) >= 3:
		earned.append("sirlar")
	if int(stats.get("ops", 0)) >= 5:
		earned.append("operator")
	if int(stats.get("checks", 0)) >= 10:
		earned.append("gercegi_goren")
	if fired_events.has("reform_meyve"):
		earned.append("reformcu")
	var have := load_achievements()
	var fresh: Array = []
	for id in earned:
		if not have.has(id):
			have[id] = Time.get_date_string_from_system()
			fresh.append(id)
	if record_chronicle and not fresh.is_empty():
		var f := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.WRITE)
		if f:
			f.store_string(var_to_str(have))
	return fresh


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
		"survived": r["survived"], "cause": r["cause"], "difficulty": DIFFICULTY[difficulty]["name"]})
	var f := FileAccess.open(CHRONICLE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(var_to_str(list.slice(maxi(0, list.size() - 50))))


func _survivor_title(top: Actor) -> String:
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


## Alan -> [iyi, orta, kötü] durum -> aynı anlamın farklı söylenişleri.
## Her kişinin kendi sesi var; hangi söylenişin çıkacağı haftaya ve kişiye göre seçilir.
const PHRASES := {
	"army": [
		["Birlikler emirlere hazır, moral yüksek.", "Kışlalarda düzen tam; subaylar size bağlılıklarını iletiyor.", "Ordu sağlam. Endişe edecek bir şey görmüyorum."],
		["Subaylar arasında huzursuz mırıltılar var, ama disiplin sürüyor.", "Bazı alaylarda maaş ve terfi şikâyetleri duyuluyor.", "Ordu emir bekliyor; ama neden beklediğini soranlar çoğalıyor."],
		["Bazı birlikler emirleri geciktiriyor. Gençler konuşuyor.", "Bazı komutanlar telefonlarıma artık geç dönüyor.", "Kışlalarda siyaset konuşuluyor. Bu iyiye işaret değil."]],
	"intel": [
		["Dosyalarda olağanüstü bir şey yok.", "Takip ettiğimiz isimler sessiz. Sessizlik de bilgidir, ama şimdilik iyi.", "Rutin hafta. Raporlarım masanızda."],
		["Sokakta ve muhalefette hareketlenme izliyoruz.", "Birkaç ismin telefon trafiği arttı. İzliyoruz.", "Muhalefetin toplantıları sıklaştı; içlerinde kulağımız var."],
		["Gizli görüşmeler artıyor. Tehdit gerçek olabilir.", "Sarayın çevresinde, sizi değil birbirlerini arayan insanlar var.", "Bazı dosyalar artık bana bile kapalı. Bu beni endişelendiriyor."]],
	"economy": [
		["Büyüme sağlıklı, enflasyon kontrolde.", "Hazine dengede; piyasalar sakin.", "Vergi gelirleri beklentinin üstünde, Majesteleri."],
		["Fiyatlar yükseliyor; bazı sektörler zorlanıyor.", "Kasadaki rakamlar tutuyor, ama pazardaki fiyatlar tutmuyor.", "Bazı fabrikalar vardiya azaltıyor. Henüz alarm değil."],
		["Bütçe açığı büyüyor. Müdahale gerekebilir.", "Maaşları gelecek ay nasıl ödeyeceğimizi hesaplıyorum.", "Rakamları güzelleştirebilirim. Ama gerçeği bilmeniz gerekiyor."]],
	"media": [
		["Halk sizden memnun, manşetler olumlu.", "Kanallarım sizi seviyor; halk da kanallarımı.", "Bu hafta manşetler sizin. Rica ederim."],
		["Kamuoyu kararsız; doğru haber akışı gerekir.", "Halk kimin hikâyesine inanacağına henüz karar vermedi.", "Biraz yardımla bu haftayı kurtarabiliriz."],
		["Anlatıyı kaybediyoruz. Bana güvenmeniz gerek.", "Kanallarım bile artık haberleri tutamıyor.", "Sokağın sesi ekranlarımızdan daha yüksek çıkıyor."]],
	"press": [
		["Sokakta sakin bir hava var.", "Kahvehanelerde siyaset değil, futbol konuşuluyor.", "İnsanlar günlerine bakıyor; öfke görmüyorum."],
		["İnsanlar daha çok soru soruyor.", "Okurlarımın mektupları sertleşiyor.", "Fırın kuyruklarında sesler yükseliyor."],
		["Halk öfkeli ve artık korkmuyor.", "Duvarlara yazılanları okumalısınız, Majesteleri.", "İnsanlar artık isimlerini saklamadan konuşuyor."]],
	"gate": [
		["Saray sakin; kimse sizi rahatsız etmek istemiyor.", "Randevu defteriniz düzenli; her şey yolunda.", "Koridorlarda huzur var, Majesteleri."],
		["Bazı heyetler randevu istiyor, ben ertelemeyi tercih ettim.", "Birkaç ziyaretçiyi sizi yormasın diye bekleme odasında tuttum.", "Sarayda fısıltılar var; önemsiz şeyler, eminim."],
		["Bazı haberleri size ulaştırmamayı doğru buldum.", "Ziyaretçi defterini ben düzenliyorum; endişelenmeyin.", "Sarayda kimin kimle görüştüğünü artık ben de tam bilmiyorum."]],
	"royal": [
		["Prens törenlerde sessiz ve uyumlu.", "Kardeşiniz bu hafta av ve resimle meşguldü.", "Prens size selamlarını gönderiyor."],
		["Prens soylularla sık yemek yiyor; sebebini bilmiyoruz.", "Prens son günlerde yabancı elçilerle fotoğraf veriyor.", "Kardeşiniz eski hanedan mektuplarını okuyormuş."],
		["Prensin çevresinde hazırlık var. Taht konuşuluyor.", "Soylu aileler prense 'Majesteleri' diye hitap etmeye başladı.", "Prensin muhafızları çoğaldı. Kimden korunduğunu sormak lazım."]],
	"opposition": [
		["Muhalefet dağınık, sesi cılız.", "Muhalefet kendi içinde kavgalı; size vakit ayıramıyorlar.", "Brandt'ın mitingleri yarı boş."],
		["Muhalefet kanatları arasında gizli görüşmeler sürüyor.", "Brandt'ın konuşmaları sertleşiyor ve dinleyeni artıyor.", "Muhalefet üniversitelerde örgütleniyor."],
		["Muhalefet birleşiyor; sokakla koordinasyon başladı.", "Muhalefetin çağrısıyla meydanlar dolabilir.", "Brandt artık 'geçiş hükümeti'nden söz ediyor."]],
	"court": [
		["Mahkemeler olağan işleyişinde.", "Yargının gündeminde saraya dair bir şey yok.", "Davalar takvimine uygun ilerliyor."],
		["Bazı dosyalar yargıda beklenenden hızlı ilerliyor.", "Savcılar bazı eski dosyaları yeniden açıyor.", "Mahkemede adınız henüz geçmiyor. Henüz."],
		["Yargı saraya yaklaşıyor; savcılar sabırsız.", "Bazı hâkimler anayasanın kraldan üstün olduğunu yazmaya başladı.", "Bir soruşturma dosyasının kapağında sarayın adresi var."]],
}


func _phrase(a: Actor, value: float, echo: float) -> String:
	if echo > 0.75:
		# Yankı odası: korku herkesin aynı cümleyi kurmasına yol açar. Bu tekdüzelik bir ipucudur.
		return "Majesteleri, her şey kontrol altında ve sizin liderliğinizde yolunda gidiyor."
	var band := _band(a, value)
	if not PHRASES.has(a.domain):
		return "…"
	var variants: Array = PHRASES[a.domain][band]
	return variants[absi(("%s%d" % [a.id, week]).hash()) % variants.size()]


func _add_fact(id: String, text: String, subject: String, severity: float, knowers: Array, copies: int, leakiness: float = 0.5) -> void:
	facts[id] = {"id": id, "text": text, "subject": subject, "severity": severity,
		"knowers": knowers.duplicate(), "common": 0.0, "copies": copies, "leakiness": leakiness}
