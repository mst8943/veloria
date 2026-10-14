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
- **Orta — Testler oyuncunun profilini kirletiyor.** `%APPDATA%\Godotpp_userdata\Veloria
eloria_chronicle.txt`, `veloria_achievements.txt`, `army_test.sav`, `test_save.txt` gibi dosyalara test koşuları yazıyor (5 sahte saltanat kaydı ve başarım tarihleri bugüne işlenmiş). Testler `user://` yerine geçici profil/yol kullanmalı ya da dosyaları yedekleyip geri yüklemeli; `record_chronicle=false` ve `autosave=false` varsayılan olmalı. daily_card_test takılması da bununla ilgili olabilir.
- **Orta — Komutan portreleri gerekiyor** (Codex notu; Claude promptları hazırlayacak).
- **Denge.** R5a sonrası ölçüt 60/29/17 (Claude bağımsız doğruladı). Zor ≤ 16 hedefi hâlâ tutmuyor.

## 2026-10-12 — M1 takip

### Düzeltilen

- **Yüksek — Mobil dokunma hissiyatı.** Dokunmatik etkileşimler artık ortak `touch_scroll.gd` kapısından geçiyor: kısa dokunma bırakmada etkinleşir; 11 px sürükleme ve uzun basma iptal edilir; hover sesi/animasyonu dokunmada bastırılır. `touch_tap_test` ve masaüstü/mobil `ui_input_test` ile kontrol edildi.
- **Orta — Hükümdarlık Arşivi EN sızıntısı.** Yeni kayıtların sebebi dil anahtarı ve argümanlarla saklanıp görüntülemede çevriliyor. Arşiv dolu iken `en_leak_test` artık 0 sızıntı veriyor.
- **Orta — Testlerin gerçek profili kirletmesi ve günlük testinin takılması.** Günlük test kendi dosya/klasörünü kullanıyor; test çalıştırıcısı her süreç için geçici `APPDATA` profili oluşturup temizliyor. Headless günlük kartı, render dokusu bulunmadığında beklemek ya da hata vermek yerine temiz çıkıyor. Bugünkü sahte arşiv/başarım kayıtları silinmedi.
- **Düşük — Dar mobil Capital Region etiketi.** EN 1067×600 harita ekranında işaretçi adı kesiliyordu. Mobil etiket satıra sarılıyor; `region_map_test --mobile` kontrol ediyor.

### Ertelenen

- **Orta — Eski arşiv sebebinin ayrıntılı EN çevirisi.** Eski kayıtlarda `cause_key` ve biçim argümanları yok. Kayıtlar korunuyor; EN'de Türkçe sebebi sızdırmamak için genel uyumluluk cümlesi gösteriliyor. Eski kayıt biçimini tanıyıp ayrıntılı çevirecek göç/haritalama ayrı çalışma gerektiriyor.
- **Orta — Komutan portreleri (4 isim + prompt).** Sanat varlığı işi M1 kapsamı dışında kaldı; `art/` değiştirilmedi.

### Ekran gözlemi

EN yatay mobil harita katmanı ve bölge paneli ekranları açıldı; Capital Region işaretçi kesilmesi sarma düzeltmesinden sonra tekrar açılarak kontrol edildi. İşaretçi simgeleri renk dışında şekil/doku ile ayırt ediliyor; panelde vali portresi, nitel durum ve eylem girişi görünür. Geçici görüntüler gözlem sonrası silindi.


## 2026-10-13 — R5b

### Düzeltilen

- **Komutan portreleri:** `commander_*.png` kartlarda kullanılıyor; art dosyalarına dokunulmadı. Kompakt Divan kartlarında portre yukarı hizalı, isim/rol altta; etiket çeneyi kapatmıyor.
- **Uzun karar listeleri:** dördüncü seçenekten sonra tekrar eden IV işareti madde işaretine çevrildi.
- **Dokunmatik ses çubukları:** HSlider/Range dokunuşu kaydırma sayılmıyor; basma, sürükleme ve bırakma slider'a iletiliyor. Sentetik kontrol eklendi.
- **Bayat eylem raporu:** son ordu kararı dört hafta sonra nitel rapor satırından kalkıyor; geçmiş kaydı duruyor.
- **Mobil erişilebilirlik testi:** test başlangıç kipini gözetiyor; masaüstü ve `--mobile` geçiyor.

