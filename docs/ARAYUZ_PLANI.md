# Veloria — Diegetik Arayüz Planı

Amaç: Oyuncu menülerde değil, dünyanın içinde gezinsin. Masa, harita ve medya; oyunun gizli bilgi sistemine bağlı, okunabilir ve tıklanabilir yüzeyler olsun.

## 1. Çalışma Masası (ana merkez)

Her haftanın başında açılan merkez ekran. Masadaki nesneler birer kapıdır:

| Nesne | Açtığı ekran | Rozet |
|---|---|---|
| Mühürlü mektuplar | Gündem: kararlar ve raporlar | Bekleyen karar sayısı |
| Gazete | Medya Merkezi (gazeteler + TV) | Yeni sayı |
| Telefon | Kişiler: güç merkezleri ve eylemler | Kalan mesai |
| Saltanat Günlüğü | Günlük, Söz Defteri | Vadesi yaklaşan söz |
| Gizli çekmece (dosya) | Dosyalar ve sırlar | Dedikoduya dönüşen sır |
| Hanedan fotoğrafı | Hanedan, Hükümdarlık Arşivi, başarımlar | — |
| Başkent haritası | Başkent Haritası | — |

Alt bantta büyük düğme: "GÜNDEMİ AÇ". Nesnelerin üzerine gelince hafifçe kalkar ve parlar.

**Görsel:** Masa arka planı + her nesne ayrı, saydam PNG (yerleri kodla belirlenir, hareket edebilir). Görseller gelene kadar mevcut ikonlarla ve kodla çizilmiş nesnelerle çalışır.

## 2. Başkent Haritası

Gece kuşbakışı şehir; kurumlar birer bina:

| Bina | Panel içeriği |
|---|---|
| Saray | Masaya dön |
| Genelkurmay | Arden, ordunun raporu, ordu ile ilgili eylemler |
| İstihbarat | Voss, araştırma ve soruşturma, arşiv |
| Adliye | Yargıç Falk, saraya uzanan dava dosyaları |
| Parlamento | Brandt, muhalefetin durumu, söz defteri |
| Medya Merkezi | Gazeteler ve TV |
| Halden Holding | Halden, ihaleler, borçlar |

**Görsel:** `art/city_map.png` (16:9 gece kuşbakışı). Bina konumları `game/data/city_map.json` dosyasında yüzde olarak tutulur; görsel değişirse sadece bu dosya güncellenir.

## 3. Medya Merkezi (okunabilir)

| Yayın | Sahibi | Davranış |
|---|---|---|
| Veloria Haber (gazete) | Halden | Halden'in süsleme oranıyla yazar; kamuya açılan saray skandallarını sansürler ya da "asılsız iddia" der |
| Serbest Kalem (gazete) | Lena | Lena'nın dürüstlüğüyle yazar, söylentileri basar. Lena susturulduysa kapanır, korkutulduysa yumuşar |
| Halden TV | Halden | Canlı yayın, alt bant manşet, kayan haber şeridi |

İçerik her hafta simülasyondan üretilir: manşet (haftanın olayı ya da patlayan skandal), ekonomi, sokak, muhalefet, saray kulisleri, küçük ilanlar ve hava durumu. Haber fotoğrafı, olay görselinin gazete baskısı filtresinden geçmiş hâlidir.

## Uygulama sırası

1. **Medya Merkezi** (görsel gerektirmez) — tamamlandı
2. **Çalışma Masası** — kodla çizilmiş nesnelerle; görseller gelince değişir
3. **Başkent Haritası** — kodla çizilmiş harita; `city_map.png` gelince değişir
4. Görsel prompt'ları: `ART_PROMPTS.md` bölüm 7
