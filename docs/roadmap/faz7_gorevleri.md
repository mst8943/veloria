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

## R4 — Bölgeler
Tasarım: "R4". R5 — Ordu iç yapısı: Tasarım: "R5". İkisi de R1–R3 oturduktan sonra; ayrı oturumlarda.