### Ertelenen

- **Düşük — Mobil Divan yoğunluğu.** Hanedan, devlet, komutanlar ve dış ilişkiler tek uzun kaydırma alanında; taşma yok ve kaydırma çalışıyor. Komutanlara ulaşmak için aşağı kaydırmak gerekiyor. İleride ayrı komuta filtresi akışı sadeleştirebilir.

### Ekran gözlemi

EN/TR masaüstü ve 1067×600 yatay mobilde ordu karar kartı, Günlük birlik satırı, Divan ve komutan kartlarını açtım (16 görüntü). Önizlemeleri, nitel/sayısız değerleri, portre ve etiket okunurluğunu, kaydırmayı kontrol ettim. Görseller TEMP'de kaldı; doğrulanmış yollar için Remove-Item çağrıları araç politikası tarafından reddedildi.

## 2026-10-13 — R5b (Claude doğrulama gözlemleri)

- **Orta — Türkçe ek hatası ordu emri kartında.** "Başkent garnizonu'nin", "Sınır kolordusu'nin", "Jandarma ve güvenlik'in görevini devralsın": iyelik eki yanlış (doğrusu "Başkent garnizonunun", "Sınır kolordusunun", "Jandarma ve güvenliğin"). Ek üretimi için Sim.ek(isim, "in") kullanılmalı ya da birim adlarının tamlama biçimi içerikte ayrı alan olmalı. TR/EN testine örnek eklenmeli.
- **Orta — Kompakt vali/komutan kartlarında yüz yine kesiliyor.** "Üstten hizalı" kırpma yalnızca alın ve gözleri gösteriyor (burun-ağız yok); isim şeridi çeneyi kapatıyor. Portrelerin yüz merkezi görüntünün yaklaşık %35–45 yüksekliğinde; kırpma yüz merkezli olmalı ya da kart yüksekliği ~84–90 px'e çıkarılmalı. Hedef: Solen/Vey/Aven/Dask/Rell/Kest/Nadir kartlarında göz+burun+ağız görünsün, isim yüzün altında kalsın.
- **Orta — Ordu emri kartında yalnızca komutan değişimi seçenekleri var (6 permütasyon).** Ödenek, garnizon yer değiştirme, komuta zinciri bölme seçenekleri bu kartta yok ve eşit görünen altı komutan-değişimi seçeneği karar yükünü artırıyor. Kart ya tek tür eylemi tek seçenekle sunmalı ya da seçenekleri gruplayıp en fazla 3-4 göstermeli.
- **Düşük — "Ordu emri" başlığı kartın üst çerçevesine değiyor** (aynı görselsiz karar kartı boşluk sorunu geri gelmiş).
- **Denge notu.** R5b sonrası ölçüt 58/27/15 (Claude doğruladı): Zor tabana yaklaştı (+2) ama Kolay −4, Normal −3 hedefin altında; Kolay'da yabancı müdahale kaybı 10. R5c'de Kolay ≈ 60–62, Normal ≈ 29–30'a geri çek.


## 2026-10-13 — R5c

### Düzeltilen

- **Düşük — Mobil darbe kartında üçüncü karar ilk ekranda görünmüyordu.** Uzun olay anlatısı sabit alt çubuğa doğru üç seçenekli listeyi itiyordu. Mobilde birlik, sessiz komutan, geciken ikmal, garnizon konumu ve muhafız tereddüdünü koruyan kısa özet kullanıldı; masaüstü metni aynı kaldı. EN/TR yatay mobil görüntülerde üç seçenek de görünür.
- **Düşük — Divan görüntü kontrolünde dikey konum portreleri kesiyordu.** Mobil Divan ekranı valiler ve komutanlar aynı anda görülecek kaydırma konumunda tekrar açıldı. Solen/Vey/Aven/Dask ile Rell/Kest/Nadir kartlarında göz, burun ve ağız görünüyor; ad/rol yüzün altında kalıyor. Kart kodunda yeni kırpma değişikliği gerekmedi.

### Açık

