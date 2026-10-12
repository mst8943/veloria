# Ürün gözlemleri

## 2026-10-12 — R4a

### Düzeltilen küçük sorunlar

- **Düşük — Divan erişimi ve mobil taşma.** Kişiler ekranının Devlet grubunda mobil kullanıcılar için ayrı Divan girişi yoktu. Mobil Divan düğmesi/çekmecesi eklendi; valiler dâhil kartlar kaydırılabilir Devlet grubunda gösteriliyor. Eski “Diğer kişiler Divan'da” satırı mobil alt çerçeveye taşıyordu; mobil düzen ağacından kaldırıldı. EN/TR mobil kişi ekranı ve Divan açıldığında kontrol edildi.
- **Düşük — Anket kartı.** Görselsiz kamuoyu kartında başlık üst çerçeveye değiyordu. Kart iç üst boşluğu artırıldı; EN masaüstü ve TR mobil kart görüntüleri kontrol edildi.
- **Düşük — Hanedan defteri.** Mobil görünümde uzun RichText satırı kesiliyor ve iç içe kaydırma alanı hareketi yutuyordu. Metin sarımı etkinleştirildi ve kaydırma parent ScrollContainer'a bırakıldı; EN mobil defter kontrol edildi.
- **Düşük — Suikast krizi kartı.** Kortej planı kartında konu dışı/eksik görsel vardı. Var olan suikast görseline bağlandı; TR masaüstü kart kontrol edildi.

### Ertelenen

- **Orta — Vali portreleri.** Dört vali kartı şu an harf baş harfleriyle görünüyor; isim ve “Vali/Governor” rolü okunuyor, işlevsel taşma yok. Her bölge için ayrı portre üretip sanat varlıklarına eklemek görsel kimliği ve kartlar arası ayrımı güçlendirir. Portre üretimi ayrı sanat çalışması olarak bırakıldı.

### Ekran gözlemi

TR ve EN masaüstü/mobil Günlük bölge satırları ile Divan rapor ve vali kartları açıldı. Raporlarda sayı görünmüyor; dört bölge adı ve nitel huzursuzluk/pazar/bağlılık terimleri sarılarak okunuyor. Masaüstünde Devlet grubundaki vali kartları, mobilde kaydırılabilir çekmece kontrol edildi. EN/TR farkı ve kart taşması görülmedi.

## 2026-10-12 — R4a (Claude doğrulama gözlemleri)

