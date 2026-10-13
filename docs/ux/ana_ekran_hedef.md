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

## Uygulama ilerlemesi

### 1 — Başlık bandı

İki katmanlı saray şeridi ve altın bilgi bandı eklendi. `header_bg.png`, `lion.png`, `king_bust.png` ve `crest.png` mevcut kaynakları `ResourceLoader.exists` ile kullanılıyor; eksikse koyu gradyan/boş yer ayrılır. Hafta plakası artık ilerleme çizgisini taşır, mesai yalnızca mevcut toplam kadar dolu/boş çizilmiş baklava gösterir. Gezinme simgeleri glif yerine çizimdir; mobilde aslanlar, arma ve Kaydet öğesi gizlenir, büst ve 44 px gezinme hedefleri kalır.

`tests/ui_shots.gd --main-target` aynı görsel durumunu (1. hafta, bekleyen karar yok, `voss`/Nadir Vale seçili, “Raporları oku” adımı) üretir; sadece ekran görüntüsü için durum kurar. 1600×900, 1495×840 ve yatay mobil; TR/EN başlık görüntüleri açılıp kontrol edildi. `ui_input_test.gd`: masaüstü `UI INPUT: OK`, mobil `UI INPUT: OK (mobile)`. Test ve screenshot süreçleri exit code 0 verdi; Godot kapanışında mevcut RID/ObjectDB kaynak uyarıları da çıktı.

### 2 — Haber şeridi ve sol sekmeler

Haber şeridi koyu çerçeveli serif satıra dönüştürüldü; iki haber ayrı metin alanlarında, aralarında çizilmiş baklava ve solunda çizilmiş kıvrım bulunur. Sol sekmelerde simge ve metin serif tipografiye geçti, masaüstünde ve mobilde sekme yüksekliği dokunma erişimini korur. 1600×900 EN ve 1067×600 EN hedef görüntüleri açılıp kontrol edildi; dar mobil şeritte haber metinleri üç noktayla kısalıyor ve dokununca genişleyebiliyor. Masaüstü/mobil `ui_input_test.gd` sonuçları `UI INPUT: OK` ve `UI INPUT: OK (mobile)`; çıkış kodları 0. Godot kapanışında mevcut kaynak/RID uyarıları sürüyor.
### 3 — Sol panel

Sol gündem alanının arkasına mevcut `watermark_crest.png` düşük alfa ile çiziliyor; kaynak yoksa hiçbir öğe ayrılmaz ve mevcut gündem içeriği aynen çalışır. Haftalık rehberin başlığı/step metinleri serif oldu, seçili adım çerçevelendi; mobil hedefler en az 44 px. Bekleyen karar olmadığında bilgilendirme metni koyu-altın kutu içinde gösteriliyor. 1600×900 TR ve 1067×600 EN hedef ekranları açıldı; filigran metni bastırmıyor, rehber ve boş durum kutusu yatay alana sığıyor. Masaüstü ve mobil `ui_input_test.gd`: `UI INPUT: OK`, `UI INPUT: OK (mobile)`; exit code 0. Godot kapanışında mevcut kaynak/RID uyarıları sürüyor.
### 4 — Sağ sütun

İzleme kartları bir miktar büyütüldü ve rol metinleri daha parlak serif-altın oldu. Seçili kişi kartında portre büyütülüp ince süslü çerçeve ve çizilmiş yıldız eklendi; ad/unvan serif, kapatma düğmesi sağ üstte. Nitel çiplerde seviye yıldızları ve diğer işaretler yazı glifi yerine çizilir. Eylem sekmeleri serif ve büyük harf; “HALK” düzeltildi, “OPERASYON” kesilmiyor. Eylem önizlemesi/sonuç alanı serif biçime geçti. 1600×900 TR ve 1495×840 EN hedef görüntüleri açıldı; EN’de çipler gerektiğinde ikinci satıra akıyor, içerik taşmıyor. 1067×600 EN gündem görünümü de açıldı; mobilde Kişiler ayrı sekmede kaldığı için panelin mobil görünümü de açılıp kontrol edildi. `ui_input_test.gd`: masaüstü `UI INPUT: OK`, mobil `UI INPUT: OK (mobile)`; exit code 0. Godot kapanış uyarıları sürüyor.
### 5 — Değişenler, bu hafta, raporlar ve alt bilgi

