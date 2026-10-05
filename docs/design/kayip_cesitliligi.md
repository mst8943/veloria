# Kayıp çeşitliliği — sokak ve mahkeme krizleri

Tarih: 2026-10-06. Yol haritası Faz 2 "kayıp çeşitliliği". Kalıp: `darbe_asamalari.md` (aşamalı, görünür, cevap verilebilir kriz).

## Ölçüm (teşhis sondajı, Normal, 60 kampanya)
| Bot | En yüksek huzursuzluk (medyan / en kötü) | En yüksek yargı baskısı (medyan / en kötü) |
|---|---|---|
| idle | 70 / 86 | 2 / 2 |
| advice_weighted | 37 / 61 | 32 / 47 |
| visible_wise | 35 / 51 | 24 / 32 |
Kayıp eşikleri 100. Bir şey yapan hiçbir oyuncu yaklaşmıyor: ayaklanma ve yetkisiz bırakılma yolları ölü. Kayıpların ~%95'i darbe.

## Neden
1. **Bastırma bedelsiz denecek kadar etkili:** sözlü "Bastır" emri her mesai ~10 puan düşürüyor; haftalık kayma huzursuzluğu 30'a çekiyor. Tek bedel emri alanın güçlenmesi, o da orduya gidiyor. Sonuç: her yol Arden'in darbesine çıkıyor.
2. **Diğer iki yol sessiz birer sayı:** 100'e varınca oyun bitiyor ama oyuncu yaklaşmayı görmüyor, cevap veremiyor; darbe ise alamet, aşama ve kriz kartıyla geliyor.

## Tasarım
**Sokak öfkesi** (gizli, 0–100): her bastırma emri öfke biriktirir (fidelity × 8). Öfke arttıkça bastırma daha az işe yarar (etki × (1 − öfke/150)) ve huzursuzluğu her hafta kendisi besler (öfke × 0,03). Öfke haftada %7 söner. *Bastırmak bir borçtur: bugün sokağı susturur, yarın daha yüksek sesle geri gelir.*

**Ayaklanma krizi** (huzursuzluk ≥ 54; ayar için Sonuç'a bak): kriz kartı "Sokaklar ayakta". Bir hafta içinde çözülmezse ya da seçilen yol başarısız olursa saray düşer (ayaklanma).
- *Orduyu sokağa sür*: başarı orduya, kralın gücüne bağlı, öfkeyle düşer. Başarırsa huzursuzluk ciddi düşer ama öfke artar, ordu güçlenir ve kral hakkında ağır bir sır doğar ("kanlı gece"): sokak yolundan mahkeme yoluna geçiş.
- *Talepleri kabul et*: ilk sefer büyük olasılıkla tutar (%85), sonrakilere daha az inanılır. Bedeli ekonomi, kralın gücü, muhalefet.
- *Halka seslen*: kralın gücüne bağlı, öfke ve muhalefetle düşer.

**Yetki krizi** (yargı baskısı ≥ 40): kriz kartı "Mahkeme yetkilerini askıya almayı görüşüyor". Çözülmezse ya da yol başarısız olursa yetkisiz bırakılırsın.
- *Mahkemeyi tasfiye et*: başarı muhalefete ve kamuya açık skandallara bağlı. Başarırsa baskı büyük ölçüde düşer, Falk gider, muhalefet ve sokak öfkelenir, yeni bir sır doğar.
- *İfade ver, uzlaş*: ilk sefer büyük olasılıkla tutar (%85), sonra azalır. Bedeli kralın gücü.
- *Meclisle dokunulmazlık pazarlığı*: muhalefet zayıfsa tutar; servet ve muhalefet bedeli.

**İşaretler (tohum → işaret):** huzursuzluk 46'yı, yargı baskısı 32'yi geçtiğinde bir kez haber satırı (SOKAK / MAHKEME); "Geçen haftadan beri" özetinde de görünür. Bastır önizlemesinde öfke yüksekse "Sokak bastırmaya alışıyor" uyarısı. Kriz kartı darbe kartı gibi görünür ipuçları taşır (muhafız/meclis ve sokak durumu).

## İlke kontrolü
1 Belirsiz bilgi: öfke gizli ama sezilir (bastırmanın azalan etkisi, haber satırları, kriz kartı ipuçları). 2 Bedel: güçlü destek (bastırma artık borç). 3 İnsanlar: kriz kartlarında Lena, Brandt, Falk. 4 Dünya beklemez: öfke ve skandal birikimi gecikmeli döner. 5 Ortak bilgi: kanlı gece ve tasfiye sırları mahkeme yolunu besler. 6 Başarısızlık hikâye: üç farklı düşüş, üç farklı tarih metni.

## İstismar ve denge
Kabul/uzlaşma ilk seferde %85, sonra azalır (darbe tavizi gibi): sonsuz kaçış yok. Krizler darbe kriziyle aynı bekleme süresini paylaşır. Hedef: ölçüt botta darbe payı ≤ %75, ayaklanma ve yetkisizlik birlikte ≥ %15; kazanma oranları bantta.

## Sonuç (2026-10-06, uygulandı)
Ayar: `UPRISING_AT` 54, `LEGAL_CRISIS_AT` 40 (ilk denemede 70/50 hiç tetiklenmedi, 58/42 çok seyrek kaldı), uyarılar 46/32, ilk taviz/uzlaşma %85 (kesin değil).

**Oyun tarzına göre** (Normal, 80 kampanya; yeni sondaj botları `advice_soft`, `advice_dirty`):
| Tarz | Kazanma | Açılan kriz (darbe / mahkeme / sokak) | Darbe dışı kayıp payı |
|---|---|---|---|
| Bastıran (advice_weighted) | %40 | 128 / 9 / 1 | %4 |
| Yumuşak (hiç bastırmaz) | %43 | 113 / 8 / 8 | %11 |
| Kirli (yazılı emir, şantaj) | %36 | 124 / 35 / 4 | %16 |
| Bilge (visible_wise) | %91 | 18 / 0 / 0 | – |
Kayıp artık oyun tarzına bağlı: kirli oynayan mahkemeyle, sokağı bastırmayan sokakla, bastıran ordu darbesiyle yüzleşiyor (§20 "final tehdidini oyuncunun geçmişi belirler").

**Denge** (ölçüt bot advice_weighted, 80 kampanya): Kolay 85 -> 81, Normal 48 -> 40, Zor 21 -> 18; üçü de bantta. Görünür bot Kolay'da 11 kez yetkisiz bırakılıyor (bol servetle rüşvet -> iz -> mahkeme).

**Kısmi:** ölçüt botta darbe dışı pay %4 (hedef %15). Bu bot sokağı her hafta bastırdığı için doğal olarak darbe yoluna gidiyor; daha fazla çeşitlilik için darbe sıklığının kendisi düşürülmeli (ayrı denge işi). `idle` bot artık 14–25. haftalarda ayaklanmayla düşüyor (eskiden ~25. haftada darbe).
