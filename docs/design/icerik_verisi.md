# İçerik tablolarının JSON'a ayrılması

Tarih: 2026-10-06. Başlangıç ölçümü: `dist/content_before_sim.log`, `content_before_full.log`, `content_before_probe.log`. Tohum 101: 104 hafta, Oligark Rejimi, 115 olay. Ölçüt bot: Kolay 67/80, Normal 36/80, Zor 13/80.

## Sınır

Oyunun sayısal kuralları, olay seçme sırası ve rastgelelik çağrıları aynı kalır. `PHRASES`, `SIGN_TEXTS`, başarımlar, Meclis söyleyişleri/uzman eşleşmesi, rejim adları ve benzeri sabit metin tabloları `game/data/*.json` içinde yer alır. JSON dizilerinin sırası özgün dizilerle birebir aynıdır; sözlük anahtarlarının sırası değiştirilmez. `SIGN_TEXTS` aşama anahtarları JSON'da metindir; erişimde `str(stage)` kullanılır. Hiçbir veri yükleme yolu `rng` tüketmez.

Meclis görüşleri 300 satırı aşan bağımsız bir alt sistemdir. Davranış değiştirmeyen ilk adımda `game/core/advice.gd` içine alındı; `Sim` dış API'si aynı adlarla yönlendirir. Tarihçi, rapor ve alamet anlatımı `game/core/narrative.gd` içindedir. İçerik tabloları beş JSON'a taşındı; `sim.gd` 2607 satırdan 2205 satıra indi. Kuralların sayısal sabitleri betikte kaldı.

## Yükleme ve hata

Her dosya başta açılır ve şema doğrulanır; hata durumunda kampanya başlatılmaz, Türkçe dosya yolu ve sorun `Sim.content_error` ile menüde açıkça gösterilir. Sessiz boş diziye düşülmez. `tests/content_check.gd` aynı şemayı içerik üretimi sırasında denetler: eksik anahtar, boş metin, bilinmeyen aktör, eksik dosya ve bozuk JSON. Hata yolu beş bozuk örnekle sınanır.

## Kabul ölçümü

Taşıma sonrası `sim_test` (54 satır), `--autoplay --full` (3 satır) ve `probe_template` (8 satır) çıktıları başlangıçla birebir aynı çıktı. Ölçüt bot yine 67/80, 36/80, 13/80 kazandı. Masaüstü/mobil otomatik oynatma, olay/kayıt/içerik doğrulayıcıları ve pencereli görüntü kontrolü yapıldı. İçerik JSON'ları `game/data/*.json` filtresine zaten girer; `export_presets.cfg` değiştirilmedi.
