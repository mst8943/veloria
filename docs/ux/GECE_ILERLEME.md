# Gece görevi ilerleme

**SIRADAKİ DİLİM: 3 — İlk açılış turu**

## Kararlar

- Bu görev için başlangıçta ilerleme dosyası yoktu; oluşturuldu.
- Var olan kullanıcı değişiklikleri ve hariç tutulan proje ayarları korunacak. Yalnızca görev kapsamındaki dosyalar stage edilecek.
- Sızıntı denetimi görünür arayüz metinlerini, tooltip'leri ve simülasyonun ürettiği günlük/haber/rapor metinlerini kapsayacak; kişi/yer adları izin listesinde tutulacak.
- Bilgisayar kapatma isteği görev tamamlanınca uygulanacak; bu açık Godot editörünü de sonlandırır.

## Dilim 1 — İngilizce sızıntı taraması

Durum: tamamlandı.

- Beş tohum/zorluk kampanyasının geçmiş, haber ve rapor metinleri; ana sekmeler, yedi eylem kategorisi, Divan, masa, medya kanalları, harita, menü, ayarlar, yardım/hakkında pencereleri, arşiv, oyun sonu sekmeleri ve `cutscenes.json` satırları kalıcı `tests/en_leak_test.gd` ile taranıyor. Test `i18n_check` tarafından da başlatılıyor. İlk taramada 109 tekrar eden aday sızıntı bulundu; haftalık tarihçe biçimi, rapor ipucu, harita durum etiketi, açılış sineması ve menü yardım/hakkında metinleri düzeltildi. Son tarama: **5 kampanya, 0 sızıntı**.
- `Sim.history` yalnızca gösterilen tarihçe metinleri için yerelleştirildi; Türkçe biçim aynı kalıyor. Haber, olay çözümü, RNG, sim akışı değişmedi. Açılış sineması ile yardım/hakkında satırları `tr()` ve en.po üzerinden çevriliyor.
- `tests/ui_shots.gd` kararlı kare için geçişlerden sonra 30 kare bekliyor; eylem kategorileri, Dosyalar/Günlük, menü modalları ve hafta perdesi için kanıt kipleri eklendi. `cutscene_check` EN ve mobil başlatma sırasını düzeltti.
- KAPI: `sim_test` TEST: OK; `event_check` EVENTS: OK (195 olay/0 uyarı); `save_test` SAVE: OK; `content_check` CONTENT: OK; `i18n_check` I18N: OK (çalışma zamanı sızıntı taraması dahil); masaüstü/mobil `ui_input_test`, `touch_scroll_test`, `cutscene_check`, `audio_check`: OK. Godot kapanışında bazı eski ObjectDB/kaynak temizleme uyarıları var.
- `--autoplay`: tohum 11/12/13 için 55/25/66 hafta; `--autoplay --mobile`: 40 hafta. `--autoplay --full` TR/EN aynı: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- Probe TR ve EN aynı: **68/80, 36/80, 16/80** (Kolay/Normal/Zor), `advice_weighted`, 80 kampanya.
- EN ekran kanıtları (PNG'ler temas sayfasında ve temsilî tam boy karelerde incelendi; dil karışması/kırpılma görülmedi): `C:/Users/USER/Desktop/oyun_gece_s1_en_{desktop,mobile}/` — Gündem, karar, Masa, Medya/üç kanal, Harita, menü/yeni oyun/ayarlar, oyun sonu/sekme görünümleri; `...s1_actions_en_{desktop,mobile}/` — yedi eylem kategorisi ve alt açıklamaları; `...s1_docs_en_{desktop,mobile}/` — Dosyalar/Günlük; `...s1_divan_en_desktop/` — şerit/Divan/seçili kişi; `...s1_modals_en_{desktop,mobile}/` — yardım, hakkında, arşiv; `...s1_curtain_en_{desktop,mobile}/` — hafta perdesi; `...s1_cutscene_en_{desktop,mobile}/` — ara sahne altyazıları. Harita karesinde ana ekranın loş arka planı örtünün altından görünüyor; metinler İngilizce ve kırpılmamış.
- Değişiklikler tek Dilim 1 commit'inde.

## Dilim 2 — Canlılık

Durum: tamamlandı.

- Tek CanvasLayer ekran derecelendirmesi eklendi (satürasyon 1.30, kontrast 1.00, parlaklık 1.03); ayar anahtarı yok. UIKit'teki var olan GOLD_DIM ve DANGER tonları aynı renk ailesinde açılarak hover zemininde sırasıyla **4.71:1** ve **4.65:1** kontrasta ulaştı.
- `docs/ux/canlilik_oncesi_sonrasi.md` altı ekranın bütün önce/sonra S/V ölçümlerini ve kanıt yollarını içeriyor. PIL ölçümü: masaüstü ekran ortalaması S **+23.9%**, V **+7.6%**; mobil S **+26.6%**, V **+8.4%**; birleşik S **+25.3%**, V **+8.0%**.
- 1600×900 ve 1067×600 Türkçe `ui_shots` PNG'leri `C:/Users/USER/Desktop/oyun_gece_s2_{before,after}_tr_{desktop,mobile}/` altında. Her klasörde Menü, Gündem/karar, Masa, Medya, Harita, Oyun sonu ve ek UI kareleri var; temas sayfaları ve tam boy karar, medya, harita, oyun sonu kareleri açıldı. Metin/karar seçenekleri okunuyor, kırmızı ve yeşil ayırt ediliyor, yapay/neon renk yok. Oyun sonu Özeti kaydırılabilir; ekran karesi görünür kısmı gösterir.
- KAPI: `sim_test`, `event_check`, `save_test`, `content_check`, `i18n_check`: OK; masaüstü/mobil `ui_input_test`, `touch_scroll_test` (tekrarda 3/3), `cutscene_check`, `audio_check`: OK. Godot çıkışında test süreçlerinde önceki ObjectDB/kaynak uyarıları görülüyor.
- `--autoplay`: tohum 11/12/13 için 49/25/99 hafta; `--autoplay --mobile`: 84 hafta. `--autoplay --full` TR/EN aynı: `tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- Probe TR/EN aynı: **68/80, 36/80, 16/80** (Kolay/Normal/Zor), `advice_weighted`, 80 kampanya.
- Değişiklikler tek Dilim 2 commit'inde.

## Dilim 3 — İlk açılış turu

Durum: sırada.
