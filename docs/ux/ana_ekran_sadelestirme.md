# Ana Ekran Sadeleştirme (UX turu 4)

Tarih: 2026-10-04. Kaynak: kullanıcı geri bildirimi "ilk girilen sayfa çok kalabalık" + ux-review.

## İnceleme bulguları (önem sırasıyla)
| Önem | Ekran | Sorun | Kanıt | Öneri |
|---|---|---|---|---|
| Yüksek | Ana ekran | Aynı anda ~50 etkileşimli öğe: 17 eylem düğmesi 6 satırda her zaman açık, bağlama göre değişmiyor | `1_oyun` sağ sütun | Eylemler kategori sekmelerine: bir satır sekme + yalnızca seçili kategorinin 2–3 düğmesi |
| Yüksek | Ana ekran, masa, mobil | Bildirim kartı Güç Merkezleri başlığını, "Çoklu seçim"i, mobilde sekmeleri ve haber şeridini örtüyor; 3'e kadar birikiyor | `1_oyun`, `m/1_oyun`, `1_masa` sağ üst | Kompakt kart, en çok 2 (mobilde 1); eylem sonucu ayrıca alttaki bilgi kutusunda kalıcı ("Son eylem") |
| Orta | Ana ekran | Kâtip notu gündemin en değerli yerinde 3 satır (mobilde ekranın ~¼'ü) | `1_oyun`, `m/1_oyun` üst | Tek ince satır; başlık satırı kalkar, "menüden kapatılabilir" ipucuna taşınır |
| Orta | Ana ekran | "Çoklu seçim" düğmesi yalnızca operasyon için gerekli ama her zaman görünür | `1_oyun` sağ üst | OPERASYON sekmesinin içine |
| Orta | Ana ekran | Bölüm yardımcı metinleri ("her karar 1 mesai · ertelenen karar…") her hafta tekrar ediyor | `1_oyun` | İlk 4 haftadan sonra yalnızca başlığın ipucunda |
| Düşük | Masa | "Kişiler" etiketinin altında "4 mesai kaldı" yazıyor; kişilerle ilgili bilgi (şüpheliler) yok | `1_masa` sağ | "4 mesai · 1 şüpheli" |
| Düşük | Mobil masa | Alt etiket yazıları Gündem düğmesine çok yakın | `m/1_masa` alt | izlenecek |
Temiz: menü, yeni oyun, ayarlar, harita, medya, oyun sonu sekmeleri; glif taraması temiz.

## İlke
Varsayılan olarak yalnızca en kritik öğeler görünür, gerisi talep üzerine (aşamalı açılım). Strateji oyunlarında yaygın çözüm:
eylemleri seçili kişiye bağlı, kategoriye ayrılmış kısa bir menüde toplamak (Crusader Kings III'ün karakter etkileşim menüsü gibi).

## Yeni sağ sütun (masaüstü)
```
◆ GÜÇ MERKEZLERİ ────────────────────────────
[portre][portre][portre][portre][portre]
[portre][portre][portre][portre]
┌ Viktor Halden · Oligark / Medya Patronu ────┐
│ ●●○ Güç · etkili  ●○○ Tavır · Huzursuz  …   │
└──────────────────────────────────────────────┘
┌ EYLEMLER · Viktor Halden ────────────────────┐
│ [KAZAN] [SÖZ VER] [ÖĞREN] [EMRET] [BASKI] [OPERASYON] │  ← kategori sekmeleri
│ [Huzura Çağır]   [Terfi]   [Gizli Ödeme]     │  ← yalnızca seçili kategori
└──────────────────────────────────────────────┘
┌ (üzerine gelinen eylemin açıklaması / son eylemin sonucu) ┐
└──────────────────────────────────────────────┘
```
- Sekme seçimi hatırlanır. Varsayılan KAZAN. BASKI sekmesinin yazısı kırmızı.
- Sekmenin üzerine gelince alttaki kutu kategoriyi anlatır.
- OPERASYON sekmesinde "Çoklu seçim" düğmesi satırın sonunda.
- Devre dışı düğmeler nedenini ipucunda söylemeye devam eder.

## Kabul ölçütleri
- Ana ekranda eylem paneli 7 satırdan 3 satıra iner; masaüstü ve mobilde taşma yok.
- Bildirim hiçbir zaman sekme başlıklarını ya da portreleri örtmez (en çok 2 kart, kompakt).
- Kâtip notu tek satır.
- `--autoplay`, `--autoplay --mobile`, `--autoplay --full` geçer (otomatik oynatma düğmelere `_buttons[...]` ile basar; gizli kategorideki düğme de çalışır).

## Uygulandı (2026-10-04) — kullanıcı notu: "özellik silme, gerekirse başka yere taşı; ilk girince ne yapacağı anlaşılsın"
Hiçbir özellik silinmedi; hepsi taşındı ya da katlandı:
- **Eylemler** kategori sekmelerinde (`_show_act_cat`, `CAT_TIPS`); 17 düğmenin hepsi duruyor, bir tıkla açılıyor. Otomatik oynatma `_buttons[...]` ile gizli sekmedeki düğmeye de basabiliyor.
- **Çoklu seçim** OPERASYON sekmesine taşındı.
- **Eylem açıklaması / sonucu** ayrı boş kutu yerine eylem panelinin içinde iki satır ("Son eylem" kalıcı).
- **Raporlar** masaüstünde sağ sütunda, güç merkezlerinin altında kompakt liste (`_fill_reports_compact`); tıklayınca kişiyi seçer; kenar rengi raporun söylediği bant. Mobilde Gündem'de (tek sütun).
- **Yol gösterici** "Bu hafta ne yapmalı?" (ilk 3 hafta, ipuçları açıkken): 4 adım, sıradaki altın, adıma tıklayınca ilgili yere gider (`_add_guide`, `_guide_step`, `_guide_go`).
- **Kâtip notu** tek ince satır; mobilde ilk 3 haftada yol gösterici varken gizli.
- **Bildirimler** kompakt, en çok 2 (mobilde 1).
- Bölüm yardımcı metni ilk 4 haftadan sonra gizli.
- Masa: "Kişiler" altında "N mesai · N şüpheli".
- Mobil portre kartları 190 → 132 px: Saray sekmesinde 9 kişinin tamamı tek ekranda.

Doğrulama: `ui_shots` (`--guide`, `--mobile`, yeni `1_saray` görüntüsü), `--autoplay`, `--autoplay --mobile`, `--autoplay --full` geçti.
Kalan: mobilde bildirim haber şeridinin üstüne biniyor (5 sn); eylem önizlemesi (Faz 1).
