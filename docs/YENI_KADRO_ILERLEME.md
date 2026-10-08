# Yeni kadro ilerleme

Tarih: 2026-10-08. Dal: `veloria`. Tasarım: `docs/design/yeni_kadro.md` §1–2. Kullanıcıya ait `export_presets.cfg`, portre notları ve önizleme görseli çalışma ağacında; commit'e alınmayacak.

## Taban

`dist/yeni_kadro_baseline_full.log`: tohum 101, **hafta 104, TAHTTA, Medya Rejimi, 112 olay**.

`dist/yeni_kadro_baseline_probe.log`: 80 kampanya/zorluk.

| Bot | Kolay | Normal | Zor |
|---|---:|---:|---:|
| advice_weighted | 67/80 (%83) | 37/80 (%46) | 14/80 (%17) |
| advice_dirty | 70/80 (%87) | 34/80 (%42) | 10/80 (%12) |
| visible_wise | 80/80 (%100) | 70/80 (%87) | 59/80 (%73) |

Ölçütte Marcus Arden darbe girişimi 26/80, 51/80, 70/80. Ölçüm sırasında oyun dosyası düzenlenmedi.

## Uygulama kararı

Yeni aktörlerin başlangıç gürültüsü ve yeni durum değerleri ayrı tohum üretecinden gelecek. Eski dokuz kişinin ana RNG tüketimi ve darbe payı korunacak. Julian ve Elena kişi/olay/rapor ekranlarında görünecek; darbe yürütme hesabına eklenmeyecek. Beş yeni portre mevcut isimlerinden iç kimliklerine taşınacak. Eylemler ve dış güçler küçük etki grupları olarak ayrı ölçülecek.

## Tamamlanan adımlar

