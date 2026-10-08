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

## Ölçüm tablosu

| Aşama | Kolay | Normal | Zor | Tam oyun |
|---|---:|---:|---:|---|
| Taban | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.1 `5a18c3f` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.2 `92dbeae` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |
| B1.3 `a5f0eb9` | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |

## Açık sorunlar

Faz 4c'den devreden Zor bot farkı: `advice_soft` ve `advice_lavish` ölçütü +9/+11 puan aşıyor. Yeni kadro kapılarının ölçümü bu eski farktan bağımsız kaydedilecek.

## SIRADAKİ ADIM

B1.4: `min_heir/max_heir` olay koşullarını, `event_check` doğrulamasını ve VELORIA şemasını ekle. Tüm testler ve ölçüt ölçümü geçince ayrı commit'le.
