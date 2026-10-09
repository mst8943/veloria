# Gündem v2 — uygulama görev promptu (kalıcı kopya)

Yeni oturum önce bunu, sonra `docs/ux/gundem_sadelestirme_v2.md` (tasarım + taslak kararları) ve `docs/ux/GUNDEM_V2_ILERLEME.md` (yoksa oluştur) dosyasını okur. Kurallar aynen geçerlidir.

## Çalışma biçimi
- Bir oturumda yalnızca "SIRADAKİ DİLİM"i bitir (U1…U4). Dilim ortasında rapor yazma, dilim sonunda dur ve kısa Türkçe rapor ver.
- Büyük dosyaları (main.gd, person_panel.gd, agenda_view.gd) 150 satırlık bölümlerle oku; çıktıları kısa tut.
- Her mantıksal adım AYRI commit (refactor ile özellik ayrı). PUSH YOK (kullanıcı ayrıca isteyecek).
- Her dilim sonunda ilerleme dosyasını güncelle ve commit'le.

## Bağlam
Veloria: Godot 4.7.2, Türkçe + İngilizce (tr()/en.po; yeni metin ikisine de). Proje C:\Users\USER\Desktop\oyun, dal veloria. Oku: CLAUDE.md, .claude/skills/game-design/VELORIA.md, docs/ux/gorsel_dil_v2.md, docs/ux/ana_ekran_sadelestirme.md, docs/i18n/gorev_promptu.md (i18n kuralları), docs/ux/gundem_sadelestirme_v2.md ve docs/ux/taslak_v2/*.png (YALNIZCA yerleşim referansı; kararlar tablosunda "Değiştirilenler" bölümü bağlayıcıdır).

## Değişmez kurallar
- Hiçbir özellik silinmez: 14 kişi, 7 eylem sekmesi, raporlar, Dosyalar/Günlük, yol gösterici, çoklu seçim, otomatik oynatma hepsi erişilebilir kalır.
- "Sayı yok": gizli değerleri sayı/renk koduyla (yeşil-sarı-kırmızı iyi-kötü gibi) GÖSTERME. Rozet noktaları yalnızca görülebilir duruma bağlı: kırmızı = düşman/komplo belirtisi görüldü, altın = bekleyen kararda söz sahibi, mavi = yeni/değişen rapor.
- Web'de glif kuralı: → ◆ ✓ ★ ⏳ ▸ ▾ ok/simge glifleri KUTU çıkar; çizilmiş şekil kullan (UIKit çizim yardımcıları, _draw).
- Palet ve bileşenler UIKit'ten (yeni renk ekleme); düğme hiyerarşisi (PrimaryButton, ChoiceButton, GhostButton); köşe en çok UIKit.RADIUS; ornament/divider/band_style imza öğeleri.
- Görünmez Control'lerde mouse_filter IGNORE; `class_name` yok, `preload`; yeni bileşenler `_init(main)` + `host` deseni (agenda_view.gd / person_panel.gd gibi).
- Mobil taban 1067x600, dokunma hedefi >= 44 px, `_fs()` ölçeği.
- 14 kart nesnesi AYNI kalır; şerit/Divan yalnızca kapsayıcıyı değiştirir. `--autoplay` ve `ui_input_test` kişi seçimini kartlar üzerinden yapar: `_cards[id]` gizli kapsayıcıdayken de erişilebilir ve basılabilir olmalı.
- Oyun mantığı (Sim) DEĞİŞMEZ; ölçüt probe (advice_weighted, 80 kampanya) ve `--full` tabanla BİREBİR aynı olmalı: tr ve en. Taban: 68/80, 36/80, 16/80; --full 101/104/TAHTTA/Medya Rejimi/112.
- Yeni metin: tr("...") + game/i18n/en.po; İngilizce sentence case; sayılı ifadeler Loc.ntr ile.
- Düzenleme betiklerini heredoc ile değil dosyayla çalıştır (Türkçe karakter). Çalışan Godot_v4.7.2-stable_win64.exe (konsol olmayan) kullanıcının editörüdür: ASLA kapatma.

## Test ($G = C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe)
sim_test, event_check, save_test, content_check, i18n_check (headless, --script res://tests/…); ui_input_test (pencereli); --autoplay, --autoplay --mobile, --autoplay --full; ui_shots.gd (-- --out=KLASÖR [--mobile] [--state] [--lang=en]); ölçüt probe .claude/skills/balance-check/probe_template.gd. Başsız testler arayüzü denetlemez: her dilim sonunda ui_shots'ı Türkçe + --lang=en, masaüstü + mobil çek, PNG'leri aç ve gözle kontrol et (taşma, kırpılma, karışık dil, tıklama yutan Control).

## Git
Commit'e KATMA: .mcp.json, .cursor/, export_presets.cfg, project.godot (editör yeniden kaydetmiş olabilir; dokunma), BECKETT_SETUP.md, CLAUDE.md, dist/, art/portraits/PROMPTS.md, art/portraits/overview.png(.import), tools/*.uid dışındaki kullanıcı dosyaları. Yalnızca kendi dosyalarını tek tek `git add`. Godot --import portları 8772 yaparsa 8770'e geri al.

## Dilimler
**U1 — Kişi şeridi + Divan çekmecesi (masaüstü).** `strip_ids() -> Array` saf fonksiyon (Sim'e bağımlı olmayan, test edilebilir): öncelik (1) bekleyen karardaki danışmanlar, (2) bu hafta raporu/tavrı değişenler (week_changes), (3) komplo/şüphe işareti görülenler, (4) seçili kişi, (5) son eylem yapılan; kalanı çekirdek 5 (Arden, Vale, Veyra, Sarne, Prens) ile tamamla; en çok 5, tekrar yok, seçili kişi her zaman içeride; ilk 3 hafta (yol gösterici açıkken) çekirdek 5 sabit. Şerit: sağ sütun üstünde "İZLEME LİSTESİ" (en: Watchlist), 5 portre + ad + rozet noktası, sonunda "+N Divan" karosu. Divan: `game/ui/divan_view.gd`, sağdan kayan çekmece (0,18 sn; `_fast()` ise anında), SHADE örtü, 4 katlanır grup (Hanedan: Helena, Prens Marcus, Valerius; Devlet: Arden, Vale, Veyra, Renn; Güç ve kamuoyu: Sarne, Sarn, Voss; Dış ilişkiler: Varos, Duvall, Malenkov, Lucien + "Dışişleri Bakanı'nın raporu" notu), kart tıklanınca çekmece kapanır ve kişi seçilir, Esc/dış tıklama kapatır. Mevcut 14 kartlık ızgarayı kaldırma; kapsayıcıyı değiştir. Birim testi (sim_test ya da yeni tests/ui_logic_test.gd): strip_ids kuralları. KAPI: tüm testler; autoplay x3; ölçüt probe birebir aynı; TR+EN masaüstü ekran görüntüleri (şerit, Divan açık, kişi seçili).
**U2 — Karar sırası.** Bekleyen kararlar: tek tam kart + altında "Sırada" satırları (başlık + kalan hafta; tıklayınca geçiş; "Karar 1/2" noktalar; ←/→). Danışman görüşü tek satır (mini portreler + "II'yi öneririm · bence III (çıkarı var)"), "Gerekçeler" ile tam alıntılar açılır. KAPI: aynı testler + ekran görüntüleri; 2 ve 3 bekleyen karar durumları.
**U3 — Değişenler ve seçime bağlı blok.** Rapor listesi "Bu hafta değişenler": önce değişenler, ilk 4 + "Tüm raporlar (N)" (mevcut liste çekmece/kaplamada); "Geçen haftadan beri" sol sütundan buraya taşınır (aynı veri, tek yer); seçim yokken eylem/bilgi bloğu kapalı (tek satır ipucu), seçince şeridin altında kişi bloğu açılır (mevcut çipler/eylem sekmeleri/düğmeler AYNEN); "×"/Esc seçimi kaldırır. Üst şerit: bildirim > haber > ipucu tek satırda. KAPI: aynı + "seçim yok / seçili / düşman kişi" ekran görüntüleri.
**U4 — Mobil.** Sekmeler Gündem · Kişiler · Raporlar; Kişiler'de grup sekmeleri (Hanedan | Devlet | Güç | Dış), yatay kaydırmalı portre şeridi (iki yanda ok), altında kişi bloğu ve >= 44 px eylem düğmeleri; Gündem'de U2 düzeni. KAPI: 1067x600'de taşma yok (TR+EN), autoplay --mobile, ui_input_test mobil.

Kabul ölçütleri tasarım belgesinde ("Kabul ölçütleri"). Dilim sonunda: tüm test çıktıları, --full satırı, ölçüt probe (tr ve en), ekran görüntüsü yolları ve neleri gözle kontrol ettiğin, açık sorunlar; ilerleme dosyasında SIRADAKİ DİLİM'i güncelle.
