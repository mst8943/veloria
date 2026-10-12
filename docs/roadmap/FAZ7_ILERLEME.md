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
## DALGA R3 — R3b: Kalıcı yasa etkileri

R3a tekliflerinin geçmesi artık yasayı yürürlüğe sokuyor. Basın, ordu bütçesi, vergi, erken seçim, af ve yargı yasalarının kalıcı etkileri eklendi. Oyuncu yürürlükteki yasaları Günlükte ve Divan'da nitel olarak görür; 26 haftalık gözden geçirmede bedel ödeyerek bir yasayı kaldırabilir. Kayıt sürümü 17; sürüm 16 ve öncesi yasa defterini boş başlatır. Meclis sonuçları mevcut ayrı `parliament_rng` ile sürer. R3c seçimi/güven oyu uygulanmadı.

| Mantıksal adım | Commit |
|---|---|
| Yasa etkileri, kayıt göçü, kaldırma kararı, kuvvetli baskı eşiği ve testler | `e49f370` |
| Günlük/Divan listesi, EN metinleri ve ekran kontrol yardımcısı | `ca1c3e1` |
| Probe ayarı ve ilerleme kaydı | bu dokümantasyon commit'i |

### Kapılar ve denge

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Ölçüt (advice_weighted) | 56/80 | 33/80 | 19/80 |
| Hep baskıyla geçir | 39/80 | 13/80 | 6/80 |
| Hep geri çek | 41/80 | 7/80 | 4/80 |
| Hiç oy verme | 33/80 | 5/80 | 1/80 |

Ölçüt hedefi 62/30/13; fark −7,5/+3,75/+7,5 yüzde puan. %70 hedef tavanı 43,4/21/9,1; uç botlar altında. `pacing_test.gd`: en düşük 0,81 olay/hafta, en uzun olaysız seri 3 hafta. `--full --seed=101` TR ve EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay.

Geçen testler: `save_test`, `sim_test`, `pacing_test`, `economy_test`, `external_crisis_test`, `scenario_test`, `public_opinion_test`, `dynasty_test`, `legacy_test`, `endless_test`, `parliament_laws_test`, `parliament_test`, `content_check` (TR/EN), `event_check` (TR/EN), `i18n_check`, `lang_switch_test`, `ui_logic_test`, `unit_tests` (399), `en_leak_test` (5 kampanya, 0 sızıntı), `audio_check`, `cutscene_check`, `daily_card_test`, `budget_ui_test` (masaüstü/mobil), `ui_input_test` (masaüstü/mobil), `touch_scroll_test`, `a11y_test` ve `tour_test`. `tools/i18n_missing.py`: 0. EN/TR masaüstü ve mobil yasa kartı/listesi gözle incelendi; metinler çevrilmiş, görünür taşma yok. Bazı Godot testlerinin kapanışında ObjectDB/resource cleanup uyarıları var; testler exit 0.

`tests/title_shot.gd` bu oturumda çalıştırılmadı; `ux_audit.gd` ekran görüntüsü yığını oluşturacağı için çalıştırılmadı. `cause_probe.gd` tanı aracıdır, kapı değildir. PUSH yapılmadı; R3c yapılmadı.

## DALGA R3 — R3c: Seçim ve güven oyu

Mevcut `secim_sonucu` olayı artık ayrı `government_rng` ile rıza, ekonomi, huzursuzluk, yasa geçmişi ve açık skandallardan nitel blok değişimi üretir; kesin oy/sandalye sayısı yoktur. Sonuç, farklı maliyetleri olan üç hükümet kurma kararına bağlanır. Veyra'nın koalisyon desteği kaybolunca destekle / hükümeti düşür / bedelli baskıyla kurtar güven oyu kartı çıkar. Hükümet düşerse Veyra, Kraliçe Helena veya Brandt için başbakan atama kararı gelir. Helena geçici mali rapor kaynağı olur; R1 bütçe akışı devam eder. Günlük ve Divan satırları hükümet/koalisyonu ve mali rapor sorumlusunu bildirir. Üç başarım eklendi. Kayıt sürümü 18; v17 ve eski kayıtlar için göç adımı var.

| Mantıksal adım | Commit |
|---|---|
| Seçim, hükümet/güven oyu, mali rapor devri, kayıt göçü, TR/EN ve test | `7fd4955` |
| Ölçüm botları ve seçim/güven oyu görüntü kapısı | `4ea1b6e` |
| R3c ölçüm tablosu ve ilerleme notu | bu dokümantasyon commit'i |

### Denge ve kapılar

