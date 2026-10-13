# Faz 7 — Gerçekçilik: ekonomi, kamuoyu, meclis, bölgeler, ordu

Tarih: 2026-10-11. Amaç: oyunu "tek sayıların oynadığı soyut simülasyon"dan "kurumları ve yurttaşları olan bir devlet"e yaklaştırmak. İlkeler değişmez: **sayı yok** (gizli değerler nitel ipuçlarıyla), **yanılabilir bilgi** (rapor/anket/danışman yalan söyleyebilir), **bedel** (her kazanç bir borç doğurur), **dünya beklemez** (gecikmeli, ikinci derece sonuçlar), **başarısızlık hikâye**. Oyuncu hâlâ haftada 4 mesai harcar; yeni sistemler yeni KARAR üretir, yeni düğme yığını değil.

Mevcut durum özeti (kod): ulusal tek değerler `economy, unrest, opposition, treasury, holding, foreign[3], king_strength`, dört kurum kapasitesi (`maliye, hukuk, ordu, idare`), 14 kişi, krizler (`coup_crisis`, `other_crisis`: street, legal, border, siege, assassination), patronaj, rapor/yalan sistemi. Eksik gerçeklik: coğrafya yok, meclis yok (yalnızca olay ve `opposition` skaleri), kamuoyu tek skalerde (`unrest`), ekonomi tek skaler, ordu tek skaler kapasite.

## Sıra ve bağımlılık
| Dilim | Sistem | Maliyet | Neden bu sırada |
|---|---|---|---|
| R1 | Ekonomi ve bütçe | orta | Diğerlerinin altyapısı (hükümet geliri, tahsis); mevcut `Quarterly Budget` olayını genişletir |
| R2 | Kamuoyu ve meşruiyet | orta-düşük | Arayüzü en çok değiştiren, en çok "gerçek" hissettiren |
| R3 | Meclis ve kanunlar | yüksek | R1 (bütçe yasası) ve R2 (kamuoyu) ile bağlanır |
| R4 | Bölgeler | yüksek | Harita/olay içeriği geniş; R1–R3 oturunca |
| R5 | Ordu iç yapısı | orta | Darbe gerçekçiliği; R4'ün garnizon/bölge verisini kullanır |
Her dilimde denge kapısı: ölçüt botu (80 kampanya/zorluk) tabanın ±8 puanı içinde (taban: Kolay 62/80, Normal 30/80, Zor 13/80 — B1 sonrası); `--full` tohum 101'in sonucu değişirse yeni taban açıkça belgelensin; tempo ≥ 0,8; sızıntı kapıları 0.

---
## R1 — Ekonomi ve bütçe (tek skaler `economy` → beş gösterge)
**Gizli durum (0–100, oyuncu görmez):** `inflation` (enflasyon), `jobs` (istihdam), `debt` (kamu borcu baskısı), `trade` (ticaret dengesi), `growth` (büyüme). Mevcut `economy` bunların ağırlıklı özeti olarak türetilir (geriye dönük uyum: eski kodlar `economy`yi okumaya devam eder).
**Görünür:** Maliye raporu (Veyra) beş göstergeyi nitel bantlarla anlatır ("fiyatlar tırmanıyor", "fabrikalar vardiya azaltıyor"), kaynağa göre yanılır (rapor/yalan sistemi). Sarne TV ve Leyla'nın gazetesi farklı ekonomik tablo çizer (mevcut medya sistemi). Günlükte "ekonomi" başlığı.
**Bütçe kararı (çeyreklik, 13 haftada bir, mevcut `Quarterly Budget`i genişletir):** dört kalem arasında oran seçimi (basit üç hazır paket + özel): *Ordu ve güvenlik*, *Sosyal harcama*, *Altyapı ve sanayi*, *Saray ve vakıf*. Etkileri gecikmeli (4–12 hafta): sosyal ↑ → huzursuzluk ↓ ama borç ↑; altyapı ↑ → büyüme/istihdam ↑ geç; ordu ↑ → Arden gücü ↑ (darbe riski); saray ↑ → Helena/Marcus bağı, skandal riski. Borç yüksekken Seravia/Asteria baskısı artar (`siege` ile bağ: mali kuşatma artık gerçek bir borç dinamiğine dayanır).
**Politika eylemleri (Devlet sekmesi, mevcut eylemlere eklenir, mesai harcar):** vergi ayarı (artır/azalt), kemer sıkma, teşvik paketi. Sonuçlar iki yönlü ve gecikmeli; aynı eylem üst üste etkisini azaltır.
**Sinyaller:** enflasyon yüksekken sokak olayları ve fiyat haberleri; işsizlikte protesto; borçta elçi notaları.
**Denge/istismar:** "sosyal harcamayı hep yüksek tut" borçla çöker; "kemer hep sık" huzursuzlukla çöker; ikisi arası dengede kalan oyuncu kazanır ama sürekli gözlem ister.

## R2 — Kamuoyu ve meşruiyet
**Gizli iki eksen:** `consent` (rıza: halk ve elit kralı meşru görüyor) ve `fear` (korku: baskıyla ayakta tutuluyor). Mevcut `unrest` bunlardan türetilir. Yüksek korku + düşük rıza = kırılgan düzen (ayaklanma/darbe riski sıçrar); yüksek rıza = dayanıklılık.
**Anketler:** her 8 haftada bir "kamuoyu araştırması" kartı; sonuç kaynağa göre yanılır (Sarne'nin anket şirketi kralı kayırır, Leyla'nınki muhalefete yakın, bağımsız kurum gürültülü). Oyuncu yalnızca nitel bant görür ("desteğin dalgalanıyor"). Anketin kendisi bir *hamle*: anket yayınlamak algıyı etkiler.
**Kral görünürlüğü eylemleri:** halka konuşma, saha ziyareti, tören (rıza ↑, risk: suikast/protesto, mesai bedeli); gizlenme (korku ↑ rıza ↓ uzun vadede).
**Skandal yönetimi:** büyük sırlar açığa çıkınca (mevcut `facts` kaskadı) oyuncu bir *yanıt* seçer: inkâr / özür / kurban bul / gündem değiştir. Her biri farklı yarı ömür ve yan etki (özür: rıza kısa vadede ↑, elit güveni ↓; kurban: bir kişi düşer ve intikam yolu açılır).
**Sinyaller:** haber tonu, sokak olayları, Sarn'ın raporu, Divan'da "kamuoyu" satırı.

