# Faz 7 — Gerçekçilik: Codex görev dosyası (kalıcı)

Önce `docs/roadmap/faz6_gorevleri.md` içindeki "Değişmez kurallar" bölümünü oku (hepsi geçerli) ve `docs/design/gerceklik_faz7.md` tasarımını BAŞTAN SONA oku. Dilimleri SIRAYLA yap; her dilim ayrı commit(ler); ilerleme `docs/roadmap/FAZ7_ILERLEME.md`. Bir oturumda yalnızca "SIRADAKİ"(leri) bitir, dur, kısa Türkçe rapor ver. PUSH YOK, bilgisayarı kapatma veya kapatma zamanlama.

## Denge tabanı (B1+B2 sonrası, ölçüt botu advice_weighted, 80 kampanya)
Kolay 62/80, Normal 30/80, Zor 13/80. Her dilim sonrası ±8 puan içinde kal; fark varsa "Ayar" bölümüne ölçümlü yaz. `--full` tohum 101 TR=EN: 104 hafta / TAHTTA / Medya Rejimi / 112 olay; değişirse yeni tabanı açıkça belgele ve raporda işaretle.

## R1 — Ekonomi ve bütçe (SIRADAKİ)
Tasarım: gerceklik_faz7.md "R1". Parçalar (ayrı commit): (a) beş gizli gösterge + türetilmiş `economy` + kayıt göçü + Maliye raporu nitel bantları (yalan/yanılma sistemine bağlı) ve medya kanallarında farklı tablo; (b) çeyreklik bütçe kararı (üç hazır paket + özel seçim, gecikmeli etkiler), mevcut `Quarterly Budget` olayı yerini alır/genişler; (c) vergi / kemer sıkma / teşvik eylemleri (Devlet sekmesi), azalan getiri; (d) borç → dış baskı (`ext_pressure`/`siege`) bağı; (e) Günlük ve Divan'da ekonomi satırları; TR/EN içerik; en az 3 başarım.
Kapı: tüm testler (yeni tests/economy_test.gd), ölçüt probe ±8, "sosyal hep yüksek" ve "kemer hep sıkı" ucu botları tek başına kazanmamalı (≤ ölçütün %70'i), tempo ≥ 0,8, sızıntı kapıları 0, EN+TR masaüstü ve mobil ekran görüntüleri (bütçe kartı, Maliye raporu, Devlet sekmesi) gözle.

## R2 — Kamuoyu ve meşruiyet
Tasarım: "R2". `consent`/`fear`, anket kartı (kaynağa göre yanılır), kral görünürlüğü eylemleri, skandal yanıtı seçimi. Kapı: R1 ile aynı + "hep halka çık" ve "hep gizlen" botları tek başına kazanmamalı.

## R3 — Meclis ve kanunlar
Tasarım: "R3". Bloklar, kanun teklifi kartları, belirsiz oylama, kalıcı yasa etkileri, seçim ve güven oyu. En büyük dilim: alt dilimlere böl (bloklar+teklifler, yasa etkileri, seçim/güven oyu). Kapı: R1 ile aynı.

## R4 — Bölgeler
Tasarım: "R4". R5 — Ordu iç yapısı: Tasarım: "R5". İkisi de R1–R3 oturduktan sonra; ayrı oturumlarda.
