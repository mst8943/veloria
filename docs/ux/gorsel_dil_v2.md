# Görsel Dil v2 — "Devlet Arşivi" cilası

Tarih: 2026-10-05. Kapsam: tüm arayüzün ortak stil katmanı (`game/ui/ui_kit.gd`) ve ana ekranın göze batan birkaç yeri. Oyun mekaniği, yerleşim ve bilgi miktarı değişmez.

## Sorun (önce hali, `ui_shots` 1280×720)
1. **Web kartı görünümü**: her şey 5–10 px yuvarlak köşeli, tek çizgi çerçeveli kutu. Rapor satırı, sekme, düğme, çip... hepsi aynı ağırlıkta kutu; hiyerarşi kayboluyor ("kutu çorbası").
2. **Mor/mavi kayma**: nötrler (`201e27`, `2a2733`, `1b1a21`, perde `0.03,0.02,0.04`) mor tonlu; altın ve parşömen paletiyle çatışıyor. Menüde "Yeni Oyun / Ayarlar" düğmeleri gri-mavi görünüyor.
3. **Sekmeler**: seçili sekme tam altın çerçeveli kutu, düğmeden ayırt edilmiyor.
4. **Alamet satırı**: turuncu düz metin, hiçbir kaba oturmuyor; sistem uyarısı gibi değil, hata çıktısı gibi duruyor.
5. **Rapor satırları**: dört kenarı da renkli; renk anlamı (raporun söylediği durum) bütün kutuya yayılıyor, liste gürültülü.

## İlke
Referans: Crusader Kings III, Suzerain, Frostpunk. Ortak noktaları:
- **Keskin geometri**: köşeler 0–3 px. Yuvarlaklık "uygulama" hissi verir; keskinlik "belge, mühür, devlet" hissi verir.
- **Çift çerçeve**: önemli paneller dışta koyu bir kenar, içte 3 px içeride ince altın kıl çizgisi taşır. Göz paneli "hazırlanmış bir yüzey" olarak okur.
- **Sıcak nötrler**: kömür ve is tonları (kırmızı ≥ yeşil ≥ mavi). Altın tek vurgu rengi kalır.
- **Renk = anlam**: renk yalnızca anlam taşıdığı yerde ve en küçük yüzeyde (kenar çizgisi, nokta) kullanılır.
- **Seçili durum çizgiyle gösterilir**: sekmede üstte 2 px altın çizgi, kutu yok.

## Değişiklikler
| Alan | Önce | Sonra |
|---|---|---|
| Palet nötrleri | `17161b` / `201e27` (mor) | `171511` / `221e18` (sıcak kömür); düğme üstü `2c271e` |
| Perde/örtü renkleri | `Color(0.03,0.02,0.04)` | `UIKit.SHADE` (sıcak is) |
| Köşe yarıçapı | 4–10 px | `UIKit.box` en fazla `RADIUS`=3 px (çipler dahil) |
| Önemli paneller | köşebent | köşebent + iç kıl çizgisi + üst ışık çizgisi (`UIKit.ornament` otomatik) |
| Düğmeler | düz kutu | 3 px köşe, alt gölge (1 px kalkık); Birincil düğme aralıklı büyük harf serif |
| Sekmeler | seçili = altın kutu | seçili = panel rengi + üstte 2 px altın; seçili olmayan = zeminsiz, sönük metin |
| Alamet satırı | turuncu düz metin | koyu şerit, solda 3 px amber çizgi, sıcak açık amber metin; boşken gizli |
| Rapor satırı | 4 kenar renkli | yalnızca sol 3 px renk çizgisi, zemin daha hafif |
| Oyun sonu | başlık çıplak | başlık bandı (`band_style`) |

## Kabul ölçütleri (ux-review)
- Ekranlarda mor/mavi nötr kalmadı; menü düğmeleri sıcak kömür.
- Hiçbir panelde 3 px'ten büyük köşe yok (sahne öğeleri, mühür ve elmaslar hariç).
- Seçili sekme bir bakışta seçili; düğmeyle karışmıyor.
- Alamet satırı okunur ve bir şerit içinde.
- Mobilde taşma ve kırpılma yok; otomatik oynatma testleri (masaüstü/mobil/tam) geçiyor.
- Web glifi eklenmedi; görünmez tıklama yutucu eklenmedi (yeni çizimler yalnızca `draw` sinyalinde).