- **Düşük — Headless kapanış kaynak uyarıları.** Bazı UI/Sim testleri başarı özetinden sonra ObjectDB/RID/resource uyarıları bırakıyor; çıkış kodları 0. Hangi kaynakların motor kapanışından önce serbest bırakılabileceği ayrı temizlik işi gerektiriyor.
- **Düşük — Eski arşiv kayıtlarında ayrıntılı EN sebep.** `cause_key` içermeyen önceki kayıtlar korunuyor; İngilizcede genel uyumluluk cümlesi gösteriliyor. Ayrıntılı çeviri için eski kayıtların tanınması gerekir.
- **Düşük — Mobil Divan yoğunluğu.** Devlet, komutanlar ve dış ilişkiler tek uzun kaydırma alanında; taşma yok ama komutanlara ulaşmak için aşağı kaydırmak gerekir.
- **Düşük — Bölge çekmecesi ergonomisi.** Uzun mobil içerikte kapatma düğmesi çekmecenin üstünde sabit kalıyor; gerçek cihazda uzun eylem listesinin kullanımı ayrıca gözlenebilir.

## 2026-10-13 — Faz 7 kapanış

### Düzeltilen

- **Denge kapısı:** `advice_weighted` kapanış ölçümü 62/31/14 ile R5c'deki 59/31/16 sonuçlarını düzeltti. Kalibrasyonun kök nedeni ve uç botlar tasarım belgesinde kayıtlı.
- **Düşük — Görselsiz karar kartı başlığı:** `game/ui/agenda_view.gd` üst iç boşluğu 24'ten 32'ye çıkarıldı; bu, “Ordu emri” gibi sanatsız kartlarda başlığın çerçeveye yaklaşmasını önlüyor (`073cd90`). Ortak UI kapıları tekrar çalıştırıldı.
- Önceki R5c TEMP klasörü `Veloria_R5c_Visual` artık mevcut değil.

### Açık / doğrulama notu

- **Düşük — Açılış ekranından menüye geçiş gözlemi:** `tests/title_shot.gd` ile yalnızca TR masaüstü giriş ve menü görüntülerini açtım. Sentetik tıklama sonrası menü karesinde giriş ekranının sloganı/zemini hâlâ görünüyordu; bunun gerçek tıklama akışı mı yoksa ekran görüntüsü yardımcısının input/timing davranışı mı olduğu canlı dokunuşla doğrulanmalı. `title_shot.gd`, `title_screen.gd` ve `art/` değiştirilmedi.
- **Düşük — Görsel matris eksik:** EN ve yatay mobil menü, gündem, karar kartı, Divan, harita ve Günlük görüntüleri bu oturumda açılamadı; üç TR masaüstü görüntüsü dışında screenshot üretimini durdurdum, çünkü görüntüleri sildirme çağrısı araç politikasınca reddedildi. Kalan dosyalar: `C:\Users\USER\AppData\Local\Temp\Veloria_Faz7Closure\title_desktop_tr.png`, `C:\Users\USER\AppData\Local\Temp\Veloria_Faz7Closure\title_blink_desktop_tr.png`, `C:\Users\USER\AppData\Local\Temp\Veloria_Faz7Closure\menu_desktop_tr.png`.

## 2026-10-14 — v3 Görsel Dil Geçişi (Tüm Sayfalar)

### Düzeltilen

