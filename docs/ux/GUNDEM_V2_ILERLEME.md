# Gündem v2 ilerleme

**SIRADAKİ DİLİM: bitti**

## M1 — mobil karar kartı düzeltmesi tamamlandı (2026-10-10)

- Mobil I/II/III seçenekleri UIKit `ChoiceButton` normal/hover/pressed dokularını kullanıyor; en az 44 px yüksekliğinde. Karar görseli solda 320×110 (kartın %30’undan geniş), başlık iki satıra sarılabiliyor; ornament köşeleri ve artırılmış iç boşluk metin/düğme alanını açık bırakıyor. Yalnız mobil boşluklar sıkılaştırıldı; masaüstü yerleşim kodu değişmedi.
- Pencereli `ui_input_test`: masaüstü ve `--mobile` OK. Mobil kontrol; düğme dokuları/hedefleri, görsel oranı, uzun başlıkta sarma, kart/alt çubuk sınırları ve karar sırası geçişini doğruluyor.
- KAPI: `sim_test` TEST: OK (kapanışta mevcut Godot ObjectDB/kaynak uyarıları); `event_check` TR/EN 195 olay, 0 uyarı; `save_test` SAVE: OK; `content_check` TR/EN 5 dosya/8 bozuk örnek; `i18n_check` I18N: OK. Masaüstü `--autoplay` ×3: 53/55/64 hafta; `--autoplay --mobile`: 35 hafta/104 eylem. `--autoplay --full` TR ve EN birebir: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- `advice_weighted`, 80 kampanya, TR ve EN: **68/80, 36/80, 16/80**; tabanla birebir.
- 1067×600 mobil kanıtlar `C:/Users/USER/Desktop/oyun_m1_shots/final-mobile-{tr,en}/` altında. Her dilde `u4b_agenda_1.png`, `u4b_agenda_2.png`, `u4b_agenda_3.png`: başlık, görsel, danışman satırı, dokulu üç seçenek, kart çerçevesi ve 1/2/3 karar göstergeleri tam; taşma/örtüşme yok. `people_selected.png`: kişi seçimi, grup, ad/çipler ve eylem kategorileri; `u4b_reports.png`: Raporlar üst görünümü ve metin akışı. Aynı klasörlerdeki dört grup/eylem ek kareleri de açılıp kontrol edildi.
- Masaüstü TR önce/sonra karşılaştırması: `C:/Users/USER/Desktop/oyun_m1_shots/before-desktop-tr/u2_3_karar.png` ve `final-desktop-tr/u2_3_karar.png`; `final-desktop-tr/u2_3_son_karar.png`, `u2_3_gerekceler.png` de incelendi. Kart yerleşimi/ölçeklemesi değişmedi.
- Değişiklikler: ayrı doku commit’i `9a75778`; mobil kart/kanıt/test ve bu kayıt ikinci commit’te.

## U4b — mobil düzeltmeler tamamlandı (2026-10-10)

- Kişiler’de seçim yapıldığında portre kartları 150×132’den 120×104’e iner; grup sekmeleri ve oklar sabit kalır. Seçili kişi alanı kendi dikey kaydırmasında kalır; EYLEMLER başlığı tek satır ellipsis kullanır, eylem sekmeleri/düğmeleri en az 44 px’tir. Alt çubuk kişi alanının dışında kalır.
- Gündem karar kartı görseli mobilde gizlenmez; 112×63’e küçültülür. Başlık en az 44 px yer ayırır ve taşarsa ellipsis uygular. 2/3 bekleyen kararda tek kart, sayaç/noktalar ve seçenekler korunur.
- KAPI: `sim_test` TEST: OK (çıkışta mevcut Godot kaynak temizleme uyarıları); `event_check` TR/EN 195 olay, 0 uyarı; `save_test` SAVE: OK; `content_check` TR/EN 5 dosya/8 bozuk örnek; `i18n_check` I18N: OK; `ui_logic_test` OK; `unit_tests` 399/399; `pacing_test` OK (çıkışta kaynak temizleme uyarıları); masaüstü ve mobil pencereli `ui_input_test` OK. İlk paralel içerik kontrolünde paylaşılan `user://` test dosyası çakıştığından TR/EN kontrolleri sırayla tekrarlandı; ikisi de geçti.
- Masaüstü `--autoplay` ×3: DONE (38/44/36 hafta); `--autoplay --mobile`: DONE (48 hafta). `--autoplay --full` TR/EN aynı: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- `advice_weighted`, 80 kampanya: TR ve EN **68/80, 36/80, 16/80**; tabanla birebir.
- 1067×600 ekran kanıtları `C:/Users/USER/Desktop/oyun_u4b_shots/{tr,en}/` altında; her dosya açılarak kontrol edildi:
  - `u4b_agenda_1.png`, `u4b_agenda_2.png`, `u4b_agenda_3.png` (iki dilde): karar başlığı ve küçültülmüş görsel, tüm seçenekler; 2/3’te tek kart ve karar göstergeleri.
  - `u4b_people_dynasty.png`, `u4b_people_state.png`, `u4b_people_power.png`, `u4b_people_foreign.png` (iki dilde): seçili kişi, doğru grup/portre, başlık ve çipler; isim veya alt çubuk taşması yok.
  - `u4b_people_dynasty_actions.png`, `u4b_people_state_actions.png`, `u4b_people_power_actions.png`, `u4b_people_foreign_actions.png` (iki dilde): eylem sekmeleri, düğmeler ve son eylem alanı tamamen görünür; eylem düğmeleri alt çubuktan ayrı.
  - `u4b_reports.png` (iki dilde): Raporlar sekmesi, değişenler/rapor listesi ve tüm raporlar düğmesi; kesik satır veya taşma yok.
