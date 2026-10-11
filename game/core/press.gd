extends RefCounted
## Basın: gazeteler ve televizyon, simülasyonun gizli durumundan her hafta üretilir.
## Her yayın sahibinin gözüyle yazar: Sarne süsler ve sansürler, Leyla gerçeğe yakın yazar.
## Böylece iki gazeteyi karşılaştırmak oyuncu için bir bilgi kaynağıdır.

const OUTLETS := {
	"state": {"name": "VELORİA HABER", "motto": "Krallığın sesi · 1892'den beri", "owner": "halden"},
	"free": {"name": "SERBEST KALEM", "motto": "Bağımsız · Korkusuz · Haftalık", "owner": "lena"},
}

const ECON := {
	"state": [["Ekonomide altın dönem", "Hazine güçlü, pazarlar canlı. Uzmanlar krallığın istikrarını övüyor."],
		["Ekonomi sağlam zeminde", "Bazı fiyat dalgalanmalarına rağmen hükümet kontrolü elinde tutuyor."],
		["Geçici zorluklar aşılacak", "Bakanlık, dış etkenlerden kaynaklanan sıkıntının kısa sürede biteceğini açıkladı."]],
	"free": [["Pazarda nefes alınıyor", "Fiyatlar bu hafta durdu. Esnaf temkinli ama umutlu."],
		["Fiyatlar cebi yakıyor", "Ekmek ve yakıt fiyatları yine arttı. Maaşlar aynı yerde duruyor."],
		["Hazine alarm veriyor", "Kulislere göre maaşlar için borç aranıyor. Resmî rakamlar ise başka bir şey söylüyor."]],
}
const STREET := {
	"state": [["Başkentte huzur", "Vatandaşlar günlük hayatına devam ediyor; meydanlarda bayram havası."],
		["Bazı gruplar tahrik peşinde", "Polis, az sayıdaki provokatörün kamu düzenini bozmasına izin vermeyeceğini açıkladı."],
		["Yabancı parmağı", "Uzmanlara göre son olayların arkasında dış güçler var."]],
	"free": [["Sokaklar sakin", "Bu hafta meydanlarda kimse yoktu. Sessizlik mi, yorgunluk mu?"],
		["Öfke büyüyor", "Fırın kuyruklarında konuşulanlar artık fiyatlar değil, saray."],
		["Meydanlar doldu", "Binlerce kişi sokakta. Polisin bazı birimlerinin müdahaleden kaçındığı görüldü."]],
}
const OPP := {
	"state": [["Muhalefet dağınık", "Voss'un partisi iç kavgalarla uğraşıyor."],
		["Muhalefet sorumsuz", "Meclisteki bazı vekillerin söylemleri istikrarı tehdit ediyor."],
		["Muhalefete sert uyarı", "Hükümet, sokağı kışkırtanların hesap vereceğini açıkladı."]],
	"free": [["Muhalefet sessiz", "Voss bu hafta kürsüye çıkmadı."],
		["Muhalefet örgütleniyor", "Kapalı kapılar ardında iki kanadın birleşme görüşmesi sürüyor."],
		["Muhalefet sokağa çağırıyor", "Voss: 'Bu saray halkın sesini artık duymak zorunda.'"]],
}
const ROYAL_FLUFF := ["Kral, saray bahçelerini halka açtı.", "Kraliyet orkestrası hafta sonu konser verecek.",
	"Kral, yetimhaneye bağışta bulundu.", "Saray protokolü yeni törenler hazırlıyor.", "Kral'ın sabah yürüyüşü halkı mutlu etti."]
const WEATHER := ["Başkentte yağmur, gece sis.", "Açık ve soğuk; sabah kırağı.", "Bulutlu, akşama doğru fırtına.",
	"Güneşli ama rüzgârlı.", "Kar bekleniyor; yollar kayganlaşabilir.", "Ilık bir hafta, gece serin."]
const ADS := ["KRALİYET PİYANGOSU · Büyük ikramiye bu cumartesi!", "SARNE ENERJİ · Kışa hazır mısınız?",
	"Saat tamiri ve altın alım satımı · Eski Çarşı No: 12", "Grand Otel Veloria · Balo salonu kiralanır.",
	"Kayıp: Gri kedi, adı Baron. Bulana ödül.", "Tercüme bürosu · Gizlilik garantili."]