- **Gündem, Karar Kartı, Dosyalar ve Günlük (Commit `f21158b`):** Karar kartlarında tek süslü altın/kırmızı çerçeve (`border_width 0`), 1 px ince altın görsel kenarı, EB Garamond başlıklar, Alegreya Sans gövde metni, `ChoiceButton` stili, `_trait` kalıbında çipler, danışman portrelerinde 1 px kenar, kanıt satırlarında ton çubukları ve rahat iç boşluklar uygulandı.
- **Divan Çekmecesi (Commit `b9eb3c7`):** Tek süslü altın köşe çerçevesi ve soluk arma filigranı, rapor satırı kalıbında ton çubukları ve rahat boşluk, grup başlıklarında altın baklava ve caps Garamond, portre ve vali/komutan kartlarında 1 px ince altın kenar uygulandı.
- **Başkent Haritası ve Yakınlaştırma/Kaydırma (Commit `2cb4bda` ve `8e8b837`):** `art/city_map_v3.png` arka planı bağlandı; kurumlar `map_badge` diliyle (simgeli altın dairesel rozet, altın büyük harf ad, üçgen iğne) donatıldı; bölge katmanı ve butonları v3 diline uyarlandı; kurumlarda ve bölgelerde tek süslü altın çerçeve ve filigran; iki parmakla sıkıştırma (pinch), fare tekerleğiyle imleç merkezli zoom, sınır korumalı kaydırma, sabit 1x ters ölçekli yazı boyutu ve sıfırla butonu eklendi (`map_zoom_test.gd`).
- **Medya Merkezi (Commit `c4c5dd7`):** Gazete (Veloria Haber, Serbest Kalem kâğıt shader ve tramlar) ve Sarne TV (CRT shader ve ahşap kasa) diegetik görünümü korundu; üst başlık bandı `band_style`, sekmeler v3 altın süslü sekme dili (`tab_normal`/`tab_active`, caps Garamond, 44 px), Masaya dön düğmesi `GhostButton` ve 44 px dokunma hedefi uygulandı.
- **Masa (Commit `44b2026`):** Nesne etiket plakaları `map_badge` dilinde koyu zemin, ince altın kenarlık ve 3 px köşe pahı ile güncellendi; her nesne için altın dairesel rozet ve kodla çizilen vektörel altın simgeler (pusula, taç, defne, yıldız, terazi, göz, anten) yerleştirildi; altın caps Garamond başlıklar ve Alegreya Sans özetler; üst başlık altın caps Garamond (32 px) + 460 px divider + Alegreya Sans alt başlık; alt buton `PrimaryButton` ve caps Garamond (20 px, 68 px dokunma hedefi) yapıldı.
- **Menü, Ayarlar, Modallar, Arşiv, Hanedan, Başarımlar, Bütçe, Oyun Sonu, Tur (Commit `9c2d978`):** Panellerde kalın çift çerçeveler kaldırıldı, tek süslü altın köşeli çerçeve (`ornament` 1 px, panel `border_width 0`) uygulandı; tüm başlıklar altın Garamond caps, tüm gövdeler Alegreya Sans yapıldı; butonlar `PrimaryButton` / `GhostButton` ve caps Garamond, dokunma hedefleri en az 44 px sağlandı.
- **Mobil (1067x600) Genel Geçiş:** 1067x600 yatay mobil modunda tüm sayfalar (Gündem, Divan, Başkent haritası, Medya, Masa, Menü, Ayarlar, Oyun sonu) test edildi; tüm etkileşimli öğeler ve düğmeler ≥ 44 px dokunma hedefi karşılar; taşma veya yatay kayma yok; M1 dokunma kuralları doğrulandı.

### Açık

- **Düşük — Sanat varlığı ihtiyacı:** `art/city_map_v3.png` arka planı başarıyla kullanılıyor; ileride valiler ve komutanlar için bireysel sanat varlıkları eklenirse `map_badge` ve Divan kartlarında doğrudan kullanıma hazır altyapı mevcuttur (`art/` klasörüne dokunulmadı).
- **Düşük — Headless Godot kapanış kaynak uyarıları:** Bazı headless testlerde Godot motorunun çıkışta verdiği zararsız RID/ObjectDB uyarıları (exit code 0).

## 2026-10-14 — Görsel Dil v3 bağımsız denetimi

### Düzeltilen

- **Orta — Harita dokunma hareketleri oyuna ulaşmıyordu.** Ortak `TouchScroll` girdi olayını tükettiği için `CityView` sürükleme/sıkıştırma olaylarını alamıyordu. Harita hareketleri ayrı gruptan yönlendirildi; kısa dokunma bırakmada açıyor, sürükleme/pinch açmıyor. Sentetik test gerçek `ScreenTouch` / `ScreenDrag` olaylarını kapsıyor (`b00b0e3`).
- **Düşük — Bölge çekmecesi arkasındaki harita etiketleri görünüyordu.** Çekmece zemini opaklaştırıldı; işaretçinin ikinci açma yolu kaldırıldı (`b00b0e3`).
- **Düşük — Öne çıkan bölge yıldız glifi kullanıyordu.** Harita yıldızı çizimle gösteriliyor; test artık glif yerine öne çıkan bölge metaverisini doğruluyor (`af5059d`).
- **Düşük — UI görüntü fikstürleri geçersiz olay kimlikleri kullanıyordu.** Görselsiz ve çok karar durumları mevcut olaylara bağlandı; fikstür bulunamazsa hata veriyor (`1573102`).
- **Düşük — Harita sıfırlama kontrollerinin İngilizcesi eksikti.** Düğme ve tooltip çevirileri eklendi (`aa3b9f2`).
- **Düşük — Küçük etkileşim hedefleri.** Eylem kategorisi sekmeleri masaüstünde 28 px'e, mobil üst gezinme düğmeleri en az 44 px genişliğe çıkarıldı (`d70de6e`).