- **B1.1** `5a18c3f`: Julian ve Elena aktörleri dosyanın sonunda; `supporting` işaretiyle eski dokuz kişinin ana RNG, haftalık büyüme, darbe payı, alamet ve rapor çekilişlerine girmezler. Başlangıç gürültüsü ile veliaht olgunluğu ayrı üreteçten gelir. Kayıt sürümü 8, v7→v8 göçü ve iki portre içe aktarması yapıldı. Yeni rapor alanlarının şeması tamamlandı; rapor üretimi B1.3'te açılacak. `TEST: OK` (eski dokuz aktörün RNG değerleri ayrıca denetlendi), `EVENTS: OK (179, 0)`, `SAVE: OK`, `CONTENT: OK`, `UI INPUT: OK`, masaüstü/mobil `AUTOPLAY DONE`; tempo görülen dilimler ≥0,81. Tam oyun **101 / 104 / TAHTTA / Medya Rejimi / 112 olay** ile tabanla birebir aynı. Ölçüt 80 kampanya/zorlukta **%83/%46/%17**, tabanla aynı.
- **B1.2** `92dbeae`: Veliahdı Yetiştir eylemi, altı hafta bekleme, olgunluk bandı, yüksek olgunluğun küçük haftalık etkisi ve üçüncü ardışık eğitimde Marcus ile Arden'in hırs sınaması. `TEST/EVENTS/SAVE/CONTENT/UI INPUT: OK`; masaüstü/mobil autoplay, tempo ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay. Ölçüt %83/%46/%17.
- **B1.3** `a5f0eb9`: Julian ve Elena'nın ayrı üreteçle hazırlanan raporları, ilgili meclis uzmanlıkları ve sesleri. Eski ölçüt bot yeni raporları karar girdisi olarak kullanmadığından eski stratejisi korundu. `TEST: OK`, `EVENTS: OK (179, 0)`, `SAVE: OK`, `CONTENT: OK`, `UI INPUT: OK`; masaüstü/mobil autoplay, tempo ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay. Ölçüt **67/80, 37/80, 14/80 (%83/%46/%17)**, tabanla birebir aynı.
- **B1.4** `fd374f5`: `min_heir/max_heir` olay koşulları, doğrulayıcı, birim sınaması ve şema belgesi. Tüm testler geçti; ölçüt %83/%46/%17, tam oyun değişmedi.
- **B1.5** `577ab07`: Julian için dört, Elena için dört olay; Elena'nın doğrulanması kendi olay zincirini açar. Olaylar mevcut görselleri kullanır. `EVENTS: OK (187 olay, 0 uyarı)`; ulaşılabilirlik sınaması, tam oyun ve tempo geçti. Ölçüt %83/%46/%17, tabanla aynı.
- **B1.6** `20a70af`: `advice_veliaht` sondajı, ölçülen dengeye göre veliahtın haftalık etkisinin tek grup olarak küçültülmesi, masaüstü/mobil ekran görüntüsü kipi. Tüm testler (`TEST/EVENTS/SAVE/CONTENT/UI INPUT: OK`, iki autoplay, pacing, full) geçti. `dist/qa_yeni_kadro_b1_desktop` ve `_mobile` içindeki Julian/Elena kartı, Elena raporu ve Julian olay kartı PNG'leri açılıp incelendi. UI glif taraması temiz; iki port 8770.
- **B2.1** `e9311c3`: Claire Duvall, Viktor Malenkov ve Lucien Vale dosyanın sonunda dışarıdan/supporting aktörler olarak eklendi. Portreleri iç kimliklerine taşındı; baştaki üç ilişki 50±5 ayrı üreteçten geliyor. B1 v8 kayıtları dış ilişkiler ve yeni aktörler yoksa göçte tamamlanıyor; bozuk kayıt reddi korunuyor. `TEST/EVENTS/SAVE/CONTENT/UI INPUT: OK`, masaüstü/mobil autoplay, pacing ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay. Ölçüt %83/%46/%17.
- **B2.2** `1f698d7`: Asteria, Drakon ve Seravia'nın haftalık kayması; yakın/soğuk küçük etkileri ve Drakon'un sadece mevcut darbe krizi savunmasına eklenen desteği. Parametre tablosu tasarım belgesinde. Yön, eşik ve zorluk katsayısı birim testte sınandı. `TEST/EVENTS/SAVE/CONTENT/UI INPUT: OK`, masaüstü/mobil autoplay, pacing ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay. Ölçüt **%85/%45/%20** (tabandan +2/−1/+3, ±3 içinde).
- **B2.3** `c330cbf`: Elena raporu artık Asteria, Drakon ve Seravia için yalnızca Soğuk/Mesafeli/Yakın bantlarını veriyor; iyimserlik ve ayrı üreteç gürültüsü korunuyor. Doğrula altı hafta gürültüsüz bant açıyor. DIŞİŞLERİ eşik haberleri bir kez gündeme düşüyor; TV şeridine aktarılmıyor. DEVLET sekmesindeki Heyet Gönder seçili elçiliği güçlendirip diğer ikisini hafifçe geri çekiyor ve dört hafta bekliyor. Birim testi hedef yönünü, beklemeyi ve Doğrula sonucunu kapsıyor. `TEST/EVENTS/SAVE/CONTENT/UI INPUT: OK`; masaüstü/mobil autoplay, tempo ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay; tempo alt sınırı **0,81**.
- **B2.4** `d05fd38`: Olay şemasına `min_foreign/max_foreign{asteria|drakon|seravia: değer}` eklendi; motor koşulu uygular, denetleyici bilinmeyen güç ve 0–100 dışı değeri reddeder. Birim testi olumlu ve olumsuz uygunluk durumunu kapsıyor. `TEST/EVENTS/SAVE/CONTENT/UI INPUT: OK`; masaüstü/mobil autoplay, tempo ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay.
- **B2.5** `519bb33`: Asteria kredi/özgürlük notası, Drakon silah/sınır/darbe desteği ve Seravia yatırım/ambargo/Sarne kredisi için sekiz olay eklendi. Olaylar Heyet Gönder bayrağıyla açılır; bu kapı yeni sistemi kullanmayan kampanyaların içerik akışını değiştirmez. `fx.foreign` etkisi ve doğrulaması eklendi. `TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)`, `SAVE/CONTENT/UI INPUT: OK`; masaüstü/mobil autoplay, tempo ve tam oyun geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay; tempo alt sınırı 0,81.
- **B2.6** `10d34f7`: Sondaja dönüşümlü elçilik kullanan `advice_heyet` ve yalnız Drakon'a yaslanan `advice_bloc` eklendi. 80 kampanya/zorluk ölçümünde ölçüt **%85/%45/%20**, heyet **%87/%50/%25**, blok **%87/%45/%27** çıktı. Ölçüt tabandan +2/−1/+3; heyet/blok farkları sırasıyla en çok +5/+7 puan, kapı sınırları içinde.
- **B3.1** `cb2e15c`: Başkent haritasına mevcut zemin üzerinde Asteria, Drakon ve Seravia plakaları eklendi. Elçilik çekmecesi ilişki bandını, Elena'nın iyimserlik uyarısını ve altı haftalık kayıt açan Doğrula düğmesini gösteriyor. `UI INPUT: OK`.

