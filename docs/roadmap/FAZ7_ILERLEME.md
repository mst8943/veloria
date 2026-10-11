# Faz 7 ilerleme

## DALGA R1 — Ekonomi ve bütçe

R1'in a–e parçaları tamamlandı. Başlangıç economy metrikleri, eski kayıt göçü ve Maliye raporu; çeyreklik dört bütçe yaklaşımı ve gecikmeli sektör etkileri; azalan getirili Devlet politikaları; borçtan dış baskıya geçiş; Günlük/Divan satırları ve üç ekonomi başarımı eklendi. Özel bütçe dağılımı dört düzenlenebilir pay ve toplam 100 doğrulaması sunuyor. Bütçe kararları ve yeni metinler TR/EN; kriz haber başlığı için ayrıca EN sızıntı regresyon testi var.

| Parça | Commit |
|---|---|
| R1a — göstergeler ve Maliye raporu | `7b23a2a` |
| R1b — çeyreklik bütçe | `64f5d29` |
| R1c — hazine politikaları | `e2c8b51` |
| R1d — borç ve dış baskı | `df8a356` |
| R1e — Günlük/Divan, başarımlar ve kalibrasyon | `be22c77` |
| EN kriz başlığı sızıntı düzeltmesi | `70de806` |
| Özel dağılım düzenleyicisi ve mobil test | `4a3bf7c` |

### Kapılar

- `--full --seed=101`: TR ve EN'de 104 hafta / TAHTTA / Medya Rejimi / 112 olay.
- 80 oyun/zorluk ölçüt botu: Kolay 61/80, Normal 31/80, Zor 14/80; tabanın ±8 puanı içinde. Uç botların hiçbiri kendi ölçüt tavanını (%70) aşmadı. Probe tablosu ve ayarlar tasarım belgesinin sonundaki **R1 Ayar** bölümünde.
- `tests/economy_test.gd`, `budget_ui_test.gd` (masaüstü/mobil), `sim_test.gd`, `pacing_test.gd` (en düşük dilim 0,81), `external_crisis_test.gd`, `event_check.gd`, `save_test.gd`, `content_check.gd`, `i18n_check.gd`, `en_leak_test.gd`, `lang_switch_test.gd`, `touch_scroll_test.gd`, `tour_test.gd`, `cutscene_check.gd`, `audio_check.gd`, `ui_logic_test.gd`, `ui_input_test.gd` (masaüstü/mobil), `a11y_test.gd` ve `unit_tests.gd` geçti.
- `tools/i18n_missing.py`: 0 eksik `tr()` kaynağı. `tools/i18n_leak_scan.py` EN UI/oyun dökümünde 3.491 metin taradı, 0 şüpheli.
- EN/TR masaüstü ve mobil ekranları `screenshots/faz7_r1/` altında üretildi ve açılarak kontrol edildi: bütçe kartı, özel dağılım penceresi, Maliye rapor metni ve Devlet eylem düğmeleri okunaklı; masaüstü Divan'da ekonomi satırı görünüyor.

### Bilinen test notu

`tests/daily_card_test.gd` headless çalışmada kart kaydetme adımında uzun süre çıktı üretmeden bekledi; bu R1 kapısı olmadığı için yalnızca başlatılan test süreci durduruldu. Geçen Godot testlerinin kapanışında ObjectDB/resource cleanup uyarıları görülebiliyor.

R1 ilk uygulama oturumunda burada durduruldu; R2 tamamlanma kaydı aşağıdadır. PUSH yapılmadı.

## R1 senaryo kapısı düzeltmesi

R1'in borç baskısı “Boş kasa” senaryosunu Normal'de 12/80'e düşürüyordu. Senaryoya özel başlangıç kamu hazinesi 72 ve borç göstergesi 28 verildi; özel servet 2 ve maliye kapasitesi 28 olarak kaldı. Böylece boş saray kasası duygusu korunurken R1'in yüksek borç kaynaklı dış baskı sarmalı başlamıyor. Varsayılan senaryoya etkisi yok.

| Senaryo | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Darbeye açık krallık | 51/80 | 21/80 | 18/80 |
| Naiplik | 49/80 | 24/80 | 21/80 |
| Boş kasa | 35/80 | 22/80 | 20/80 |

Commit: `5862e0c` (`fix: tune empty treasury scenario for R1 debt`). `tests/scenario_test.gd`: OK.

## DALGA B — R2 Kamuoyu ve meşruiyet

Rıza ve korku gizli kayda eklenip ayrı `public_rng` ile anket kaynağı yanlılığı/risk ayrıldı. Oyuncu görünürlük eylemlerinden birini seçince R2 devreye girer; böylece eski kampanyaların RNG ve hafta akışı aynı kalır. Sekiz haftada bir Sarne, Leyla veya bağımsız kurumun nitel bantta sonuç veren anket kartı çıkar. Kamuya açılmış kral sırları için inkâr, özür, kurban bulma ve gündem değiştirme yanıtları bir kez kullanılabilir. Divan'da sayı göstermeyen kamuoyu satırı var. Kayıt sürümü 15'e çıktı ve eski kayıt göçü eklendi.

| Mantıksal adım | Commit |
|---|---|
| R2 durum alanları, ayrı RNG, anket ve kayıt göçü | `b678808` |
| Kamuoyu eylemleri, Divan satırı, skandal yanıtları ve TR/EN metinler | `50847ee` |
| Sadece görünür ol / sürekli gizlen botları için ölçüm | `d5384bf` |
| Korku/rıza kaybı kalibrasyonu, tek kullanımlık skandal yanıtı ve test | `d79c83e` |
| Eski muhalefet finansmanı dosyası İngilizce sızıntı düzeltmesi/regresyon | `06b3f5e` |

