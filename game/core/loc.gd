extends RefCounted
## Yerelleştirme durumu. Kaynak dil her zaman Türkçedir.

static var lang := "tr"


static func set_lang(value: String) -> void:
	lang = "en" if value == "en" else "tr"
	TranslationServer.set_locale(lang)


static func poss(name: String) -> String:
	return name + "'" if name.ends_with("s") else name + "'s"
