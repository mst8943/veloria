# Faz 4 ilerleme

Tarih: 2026-10-07. Dal: `veloria`. Tasarım ve değişmez kararlar: `docs/design/devlet_ve_patronaj.md` §13.

## Taban

`dist/phase4_baseline_probe.log`: 80 kampanya, `advice_weighted` Kolay 67/80 (%83), Normal 36/80 (%45), Zor 13/80 (%16). `advice_dirty`: %63/%41/%12; `visible_wise`: %100/%90/%71.

`dist/phase4_baseline_full.log`: tohum 101, hafta 104, TAHTTA, Oligark Rejimi, 115 olay.

## Tamamlanan adımlar

- **4a.1** `3eb95af`: dört kapasite alanı ayrı tohum üreteciyle başlatılır; kasa, bütçe duruşu, saray payı ve kapasite çizelgesi kaydedilir. `SAVE_VERSION=5`, v4 göçü ve kayıt testi eklendi. Bütün testler geçti; `--full` çıktısı tabanla aynı.
- **4a.1 test düzeltmesi** `2bed482`: `var_to_str` kayan nokta yuvarlaması için toleranslı kapasite karşılaştırması.
- **4a.2** `501d68b`: haftalık yıpranma/kasa/ekonomi/huzursuzluk, emir uygulama, kriz şansı, yargı baskısı ve rapor gürültüsü; Kessler'in raporu ekonomi ve kasayı birlikte okur. Kalibrasyon `ATTRITION=0,04`, ekonomi katsayıları `0,003/0,001`, Zor kasa gideri çarpanı `1,8`, Zor ordu toparlama paydası `100`. Bütün testler geçti; `--full` 104 hafta TAHTTA, 120 olay.
- **4a.3** `6f0ac53`: kapasite/kasa olay koşulları, kurum adı doğrulaması, sentetik uygunluk testi ve olay şeması belgesi. Bütün testler geçti; `--full` ve denge 4a.2 ile aynı.

## Son ölçüm

| Aşama | Kolay | Normal | Zor |
|---|---:|---:|---:|
| Taban | %83 | %45 | %16 |
| 4a.1 | %83 | %45 | %16 |
| 4a.2 | %80 | %42 | %18 |
| 4a.3 | %80 | %42 | %18 |

## Açık sorunlar

Tempo testinde 73–80. hafta dilimi **0,78**; 4a içerik adımıyla ≥0,8'e çıkarılmalı. `--full` olay sayısı mekanik değişim nedeniyle tabandaki 115'ten 120'ye çıktı. `export_presets.cfg` kullanıcı değişikliği olarak çalışma ağacında duruyor.

## SIRADAKİ ADIM

4a.4: çeyrek bütçe sistem kartı ve `choice_value` yeni değer terimleri. Erteleme ve bekleyen karar sınırını test et; ardından bütün testler ve denge ölçümü.