Ölçüt `advice_weighted`, 80 kampanya/zorluk: Kolay 62/80, Normal 31/80, Zor 17/80; hedef 62/30/13 sapması 0/+1/+4, ±4 kapısında. `confidence_force`: 38/10/3; `confidence_fall`: 37/11/3; `parliament_abstain`: 29/10/4. Ölçütün %70 tavanı her zorlukta 43,4/21,7/11,9; üç bot da tavan altında. `pacing_test.gd`: ilk 8 haftada 0,81 olay/hafta, en uzun olaysız seri 3.

`--full --seed=101` TR ve EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. `tests/en_leak_test.gd`: 5 kampanyada 0 benzersiz sızıntı; `tools/i18n_missing.py`: 0. `tests/election_test.gd`: seçim RNG/faktörleri, erken seçim eşiği, karar akışı, güven oyu maliyeti/izleri, rapor devri, R1 bütçe akışı, eski kayıt göçü ve başarımlar OK.

Geçen testler: `a11y_test`, `audio_check`, `budget_ui_test`, `content_check`, `cutscene_check`, `daily_card_test`, `dynasty_test`, `economy_test`, `election_test`, `endless_test`, `en_leak_test`, `event_check`, `external_crisis_test`, `i18n_check`, `lang_switch_test`, `legacy_test`, `pacing_test`, `parliament_laws_test`, `parliament_test`, `public_opinion_test`, `save_test`, `scenario_test`, `sim_test`, `touch_scroll_test`, `tour_test`, `ui_input_test`, `ui_logic_test`, `unit_tests` (399 kontrol). `content_check` 5 dosya/8 bozuk örneği hata vermeden yakaladı; `event_check` 201 olayı 0 uyarıyla geçti. `daily_card_test` pencereli modda `DAILY CARD: OK` verdi. Bazı Godot testleri kapanışta ObjectDB/resource cleanup uyarıları yazdı, exit kodları 0.

EN ve TR masaüstü/mobil ekranlarında seçim sonucu, hükümet kurma ve güven oyu kartlarının 12 görüntüsü açılarak incelendi. Sonuçta sayısal oy/sandalye yok; hükümette üç seçenek; güven kartında üç karar ve bedelli baskı seçeneği okunur, taşma görülmedi. Ekran görüntüleri doğrulama sonrasında geçici klasörden silindi. `tests/title_shot.gd` ve `game/ui/title_screen.gd` değiştirilmedi; `ux_audit.gd` görüntü yığını üreteceğinden çalıştırılmadı. `cause_probe.gd`, `en_dump.gd` ve `en_dump2.gd` tanı/döküm araçları olduğu için çalıştırılmadı. PUSH yapılmadı; R4'e geçilmedi.


Test notu: daily_card_test.gd ilk kez headless çalıştırıldığında beklemede kaldı; pencereli tekrar DAILY CARD: OK verdi ve 2099 tarihli test kaydı temizlendi. İlk denemeden önce var olan günlük sonuç kontrol edilmediğinden, önceki bir günlük kaydı varsa geri yüklenememiş olabilir.


## DALGA R4 — R4a: Bölge verisi ve raporlar

R4a tamamlandı; R4b ve R4c'ye geçilmedi. Eklendi: Başkent, Sanayi Kuşağı, Tarım Ovaları ve Sınır İlleri için gizli huzursuzluk/bağlılık/ekonomi, ağırlıklar %35/%30/%22/%13 ve her bölgeye supporting çevresel vali. Ulusal huzursuzluk ile ekonomi bu bölgelerin ağırlıklı özeti; yerel sapmalar `region_rng` kullanır ve ana RNG akışını tüketmez. Kayıt v19; v18 göçü eski ulusal değerleri korur. Günlük ve Divan'da nitel bölge satırı, Divan'ın Devlet grubunda vali kartları, mobilde ayrı Divan çekmecesi bulunur. R4a'da yatırım eylemi yoktur.

| Mantıksal adım | Commit |
|---|---|
| Cila: görselsiz kart boşluğu | `fef32d5` |
| Cila: hanedan defteri sarım/kaydırma | `1654714` |
| Cila: suikast kartı görseli | `c26ee58` |
| Bölge durumu, v19 göçü, ayrı RNG, vali aktörleri ve test | `d31efff` |
| Günlük/Divan bölge raporu, vali kartları ve mobil Divan | `c940fe1` |
| Vali kırmızı çizgileri EN çevirisi ve kaplama şema uyumu | `8805050`, `33f8cc5` |
| R4a ölçümleri, kapılar ve gözlem notları | bu dokümantasyon commit'i |

### Ölçüm ve kapılar

`advice_weighted`, 80 kampanya/zorluk; hedef 62/30/13, ±4 kampanya kapısı:

| Ölçüt | Kolay | Normal | Zor | Hedeften fark |
|---|---:|---:|---:|---:|
| Ölçüt botu | 62/80 | 31/80 | 17/80 | 0 / +1 / +4 |

