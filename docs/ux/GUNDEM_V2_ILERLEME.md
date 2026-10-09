# Gündem v2 ilerleme

**SIRADAKİ DİLİM: U2**

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

### Açık konu

- U2 karar sırası, U3 rapor/kişi blokları ve U4 mobil yeniden düzenleme kendi dilimlerinde uygulanacak.
