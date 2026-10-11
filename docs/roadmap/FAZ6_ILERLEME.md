# Faz 6 ilerleme

## Tamamlandı

### A1 — Uyarlamalı müzik (`4accbb5`)
- Menü, normal oyun, yaşlanan karar ve kriz durumları iki müzik oynatıcısı arasında çapraz geçişle eşleniyor. Dosya yoksa ambient akışına, o da yoksa sentezlenmiş müziğe düşüyor; hızlı kip/autoplay geçişleri anında.
- `audio_check`, `sim_test`, `event_check`, `save_test`, `content_check`, `i18n_check`, `en_leak_test`, `lang_switch`, `touch_scroll`, `tour`, `cutscene`, `ui_input_test` (masaüstü/mobil) ve autoplay kapıları geçti.
- `--full` tohum 101: 104 hafta / TAHTTA / Medya Rejimi / 112 olay; TR ve EN aynı. Ölçüt probe: 68/80, 36/80, 16/80.
- TR/EN masaüstü ve mobil görüntüleri alınıp incelendi: `screenshots/faz6_a1_tr`, `faz6_a1_en`, `faz6_a1_mobile_tr`, `faz6_a1_mobile_en`.

### A2 — Erişilebilirlik
- Ayarlara kalıcı yazı boyutu, renk körü modu, hareketi azalt, titreşim ve yüksek kontrast seçenekleri eklendi. Tercihler kampanya kaydından ayrı ayar dosyasında tutuluyor ve arayüze canlı uygulanıyor.
- Hareket azaltma UI animasyonlarını, tozu ve yakınlaştırmayı etkisizleştiriyor; Android için karar, kriz başlangıcı ve hafta bitişi titreşimi eklendi. Renk körü görünümünde tehlike işareti şekil ile ayrılıyor.
- `a11y_test`: `A11Y: OK`; i18n eksikleri: 0. Büyük metin UX auditleri TR/EN, 1067×600 ve 1280×720: hepsi `AUDIT BULGU: 0`.
- Görüntüler alınıp incelendi: `screenshots/faz6_a2_large_1067_verified`, `faz6_a2_large_1280_verified`, `faz6_a2_large_1067_en_verified`, `faz6_a2_large_1280_en`.

### A3 — Günlük tohum ve paylaşılabilir saltanat kartı
- UTC tarihinden kararlı günlük tohum üretiliyor; günlük oyun Normal zorlukla açılıyor. `user://daily.cfg` günün ilk sonucunu saklıyor; tekrar oyun serbest, ilk sonuç korunuyor ve kampanya kaydına ek alan yazılmıyor.
- Bitiş ekranındaki kart SubViewport ile 1080×1350 PNG olarak `user://cards/` içine kaydediliyor. Kartta kral portresi, ünvan, hafta, rejim, tarih ve tohum var. Paylaşım metni Türkçe ve İngilizce kopyalanıyor; Windows/Linux kart klasörünü açabiliyor. Web kart düğmesi metin kopyalıyor; Android uygulama klasörünü kullanıyor.
- `daily_card_test`: `DAILY CARD: OK`; günlük tohum, ilk-sonuç korunması, çift dilli metin ve PNG boyutu/dosyası doğrulandı. i18n eksikleri: 0. TR/EN masaüstü ve mobil UX auditleri `AUDIT BULGU: 0`.
- Görüntüler alınıp incelendi: `screenshots/faz6_a3_desktop_tr`, `faz6_a3_desktop_en`, `faz6_a3_mobile_tr`, `faz6_a3_mobile_en`, `faz6_a3_end_screen_tr_desktop.png`, `faz6_a3_end_screen_en_mobile.png`, `faz6_a3_card_tr.png`, `faz6_a3_card_en.png`.