Yatırım kararları R4b'ye bırakıldığı için tek bölge yatırım / hiç yatırım botları bu dilimde çalışmıyor; dört bölgenin yatırım sayacı 0 kaldı (`regions_test.gd`). Tempo: ilk 8 haftada 0,81 olay/hafta; en uzun olaysız seri 3 hafta. TR ve EN `--full --seed=101`: 104 hafta / TAHTTA / Medya Rejimi / 112 olay.

Geçen testler (her biri exit 0): `a11y_test`, `audio_check`, `budget_ui_test`, `content_check`, `cutscene_check`, `daily_card_test`, `dynasty_test`, `economy_test`, `election_test`, `endless_test`, `en_leak_test`, `event_check`, `external_crisis_test`, `i18n_check`, `lang_switch_test`, `legacy_test`, `pacing_test`, `parliament_laws_test`, `parliament_test`, `public_opinion_test`, `regions_test`, `save_test`, `scenario_test`, `sim_test`, `touch_scroll_test`, `tour_test`, `ui_input_test`, `ui_logic_test`, `unit_tests` (399 kontrol). `en_leak_test`: 5 kampanyada 0 kaçak; EN metin dökümü 3.623 metinde `i18n_leak_scan.py`: 0 şüpheli; `i18n_missing.py`: 0. İçerik kapısı 5 dosya/8 bozuk örneği doğru saptadı; olay kapısı 201 olay/0 uyarı.

EN/TR masaüstü ve mobil görüntülerde Günlük bölge satırı ve Divan raporu/vali kartları açılıp incelendi. Bölge alanları nitel, sayısal değer yok; rapor satırları sarılıyor, kartlar ekrana sığıyor. Mobil kişi ekranındaki yinelenen yardım satırı kaldırıldı. Cila bekleyen dört konu tamamlandı. Godot kapanışında bazı süreçler ObjectDB/resource cleanup uyarısı yazdı, ancak test ve tam koşu çıkış kodları başarılıydı. Ekran görüntüleri kontrol sonrası geçici klasörden silindi. `tests/title_shot.gd` ve `game/ui/title_screen.gd` değişmedi. PUSH yapılmadı; R4b/R4c'ye geçilmedi.

## DALGA R4 — R4b: Kararlar ve bölgesel krizler

R4b tamamlandı. Bölge yönetimi, oyuncunun Devlet eyleminden isteğe bağlı karar olarak açılıyor; bölge seçiminin ardından yatırım, garnizon, yerel medya, vali atama/azli seçenekleri geliyor. Yatırım sanayi bütçesi, garnizon ordu bütçesi, yerel medya sosyal bütçesi ve hazineye bağlı; hepsi bir mesai harcıyor. Yatırım/pazar, garnizon/sükûnet ve medya/bağlılık etkileri gecikmeli uygulanıyor. Vali atama ve azli hazine, Saray listesi/soylular blokları, kraliyet otoritesi ve patronaj göstergelerine bedelli etki ediyor. Grev, kıtlık, sınır gerilimi ve başkent karışıklığı yerel eşiklerde yalnız `region_rng` kullanıyor; sınır krizi Drakon baskısı ve mevcut dış kriz akışına bağlandı. Yeni gizli alanlar ve eylem/kriz sayaçları için kayıt v20 göçü eklendi; TR/EN içerik ve üç bölge başarımı eklendi.

| Mantıksal adım | Commit |
|---|---|
| Bölgesel kararlar/krizler, v20 göçü, TR/EN, test ve ölçüm botları | `fd8a5ec` |
| Bölge satırı, vali kartı paleti ve masaüstü Divan cila düzeltmeleri | `23d6490` |
| Ölçüm/ilerleme/gözlem belgeleri | bu dokümantasyon commit'i |

### Denge ve diğer kapılar

80 kampanya/zorluk; R4b sonrası taban 62/31/17 ve kapı ±3:

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Ölçüt (`advice_weighted`) | 60/80 | 29/80 | 17/80 |
| Tek bölge yatırım (`region_invest_one`) | 7/80 | 1/80 | 0/80 |
| Hiç bölge yatırımı (`region_invest_none`) | 14/80 | 1/80 | 1/80 |
| Garnizon yalnız başkentte (`region_garrison_capital`) | 17/80 | 1/80 | 0/80 |

Ölçüt sapması yüzde puan olarak −2,5/−2,5/0; hedef bandında. Uç botların hepsi kendi ölçütünün %70 tavanının altında. `pacing_test`: ilk sekiz haftada 0,81 olay/hafta, en uzun olaysız seri 3 hafta. TR/EN `--full --seed=101`: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. `en_leak_test`: 5 kampanya, 0 sızıntı; `i18n_missing.py`: 0 eksik `tr()` kaynağı.

### Test çıktıları

