# Aktörlerin kendi hamleleri — "Dünya oyuncuyu beklemez"

Tarih: 2026-10-06. Yol haritası Faz 2. Kaynak: Tasarım Özeti §21 (olayların büyümesi), §23 (dünya beklememeli).

## Sorun
Güç merkezleri arka planda büyüyor (haftalık tick, komplo hazırlığı) ama bunu kimse "yapmıyor". Oyuncu Arden'in güçlendiğini kart kademesinin değişmesinden öğreniyor, nedenini görmüyor. §21 darbenin "önce general güçlenir, sonra kendi subaylarını kritik görevlere getirir..." diye gelmesini istiyor; §23 "Ben bu dünyanın en güçlü aktörüyüm fakat tek aktörü değilim" hissini.

## Tasarım
Her güç merkezinin kendi alanında, kendi çıkarına yaptığı küçük **hamleler**. Seçeneksiz, kendiliğinden olan olaylar:
- Koşulları kişinin durumuna bağlı (güç, hırs, hayatta olması); bu yüzden büyüttüğün kişi daha çok hamle yapar.
- Etkileri küçük (±1–4) ama birikir; çoğu o kişiyi güçlendirir, bazıları kralın işine yarar (sadakat yemini, bütçe fazlası).
- Görünür: haber şeridinde "HAMLE: ..." ve "Geçen haftadan beri" özetinde portresiyle. Kanal (TV) yayınlamaz.
- Tekrarlanır (`once: false`, `cooldown`, `chance`); haftalık karar sınırına sayılmaz.

**Oyuncuya ne kazandırır?** Tehdit nedenleriyle görünür: "Arden üç haftadır kendi adamlarını atıyor." Huzura çağırma, terfi etmeme, rakibini güçlendirme gibi kararlara bilgi verir.
**İstismar:** yeni oyuncu eylemi yok; hamleler yalnızca görünür kılınan bir dünya akışı.
**Denge:** dünyaya küçük bir net baskı ekler; ölçülür ve olasılıklarla ayarlanır (hedef: ölçüt bot bantta).

## Motor
Seçeneksiz olaylar zaten etkilerini doğrudan uygular. Ek alanlar: `news` (haber metni, "HAMLE: " önekiyle), `actor` (özette portre), `tone` (-1/0/+1). Haber şeridinde öncelik: KRİZ, ALAMET, SOKAK/MAHKEME, MANŞET önce; HAMLE en son. `event_check` seçeneksiz olayı ayrı denetler (`news` zorunlu, `choices`/`ignore` yok).

## Sonuç (2026-10-06, uygulandı)
16 hamle (her güç merkezi 1–3), haftada ortalama ~0,7 hamle. Etkiler ±1–2.

**Denge dersi:** İlk sürüm ölçüt botu Normal'de %40 -> %22'ye düşürdü. Grup grup yalıtılarak ölçüldü (`--keep=` süzgeci): suçlu Prens'in hamleleriydi. Prens hanedan olduğu için darbe yapabilen iki kişiden biri; küçük güç ve hırs artışları komplocuların güç payını darbe eşiğinin üstüne itiyordu. Karar: **darbe yapabilen aktörlerin hamleleri tehdidi göstermeli, yaratmamalı.** Prens'in soylu yemekleri artık yalnızca hırsı zaten yüksekken çıkan etkisiz bir işaret; Arden'in hamleleri küçük tutuldu ve bir de iyi hamlesi var (bağlılık yemini).

**Ölçüm** (80 kampanya, ölçüt bot advice_weighted):
| | Kolay | Normal | Zor |
|---|---|---|---|
| Hamlesiz | 81 | 40 | 18 |
| Hamleli | 80 | 41 | 27 |
Zor'daki artış iyi hamlelerden (yemin, bütçe fazlası, vakıf); bant içinde.

`pacing_test` hamleleri karar olayı saymaz. Tam saltanat UI testi (`--full`) her mesaiyi rüşvete harcayan bir bottu; mahkeme yolu bu tarzı cezalandırdığı için artık haftada en fazla bir ödeme yapıp huzura çağırıyor ve kriz kartında uzlaşıyor.
