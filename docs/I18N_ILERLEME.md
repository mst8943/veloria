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

- S5 ile `actors.json` ve içerik kaplamalarının ilk grubu tamamlandı. İngilizce
  ekranlarda kalan Türkçe içerik, `events.json` başlık/gövde/seçenekleri ve
  bunlardan türeyen haber/karar kayıtlarıdır; S6–S9 olay partilerinde çevrilecek.

## SIRADAKİ ADIM

S9: L4 — `events.json` parti 4 (olay 151–195, son parti).

S9 olay kontrol noktası: 151–160 `9d8f816`, 161–170 `c48566d` ile kaplandı
ve her partiden sonra `i18n_check` ile `event_check --lang=en` geçti.

S9 ön kontrolleri: cinsiyet tutarlılığı ve sezgisel uyarı `c154aa5`, İngilizce
tırnak normalleştirmesi ve stil uyarısı `7aeb00f` ile tamamlandı; son olay
partisi sürüyor.

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

## S3b — tamamlandı

- `sim.gd`: oyun sonu nedenleri/özetleri, ünvanlar ve dış ilişki raporlarının
  gösterim çevirileri eklendi. Ham `record.title`, `record.cause`, söz sicili,
  başarımlar ve kronik anahtarları Türkçe kaldı; ekran için ayrı gösterim
  alanları kullanıldı. `narrative.gd` tarihçi metinleri, `press.gd` gazete/TV
  statik manşet ve sütunları, `advice.gd` meclis kalıpları ve kişi gerekçeleri,
  `content_data.gd`
  doğrulama hataları yerelleştirildi. Dosya başına commitler: `938c66c`,
  `f8ae226`, `9d8d5c9`, `60a5972`, `3437659`, `599f1e1`, `4b3c178`, `f33d39f`,
  `f726948`, `634fa36`, `70c1aa5`, `e1e2f76`, `f0a7b94`, `38ac822`, `8ed3501`.
- Kapı testleri: `TEST: OK`; `EVENTS: OK (195 olay, 0 uyarı)`; `SAVE: OK`;
  `CONTENT: OK (5 dosya, 8 bozuk örnek)`; `I18N: OK`; `UI INPUT: OK`;
  pacing en uzun olaysız seri medyan/en kötü `2/2` hafta (en kötü olay hızı
  `0.81`). `unit_tests.gd`: `398 passed, 1 failed` — mevcut, Beckett'e ait
  `audit finds the offscreen control`.