Tüm test süreçleri exit 0 ile bitti. Tablodaki satırlar testlerin birebir başarı çıktılarıdır; Godot kapanış uyarıları ayrıca aşağıda belirtilmiştir:

| Test | Son çıktı satırı |
|---|---|
| `a11y_test` | `A11Y: OK` |
| `audio_check` | `AUDIO: OK` |
| `budget_ui_test` | `BUDGET UI: OK` |
| `content_check` | `CONTENT: OK (5 dosya, 8 bozuk örnek)` |
| `cutscene_check` | `CUTSCENE: OK` |
| `daily_card_test` | `DAILY CARD: OK` |
| `dynasty_test` | `DYNASTY: OK` |
| `economy_test` | `ECONOMY: OK` |
| `election_test` | `ELECTION: OK` |
| `endless_test` | `ENDLESS: OK` |
| `en_leak_test` | `EN LEAK SCAN: 5 campaigns, 0 unique leaks` |
| `event_check` | `EVENTS: OK (201 olay, 0 uyarı)` |
| `external_crisis_test` | `EXTERNAL CRISIS: OK` |
| `i18n_check` | `I18N: OK` |
| `lang_switch_test` | `LANG: OK` |
| `legacy_test` | `LEGACY: OK` |
| `pacing_test` | `En uzun olaysız seri (medyan / en kötü): 2 / 3 hafta` |
| `parliament_laws_test` | `PARLIAMENT LAWS: OK` |
| `parliament_test` | `PARLIAMENT: OK` |
| `public_opinion_test` | `PUBLIC OPINION: OK` |
| `regions_test` | `REGIONS: OK` |
| `save_test` | `SAVE: OK` |
| `scenario_test` | `SCENARIO: OK` |
| `sim_test` | `TEST: OK` |
| `touch_scroll_test` | `TOUCH: OK` |
| `tour_test` | `TOUR: OK` |
| `ui_input_test` masaüstü | `UI INPUT: OK` |
| `ui_input_test` mobil (`-- --mobile`) | `UI INPUT: OK (mobile)` |
| `ui_logic_test` | `UI LOGIC: OK` |
| `unit_tests` | `[unit] all 399 checks passed` |

Godot bazı kapanışlarda RID/ObjectDB/resource temizleme uyarıları bastı (özellikle `a11y_test`, `regions_test` ve mobil `ui_input_test`); bu uyarılara rağmen her süreç exit 0 ve yukarıdaki sonuç satırı başarılıydı. `tools/i18n_missing.py`: `0 tr() kaynağı en.po'da yok`.

### Ekran ve ürün gözlemi

EN/TR masaüstü ve yatay mobil ekran görüntüleri açılıp kontrol edildi: bölge seçimi, yatırım/garnizon/medya kararı, bölgesel kriz, vali azli ve vali ataması. Metin sarımı, görünür seçenekler, kriz çerçevesi, EN/TR uzunluk farkı ve 1067×600 yerleşim kontrol edildi; taşma yok. Vali azli ve ataması için görüntü yardımcısının aynı dosyaya yazması düzeltilip dosya adları ayrıldı. R4a'nın tekdüze/uzun Günlük satırı, vali kartı renkleri ve Divan yüksekliği düzeltildi. Ertelenen: vali adaylarına ayrı sanatsal portre kimliği ve gerçek oyuncu oturumlarında bölgesel medya/atama akışının anlaşılabilirlik ölçümü. Ekran görüntüleri ve probe logları kontrol sonrası `C:\temp\veloria_r4b` içinden temizlenecek.

`tests/title_shot.gd` ve `game/ui/title_screen.gd` değiştirilmedi. PUSH yapılmadı. R4c'ye geçmeden önce R4a/R4b geçmişi `git log` ile denetlenmeli.

## R4c — Harita katmanı (2026-10-12)

R4a/R4b önkoşul commit'leri `git log` ile doğrulandı. Haritaya katman aç/kapa, renk kullanmadan üçgen/çubuk/kalkan durum simgeleri, kriz/vali işaretleri ve aynı öne çıkan bölge için yıldız eklendi. Bölge paneli nitel durumu, vali portresini ve mevcut R4b eylemlerini gösteriyor; tek tık karar kartını açıyor. Bina tıklamaları korundu. Panel açıkken arkada kalan harita işaretçileri gizlenip kapanışta geri geliyor. R4c yalnızca görünüm/harita gezinmesi ekledi; `--full --seed=101` değişmedi.

### Denge ve içerik kapıları

R4c için özel 80 kampanyalık `advice_weighted` probe'u tekrar çalıştırılmadı; son gerçek ölçüm R4b'nin 60/29/17 sonucu. Bu sunum değişikliğinde simülasyon/kriz/RNG kodu değişmedi, bu yüzden önceki ölçüm karşılaştırma tabanı olarak korundu (fark 0/0/0; ölçüm yeniden üretimi açık iş). Rapor bu farkı gizlemez.

