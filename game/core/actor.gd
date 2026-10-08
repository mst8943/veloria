extends RefCounted

var id: String
var display_name: String
var short := ""   # kart ve meclis kısa adı; boşsa soyadı (aynı soyadlı iki kişiyi ayırmak için)
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
var supporting := false        # yeni kadro: eski dokuz aktörün RNG ve darbe hesabına girmez
var loyalty: Dictionary
var red_line: String
var weak_point: String

var obligation := 0.0          # kralın ona olan borcu
var perceived_king := 60.0     # kralın gücü hakkındaki (yanlış olabilen) algısı
var ready := false             # kralı devirmeye hazır
var moved := false             # fiilen harekete geçti / düşman oldu
var secrets_on_king := 0       # kral hakkında bildiği sır sayısı
var known_weak := false        # oyuncu zayıf noktasını keşfetti mi
var known_red := false         # oyuncu kırmızı çizgisini keşfetti mi
var blackmailed := 0           # kaç kez şantaj yapıldı
var plot_stage := 0            # komplo aşaması: 0 sakin, 1 huzursuz, 2 komplocu (ready), 3 hazırlıkta
var plot_calm := 0             # komplodan çekilme koşulunun üst üste sağlandığı hafta sayısı
var signs: Array = []          # oyuncunun gördüğü alametler: {w, text, weight, real}

const SAVE_PROPS := ["power", "ambition", "fear", "honesty", "threshold", "loyalty", "obligation",
	"perceived_king", "ready", "moved", "secrets_on_king", "known_weak", "known_red", "blackmailed",
	"plot_stage", "plot_calm", "signs"]


func setup(d: Dictionary) -> void:
	id = d["id"]
	display_name = d["name"]
	short = d.get("short", "")
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
	supporting = d.get("supporting", false)
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
	if crosses_red_line(task):
		return 0.35
	return 0.0


## Bastırma emri, sivillere şiddet ya da taraftar tutuklamayı kırmızı çizgi sayan birine dokunur.
func crosses_red_line(task: String) -> bool:
	return task == "bastir" and (red_line.contains("ateş") or red_line.contains("tutuklan"))


## Korku ve dürüstlük raporun ne kadar süslendiğini belirler (0..1).
func flattery() -> float:
	return clampf(fear / 100.0 * 0.7 + (1.0 - honesty) * 0.5, 0.0, 1.0)
