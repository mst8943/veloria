extends Control
## Ana menü (main.gd'den ayrıldı): Devam Et / Yeni Oyun / Ayarlar / Çıkış, sayfalar (ana, yeni oyun, ayarlar),
## Nasıl Oynanır / Hükümdarlık Arşivi / Hakkında bağlantıları. Menünün kendisi bu düğüm; main.gd onu `_menu` olarak tutar.
## Açma/kapama (_show_menu, _hide_menu) başka görünümleri de yönettiği için main.gd'de kalır.

const UIKit := preload("res://game/ui/ui_kit.gd")
const Loc := preload("res://game/core/loc.gd")
const SHIMMER_SHADER := preload("res://game/ui/shimmer.gdshader")

## Emeği geçenler ve lisans bildirimleri (Godot MIT ve EB Garamond OFL bildirimi dağıtımda zorunludur).
const CREDITS := """[b][font_size=30][color=#d6b25e]VELORIA[/color][/font_size][/b]
[color=gray]Reaktif bir siyaset ve iktidar simülasyonu[/color]

[b]Yapım[/b]
Mesut Canturk

[b]Tasarım ve geliştirme desteği[/b]
Claude (Anthropic)

[b]Görseller[/b]
Yapay zekâ ile üretilmiş özgün görseller. Tüm karakterler ve kurumlar kurgusaldır; gerçek kişi ve kurumlarla benzerlik tesadüftür.

[b]Yazı tipi[/b]
EB Garamond — Copyright 2017 The EB Garamond Project Authors (github.com/octaviopardo/EBGaramond12).
IBM Plex Sans — Copyright 2017 IBM Corp. (github.com/IBM/plex).
İkisi de SIL Open Font License 1.1 altında kullanılmıştır (lisans metinleri oyun dosyalarında: game/fonts/OFL.txt, game/fonts/OFL_IBMPlexSans.txt).

[b]Oyun motoru[/b]
Bu oyun Godot Engine ile yapılmıştır ve aşağıdaki lisans altında kullanılmaktadır:

[color=gray][font_size=13]Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Portions of this software are copyright © The FreeType Project (www.freetype.org). All rights reserved.[/font_size][/color]"""

## Nasıl oynanır penceresi (ana menüdeki bağlantı).
const HOW_TO := "[b][font_size=26][color=#d6b25e]Nasıl oynanır[/color][/font_size][/b]\n\n• 104 hafta tahtta kal. Haftada [b]4 mesain[/b] var; kararlar, emirler ve operasyonlar mesai harcar.\n• Sayıları göremezsin; yalnızca [b]raporlar[/b] vardır ve herkes yalan söyleyebilir. Korktukça insanlar sana gerçeği söylemez; hepsi aynı cümleyi kurmaya başlar.\n• Verdiğin güç sana dönebilir. Terfi, borç ve gizli ödemeler iz bırakır.\n• Söz vermek kolaydır; vadesi gelince ya tutarsın ya da bedelini ödersin. Aynı makamı iki kişiye vaat etmek er geç duyulur.\n• Herkesin bildiği bir sır, gizli bir sırdan çok daha tehlikelidir.\n• Her kararda [b]meclisten iki kişi[/b] görüş bildirir. Gerekçeleri doğrudur ama seçicidir; [color=#d08a3d]ÇIKARI VAR[/color] olanın önerisi tarafsız olmayabilir.\n• Darbe bir sabah gelmez: önce [b]alametler[/b] görünür, kişi kartında [color=#d08a3d]ŞÜPHELİ[/color] yazar. Bir kısmı dedikodudur; [b]Huzura Çağır[/b] ile yoklayabilirsin. Darbe kapına dayandığında son kararı sen verirsin.\n• Ertelediğin kararlar iki hafta sonra kendi kendine çözülür.\n• Oyun bittiğinde [b]Hakikat Dosyası[/b] sana kimin ne zaman yalan söylediğini gösterir."

var host: Control   # main.gd
var bg: Control
var items: Array = []        # açılış animasyonu sırası
var pages: Dictionary = {}
var page_now := "main"