TR ve EN `--full --seed=101`: her ikisi de **104 hafta / TAHTTA / Medya Rejimi / 112 olay**. Tempo R4b ölçümüyle aynı; `pacing_test` ilk 8 haftada 0,81 olay/hafta, en uzun olaysız seri 3 hafta verdi. `en_leak_test`: 5 kampanya, 0 benzersiz sızıntı. EN dökümleri `DUMP 881`, `DUMP2 2752`; `tools/i18n_leak_scan.py`: `TARANAN 3633 metin, ŞÜPHELİ 0`; `tools/i18n_missing.py`: `0 tr() kaynağı en.po'da yok`.

### Test kapıları

| Test | Başarılı çıktı satırı |
|---|---|
| `a11y_test` | `A11Y: OK` |
| `audio_check` | `AUDIO: OK` |
| `budget_ui_test` | `BUDGET UI: OK` |
| `content_check` | `CONTENT: OK (5 dosya, 8 bozuk örnek)` |
| `cutscene_check` | `CUTSCENE: OK` |
| `daily_card_test` | `DAILY CARD: OK` |
| `dynasty_test` | `DYNASTY: OK` |
| `economy_test` | `ECONOMY: OK` |
| `election_test` | `ELECTION: OK` |
| `endless_test` | `ENDLESS: OK` |
| `en_leak_test` | `EN LEAK SCAN: 5 campaigns, 0 unique leaks` |
| `event_check` | `EVENTS: OK (201 olay, 0 uyarı)` |
| `external_crisis_test` | `EXTERNAL CRISIS: OK` |
| `i18n_check` | `I18N: OK` |
| `lang_switch_test` | `LANG: OK` |
| `legacy_test` | `LEGACY: OK` |
| `pacing_test` | `En uzun olaysız seri (medyan / en kötü): 2 / 3 hafta` |
| `parliament_laws_test` | `PARLIAMENT LAWS: OK` |
| `parliament_test` | `PARLIAMENT: OK` |
| `public_opinion_test` | `PUBLIC OPINION: OK` |
| `region_map_test` masaüstü | `REGION MAP: OK` |
| `region_map_test` mobil | `REGION MAP: OK` |
| `regions_test` | `REGIONS: OK` |
| `save_test` | `SAVE: OK` |
| `scenario_test` | `SCENARIO: OK` |
| `sim_test` | `TEST: OK` |
| `touch_scroll_test` | `TOUCH: OK` |
| `tour_test` | `TOUR: OK` |
| `ui_input_test` masaüstü | `UI INPUT: OK` |
| `ui_input_test` mobil (`-- --mobile`) | `UI INPUT: OK (mobile)` |
| `ui_logic_test` | `UI LOGIC: OK` |
| `unit_tests` | `[unit] all 399 checks passed` |

### Ekran ve ürün gözlemi

EN/TR masaüstü ve 1067×600 mobilde katman kapalı/açık, bölge paneli/vali kartı ve kriz kartı görüntüleri ayrı üretildi, açıldı ve gözle kontrol edildi. Harita arka planı/kurumlar, sembollerin renk dışı ayrımı, nitel rapor, portre, çevrilen metin, mobil kaydırma ve birincil 48 px karar düğmesi kontrol edildi. Görüntü ve dump dosyaları incelemeden sonra geçici klasörden silindi.

Beckett `ui_snapshot` çalışan masa görünümünde 150 görünür denetim taradı; iki `occluded_by` kaydı rapor metninin kendi kart paneli altında kalmasıydı. Lite oturumunda harita ekranı açılamadığından bu araçla harita katmanına özel snapshot alınamadı. Bunun yerine `region_map_test` iki çözünürlükte işaretçi-kurum çakışmasını ve tıklamaları denetledi; panel aç/kapa görünürlüğü, Parlamento tıklaması ve simülasyon durumunun değişmediği de test edildi.

Gözlemlerde mobilde 4 px kurum çakışması, panel arkasında kısmi işaretçi görünmesi, vali satırında gereksiz dikey boşluk ve ana karar düğmesinin ilk ekranda kalmaması düzeltildi. Ayrıntılı küçük/bekleyen maddeler `docs/roadmap/GOZLEMLER.md` içinde. Kod commit'i `844f6bc` (`Add regional map layer and panel`). R5'e geçilmedi; PUSH yapılmadı; `tests/title_shot.gd`, `game/ui/title_screen.gd` ve `art/` değiştirilmedi.

## 2026-10-12 — R5a Ordu iç yapısı

