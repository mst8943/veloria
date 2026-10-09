# Gündem v2 ilerleme

**SIRADAKİ DİLİM: U4**

## U2b + U3 — tamamlandı (2026-10-09)

- U2b ayrı commit `eb36696`: Sırada satırında HOVER zemin/çerçeve, el imleci ve çizilmiş ok. TR/EN, 2/3 karar, gerekçe açık/kapalı ekranları: `C:/Users/USER/Desktop/oyun_u2b_u3_shots/final-u2b-{tr,en}-{2,3}/`. EN 1280×720, 3 karar ve açık gerekçede sol sütun taşması 0 px; 4 hafta defteri satırı U3 rapor sütununda kesilmeden görünüyor: `final-u2b-log-en/u2_3_gerekceler.png`.
- U3: raporlar “Bu hafta değişenler” altında görünür hafta değişimleri, hafta defteri ve ilk 4 rapor sırasıyla gösteriliyor; “Tüm raporlar (N)” kaplaması tam listeyi ve rapordan kişi seçimini koruyor. Geçen haftadan beri verisi yalnızca burada. Seçim yokken tek satır ipucu, seçimde kişi/eylem bloğu ve X/Esc kaldırma; otomatik tam oynatma eylemden önce kişiyi seçiyor. Bildirim > haber > ipucu üst şeridi tek satır ve en çok 2 öğe.
- `ui_input_test`: Sırada satırı, tüm raporlar kaplaması/listedeki rapor sayısı, rapor tıklaması, X/Esc ile seçim temizleme ve Divan etkileşimleri OK. Beckett `unit_tests` fikstüründeki ekran dışı hedef artık geçerli viewport ölçüsüne göre kuruluyor: 399/399 kontrol geçti.

### KAPI

- `sim_test`, `event_check` (195 olay, 0 uyarı), `save_test`, `content_check`, `i18n_check`, `pacing_test`, `ui_logic_test`, `ui_input_test`: OK. EN `event_check` ve `content_check`: OK. `unit_tests`: 399/399.
- Masaüstü `--autoplay` ×3: DONE (32/29/105 hafta); `--autoplay --mobile`: DONE (34 hafta). `--autoplay --full` TR ve EN birebir: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- `advice_weighted`, 80 kampanya, tüm zorluklar: TR ve EN **68/80, 36/80, 16/80**; tabanla birebir. Loglar: `C:/Users/USER/Desktop/oyun_u2b_u3_shots/final-probe-{tr,en}.log`.
- TR/EN masaüstü PNG'leri (seçim yok, seçili, düşman seçili, 3 karar) gözle incelendi: `C:/Users/USER/Desktop/oyun_u2b_u3_shots/final-u3-{tr,en}/u3_{none,selected,enemy,3}.png`. Taşma, kırpılma ve dil karışımı görülmedi. `pacing_test` ve `sim_test` çıkışlarında önceki Godot kaynak/nesne sızıntısı uyarıları sürüyor.

## U1b + U2 — tamamlandı (2026-10-09)

- U1b: Divan gruplarında glif yerine çizilmiş aç/kapat üçgeni; katlı durum çekmece kapanıp açılsa da korunuyor. Dışişleri notu grup başlığının yanında. Seçili kartın altın çerçevesi Divan'da da görünüyor.
- U1b animasyon bitişi beklenerek ölçüldü: 1280×720 pencerede mantıksal çekmece `x=880..1600`, Kapat `x=1506..1586`; 1067×600 pencerede çekmece `x=816..1600`, Kapat `x=1506..1586` (Godot mantıksal alanı 1600×900). Ekran sınırı aşılmadı. PNG'ler: `C:/Users/USER/Desktop/oyun_u1b_u2_shots/u1b_{1280,1067}/u1b_divan.png`.
- U2: Bir tam karar kartı, diğer bekleyen kararlar için Sırada satırları, Karar x/y ve çizilmiş noktalar/oklar; satır, düğme ve klavye oklarıyla geçiş. Danışman özeti tek satır; Gerekçeler tam alıntıları açıyor. Görünür hafta değişimleri, 3 karar varken sol sütunun kaydırılmaması için sağdaki mevcut rapor akışının başına taşındı; U3 bu alanı son düzene getirecek.

### KAPI

