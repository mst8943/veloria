# Medya Merkezi v2 — gerçek gazete, gerçek televizyon

Tarih: 2026-10-05. Kullanıcı: "gazeteyi daha gerçekçi bir gazete gibi yap, televizyon gibi nesneleri de".
Kod: `game/ui/media_view.gd`; shader'lar `paper.gdshader`, `newsprint.gdshader` (yarım ton), `crt.gdshader`.

## Oyuncu sorusu (değişmedi)
"İki gazete ve kanal aynı haftayı nasıl anlatıyor; kim yalan söylüyor?" Gerçekçilik bu karşılaştırmaya hizmet etmeli:
iki gazetenin **kimliği bir bakışta ayrılmalı** (resmî, parlak, devletin sesi / ucuz kâğıtlı, sert, bağımsız).
Bilgi miktarı aynı kalır; yeni gizli bilgi eklenmez.

## Gazete: neden şimdi "gazete gibi" değil
Düz krem kutu, gövde metni sans ve sola yaslı, fotoğraf düz gri ton, künye tek satır. Gazeteyi gazete yapan ögeler eksik:
kâğıt dokusu ve katlanma izi, iki yana yaslı serif gövde, künye kulakçıkları, fotoğraf altı yazısı, yarım ton baskı, haber yeri ("BAŞKENT —").

| Öge | Veloria Haber (resmî) | Serbest Kalem (bağımsız) |
|---|---|---|
| Kâğıt | sıcak krem, temiz; lif dokusu, kenarlarda sararma, yatay katlanma izi | gri, ucuz kâğıt, daha belirgin lif ve kenar |
| Künye | büyük serif, iki yanda kulakçık kutuları (sayı / fiyat), ince-kalın çift çizgi | kalın Plex büyük harf, solda kırmızı blok, altında kırmızı çizgi |
| Tarih satırı | büyük harf, iki çizgi arasında: BAŞKENT · HAFTA · SAYI · slogan | aynı yapı, kırmızı vurgu |
| Manşet | serif, tam genişlik | serif, daha büyük ve sıkışık |
| Spot | eğik serif | eğik serif |
| Gövde | serif, iki yana yaslı, "BAŞKENT —" ile başlar | aynı |
| Fotoğraf | yarım ton nokta baskı, altında eğik küçük fotoğraf yazısı | yarım ton, daha sert |
| Sütunlar | kırmızı küçük başlık, serif sütun başlığı, iki yana yaslı serif gövde | aynı |
| Alt şerit | hava durumu kutusu + çift çerçeveli ilan | aynı |

## Televizyon: neden şimdi "televizyon gibi" değil
Yuvarlak siyah kutunun içinde bir görsel; ekranın kendisi yok (cam, eğrilik, fosfor), kanal grafikleri amatör.

- **Cihaz**: koyu ceviz kasalı 90'lar tüplü televizyonu. Ekran çevresinde içe eğimli siyah çerçeve, altta marka plakası (VELTRON), güç ışığı, iki düğme ve hoparlör ızgarası. Hepsi çizilir (görsel dosyası yok).
- **Ekran (CRT shader, ekran dokusunu okur)**: hafif fıçı eğriliği, yuvarlak köşe maskesi, tarama çizgileri, RGB fosfor maskesi, kenar kararması, ince parazit ve yavaş kayan parlaklık bandı. Kanal grafikleri de camın arkasında kalır: bindirmeler de eğrilir.
- **Yayın grafikleri**: sol üstte kanal logosu kutusu + CANLI, sağ üstte saat, alt üçlü bant (kategori etiketi "GÜNDEM" ya da kriz haftasında "SON DAKİKA" + manşet + spot), en altta sabit "HABERLER" bloklu kayan şerit, haberler arasında çizilmiş kare ayraç.
- **Hata düzeltmesi**: Kayan şerit `ALAMET:` satırlarını da yayınlıyordu. Alametler kralın gizli gözlemleri; kanal bunları bilemez. Filtrelenir (`press.gd::broadcast`).

## Mobil
TV ekran genişliği eldeki yüksekliğe göre hesaplanır (taşma yok). Gazete kaydırılabilir kalır, kâğıt genişliği ekrana sığar.

## Kabul ölçütleri
- İki gazete bir bakışta ayırt ediliyor; ikisi de "basılı kâğıt" gibi duruyor (doku, katlanma, yaslı serif, yarım ton).
- TV bir nesne gibi duruyor; ekran camı (eğrilik/tarama/maske) kanal grafiklerini de kapsıyor.
- Şeritte ALAMET yok. Metinlerde web glifi yok (ayraçlar çizilir).
- Masaüstü ve mobil görüntülerde kırpılma ya da taşma yok; otomatik oynatma testleri geçiyor.
