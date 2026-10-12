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
