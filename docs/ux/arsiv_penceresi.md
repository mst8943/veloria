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