### A4 — Senaryo modları ve sonsuz mod
- Üç senaryo (Darbeye açık krallık, Naiplik, Boş kasa) Türkçe/İngilizce veri kaplamalarıyla eklendi. Varsayılan başlangıç yolu senaryosuz çalışıyor; kayıt sürümü 10'a çıkarıldı ve eski kayıtlarda senaryo/uzatma alanları göçle varsayılanlanıyor.
- Senaryo seçimi yeni saltanat menüsünde yer alıyor; senaryoya göre üç yeni başarım veriliyor. Senaryo bot kapısı her zorlukta 80 kampanya çalıştırdı; Normal sonuçları darbe 36/80, naiplik 30/80, boş kasa 42/80 (hepsi %25–65 bandında).
- Tahtta kalınan normal bitişten sonra uzatmaya geçilebiliyor. Uzatma ayrı kayıt/başarım dosyası kullanıyor, süreli olayları bekleme süresiyle yeniden açıyor ve her 26 haftada kriz eşiklerini azaltıyor. 200 haftayı aşan bot, ayrı kayıt ve eşik testi `ENDLESS: OK` verdi.
- `sim_test`, `save_test`, `content_check`, `i18n_missing.py` (0) ve `scenario_test` geçti. UX audit TR/EN masaüstü ve 1067×600 mobilde `AUDIT BULGU: 0` verdi.
- Görüntüler alınıp incelendi: `screenshots/faz6_a4_desktop_tr`, `faz6_a4_desktop_en`, `faz6_a4_mobile_tr`, `faz6_a4_mobile_en`; mobilde senaryo listesinin altı ve oyun sonu uzatma düğmesi de kontrol edildi.

### Dalga A son dokunuş — kurum çekmecesi dış tıklaması
- Başkent haritasındaki kurum ayrıntısı açıkken boş alana/dışarıya fareyle tıklama veya dokunma çekmeceyi kapatıyor. Kurum kartına tıklama başka kurum ayrıntısını açmaya devam ediyor; çekmece içi tıklama ve Esc davranışı korundu.
- `ui_input_test` masaüstü ve mobil: `UI INPUT: OK`; kurum değişimi, panel içi tıklama, dış dokunma ve boş alana tıklama denetlendi.
- TR masaüstü ve EN mobil görüntüleri alındı, panel açık/kapalı durumu ve kurum haritasındaki metinler gözle kontrol edildi: `screenshots/faz6_city_dismiss_tr`, `screenshots/faz6_city_dismiss_en_mobile`.
- Son kapılar: `sim_test`, `event_check` TR/EN, `save_test`, `content_check` TR/EN, `i18n_check`, `en_leak_test` (0 sızıntı), `lang_switch_test`, `touch_scroll_test`, `tour_test`, `cutscene_check`, `audio_check`, `a11y_test`, `daily_card_test`, `scenario_test`, `endless_test`, UI giriş testleri ve `i18n_missing.py` (0) geçti.
- `--autoplay`, `--autoplay --mobile` TR/EN ve `--autoplay --full` TR/EN geçti. Tohum 101 tam koşusu iki dilde de 104 hafta / TAHTTA / Medya Rejimi / 112 olay verdi. `advice_weighted` probe (80 kampanya, üç zorluk) TR ve EN: 68/80, 36/80, 16/80.

### B1a — Altyapı + Drakon sınır krizi
- `ext_pressure` üç güç için ayrı kaydediliyor; SAVE_VERSION 11 oldu. v10 ve daha eski kayıtlara basınç, ayrı RNG ve geçmiş alanları güvenli varsayılanlarla göçüyor. Haftalık baskı ve şüphe göstergesi ana RNG'yi tüketmiyor; heyet gönderme baskıyı düşürüyor.
- Drakon sınır notası bir hafta sonra ültimatoma ilerliyor; ordu, taviz ve Asteria güvencesi yolları var. Başarısızlık `Yabancı müdahalesi` / `Çöken Egemen`; dış eylemler ve Elena raporu Hakikat Dosyası'na ekleniyor. Başarım ve kriz kartı TR/EN içerikleri eklendi.
- `external_crisis_test`, `sim_test`, `event_check` TR/EN, `save_test`, `content_check` TR/EN, `i18n_check`, `en_leak_test`, `i18n_missing.py` (0), `ui_input_test` masaüstü/mobil, `lang_switch`, `touch_scroll`, `tour`, `cutscene`, `audio`, `a11y`, `scenario`, `endless`, `ui_logic`, `unit_tests` (399 kontrol) geçti. Tempo testi en düşük dilimde 0,81 olay/hafta verdi.
- Seed 101 `--autoplay --full`: TR/EN 104 / TAHTTA / Medya Rejimi / 112. Probe, TR ve EN aynı: Kolay 68/80 (%85), Normal 36/80 (%45), Zor 16/80 (%20). Bu alt dilimde dış kriz kaybı tetiklenmedi.
- `en_dump` masaüstü/mobil + `en_dump2` sızıntı taraması: 4.052 metin, 0 şüpheli. Drakon nota/ültimatom kartı ekran görüntüleri TR/EN masaüstü (1280×720) ve mobil (1067×600) açılıp gözle kontrol edildi: `screenshots/faz6_b1a/{tr,en}/{desktop,mobile}`.

