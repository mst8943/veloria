# Faz 6 — Genişleme: Codex görev dosyası (kalıcı)

Orkestra: Claude tasarlar ve doğrular; Codex kodlar. Bu dosya her yeni Codex oturumunda önce okunur. Dilimleri SIRAYLA yap, her dilim ayrı commit(ler); bir oturumda yalnızca "SIRADAKİ DİLİM"(ler)i bitir, ilerleme dosyasını (docs/roadmap/FAZ6_ILERLEME.md) güncelle, dur, kısa Türkçe rapor ver.

## Değişmez kurallar (hepsi geçerli)
- Önce oku: CLAUDE.md, docs/ux/gundem_v2_gorev_promptu.md (UI kuralları), docs/i18n/gorev_promptu.md ve docs/i18n/sizinti_gorevi.md ("Kararlar": çift dilli metin üretimi). Oyun mantığı varsayılan yolda DEĞİŞMEZ: `--full` tohum 101 = 104 hafta / TAHTTA / Medya Rejimi / 112 olay, TR ve EN aynı; ölçüt probe 68/80, 36/80, 16/80. Yeni mekanik tohumları kaydıracaksa AYRI üreteç kullan ya da değişimi ve yeni tabanı açıkça belgele.
- PUSH YOK. Her mantıksal adım ayrı commit. Commit'e GİRMEYENLER: .mcp.json, .cursor/, project.godot (zorunlu değilse), art/portraits/PROMPTS.md, art/portraits/overview.png(.import), audio/_kaynak, docs/marketing. Godot --import portları 8772 olursa 8770'e geri al. Çalışan editörü (konsol olmayan Godot exe) ASLA kapatma. Bilgisayarı KAPATMA veya kapatma zamanlama.
- Yeni metin: tr("...") + game/i18n/en.po (sentence case, çoğul Loc.ntr); saklanan/üretilen metin çift dilli (Türkçe + İngilizce birlikte). EN sızıntı kapıları: `tools/i18n_leak_scan.py` (tests/en_dump.gd masaüstü ve --mobile, tests/en_dump2.gd) ŞÜPHELİ 0, `tools/i18n_missing.py` 0, en_leak_test OK.
- UI: UIKit paleti, boyanmış çerçeve dokuları (art/ui, UIKit.tex_box/ornament), mobil 44 px, web'de glif kutusu çıkar (çizilmiş şekil kullan), "sayı yok" ilkesi. Mobil dokunuş: game/ui/touch_scroll.gd ile çakışma yok.
- Test paketi ($G = C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe): sim_test, event_check, save_test (eski kayıt yükleme dahil), content_check, i18n_check, en_leak_test, ui_input_test (masaüstü ve -- --mobile), lang_switch_test, touch_scroll_test, tour_test, cutscene_check, audio_check; --autoplay, --autoplay --mobile, --autoplay --full (TR ve EN); ölçüt probe (.claude/skills/balance-check/probe_template.gd). Her dilimin sonunda pencereli ekran görüntüsü (tests/ux_audit.gd, tests/ui_shots.gd) TR + EN, masaüstü + mobil: AÇ ve gözle kontrol et.

## DALGA A (bağımsız, ucuz-orta işler)

### A1 — Uyarlamalı müzik
Amaç: tek ambient yerine duruma göre müzik: menü, normal oyun, gerilim, kriz; geçişlerde çapraz solma.
- `Sfx` (game/core/sfx.gd): iki AudioStreamPlayer (A/B) ile `crossfade_to(name, seconds)`; müzik adları: `menu`, `ambient`, `tension`, `crisis` (dosya `res://audio/<ad>.ogg|wav|mp3`; eksikse `ambient`e düş; o da yoksa mevcut sentez). Döngü: ogg/mp3 `loop=true`.
- Durum eşlemesi (UI'dan çağrı, Sim'e bağımlılık yok): menü açık → `menu`; oyun içi → `ambient`; bekleyen kararlardan biri süresi dolmak üzereyse (age>0) → `tension`; `Sim.active_crisis_label() != ""` → `crisis`; oyun sonu → sessiz + jingle (mevcut). Geçiş en az 2 sn, durum titremesini önlemek için en az 8 sn kalma süresi.
- Hızlı kip/test/autoplay'de çapraz solma yok (anında). Müzik ses ayarına bağlı kalsın.
- Dosyalar yoksa `menu/tension/crisis` için `ambient` akışı farklı ses seviyesiyle çalabilir ya da `tools/audio_build.py`ye sentezlenmiş 60 sn'lik döngüler eklenebilir (kullanıcı gerçek dosyaları sonra `audio/` içine koyacak, otomatik tercih edilir).
- Test: tests/audio_check.gd genişlet (dört müzik adı çözümleniyor, çapraz solma durumları, döngü). Kapı: tüm testler; ses ayarı çalışıyor.

