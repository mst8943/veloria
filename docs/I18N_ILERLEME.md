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

S3b: `sim.gd` kalan son/özet metinleri ve `narrative.gd`, `press.gd`, `advice.gd`.

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
- S1: `menu.gd` yardım metni ve sürüm kısayolları, `main.gd` statik ana arayüz
  metinleri ve `agenda_view.gd` gündem/yol gösterici metinleri `tr()` ile
  bağlandı; `en.po` karşılıkları eklendi. Önceki L2 commitleri `ui_kit.gd`
  (`2948d4b`) ve `truth_chart.gd` (`e17e796`) için zaten tamamlanmıştı;
  `autoplay.gd` oyuncuya gösterilen sabit metin içermedi. Commitler:
  `621eff8`, `e1b4848`, `f9a1123`, `5061966`, `b3b4539`.
- S2 öncesi kalan künye: `menu.gd` Hakkında metni `tr()` ile kaynak anahtara
  bağlandı; İngilizce lisans/katkı karşılığı `en.po`'ya eklendi.
- `person_panel.gd`: kişi rolleri, eylem kategorileri, ACTION_META önizlemesi,
  araç ipuçları ve durum metinleri çevrildi; `en.po` karşılıkları eklendi.
- `desk_view.gd`: masa etiketleri, hafta/karar düğmesi, rozetler ve kısa durum
  özetleri `tr()` ile bağlandı; `en.po` karşılıkları eklendi.
- `city_view.gd`: kurum adları/açıklamaları, çekmece başlıkları ve eylem
  düğmeleri `tr()` ile bağlandı; `en.po` karşılıkları eklendi.
- `media_view.gd`: gazete künyeleri, medya sekmeleri, yayın durumu ve TV
  etiketleri `tr()` ile bağlandı; haber içeriği L4 kaplamalarına bırakıldı.
- `end_screen.gd`: sonuç sekmeleri, hakikat dosyası, tarihçi ve devlet özeti
  etiketleri `tr()` ile bağlandı; dinamik anlatı metinleri çeviri anahtarından
  geçirildi.
- S2b: `main.gd` statik sekme/alt çubuk/son eylem metinleri ve görünen haber
  etiketleri kaynak metin anahtarları korunarak çevrildi; `content_labels.json`
  İngilizce kişi-kademe kaplaması eklendi. `en.po` tamamlandı.
- S3a eylem sonuçları: `sim.gd` eylem sonuçları ve vaat karar kartı cümleleri
  tam cümle `tr()` anahtarlarına bağlandı; Türkçe kaynaklar değişmeden kaldı.
  Commit: `55d6c2d`.
- S3a haber/uyarıları: Türkçe `weekly_news` anahtarları korunarak gösterim ve
  sinyal İngilizceleştirildi; hafta özeti, masa alt başlığı ve TV şeridi aynı
  görünür metin yardımcısını kullanıyor. `en.po` tam cümle/etiketleri aldı.
  Commitler: `4d8f369`, `4c6ce42`, `cb939f9`, `2bce4ba`, `46a09b2`.
- S3a krizleri: darbe, ayaklanma ve yetki krizi kartları, sonuçları ve uyarı
  cümleleri tam cümle `tr()` anahtarlarına bağlandı; Türkçe sonuç akışı korundu.
  `en.po` karşılıkları eklendi. Commitler: `2121cbc`, `ab40560`.
- S2b görsel taraması sırasında kalan başlangıç bildirimi de `tr()`'a bağlandı;
  kişi kademe kaplamasındaki boş yer tutucu `unknown` ile dolduruldu.
  Commitler: `8257519`, `6cf58f1`, `2dcbbdb`.
- Menü künyesi sabit kaynak metin olarak kalır; Godot sabit ifadede `tr()`
  değerlendirmediğinden çeviri modal açılırken uygulanır.
- `ui_shots.gd`, autoload ayarları yüklendikten sonra `--lang=en`/varsayılan
  dili uygular; önceki sırada ayar dosyasındaki Türkçe tercihi test bayrağını
  eziyordu. Gazete sayfa bilgisinin İngilizce biçimlendirme hatası giderildi;
  eylem kategori adları kısaltıldı.
- Görsel kanıtlar: masaüstü ve mobil, TR ve EN; standart ekranlar 17/19 PNG,
  durum ekranları 14/16 PNG. Çekimler `dist/i18n_s2_*` altında. Eylem
  kategorileri, masa, şehir çekmecesi, medya ve oyun sonu örnekleri açılarak
  incelendi; hedef L2 panellerinde taşma görülmedi. Buna rağmen tüm oyun
  ekranlarının dil saflığı kapısı geçmedi.
- S2b + S3a görsel kapısı: yeni çekimler `dist/i18n_s3b_{tr,en}_{desktop,mobile}`
  altında (17/19 PNG); kriz örnekleri ayrıca `dist/i18n_s3b_crisis_{tr,en}_{desktop,mobile}`
  altında (4/6 PNG). Türkçe masaüstü/mobil örnekleri tamamen Türkçe. İngilizce
  arayüz etiketleri ve kriz kartı İngilizce; incelenen ekranlarda yatay taşma yok.
- İngilizce modda kalan Türkçe içerik (L4/S3b kapsamı): olay kartı başlığı,
  gövdesi ve seçenekleri (`Gıda fiyatları protestoya dönüşüyor`, karar metinleri,
  meclis alıntıları); kişi unvanları ve rapor/hareket/alâmet cümlelerinin gövdesi;
  oyun sonu başlığı (`Devrilen Kral`), hakikat dosyası ve karar geçmişi; gazetenin
  ana/ikincil haber metinleri, `KRALLIĞIN SESİ · 1892'DEN BERİ` ve `kuruş`.
  Haber/kriz kategori etiketleri çevrilmiştir; ham Türkçe oyun içerikleri bu
  kapsamda çevrilmemiştir.
- Doğrulama: `TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)`, `SAVE: OK`,
  `CONTENT: OK (5 dosya, 8 bozuk örnek)`, `I18N: OK`, `UI INPUT: OK`;
  tempo en düşük `0.81` (eşiği `0.8`). `--full`: `FULLRUN tohum=101 hafta=104
  sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
  İngilizce yerel ayarla 80 kampanya (`advice_weighted`, tüm zorluklar) L1 tabanıyla
  birebir aynı: kazanma `68/80, 36/80, 16/80`; ortalama hafta `97.0, 81.3, 62.3`;
  kapasite `54.0, 53.2, 53.3`; diğer ölçütler ve rejim sayımları da aynı.
  `unit_tests.gd`: 398 geçti; mevcut `audit finds the offscreen control` testi
  1 başarısız (çalışma zamanı değişikliğiyle ilgili değil).