### B1b — Mali kuşatma
- Asteria/Seravia baskısı ve zayıf hazine/maliye ambargo notasını açıyor; sonraki hafta kredi kesintisi kartı geliyor. Kemer sıkma, Sarne sermayesi ve liman/ticaret tavizi ayrı başarı olasılıkları ve maliyetlerle çözülebiliyor; başarısızlık `Mali çöküş` finali ve `Mali Çöküş` ünvanını veriyor.
- Kriz geçmişi, notalar, kredi kesintisi kartı, yeni başarım ve hata nedeni TR/EN. `external_crisis_test`, `sim_test`, event/save/content/i18n/leak, UI giriş (masaüstü/mobil), dil, dokunma, tur, ara sahne ve ses kapıları geçti. `i18n_missing.py`: 0; dump taraması: 4.035 metin, 0 şüpheli. Tempo en düşük dilimde 0,81 olay/hafta.
- Seed 101 tam koşusu TR/EN yine 104 / TAHTTA / Medya Rejimi / 112. Probe (80 kampanya/zorluk), iki dilde: Kolay 68/80 (%85), Normal 36/80 (%45), Zor 16/80 (%20); dağılım B1a ile aynı, bu probe örnekleminde dış kriz kaybı yok.
- Ambargo ve kredi kesintisi kartı ekran görüntüleri TR/EN masaüstü (1280×720) ve mobil (1067×600) açılıp gözle kontrol edildi: `screenshots/faz6_b1b/{tr,en}/{desktop,mobile}`.

### B1c — Suikast
- Ayrı dış RNG'siyle düşük olasılıklı alamet açılıyor; yalnızca sonraki haftada ve alamet bayrağı varsa Kortej Planı krizi çıkıyor. Güvenlik, rota ve halka görünme seçenekleri saldırı gecesini çözüyor. Başarılı rota değişiminde yaralı kurtuluş, Hakikat Dosyası sırrı, koşullu Saray sonrası olayı ve `Yaralı Egemen` ünvan/başarımı; başarısızlıkta `Suikast` finali ve başarımı var. Eski kayıt biçimi korunuyor.
- `external_crisis_test`, `sim_test`, `event_check` TR/EN (201 olay, 0 uyarı), `save_test` (v10 göçü dahil), `content_check` TR/EN, `i18n_check`, `i18n_missing.py` (0), `en_leak_test` (5 kampanya, 0 sızıntı), `pacing_test` (en düşük dilim 0,81), UI giriş masaüstü/mobil ve `lang_switch`, `touch_scroll`, `tour`, `cutscene`, `audio`, `a11y`, `scenario`, `endless`, `ui_logic`, `unit_tests` (399 kontrol) geçti.
- `--full` tohum 101 TR/EN: `104 / TAHTTA / Medya Rejimi / 112`; aynı ekran sonucu. `advice_weighted` 80 kampanya/zorluk probe'u iki dilde birebir: Kolay 62/80, Normal 30/80, Zor 13/80 (tabana göre −7,5 / −7,5 / −3,75 puan).
- Kayıp dağılımı: toplam 135 kaybın 102'si darbe (**%75,6**, ≤%65 hedefi geçmedi); dış kriz 20 (**%14,8**) ve her tür %2 üzerinde: müdahale 3 (%2,2), mali 8 (%5,9), suikast 9 (%6,7). Kampanyaların tümüne göre dış kriz kaybı %8,3. Bu nedenle uygulama tamamlanmış olsa da B1 toplam denge kapısı AÇIK olarak işaretlendi.
- `screenshots/faz6_b1c/{tr,en}/{desktop,mobile}/assassination_prep.png` görüntülerinin dördü de açılıp incelendi: hazırlık kartı, üç karar seçeneği, İngilizce/Türkçe tutarlılığı, metin okunurluğu, mobil taşma ve kırpılma kontrol edildi. B1a/B1b nota ve kriz kartı görüntüleri önceki alt dilimlerde ayrıca incelendi.
- Godot bazı başsız testlerin sonunda var olan ObjectDB/RID/kaynak temizleme uyarılarını verdi; test sonuç kodları ve kapılar başarılıydı.