R4a/R4b/R4c ve cila commit'leri `git log` ile doğrulandı. R5a ayrı kod commit'i `a8ca5d2` (`Add army units and commanders`) olarak eklendi; R5b/R5c'ye geçilmedi. Üç birliğin sadakati, morali ve ikmali gizli tutuluyor; birlik komutanları çevresel aktörler ve `army_rng` ile ana RNG'den ayrılıyor. Arden'in mevcut gücü birlik sadakatlerinin ortalamasından türetiliyor. v20 kayıtları v21'e göçerken her birliğe eski Arden değeri atanıyor, böylece eski güç korunuyor. Günlük ve Divan aynı nitel, sayısız birliği raporluyor; yalnızca öne çıkan/endişe verici birlik vurgulanıyor.

### Kapılar

`advice_weighted` 80 kampanya ölçümü R4b tabanını aynen korudu (Kolay 60/80, Normal 29/80, Zor 17/80; fark 0/0/0). ±3 kapısı ve varsayılan denge şartı sağlandı. Fazın ayrıca istediği `Zor ≤ 16` hedefi 17/80 ile bir galibiyet farkla kaçtı; R5a'da ordu eylemi olmadığı ve dengeyi kaydırmama kuralı bulunduğu için yapay ayar yapılmadı. Ordu ödeneği/komuta bölme uç botları R5a'da eylem bulunmadığından uygulanamaz; R5b'ye bırakıldı.

`--full --seed=101` çıktısı her iki dilde de 104 hafta / TAHTTA / Medya Rejimi / 112 olay. Tempo: ilk sekiz haftada 0,81 olay/hafta (`H  1-  8        0.81        (280)`); en uzun olaysız seri (medyan/en kötü) 2/3 hafta. `en_leak_test`: 5 kampanya, 0 benzersiz sızıntı. `tools/i18n_missing.py`: `0 tr() kaynağı en.po'da yok`.

### Testler

Her test başarılı çıktı satırını verdi. Toplu headless koşuda `daily_card_test` takıldığı için o alt süreç durduruldu; test hemen ardından pencereli ve profil yedeği korumalı tekil koşuda yeniden çalıştırıldı ve geçti. Diğer tüm satırlar toplu koşudaki sonuçlardır.

| Test | Başarılı çıktı satırı |
|---|---|
| `a11y_test` | `A11Y: OK` |
| `army_test` | `ARMY TEST: OK` |
| `audio_check` | `AUDIO: OK` |
| `budget_ui_test` | `BUDGET UI: OK` |
| `content_check` | `CONTENT: OK (5 dosya, 8 bozuk örnek)` |
| `cutscene_check` | `CUTSCENE: OK` |
| `daily_card_test` (pencereli tekil koşu) | `DAILY CARD: OK` |
| `dynasty_test` | `DYNASTY: OK` |
| `economy_test` | `ECONOMY: OK` |
| `election_test` | `ELECTION: OK` |
| `endless_test` | `ENDLESS: OK` |
| `en_leak_test` | `EN LEAK SCAN: 5 campaigns, 0 unique leaks` |
| `event_check` | `EVENTS: OK (201 olay, 0 uyarı)` |
| `external_crisis_test` | `EXTERNAL CRISIS: OK` |
| `i18n_check` | `I18N: OK` |
| `lang_switch_test` | `LANG: OK` |
| `legacy_test` | `LEGACY: OK` |
| `pacing_test` | `H  1-  8        0.81        (280)`; `En uzun olaysız seri (medyan / en kötü): 2 / 3 hafta` |
| `parliament_laws_test` | `PARLIAMENT LAWS: OK` |
| `parliament_test` | `PARLIAMENT: OK` |
| `public_opinion_test` | `PUBLIC OPINION: OK` |
| `region_map_test` masaüstü | `REGION MAP: OK` |
| `region_map_test` mobil | `REGION MAP: OK` |
| `regions_test` | `REGIONS: OK` |
| `save_test` | `SAVE: OK` |
| `scenario_test` | `SCENARIO: OK` |
| `sim_test` | `TEST: OK` |
| `touch_scroll_test` | `TOUCH: OK` |
| `tour_test` | `TOUR: OK` |
| `ui_input_test` masaüstü | `UI INPUT: OK` |
| `ui_input_test` mobil (`-- --mobile`) | `UI INPUT: OK (mobile)` |
| `ui_logic_test` | `UI LOGIC: OK` |
| `unit_tests` | `[unit] all 399 checks passed` |

### Ekranlar ve gözlemler

TR/EN masaüstü ve yatay mobilde Günlük birlik satırı, Divan raporu ve komutan kartlarının 12 ekranı açılıp incelendi. Birlik adı/rapor dili eşleşiyor, gizli sayılar görünmüyor, portresiz kartlarda komutan adları ve rolleri kırpılmıyor. Görüntüler inceleme sonrası silindi. R4b/R4c cila maddeleri ayrı commit'lerle kapatıldı (`7a1c89d`, `ddedf75`, `6e6468d`, `68b80a5`, `4134d48`). Komutanlar için dört ayrı portre gerekiyor; isimler ve üretim promptu `GOZLEMLER.md` içine eklendi. `tests/title_shot.gd`, `game/ui/title_screen.gd` ve `art/` değiştirilmedi; kullanıcı profili testlerden sonra geri yüklendi, kendi Godot test süreçleri kapandı. PUSH yapılmadı.