## R3 — Meclis ve kanunlar
**Blok yapısı (gizli):** dört blok: *Saray listesi* (iktidar), *Muhalefet*, *Soylular*, *Bağımsızlar*; her blokta sadakat ve baskı noktası. Mevcut `opposition` ve patronaj bu bloklardan türetilir.
**Kanun teklifleri (her ~10 haftada bir kart):** vergi reformu, basın yasası, ordu bütçesi, seçim yasası, af yasası, yargı reformu... Oyuncu teklifi *destekle / değiştir / geri çek / baskıyla geçir* seçer; oylama sonucu belirsiz, yalnızca blok davranışlarından ve vekil sayımı söylentilerinden okunur (**kesin oy sayısı yok**). Başarısız teklifler muhalefeti güçlendirir; baskıyla geçirmek (patronaj, tehdit, rüşvet) bedel ve iz bırakır.
**Kalıcı etkiler:** kabul edilen yasalar kuralları değiştirir (basın yasası → Leyla'nın etkisi azalır ama rıza ↓; ordu bütçesi → Arden ↑; seçim yasası → erken seçim eşiği).
**Fesih ve seçim:** mevcut `erken_secim` olayı gerçek bir seçime bağlanır (blok dağılımı değişir; sonuç bir hükümet kurma kararı).
**Güven oyu / hükümet krizi:** Başbakan (Veyra) meclis desteğini kaybederse hükümet düşer; yeni başbakan ataması bir karar (yeni karakter ya da var olan biri).

## R4 — Bölgeler (coğrafya)
**Dört bölge:** Başkent, Sanayi Kuşağı, Tarım Ovaları, Sınır İlleri. Her birinde gizli `unrest/loyalty/economy` ve bir vali (supporting aktör, çevresel; ana RNG'yi tüketmez). Ulusal `unrest` bölgelerin ağırlıklı toplamı olur.
**Mekanik:** yatırım ve garnizon dağılımı kararları; bölgesel krizler (sanayi grevi, tarım kıtlığı, sınır gerilimi → B1 ile birleşir); vali ataması/azli; bölgesel medya etkisi.
**Arayüz:** Başkent haritasına bölge katmanı (renksiz nitel simgeler), bölge raporu satırı, vali kartı Divan'da "Devlet" grubunda.

## R5 — Ordu iç yapısı
**Birlikler:** başkent garnizonu, sınır kolordusu, jandarma/güvenlik. Her birinin komutanı ve sadakati gizli; Arden tek komutan değil bir zincirin başı. Darbe aşamaları artık "hangi birlik dönüyor" ile anlatılır (alametler: garnizon değişimi, muhafız ikilemi).
**Eylemler:** subay tayini, garnizon yer değiştirme, maaş/ikmal ek ödeneği (bütçe R1'e bağlı); komuta zincirini bölmek (Arden'in gücünü azaltır, ordu verimini düşürür).
**Darbe karşıtı denge:** birliklerin dağılması darbe başarı olasılığını bölgeye göre değiştirir; sınır krizi (B1) sırasında garnizonu başkentten çekmek darbe riskini artırır (gerçekçi ödünleşme).

---
## Ortak teknik notlar (Codex için)
- Yeni gizli alanlar kayda yazılır (SAVE_VERSION artır + eski kayıt göçü: eski kayıtlarda yeni alanlar mevcut `economy/unrest/opposition` değerlerinden türetilir).
- Metinler çift dilli üretilir (docs/i18n/sizinti_gorevi.md); içerik `game/data/*.json` + `game/data/en/*.json`; sızıntı kapıları (en_leak_test, tools/i18n_leak_scan.py, tools/i18n_missing.py) 0.
- Yeni RNG için AYRI üreteç (mevcut tohumlar kaymasın); `--full` tohum 101 etkilenirse değişim ve yeni taban belgelenir.
- UI: Divan/rapor/Günlük satırları ve kriz kartı kalıpları yeniden kullanılır; "sayı yok" ilkesi; mobil 44 px; web'de glif kutusu çıkar.
- Her sistem için `tests/<sistem>_test.gd` birim testi, probe'a ilgili sayaçlar (ör. enflasyon kaynaklı kayıplar), ölçüm tabloları belge sonunda "Ayar" bölümünde.

## R1 Ayar

80 kampanya/zorluk ölçümü (`advice_weighted`), referans hedefi ve farkı:

| Zorluk | Hedef | Ölçüm | Fark |
|---|---:|---:|---:|
| Kolay | 62/80 (%77,50) | 61/80 (%76,25) | −1,25 puan |
| Normal | 30/80 (%37,50) | 31/80 (%38,75) | +1,25 puan |
| Zor | 13/80 (%16,25) | 14/80 (%17,50) | +1,25 puan |

Uç bot kapısı (kazanma / 80; ölçüt botu kazanma sayısının en çok %70'i):

| Zorluk | Ölçüt | Tavan | Hep kemer sıkı (`advice_austere`) | Sosyal hep yüksek (`advice_lavish`) |
|---|---:|---:|---:|---:|
| Kolay | 62 | 43,4 | 21 | 24 |
| Normal | 30 | 21 | 14 | 18 |
| Zor | 13 | 9,1 | 6 | 9 |

Kalibrasyon: sosyal tahsis %25'i aştığında dış borç baskısı katsayısı 1,2; varsayılan dağılımda katsayı 0,04 olarak kaldı. Gecikmeli sosyal harcama hazineden pay başına 1,6 düşürüyor. Danışman bütçe önerisi, sosyal pay değişimini huzur değeri `0,045` ve hazine maliyeti `0,25` katsayılarıyla puanlıyor; genel `choice_value` ve başlangıçtaki varsayılan akış böylece değişmiyor. Özel dağılım penceresi 10/70/10/10 ile başlar; oyuncu dört payı düzenleyebilir ve toplam 100 değilse uygulayamaz. İlk sekiz haftadaki tempo en düşük 0,81 olay/hafta. EN sızıntı taraması ve eksik çeviri kapıları 0.

`--full --seed=101` sonucu hem TR hem EN'de: 104 hafta / TAHTTA / Medya Rejimi / 112 olay.

## R3a Ayar

80 kampanya/zorluk ölçümü (`advice_weighted`); hedefler 62/30/13. Blokların başlangıç toplam sadakati 80 olduğundan ilk muhalefet değeri 20 olarak kalır. Meclis teklifleri ayrı `parliament_rng` kullanır ve yaklaşık 10 haftada bir açılır. Sonuç ve blok raporu nitel gösterilir; kesin oy sayısı üretilmez.

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Ölçüt (`advice_weighted`) | 60/80 | 30/80 | 13/80 |
| Hep baskıyla geçir (`parliament_force`) | 43/80 | 9/80 | 6/80 |
| Hep geri çek (`parliament_withdraw`) | 41/80 | 7/80 | 4/80 |
| Hiç oy verme (`parliament_abstain`) | 33/80 | 5/80 | 1/80 |

Ölçüt hedefinden fark: Kolay −2,5 yüzde puan; Normal 0; Zor 0 (±8 puan kapısı içinde). Tek yönlü stratejilerin tavanları ölçüt botunun %70'i: Kolay 43,4; Normal 21; Zor 9,1. Üç bot da her zorlukta tavanın altında kaldı.

Zorlama maliyeti baskı sayısıyla artar: hazine `10 + 6×tekrar`, özel servet `7 + 3×tekrar`, huzursuzluk `100 + 30×tekrar`, kral gücü −14. Başarısız olağan oylama blok sadakatini değiştirir ve muhalefeti −2 etkiler; geri çekme/sona erme daha ağır sonuç verir. Tempo kontrolünde ilk sekiz haftanın en düşük olay oranı 0,81/hafta, en uzun olaysız seri 3 haftadır.

`--full --seed=101`: TR ve EN 104 hafta / TAHTTA / Medya Rejimi / 112 olay. EN sızıntı taraması 4.532 metin, 0 şüpheli; `tools/i18n_missing.py`: 0.

## R2 Ayar

Ölçüt ve görünürlük botları, 80 kampanya/zorluk (`advice_weighted`, `public_out`, `public_hide`):

| Zorluk | R1 tabanı | Ölçüt | Hep halka çık | Hep gizlen |
|---|---:|---:|---:|---:|
| Kolay | 61/80 (%76,25) | 61/80 (%76,25) | 23/80 (%28,75) | 0/80 (0%) |
| Normal | 31/80 (%38,75) | 31/80 (%38,75) | 15/80 (%18,75) | 0/80 (0%) |
| Zor | 14/80 (%17,50) | 14/80 (%17,50) | 1/80 (%1,25) | 0/80 (0%) |

Kalibrasyon: “gizlen” hamlesi başına rıza −1, korku +1; korku yüksek ve rıza düşük kaldıkça haftalık huzursuzluk ikisinden türetiliyor. Böylece tek başına gizlenme kazanma sağlamaz; etkisi anlık değil, birikimli. Halka çıkış eylemlerinin maliyeti 1 mesai; saha ziyaretindeki protesto riski kamuoyu RNG'sinden gelir. Anket kaynak farkı: Sarne +8, Leyla −8, bağımsız kurum ±12 puan gürültü; oyuncu yalnızca nitel destek bandını görür. R2 devre dışıyken R1'in mevcut huzursuzluk akışı ve ana RNG'si aynı kalır.

Ölçüt R1 tabanının farkı: Kolay 0, Normal 0, Zor 0 puan. `public_out` ve `public_hide` tek yönlü botları hiçbir zorlukta ölçüt botunu geçmiyor. `--full --seed=101` TR/EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. Tempo en düşük dilim 0,81; en uzun olaysız seri 3 hafta. EN leak taraması: 4.320 metin, şüpheli 0; `i18n_missing.py`: 0.
## R3b Ayar

Kanunlar yürürlüğe girdikten sonra kuralları kalıcı değiştirir; Günlük ve Divan yalnızca nitel etkiyi gösterir. Yürürlükten kaldırma, 26 haftalık gözden geçirmede verilen ve hazine/otorite/siyasi bedeli olan ayrı karardır. Vergi reformunun sokak yükü zorlukla artar; oranlar oyuncu arayüzünde görünmez. Baskıyla geçirme için hazine ve kişisel servet yanında en az orta düzey kraliyet otoritesi gerekir; bedeli R3a'nın tek başına baskı botu kapısını koruyacak biçimde kalibre edildi.

80 kampanya/zorluk; hedef ölçüt 62/30/13. Fark, yüzde puan olarak ±8 sınırında:

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Ölçüt (advice_weighted) | 56/80 | 33/80 | 19/80 |
| Hep baskıyla geçir (parliament_force) | 39/80 | 13/80 | 6/80 |
| Hep geri çek (parliament_withdraw) | 41/80 | 7/80 | 4/80 |
| Hiç oy verme (parliament_abstain) | 33/80 | 5/80 | 1/80 |

Ölçüt farkı: Kolay −7,5; Normal +3,75; Zor +7,5 yüzde puan. Hedefe göre %70 tavanları 43,4 / 21 / 9,1; üç uç bot da bu tavanların altında.

Yasa etkileri: basın yasası Leyla'nın ücretsiz basın etkisini zayıflatırken rızayı azaltır; ordu yasası Arden'i güçlendirir ve R1 tahsisini en az %26 ordu payına bağlar; vergi reformu hazineye gelir eklerken düzenli kamuoyu baskısı üretir; seçim yasası erken seçim eşiğini düşürür; af ve yargı reformu hukuki baskıyı kalıcı olarak hafifletir. Yasa adları ve nitel özetleri Günlük ile Divan'da görünür. Kayıt şeması 17'ye yükseldi; sürüm 16 kayıtları boş yasa defteriyle yüklenir. Meclisin mevcut `parliament_rng` akışı ana oyun RNG'sinden ayrıdır.

Tempo kapısı: ilk sekiz haftada en düşük dilim 0,81 olay/hafta; en uzun olaysız seri 3 hafta. `--full --seed=101`, TR ve EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. `tests/*.gd` kapıları çalıştırıldı; `tests/title_shot.gd` ve `ux_audit.gd` bu kapsam dışında bırakıldı, ikincisi ekran görüntüsü yığını üretiyor. `en_leak_test.gd`: 5 kampanya, 0 sızıntı; `tools/i18n_missing.py`: 0.

EN/TR masaüstü ve mobil ekranları açılıp gözle kontrol edildi: kanun teklifi kartı, Günlükte yürürlükteki yasa satırı ve masaüstü Divan listesindeki aynı satır. Çeviri, nitel etki metni ve mobilde satır/düğme taşması kontrol edildi. Geçici ekran görüntüleri inceleme sonrası silindi. `--full` kapanışında Godot'un bilinen ObjectDB/resource cleanup uyarıları görüldü; kapılar exit 0 ile geçti.

## Kalibrasyon

Önceki `advice_weighted` probe'unda Kolay 56/80, Normal 33/80, Zor 19/80 idi; Kolay'da yabancı müdahalesi 11/80 kayıp, Zor'da darbe dışı kayıplar 12/80'di. Vergi yasası haftada yalnızca 0,02 hazine getirirken huzursuzluğu Kolay/Normal/Zor'da 0,16/0,25/1,2 artırıyordu: gelir R1 kaynaklı dış baskıyı dengelemeye yetmiyor, huzursuzluk da Zor'daki darbe dışı kayıp yolunu belirliyordu. `_tick_external_pressure()` düşük hazineyi Asteria/Seravia baskısına, yasa kaynaklı huzursuzluk ise sokak ve meşruiyet kayıplarına taşır. Bu nedenle Easy'de vergi gelirini yükseltip yükü hafiflettim; Zor'da daha ağır yük uyguladım. Ordu yasasının Arden gücü artışı da askerî darbe baskısıdır; zorlukla 1/2/4'e ölçeklendi.

Vergi yasası artık haftalık R1 geliri ve huzursuzluk yükünü zorlukla ölçekler: gelir 0,15/0,02/0,02; tek seferlik huzursuzluk 0/2/4; haftalık huzursuzluk 0/0,75/2,4. Son probe'da Easy yabancı müdahalesi 11'den 6'ya indi; Zor darbe dışı kayıp 12'den 16'ya çıktı ve ölçüt zor skoru hedefe yaklaştı.

| Ölçüm (80 kampanya) | Önce | Kalibrasyon sonrası |
|---|---:|---:|
| Ölçüt Kolay | 56/80 | 63/80 |
| Ölçüt Normal | 33/80 | 30/80 |
| Ölçüt Zor | 19/80 | 14/80 |
| Kolay yabancı müdahalesi kaybı | 11/80 | 6/80 |
| Zor darbe dışı kayıp | 12/80 | 16/80 |
| Zor darbe kaybı (askerî + saray) | 49/80 | 50/80 |

Sonuçlar istenen 60–64 / 28–32 / 11–15 bantlarında. Uç botlar sırasıyla Kolay/Normal/Zor: baskıyla geçir 43/12/4, geri çekil 41/7/4, oy verme 33/5/1, `advice_austere` 18/11/2, `advice_lavish` 24/16/7. Ölçüt gerçek değerinin %70 tavanları 44,1/21/9,8; tümü altında. Tempo ilk dilimde 0,81 olay/hafta; en uzun olaysız seri 2 hafta. `--full --seed=101` TR/EN 104 hafta / TAHTTA / Medya Rejimi / 112 olay.

EN masaüstü ve mobil üretim metin taramasındaki tek kaçak, bütçe olayıyla üretilebilen “Saray tahsisi büyüdü” olgusuydu; İngilizce karşılığı eklendikten sonra tarama 4.506 metinde 0 şüpheli verdi. `i18n_missing.py`: 0.


## R4 Ayar

R4a dört bölgeyi (Başkent %35, Sanayi Kuşağı %30, Tarım Ovaları %22, Sınır İlleri %13) tanımlar. Her bölgede gizli huzursuzluk, bağlılık ve ekonomi alanı ile supporting vali aktörü vardır. Yeni başlangıçlarda bölgesel sapmalar ayrı `region_rng` ile üretilir ve ulusal huzursuzluk/ekonomi ağırlıklı ortalamaları korunur. V18 kayıt göçü, önceki ulusal değerleri dört bölgeye dağıtarak korur; v19 kayıtlarında bölge verisi ve üreteç durumu saklanır. Her hafta var olan ulusal simülasyon delta kaynağı kalır; yerel değerler bu ulusal hedefe göre eşit kaydırılarak sınırlar içinde ağırlıklı özeti verir.

80 kampanya/zorluk (`advice_weighted`); R4a hedefi 62/30/13, kapı ±4 kampanya:

| Zorluk | Hedef | Ölçüm | Fark |
|---|---:|---:|---:|
| Kolay | 62/80 | 62/80 | 0 |
| Normal | 30/80 | 31/80 | +1 |
| Zor | 13/80 | 17/80 | +4 |

Bu dilimde bölgesel yatırım eylemi henüz yok; bu nedenle tek bölgeye yatırım ve hiç yatırım botları uygulanabilir değil. Her dört bölgenin `regional_investments` sayacı 0 ve bu durum `regions_test.gd` ile doğrulanıyor. `pacing_test.gd`: ilk sekiz haftada 0,81 olay/hafta; en uzun olaysız seri 3 hafta. `--full --seed=101`, TR ve EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay; önceki taban değişmedi.

`tests/en_leak_test.gd`: 5 kampanyada 0 sızıntı. İngilizce üretim metin dökümü 3.623 metinde `tools/i18n_leak_scan.py` ile 0 şüpheli verdi; `tools/i18n_missing.py`: 0. R4a ekranları EN/TR masaüstü ve mobilde açılıp incelendi: Günlük bölge satırı, Divan rapor satırı ve Devlet grubundaki vali kartları. Nitel değerler sayı göstermiyor; rapor metni satır sarıyor, kartlar kesilmiyor. `tests/title_shot.gd` ve `game/ui/title_screen.gd` değiştirilmedi.

R4a ile birlikte cila bekleyen dört arayüz konusu giderildi: görselsiz anket kartındaki üst boşluk, hanedan defteri metninin kaydırılması/sarılması, suikast kartı görseli ve mobilde ayrı Divan çekmecesi. Mobilde yinelenen yardım satırı da kaldırıldı.

## R4b Ayar

R4b, bölge yönetimini Devlet eyleminden oyuncunun isteğiyle açar; normal haftalara zorunlu kart eklemez. Bölge seçimi ve ardından yatırım, garnizon, yerel medya veya vali kararı alır. Yatırım R1 sanayi payına, garnizon ordu payına, yerel yayın sosyal payına ve hepsi hazine/mesaiye bağlıdır; yatırımın pazar, garnizonun sükûnet ve yerel yayının bağlılık etkisi gecikmeli uygulanır. Vali atama/azli hazine, Saray listesi-soylular blok desteği ve patronaj yükünü değiştirir.

Grev, kıtlık, sınır gerilimi ve başkent karışıklığı yalnız ilgili yerel eşikler oluştuğunda `region_rng` ile belirlenir. Sınır gerilimi Drakon baskısını yükseltip var olan dış kriz olayına bağlanır. Bölgesel RNG ayrı kayıt alanıdır; bu değişiklik tam tohum yolunu etkilemedi. Kayıt sürümü v20'ye çıkarıldı; eski ulusal ve bölgesel değerler korunarak yeni sayaç, gecikmeli etki, garnizon ve medya alanları göçte ekleniyor.

R4a gözlemleri düzeltildi: Günlükte yalnız en huzursuz bölge öne çıkıyor ve diğerleri özetleniyor; vali yer tutucu renkleri karartılıp desatüre edildi; masaüstü Divan vali kartları küçültüldü; günlük rapor satırı kısaltıldı. EN/TR masaüstü ve yatay mobil ekranlarında yatırım/bölge seçimi, kriz, vali azli ve atama kartları açıldı. Metin taşması veya seçenek çakışması görülmedi. `tests/ui_shots.gd` vali azli ve atamasını ayrı dosyalara kaydediyor.

80 kampanya, zorluk başına; R4b tabanı 62/31/17, kapı ±3:

| Bot | Kolay | Normal | Zor | Ölçüt tavanının %70'i |
|---|---:|---:|---:|---:|
| Ölçüt (`advice_weighted`) | 60/80 | 29/80 | 17/80 | — |
| Tek bölgeye yatırım (`region_invest_one`) | 7/80 | 1/80 | 0/80 | 42 / 20 / 11 |
| Bölgeye hiç yatırım yapma (`region_invest_none`) | 14/80 | 1/80 | 1/80 | 42 / 20 / 11 |
| Garnizonu başkentte tut (`region_garrison_capital`) | 17/80 | 1/80 | 0/80 | 42 / 20 / 11 |

Ölçüt taban farkı: Kolay −2,5, Normal −2,5, Zor 0 yüzde puan; üçü de ±3 puan kapısında. Uç botların hepsi ilgili ölçütün %70 tavanının altında. Pacing ilk sekiz hafta 0,81 olay/hafta; en uzun olaysız seri 3 hafta. `--full --seed=101` TR ve EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay.

`tests/en_leak_test.gd`: 5 kampanya, 0 sızıntı; `tools/i18n_missing.py`: 0 eksik `tr()` kaynağı. İçerik denetimi 5 dosyada başarılı, olay denetimi 201 olayı 0 uyarıyla geçti. Tüm testler exit 0. `ui_input_test.gd`: masaüstü `UI INPUT: OK`, mobil `UI INPUT: OK (mobile)`. `a11y_test.gd` çıktısı `A11Y: OK`; Godot kapanışında iki testte RID/resource temizleme uyarısı var. Tam stdout son satırları ilerleme belgesindeki R4b test tablosunda tutuluyor.

TR/EN masaüstü ve mobilde bölge seçimi, yatırım, bölgesel kriz, vali azli ve atama görüntüleri açılıp incelendi. Seçenekler ve uzun kriz metni yatay mobilde taşmıyor; başlık ve karar düğmeleri görünür. Görüntüler kontrol sonrası silindi.


## R3c Ayar

Seçim sonucu rıza, ekonomi, huzursuzluk, yasa geçmişi ve açık skandallardan nitel blok kaymasına dönüştürülüyor; sonuçta kesin oy veya sandalye sayısı gösterilmiyor. Sonuç kartı hükümet kurma kararını açıyor. Veyra koalisyonunu sürdürme, Saray ve Bağımsızlar arasında uzlaşma ya da Brandt liderliğinde muhalefet hükümeti seçenekleri ayrı maliyet taşıyor. Koalisyon desteği zayıfladığında güven oyu kartı geliyor: Veyra'yı destekle, hükümeti düşür veya hazine/rıza/kral otoritesinden bedel ödeyip baskıyla kurtar. Düşüşte Kraliçe Helena mali raporlarını geçici olarak üstleniyor; yeni başbakan Veyra, Helena veya Brandt arasından seçiliyor. R1 bütçe kararları ve mali rapor akışı geçişte sürüyor.

Seçim/güven oyu rastgeleliği `government_rng` üzerinden gidiyor; ana ve meclis üreteçlerinin durumu değişmiyor. Kayıt v18; v17 kayıtlarında mevcut kabine ve ayrı üreteç varsayılanları göç sırasında ekleniyor.

| Bot / ölçüm (80 kampanya, Kolay / Normal / Zor) | Kolay | Normal | Zor | Ölçüt tavanının %70'i |
|---|---:|---:|---:|---:|
| Ölçüt (`advice_weighted`) | 62/80 | 31/80 | 17/80 | — |
| Her güven oyunda baskıyla kurtar (`confidence_force`) | 38/80 | 10/80 | 3/80 | 43,4 / 21,7 / 11,9 |
| Her güven oyunda hükümeti düşür (`confidence_fall`) | 37/80 | 11/80 | 3/80 | 43,4 / 21,7 / 11,9 |
| Mecliste hiç oy verme (`parliament_abstain`) | 29/80 | 10/80 | 4/80 | 43,4 / 21,7 / 11,9 |

Ölçüt hedefi 62/30/13; sapma 0/+1/+4, kapı ±4 içinde. Üç uç botun her biri ilgili ölçütün %70 tavanının altında. En düşük tempo ilk 8 haftada 0,81 olay/hafta; en uzun olaysız seri 3 hafta. `--full --seed=101` hem TR hem EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay, taban değişmedi. `tests/en_leak_test.gd`: 5 kampanyada 0 benzersiz sızıntı; `tools/i18n_missing.py`: 0 eksik çeviri.

`tests/election_test.gd` seçim etkenlerini ve RNG yalıtımını, erken seçim yasası eşiğini, hükümet kurma/güven oyu geçişini, Helena'nın mali raporu devralmasını, bütçe akışını, v17→v18 göçünü ve üç başarımı denetler. Tam test paketi bu oturumda exit 0 ile tamamlandı; test adları ve görsel kapı notları `docs/roadmap/FAZ7_ILERLEME.md` içinde.

## R4c Ayar

Bu dilim harita ve panel sunumuyla sınırlı kaldı; ekonomi, olay üretimi, bölgesel etkiler ve ana RNG akışında değişiklik yok. R4b sonrası son ölçülmüş `advice_weighted` tabanı Kolay 60/80, Normal 29/80, Zor 17/80 olarak korundu; R4c için ayrı 80 kampanyalık probe çalıştırılmadı. Dolayısıyla karşılaştırma önceki ölçümün aynısıdır ve R4b taban farkı 0/0/0 puandır. `--full --seed=101` bu oturumda yeniden çalıştırıldı:

| Ölçüt probe (R4b son ölçümü; 80 kampanya) | R4b sonucu | R4c karşılaştırması | Fark |
|---|---:|---:|---:|
| Kolay | 60/80 | 60/80 | 0 |
| Normal | 29/80 | 29/80 | 0 |
| Zor | 17/80 | 17/80 | 0 |

| `--full --seed=101` | TR | EN |
|---|---|---|
| Sonuç | 104 hafta / TAHTTA / Medya Rejimi / 112 olay | 104 hafta / TAHTTA / Medya Rejimi / 112 olay |

Tempo ölçümü R4b tabanından devralındı: ilk 8 haftada 0,81 olay/hafta; en uzun olaysız seri 3 hafta. `pacing_test.gd` yeniden geçti. `tests/en_leak_test.gd`: 5 kampanya, 0 benzersiz sızıntı; EN masaüstü/mobil dökümlerinde `tools/i18n_leak_scan.py`: 3.633 metin, 0 şüpheli; `tools/i18n_missing.py`: 0 eksik `tr()` kaynağı.

EN/TR masaüstü ve 1067×600 yatay mobil ekranlarında katman kapalı/açık, bölge paneli, vali kartı ve bölgesel kriz ekranları ayrı görüntüler olarak açılıp incelendi. Simge/şekil taraması renk gerektirmiyor; yıldız Günlük/Divan satırındaki öne çıkan bölgeyi eşliyor. Mobil işaretçiler kurum etiketleriyle kesişmiyor; bölge paneli açıkken arkasında kalan işaretçiler gizleniyor. Ana eylem düğmesi 48 px ve panelin ilk görünür bölümünde. Ekran görüntüleri yalnızca geçici klasörde tutuldu ve gözden sonra silindi.

Beckett `ui_snapshot` taraması çalışan masa görünümünde 150 görünür denetim buldu; `occluded_by` alanında iki rapor RichTextLabel'ı kendi PanelContainer'ı altında rapor içeriği olarak işaretlendi, etkileşimli hedef değiller. Beckett Lite oturumu harita ekranına giriş/etkileşim sağlayamadığı için harita katmanına özel `ui_snapshot` alınamadı. Harita için `region_map_test.gd` masaüstü/mobilde işaretçi-kurum dikdörtgen çakışmasını, bölge ve Parlamento tıklamalarını, panel kapanınca işaretçilerin geri gelmesini ve simülasyon/RNG değişmediğini doğruladı.

## R5a Ayar

R5a üç çevresel birlik ve komutanlarını ekledi. `army_rng`, ana RNG'den ayrı tutuluyor. Birim sadakati ortalaması Arden gücünü verir; eski kayıtlarda her birimin sadakati eski Arden gücüne eşlenerek başlangıç değerleri korunur. Birlik morali/ikmali ve komutan özellikleri yeni üreteçten gelir. R5a karar/eylem eklemediğinden savaş gücü katsayısı, oyun zorluğu veya olay akışı ayarlanmadı.

| `advice_weighted`, 80 kampanya | R4b tabanı | R5a sonucu | Fark |
|---|---:|---:|---:|
| Kolay | 60/80 | 60/80 | 0 |
| Normal | 29/80 | 29/80 | 0 |
| Zor | 17/80 | 17/80 | 0 |

Taban ±3 kapısı sağlandı ve varsayılan denge değişmedi. R5 kapısındaki `Zor ≤ 16` şartı 17/80 ile bir galibiyet farkla sağlanmadı; R5a'nın “varsayılan dengeyi kaydırma” kuralı nedeniyle bu ölçümü yapay olarak aşağı çekmedim. Ordu ödeneğini artırma/komuta zincirini bölme uç botları için R5a'da karar bulunmuyor; bu bot ölçümleri R5b kapsamındaki eylemler eklenmeden uygulanabilir değil.

`--full --seed=101` TR ve EN: **104 hafta / TAHTTA / Medya Rejimi / 112 olay**. Her iki dil de aynı sonucu verdi. R5a'nın yeni içerikleri TR/EN aktör verisinde ve `en.po` kataloğunda yer alıyor; birlik raporu sayı göstermez ve birliği nitel olarak vurgular.

EN/TR masaüstü ve 1067×600 mobilde Günlük raporu, Divan raporu ve komutan kartları ayrı ayrı açıldı. Günlük ile Divan'daki birlik cümlesi aynı; raporda sayısal gizli değer yok. Komutan kartları kompakt ve isim/rol kırpılmıyor; mobil kaydırmada erişiliyor. Masaüstü ve mobil yer tutucu zeminleri portre paletine yaklaştırıldı. Görüntüler incelemeden sonra silindi.

## R5b Ayar

R5b eylemleri `army_rng` kullanır; ana RNG akışı değiştirilmedi. R1 ordu tahsisi yetersizse ek ödenek kapalıdır; hazine bedeli tekrarlandıkça artar, gecikmeli moral/ikmal/sadakat getirisi azalır. Sadakat artışı Arden'in birliklerden türetilen gücüne de yansır. Bu yüzden ölçüt botu, Zor'da Arden'in görünür darbe aşaması en üst seviyeye ulaştığında bir kez komuta zincirini bölüyor: Arden'in gücü düşer, kapasite kaybı ve artan öfke/tansiyon karşılığında darbe baskısı da artar. Bot gizli sadakat değerlerine bakmıyor.

İlk R5b ölçümü, periyodik ek ödenek kararıyla 58/27/17 verdi. Sadakat getirisi 0,25'ten 0,5'e yükseltilince Zor 18'e çıktı; uyarı görünür olur olmaz komuta bölmek Zor'u 8'e, bir önceki aşamada bölmek 12'ye indirdi. Eylem etkisini/karar zamanını kök neden üzerinden kalibre edip yalnızca en yüksek görünür darbe uyarısında bölme kararı seçilince hedef aralığa dönüldü.

| `advice_weighted`, 80 kampanya | R5a tabanı | R5b sonucu | Fark |
|---|---:|---:|---:|
| Kolay | 60/80 | 58/80 | −2 |
| Normal | 29/80 | 27/80 | −2 |
| Zor | 17/80 | 15/80 | −2 |

| Uç bot (80 kampanya) | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Hep ordu ödeneği artır (`army_allowance`) | 14/80 | 3/80 | 0/80 |
| Hep komuta zincirini böl (`army_split`) | 11/80 | 4/80 | 0/80 |
| Garnizonu hep başkente çek (`army_garrison_capital`) | 13/80 | 2/80 | 0/80 |
| Hiç ordu kararı verme (`army_none`) | 14/80 | 2/80 | 0/80 |

Ölçüt sapması −2/−2/−2 puan; R5 kapısındaki tabana ±3 şartı ve Zor ≤16 kapısı geçti. En yüksek uç bot sonucu 14/80; %70 tavanları ölçüte göre Kolay 40,6, Normal 18,9, Zor 10,5 galibiyettir ve tüm uçlar altında kaldı. `pacing_test`: ilk 8 haftada 0,81 olay/hafta; en uzun olaysız seri 3 hafta.

`--full --seed=101` TR ve EN çıktısı:

```text
FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true
FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true
```

Her iki dilde sonuç 104 hafta / TAHTTA / Medya Rejimi / 112 olay olarak aynı kaldı. `EN LEAK SCAN: 5 campaigns, 0 unique leaks`; `tools/i18n_missing.py`: `0 tr() kaynağı en.po'da yok`.

`SAVE_VERSION` 21'den 22'ye çıktı. v21 kayıtlarında birlik bölgeleri, eylem durumu ve sayaçları güvenli varsayılanlarla ekleniyor; mevcut birlik/Arden gücü korunuyor. Belgeye alınan denge ve olay akışı ölçümleri R5b eylemlerini kullanan `advice_weighted` botuna aittir.

EN/TR masaüstü ve 1067×600 yatay mobilde eylem kartı, Günlük birlik raporu, Divan ve komutan kartları ayrı ayrı açılıp incelendi (toplam 16 görüntü). Dört dil/yerleşim birleşiminde metin taşması, gizli seçenek veya yüzü kapatan etiket görülmedi. Askerî değerler nitel; kart ve raporlarda gizli sayılar yok. Görüntüleri TEMP'den silme girişimlerini araç politikası engelledi; geçici klasör hâlâ duruyor.

### R5b test çıktıları

Her test `tools/run_test_isolated.ps1` ile ayrı geçici kullanıcı profili altında çalıştırıldı; çıkış kodları 0.

| Test | Başarı çıktısı |
|---|---|
| `a11y_test` masaüstü | `A11Y: OK` |
| `a11y_test --mobile` | `A11Y: OK` |
| `audio_check` | `AUDIO: OK` |
| `army_actions_test` | `ARMY ACTIONS: OK` |
| `army_test` | `ARMY TEST: OK` |
| `budget_ui_test` | `BUDGET UI: OK` |
| `content_check` | `CONTENT: OK (5 dosya, 8 bozuk örnek)` |
| `cutscene_check` | `CUTSCENE: OK` |
| `daily_card_test` | `DAILY CARD: OK` |
| `dynasty_test` | `DYNASTY: OK` |
| `economy_test` | `ECONOMY: OK` |
| `election_test` | `ELECTION: OK` |
| `endless_test` | `ENDLESS: OK` |
| `en_leak_test` | `EN LEAK SCAN: 5 campaigns, 0 unique leaks` |
| `event_check` | `EVENTS: OK (201 olay, 0 uyarı)` |
| `external_crisis_test` | `EXTERNAL CRISIS: OK` |
| `i18n_check` | `I18N: OK` |
| `lang_switch_test` | `LANG: OK` |
| `legacy_test` | `LEGACY: OK` |
| `pacing_test` | `H  1-  8        0.81        (280)`; `En uzun olaysız seri (medyan / en kötü): 2 / 3 hafta` |
| `parliament_laws_test` | `PARLIAMENT LAWS: OK` |
| `parliament_test` | `PARLIAMENT: OK` |
| `public_opinion_test` | `PUBLIC OPINION: OK` |
| `region_map_test` masaüstü | `REGION MAP: OK` |
| `region_map_test --mobile` | `REGION MAP: OK` |
| `regions_test` | `REGIONS: OK` |
| `save_test` | `SAVE: OK` |
| `scenario_test` | `SCENARIO: OK` |
| `sim_test` | `Meclis görüşleri: OK`; `Darbe aşamaları: OK`; `TEST: OK` |
| `touch_scroll_test` | `TOUCH: OK` |
| `touch_tap_test` | `TOUCH TAP: OK` |
| `tour_test` | `TOUR: OK` |
| `ui_input_test` masaüstü | `UI INPUT: OK` |
| `ui_input_test --mobile` | `UI INPUT: OK (mobile)` |
| `ui_logic_test` | `UI LOGIC: OK` |
| `unit_tests` | `[unit] all 399 checks passed` |

Birçok Godot süreci başarılı test özetinden sonra kapanışta RID/ObjectDB/resource temizleme uyarıları verdi; tüm test çıkış kodları yine de 0 oldu.


## R5c Ayar

R5c darbe akışı artık komplonun yöneldiği birliği, o birliğin bölgesini ve sarayın nöbet durumunu kullanıyor. Birlik alametleri `army_rng` ile üretiliyor; bastırma, pazarlık ve yedek birlik çağırma da aynı ayrı üreteci kullanıyor. Başkent garnizonunun sınırda olması yerel bastırma şansını azaltıyor; sınır kolordusunun sınırda, hazır ve sadık olması Drakon krizinde güç gösterisinin güvenilirliğini artırıyor. Yeni gizli durum için SAVE_VERSION 23 oldu; v22 darbe kayıtlarına güvenli `capital` birliği ekleniyor. İki yeni başarım birlikle bastırma ve komuta zincirini değiştirme kararlarını kaydediyor.

### Denge

`advice_weighted`, 80 kampanya. R5b tabanı ile son R5c ölçümü:

| Zorluk | R5b tabanı | R5c sonucu | Fark | R5c kapısı |
|---|---:|---:|---:|---:|
| Kolay | 58/80 | 59/80 | +1 | 60–64 — **1 galibiyet eksik** |
| Normal | 27/80 | 31/80 | +4 | 28–31 — geçti |
| Zor | 15/80 | 16/80 | +1 | 13–16 — geçti |

Kolay ölçümündeki kayıplar: mali çöküş 5, yabancı müdahale 10, saray darbesi 2, ayaklanma 3, askerî darbe 1. R5c birlik savunması ve sınır kolordusu etkisi eklendi; Easy askerî bastırma katsayısını artırmak Kolay galibiyetini değiştirmedi. Eksik galibiyet darbe dışı yabancı müdahale kayıplarından geliyor; R5c mekanikleri bu krizin tamamını karşılamıyor. Ölçüm hedefini karşılamadığı için bu kapı **başarısız** kaydedildi; sonucu gizlemek için başlangıç verisi ya da ölçüt botu değiştirilmedi.

| Uç bot (80 kampanya) | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Garnizonu hep sınıra çek (`army_garrison_border`) | 19/80 | 3/80 | 0/80 |
| Garnizonu hep başkente topla (`army_garrison_capital`) | 19/80 | 3/80 | 0/80 |
| Hiç ordu kararı verme (`army_none`) | 17/80 | 4/80 | 0/80 |
| Komuta zincirini hep böl (`army_split`) | 17/80 | 4/80 | 0/80 |

Dört uç bot da ölçütün %70 sınırının altında kaldı. `pacing_test`: ilk 8 hafta 0,81 olay/hafta; en uzun olaysız seri 3 hafta.

EN ve TR `--full --seed=101` çıktıları:

```text
FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true
FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true
```

EN sızıntı testi: `EN LEAK SCAN: 5 campaigns, 0 unique leaks`; `python tools/i18n_missing.py`: `0 tr() kaynağı en.po'da yok`. Eski kayıt ve ana RNG testleri geçti. Bütün testler `tools/run_test_isolated.ps1` ile ayrı geçici profilde çalıştırıldı. Özetler: `A11Y: OK` (masaüstü ve mobil), `ARMY ACTIONS: OK`, `ARMY COUP: OK`, `ARMY TEST: OK`, `AUDIO: OK`, `BUDGET UI: OK`, `CONTENT: OK (5 dosya, 8 bozuk örnek)`, `CUTSCENE: OK`, `DAILY CARD: OK`, `DYNASTY: OK`, `ECONOMY: OK`, `ELECTION: OK`, `ENDLESS: OK`, `EN LEAK SCAN: 5 campaigns, 0 unique leaks`, `EVENTS: OK (201 olay, 0 uyarı)`, `EXTERNAL CRISIS: OK`, `I18N: OK`, `LANG: OK`, `LEGACY: OK`, `PARLIAMENT LAWS: OK`, `PARLIAMENT: OK`, `PUBLIC OPINION: OK`, `REGION MAP: OK` (masaüstü ve mobil), `REGIONS: OK`, `SAVE: OK`, `SCENARIO: OK`, `TEST: OK`, `TOUCH: OK`, `TOUCH TAP: OK`, `TOUR: OK`, `UI INPUT: OK` (masaüstü), `UI INPUT: OK (mobile)`, `UI LOGIC: OK`, `[unit] all 399 checks passed`. Mobil özet değişikliğinden sonra `army_coup_test`, a11y (masaüstü/mobil), dokunma (kaydırma/bırakma), `ui_input_test` (masaüstü/mobil) ve `ui_logic_test` yeniden geçti. Bazı Godot headless kapanışları RID/ObjectDB/resource uyarısı verdi; çalıştırılan test süreçlerinin çıkış kodu 0'dı.

## Kalibrasyon (Faz 7 kapanış)

`advice_weighted`, 80 kampanya/zorluk; R5c sonrası kapanış ölçümü:

| Ölçüt botu | Önce (R5c) | Sonra | Hedef |
|---|---:|---:|---:|
| Kolay | 59/80 | 62/80 | 61–64 |
| Normal | 31/80 | 31/80 | 28–31 |
| Zor | 16/80 | 14/80 | 13–16 |

Kök neden tek bir katsayı değildi. Kolay'da R1 borç baskısı tüm zorluklarda aynı hızlı artıyordu; dış kuşatma/müdahale bunun üzerinden büyüyordu. Borç kaynaklı dış baskı artışı Kolay'da yavaşlatıldı, Normal ve Zor akışı korundu. Zor'da R5c darbe başarı payı ve hazırlık eşiği yüksek, R3b ordu yasasının Arden etkisi de bu seviyede fazlaydı. Zor darbe payı 0,63'ten 0,66'ya, hazır oluş itişi 36'dan 38'e yükseltilirken ordu yasası etkisi 4'ten 2,5'e indirildi. Bu ayar darbe baskısını karşılıklı dengeledi; Zor galibiyeti 2 arttı, askerî darbe kayıpları 47'den 38'e düştü. Kolay yabancı müdahale kayıpları 10'dan 8'e inerken Normal temel oranı değişmedi.

Kolay uç botları (80 kampanya): kemer 22, ödenek 40, baskıyla geçirme 39, oy vermeme 17, sınır garnizonu 21, başkent garnizonu 21, komuta bölme 22, ordu kararı yok 23, tek bölgeye yatırım 22, yatırım yok 19 galibiyet. En yüksek sonuç 40/80; ölçütün %70 sınırı olan 43,4'ün altında. `parliament_force`, zorla geçirme seçeneği yoksa destek vermek yerine teklifi cevapsız bırakacak şekilde düzeltildi; ölçülen strateji artık adındaki politikayı izliyor.

Senaryo dayanıklılığı `advice_weighted`, Normal, her biri 40 kampanya: Darbeye açık krallık 18/40; Naiplik 23/40; Boş kasa 14/40. Sonsuz mod Normal'de 40 kampanyayla 145. haftaya kadar çalıştırıldı; 0/40 bu noktaya sağ ulaştı. Erken bitişler arasında 22 askerî darbe, 10 ayaklanma ve diğer krizler vardı. Bu sonuç ayrı bir sonsuz-mod kazanma kapısı değil, uzun koşu stres ölçümüdür; senaryo başlangıçları değiştirilmedi.