### R2 denge ve kapı sonuçları

80 kampanya/zorluk, ölçüt botu `advice_weighted`; görünürlük botları her hafta bir mesaiyi kamuoyu hamlesine ayırır:

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Ölçüt (`advice_weighted`) | 61/80 | 31/80 | 14/80 |
| Hep halka çık (`public_out`) | 23/80 | 15/80 | 1/80 |
| Hep gizlen (`public_hide`) | 0/80 | 0/80 | 0/80 |

Ölçüt R1 tabanı 61/31/14 ile aynı. R2'nin iki tek yönlü stratejisi de tek başına kazanma yolu olmadı. `--full --seed=101`, TR ve EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. Tempo: en düşük 8 haftalık dilim 0,81 olay/hafta; en kötü olaysız seri 3 hafta.

### R2 doğrulama

`tests/*.gd` içindeki 30 dosya tek tek çalıştırıldı; hepsi exit 0. `daily_card_test.gd` pencereli modda `DAILY CARD: OK`; `scenario_test.gd` bütün senaryo/zorluk koşularıyla `SCENARIO: OK`; `public_opinion_test.gd`, `sim_test.gd`, `save_test.gd` ve diğerleri geçti. `content_check` ve `event_check` TR/EN; `ui_input_test` masaüstü/mobil çalıştırıldı. `tools/i18n_missing.py`: 0. EN masaüstü dökümü, mobil dökümü ve oyun metni dökümü: 4.320 metin tarandı, şüpheli 0.

EN/TR masaüstü ve mobil R2 ekranları `screenshots/faz7_r2/` altında üretildi ve açılarak kontrol edildi: `r2_visibility_actions`, `r2_poll_card`, `r2_scandal_response` (mobilde ek olarak `r2_scandal_response_lower`). Metin dili, nitel anket bandı, eylem seçenekleri, dört skandal yanıtı ve mobil 44 px düğme yüksekliği kontrol edildi; görünür taşma/sızıntı yok.

Bilinen test notu: Bazı Godot testleri exit 0 ile tamamlanırken kapanışta ObjectDB/resource cleanup uyarıları yazıyor. PUSH yapılmadı.

## DALGA R3 — R3a: Bloklar ve kanun teklifleri

Dört gizli meclis bloğu (Saray listesi, Muhalefet, Soylular, Bağımsızlar) eklendi; muhalefet ve patronaj blok sadakati/baskısından besleniyor. Yaklaşık 10 haftada bir altı teklif türünden biri açılıyor. Destekleme, değiştirme, geri çekme ve baskıyla geçirme kararları var; sonuçlar ayrı `parliament_rng` ile belirleniyor. Haftalık kayıt, Günlük ve Divan nitel rapor veriyor, kesin oy sayısı göstermiyor. Kayıt sürümü 16; eski kayıtların muhalefeti korunup bloklar ve ayrı üreteç göç sırasında başlatılıyor. R3b yasa etkileri ve R3c seçim/güven oyu bu dilimin kapsamında değil.

| Mantıksal adım | Commit |
|---|---|
| R3a mekaniği, kayıt göçü, metin ve test | `37a4b26` |
| R3a masaüstü/mobil rapor sunumu | `7daa7ba` |
| R3a ayar tablosu ve ilerleme kaydı | bu dokümantasyon commit'i |

### Denge ve kapılar

80 kampanya/zorluk; ölçüt hedefi 62/30/13, sonuç tablosu ve uç botlar tasarım belgesinin sonundaki **R3a Ayar** bölümünde. Ölçüt 60/30/13 (fark −2,5/0/0 yüzde puan); baskıyla geçir 43/9/6, geri çek 41/7/4, hiç oy verme 33/5/1. Üç uç bot da ölçüt kazanma tavanının %70 altında. Tempo en düşük 0,81 olay/hafta, en uzun olaysız seri 3.

`--full --seed=101` TR/EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. EN kaçak taraması 4.532 metinde 0 şüpheli, `tools/i18n_missing.py`: 0. `tests/parliament_test.gd`, `sim_test.gd`, `pacing_test.gd`, `economy_test.gd`, `external_crisis_test.gd`, `scenario_test.gd`, `daily_card_test.gd`, `save_test.gd`, `public_opinion_test.gd`, `dynasty_test.gd`, `legacy_test.gd`, `endless_test.gd`, UI/giriş/erişilebilirlik testleri, `unit_tests.gd`, içerik/olay dil kontrolleri çalıştırıldı. `ux_audit.gd` ekran görüntüsü yığını üreteceği için, `cause_probe.gd` tanı aracı olduğu için çalıştırılmadı. Godot kapanışında bazı testlerde ObjectDB/resource cleanup uyarısı var.

EN/TR masaüstü ve mobil teklif, günlük rapor ve Divan rapor ekranları incelendi: dört teklif seçeneği görünür, mobil düğmeler 44 px, rapor dili çevrilmiş ve oy sayısı yok. Mobilde ayrı Divan çekmecesi bulunmadığından mobil “Divan raporu” kontrolü Günlük rapor görünümünden yapıldı; mobil Divan penceresi hâlâ açık bir UI kapsamıdır. Ekran görüntüleri kontrol sonrası geçici dizinden silindi.

Bu dilimde baskıyla geçirme huzursuzluğu 100'e taşır ve kral gücünü 14 azaltır; seçenek özellikle pahalıdır. PUSH yapılmadı.
