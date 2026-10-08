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
  `experts` aktör kimliği dizisi metin sayılmaz. Commit: `b5112f4`.
- L0.2 — Terim ve üslup sözlüğü: `docs/i18n/sozluk_en.md`. Commit: `b5112f4`.
- L0.3 — Türkçe taban test, tam oyun, ölçüm ve görsel kanıtları kaydedildi.
  Commit: `b5112f4`.

## Açık sorunlar

- İngilizce içerik kaplamaları L4'te yazılacak. O zamana kadar İngilizce dil
  seçimi, eksik içerikte güvenli Türkçe geri dönüş kullanır.

## SIRADAKİ ADIM

L2: statik arayüz metinleri, dosya başına ayrı commit ve `en.po` karşılıkları.

## L1 — tamamlandı

- Statik `Loc` yardımcısı ve `en.po` başlığı eklendi. `Loc` sistem yerelini
  kullanmaz; varsayılanı `tr`dir.
- `Sfx` ayar dosyası dili saklar; menü Ayarlar ekranında `Dil / Language`
  seçicisi yer alır.
- Kaydedilen kampanya dili v9 alanıdır; v8 ve öncesi kayıtlar `tr`ye göçer.
- `content_data.gd`, İngilizce etkinse `game/data/en/` içindeki metin
  kaplamasını güvenli biçimde birleştirir. Kaplama yoksa Türkçe kaynak kalır.
- Türkçe test kilidi eklendi; `event_check` ve `content_check` `--lang=en`
  yolunu doğrular.
- Kapı: `I18N: OK`, `EVENTS: OK`, `CONTENT: OK`, `SAVE: OK`, `TEST: OK`,
  pencereli giriş testi, autoplay masaüstü/mobil ve tempo testi geçti.
- Tam koşu: 101/104/TAHTTA/Medya Rejimi/112. Ölçüt bot: 85% / 45% / 20%,
  L0 ile birebir aynı. Ayar ekranı görüntüsü: `dist/i18n_l1_menu/`.
- Altyapı commit'i: `ab56462`; kapı tamamlama commit'i: `005316b`.

## L2 — devam ediyor

- `modal.gd`: Kapat ve Vazgeç düğmeleri `tr()` ile kaynak anahtarına bağlandı;
  İngilizce karşılıkları `Close` ve `Cancel`. Commit: `db05126`.
- `ui_kit.gd`: İngilizce büyük harf dönüşümü Türkçe `i/ı` kuralını uygulamaz.
  Commit: `2948d4b`.
- `truth_chart.gd`: Hakikat grafiği başlığı, boş durum metni ve seri etiketleri
  çevrildi. Commit: `e17e796`.
- `menu.gd`: Ana menü, yeni oyun ve ayarlar etiketleri ile açıklamaları
  çevrildi. Uzun Nasıl Oynanır ve Hakkında metinleri sonraki L2 adımında
  tamamlanacak. Commit: `39044fa`.
