extends SceneTree

const UIKit := preload("res://game/ui/ui_kit.gd")
const IconFallback := preload("res://game/ui/ornament_icon.gd")
const ICONS := ["bina", "gazete", "kumsaati", "disli", "zarf", "klasor", "parsomen", "sandik", "terazi", "tac", "meclis", "altin", "kilic", "goz", "pusula", "defne", "kalem"]


func _initialize() -> void:
	for name in ICONS:
		var icon := UIKit.icon(name, Vector2(24, 24), Color.WHITE)
		if not icon is TextureRect or icon.custom_minimum_size != Vector2(24, 24) or icon.texture_filter != CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS:
			printerr("UI ICONS: premium icon failed: ", name)
			quit(1)
			return
		icon.free()
	var fallback := UIKit.icon("missing_icon_for_test", Vector2(20, 20))
	if fallback.get_script() != IconFallback:
		printerr("UI ICONS: ornament fallback was not used")
		quit(1)
		return
	fallback.free()
	var main_script: Script = load("res://game/ui/main.gd")
	var english_header: Texture2D = main_script._header_texture(true)
	var pixels := english_header.get_image()
	for y in range(118, 175):
		for x in range(390, 820):
			if pixels.get_pixel(x, y).get_luminance() > 0.08:
				printerr("UI ICONS: baked header copy was not removed at ", x, ",", y)
				quit(1)
				return
	print("UI ICONS: OK")
	quit(0)