- **Orta — Bölge satırı tekdüze.** Dört bölgenin hepsi aynı nitel kalıpla ("huzurlu, pazar durgun, bağlılık tereddütlü") yazılıyor; oyuncuya ayırt edici bilgi vermiyor. R4b'de bölgeler farklılaşınca satır yalnızca *öne çıkanı* (en huzursuz / en sadık bölge) vurgulamalı, geri kalanı "diğerleri sakin" diye özetlemeli.
- **Orta — Vali kartları düz renkli.** Mor/yeşil/kahve zemin ve baş harf, portre diliyle (altın-karanlık) çelişiyor; mor "D" kartı en çok göze çarpan şey oluyor. Ayrı vali portreleri üretilene kadar zemin renkleri portre paletine yaklaştırılmalı (koyu, desatüre).
- **Düşük — Divan masaüstünde uzadı.** 4 vali "Devlet" grubunu iki satıra çıkardı; 720p'de "Dış ilişkiler" grubu kaydırmadan görünmüyor. Valiler daha küçük kartla ya da tek satır şerit olarak gösterilebilir.
- **Düşük — Bölge satırı Günlükte çok uzun** (4 bölge x 3 terim). R4b'de özetlenmeli.
- **Süreç — ui_input_test.** R4a raporu "ui_input_test geçti" dedi ama test hem masaüstünde hem mobilde başarısızdı (Divan'da kart ekran dışı, mobilde kart sayısı 14 beklentisi). Claude düzeltti. Kural: rapora yazılan her test için çıktının son satırı raporda aynen gösterilsin.
- **Denge notu.** R3c sonrası ölçüt 62/31/17 (Zor taban 13'e göre +4, sınırda). R4a bunu değiştirmedi. R4b için taban artık 62/31/17; Zor'un daha da kolaylaşmasına izin verme.

## 2026-10-12 — R4b

### Düzeltilen

- **Orta — Tekdüze bölge satırı.** Günlük ve Divan satırı artık en huzursuz bölgeyi nitel kelimelerle vurguluyor, kalan bölgeleri özetliyor; tüm bölgeleri aynı biçimde sıralamıyor ve sayı vermiyor.
- **Düşük — Vali kartı rengi ve Divan yüksekliği.** Yer tutucu kart zeminleri koyu/desatüre oldu; vali kartları masaüstünde küçültülerek Devlet grubunun yüksekliği azaltıldı.
- **Düşük — Günlük satırı uzunluğu.** Dört bölgenin ayrı ayrı tekrarlanan değerleri tek öne çıkan satıra indirildi.
- **Düşük — Görsel test adları.** Vali azli ve atama görüntüleri artık ayrı ad alıyor; denetim bir görselin diğerinin üstüne yazılmasını önlüyor.

### Ertelenen

- **Orta — Vali portreleri.** R4a'da mevcut olan genel vali görselleri korunuyor; atama adayları birbirinden daha iyi ayırt edilsin diye her valiye ayrı portre/kimlik tasarımı gerekebilir. Bu sanat çalışması R4b kapsamına alınmadı.
- **Düşük — Bölge yatırımının maliyeti.** Yatırım tek seferlik hazine ve mesai tüketiyor, R1 tahsis eşiğine bağlı; eylem sıklığı için 12 haftalık bekleme var. Yeni bir kampanya başına birden fazla bölge yatırımını teşvik etme ihtiyacı ölçümde görülmedi; gerçek oyuncu telemetrisi yok.

### Ekran gözlemi

TR/EN masaüstü ve yatay mobil kartları açıldı: bölge seçimi, yatırım/garnizon/medya kararı, grev krizi, vali azli ve ataması. Kartların sınırları, metin sarımı, düğme görünürlüğü, mobil yatay yerleşim ve EN/TR çeviri uzunlukları kontrol edildi; taşma görülmedi. Gerçek oyuncu oturumlarında vali/yerel medya kararlarının anlaşılırlığı telemetriyle doğrulanmadı.

## 2026-10-12 — R4c

### Düzeltilen

- **Orta — Harita işaretçisi/kurum çakışması (yatay mobil, 1067×600).** İlk yerleşimde bölge hedefleri Maliye/Asteria ve Genelkurmay etiketlerine değiyordu. İşaretçi koordinatları düzeltildi; `region_map_test` masaüstü ve mobilde hedef dikdörtgenlerinin kurumlarla kesişmediğini ve tıklamaların çalıştığını denetliyor.
- **Düşük — Panel arkasında görünen işaretçiler.** Sağ çekmece açılınca bazı işaretçiler kenardan görünüyordu. Çekmece açıkken tüm bölge işaretçileri gizleniyor, kapanınca katman durumuna göre geri geliyor.
- **Düşük — Vali satırındaki fazla boşluk ve mobil eylem akışı.** Vali adı için RichTextLabel'ın dikey boşluğu kaldırıldı; ana bölge karar düğmesi açıklama listesinin üstüne alındı ve ilk mobil görünümde kalıyor.
- **Düşük — Günlük/harita odak tutarsızlığı.** Haritadaki yıldız artık Günlük/Divan'ın kullandığı aynı öne çıkan bölgeyi işaretliyor; nitel durum kelimeleri ortak Sim yardımcısından geliyor.

### Ertelenen

- **Düşük — Harita ekranına özel Beckett `ui_snapshot`.** Lite oturumu harita ekranını açamadı; çalışan masa görünümündeki tarama harita katmanına ait değildi. `region_map_test` geometri ve tıklama kontrollerini iki çözünürlükte yaptı; Beckett ile özel harita snapshot'ı alınmadı.
- **Düşük — Uzun bölge panelinde alt eylem listesi.** Mobil panelde açıklama ve eylem listesi kaydırılıyor; kapatma düğmesinin uzun içerikte alt kısma düşmesi olası. Çekmece üstündeki kapatma kontrolü mevcut. Gerçek cihazda uzun liste ergonomisi ayrıca incelenebilir.

## 2026-10-12 — R4b/R4c (Claude doğrulama gözlemleri)

- **Orta — Kompakt vali kartlarında yüz kırpılıyor.** Divan'da Solen/Vey/Aven/Dask kartları 78x70; portre ortadan kırpıldığı için burun-ağız hizası isim yazısının arkasında kalıyor. Kırpma üstten hizalanmalı (yüz/göz görünür) ya da kart yüksekliği biraz artmalı.
- **Orta — "Başkent" adı iki anlamda.** Harita başlığı "BAŞKENT" (şehir) ve bölge işaretçisi "Başkent" (bölge) aynı ekranda; EN'de "CAPITAL" ve "Capital". Bölge adı "Başkent Bölgesi / Capital Region" ya da başlık "Şehir haritası" olmalı.
- **Düşük — Bölge paneli saydam.** Panel arkasında bina etiketleri (İSTİHBARAT, SERAVIA) silik görünüyor; panel zemini daha opak olmalı.
- **Düşük — Bölge eylemleri liste gibi.** "Altyapı yatırımı / Garnizon takviyesi..." düz metin görünüyor, tıklanabilir hissettirmiyor; yalnızca "Bölge kararlarını aç" düğmesi var. Ya düğme yapılmalı ya da açıklayıcı not olarak etiketlenmeli.
- **Düşük — Harita bölge işaretçileri küçük** (masaüstünde ~88x52, köşelerde); simge anlamı panelde "Simgeler:" satırıyla açıklanıyor, harita üstünde kısa bir açıklama düğmesi (?) faydalı olur.
- **Süreç — dürüstlük.** R4c raporunda "A11Y: OK" yazıyordu; test hata veriyordu (a11y_test mobil bayrağı yüzünden). Claude düzeltti. Rapor dürüstlüğü kuralı hâlâ geçerli: yazdığın her test çıktısını çalıştırıp yapıştır.
- **Denge.** R4b+R4c sonrası ölçüt 60/29/17. Zor taban 13'ün +4 üstünde (R3c'den beri); R4b'de Zor'u 14-15'e çekme hedefi yapılmadı. R5 bunu oynanış değişikliğiyle birlikte ele almalı (Zor ≤ 16).

## 2026-10-12 — R4b/R4c cila kapanışı

### Düzeltilen

- **Orta — Vali kartında yüz kırpılması:** kart 78×82'ye büyütüldü, portre `KEEP_ASPECT_CENTERED` ile yerleştirildi (`7a1c89d`).
- **Orta — “Başkent” ad çakışması:** bölge adı Başkent Bölgesi / Capital Region yapıldı (`ddedf75`).
- **Düşük — Bölge paneli saydamlığı:** çekmece zemini opaklaştırıldı (`6e6468d`).
- **Düşük — Bölge eylemlerinin tıklanabilir görünmesi:** eylem listesinin yalnızca açıklama olduğu açıkça yazıldı (`68b80a5`).
- **Düşük — Harita işaretçisi açıklaması:** renk dışı simgeler için 44 px erişilebilir açıklama düğmesi eklendi (`4134d48`).

## 2026-10-12 — R5a

### Düzeltilen küçük sorunlar

- Komutanların portresiz yer tutucu kartları vali kartlarıyla aynı koyu, düşük doygunluklu paleti kullanıyor; masaüstü ve mobil Divan'da ad/rol görünür.
- Birlik raporu Günlük ve Divan'da aynı nitel satırla gösteriliyor; bir öne çıkan birliği belirtip diğerlerini özetliyor.

### Ertelenen

- **Orta — Komutan portreleri gerekiyor (4 isim + prompt).** İsimler: Marcus Arden (Genelkurmay), Ilyan Rell (Başkent garnizonu), Sera Kest (Sınır kolordusu), Marek Nadir (Jandarma ve güvenlik). Önerilen sanat promptu: “Create four distinct, fictional senior military commander portraits for a restrained political strategy game. Chest-up, direct but understated expression, realistic painterly editorial illustration, muted bronze and charcoal palette, soft architectural background, consistent framing and lighting, readable at small card size; no insignia text, no flags, no weapons, no real public figures. Marcus Arden is a silver-haired general in his late fifties; Ilyan Rell is a disciplined capital officer in his forties; Sera Kest is a composed border corps commander in her forties; Marek Nadir is a watchful gendarmerie commander in his fifties.” Portre üretimi sonraki sanat çalışmasına bırakıldı; `art/` değiştirilmedi.
- **Denge kapısı:** R5a ölçümü 60/29/17 ile tabanı aynen korudu; R5 kapısındaki Zor ≤16 hedefi bir galibiyetle kaçtı. R5a'da ordu eylemi bulunmadığından R5b uç botları henüz ölçülemez. Dengeyi koruma şartı nedeniyle yapay zorluk ayarı yapılmadı.

## 2026-10-12 — R5a (Claude doğrulama gözlemleri)

- **Yüksek — Mobil dokunma hissiyatı kötü (kullanıcı geri bildirimi, telefonda).** Parmak ekrana değdiği anda masa nesneleri (telefon, kitap), harita levhaları ve kartlar tetikleniyor; parmak basılı gezdirilirken geçilen her öğe hover/sesi/seçimi çalıştırıyor; kullanıcı kaydırmak isterken seçim oluyor. Kod nedenleri: masa nesneleri ve harita levhaları `InputEventMouseButton.pressed` anında harekete geçiyor (desk_view.gd ~243, city_view.gd ~261, main.gd haber şeridi ~394), `mouse_entered/exited` hover animasyonu ve sesi dokunmatik cihazda da çalışıyor (desk_view ~224, city_view ~250, main.gd ~811, ui_kit ~492). touch_scroll.gd yalnızca ScrollContainer içindeki düğmeleri ele alıyor.
- **Orta — Hükümdarlık Arşivi İngilizcede Türkçe gösteriyor.** `Sim` kayda `cause` alanını Türkçe yazıyor ve arşiv ekranı bunu çevirmeden gösteriyor (satır sonundaki "When the coup reached your door…" cümlesi İngilizce, başı Türkçe karışık). Daha önce arşiv boş olduğu için en_leak_test 0 diyordu; arşivde kayıt olunca test "1 unique leaks" veriyor. Çözüm: kayıt `cause`'ı dilden bağımsız saklasın (anahtar + argümanlar ya da gösterimde çevrilebilir kalıp) ve arşiv gösterimde çevirsin.
- **Orta — Testler oyuncunun profilini kirletiyor.** `%APPDATA%\Godotpp_userdata\Veloriaeloria_chronicle.txt`, `veloria_achievements.txt`, `army_test.sav`, `test_save.txt` gibi dosyalara test koşuları yazıyor (5 sahte saltanat kaydı ve başarım tarihleri bugüne işlenmiş). Testler `user://` yerine geçici profil/yol kullanmalı ya da dosyaları yedekleyip geri yüklemeli; `record_chronicle=false` ve `autosave=false` varsayılan olmalı. daily_card_test takılması da bununla ilgili olabilir.
- **Orta — Komutan portreleri gerekiyor** (Codex notu; Claude promptları hazırlayacak).
- **Denge.** R5a sonrası ölçüt 60/29/17 (Claude bağımsız doğruladı). Zor ≤ 16 hedefi hâlâ tutmuyor.
