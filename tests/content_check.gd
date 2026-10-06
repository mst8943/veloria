extends SceneTree
## İçerik JSON şeması ve çökmeden hata bildirme denetimi.
const ContentData := preload("res://game/core/content_data.gd")

func _init() -> void:
	var loader: RefCounted = ContentData.new()
	var all: Dictionary = loader.load_all()
	if loader.error != "":
		print("CONTENT: FAIL — ", loader.error)
		quit(1)
		return
	var ok := true
	var bad: Dictionary = all["reports"].duplicate(true)
	bad.erase("phrases")
	ok = _expect_bad(loader, "reports", bad, "eksik anahtar") and ok
	bad = all["achievements"].duplicate(true)
	bad["ilk_saltanat"][0] = ""
	ok = _expect_bad(loader, "achievements", bad, "boş başarım") and ok
	bad = all["council"].duplicate(true)
	bad["experts"]["king"][0] = "bilinmeyen_kisi"
	ok = _expect_bad(loader, "council", bad, "bilinmeyen uzman aktör") and ok
	loader.load_all({"reports": "res://game/data/olmayan_icerik.json"})
	if not loader.error.contains("İçerik dosyası hatalı"):
		push_error("eksik içerik dosyası açık hata vermedi")
		ok = false
	var broken := "user://veloria_content_check_bad.json"
	var f := FileAccess.open(broken, FileAccess.WRITE)
	f.store_string("{ bozuk JSON")
	f.close()
	loader.load_all({"reports": broken})
	DirAccess.remove_absolute(ProjectSettings.globalize_path(broken))
	if not loader.error.contains("JSON bozuk"):
		push_error("bozuk JSON açık hata vermedi")
		ok = false
	print("CONTENT: %s (5 dosya, 5 bozuk örnek)" % ("OK" if ok else "FAIL"))
	quit(0 if ok else 1)


func _expect_bad(loader: RefCounted, section: String, data: Dictionary, expected: String) -> bool:
	var path := "user://veloria_content_check_bad.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("içerik test dosyası açılamadı")
		return false
	f.store_string(JSON.stringify(data, "  ", false))
	f.close()
	loader.load_all({section: path})
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if not loader.error.contains(expected):
		push_error("%s hatası yakalanmadı: %s" % [section, loader.error])
		return false
	return true
