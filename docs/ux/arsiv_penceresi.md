# Hükümdarlık Arşivi penceresi — hedef tasarım

Hedef: `docs/ux/ref/arsiv_hedef.webp` (kullanıcının onayladığı mockup). Ana menü > "Hükümdarlık Arşivi" ile açılan pencere (şu an `main.gd` `_show_chronicle()`, düz metinli modal).
Not: "Hanedan Defteri" ayrı bir sayfa (menu.gd `show_page("dynasty")`); bu görevin DIŞINDA, aynı dil sonra uygulanabilir.

## Yerleşim (mockup, 1600×900 tam ekran pencere)
- Dış çerçeve: kalın süslü altın çerçeve (köşelerde akantus), koyu zemin. Arka plan görseli `art/ui/arsiv_arka_plan.png`: iki yanda altın aslan kabartması + taçlar, mum ışığı, ortası boş koyu. Görsel yoksa koyu zemin + `UIKit.ornament`.
- Üst: "HÜKÜMDARLIK ARŞİVİ" (EB Garamond, büyük, altın) + yanında kitap yığını simgesi (`art/ui/arsiv_kitaplar.png` ya da yedek çizim) + alt başlık "Tarih, kararlar ve sonuçlar." (EN: "History, decisions and consequences.").
- Üç istatistik kutusu (süslü köşeli, simge + küçük başlık + değer): **Saltanat sayısı** (takvim simgesi), **Tahtta kalan** (kum saati; kaç saltanat tahtta bitti), **En uzun saltanat** (parşömen; "26 Hafta"). Mevcut `Sim` kayıt verisinden; mockup'taki "5. Saltanat Yılı / 0 Yıl - 2 Gün" yer tutucudur, uydurma veri yazma. Mevcut metindeki üç değer (saltanat sayısı, tahtta kalan, en uzun saltanat) bu kutulara taşınır.
- **SON OLAYLAR** bölümü: kırmızı tonlu başlık bandı (kılıç simgesi), altında en çok 6–8 kayıt satırı; her satır: solda tarih + "N hafta" (ortalı), ortada kalkan rozeti (düşenler için kırmızı kalkan: taç/kılıç; tahtta kalanlar için altın-yeşil kalkan), sağda **DÜŞTÜ** (kırmızı) veya **TAHTTA** (yeşil) + unvan (ör. "Devrilen Kral") + sebep metni (en çok 2–3 satır, küçük). Satırlar ince ayraçlarla bölünür; solda ince kırmızı/yeşil durum çubuğu. Kalkan tipi sonuç türüne göre (darbe → kılıç kalkan, ayaklanma → taçlı kalkan, tahtta → altın kalkan); bilinmeyen tür taçlı varsayılan.
- **BAŞARIMLAR** bölümü: yeşil tonlu başlık bandı (defne simgesi), sağda "3 / 46" sayacı; satırlar: simge + ad (kazanılmış parlak, kazanılmamış sönük) + açıklama; kazanılmışlar önce. Simgeler kodla çizilir (ince altın çizgi; bayrak, insanlar, bina, çapraz kılıç, el sıkışma, çadır, terazi, taç, defne dalı… başarıma göre; eşleşme yoksa genel yıldız/baklava). 46 başarım uzun: liste kaydırılır (ince altın kaydırma çubuğu), pencere içeriği kaydırmalı.
- Alt: "Kapat" süslü düğme (mevcut `btn_*` teması), ortada, çerçevenin altında. Esc de kapatır, × yok.
- Mobil (1067×600): arka plan aslanları gizli, tek sütun, istatistik kutuları üçlü şeritte küçük, satırlar ≥ 44 px, kaydırma M1 dokunma kurallarına uyar.

## Kurallar
- Gövde yazısı `UIKit.sans()` (Alegreya Sans), başlıklar `UIKit.serif()/caps()`, TEK süslü çerçeve (çerçeve üstüne çerçeve yok), "sayı yok" ilkesi (burada yalnızca açık kayıt verisi: hafta sayıları, tarih).
- Metinler TR+EN (`tr()`), mevcut `Sim.chronicle_cause(r)` kullanılır (eski kayıtların İngilizce uyumluluk cümlesi bozulmasın; mockup'taki karışık TR/EN satır bu eski kayıt davranışıdır, düzelt: EN dilde sebep EN, TR dilde TR gösterilsin; eski cause_key'siz kayıtlar yalnızca mevcut dilde genel cümle).
- Test hijyeni: gerçek `user://` profiline yazma; test sahte kayıtları geçici profille yüklesin.

