# Faz 7 ilerleme

## DALGA R1 — Ekonomi ve bütçe

R1'in a–e parçaları tamamlandı. Başlangıç economy metrikleri, eski kayıt göçü ve Maliye raporu; çeyreklik dört bütçe yaklaşımı ve gecikmeli sektör etkileri; azalan getirili Devlet politikaları; borçtan dış baskıya geçiş; Günlük/Divan satırları ve üç ekonomi başarımı eklendi. Bütçe kararları ve yeni metinler TR/EN; kriz haber başlığı için ayrıca EN sızıntı regresyon testi var.

| Parça | Commit |
|---|---|
| R1a — göstergeler ve Maliye raporu | `7b23a2a` |
| R1b — çeyreklik bütçe | `64f5d29` |
| R1c — hazine politikaları | `e2c8b51` |
| R1d — borç ve dış baskı | `df8a356` |
| R1e — Günlük/Divan, başarımlar ve kalibrasyon | `be22c77` |
| EN kriz başlığı sızıntı düzeltmesi | `70de806` |

### Kapılar

- `--full --seed=101`: TR ve EN'de 104 hafta / TAHTTA / Medya Rejimi / 112 olay.
- 80 oyun/zorluk ölçüt botu: Kolay 61/80, Normal 31/80, Zor 14/80; tabanın ±8 puanı içinde. Uç botların hiçbiri kendi ölçüt tavanını (%70) aşmadı. Probe tablosu ve ayarlar tasarım belgesinin sonundaki **R1 Ayar** bölümünde.
- `tests/economy_test.gd`, `sim_test.gd`, `pacing_test.gd` (en düşük dilim 0,81), `external_crisis_test.gd`, `event_check.gd`, `save_test.gd`, `content_check.gd`, `i18n_check.gd`, `en_leak_test.gd`, `lang_switch_test.gd`, `touch_scroll_test.gd`, `tour_test.gd`, `cutscene_check.gd`, `audio_check.gd`, `ui_logic_test.gd`, `ui_input_test.gd` (masaüstü/mobil), `a11y_test.gd` ve `unit_tests.gd` geçti.
- `tools/i18n_missing.py`: 0 eksik `tr()` kaynağı. `tools/i18n_leak_scan.py` EN UI/oyun dökümünde 3.497 metin taradı, 0 şüpheli.
- EN/TR masaüstü ve mobil ekranları `screenshots/faz7_r1/` altında üretildi ve açılarak kontrol edildi: bütçe kartındaki seçenekler, Maliye rapor metni ve Devlet eylem düğmeleri okunaklı; masaüstü Divan'da ekonomi satırı görünüyor.

### Bilinen test notu

`tests/daily_card_test.gd` headless çalışmada kart kaydetme adımında uzun süre çıktı üretmeden bekledi; bu R1 kapısı olmadığı için yalnızca başlatılan test süreci durduruldu. Geçen Godot testlerinin kapanışında ObjectDB/resource cleanup uyarıları görülebiliyor.

R2–R5 bu çalışmada başlatılmadı. PUSH yapılmadı.