- `--autoplay --full` iki dilde aynı satır verdi: `FULLRUN tohum=101 hafta=104
  sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
  `advice_weighted`, 80 kampanya × üç zorluk, TR/EN birebir eşit: kazanma
  `68/80, 36/80, 16/80`; ortalama hafta `97.0, 81.3, 62.3`; son kapasite
  `54.0, 53.2, 53.3`; Arden girişimi `25, 52, 70`; Arden hazırlığı `51, 61, 52`;
  Arden darbe zaferi `11, 34, 57`; diğer rejim ve yayın ölçütleri de eşit.
- Görsel kapısı: `dist/i18n_s3b2_{tr,en}_{desktop,mobile}`; her dilde masaüstü
  17, mobil 19 PNG. Gazete, TV, ana oyun ve oyun sonu görüntüleri açılarak
  incelendi. Türkçe örnekler tamamen Türkçe; incelenen sayfalarda kırpılma/
  taşma görülmedi. İngilizce basın şablonları ve tarihçi/oyun sonu özeti İngilizce.
- S3b'de kalan kişi unvanları ile rapor/alamet gövdeleri S5'te çevrildi.
  Güncel İngilizce ekranlarda kalan Türkçe içerik `events.json` başlıkları,
  gövdeleri, seçenekleri ve bunlardan türeyen haber/karar geçmişi metinleridir;
  olay çevirileri S6–S9 kapsamındadır.

## S5 — tamamlandı

- `game/data/en/actors.json` 14 kişinin ad/unvan/kırmızı çizgi/zayıf nokta
  gösterimlerini aldı. İngilizce `content_labels`, `content_council`,
  `content_reports`, `content_achievements` ve `content_history` kaplamaları
  ana metin yapısı ve dizi uzunluklarıyla eşleşir. İç ödül/rejim kimlikleri,
  uzman aktör listesi ve mantık değerleri Türkçe kaynakta bırakıldı.
- `i18n_check.gd` kaplama yapısını, mantık alanı dışlamalarını, dil seçimi ve
  eksik çeviride Türkçe geri dönüşü denetler. `content_check.gd` İngilizce hata
  metinleriyle de çalışır. S5'in ilk denemesinde bulunan rapor iyeliği karışımı,
  `Loc.poss()` ile giderildi; Türkçe cümle değişmedi.
- Kalite örnekleri: `docs/i18n/kalite_ornekleri.md`, sabit sıradaki 376 metinden
  her onuncu örnek (37 satır).
- Testler: `TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)`, `SAVE: OK`,
  `CONTENT: OK (5 dosya, 8 bozuk örnek)` Türkçe ve `--lang=en`, `I18N: OK`,
  `UI INPUT: OK`; pacing en düşük `0.81`, en uzun olaysız seri `2/2`. Bilinen
  bağımsız Beckett unit testi: `398 passed, 1 failed` (`audit finds the offscreen control`).
- `--autoplay --full` TR/EN birebir: `FULLRUN tohum=101 hafta=104 sonuç=TAHTTA
  ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`. İngilizce
  `advice_weighted` 80 kampanya ölçümü tüm zorluklarda tabanla aynı: kazanma
  `68/80, 36/80, 16/80`; ortalama hafta `97.0, 81.3, 62.3`; kapasite
  `54.0, 53.2, 53.3`; Arden girişimi `25, 52, 70`, hazırlığı `51, 61, 52`,
  darbe zaferi `11, 34, 57`.
- Son görseller `dist/i18n_s5_{tr,en}_{desktop,mobile}`: 17/19 PNG her dil/cihaz
  için. Masa, rapor, basın ve oyun sonu ekranları açılarak karşılaştırıldı;
  incelenen ekranlarda taşma yok. İngilizce ekranda kalan metinler olay ve olay
  kayıtlarıdır; `kurush` para adı tarihsel birim olarak translitere edilmiştir.
- S5 dosya commitleri: `09b5192`, `fb0c46d`, `68f362c`, `267cca4`, `d0ef3b0`,
  `89e39b4`, `b36fe87`, `53665c4`, `b8de8d3`, `c1c8ef5`, `4d047af`, `9f21772`,
  `52ec99f`, `4bd1be1`.

## S6 — tamamlandı

- `actors.json` elçi unvanları, `Ambassador of Drakon`, `Ambassador of Asteria`
  ve `Economic Envoy of Seravia` biçimine getirildi. Commit: `1873c1f`.
- `events.json` ilk 50 sıra girdisi beş adet 10'luk parti hâlinde çevrildi.
  Kaplamada yalnızca gösterim metni var; ID sırası, seçenek sayıları, alan
  yapısı ve yer tutucular kaynağa göre doğrulandı. Her parti sonrası
  `i18n_check` ve İngilizce `event_check` geçti. Commitler: `e3bf061`,
  `65feb7c`, `e5c3c28`, `63f819a`, `eeb291b`.
- Kalite örneklerine her beş olaydan bir başlık (5–50) eklendi.
- Kapı testleri: `TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)`, `SAVE: OK`,
  `CONTENT: OK` Türkçe ve `--lang=en`, `I18N: OK`, `UI INPUT: OK`; pacing en
  düşük `0.81`, en uzun olaysız seri `2/2` hafta. Genel `unit_tests.gd` sonucu
  `398 passed, 1 failed` — önceden bilinen, bu kapsamla ilgisiz Beckett
  `audit finds the offscreen control` testi.
- `--autoplay --full` iki dilde aynı: `FULLRUN tohum=101 hafta=104
  sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
  İngilizce `advice_weighted`, 80 kampanyada üç zorluk için tabanla aynı
  `68/80`, `36/80`, `16/80` sonuçlarını verdi.
- Görseller: `dist/i18n_s6_{tr,en}_{desktop,mobile}`; masaüstünde 17, mobilde
  19 PNG/dil. Karar kartı başlık/gövde/seçenekleri iki dilde gözle incelendi;
  kart metninde taşma yok. Mobil kart dikey kaydırma gerektiriyor. İngilizce
  haber şeridinde hâlâ olay 51+ kaynaklı Türkçe kayıtlar görünüyor; örnekler:
  “Vale Başbakan hakkında yeni bir dosya hazırladı; Veyra bunu duydu.” ve
  “Sarne'nin kanalları bir hafta boyunca Veyra'yı hedef aldı. Hedefin neden
  Veyra olduğunu kimse sormuyor.” Bunlar sonraki olay partilerinde kapanacak.