## Yeni görseller (kullanıcı üretir; yoksa yedek çizim)
`art/ui/arsiv_arka_plan.png` (2000×1125, opak), `art/ui/arsiv_kitaplar.png` (saydam), `art/ui/arsiv_kalkan_dustu.png` (saydam, kırmızı kalkan), `art/ui/arsiv_kalkan_tahtta.png` (saydam, altın-yeşil kalkan). Kalkan varyantları kodla da boyanabilir (yedek).

## Uygulama kontrol listesi

| Mockup bölgesi | Durum | Kontrol |
|---|---|---|
| Dış çerçeve, koyu zemin ve yan aslanlar | Kısmen | Tek ince çift altın çerçeve ve kodla çizilmiş köşe süsleri var. `arsiv_arka_plan.png` depoda olmadığından aslan kabartmaları ve mumlar görünmüyor; dosya gelince otomatik kullanılır. |
| Başlık ve kitap yığını | Karşılandı | Başlık ve alt başlık ortalı; kitap görseli yokken yazıyla çizilmiş kitap yedeği gösteriliyor. |
| Üç istatistik kutusu | Karşılandı | Saltanat sayısı, tahtta bitenler ve en uzun saltanat yalnızca arşiv kayıtlarından hesaplanıyor. Kayıt yokken en uzun süre `—`; örnek değer uydurulmuyor. |
| Son olaylar bandı ve kayıt satırları | Karşılandı | En yeni sekiz kayıt kaydırılabilir; tarih/hafta, sonuç kalkanı, renkli sonuç, unvan ve `Sim.chronicle_cause()` metni bulunuyor. Eski anahtarsız kayıt İngilizcede mevcut genel cümleyi, Türkçede kayıtlı sebebi kullanıyor. Kalkan görselleri yokken çizilmiş yedek gösteriliyor. |
| Başarımlar bandı ve liste | Karşılandı | 46 başarımın tamamı kaydırılabilir, kazanılanlar üstte, sayaç doğru; simgeler glif yerine ince altın çizgilerle çiziliyor. EN görünümünde İngilizce başarı içeriği yükleniyor. |
| Kapat düğmesi ve Esc | Karşılandı | Ortalı süslü düğme ve Escape kapatması çalışıyor. |
| Mobil düzen | Karşılandı | 1067×600 yatayda üç küçük istatistik kutusu, dikey olay/başarım akışı ve en az 44 px düğme/satırlar kontrol edildi. |

TR ve EN için 1600×900, 1280×720 ve 1067×600; boş ve 10 kayıtlı arşiv görüntüleri açılıp incelendi. 1600×900 TR uygulaması ile hedef mockup yan yana [karşılaştırma görselinde](ref/arsiv_karsilastirma.jpg); her iki panel 1600×900 (toplam 3200×900). Geçici görüntüler `C:\Users\USER\Desktop\oyun\Temp` altında kaldı; temizleme komutu güvenlik politikası tarafından reddedildi.

## Gözlemler

Kullanıcı tarafından sağlanacağı belirtilen dört `art/ui/arsiv_*.png` görseli mevcut değil. Beklenen dosyalar ve ekranda değiştirecekleri:

- `art/ui/arsiv_arka_plan.png` — 2000×1125 opak arka plan; koyu düz yedek zeminin yerini alıp mockup'taki mum/aslan kabartmalarını getirir.
- `art/ui/arsiv_kitaplar.png` — saydam kitap illüstrasyonu; başlıkta 62×52 px (mobilde 44×42 px) çizim yedeğinin yerini alır.
- `art/ui/arsiv_kalkan_dustu.png` — saydam düşüş kalkanı; olay satırında 42×50 px (mobilde 36×44 px) vektör kalkanın yerini alır.
- `art/ui/arsiv_kalkan_tahtta.png` — saydam tahtta kalma kalkanı; aynı ölçüdeki yeşil-altın vektör kalkanın yerini alır.

Dosyalar yokken çizim yedekleri içerik, erişilebilirlik ve yerleşimi korur. Her varlık `ResourceLoader.exists()` ile seçilir; sonradan eklendiklerinde kod değişmeden görünür. `art/` klasörüne bu çalışma sırasında dosya yazılmadı.
