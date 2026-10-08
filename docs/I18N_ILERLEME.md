# İngilizce Yerelleştirme İlerlemesi

## Taban (L0)

| Kanıt | Sonuç |
|---|---|
| `sim_test.gd` | `TEST: OK` |
| `--autoplay --full` | `FULLRUN tohum=101 hafta=104 sonuç=TAHTTA ünvan=Medya Rejimi olay=112` |
| Ölçüt, `advice_weighted`, 80 kampanya | Kolay 85% (68/80), Normal 45% (36/80), Zor 20% (16/80) |
| Masaüstü ekran görüntüsü | 17 PNG, `dist/i18n_tr_desktop/`; oyun ve DEVLET ekranı gözle doğrulandı |
| Mobil ekran görüntüsü | 19 PNG, `dist/i18n_tr_mobile/`; oyun ve Saray/DEVLET ekranı gözle doğrulandı |

Ham başsız çıktılar `dist/i18n_tr_logs/` altındadır. Ölçüm sırasında oyun
dosyası değiştirilmedi.

## Tamamlanan adımlar

- L0.1 — `tools/i18n_scan.py` GDScript sabitlerini ve JSON oyuncu metinlerini
  envanterler. İç içe `content_reports`, `content_council`,
  `content_achievements` ve `content_history` özyinelemeli taranır; meclisteki
  `experts` aktör kimliği dizisi metin sayılmaz. Commit: bekliyor.
- L0.2 — Terim ve üslup sözlüğü: `docs/i18n/sozluk_en.md`. Commit: bekliyor.
- L0.3 — Türkçe taban test, tam oyun, ölçüm ve görsel kanıtları kaydedildi.
  Commit: bekliyor.

## Açık sorunlar

- Yok. L1 öncesi L0 dosyaları tek mantıksal commit olarak kaydedilecek.

## SIRADAKİ ADIM

L1: `Loc` altyapısı, boş `en.po`, içerik kaplama yükleyicisi, dil ayarı ve
kayıt göçü. Türkçe varsayılanı ile taban sonuçları korunacak.