### A2 — Erişilebilirlik
- Ayarlar'da: **Yazı boyutu** (Normal / Büyük / Çok büyük; `_fs()` ve UIKit tema yazı boyutları ölçeklenir, mobil dahil, taşma yok), **Renk körü modu** (renk tek anlam taşımasın: kırmızı/yeşil rozet ve çipler için şekil/etiket ek; "sayı yok" ilkesi korunur), **Hareketi azalt** (drift, toz, sarsıntı, nabız, ara sahne yakınlaşması kapanır/yumuşar), **Titreşim** (Android: karar verme, kriz başlangıcı, hafta bitirme; `Input.vibrate_handheld`, varsayılan açık), **Yüksek kontrast** (metin ve kenarlık açılır).
- Hepsi kullanıcı ayar dosyasında (Sfx ayarları gibi), kayıt dosyasında DEĞİL; canlı uygulanır (`main.rebuild_ui()` ile).
- Test: ux_audit en büyük yazı boyutunda 1067x600 ve 1280x720'de taşma/kırpılma bulgusu yok (kaydırma altında kalan beklenen uyarılar hariç); yeni tests/a11y_test.gd. Dil: TR + EN.

### A3 — Günlük tohum ve paylaşılabilir saltanat kartı
- **Günlük meydan okuma:** Menü → "Günlük saltanat": tohum, takvim gününden (UTC tarih) deterministik türetilir (`daily_seed(date)`; her gün aynı için herkes aynı oyunu oynar), Normal zorluk. Günün sonucu `user://daily.cfg`te saklanır (gün, ünvan, hafta, kazandı/kaybetti). Menüde "Bugünkü sonuç" gösterilir; tekrar oynama serbest (sonuç ilk tamamlananı korur).
- **Saltanat kartı:** Oyun sonu ekranında "Kartı kaydet": SubViewport ile 1080x1350 PNG (ünvan, hafta, rejim, kral portresi, tarih/gün tohumu, 3 kısa satır; "sayı yok" ilkesi: yalnızca oyun sonunda zaten açıklanan bilgiler). Windows/Linux: `user://cards/` + klasörü aç düğmesi; Android: uygulama klasörü ya da `OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)` + "Metni kopyala" (DisplayServer.clipboard_set; paylaşım metni TR/EN). Web: indirme bağlantısı (JavaScriptBridge) ya da yalnızca metin kopyalama.
- Test: daily_seed kararlılığı (aynı tarih → aynı tohum → aynı sonuç), kart oluşturma (PNG boyutu ve dosya), kayıt göçü etkilenmez. TR + EN kart.

### A4 — Senaryo modları ve sonsuz mod
- `game/data/scenarios.json` (+ `game/data/en/scenarios.json`): her senaryo `{id, name, desc, overrides: {actors:{id:{power,loyalty,ambition,...}}, flags, capacity, wealth, mesai_max, first_events:[olay_id,...]}}`. Üç senaryo: **Darbeye açık krallık** (Arden güçlü, ordu şüpheli, ilk kriz tohumu erken), **Naiplik** (veliaht küçük/olgunluğu düşük, Helena naip gücü), **Boş kasa** (kasa ve maliye kapasitesi düşük; dış baskı Faz 6-B1 gelene kadar yalnızca kasa/olay etkisi). Varsayılan senaryo = mevcut oyun (BİREBİR değişmez).
- `Sim.new_game(seed, diff, scenario_id := "")`; kayda `scenario` alanı (SAVE_VERSION artır + göç). Menü → Yeni saltanat ekranında senaryo seçimi (mobil dostu liste). Başarımlar: senaryo bazlı en az 3 yeni rozet (TR/EN).
- **Sonsuz mod:** Oyun sonu (TAHTTA) ekranında "Saltanata devam et": MAX_WEEKS aşılınca oyun sonlanmaz; olay havuzu bekleme süresiyle yeniden kullanılır; her 26 haftada kriz eşiği −2 (yumuşak zorluk artışı); kayıt ve başarımlar "Uzatma" olarak ayrı; en uzun saltanat defterde. Varsayılan akış değişmez.
- Test: senaryo birim testleri, her senaryo için bot koşusu (80 kampanya/zorluk) ve tahtta kalma oranı bandı (Normal %25–65), senaryosuz --full aynı, sonsuz modda 200 hafta bot koşusu çökmeden bitiyor, save_test eski kayıt.

## DALGA B (tasarım hazır, A'dan sonra)
- **B1 — Dış krizler ve suikast:** docs/design/dis_krizler_ve_suikast.md (yeni kayıp yolları: yabancı müdahalesi, mali çöküş, suikast).
- **B2 — Miras ve hanedan:** docs/design/miras_ve_hanedan.md (Hanedan Devam, Hanedan Defteri).

## DALGA C (kullanıcı kararı gerektirir)
Google Play yayını (release keystore, AAB), üçüncü dil, Steam sürümü, bulut kayıt, tablet düzeni.
