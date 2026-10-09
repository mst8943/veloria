# Gündem ekranı sadeleştirme v2 (UX turu 5)

Tarih: 2026-10-09. Kaynak: kullanıcı geri bildirimi "ilk açınca çok karışık; özellik silmeden, kişileri ayrı bir yere/kaydırmaya alıp ferahlat". Önceki tur: `docs/ux/ana_ekran_sadelestirme.md` (eylemler sekmelere katlandı). Bu tur, kadro 9'dan 14'e çıkınca yeniden dolan ekranı hedefler.

## İnceleme (1280x720 ekran görüntüsü, 8. hafta)
| Önem | Sorun | Neden | Öneri |
|---|---|---|---|
| Yüksek | Sağ sütunun üçte biri 14 portre kartı (3 satır) | Kadro büyüdü; her kart her an açık, hepsi aynı ağırlıkta | Dikkat çeken kişiler şeridi + "Divan" çekmecesi |
| Yüksek | Aynı anda 3 dikey blok yarışıyor: kişi kartları, kişi bilgisi + eylemler, raporlar | Hiçbiri daralmıyor; boş "Bir kişi seç" kutusu bile yer tutuyor | Seçim yokken eylem/bilgi bloğu kapalı; seçince açılır |
| Yüksek | Sol sütunda iki karar kartı üst üste; her kartta 2 danışman alıntısı + 3 seçenek | Hepsi tam açık; ikinci kart yarım görünüyor, kaydırma gerekiyor | Karar sırası: aynı anda bir tam kart, diğerleri tek satır |
| Orta | Danışman görüşü her kartta uzun alıntı | Birincil karar bilgisi değil, destek | Tek satır özet; tıklayınca tam alıntı |
| Orta | Rapor listesi 10 satır | Her hafta hepsi gösteriliyor | Değişenler önce, ilk 4 + "tümü" |
| Düşük | Üst şeritte aynı anda yol gösterici + haber + bildirim | Üç ayrı dikkat alanı | Bildirim ve haber tek satırda sırayla |

## Oyuncu soruları (en çok 3)
1. Bu hafta hangi karar bekliyor ve seçenekler ne?
2. Kime ne yapayım, kimden endişelenmeliyim?
3. Geçen haftadan beri ne değişti?

## Tasarım ilkesi
Varsayılan ekranda yalnızca bu üç sorunun cevabı. 14 kişinin tamamı, 4 eylem sekmesinin tamamı ve rapor listesinin tamamı bir tık ötede; hiçbir özellik silinmiyor, hiçbir bilgi gizli bilgi sızdırmıyor.