## 2026-10-12 — M1 Dokunma, arşiv ve test hijyeni

Yalnızca M1 uygulandı; R5b'ye geçilmedi. Dokunmatik giriş `touch_scroll.gd` içinde merkezileştirildi: kısa dokunuş bırakınca etkinleşiyor, 11 px hareket veya 480 ms basılı tutma dokunuşu iptal ediyor, dokunma hover ses/animasyonlarını bastırıyor ve 80 ms sonra hareketle iptal edilen kısa basılı geri bildirim gösteriyor. Masaüstü fare akışı aynı kaldı. `touch_tap_test.gd`, masa nesnesi/harita levhası/haber şeridi/kart yüzeyi, düğme, iptal edilen sürükleme, gecikmeli geri bildirim ve fare davranışını denetliyor.

Hükümdarlık Arşivi yeni kayıtlarda `cause_key`/argüman/plural metadatası saklıyor ve ekranda seçili dile çeviriyor. Anahtar içermeyen eski Türkçe kayıtlar bozulmadan kalıyor; İngilizce görünümde genel bir uyumluluk cümlesi gösteriliyor. Arşivde yeni ve eski kayıt bulunan `en_leak_test` 0 benzersiz sızıntı verdi. `daily_card_test`, kendine ait `user://` günlük yolu ve kart klasörünü kullanıyor; headless kipte rendering backend doku üretmediği için kartı kaydetmeden temiz çıkıyor ve toplu testte takılmıyor. `run_test_isolated.ps1` her testin `APPDATA` profilini geçici alana yönlendirip tamamlanınca temizliyor. Gerçek kullanıcı profilindeki bugünkü sahte saltanat/başarım kayıtlarına dokunulmadı.

Gözlem sırasında EN 1067×600 harita katmanı ekranında “Capital Region” işaretçisi dar alanda kesiliyordu. Ad etiketi mobilde satıra sarıldı; `region_map_test --mobile` bunu denetliyor. Görsel, değişiklikten sonra yeniden açılıp kontrol edildi. Geçici görüntü klasörü silindi.

### Denge ve çalışma sonucu

80 kampanyalık `advice_weighted` ölçümü: Kolay 60/80, Normal 29/80, Zor 17/80 (60/29/17 tabanından fark 0/0/0; ±1 kapısı geçti). Tempo `pacing_test` ilk dilimi 0,81 olay/hafta, en uzun olaysız seri 3 hafta. `--full --seed=101`:

```text
FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true
FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true
```

İlk satır EN, ikinci satır TR çalıştırmasıdır. `tools/i18n_missing.py` çıktısı: `0 tr() kaynağı en.po'da yok`.

### Test çıktıları

Her satır çalıştırılan testin başarılı özet çıktısıdır; pencereli screenshot/dump/diagnostic yardımcıları (title_shot, ui_shots, ux_audit, en_dump, cause_probe) üretilen görüntü yığını kuralı nedeniyle çalıştırılmadı.

| Test | Başarılı çıktı satırı |
|---|---|
| `a11y_test` | `A11Y: OK` |
| `army_test` | `ARMY TEST: OK` |
| `audio_check` | `AUDIO: OK` |
| `budget_ui_test` | `BUDGET UI: OK` |
| `content_check` | `CONTENT: OK (5 dosya, 8 bozuk örnek)` |
| `cutscene_check` | `CUTSCENE: OK` |
| `daily_card_test` | `DAILY CARD: OK` |
| `dynasty_test` | `DYNASTY: OK` |
| `economy_test` | `ECONOMY: OK` |
| `election_test` | `ELECTION: OK` |
| `endless_test` | `ENDLESS: OK` |
| `en_leak_test` | `EN LEAK SCAN: 5 campaigns, 0 unique leaks` |
| `event_check` | `EVENTS: OK (201 olay, 0 uyarı)` |
| `external_crisis_test` | `EXTERNAL CRISIS: OK` |
| `i18n_check` | `I18N: OK` |
| `lang_switch_test` | `LANG: OK` |
| `legacy_test` | `LEGACY: OK` |
| `pacing_test` | `H  1-  8        0.81        (280)`; `En uzun olaysız seri (medyan / en kötü): 2 / 3 hafta` |
| `parliament_laws_test` | `PARLIAMENT LAWS: OK` |
| `parliament_test` | `PARLIAMENT: OK` |
| `public_opinion_test` | `PUBLIC OPINION: OK` |
| `region_map_test` desktop | `REGION MAP: OK` |
| `region_map_test` mobil | `REGION MAP: OK` |
| `regions_test` | `REGIONS: OK` |
| `save_test` | `SAVE: OK` |
| `scenario_test` | `SCENARIO: OK` |
| `sim_test` | `TEST: OK` |
| `touch_scroll_test` | `TOUCH: OK` |
| `touch_tap_test` | `TOUCH TAP: OK` |
| `tour_test` | `TOUR: OK` |
| `ui_input_test` desktop | `UI INPUT: OK` |
| `ui_input_test --mobile` | `UI INPUT: OK (mobile)` |
| `ui_logic_test` | `UI LOGIC: OK` |
| `unit_tests` | `[unit] all 399 checks passed` |