static func _pick(arr: Array, salt: String, week: int) -> Variant:
	return arr[absi(("%s%d" % [salt, week]).hash()) % arr.size()]


static func _localized(value: Variant) -> Variant:
	if value is String:
		return TranslationServer.translate(value)
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(_localized(item))
		return result
	if value is Dictionary:
		var result: Dictionary = {}
		for key in value:
			result[key] = _localized(value[key])
		return result
	return value


static func _band(value: float, high_is_good: bool) -> int:
	if high_is_good:
		return 0 if value > 62.0 else (1 if value > 40.0 else 2)
	return 0 if value < 30.0 else (1 if value < 55.0 else 2)


## Yayının "gördüğü" değer: gerçeğin, yazarın süsleme oranıyla iyiye çekilmiş hâli.
static func _seen(truth: float, high_is_good: bool, flattery: float) -> float:
	return lerpf(truth, 100.0 if high_is_good else 0.0, flattery)


static func is_closed(sim: Node, outlet: String) -> bool:
	if outlet != "free":
		return false
	return not sim.actors.has("lena") or sim.flags.has("gazeteci_ihale_1") or sim.flags.has("GAZETECI_SUSTURULDU")


static func _flattery(sim: Node, outlet: String) -> float:
	var owner: String = OUTLETS[outlet]["owner"]
	if not sim.actors.has(owner):
		return 0.5
	var a = sim.actors[owner]
	if outlet == "state":
		return clampf(0.35 + a.flattery() * 0.5 + a.power / 400.0, 0.0, 0.85)
	return clampf(a.flattery() * 0.6, 0.0, 0.7)