## Ölçüm tablosu

| Aşama | Kolay | Normal | Zor | Tam oyun |
|---|---:|---:|---:|---|
| Taban | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.1 `5a18c3f` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.2 `92dbeae` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.3 `a5f0eb9` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.4 `fd374f5` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.5 `577ab07` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1 kapısı | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B2.1 `e9311c3` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B2.2 `1f698d7` | %85 | %45 | %20 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B2.3 `c330cbf` | Ölçülmedi | Ölçülmedi | Ölçülmedi | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B2.4 `d05fd38` | Ölçülmedi | Ölçülmedi | Ölçülmedi | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B2.5 `519bb33` | Ölçülmedi | Ölçülmedi | Ölçülmedi | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B2.6 `10d34f7` | %85 | %45 | %20 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |

## B1 kapısı

80 kampanya/zorluk, aynı tohumlar: `advice_veliaht` kazanma Kolay **72/80 (%90)**, Normal **34/80 (%42)**, Zor **18/80 (%22)**. Ölçütle fark +7/−4/+5 puan; +8/−20 sınırları içinde. Prens Marcus darbe girişimi ölçütte 0/1/2, veliaht botunda 0/2/4 (80 oyunda); artış 0/1,25/2,5 puan ve +3 sınırının altında. Tempo en düşük dilim **0,81 olay/hafta**; tabanla tüm dilimler aynı, yeni olay yükü **+0,00/hafta** (eski sistemi kullanan 40 tohumluk tempo sondajında). 101 tohumu 104 hafta TAHTTA, Medya Rejimi, 112 olay. Ekran görüntülerinde mobil üçüncü sıradaki Elena kartı ve raporu kaydırılarak görüldü. Kapı geçti; B2'ye henüz başlanmadı.

## B2 kapısı

Ölçüt bot 80 kampanya/zorlukta **%85/%45/%20**: tabana göre +2/−1/+3 ve hedef bantlarda. Dönüşümlü heyet botu **%87/%50/%25**, Drakon blok botu **%87/%45/%27**; ölçütü hiçbir zorlukta 8 puandan fazla aşmadı, 20 puandan fazla altına inmedi. Ölçütte Prens Marcus girişimi 2/80, 1/80, 2/80; B2.2 öncesi tabanla kıyaslandığında +3 puan sınırını aşan bir artış yok.

`TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)`, `SAVE: OK`, `CONTENT: OK`, `UI INPUT: OK`; masaüstü/mobil autoplay, tempo ve `--full` geçti. Tam oyun 101 / 104 / TAHTTA / Medya Rejimi / 112 olay. Tempo en düşük dilimi 0,81 olay/hafta. `dist/qa_b2_desktop2` ve `dist/qa_b2_mobile2` içinde Heyet Gönder, Elena'nın üç bant raporu ve Asteria olay kartı gözle incelendi; glif taraması temiz. **B2 kapısı geçti.**

## Açık sorunlar

Faz 4c'den devreden Zor bot farkı: `advice_soft` ve `advice_lavish` ölçütü +9/+11 puan aşıyor. Yeni kadro kapılarının ölçümü bu eski farktan bağımsız kaydedilecek.

## SIRADAKİ ADIM

B3.2: Oyun sonu hakikat çizgilerine dış ilişkiler ve veliaht olgunluğunu, Devlet Defteri'ne iki satırı ekle.