- Değişiklik commit’leri: Kişiler `e75ec72`; Gündem/görüntü akışı/ilerleme kaydı bir sonraki commit’te.

## U3b + U4 — tamamlandı (2026-10-10)

- U3b ayrı commit `3ff3b8d`: hafta defteri “Bu hafta” altında oyuncu eylemleri ve sonuçlarını tutuyor; danışman raporları ayrı “Raporlar / Reports” başlığı altında. TR/EN masaüstü kanıtı: `C:/Users/USER/Desktop/oyun_u3b_u4_shots/u3b-{tr,en}/1_oyun.png`.
- U4 mobil sekmeleri Gündem · Kişiler · Raporlar. Dosyalar ve Günlük Raporlar içindeki alt sekmelerden erişiliyor. Kişiler’de dört yerelleştirilmiş grup, aynı 14 kart kontrolünün yatay şeritte filtrelenmesi, iki yanda çizilmiş ok ve aşağıda seçime bağlı kişi/eylem alanı var. Eylem kategori ve düğmeleri, grup sekmeleri, oklar ve seçim temizleme en az 44 px. Gündem’de tek tam karar kartı ve Sırada satırları; Raporlar’da değişenler, hafta eylem defteri ve ilk dört rapor + tüm liste kaplaması.
- Mobil `ui_input_test`: OK; üç bekleyen kararda tek kart/iki kuyruk satırı, kuyruk geçişi, Gerekçeler, 14 kişinin grup erişimi, 44 px hedefler, iki şerit oku, seçim temizleme, tam rapor kaplaması ve Dosyalar/Günlük gezinmesi kontrol edildi. `--autoplay --mobile`: `tohum=11 hafta=46 basılan=150 sonuç=DÜŞTÜ`.
- KAPI testleri: `sim_test`, `event_check` (195 olay/0 uyarı), `save_test`, `content_check`, `i18n_check`, `pacing_test`, `ui_logic_test`, masaüstü ve mobil `ui_input_test`, `unit_tests` (399/399) OK; EN `event_check` ve `content_check` OK. `pacing_test`/`sim_test` kapanışında Godot kaynak temizleme uyarıları sürüyor.
- Masaüstü `--autoplay` ×3: `20/DÜŞTÜ`, `81/DÜŞTÜ`, `37/DÜŞTÜ` hafta. `--autoplay --full` TR ve EN aynı: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- `advice_weighted`, 80 kampanya: TR/EN **68/80, 36/80, 16/80**; tabanla birebir aynı.
- 1067×600 mobil PNG’leri TR/EN: `C:/Users/USER/Desktop/oyun_u3b_u4_shots/final-mobile-{tr,en}/` (Gündem, üç karar/kuyruk, dört kişi grubu, kişi seçimi/eylemler, Raporlar/tam liste, Dosyalar, Günlük). Masaüstü durum PNG’leri: `C:/Users/USER/Desktop/oyun_u3b_u4_shots/final-desktop-{tr,en}/` (seçim yok, seçili, düşman). U3b ilk ekranları ayrı `u3b-{tr,en}` klasörlerinde. Görseller gözle kontrol edildi; metin karışması veya yatay taşma görülmedi, karar kartı ve seçenekleri tam görünüyor.

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

### Sonraki adım

- U4, U3b + U4 oturumunda tamamlandı; sonraki dilim yok.

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