## Haftanın gazetesi.
static func edition(sim: Node, outlet: String) -> Dictionary:
	var o: Dictionary = OUTLETS[outlet]
	var out := {"outlet": outlet, "name": o["name"], "motto": o["motto"], "week": sim.week, "closed": false}
	if is_closed(sim, outlet):
		out["closed"] = true
		out["headline"] = "YAYIN DURDURULDU"
		out["lead"] = "Serbest Kalem bu hafta da basılamadı. Matbaanın kapısında mühür var. Muhabirlerin bir kısmı yurtdışında."
		return _localized(out)
	var f := _flattery(sim, outlet)
	var w: int = sim.week
	# Manşet: bu hafta kamuya açılan skandal > bu haftanın olayı > genel durum
	var head := ""
	var sub := ""
	var art := ""
	for fact: Dictionary in sim.facts.values():
		if int(fact.get("public_week", -1)) == w:
			if fact["subject"] == "king":
				if outlet == "state":
					head = "Saraydan sert yalanlama"
					sub = "Saray, son günlerde yayılan iddiaların 'krallığı yıpratmaya yönelik bir karalama' olduğunu açıkladı."
				else:
					head = TranslationServer.translate("SKANDAL: %s") % str(fact["text"])
					sub = "Belgeler artık herkesin elinde. Saray sessiz."
			else:
				head = TranslationServer.translate("%s gündemde") % str(fact["text"])
				sub = "Kulislerde konuşulan iddia bu hafta kamuoyuna yansıdı."
				if outlet == "state" and fact["subject"] == "halden":
					head = ""
			if head != "":
				break
	if head == "":
		for p in sim.pending:
			if int(p["age"]) == 0:
				var e: Dictionary = p["event"]
				head = str(e["title"])
				sub = str(e["text"])
				art = str(e.get("art", e["id"]))
				if outlet == "state" and float(sim.unrest) > 40.0:
					sub = TranslationServer.translate("Yetkililer durumun kontrol altında olduğunu vurguladı.") + " " + sub
				break
	if head == "":
		if outlet == "state":
			head = "Krallıkta huzur ve istikrar"
			sub = _pick(ROYAL_FLUFF, "fluff", w)
			art = "toren"
		else:
			var ub := _band(sim.unrest, false)
			head = ["Sessiz bir hafta", "Sabır taşıyor mu?", "Başkent tedirgin"][ub]
			sub = "Saraydan bu hafta da açıklama yok. Sokak ise konuşuyor."
			art = ["kis_krizi", "gida_protestosu", "gida_protestosu_b"][ub]
	if outlet == "state" and sim.halden_mood() == "düşmanca":
		head = _pick(["Saray halktan koptu", "Hükümet sözünü tutmadı", "Kraliyet hesap vermeli"], "halden_manset", w)
		sub = "Sarne'nin yayın kurulu bu hafta sarayın kararlarını sert sözlerle sorguluyor."
		art = "halden_ihale"
	out["headline"] = head
	out["lead"] = sub
	out["art"] = art
	var cols: Array = []
	var economy_view := (float(sim.economy_metrics["growth"]) * 0.35 + float(sim.economy_metrics["jobs"]) * 0.25
		+ (100.0 - float(sim.economy_metrics["inflation"])) * 0.2 + (100.0 - float(sim.economy_metrics["debt"])) * 0.2)
	if outlet == "free":
		economy_view = ((100.0 - float(sim.economy_metrics["inflation"])) * 0.45 + float(sim.economy_metrics["jobs"]) * 0.25
			+ (100.0 - float(sim.economy_metrics["debt"])) * 0.3)
	var eb := _band(_seen(economy_view, true, f), true)
	cols.append({"title": "EKONOMİ", "head": ECON[outlet][eb][0], "body": ECON[outlet][eb][1]})
	var sb := _band(_seen(sim.unrest, false, f), false)
	cols.append({"title": "SOKAK", "head": STREET[outlet][sb][0], "body": STREET[outlet][sb][1]})
	var ob := _band(_seen(sim.opposition, false, f), false)
	cols.append({"title": "MECLİS", "head": OPP[outlet][ob][0], "body": OPP[outlet][ob][1]})
	# Kulis (bağımsız gazete söylentileri basar) / Saraydan (resmî gazete)
	if outlet == "free":
		var rumors: Array[String] = []
		for fact: Dictionary in sim.facts.values():
			if fact.get("rumor", false) and not fact.get("public", false):
				rumors.append(str(fact["text"]))
		if rumors.is_empty():
			cols.append({"title": "KULİS", "head": "Saray koridorları sessiz", "body": "Bu hafta kulağımıza bir şey çalınmadı. Ya da çalınmasına izin verilmedi."})
		else:
			cols.append({"title": "KULİS", "head": "Koridorlarda konuşulanlar", "body": TranslationServer.translate("Kaynaklarımıza göre: %s.") % "; ".join(rumors.slice(0, 2))})
	else:
		cols.append({"title": "SARAYDAN", "head": "Kraliyet ajandası", "body": _pick(ROYAL_FLUFF, "ajanda", w + 3)})
		if sim.halden_mood() == "düşmanca":
			cols = [
				{"title": "EKONOMİ", "head": "Bakanlığa zor sorular", "body": "Yayın kurulu, sarayın harcamalarına ilişkin hesabın açıklanmasını istiyor."},
				{"title": "SOKAK", "head": "Halkın sesi duyulmalı", "body": "Sarne'nin köşe yazarları kararların halka sorulmadığını savunuyor."},
				{"title": "MECLİS", "head": "Saray meclise dönsün", "body": "Kanaldaki yorumcular kraliyet kararlarının denetlenmesini talep ediyor."},
				{"title": "SARAYDAN", "head": "Açıklama bekleniyor", "body": "Yayın kurulu saraydan cevap beklediğini duyurdu."},
			]
	out["columns"] = cols
	out["weather"] = _pick(WEATHER, "hava", w)
	out["ad"] = _pick(ADS, outlet, w)
	return _localized(out)


## Sarne TV yayını.
static func broadcast(sim: Node) -> Dictionary:
	var ed := edition(sim, "state")
	var ticker: Array[String] = []
	for n in sim.weekly_news:
		# Kanal yalnızca olayları yayınlar: skandal ve dedikodu basmaz; alametler, sözler, soruşturma notları
		# ve ertelenen kararlar kralın masasındaki özel bilgilerdir.
		var s := str(n)
		if s.begins_with("OLAY: "):
			ticker.append(sim.news_for_display(s).substr(6))
	for c in ed["columns"]:
		ticker.append("%s: %s" % [c["title"], c["head"]])
	ticker.append(TranslationServer.translate("HAVA: %s") % str(ed["weather"]))
	var name := "SARNE TV" if sim.actors.has("halden") else "DEVLET TELEVİZYONU"
	return _localized({"channel": name, "headline": ed["headline"], "sub": ed["lead"], "ticker": ticker, "art": ed.get("art", "")})