func _init(main: Control) -> void:
	host = main
	_build()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
	bg = Control.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var tex: Texture2D = host._art("res://art/menu_bg.png")
	if tex:
		var t := TextureRect.new()
		t.texture = tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.add_child(t)
	else:
		var grad := Gradient.new()
		grad.set_color(0, Color("1c1813"))
		grad.set_color(1, Color("080706"))
		var gt := GradientTexture2D.new()
		gt.gradient = grad
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.45)
		gt.fill_to = Vector2(1.0, 1.0)
		gt.width = 512
		gt.height = 512
		var t2 := TextureRect.new()
		t2.texture = gt
		t2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t2.stretch_mode = TextureRect.STRETCH_SCALE
		t2.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.add_child(t2)
	var shade := ColorRect.new()
	shade.color = Color(UIKit.SHADE, 0.5)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	add_child(UIKit.dust(Vector2(1600, 900), 60, 0.4))

	# Menü kaydırılabilir: küçük ekranda taşarsa kaydırılır, büyükte ortada durur.
	var menu_scroll := ScrollContainer.new()
	menu_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(menu_scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_scroll.add_child(center)
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", UIKit.box(Color(UIKit.PLATE, 0.72), Color(UIKit.GOLD_DIM, 0.35), 10, 34))
	center.add_child(plate)
	UIKit.ornament(plate, Color(UIKit.GOLD, 0.8), 24, 9)
	var box := VBoxContainer.new()
	box.custom_minimum_size.x = 560
	box.add_theme_constant_override("separation", 12)
	plate.add_child(box)
	var title := Label.new()
	title.text = tr("V E L O R İ A")
	var shine := ShaderMaterial.new()
	shine.shader = SHIMMER_SHADER
	shine.set_shader_parameter("screen_w", 1067.0 if host._mobile else 1600.0)
	title.material = shine
	title.add_theme_font_override("font", UIKit.serif())
	title.add_theme_font_size_override("font_size", 60 if host._mobile else 84)
	title.add_theme_color_override("font_color", UIKit.GOLD)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	title.add_theme_constant_override("shadow_offset_y", 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub := Label.new()
	sub.text = tr("Tahtta kalmak, ülkeyi yönetmekten daha zordur.")
	sub.add_theme_font_override("font", UIKit.serif())
	sub.add_theme_font_size_override("font_size", host._fs(20))
	sub.add_theme_color_override("font_color", Color(UIKit.TEXT, 0.85))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var mdiv := UIKit.divider(380.0)
	mdiv.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(mdiv)
	box.add_child(sub)
	var sp := Control.new()
	sp.custom_minimum_size.y = 10 if host._mobile else 18
	box.add_child(sp)

	# --- Ana sayfa: dört büyük düğme, altında küçük bağlantılar
	var main_page := _page("main", box)
	var b_first := _btn(main_page, tr("Devam Et"), func() -> void:
		if not Sim.actors.is_empty() and not Sim.ended:
			host._hide_menu()
		else:
			host._continue())
	var b_new := _btn(main_page, tr("Yeni Oyun"), func() -> void: show_page("new"))
	var b_set := _btn(main_page, tr("Ayarlar"), func() -> void: show_page("settings"))
	var b_quit := _btn(main_page, tr("Çıkış"), func() -> void: get_tree().quit())
	b_quit.visible = not OS.has_feature("web")   # tarayıcıda çıkış anlamsız
	for b in [b_first, b_new, b_set, b_quit]:
		b.custom_minimum_size.y = 50 if host._mobile else 58
		b.add_theme_font_override("font", UIKit.serif())
		b.add_theme_font_size_override("font_size", host._fs(21))
	var links := HBoxContainer.new()
	links.alignment = BoxContainer.ALIGNMENT_CENTER
	links.add_theme_constant_override("separation", 6)
	main_page.add_child(links)
	for l in [[tr("Nasıl Oynanır"), func() -> void: host._show_modal(tr(HOW_TO))], [tr("Hükümdarlık Arşivi"), host._show_chronicle], [tr("Hakkında"), func() -> void: host._show_modal(tr(CREDITS))]]:
		var lb := Button.new()
		lb.text = l[0]
		lb.theme_type_variation = "GhostButton"
		lb.custom_minimum_size.y = 40
		host._wire(lb)
		lb.pressed.connect(l[1])
		links.add_child(lb)

	# --- Yeni oyun: zorluk seçimi
	var new_page := _page("new", box)
	new_page.add_child(_heading(tr("YENİ SALTANAT")))
	var dgroup := ButtonGroup.new()
	var ddesc := [
		tr("5 mesai, daha uzun koruma süresi ve bol gelir. İlk saltanat için."),
		tr("4 mesai. Dengeli: hatalarını affeder ama unutmaz."),
		tr("4 mesai, kısa koruma, az gelir. Darbeler daha erken ve kolay gelir."),
	]
	for i in Sim.DIFFICULTY.size():
		var db := Button.new()
		db.text = "  %s\n  %s" % [tr(str(Sim.DIFFICULTY[i]["name"])), ddesc[i]]
		db.theme_type_variation = "ChoiceButton"
		db.alignment = HORIZONTAL_ALIGNMENT_LEFT
		db.toggle_mode = true
		db.button_group = dgroup
		db.button_pressed = i == Sfx.difficulty
		db.custom_minimum_size.y = 58
		db.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		host._wire(db)
		db.pressed.connect(func() -> void:
			Sfx.difficulty = i
			Sfx.save_settings())
		new_page.add_child(db)
	var nrow := HBoxContainer.new()
	nrow.add_theme_constant_override("separation", 10)
	new_page.add_child(nrow)
	var b_back1 := _btn(nrow, tr("Geri"), func() -> void: show_page("main"))
	b_back1.theme_type_variation = "GhostButton"
	b_back1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b_go := _btn(nrow, tr("Tahta Çık"), host._request_new_game, true)
	b_go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_go.size_flags_stretch_ratio = 2.0

	# --- Ayarlar
	var set_page := _page("settings", box)
	set_page.add_child(_heading(tr("AYARLAR")))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	set_page.add_child(grid)
	var checks := [
		[tr("Tam ekran (F11)"), Sfx.fullscreen, func(on: bool) -> void: Sfx.set_fullscreen(on), not host._mobile],
		[tr("Kısa geçişler"), Sfx.short_fx, func(on: bool) -> void: Sfx.short_fx = on, true],
		[tr("Danışman ipuçları"), Sfx.tips, func(on: bool) -> void: Sfx.tips = on, true],
		[tr("Açılış sineması"), Sfx.intro, func(on: bool) -> void: Sfx.intro = on, true],
		[tr("Haftaya masadan başla"), Sfx.desk_start, func(on: bool) -> void: Sfx.desk_start = on, true],
	]
	for c in checks:
		if not c[3]:
			continue
		var cb := CheckBox.new()
		cb.text = c[0]
		cb.button_pressed = c[1]
		var apply: Callable = c[2]
		cb.toggled.connect(func(on: bool) -> void:
			apply.call(on)
			Sfx.save_settings())
		grid.add_child(cb)
	grid.add_child(_label_dim(tr("Dil / Language")))
	var language := OptionButton.new()
	language.add_item("Türkçe", 0)
	language.add_item("English", 1)
	language.select(1 if Loc.lang == "en" else 0)
	language.item_selected.connect(func(index: int) -> void:
		Sfx.set_language("en" if index == 1 else "tr")
		Sfx.save_settings()
		host.call_deferred("rebuild_ui"))
	grid.add_child(language)
	var vgrid := GridContainer.new()
	vgrid.columns = 2
	vgrid.add_theme_constant_override("h_separation", 16)
	vgrid.add_theme_constant_override("v_separation", 10)
	set_page.add_child(vgrid)
	vgrid.add_child(_label_dim(tr("Müzik")))
	var s_music := _slider(Sfx.music_volume, func(v: float) -> void:
		Sfx.set_music(v)
		Sfx.save_settings())
	s_music.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vgrid.add_child(s_music)
	vgrid.add_child(_label_dim(tr("Ses efekti")))
	var s_sfx := _slider(Sfx.sfx_volume, func(v: float) -> void:
		Sfx.set_sfx(v)
		Sfx.play("click")
		Sfx.save_settings())
	s_sfx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vgrid.add_child(s_sfx)
	var b_back2 := _btn(set_page, tr("Geri"), func() -> void: show_page("main"))
	b_back2.theme_type_variation = "GhostButton"

	items = [title, mdiv, sub, b_first, b_new, b_set, b_quit, links]
	set_meta("first", b_first)
	set_meta("new", b_new)
	var ver := Label.new()
	ver.text = tr("v%s   ·   Esc: menü   Boşluk: haftayı bitir   Ctrl+S: kaydet   F11: tam ekran") % str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	if host._mobile:
		ver.text = "v%s" % str(ProjectSettings.get_setting("application/config/version", "1.0.0"))
	ver.add_theme_color_override("font_color", Color(UIKit.TEXT_DIM, 0.7))
	ver.add_theme_font_size_override("font_size", host._fs(12))
	ver.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
	ver.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	ver.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(ver)
	hide()
	# Yavaş "Ken Burns" kaydırma
	bg.pivot_offset = Vector2(800, 450)
	var kb := bg.create_tween().set_loops()
	kb.tween_property(bg, "scale", Vector2(1.07, 1.07), 22.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	kb.tween_property(bg, "scale", Vector2(1.0, 1.0), 22.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _btn(parent: Control, text: String, cb: Callable, primary := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 46
	if primary:
		b.theme_type_variation = "PrimaryButton"
	host._wire(b)
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


## Menü sayfası: aynı anda yalnızca biri görünür (ana sayfa, yeni oyun, ayarlar).
func _page(page_name: String, parent: Control) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.visible = page_name == "main"
	parent.add_child(v)
	pages[page_name] = v
	return v


func _heading(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", UIKit.serif())
	l.add_theme_font_size_override("font_size", host._fs(24))
	l.add_theme_color_override("font_color", UIKit.GOLD)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func show_page(page_name: String) -> void:
	page_now = page_name
	for k in pages:
		(pages[k] as Control).visible = k == page_name
	if not host._fast():
		UIKit.fade_in(pages[page_name], 0.25)


func _label_dim(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", UIKit.TEXT_DIM)
	return l


func _slider(value: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(120, 22)
	s.value_changed.connect(cb)
	return s
