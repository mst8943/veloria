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

## R2 Ayar

Ölçüt ve görünürlük botları, 80 kampanya/zorluk (`advice_weighted`, `public_out`, `public_hide`):

| Zorluk | R1 tabanı | Ölçüt | Hep halka çık | Hep gizlen |
|---|---:|---:|---:|---:|
| Kolay | 61/80 (%76,25) | 61/80 (%76,25) | 23/80 (%28,75) | 0/80 (0%) |
| Normal | 31/80 (%38,75) | 31/80 (%38,75) | 15/80 (%18,75) | 0/80 (0%) |
| Zor | 14/80 (%17,50) | 14/80 (%17,50) | 1/80 (%1,25) | 0/80 (0%) |

Kalibrasyon: “gizlen” hamlesi başına rıza −1, korku +1; korku yüksek ve rıza düşük kaldıkça haftalık huzursuzluk ikisinden türetiliyor. Böylece tek başına gizlenme kazanma sağlamaz; etkisi anlık değil, birikimli. Halka çıkış eylemlerinin maliyeti 1 mesai; saha ziyaretindeki protesto riski kamuoyu RNG'sinden gelir. Anket kaynak farkı: Sarne +8, Leyla −8, bağımsız kurum ±12 puan gürültü; oyuncu yalnızca nitel destek bandını görür. R2 devre dışıyken R1'in mevcut huzursuzluk akışı ve ana RNG'si aynı kalır.

Ölçüt R1 tabanının farkı: Kolay 0, Normal 0, Zor 0 puan. `public_out` ve `public_hide` tek yönlü botları hiçbir zorlukta ölçüt botunu geçmiyor. `--full --seed=101` TR/EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay. Tempo en düşük dilim 0,81; en uzun olaysız seri 3 hafta. EN leak taraması: 4.320 metin, şüpheli 0; `i18n_missing.py`: 0.
