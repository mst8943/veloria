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

## SIRADAKİ DİLİM

DALGA A tamamlandı. Sıradaki: B1 — Dış krizler ve suikast.
