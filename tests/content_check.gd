extends SceneTree
## İçerik JSON şeması ve çökmeden hata bildirme denetimi.
const ContentData := preload("res://game/core/content_data.gd")
const Loc := preload("res://game/core/loc.gd")

func _init() -> void:
	Loc.set_lang("en" if "--lang=en" in OS.get_cmdline_user_args() else "tr")
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
	bad = all["reports"].duplicate(true)
	bad["state"]["hukuk"]["aksıyor"][0] = ""
	ok = _expect_bad(loader, "reports", bad, "eksik/boş kurum raporu") and ok
	bad = all["achievements"].duplicate(true)
	bad["ilk_saltanat"][0] = ""
	ok = _expect_bad(loader, "achievements", bad, "boş başarım") and ok
	bad = all["council"].duplicate(true)
	bad["experts"]["king"][0] = "bilinmeyen_kisi"
	ok = _expect_bad(loader, "council", bad, "bilinmeyen uzman aktör") and ok
	bad = all["labels"].duplicate(true)
	bad["budget"]["choices"][0]["text"] = ""
	ok = _expect_bad(loader, "labels", bad, "bütçe seçeneği hatalı") and ok
	bad = all["labels"].duplicate(true)
	bad["patronage"]["choices"][3]["text"] = ""
	ok = _expect_bad(loader, "labels", bad, "Sarne talep seçeneği hatalı") and ok
	loader.load_all({"reports": "res://game/data/olmayan_icerik.json"})
	var file_error := "Content file error:" if Loc.lang == "en" else "İçerik dosyası hatalı:"
	if not loader.error.contains(file_error):
		push_error("eksik içerik dosyası açık hata vermedi")
		ok = false
	var broken := "user://veloria_content_check_bad.json"
	var f := FileAccess.open(broken, FileAccess.WRITE)
	f.store_string("{ bozuk JSON")
	f.close()
	loader.load_all({"reports": broken})
	DirAccess.remove_absolute(ProjectSettings.globalize_path(broken))
	var json_error := "JSON is malformed" if Loc.lang == "en" else "JSON bozuk"
	if not loader.error.contains(json_error):
		push_error("bozuk JSON açık hata vermedi")
		ok = false
	print("CONTENT: %s (5 dosya, 8 bozuk örnek)" % ("OK" if ok else "FAIL"))
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
	var translated_expected := expected
	if Loc.lang == "en":
		translated_expected = {
			"eksik anahtar": "missing key",
			"eksik/boş kurum raporu": "missing or empty institutional report",
			"boş başarım": "missing or empty achievement",
			"bilinmeyen uzman aktör": "unknown expert actor",
			"bütçe seçeneği hatalı": "budget choice is invalid",
			"Sarne talep seçeneği hatalı": "Sarne demand choice is invalid"
		}.get(expected, expected)
	if not loader.error.contains(translated_expected):
		push_error("%s hatası yakalanmadı: %s" % [section, loader.error])
		return false
	return true