## Yeni yerleşim (masaüstü 1600x900)
```
┌ KRAL ADRIAN IV   HAFTA 8/104  ⌛ ◆◆◆◆  ⛁13        Masa  Medya  Kaydet  Menü ┐
├───────────────────────────────────────┬──────────────────────────────────────┤
│ [Gündem] [Dosyalar] [Günlük]          │ ◆ DİKKAT                             │
│ ◆ Karar 1/2        ● ○                │ [Prens●][Arden][Sarne][Vale][+9]     │  ← kişi şeridi (5 slot)
│ ┌───────────────────────────────────┐ │   (+9 / "Divan" → çekmece)          │
│ │ [görsel] BAŞLIK                   │ │                                      │
│ │ Metin (2–3 satır)                 │ │ ◆ BU HAFTA DEĞİŞENLER                │
│ │ Danışmanlar: Prens ▸ II · Vale ▸ III│ │ ● Veyra raporu kötüleşti            │
│ │ I   seçenek                       │ │ ● Sarne tavrı sertleşti              │
│ │ II  seçenek                       │ │ ○ Helena listeyi daralttı            │
│ │ III seçenek                       │ │ [Tüm raporlar (10)]                  │
│ └───────────────────────────────────┘ │                                      │
│ Sırada: ▸ General kendi subaylarını…  │ (kişi seçilince bu blok yerini        │
│          (2 hafta kaldı)              │  KİŞİ KARTI + EYLEMLER'e bırakır)    │
├───────────────────────────────────────┴──────────────────────────────────────┤
│ Mesai 4/4 · 2 karar bekliyor · Medya okunmadı                [ HAFTAYI BİTİR ]│
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1. Kişi şeridi + Divan çekmecesi (ana öneri)
- **Şerit:** sağ üstte tek satır, en çok 5 slot; kişi başına küçük portre + ad + durum noktası. Slot önceliği: (1) bekleyen karardaki danışmanlar, (2) bu hafta raporu/tavrı değişenler, (3) şüphe/komplo işareti olanlar, (4) seçili kişi, (5) son eylem yapılan. Eksik slotlar sabit çekirdeğe (Arden, Vale, Veyra, Sarne, Prens) tamamlanır. Şerit bilgi sızdırmaz: yalnızca oyuncunun zaten görebildiği değişimleri öne çıkarır.
- **Divan düğmesi** (şeridin sonunda "+9" / "Divan"): sağdan kayan çekmece (ya da orta kaplama) açar: 14 kişi 4 grupta, grup başlığı altında portre kartları:
  - **Hanedan**: Helena, Prens Marcus, Julian
  - **Devlet**: Arden, Vale, Veyra, Renn
  - **Güç ve kamuoyu**: Sarne, Sarn, Voss
  - **Dış ilişkiler**: Varos, Duvall, Malenkov, Lucien (grup başlığında "Elena Varos'un bandı")
  Üstte arama/süzgeç yok (14 kişi için gerekmez); yerine grup başlıklarına tıklayınca katlanır. Kart tıklanınca çekmece kapanır ve kişi seçilir. Esc kapatır; klavye 1–9 kısayolları şerit slotlarına.
- **Kişi kartı uyarı rozetleri** (şeritte ve Divan'da): kırmızı nokta = düşman/komplo, altın nokta = bekleyen kararda söz sahibi, mavi nokta = yeni rapor. Rozetler mevcut gösterilen bilgiyle sınırlı.
- **İlk 3 hafta (yol gösterici açıkken):** şerit yerine, çekirdek 5 kişi sabit ve altında "Diğer kişiler Divan'da" ipucu.

### 2. Kişi seçilince
- Sağ sütunun alt yarısı **KİŞİ KARTI + EYLEMLER** olur (şu anki "Victor Sarne" bloğu aynen); rapor bloğu kısalır (başlık satırı + "değişenler" 3 satır).
- Seçim yokken eylem bloğu YOK (boş "Bir kişi seç" kutusu kalkar; yerine tek satırlık ipucu şeridin altında).
- Seçimi kaldırmak: kartta "×" veya Esc.

### 3. Karar sırası (sol sütun)
- Bekleyen kararlar **tek tam kart** + altında "Sırada" satırları (başlık + kalan hafta). Kart başlığında "Karar 1/2" ve noktalar; ok/tuş (←/→) ya da sıradaki satıra tıklayarak geçiş.
- **Meclisin görüşü** tek satıra iner: portre + "II'yi öneririm · bence III (çıkarı var)". Tıklayınca (ya da "Gerekçeler ▾") mevcut tam alıntılar açılır. Hiçbir bilgi kaldırılmıyor.
- Karar kartı görseli yan yana kalır (240x135 → kartın yüksekliğini yüzde 60 azaltır).

### 4. Raporlar
- "Bu haftanın raporları" yerine **"Bu hafta değişenler"**: önce değişen (kötüleşen/iyileşen) raporlar, sonra diğerleri; ilk 4 satır + "Tüm raporlar (10)" düğmesi (mevcut liste çekmece/kaplama içinde).
- "Geçen haftadan beri" bloğu sol sütundan buraya taşınır (aynı veri; tek yerde).

### 5. Üst şerit
- Yol gösterici, haber şeridi ve bildirim tek satırda sırayla (öncelik: acil bildirim > haber > ipucu), en çok 2 öğe yan yana. Kâtip notu ipuçları açıkken ilk 3 haftada.

## Mobil (1067x600)
- Sekmeler: **Gündem · Kişiler · Raporlar** (Saray sekmesi "Kişiler" olur).
- Kişiler sekmesinde **yatay kaydırmalı portre şeridi** (grup başlıklarıyla: Hanedan | Devlet | Güç | Dış) ve altında seçili kişinin kartı + eylemler; Divan çekmecesi yerine tam ekran liste.
- Gündem'de aynı "tek tam kart + Sırada" düzeni; danışman görüşü tek satır.

## Durumlar
| Durum | Davranış |
|---|---|
| Karar yok | Karar bloğu "Bu hafta bekleyen karar yok. Kişilerle ilgilen ya da haftayı bitir." |
| Tek karar | "1/1" göstergesi yok, "Sırada" satırı yok |
| Seçim yok | Eylem bloğu kapalı; ipucu satırı: "Bir kişi seç. Sayıları göremezsin; yalnızca davranışlarından tahmin edebilirsin." |
| Düşman kişi | Kartta kırmızı çerçeve + "Düşman" etiketi, şeritte öncelikli |
| Divan açık | Arkası SHADE ile karartılır, Esc/dış tıklama kapatır, odak çekmecede |
| Mesai yok | Eylem düğmeleri devre dışı, nedeni ipucunda (mevcut davranış) |

## Etkileşim ve uygulama notları
- Dosyalar: kişi kartları `game/ui/person_panel.gd` (kart üretimi, ACTION_META), ana yerleşim `game/ui/main.gd` (`_grid`, `_build_ui`), gündem `game/ui/agenda_view.gd` (karar kartı, raporlar). Yeni bileşen: `game/ui/divan_view.gd` (`_init(main)` + `host`; preload; class_name yok).
- 14 kart nesnesi AYNI kalır (şerit/Divan yalnızca kapsayıcıyı değiştirir); `--autoplay` ve `ui_input_test` kişi seçimini kartlar üzerinden yaptığından kartlar görünmez olsa da `_cards[id]` erişilebilir kalmalı. Görünmez kapsayıcıda mouse_filter IGNORE.
- Şerit önceliği saf bir fonksiyon (`strip_ids() -> Array`) olsun; birim testi: çekirdek 5'e tamamlama, değişen raporun öne çıkması, seçili kişinin her zaman görünmesi, tekrar yok.
- Animasyon: çekmece 0,18 sn kayma (`_fast()` ise anında), `Sfx.play("paper")`.
- Yeni metinler `tr()` + `en.po` (İngilizce: "Watchlist", "Court", "State", "Public & power", "Foreign affairs", "All reports", "Up next", "Why? ▾" gibi; glif yok, ▸ ▾ çizilsin).

## Kabul ölçütleri (ux-review kontrol edecek)
- İlk açılışta (8. hafta, 2 bekleyen karar) ekranda en çok 7 ana blok (başlık, karar kartı, sırada satırı, kişi şeridi, değişenler, durum çubuğu, haftayı bitir); kaydırma çubuğu sol sütunda gerekmez.
- 14 kişinin hepsine ≤ 2 tıkla ulaşılır; Divan'da gruplar okunur; mobilde 1067x600'de taşma yok.
- Karar kartında danışman alıntıları varsayılanda tek satırda; tam metin bir tıkla.
- Seçim yokken boş eylem kutusu yok.
- `--autoplay`, `--autoplay --mobile`, `--autoplay --full`, `ui_input_test` geçer; Türkçe/İngilizce ekran görüntüleri taşmasız (İngilizce daha uzun).
- Hiçbir özellik silinmedi: eylem sekmeleri, 14 kişi, raporlar, Dosyalar/Günlük, yol gösterici hepsi erişilebilir.

## Görsel taslak promptları (kullanıcı üretir, sonra uygulanır)
Hepsi: `Use the attached screenshot as the exact style reference (dark walnut and gold game UI, serif headings, thin gold borders). Redesign only the layout as described. Game UI mockup, 16:9, 1600x900. Do not render readable paragraphs: use short placeholder labels exactly as given and abstract grey lines for body text. No watermark.`

**Ana ekran:**
```
Layout: a left column and a right column under a thin header bar (title "KING ADRIAN IV", "WEEK 8 / 104", small icons, four text links on the right). LEFT: tabs "Agenda, Files, Journal"; one large decision card: image on the left (a dim banquet scene), title line, two abstract text lines, one single-line advisor summary with two tiny portraits and the words "advisors: II / III", then three wide choice buttons labelled I, II, III; below it a slim collapsed row "Up next: General brings his officers (2 weeks left)". RIGHT: a section "WATCHLIST" with a single horizontal strip of five small portrait tiles (names under each, tiny colored status dots) and a final tile "+9 Court". Below it a section "CHANGED THIS WEEK" with four one-line rows with small colored dots and a button "All reports (10)". The right column has generous empty space; nothing else. Bottom bar: "Actions 4/4 · 2 decisions waiting" on the left and one large gold button "END WEEK" on the right.
```
**Divan çekmecesi:**
```
Layout: same screen dimmed behind, a drawer sliding in from the right covering 45% of the width, titled "THE COURT". Four collapsible groups with thin gold dividers: "Dynasty" (3 portrait cards), "State" (4 cards), "Public & power" (3 cards), "Foreign affairs" (4 cards, a small note "Report by the Foreign Minister"). Each card is a small framed portrait with the name beneath and one tiny colored status dot; one card is highlighted with a gold frame. A close "×" at the top right.
```
**Kişi seçilince:**
```
Layout: same main screen, but the right column shows below the watchlist strip a framed person panel: a medium portrait, name and title, three small status chips with dots, then a row of seven small category tabs and three action buttons, then two short abstract text lines. The "changed this week" list is reduced to three rows under it.
```
**Mobil (yatay 1067x600):**
```
Layout: landscape phone game UI. Bottom tab bar with three tabs "Agenda, People, Reports". People tab: a horizontally scrollable strip of portrait tiles grouped by small labels "Dynasty | State | Power | Foreign", and below it the selected person's panel with action buttons. Large touch-friendly buttons.
```

## Taslak görsellere kararlar (2026-10-09)
Kullanıcı dört taslak üretti: `docs/ux/taslak_v2/` (`1_ana_ekran`, `2_divan`, `3_kisi_secili`, `4_mobil_kisiler`; `.gdignore` var, Godot içe aktarmaz). Karakter adları ve portreler görsel modelin uydurmasıdır; yalnızca YERLEŞİM referanstır.

### Aynen alınanlar
- **Ana ekran (1):** sol tek tam karar kartı (görsel solda, başlık, tek satır danışman özeti + iki mini portre, I/II/III geniş seçenekler), altında katlanmış "Sırada" satırı (kum saati çizilir, ▾ çizilir); sağda WATCHLIST şeridi (5 portre + "+9 Divan" karosu), altında "BU HAFTA DEĞİŞENLER" (4 satır + "Tüm raporlar (10)"); altta durum çubuğu ve tek büyük altın "HAFTAYI BİTİR".
- **Divan (2):** sağdan kayan çekmece, dört katlanır grup (Hanedan / Devlet / Güç ve kamuoyu / Dış ilişkiler), grup başlığında küçük simge ve ▾/▴; seçili kartta altın çerçeve; "Dış ilişkiler" grubunda "Dışişleri Bakanı'nın raporu" notu; sağ üstte kapatma.
- **Kişi seçili (3):** şeridin altında kişi bloğu: portre, ad, unvan, durum çipleri, kategori sekmeleri, eylem düğmeleri, kısa açıklama; "Bu hafta değişenler" alta üç satıra iner.
- **Mobil (4):** alt sekme çubuğu (Gündem / Kişiler / Raporlar), Kişiler'de üstte GRUP SEKMELERİ (Hanedan / Devlet / Güç / Dış), altında yatay kaydırmalı portre şeridi (iki yanda ok), altında seçili kişinin bloğu ve geniş dokunma hedefli eylem düğmeleri.

### Değiştirilenler (oyunun kuralları)
| Taslakta | Sorun | Uygulamada |
|---|---|---|
| Başlıkta "1.2K / +6 / 78 / 92" gibi kaynak sayıları | "Sayı yok" ilkesine aykırı | Mevcut başlık aynen kalır (hafta, mesai, kasa göstergesi, Masa/Medya/Kaydet/Menü) |
| Portre köşesinde yeşil/sarı/kırmızı nokta = sadakat/nüfuz/hırs gibi okunur | Gizli değerleri sızdırır | Nokta yalnızca GÖRÜLEBİLİR duruma bağlı: kırmızı = düşman/komplo belirtisi görüldü, altın = bekleyen kararda söz sahibi, mavi = yeni/değişen rapor; hiçbiri sadakat/hırs değil |
| Kişi çipleri "Loyal / Influential / Ambitious" (renkli) | Gizli değerleri adlandırıyor | Mevcut çipler kalır: Güç · etkili, Nüfuz, Medya, Tavır (üç kademeli bant, kural dışı bilgi yok) |
| Kategori sekmeleri yalnızca simge | Öğrenilebilirlik düşer | Metin etiketli sekmeler (KAZAN, SÖZ VER, ÖĞREN, EMRET, BASKI, OPERASYON, DEVLET) kalır; simge eklenirse etiketle birlikte ve çizilmiş şekil olarak |
| "Influence" listesi yeşil ▲ / kırmızı ▼ ok | Gizli değerin yönünü gösterir | Yalnızca oyuncunun zaten gördüğü değişim (Geçen haftadan beri) gösterilir; ok yok, değişim cümlesi var |
| Üst gezinme "Realm / Map / Codex / Settings" | Oyunda yok | Mevcut: Masa, Medya, Kaydet, Menü |
| "Changed this week" satırlarında tema simgeleri (buğday, kule, kılıç) | Web'de glif/simge riski | Renkli nokta + kısa cümle; simge gerekirse çizilmiş şekil (glif değil) |

### Eklenenler (taslakta yok)
- Şerit önceliği saf fonksiyon (`strip_ids`) ve birim testi (yukarıda).
- İlk 3 hafta çekirdek 5 kişi + "diğerleri Divan'da" ipucu.
- Divan'da klavye: Esc kapatır; kişi seçilince çekmece kapanır.
- Danışman özet satırında "Gerekçeler ▾" ile tam alıntı.

### Uygulama sırası (dilimler)
1. U1: Kişi şeridi + Divan çekmecesi (masaüstü); kartlar aynı nesneler; `strip_ids` + testler.
2. U2: Karar sırası (tek tam kart + "Sırada"), tek satır danışman özeti.
3. U3: "Bu hafta değişenler" + "Tüm raporlar"; kişi seçilmeden eylem bloğu kapalı.
4. U4: Mobil (3 sekme, grup sekmeleri, kaydırmalı şerit).
Her dilimde `--autoplay` (masaüstü/mobil/--full), `ui_input_test`, TR+EN ekran görüntüleri; denge etkilenmez (yalnızca arayüz): ölçüt probe tabanla birebir aynı.

## Sonuç

**U3b + U4 tamamlandı (2026-10-10).** Sağ sütunda oyuncunun haftalık eylem ve sonuçları “Bu hafta” altında; danışman raporları “Raporlar / Reports” altında. Mobil ana sekmeler Gündem, Kişiler ve Raporlar; Dosyalar ile Günlük, Raporlar sekmesinin alt sekmeleri olarak erişilebilir. Kişiler ekranında Hanedan, Devlet, Güç ve Dış grupları 14 mevcut kartı kapsar; portreler yatay şerit ve çizilmiş oklarla gezinir. Seçim ayrıntısı ve eylemler kaydırılabilir alt alanda kalır; dokunma hedefleri en az 44 px. Gündem’de U2’nin tek tam karar kartı ve Sırada akışı, Raporlar’da değişenler ve tam rapor listesi korunur.

KAPI: `sim_test`, `event_check`, `save_test`, `content_check`, `i18n_check`, `pacing_test`, `ui_logic_test`, masaüstü/mobil `ui_input_test`, `unit_tests` (399/399) ve İngilizce `event_check`/`content_check` geçti. Masaüstü otomatik oynatma üç tur; mobil otomatik oynatma ve TR/EN tam kampanya aynı sonuçla tamamlandı. `advice_weighted` 80 kampanya ölçütü TR/EN **68/80, 36/80, 16/80**, tabanla aynı. Gözle kontrol edilen TR/EN masaüstü ve 1067×600 mobil kanıtları: `C:/Users/USER/Desktop/oyun_u3b_u4_shots/` (`final-desktop-{tr,en}`, `final-mobile-{tr,en}`); U3b başlık kanıtları `u3b-{tr,en}` klasörlerinde. Mobil görüntülerde taşma, kırpılma veya karışık dil görülmedi.