Sağ sütundaki üç özet bölümü tek süslü çerçeveye alındı. Başlıklar/yardımcı metinler serif; rapor satırlarında kaynak portresi, mevcut yeşil/amber/kırmızı ton çubuğu ve serif kaynak/metin var. Taşan liste alt kenarda yumuşak solma ve dikey kaydırma çubuğuyla devam ediyor; kaydırmanın sonunda son satır tam görünür. Alt bilgi şeridindeki durum metni serif oldu ve başına glif olmayan çizilmiş kıvrım eklendi. Başlık katmanlarının yüksekliği hedef oranlara yaklaştırıldı; alanı raporlara açtı. `ui_input_test.gd` iç içe çerçevedeki rapor ve “Tüm raporlar” düğmesini bulacak şekilde uyarlandı. 1600×900 TR hedef görüntüsüne ek olarak EN/1495 ve yatay mobil kontrolleri final dilimde tekrar edildi. Masaüstü ve mobil `ui_input_test.gd` önceki çalıştırmada sırasıyla `UI INPUT: OK`, `UI INPUT: OK (mobile)` verdi. Godot kapanışında kaynak/RID uyarıları sürüyor.


### 6 — Genel serif geçişi ve mobil uyarlama

Ana arayüz temasında varsayılan yazı tipi `UIKit.serif()` oldu; kalın/italik temalar da aynı aileyi kullanıyor. Mobil metin yardımcıları 15 px tabanını koruyor; haber ve kişi paneli, medya, masa ve harita etiketleri bu tabana uyarlandı. Kişi kartı şeridinde yatay kaydırma çubuğu metnin üstüne binmiyor. TR/EN yatay mobil (1067×600), masaüstü ve kişi paneli açıldı; `ui_input_test` mobil ve masaüstü ile kaydırma/dokunma kapıları çalıştırıldı.

### Uygulama kontrol listesi

| Bölüm | Durum | Kontrol |
|---|---|---|
| 0. Genel | karşılandı | Serif tema, en küçük mobil metin 15 px, simgeler çizim/PNG; glif yedeği yok. |
| 1. Başlık bandı | karşılandı | İki katman, aslanlar, kral büstü, arma, hafta plakası/ilerleme, mesai baklavaları, simgeli gezinme ve ayraçlar. |
| 2. Haber/alamet şeridi | karşılandı | Kıvrım ve baklava çizili; dinamik metin, mobilde kısaltma/etkileşim. |
| 3. Sol sekmeler | karşılandı | Serif simgeli Gündem/Dosyalar/Günlük sekmeleri ve bekleyen sayaç davranışı korundu. |
| 4. Sol panel | karşılandı | Filigran, adım çubuğu, uyarı ve boş durum kutuları. |
| 5.1 İzleme listesi | karşılandı | Büyütülmüş kişi kartları, seçili kenar ve okunur rol satırları. |
| 5.2 Seçili kişi paneli | karşılandı | Yüzü görünen portre çerçevesi, nitel çipler ve köşedeki kapatma. |
| 5.3 Eylemler paneli | karşılandı | HALK/OPERASYON etiketleri, açıklama/son eylem alanı ve serif eylem düğmeleri. |
| 5.4 Değişenler / Bu hafta / Raporlar | karşılandı | Serif satırlar, kaynak portreleri/ton çubukları; alt kenarda solma ve kaydırma ile devam. |
| 6. Alt bilgi | karşılandı | Çizilmiş kıvrım, serif durum satırı ve haftayı bitir düğmesi. |
| 7. Kararlar | karşılandı | Büst/kaydet simgesi/çarpı/mesai baklavaları için belgelenen kararlar uygulandı. |
| 8. Gereken görseller | karşılandı | Beş istenen `art/ui` kaynağı mevcut ve `ResourceLoader.exists` ile kullanılıyor; `art/` değiştirilmedi. |
| 9. Mobil | karşılandı | 1067×600 yatay yerleşim, 44 px hedefler, gizlenen aslan/arma, kısa gezinme ve 15 px metin tabanı. |
| 10. Kabul | kısmen | 1600×900 ve 1495×840 aynı TR durumuyla karşılaştırıldı; bölüm düzeni yakın, fakat mockup ile piksel düzeyinde tam eşleşmiyor. Karşılaştırma: `docs/ux/ref/ana_ekran_karsilastirma.jpg`. |

