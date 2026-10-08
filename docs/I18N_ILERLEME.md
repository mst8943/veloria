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

- L1 için `event_check` ve `content_check` komut satırından `--lang=en`
  seçeneğini henüz almıyor. İngilizce kaplamalar L4'te yazılacak; bu nedenle
  yükleyici bugün güvenli Türkçe geri dönüş kullanır.

## SIRADAKİ ADIM

L1 devamı: Türkçe test kilidi ve İngilizce doğrulama parametreleri. Ardından
L1 kapısı için tam test, `--full`, ölçüt ve menü ekran görüntüsü alınacak.

## L1 — devam ediyor

- Statik `Loc` yardımcısı ve `en.po` başlığı eklendi. `Loc` sistem yerelini
  kullanmaz; varsayılanı `tr`dir.
- `Sfx` ayar dosyası dili saklar; menü Ayarlar ekranında `Dil / Language`
  seçicisi yer alır.
- Kaydedilen kampanya dili v9 alanıdır; v8 ve öncesi kayıtlar `tr`ye göçer.
- `content_data.gd`, İngilizce etkinse `game/data/en/` içindeki metin
  kaplamasını güvenli biçimde birleştirir. Kaplama yoksa Türkçe kaynak kalır.
- İlk kontroller: `I18N: OK`, `SAVE: OK`, `TEST: OK`.
