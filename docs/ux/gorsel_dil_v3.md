# Görsel dil v3 — bileşen kitabı ve sayfa sırası

Kaynak: kullanıcının onayladığı iki mockup:
- Ana ekran: `docs/ux/ref/ana_ekran_hedef.webp` (ayrıntı: `docs/ux/ana_ekran_hedef.md`)
- Harita: `docs/ux/ref/harita_hedef.jpg`

Kullanıcı isteği: "Her sayfa bu tutarlılıkta olacak." Bu belge, ana ekranda kurulan dili tüm sayfalara taşımak için ortak bileşenleri ve sırayı tanımlar. Kural: **yeni bir sayfada stil uydurulmaz; buradaki bileşen kullanılır.** Bir bileşen yetmiyorsa önce bu belgeye eklenir, sonra kullanılır.

## A. Bileşenler (UIKit'te tek yerde; her sayfa bunları çağırır)
G1 (ana ekran) sırasında yazılan kod bu adlarla `game/ui/ui_kit.gd` (ya da `game/ui/kit/` altında) tek yere toplanır:

| Bileşen | Tanım (mockup'tan) | Kullanıldığı yerler |
|---|---|---|
| `ornate_panel` | koyu zemin, ince çift altın çizgi, dört köşede akantus kıvrımı; isteğe bağlı alt-orta zambak ayıracı; isteğe bağlı soluk filigran (`art/ui/watermark_crest.png`, %6–8) | sol panel, kişi paneli, Eylemler, Divan, Dosyalar, Günlük, menü, modallar, oyun sonu |
| `section_heading` | dolu altın baklava + aralıklı büyük harf serif (altın) + ince çizgi + isteğe bağlı sönük alt başlık; büyük başlıkta çizginin ucunda kıvrım | "İZLEME LİSTESİ", "BU HAFTA…", "Raporlar", Divan grupları, menü sayfaları |
| `portrait_card` | portre yüze yakın, ince parlak altın kenar, iç gölge, alt kısımda ad (beyaz serif, gölgeli) + rol (altın kalın aralıklı büyük harf); seçili: kalın parlak kenar + ışıma; kompakt boy yüz merkezli kırpar | izleme listesi, Divan, vali/komutan, bölge paneli |
| `portrait_frame_large` | büyük portre için süslü altın çerçeve, köşe kıvrımları, sol üstte ışıltı | seçili kişi, kurum paneli, oyun sonu |
| `chip` | yuvarlak köşe, ince kenar, ton zemin, solda çizilmiş simge (yıldız/baklava), serif; tonlar: altın, yeşil, gri, kırmızı | kişi özellikleri, bölge durumu, birlik durumu, yasa etiketleri |
| `report_row` | koyu satır, solda ton çubuğu (yeşil/sarı/kırmızı), küçük çerçeveli portre, kalın ad + serif metin; liste son satırı yarım kesilmez | raporlar, Divan raporları, Günlük, bölge/birlik satırları |
| `tab_strip` | büyük simgeli sekmeler (etkin: açık zemin + parlak kenar) ve küçük büyük-harf sekmeler (etkin: altın plaka + ışıma) | sol sekmeler, Eylemler, medya sekmeleri, menü sayfaları |
| `stepper` | tek çizgide adımlar, ince altın bağlantılar, etkin adım sivri uçlu plaka, tamamlanan yeşil | gündem adımları, tur |
| `ornate_button` | mevcut `art/ui/btn_*` düğmeleri; serif; birincil ("HAFTAYI BİTİR") büyük kıvrımlı | her yer |
| `info_box` | altın kenarlı kutu, solda çizgi simge (zarf vb.), serif metin | danışman notları, ipuçları |
| `map_badge` | yuvarlak altın çerçeveli simge rozeti + koyu plaka üstünde altın büyük harf ad + altta küçük altın üçgen işaret | harita kurumları ve bölgeler |
| `icons` | ince altın çizgi simgeleri, kodla çizilir (glif yok): zarf, klasör, parşömen, sütunlu bina, gazete, mühür, dişli, terazi, taç, madalyon/para, anten, pusula yıldızı, çapraz kılıç, göz, grafik, ejder, defne, baklava, yıldız | gezinme, sekmeler, harita, çipler |
| Yazı | serif (EB Garamond) gövde dahil; en küçük masaüstü 14 px, mobil 15 px; başlıklar aralıklı büyük harf | tümü |
| Renk | mevcut UIKit paleti (GOLD d6b25e, GOLD_DIM, PLATE, TEXT e9e4d6); kırmızı yalnızca tehlike/BASKI; yeşil yalnızca olumlu/tamamlanan | tümü |

## B. Sayfa sırası (her biri ayrı Codex oturumu, ayrı commit'ler, önce/sonra ekran görüntüsü)
1. **G1 — Ana ekran** (sürüyor; `ana_ekran_hedef.md`). Bitince bileşenler A'daki adlarla tek yerde olmalı.
2. **G2 — Gündem ve karar kartları.** En çok görülen ekran: görselli/görselsiz karar kartı, danışman önerisi satırı, "Gerekçeler" açılırı, seçenek düğmeleri, kriz kartı (kırmızı kenar), damga animasyonu, Dosyalar (sırlar, söz defteri) ve Günlük sekmeleri.
3. **G3 — Harita** (aşağıda C bölümü): yeni arka plan + `map_badge` + parmakla yakınlaştırma/kaydırma + bölge katmanı ve kurum/bölge panelleri.
4. **G4 — Divan ve kişiler:** Divan çekmecesi (gruplar `section_heading`, kartlar `portrait_card`, raporlar `report_row`), mobil Kişiler sekmesi, kişi paneli eylemleri.
5. **G5 — Medya merkezi:** gazete/serbest kalem/TV kendi "diegetik" görünümünü KORUR (kâğıt, CRT); yalnızca çerçeve, başlık bandı, sekmeler, düğmeler v3 diline uyar.
6. **G6 — Masa (desk):** nesne etiket plakaları ve rozetleri `map_badge` diliyle; başlık "HAFTA 15 · KRAL ADRİAN IV" v3 başlık stilinde.
7. **G7 — Menü ve diğerleri:** ana menü sayfaları, ayarlar, modallar, Hükümdarlık Arşivi, Hanedan Defteri, başarımlar, oyun sonu ekranı, ilk açılış turu balonları, giriş ekranı (dokunma).
8. **G8 — Mobil tutarlılık geçişi:** tüm sayfalar 1067×600 yatayda; dokunma hedefleri ≥ 44 px; M1 dokunma kuralları; uzun listelerde kaydırma göstergesi.

Her sayfada kapı: önce/sonra ekran görüntüsü (TR+EN, masaüstü+mobil) `docs/ux/ref/` altına JPG karşılaştırma; bu belgedeki bileşenlerin dışında stil kullanılmadığının kontrolü; tüm UI testleri; oynanış değişmez.

## C. Harita (G3) — hedef ve yakınlaştırma
Hedef görünüm `docs/ux/ref/harita_hedef.jpg`:
- Üst çubuk: "BAŞKENT" serif büyük + "Bir kuruma tıkla"; sağda "?" (simge açıklaması) kare düğme, "Bölgeler: Kapalı/Açık" süslü düğme, "Masaya dön". Çubuk koyu, alt kenarı ince altın.
- Kurumlar: binanın ÜSTÜNDE küçük plaka: solda yuvarlak altın çerçeveli simge rozeti, sağda koyu plaka üzerinde altın büyük harf ad, plakanın altında binayı gösteren küçük altın üçgen. Alt satır açıklama (ör. "Soruşturmalar ve hukuk") plakada YOK; açıklama üzerine gelince/tıklayınca panelde. Simgeler: Adliye terazi, Saray taç, Parlamento sütunlu bina, Maliye para yığını, Medya anten, Asteria pusula yıldızı, Genelkurmay çapraz kılıç, İstihbarat göz, Sarne Holding grafik, Drakon ejder, Seravia defne. Plakalar binaları kapatmaz (binanın üstünde durur).
- Arka plan: yeni temiz harita görseli `art/city_map_v3.png` (kullanıcı üretecek; mockup'taki şehir, YAZISIZ). Gelene kadar mevcut `art/city_map.png`. Kurum konumları yeni görsele göre `game/data/city_map.json`'da güncellenir (mockup'taki konumlar yüzdeyle).
- **Parmakla yakınlaştırma/uzaklaştırma ve kaydırma:** iki parmakla sıkıştırma (pinch; `InputEventMagnifyGesture` + iki dokunuşun mesafesi), tek parmakla sürükleme kaydırma (yakınlaştırılmışken), çift dokunma yakınlaştır/sıfırla; masaüstünde fare tekerleği (imleç merkezli) ve sol tıkla sürükleme. Ölçek 1.0–2.5, harita kenarları ekran dışına taşmaz (sınırlı kaydırma), yumuşak geçiş. Plakalar ve bölge işaretçileri haritayla birlikte taşınır ama **yazı boyutu sabit kalır** (ters ölçek), okunur. Kısa dokunma (M1 kuralı) kurumu açar; sürükleme ve sıkıştırma hiçbir kurumu açmaz. "Sıfırla" küçük düğmesi (yakınlaştırılmışken görünür). Mobil ve masaüstü testleri: tests/map_zoom_test.gd (sentetik pinch, sürükleme, sınırlar, kısa dokunma hâlâ açar, sürükleme açmaz).
- Bölge katmanı: bölge işaretçileri `map_badge` dilinde; bölge paneli `ornate_panel` + `portrait_card`.

## D. Uygulama kontrol listesi

| Sayfa / Bileşen | Durum | Karşılandı / Kısmen + Neden |
|---|---|---|
| (1) Gündem: Karar kartı (görselli, görselsiz, kriz/kırmızı, çok kararlı gezinme, Gerekçeler açılırı, damga animasyonu) | Karşılandı | Tek süslü altın/kırmızı çerçeve (border_width 0), 1 px altın görsel kenarı, EB Garamond başlık, Alegreya Sans gövde metni, ChoiceButton stili, _trait kalıbında çipler, danışman portrelerinde 1 px kenarlık ve bölüm başlığı. |
| (1) Dosyalar sekmesi (Sırlar ve kanıtlar, Söz defteri) | Karşılandı | Rapor satırı kalıbında kanıt satırları (koyu zemin, ton çubuğu, portre, kalın ad, çipler), Söz defteri tek süslü çerçeve ve rahat satır aralıklı tipografi. |
| (1) Günlük sekmesi | Karşılandı | Alegreya Sans ve EB Garamond başlıklar, rahat satır aralığı, temiz sol panel düzeni. |
| (2) Divan çekmecesi (gruplar, portre kartları, raporlar, vali/komutan kartları) | Karşılandı | Çekmecede tek süslü altın çerçeve (border 0) ve soluk filigran, raporlar satır kalıbında (ton çubukları, rahat boşluk), grup başlıklarında altın baklava ve caps Garamond, portre ve vali/komutan kartlarında 1 px ince altın kenar. |
| (3a) Başkent haritası (görsel dil: arka plan, kurum plakaları, bölge katmanı, kurum ve bölge panelleri) | Karşılandı | art/city_map_v3.png arka plan, simgeli dairesel rozet + altın caps ad + altın üçgen iğne (map_badge), bölge işaretçileri map_badge dilinde, kurumlarda ve bölgelerde tek süslü altın çerçeve (border 0) + soluk arma filigranı, 1 px altın portre/görsel kenarı, rapor satırı görevli/vali kalıbı, üst bant band_style ve kare legend butonu. |
| (3b) Harita yakınlaştırma ve kaydırma (pinch, tekerlek, sürükleme, sınırlar, ters ölçek, sıfırla düğmesi) | Karşılandı | İki parmakla sıkıştırma (pinch), fare tekerleğiyle imleç merkezli zoom, tek parmak/fare ile sınırları koruyarak kaydırma (1.0-2.5x ölçek), kenarlar ekran dışına taşmaz / siyah boşluk bırakmaz, plaka ve işaretçilerde ters ölçekle sabit 1x yazı boyutu, kısa dokunma kurumu açarken sürükleme esnasında kurum açılmaz, yakınlaştırılmışken 'Sıfırla' düğmesi ve çift dokunma/tıklama ile sıfırlama, tests/map_zoom_test.gd ile doğrulandı. |
| (4) Medya merkezi (gazete ve CRT TV diegetik görünüm, başlık bandı, sekmeler, düğmeler) | Karşılandı | Gazete (Veloria Haber, Serbest Kalem kâğıt shader ve tramlar) ve Sarne TV (CRT shader ve ahşap kasa) diegetik görünümü tamamen korundu; üst başlık bandı band_style, sekmeler v3 altın süslü sekme dili (tab_normal/tab_active, caps Garamond, dokunma alanı 44 px), Masaya dön düğmesi GhostButton ve 44 px dokunma hedefi. |
| (5) Masa (nesne etiket plakaları, simge rozetleri, v3 başlık ve buton) | Karşılandı | Nesne etiket plakaları map_badge dilinde (koyu zemin, ince altın kenarlık, 3 px köşe pahı, yumuşak gölge); sol tarafta altın dairesel rozet ve kodla çizilen vektörel altın simgeler (pusula, taç, defne, yıldız, terazi, göz, anten); altın caps Garamond başlıklar (Color("fff3d0")); altın çerçeveli kırmızı hap bildirim rozeti (Alegreya Sans kalın); alt özet satırı Alegreya Sans 13-14 px; üst başlık bandı altın caps Garamond (32 px) + 460 px divider + Alegreya Sans alt başlık; alt buton PrimaryButton ve caps Garamond (20 px, 68 px dokunma hedefi). |