## S7 — tamamlandı

- `sozluk_en.md` olay başlıkları ve seçenek etiketleri için sentence-case
  kuralını aldı. `events.json` içindeki ilk 50 başlık bu biçime getirildi.
  Commit: `98ea0b7`.
- Olaylar 51–100, beş adet 10'luk parti olarak kaplamaya eklendi. Haber odaklı
  100. girdinin kaynakta seçenekleri olmadığından `choices: []` korundu. Her
  partiden sonra `i18n_check` ve İngilizce `event_check` geçti. Commitler:
  `ea12ffe`, `2b7df7e`, `5494b43`, `7df8a6f`, `7437ac5`.
- Mobil şeritte bildirim kutusu Türkçe ve İngilizce ekranlarda metni örtüyordu;
  yalnızca İngilizce uzunluğundan kaynaklanmadığı karşılaştırmayla doğrulandı.
  Mobilde bildirim sütunu kadar boşluk ayrıldı ve şerit iki satırda kısaltıldı;
  iki dilde yeniden çekimde çakışma kalmadı. Commit: `b47ea2a`.
- Kalite örneklerine her beş olaydan bir başlık (55–100) eklendi.
- Testler: `TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)` TR/EN,
  `SAVE: OK`, `CONTENT: OK` TR/EN, `I18N: OK`, `UI INPUT: OK`; pacing en
  düşük `0.81`, en uzun olaysız seri `2/2` hafta. `unit_tests.gd`:
  `398 passed, 1 failed` — bilinen Beckett `audit finds the offscreen control`.
- `--autoplay --full` TR/EN birebir: `FULLRUN tohum=101 hafta=104
  sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
  İngilizce `advice_weighted` 80 kampanya tabanıyla aynı `68/80`, `36/80`,
  `16/80` sonuçlarını verdi.
- Görseller: `dist/i18n_s7_{tr,en}_{desktop,mobile}`; 17 masaüstü ve 19 mobil
  PNG/dil. Ana oyun/karar kartları açılarak incelendi; mobil haber şeridi
  bildirimle çakışmıyor. İngilizce şeritte sonraki partilerden kalan örnekler:
  “Vale Başbakan hakkında yeni bir dosya hazırladı; Veyra bunu duydu.”,
  “Sarne'nin kanalları bir hafta boyunca Veyra'yı hedef aldı. Hedefin neden
  Veyra olduğunu kimse sormuyor.”, “Voss taşrada kalabalık bir miting yaptı.”

## S8 — tamamlandı

- `events.json` olay 101–150 beş adet 10'luk parti olarak çevrildi. Kaplama
  yalnızca görünen metin alanlarını içerir; olay sırası, seçenek sayıları,
  yer tutucular ve Türkçe kaynak değişmedi. Her parti sonrası `i18n_check` ve
  İngilizce `event_check` geçti. Parti commitleri: `e12602e`, `df273ac`,
  `4b2a0d5`, `38f5cf4`, `5c3c12d`.
- Kalite örneklerine 105, 110, …, 150 başlıkları eklendi.
- Kapı testleri: `TEST: OK`, `EVENTS: OK (195 olay, 0 uyarı)` TR/EN,
  `SAVE: OK`, `CONTENT: OK` TR/EN, `I18N: OK`, `UI INPUT: OK`; tempo testi
  geçti. Autoplay masaüstü/mobil de tamamlandı. `unit_tests.gd`: 398 geçti,
  1 başarısız — bilinen, kapsam dışı Beckett `audit finds the offscreen control`.
- `--autoplay --full` iki dilde birebir: `FULLRUN tohum=101 hafta=104
  sonuç=TAHTTA ünvan=Medya Rejimi miras_kararı=true olay=112 son_ekran=true`.
  İngilizce `advice_weighted`, 80 kampanyada kolay/normal/zor `68/80`, `36/80`,
  `16/80` verdi; önceki taban ölçümüyle aynı.
- Görseller: `dist/i18n_s8_{tr,en}_{desktop,mobile}`; 17 masaüstü/19 mobil
  PNG/dil. Ana oyun ve karar kartındaki metin ile haber şeridi açılarak
  incelendi: Türkçe çekimler Türkçe, İngilizce çekimler İngilizce; taşma ya da
  mobil bildirim-şerit çakışması görülmedi. Sonraki S9 kapsamındaki 151–195
  olayları İngilizce kaplamada henüz yok.