### B2 — Miras ve hanedan
- `game/data/legacy.json` ve İngilizce kaplaması eklendi. Gerçek kasa, Arden'in kariyer sadakati ve kapanmamış kral dosyalarından en çok üç miras etkisi üretiliyor; her pakette en az bir olumlu ve bir olumsuz etki var. Etkiler ayrı RNG çekmiyor; nesil başına aşınma uygulanıyor.
- `Sim.new_game(seed, diff, scenario, legacy)` dördüncü, isteğe bağlı miras parametresini alıyor. Miras yokken seed 101 yolu değişmedi. Miraslı yeni hükümdar Julian Valerius olabilir; açık dosya tam fact şeması ve TR/EN metniyle taşınıyor.
- `user://dynasty.cfg` nesil, saltanatlar, rejim, ünvan, hafta, puan ve sonraki mirası tutuyor. Yalnızca tahtta kalıp `halef_karari_1` seçen saltanat devamı açıyor; kayıp/halef yokluğu etkin nesli, puanı ve devam mirasını sıfırlıyor. Kampanya kayıt sürümü 12; v11 ve daha eski kayıt göçleri geçiyor.
- Ana menüde uygun oyuncuya **Hanedan Devam**, her oyuncuya **Hanedan Defteri** var. Defter TR/EN nesil listesini ve sonraki mirası gösteriyor. Mobilde kaydırılabilir alan ve 44 px ya da daha büyük menü/geri hedefleri doğrulandı. `Kuşaklar Boyu`, `Üç Nesil`, `Beşinci Taç` başarımları eklendi.
- `legacy_test`, `dynasty_test`, `save_test` (v11/v8/v1 göçleri), `sim_test`, `event_check` TR/EN, `content_check`, `i18n_check`, `i18n_missing.py` (0), `en_leak_test` (5 kampanya, 0 sızıntı), `lang_switch_test`, `touch_scroll_test`, `tour_test`, `cutscene_check`, `audio_check`, `ui_input_test` masaüstü/mobil ve autoplay kapıları geçti. Bazı Godot başsız testleri mevcut ObjectDB/RID kapanış uyarılarını verdi; testler `OK` döndü.
- `--full` seed 101 TR/EN: `104 / TAHTTA / Medya Rejimi / 112`; mirassız ölçüt botu TR/EN: Kolay 62/80, Normal 30/80, Zor 13/80.
- Ölçüt botu üç nesillik eşlenmiş denemesi (her zorlukta 80 seed × 3 saltanat; miras yalnızca önceki sonuç tahtta kalıp veliaht kararı verdiyse taşınır; kayıp seriyi sıfırlar):

| Zorluk | Taban | Hanedan yolu | Fark | Devreden kampanya |
| --- | ---: | ---: | ---: | ---: |
| Kolay | 195/240 (%81,3) | 194/240 (%80,8) | −0,4 puan | 132 |
| Normal | 95/240 (%39,6) | 107/240 (%44,6) | +5,0 puan | 71 |
| Zor | 49/240 (%20,4) | 47/240 (%19,6) | −0,8 puan | 30 |

- Hanedan defteri ve menü görüntüleri `screenshots/faz6_b2/{tr,en}/{desktop,mobile}/dynasty_{home,ledger}.png` altında üretildi. Dört dil/ekran boyutu grubundaki sekiz PNG açılıp gözle kontrol edildi: TR/EN metin tutarlılığı, uygunluk düğmesi, mobil kaydırma göstergesi, geri düğmesi erişimi, kesilme/taşma. Masaüstünde uzun miras listesi kaydırma alanında; mobilde de geçmiş ve miras satırları kaydırılarak görülüyor.
- Commit: `1133967` miras veri/başlangıç etkileri; `af945bb` hanedan devamı, defter, kayıt göçü, başarımlar ve üç nesil probe kapısı.

## SIRADAKİ DİLİM

DALGA A, B1a/B1b/B1c ve B2 uygulaması tamamlandı. B1'de darbe kayıplarının payı %75,6 ile ≤%65 kapısını geçmedi; yeni dalgaya geçmeden bu açık denge kapısı yeniden kalibre edilmeli.
