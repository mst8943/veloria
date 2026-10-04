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
##   advice_kessler   visible + Kessler konuşuyorsa ona, yoksa advice_weighted gibi (baskın strateji kontrolü)

var sim: Node
var rng := RandomNumberGenerator.new()
const BOTS := ["idle", "random", "visible", "advice_naive", "advice_weighted", "advice_kessler", "visible_wise", "omniscient"]


func _initialize() -> void:
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
	for s in range(1, n + 1):
		sim.new_game(s, diff)
		rng.seed = s * 131 + 7
		while not sim.ended:
			_play(bot)
			sim.end_week()
		var r: Dictionary = sim.record
		weeks += int(r["weeks"])
		if r["survived"]:
			wins += 1
			titles[r["title"]] = int(titles.get(r["title"], 0)) + 1
		else:
			var c := _cause_kind(str(r["cause"]))
			causes[c] = int(causes.get(c, 0)) + 1
	print("[%-12s] kazanma %2d/%d (%3d%%)  ort. hafta %5.1f  kayıplar %s  ünvanlar %s" % [
		bot, wins, n, int(100.0 * wins / n), float(weeks) / n, causes, titles])


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
			_act_visible()


# ---------------------------------------------------------------- Kararlar

func _decide(bot: String) -> void:
	var guard := 0
	while not sim.pending.is_empty() and sim.mesai > 0 and guard < 6:
		guard += 1
		var ev: Dictionary = sim.pending[0]["event"]
		var ci: int = rng.randi() % ev["choices"].size()
		if bot in ["visible_wise", "omniscient"]:
			ci = _wise_choice(ev)
		elif bot.begins_with("advice_"):
			ci = _advice_choice(bot, sim.advice_for(0), ci)
		sim.resolve_decision(0, ci)


## Ekranda görünen meclis görüşüyle seçim (yalnızca rec/warn/stake/kind görünür bilgidir).
func _advice_choice(bot: String, adv: Array, fallback: int) -> int:
	if adv.is_empty():
		return fallback
	if bot == "advice_naive":
		return int(adv[0]["rec"]) if int(adv[0]["rec"]) >= 0 else fallback
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
func _act_visible() -> void:
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
			if worst.is_empty() or int(r["band"]) > int(worst["band"]):
				worst = r
		var src: String = worst.get("source", "")
		if src != "" and sim.actors.has(src) and int(worst.get("band", 0)) >= 1:
			if src in ["press", "lena"] and sim.actors.has("arden"):
				sim.order("arden", "bastir", "sozlu")
			elif sim.private_wealth >= 5.0:
				sim.bribe(src)
			else:
				sim.cross_check(src)
			continue
		# 3) Aksi halde sırayla doğrula (bilgi topla).
		var ids: Array = sim.actors.keys()
		if ids.is_empty():
			return
		sim.cross_check(ids[(sim.week + guard) % ids.size()])


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