Headless Godot bazı UI testleri kapanırken RID/ObjectDB temizleme uyarıları verdi; test çıkış kodları 0 ve özet satırları başarılıydı. `a11y_test` anlık `main.free()` ile motoru düşürüyordu; ağaçtan `queue_free()` edip bir kare bekleyecek şekilde düzeltilince çıkış kodu 0 oldu.

### Gözlemler

Dokunmatik giriş ve İngilizce arşiv sızıntısı R5a'da raporlanan biçimde giderildi. Eski `cause_key` içermeyen arşiv kayıtlarının İngilizcede ayrıntılı sebebi henüz çözümlenemiyor; kayıt korunuyor, İngilizcede genel uyumluluk cümlesi gösteriliyor (orta, gelecekte arşiv şeması çalışması). Komutan portreleri (4 isim + prompt) sanat işi olduğundan M1 dışında bırakıldı; `art/` değiştirilmedi. Boşluk dışı dokunmayla başkent kurum çekmecesini kapatma ve masaüstü fare akışı `ui_input_test` ile yeniden kontrol edildi.


## R5b — Eylemler (2026-10-13)

R5a önkoşulu git geçmişinde doğrulandı. R5b tamamlandı; R5c'ye geçilmedi. Subay tayini, başkent/sınır garnizonu aktarımı, R1 tahsisine bağlı ve azalan getirili gecikmeli maaş/ikmal desteği ve bedelli komuta bölme kararları eklendi. Her eylem mesai ve nitel önizleme kullanıyor; rastgelelik ayrı `army_rng` üretecinden geliyor. Yeni komutan sadakat belirsizliği, eski subayın tepkisi, garnizon dengesi, Arden gücü/ordu kapasitesi/tansiyonu, Günlük/Divan raporu ve üç başarım işlendi. SAVE_VERSION 22; v21 göçü eski Arden gücünü koruyor.

Ayrı commit'ler: cila `8b3ee11`, özellikler/ölçüm botu/testi `ea49676`. Cila uzun karar kartı işaretlerini, dokunmatik slider sürüklemesini, kompakt komutan portrelerini, bayat eylem raporunu ve mobil a11y testinin kip varsayımını düzeltti.

### Kapı sonuçları

`advice_weighted`, 80 kampanya: Kolay 58/80, Normal 27/80, Zor 15/80 (R5a tabanına göre −2/−2/−2; ±3 ve Zor ≤16 geçti). Uç bot galibiyetleri Kolay/Normal/Zor: ordu ödeneği 14/3/0, komuta bölme 11/4/0, başkente garnizon 13/2/0, ordu kararı vermeme 14/2/0; tümü ölçütün %70 tavanının altında. Tempo: ilk 8 hafta 0,81 olay/hafta; en uzun olaysız seri 3 hafta.

`--full --seed=101` TR ve EN: `FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`. EN sızıntısı: 5 kampanyada 0; eksik çeviri: 0. EN/TR masaüstü ve 1067×600 mobilde 16 eylem, Günlük, Divan ve komutan kartı görüntüsü açılıp kontrol edildi; taşma veya yüzü kapatan etiket görülmedi, dosyalar silindi.

`tools/run_test_isolated.ps1` ile son ağaçta 36 test çalıştı; hepsinin çıkış kodu 0. Test adları ve tam başarı satırları tasarım belgesindeki **R5b test çıktıları** tablosunda. Bazı Godot kapanışlarında RID/ObjectDB/resource uyarıları var. R5c'ye geçilmedi; `tests/title_shot.gd`, `game/ui/title_screen.gd` ve `art/` değiştirilmedi.

### Gözlemler

Kompakt komutan kartları portre yüzü ile ad/rolü ayırıyor; uzun karar listeleri artık madde işaretli. Mobil Divan'da komutan kartları aşağı kaydırma gerektiriyor; taşma yok, yoğunluğu ileride azaltmak değerlendirilebilir. Ayrıntı `docs/roadmap/GOZLEMLER.md` içindeki 2026-10-13 R5b kaydında.