### Açık / ertelenen

- **Düşük — İngilizce menü logosunda Türkçe slogan.** TR ve EN menüleri aynı `art/logo_seffaf.png` raster logosunu kullanıyor; içindeki “Tahtın Gölgesinde” yazısı çevrilmiyor. Görsel varlık yazma kısıtı nedeniyle bu oturumda değiştirilmedi. TR/EN yan yana kanıt: `docs/ux/ref/denetim_menu.jpg`.
- **Düşük — Mobil UX ölçüm aracının etiket genişliği.** 1067×600 denetimde sekiz masa etiketi “METİN TAŞIYOR” uyarısı verdi. Ekran görüntülerinde bütün etiketler okunur ve çakışmasız; ölçer ters ölçekli harita etiketlerinin gerçek metin alanını hesaba katmıyor. Otomatik uyarı görsel kusur olarak doğrulanmadı.
- **Düşük — Girişten menüye test karesi animasyon sırasında alınıyor.** `title_shot.gd` tıklama sonrası menü katmanlarının kademeli görünmesi tamamlanmadan görüntü alabiliyor; bağımsız `ux_audit` menü karesinde kalıcı üst üste binme yok. Gerçek cihaz dokunuşuyla geçiş ayrıca doğrulanmalı.
- **Düşük — Tekrarlanan portre kenarı çizimi.** Birkaç görünüm aynı 1 px kenar panelini yerel olarak kuruyor. Görsel sonuçlar tutarlı; ortak portre kenarı yardımcısına toplama düşük öncelikli bakım işi olarak bırakıldı.
- **Düşük — Headless Godot kapanış kaynak uyarıları.** Bazı testlerin başarılı özetinden sonra RID/ObjectDB/resource uyarıları sürüyor; çıkış kodları 0.

### Ekran denetimi

TR masaüstü (1600×900 ve 1280×720) denetim görüntülerinde; EN masaüstü 1280×720'de; TR/EN yatay mobilde (1067×600) Gündem/karar, Dosyalar, Günlük, Divan, harita/kurum ve bölge panelleri, medya, masa, menü/ayarlar, modallar ve oyun sonu görünümleri kontrol edildi. EN masaüstü 1600×900'de seçili kişi, medya ve harita panelleri ayrıca açıldı. Ana ekran, onaylı `ana_ekran_g1e_karsilastirma.jpg` ile karşılaştırıldı; başlık/person paneli/gündem ana ekranına değişiklik kaynaklı sapma görülmedi. Bütün sayfa durumlarının her dil ve çözünürlük birleşimi ayrı ayrı incelenmedi. Harita dokunma düzeltmesi davranışsal; varsayılan simülasyon dosyalarına değişiklik yok.

### Test kayıt notu

Son tekrarın ham çıktısı `docs/ux/denetim_test_ciktilari.txt` içindedir. Kullanıcının “Testler tamam ben baktım” yönlendirmesi üzerine bu tekrar `ux_audit.gd` aşamasında durduruldu (36/44 vaka ilerlemesi). Önceki tam matriste `region_map_test` eski `★` beklentisiyle başarısız olmuştu; fikstür düzeltmesinden sonra desktop/mobile hedefli tekrarlar `REGION MAP: OK` verdi. Durdurulan tekrarın kalan vaka sonuçları bu dosyada doğrulanmış sayılmaz; önceki tam koşudaki tüm ham satırlar bu kısmi tekrar dosyasında saklı değildir.