- `sim_test`: TEST: OK; `event_check`: EVENTS: OK (195 olay, 0 uyarı); `save_test`: SAVE: OK; `content_check`: CONTENT: OK; `i18n_check`: I18N: OK; `ui_logic_test`: UI LOGIC: OK; `ui_input_test`: UI INPUT: OK. İngilizce event/content kontrolleri de OK. `pacing_test` tamamlandı (en uzun olaysız seri 2/2 hafta; kapanışta önceki Godot kaynak sızıntısı uyarıları).
- Masaüstü `--autoplay` ×3: DONE (tohum 11; 55/59/44 hafta). `--autoplay --mobile`: DONE (38 hafta). `--autoplay --full` TR ve EN: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- Ölçüt probe (`advice_weighted`, 80 kampanya): TR **68/80, 36/80, 16/80**; EN **68/80, 36/80, 16/80**. Tabanla birebir aynı. Günlükler: `C:/Users/USER/Desktop/oyun_u1b_u2_shots/probe_{tr,en}.log`.
- Masaüstü PNG: `C:/Users/USER/Desktop/oyun_u1b_u2_shots/u2_{tr,en}_{2,3}/u2_{2,3}_{karar,son_karar,gerekceler}.png`; mobil PNG: `u2_mobile_{tr,en}/u2_2_{karar,son_karar,gerekceler}.png`. Görüntülerde 2 ve 3 karar, Sırada satırları, oklar/noktalar, tam alıntı ve TR/EN metinler gözle kontrol edildi. 1280×720 masaüstünde iki ve üç karar için sol kaydırma payı **0 px**. Mobilde mevcut kaydırmalı Gündem düzeni duruyor; yeniden düzenleme U4 kapsamında.

### Açık konu

- U4: mobil yeniden düzenleme.

## U1 — tamamlandı (2026-10-09)

- Masaüstünde 5 kişilik İzleme Listesi ve +N Divan karosu; görünür danışman, hafta değişimi ve şüphe verilerinden sıralama. İlk üç haftada yol gösterici açıksa çekirdek beşli sabit. Seçili kişi sırada kalır.
- Sağdan 0,18 saniyede açılan SHADE örtülü Divan; dört katlanır grup, 14 mevcut kart nesnesi, görünür duruma bağlı rozetler. Kişi seçimi, dış tıklama, Esc ve 1–5 kısayolu çalışıyor.
- Saf sıralama mantığı `game/ui/strip_order.gd`; birim kontrolü `tests/ui_logic_test.gd`. Oyun mantığı ve kayıt şeması değişmedi.

### KAPI

- `sim_test`: TEST: OK. `event_check`: EVENTS: OK (195 olay, 0 uyarı). `save_test`: SAVE: OK. `content_check`: CONTENT: OK (5 dosya, 8 bozuk örnek). `i18n_check`: I18N: OK. İngilizce event/content kontrolleri de OK.
- `pacing_test`: 1–88 haftalarının bütün dilimleri ≥0,81 olay/hafta; çıkışta mevcut kaynak sızıntısı uyarısı var. `ui_logic_test`: UI LOGIC: OK. Pencereli `ui_input_test`: UI INPUT: OK.
- `--autoplay` masaüstü ×3: DONE (tohum 11; 35/44/37 hafta). `--autoplay --mobile`: DONE (tohum 11; 47 hafta). `--autoplay --full`: TR ve EN `FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi olay=112`.
- Ölçüt probe, `advice_weighted`, 80 kampanya: TR = **68/80, 36/80, 16/80**; EN = **68/80, 36/80, 16/80**. Tabanla birebir aynı. Günlükler: `C:/Users/USER/Desktop/oyun_u1_shots/probe_tr.log`, `probe_en.log`.
- Pencereli görüntüler: `C:/Users/USER/Desktop/oyun_u1_shots/{tr,en}/u1_{serit,divan,kisi_secili}.png`; ilk hafta: `guide_tr/u1_serit.png`; mobil: `mobile_{tr,en}/1_{saray,karar}.png`. PNG'ler açılıp şerit, dört grup ve 14 kart, seçili kişi, iki dil, 1067×600 mobil yerleşim, taşma/kırpılma ve örtünün tıklama alanı gözle incelendi; U1'e ait görünür sorun saptanmadı.