EN/TR masaüstü ve yatay mobilde Gündem/karar, Dosyalar, Günlük, Divan, harita, medya, menü ve giriş ekranları açıldı. EN metinlerde belirgin taşma görülmedi. Kişiler görünümündeki yatay kart şeridi kaydırılabilir; daha fazla kart kenar oklarıyla erişilebilir.

### Kapı kapanışı

- `tools/run_test_isolated.ps1` ile bütün `*_test.gd`, `*_check.gd` ve `unit_tests.gd` çalıştırıldı. `a11y_test` ilk denemede renk körü işaretini yakaladı; düzeltmeden sonra `A11Y: OK`. Masaüstü/mobil giriş sonuçları `UI INPUT: OK`, `UI INPUT: OK (mobile)`. Dokunma `TOUCH: OK`, `TOUCH TAP: OK`; `UI LOGIC: OK`; senaryo ve simülasyon `SCENARIO: OK`, `TEST: OK`; `TR SUFFIX: OK (7034 Turkish, 5602 English strings; 40 campaigns)`. İçerik `CONTENT: OK (5 dosya, 8 bozuk örnek)`, olaylar `EVENTS: OK (201 olay, 0 uyarı)`, birim paketi `[unit] all 399 checks passed`. Ayrıntılı, değiştirilmemiş araç çıktıları `docs/ux/ana_ekran_test_raporu.txt` içinde.
- Doğru `--autoplay --full --seed=101` koşusu TR ve EN için aynı sonucu verdi: `FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
- `docs/ux/ref/ana_ekran_karsilastirma.jpg` hedef mockup, 1600×900 ve 1495×840 aynı TR durumunu yan yana gösterir. EN/TR, masaüstü/yatay mobil için Gündem/karar, Dosyalar, Günlük, Divan, harita, medya, menü ve giriş ekranları açılıp kontrol edildi.

### Gözlemler

Ana ekranın bölge düzeni mockup'a yakın, ancak tipografi ölçüsü ve bazı panellerin oranı piksel düzeyinde tam eşleşmiyor; kabul listesinde bu yüzden “kısmen” olarak işaretlendi. Mobil haber şeridi uzun metni kısaltıyor; dokunarak genişletilebiliyor. Rapor listesinde alt solma/kaydırma göstergesi var; aşağıdaki satırlar kaydırmayla görülüyor. EN/metin taşması görsel kontrolde görülmedi. Test/screenshot Godot süreçleri exit code 0 ile kapansa da kapanışta RID/ObjectDB kaynak uyarıları sürüyor; bunlar bu UI diliminde çözülmedi.


### Geçici dosyalar

Görsel kontrol tamamlandı. Geçici ekran görüntülerini silme isteği otomatik inceleme tarafından “blocked by policy” gerekçesiyle reddedildi; bunu aşmak için başka silme yöntemi kullanmadım. Ekran görüntüsü ve yardımcı log/script dosyaları `C:\Users\USER\AppData\Local\Temp\Veloria_AnaEkran_s2_review` altında kaldı. İzole çalıştırıcının artakalan profilleri: `C:\Users\USER\AppData\Local\Temp\Veloria_M1_Test_50cd275483f14112910ee28fdfa56dfa`, `C:\Users\USER\AppData\Local\Temp\Veloria_M1_Test_749fac86511e4c78b303e962151d16ba`, `C:\Users\USER\AppData\Local\Temp\Veloria_M1_Test_7fd52f7acd0140fb926a0ef152a428a3`, `C:\Users\USER\AppData\Local\Temp\Veloria_M1_Test_a78c287ef8594457b812dba6ca73b9a3`.

## Claude doğrulaması (G1 sonrası) — kalan farklar → G1b
Ekran: `docs/ux/ref/ana_ekran_g1.jpg` (1600×900, aynı durum). Mockup'la bölge bölge karşılaştırıldı. Testler geçiyor; aşağıdakiler görünür farklar. Hepsi G1b'de düzeltilecek.

**Başlık**
1. Üst resim şeridi neredeyse görünmüyor: bulanık kahverengi bant. Mockup'ta sancaklar, mumlar, sütunlar net ve görünür. `header_bg.png` görselin ÜST bölümü (sancak + mum) gösterilecek şekilde konumlansın; bulanıklık yok; karartma hafif (mockup parlaklığı); şeridin ortası resmin karanlık koridoru olmasın (görsel genişliğe sığdır, gerekirse yanlardaki sancaklı bölümleri göster).
2. Aslanlar (~70 px) ve kral büstü (~70 px) çok küçük. Mockup'ta ikisi de başlığın TAMAMI boyunca (~135–150 px) durur, üst şeride taşar; taç neredeyse en üste değer. Aslanlar büst kadar yüksek.
3. Arma mockup'ta daha büyük, iki katmana taşar (~110 px).
4. Unvan önündeki zambak simgesi şu an küçük, anlaşılmayan bir işaret. Mockup'ta ~30 px net altın zambak (fleur-de-lis); kodla çiz ya da PNG.
5. Bilgi çubuğu çerçevesi ince tek çizgi; mockup'ta çift altın çizgi ve sol bölümün (unvan→hazine) sağ ucu ok/sivri süsle biter.
6. Gezinme: simge ile yazı arasında çok boşluk var (simge solda, yazı ~100 px sağda). Mockup'ta simge yazının hemen solunda (8–10 px). Simgeler biraz büyüsün (~24 px).

**Haber şeridi**
7. Öğeler yayılmış (ikinci öğe ortaya-sağa itilmiş). Mockup'ta öğeler satırda art arda akar, aralarında küçük altın baklava.
8. Soldaki ve alt bilgideki kıvrım simgesi "↻" gibi okunuyor. Mockup'taki gibi altın kıvrım/akantus süsü olsun.

**Sol panel**
9. "BU HAFTA NE YAPMALI?" harf aralıklı değil ve altında süslü çizgi yok (mockup'ta var).
10. Adım çubuğu hâlâ dört ayrı kutu. Mockup: kutu yok; adımlar tek yatay çizgide, aralarında ince altın bağlantı çizgileri; yalnızca etkin adım sivri uçlu plaka içinde; tamamlanan yeşil.
11. "Bu hafta bekleyen karar yok…" mockup'ta kutusuz düz metin.
12. Zarf simgesi küçük; mockup'ta ~28 px ince çizgi zarf.

**Sağ sütun**
13. **Seçili kişi portresi yanlış kırpılmış:** Vale'nin yüzü sol kenarda yarım kalıyor. Yüz merkezli kırp; portre ~120×110'a büyüsün (mockup).
14. Kişi panelinin alt kenarında ortada zambak süslü ayraç yok (mockup'ta var).
15. "İZLEME LİSTESİ" çizgisinin ucunda kıvrım süsü yok.
16. Eylemler sekmelerinin hepsi kutulu; mockup'ta yalnızca etkin sekme plakada, diğerleri düz yazı.
17. **Raporlar yine yarım satırla kesiliyor** (Arden satırı alt kenarda yarım). Liste tam satırla bitsin ya da alt kenarda solma + kaydırma göstergesi. Mockup'ta üç rapor tam görünüyor: alt çerçeve yüksekliğini ve üstteki bölümlerin boşluklarını buna göre ayarla.
18. "BU HAFTA" metinleri çerçevenin sol kenarına yapışık (iç boşluk yok); sağ üst köşe süsü başlıktaki baklavanın üstüne biniyor.
19. "Raporlar" başlığı "R a p o r l a r" gibi aşırı aralıklı; diğer bölüm başlıklarıyla aynı aralık.
20. "Diğer kişiler Divan'da" mockup'ta daha açık (krem-beyaz).

**Genel**
21. Mesai 4/4 doğru (4 dolu). Harcandığında içi boş baklava kontrol edilsin (3/4 durumunda ekran görüntüsü).
