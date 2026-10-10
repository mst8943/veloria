extends RefCounted
## Yerelleştirme durumu. Kaynak dil her zaman Türkçedir.

static var lang := "tr"


static func set_lang(value: String) -> void:
	lang = "en" if value == "en" else "tr"
	TranslationServer.set_locale(lang)


static func poss(name: String) -> String:
	return name + "'" if name.ends_with("s") else name + "'s"


static func en(message: String) -> String:
	var translation := TranslationServer.get_translation_object("en")
	if translation == null:
		return message
	var result := str(translation.get_message(message))
	return result if result != "" else message


static func ntr(message: String, count: int) -> String:
	if lang != "en":
		return TranslationServer.translate(message)
	return str(TranslationServer.translate_plural(message, message + " [plural]", count))
