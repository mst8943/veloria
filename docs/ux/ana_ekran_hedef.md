# Ana ekran — hedef görünüm (mockup birebir)

Hedef: `docs/ux/ref/ana_ekran_hedef.webp` (kullanıcının onayladığı mockup, 1495×840).
Önceki durum: `docs/ux/ref/ana_ekran_onceki.jpg` (aynı an: Hafta 1, bekleyen karar yok, Nadir Vale seçili, 1600×900).
Kullanıcı isteği: "Bu sayfanın aynı böyle olmasını istiyorum." Aşağıdaki farkların HEPSİ uygulanır; "Mockup hatası" diye işaretlenenlerde mockup değil, belirtilen doğru davranış uygulanır.

## 0. Genel
- **Yazı tipi:** mockup'ta gövde metinleri dahil neredeyse her şey serif (EB Garamond, `UIKit.serif()`): şerit, sekme adları, açıklama kutuları, raporlar, çipler, alt bilgi. Şu an gövde metni sans. Masaüstünde gövde metni serife geçer; okunurluk için gövde boyutu serifte ~1–2 pt büyür. Mobilde de serif, ama en küçük metin 15 px altına inmez.
- **Altın süs dili:** her panelde köşe süsleri (kıvrım/akantus), ince çift altın çizgi, ortada küçük zambak (fleur-de-lis). Mevcut `art/ui/frame_panel*.png` dokuz dilim çerçeveleri temel alınır; eksik süsler aşağıdaki görsellerden ya da kodla çizilir.
- **Simgeler:** web'de sistem glif yedeği yok; ✦ ◈ ◆ ⚜ gibi semboller yazı karakteri olarak KULLANILMAZ, `draw_*` ile ya da PNG ile çizilir.
- **Ölçek:** mockup 1495 genişlikte; 1600×900'de oranlar korunur (×1,07).

## 1. Başlık bandı (en büyük değişiklik)
Mockup iki katmanlı:
1. **Üst resim şeridi** (~55 px): saray içi, kırmızı sancaklar, mumlar, sütunlar (yeni görsel `art/ui/header_bg.png`). Koyu, merkez sakin.
2. **Altın çerçeveli bilgi çubuğu** (~70 px): koyu zemin, üst ve altta ince altın çizgi, bölümler arasında ince dikey ayraçlar.

