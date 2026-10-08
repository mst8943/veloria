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

Henüz yok.

## Ölçüm tablosu

| Aşama | Kolay | Normal | Zor | Tam oyun |
|---|---:|---:|---:|---|
| Taban | %83 | %46 | %17 | 101 / 104 / TAHTTA / Medya Rejimi / 112 olay |

## Açık sorunlar

Faz 4c'den devreden Zor bot farkı: `advice_soft` ve `advice_lavish` ölçütü +9/+11 puan aşıyor. Yeni kadro kapılarının ölçümü bu eski farktan bağımsız kaydedilecek.

## SIRADAKİ ADIM

B1.1: Julian ve Elena'yı ana RNG'yi ve darbe payını koruyarak ekle; kayıt sürümünü 8'e yükselt, v7 göçünü ve kaydet/yükle testini ekle. Sonra bütün işlev testlerini ve tohum 101 tam oyunu çalıştır.
