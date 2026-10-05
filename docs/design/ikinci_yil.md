# İkinci yıl paketi — Bedellerin Dönüşü ve Hesaplaşma

Tarih: 2026-10-06. Yol haritası Faz 3 ("ikinci yıl için 20–30 olay") + Faz 2 (kayıp çeşitliliği) katkısı.
Kaynak: Tasarım Özeti §20 (kampanya dönemleri), §21 (olayların büyümesi), §22 (dünya hafızası).

## Sorun (ölçüm, `pacing_test.gd`)
İlk yıl haftada ~1,0–1,3 olay; 57. haftadan sonra ~0,6. 52. haftadan sonra yalnızca 6 olay vardı; 67–95 arası yalnızca zincir/tekrar olaylarla doluyordu. Oyunun doruk noktası olması gereken son çeyrek, en ince bölümüydü. Kayıpların çoğu askerî darbe.

## Fikir
§20'deki iki dönem, oyuncunun geçmişinden beslenir ("final tehdidini oyuncunun kendi geçmişi belirler"):
- **Bedellerin Dönüşü (56–80):** ilk yılın araçları geri döner. Rüşvet verdiysen ödeme defteri, yazılı emir verdiysen kopyaları, şantaj yaptıysan kurbanı, söz bozduysan elitlerin hafızası. Hiç dokunmadığın şey geri gelmez; bu yüzden her kampanyada farklı olaylar çıkar.
- **Hesaplaşma (80–100):** büyüttüğün güç merkezi faturayı keser. Ordu (muhtıra), oligark (meclisi satın alma), halk (çadır kent), prens (soylular meclisi), yargı (dosyaların birleşmesi), istihbarat (derin devlet). Koşullar o merkezin gücüne/hırsına bağlı; zayıf tuttuğun merkezden hesap gelmez.
- **Ortam olayları** aradaki boşlukları doldurur (kuraklık, maden faciası, yabancı yatırımcı, mülteciler, bayram, saray tarihçisi) ve iki zincir devamı (muhtıranın sonrası, defterin ikinci kopyası).

## Motor
Yeni koşul `min_stat` / `max_stat` (`Sim.stats`: bribes, written, blackmails, promotes, broken, ops...). `event_check.gd` istatistik adlarını denetler.

## Tasarım soruları
1. **Ne kazandırır?** İkinci yıl ilk yılın tekrarı değil, sonucu olur. "Bu benim yüzümden" hissi (§21).
2. **Karar:** her olayda üç seçenek: bedeli şimdi öde / başkasına yükle (iz, güç, borç) / ertele. Ertelemenin de bedeli var.
3. **Gerilim:** oyuncu ilk yılda yaptıklarının döneceğini bilir ama ne zaman ve nasıl döneceğini bilmez.
4. **Derinlik:** her seçenekte bir kazanç ve bir bedel var; "doğru" cevap oyuncunun rejimine göre değişir.
5. **Okunurluk:** metinler isim taşır; meclis görüşleri otomatik; "Geçen haftadan beri" özeti sonuçları gösterir.
6. **Etkileşim:** sırlar (kral hakkında yeni dosyalar → yargı baskısı), söz defteri, kaskad (güç/hırs), kriz (Hesaplaşma olayları komplocu güçleri büyütebilir).
7. **İstismar:** istatistik koşulları yalnızca kötü sonuçları tetikler; "hiç yapmama" ödülü yok (max_stat yalnızca bir iyi niyet olayında). Hesaplaşma olayları `once`.
8. **Evre dengesi:** yalnızca 56+; Hesaplaşma 80+.

## İlke kontrolü
1 Belirsiz bilgi: nötr. 2 Bedel: güçlü destek (bedellerin dönüşü). 3 İnsanlar: destek (her olay bir isim). 4 Dünya beklemez: güçlü destek (gecikmeli sonuç). 5 Ortak bilgi: destek (yeni sırlar ve sızıntılar). 6 Başarısızlık hikâye: destek (yargı/halk kayıpları çeşitlenir).

## Ölçüt
- `pacing_test`: 57–104 dilimlerinin her birinde ≥0,8 olay/hafta.
- `balance-check` (advice_weighted): Kolay 70–85, Normal 35–55, Zor 15–30 bandında kalır; darbe dışı kayıp payı artar.
- `event_check`: temiz. `sim_test`: tetiklenmeyen olay listesine bakılır.
- Görseller: hepsi mevcut görsellere bağlı; özel görsel promptları sonra (ART_PROMPTS.md).

## Sonuç (2026-10-06, uygulandı)
30 olay eklendi (71 -> 101): 8 "Bedellerin Dönüşü" (6'sı `min_stat` ile oyuncu geçmişine bağlı, 1'i `max_stat` iyi niyet olayı), 6 kişiye bağlı ikinci yıl olayı, 6 Hesaplaşma, 2 zincir devamı, 8 ortam/son dönem olayı. Hepsi mevcut görsellere `art` ile bağlı.

**Tempo** (`pacing_test`, olay/hafta):
| Dilim | Önce | Sonra |
|---|---|---|
| 57–64 | 0,59 | 1,00 |
| 65–72 | 0,60 | 1,13 |
| 73–80 | 0,65 | 0,85 |
| 81–88 | 0,57 | 0,82 |
| 89–96 | 0,65 | 0,80 |
| 97–104 | 0,50 | 0,57 (örneklem küçük: 40 oyun-haftası) |
En uzun olaysız seri (medyan / en kötü): 4 / 8 -> 2 / 5.

**Denge** (probe, 80 kampanya):
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible | 56 -> 41 | 23 -> 17 | 15 -> 12 |
| advice_weighted (ölçüt) | 80 -> 85 | 48 -> 48 | 27 -> 21 |
| visible_wise | 100 -> 100 | 98 -> 85 | 88 -> 81 |
Ölçüt bot hedef bantta. Kararları rastgele veren bot belirgin düştü: ikinci yılda kararlar daha önemli (istenen). Ünvan çeşitliliği hafif arttı (Normal'de "Medya İmparatorunun Kuklası" 11 -> 17).

**Tutmayan hedef:** kayıp çeşitliliği değişmedi (hâlâ ~%95 darbe). Hesaplaşma olayları halk/yargı yollarına bedel ekliyor ama ayaklanma (unrest 100) ve yetkisiz bırakılma (legal_pressure 100) eşiklerine botlar yaklaşmıyor. Ayrı iş: Faz 2 "kayıp çeşitliliği" (eşiklere giden sürekli baskılar, ör. kamuya açılan kral sırlarının birikmesi).

**Bilinen:** sim_test botları rüşvet/şantaj/yazılı emir kullanmadığı için istatistik olayları o testte "hiç tetiklenmeyen" listesinde görünür; ulaşılabilirlik kontrolü bunları doğrular.