Sol uç: altın aslan heykeli (`art/ui/lion.png`, sağda yatay aynalanmış aynısı). Aslanın yanında **taçlı kral büstü** (`art/ui/king_bust.png`, saydam), bilgi çubuğundan yukarı taşar (üst şeride biner); mevcut küçük kare portre kutusu kalkar.
Sonra: zambak simgesi + ince dikey ayraç + **"KRAL ADRİAN IV"** (serif, ~38 px, altın, gölge).
**Hafta plakası:** uçları sivri/kıvrımlı, ince altın çerçeveli koyu plaka; solda dolu altın baklava, "HAFTA 1 / 104" (serif ~20 px beyaz), altında plakanın içinde ince ilerleme çizgisi (mevcut ilerleme çubuğu buraya taşınır, uçlarında küçük süs).
**Arma:** hafta plakası ile mesai baklavaları arasında, iki katmana taşan taçlı aslanlı kalkan (`art/ui/crest.png`).
**Mesai:** büyük altın baklavalar; harcanan mesai içi boş (yalnızca çerçeve) baklava. Kum saati simgesi KALKAR. (Mockup hatası: mockup'ta 4 dolu + 1 boş = 5 baklava var, altta "Mesai 3/4" yazıyor. Doğrusu: toplam mesai kadar baklava, 3/4 ise 3 dolu + 1 boş.)
**Hazine:** ayraç + sandık simgesi + sayı (mevcut).
Sol bölüm (unvan → hazine) tek bir plaka gibi biter, sağ ucu ok/sivri süsle kapanır.
**Sağ gezinme:** her öğe simge + serif metin, aralarında ince dikey ayraç: "Masa" (sütunlu bina simgesi), "Medya · yeni sayı" (gazete simgesi), "Kaydet" (mockup'ta kum saati; mesaiyle karışmasın diye mühür/kayıt defteri simgesi kullan, bkz. Kararlar), "Menü" (dişli). Sağ uçta ikinci aslan.
Bandın altında süslü altın çizgi.

## 2. Haber/alamet şeridi
- Serif, beyaz-krem (~16 px); öğe ayıracı küçük altın baklava (çizilir), "·" değil.
- Solda düz amber çubuk yerine küçük altın kıvrım süsü; zemin hafif koyu, alt çizgisi ince.
- İçerik dinamik kalır (mockup'taki "Vale sana kalın bir dosya bıraktı…" yalnızca örnek).

## 3. Sol sekmeler (Gündem / Dosyalar / Günlük)
- Daha büyük sekmeler (~46 px yükseklik, serif ~18 px), her biri simgeli: zarf, klasör, parşömen/kitap. Etkin sekme daha açık zemin + parlak altın kenar; edilgenler koyu, sönük altın kenar. Bekleyen karar varsa "· 1" sayacı korunur.

## 4. Sol panel
- Çerçeve köşeleri mevcut gibi süslü; **panel zemininde soluk arma filigranı** (`art/ui/watermark_crest.png`: taç, kalkan, iki aslan, kıvrımlar; ~%6–8 opaklık, boş alanın ortasında).
- "BU HAFTA NE YAPMALI?" altın aralıklı büyük harf; altında ortada süslü ince altın çizgi.
- **Adım çubuğu:** dört adım tek yatay çizgi üzerinde, aralarda ince altın bağlantı çizgileri; tamamlanan adım yeşil; etkin adım uçları sivri (altıgen) altın çerçeveli plaka içinde; diğerleri sönük. Numaralar serif.
- Açıklama satırı serif.
- Zarflı uyarı kutusu: altın kenarlı kutu, solda büyük çizgi zarf simgesi, serif metin.
- "Bu hafta bekleyen karar yok…" serif.

## 5. Sağ sütun
### 5.1 İzleme listesi
- Başlık "◆ İZLEME LİSTESİ" + sağa uzanan süslü kıvrımlı çizgi (uçta kıvrım).
- Kartlar ~%10 büyük; portre yüze daha yakın (yüz kartın üst 2/3'ünde); **çerçeve:** ince parlak altın kenar + iç gölge; seçili kartta daha parlak/kalın altın kenar ve hafif ışıma. Ad beyaz serif (gölgeli), rol altın, kalın, aralıklı büyük harf (şimdiki sönük gri-altın yerine parlak).
- "+16 Divan" aynı.
- "Diğer kişiler Divan'da": serif, krem-beyaz, ~16 px (şimdiki küçük sans gri değil).

### 5.2 Seçili kişi paneli
- Panel: süslü altın çerçeve (köşelerde kıvrım), alt kenarın ortasında zambak süsü ve iki yana kıvrımlı çizgi (bu süs, alttaki Eylemler paneliyle ayıraç görevi görür).
- **Portre büyür** (~120×110 px, şimdiki ~70×65) ve kendi süslü altın çerçevesine girer (köşe süsleri, sol üstte küçük yıldız/ışıltı).
- Ad "Nadir Vale" serif ~24 px beyaz; unvan serif ~17 px krem.
- **Çipler:** yuvarlak köşeli, ince kenarlı, renk tonlu zemin: "Güç · etkili" (altın ton, iki küçük altın yıldız simgesi), "Tavır · Sakin" (yeşil ton, yeşil yıldız), "Zayıf nokta: ?" (gri ton, gri baklava), "Kırmızı çizgi: ?" (kırmızı ton, kırmızı baklava). Serif ~15 px. Simgeler çizilir. Mevcut nokta göstergesi (●●○) yerine simge; güç seviyesi bilgisi kaybolmasın: yıldız sayısı = seviye.
- Mockup'ta seçimi kaldıran "×" düğmesi yok. İşlev korunur: "×" panelin sağ üst köşesine küçük, sönük bir kapatma simgesi olarak taşınır (testler `clear_button` kullanıyor).
- (Mockup hatası: seçili kişi panelindeki portre bir kadın; Nadir Vale erkek. Gerçek portre kullanılır.)

### 5.3 Eylemler paneli
- Süslü çerçeve köşeleri; "EYLEMLER · Nadir Vale" serif.
- Sekme satırı: etkin sekme parlak altın kenarlı plaka + ışıma; diğerleri serif büyük harf; BASKI kırmızı. **Düzelt:** "OPERASYO(N)" kesilmesin (sığmazsa yazı küçülsün ya da sekmeler sıkışsın); "Halk" → "HALK" (diğerleriyle aynı biçim). (Mockup da bu iki hatayı taşıyor; uygulanmaz.)
- Eylem düğmeleri mevcut süslü düğmeler, serif.
- Düğmelerin altı: mockup bir sekmenin (Öğren) altın başlıklı **açıklamasını** gösteriyor ("Raporları doğrula, zayıf noktayı ve kırmızı çizgiyi araştır, soruşturma aç."). Davranış: fare bir sekme ya da eylemin üzerindeyken (mobilde uzun basışta) bu alan o sekmenin/eylemin açıklamasını gösterir; boştayken "Son eylem" bilgisi gösterilir. Başlık altın kalın serif, metin serif.

### 5.4 Bu hafta değişenler / Bu hafta / Raporlar
- Başlıklar: büyük altın baklava + aralıklı büyük harf serif (~18 px), ardından ince çizgi ve sönük alt başlık ("önce değişenler", "yaptıkların ve sonuçları").
- Metinler serif krem.
- "◆ Raporlar" başlığı serif altın + çizgi.
- Rapor satırları: koyu satır zemini, solda renkli dikey çubuk (rapor tonu: iyi/nötr yeşil, kötüleşen/olumsuz kırmızı-turuncu), küçük çerçeveli portre (~48×44), ad kalın serif beyaz, metin serif. Satır yüksekliği metne göre; son satır yarım kesik görünmesin (şimdiki ekranda 4. rapor yarıda kesiliyor): liste ya tam satırla biter ya da alt kenarda yumuşak solma + kaydırma göstergesi olur.
- Değişenler + Bu hafta + Raporlar bölümü sağda/altta süslü köşeli bir çerçeve içinde durur (mockup'ta sağ üst ve sağ alt köşe süsü görünüyor).

## 6. Alt bilgi
- Sol bilgi şeridi: ince altın çerçeve, solda kıvrımlı uç süsü; "Mesai 3 / 4 • Medya okunmadı" serif altın-krem.
- "HAFTAYI BİTİR »" mevcut süslü düğme (mockup'ta aynı), serif aralıklı.

## 7. Kararlar (kullanıcıya soruldu; aksi söylenmedikçe varsayılan uygulanır)
1. **Gövde yazısı serif** — evet (mockup). Mobilde en küçük metin 15 px.
2. **Kral büstü:** oyundaki kralın (art/portraits/king.png, koyu saçlı Adrian) taçlı büstü üretilir; mockup'taki gri sakallı farklı yüz değil.
3. **Kaydet simgesi:** kum saati değil (mesaiyle karışır), mühür/kayıt defteri simgesi.
4. **Seçimi kaldır "×":** korunur, köşede küçük.
5. **Mesai baklavaları:** toplam mesai kadar; harcanan içi boş.

## 8. Gereken görseller (kullanıcı üretir; gelene kadar kod yer tutucuyla çalışır)
| Dosya | Boyut | Not |
|---|---|---|
| `art/ui/header_bg.png` | 2400×220, opak | saray içi şerit: kırmızı sancaklar, mumlar, sütunlar, heykeller; koyu; yazı yok |
| `art/ui/lion.png` | 640×800, saydam | altın aslan heykeli, sola bakan; sağdaki aynalanır |
| `art/ui/crest.png` | 600×720, saydam | taçlı kalkan, içinde ayakta aslan, altın; yazı yok |
| `art/ui/king_bust.png` | 900×900, saydam | taçlı Kral Adrian IV büstü (king.png yüz referansı), sağa hafif dönük |
| `art/ui/watermark_crest.png` | 1600×1100, saydam | arma filigranı: taç, kalkan, iki aslan, kıvrımlar; tek renk altın çizgi/kabartma |
Simgeler (zarf, klasör, parşömen, sütunlu bina, gazete, mühür, dişli, baklava, yıldız) kodla çizilir (ince altın çizgi, 1.5–2 px).

## 9. Mobil
Mockup masaüstü. Mobil (yatay 1067×600) aynı dili kullanır ama: üst resim şeridi ~28 px'e iner, aslanlar gizlenir, kral büstü küçük taşma ile kalır, arma gizlenir, gezinmede yalnızca simge + kısa metin; sol panel filigranı korunur; dokunma hedefleri ≥ 44 px; M1 dokunma kuralları geçerli.

## 10. Kabul
- 1600×900 ve 1495×840'ta aynı durumdaki ekran görüntüsü mockup'la yan yana konunca bölge bölge eşleşir (bu belgedeki her madde işaretlenir).
- Diğer ekranlar (gündem karar kartı, Dosyalar, Günlük, Divan, harita, medya, menü) yeni başlık/şerit/yazı diliyle bozulmaz.
- Tüm testler (ui_input masaüstü+mobil, ui_logic, touch_*, a11y, tour, lang_switch, region_map, en_leak) geçer; EN metinler sığar.
