# Faz 7 — Gerçekçilik: Codex görev dosyası (kalıcı)

Önce `docs/roadmap/faz6_gorevleri.md` içindeki "Değişmez kurallar" bölümünü oku (hepsi geçerli) ve `docs/design/gerceklik_faz7.md` tasarımını BAŞTAN SONA oku. Dilimleri SIRAYLA yap; her dilim ayrı commit(ler); ilerleme `docs/roadmap/FAZ7_ILERLEME.md`. Bir oturumda yalnızca "SIRADAKİ"(leri) bitir, dur, kısa Türkçe rapor ver. PUSH YOK, bilgisayarı kapatma veya kapatma zamanlama.

## Denge tabanı (B1+B2 sonrası, ölçüt botu advice_weighted, 80 kampanya)
Kolay 62/80, Normal 30/80, Zor 13/80. Her dilim sonrası ±8 puan içinde kal; fark varsa "Ayar" bölümüne ölçümlü yaz. `--full` tohum 101 TR=EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay; değişirse yeni tabanı açıkça belgele ve raporda işaretle.

## R1 — Ekonomi ve bütçe (TAMAM)
Tasarım: gerceklik_faz7.md "R1". Parçalar (ayrı commit): (a) beş gizli gösterge + türetilmiş `economy` + kayıt göçü + Maliye raporu nitel bantları (yalan/yanılma sistemine bağlı) ve medya kanallarında farklı tablo; (b) çeyreklik bütçe kararı (üç hazır paket + özel seçim, gecikmeli etkiler), mevcut `Quarterly Budget` olayı yerini alır/genişler; (c) vergi / kemer sıkma / teşvik eylemleri (Devlet sekmesi), azalan getiri; (d) borç → dış baskı (`ext_pressure`/`siege`) bağı; (e) Günlük ve Divan'da ekonomi satırları; TR/EN içerik; en az 3 başarım.
Kapı: tüm testler (yeni tests/economy_test.gd), ölçüt probe ±8, "sosyal hep yüksek" ve "kemer hep sıkı" ucu botları tek başına kazanmamalı (≤ ölçütün %70'i), tempo ≥ 0,8, sızıntı kapıları 0, EN+TR masaüstü ve mobil ekran görüntüleri (bütçe kartı, Maliye raporu, Devlet sekmesi) gözle.

## R2 — Kamuoyu ve meşruiyet (TAMAM)
Tasarım: "R2". `consent`/`fear`, anket kartı (kaynağa göre yanılır), kral görünürlüğü eylemleri, skandal yanıtı seçimi. Kapı: R1 ile aynı + "hep halka çık" ve "hep gizlen" botları tek başına kazanmamalı.

## R3 — Meclis ve kanunlar (SIRADAKİ)
Tasarım: gerceklik_faz7.md "R3" (R1 bütçe ve R2 kamuoyu ile bağlanır). Üç alt dilim, SIRAYLA, her biri ayrı commit(ler); her alt dilim sonrası kapıları çalıştır. Bu oturumda yalnızca R3a'yı bitir, dur, rapor ver (R3b/R3c sonraki oturumlarda).
- **R3a — Bloklar ve kanun teklifleri:** dört gizli blok (Saray listesi, Muhalefet, Soylular, Bağımsızlar; her birinde sadakat + baskı noktası), mevcut `opposition` ve patronaj bunlardan türetilir (geriye dönük uyum, kayıt göçü, SAVE_VERSION). ~10 haftada bir kanun teklifi kartı; seçenekler: destekle / değiştir / geri çek / baskıyla geçir (patronaj, tehdit, rüşvet: bedel ve iz). Oylama sonucu belirsiz; kesin oy sayısı YOK, yalnızca blok davranışı ve vekil sayımı söylentileri (nitel). Başarısız teklif muhalefeti güçlendirir. Meclis raporu/Günlük/Divan satırları, TR/EN içerik, yeni RNG ayrı üreteç.
- **R3b — Kalıcı yasa etkileri:** kabul edilen yasalar kuralları değiştirir (basın yasası → Leyla'nın etkisi ↓ ama rıza ↓; ordu bütçesi → Arden ↑ ve R1 tahsisi; vergi reformu → R1; seçim yasası → erken seçim eşiği; af, yargı reformu). Yürürlükteki yasalar Günlük/Divan'da listelenir; yürürlükten kaldırma ayrı bir bedelli karardır.
- **R3c — Seçim ve güven oyu:** `erken_secim` olayı gerçek seçime bağlanır (blok dağılımı değişir; sonuç bir hükümet kurma kararı); Başbakan (Veyra) meclis desteğini kaybederse güven oyu/hükümet krizi, yeni başbakan atama kararı.
Kapı (her alt dilim): tüm testler (yeni tests/parliament_test.gd, R3b/R3c için eklemeler), ölçüt probe ±8 (Kolay 62 / Normal 30 / Zor 13 /80), "hep baskıyla geçir" ve "hep geri çek / hiç oy verme" uç botları tek başına kazanmamalı (≤ ölçütün %70'i), tempo ≥ 0,8, `--full --seed=101` TR=EN, sızıntı kapıları 0, EN+TR masaüstü ve mobil ekran görüntüleri (teklif kartı, Meclis raporu, Divan) gözle; sayı gösterme ilkesi korunur.

## R4 — Bölgeler (R4a/R4b TAMAM, R4c SIRADAKİ)
Tasarım: gerceklik_faz7.md "R4" (R1–R3 ile bağlanır: bölgesel ekonomi R1'e, bölgesel rıza R2'ye, vali ve vekil dağılımı R3'e). Üç alt dilim, SIRAYLA; her oturumda yalnızca SIRADAKİ alt dilimi bitir.
- **R4a — Bölge verisi ve raporlar (TAMAM):** dört bölge (Başkent, Sanayi Kuşağı, Tarım Ovaları, Sınır İlleri), her birinde gizli `unrest/loyalty/economy`; ulusal `unrest/economy` bölgelerin ağırlıklı özeti olur (geriye dönük uyum, kayıt göçü, SAVE_VERSION artır). Her bölgeye bir vali (supporting aktör, çevresel; ana RNG'yi tüketmez, ayrı üreteç). Bölge raporu satırları (Günlük/Divan, nitel, "sayı yok"); Divan'da "Devlet" grubunda vali kartı. Bölge dağılımı varsayılanda dengeyi KAYDIRMAMALI (ulusal değerler eski türetmeyle ±küçük).
- **R4b — Kararlar ve bölgesel krizler (TAMAM):** oyuncunun Devlet eyleminden açtığı yatırım/garnizon/yerel medya/vali kararları; gecikmeli ve R1 tahsisine bağlı etkiler; dört bölgesel kriz `region_rng` ile ve sınır geriliminin dış kriz akışına bağlanması; R3 blok/patronaj bedelli vali ataması/azli.
- **R4c — Harita katmanı:** Başkent haritasına bölge katmanı (renksiz nitel simgeler), bölge seçimi ve bölge paneli, mobil düzen.
Kapı (her alt dilim): tüm testler (yeni tests/regions_test.gd), ölçüt probe Kolay 62 / Normal 30 / Zor 13 (/80) ±4 puan içinde, "hep tek bölgeye yatırım" ve "hiç yatırım yapma" uç botları tek başına kazanmasın (ölçütün en çok %70'i), tempo ≥ 0,8, `--full --seed=101` TR=EN 104 hafta / TAHTTA / Medya Rejimi / 112 olay (değişirse yeni tabanı belgele), sızıntı kapıları 0, EN+TR masaüstü ve mobil ekran görüntüleri gözle; ölçümler "R4 Ayar" bölümüne.

## R5 — Ordu iç yapısı
Tasarım: "R5"; R4'ün garnizon/bölge verisini kullanır. R4 bitince ayrı oturumlarda, alt dilimlere bölünerek.

## Denge tabanı (R4b sonrası, güncel): Kolay 62/80, Normal 31/80, Zor 17/80 (advice_weighted). R4b ölçümü bu tabandan en çok ±3 puan sapabilir; Zor'un 14–15'e yaklaşması tercih edilir. R4c yalnızca sunum değiştirir ve R4b tabanına ±2 puan içinde kalmalıdır.

## KALICI KURAL — Rapor dürüstlüğü
Raporda "X testi geçti" yazdığın her test için çıktının son satırını (ör. `UI INPUT: OK`) aynen yaz; çalıştırmadığın testi geçti diye yazma. Yeni sistem Divan, kişi kartı, harita gibi ortak arayüzü değiştiriyorsa `ui_input_test` (masaüstü + `-- --mobile`), `ui_logic_test`, `touch_scroll_test`, `a11y_test`, `tour_test`, `lang_switch_test` dahil HEPSİNİ çalıştır; kırılan testi koda uydurmadan önce kodun mu testin mi güncel olduğuna karar ver.

## KALICI KURAL — Gözlem (her dilimde, hepsi için geçerli)
Her dilimde kapılara ek olarak ürünü eleştirel gözle de değerlendir: **iyileştirme, tutarsızlık, eksik özellik, UI/UX sorunu** (ekran görüntüsü aç; kesilen/çakışan metin, tıklama yutan öğe, kafa karıştırıcı akış, mobil/EN farkı, diğer sistemlerle çelişki, istismar yolu). Küçük ve güvenli olanları aynı dilimde düzelt (ayrı commit). Büyük/tasarım gerektirenleri `docs/roadmap/GOZLEMLER.md` dosyasına tarih, dilim, ekran/konum, öneri ve önem (düşük/orta/yüksek) ile ekle. Raporda ayrı bir "Gözlemler" başlığı aç: bulduğun, düzelttiğin ve ertelediğin. Hiçbir şey bulamadıysan bile hangi ekranlara baktığını yaz.

## Cila bekleyenler (R4a/R4b'de tamamlandı)
- [x] Kamuoyu araştırması kartında görselsiz kart başlığına üst boşluk eklendi.
- [x] Hanedan defterinde metin sarımı ve kaydırma düzeltildi.
- [x] Suikast kartı doğru görsele bağlandı.
- [x] Mobilde ayrı Divan çekmecesi eklendi; yinelenen alt yardım satırı kaldırıldı.
- [x] R4b: bölge Günlük satırı tek öne çıkan bölgeyi nitel terimlerle gösterip ötekileri özetliyor.
- [x] R4b: vali kartlarının baş harf zeminleri koyu ve desatüre palete çekildi.
- [x] R4b: masaüstü Divan vali kartları küçültülerek dış ilişkiler grubunun dikey taşması azaltıldı.
- [x] R4b: görsel test çıktıları vali azli ve atamasını ayrı dosyalara kaydediyor.
