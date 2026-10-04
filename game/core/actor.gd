extends RefCounted

var id: String
var display_name: String
var title: String
var domain: String
var power: float
var ambition: float
var fear: float
var honesty: float
var threshold: float
var military := false
var royal := false
var insider := true            # darbe/kaskad hesabına katılır mı
var loyalty: Dictionary
var red_line: String
var weak_point: String

var obligation := 0.0          # kralın ona olan borcu
var perceived_king := 60.0     # kralın gücü hakkındaki (yanlış olabilen) algısı
var ready := false             # kralı devirmeye hazır
var moved := false             # fiilen harekete geçti / düşman oldu
var secrets_on_king := 0       # kral hakkında bildiği sır sayısı

const SAVE_PROPS := ["power", "ambition", "fear", "honesty", "threshold", "loyalty", "obligation",
	"perceived_king", "ready", "moved", "secrets_on_king"]


func setup(d: Dictionary) -> void:
	id = d["id"]
	display_name = d["name"]
	title = d["title"]
	domain = d["domain"]
	power = d["power"]
	ambition = d["ambition"]
	fear = d["fear"]
	honesty = d["honesty"]
	threshold = d["threshold"]
	military = d.get("military", false)
	royal = d.get("royal", false)
	insider = d.get("insider", true)
	loyalty = (d["loyalty"] as Dictionary).duplicate()
	red_line = d.get("red_line", "")
	weak_point = d.get("weak_point", "")


func to_save() -> Dictionary:
	var out := {}
	for p in SAVE_PROPS:
		out[p] = get(p)
	return out


func from_save(d: Dictionary) -> void:
	for p in SAVE_PROPS:
		if d.has(p):
			set(p, d[p])


func total_loyalty() -> float:
	var s := 0.0
	for k in loyalty:
		s += float(loyalty[k])
	return s


## Güç kazandıkça, borç biriktikçe ve kral zayıf göründükçe isyan eğilimi artar.
func rebellion_drive() -> float:
	return ambition + power * 0.3 + obligation * 0.4 + (60.0 - perceived_king) * 0.5 - total_loyalty() * 0.8


## Emir kırmızı çizgiye dokunuyorsa, muğlak emir uygulanmaz.
func red_line_penalty(task: String) -> float:
	if task == "bastir" and red_line.contains("ateş"):
		return 0.35
	return 0.0


## Korku ve dürüstlük raporun ne kadar süslendiğini belirler (0..1).
func flattery() -> float:
	return clampf(fear / 100.0 * 0.7 + (1.0 - honesty) * 0.5, 0.0, 1.0)
