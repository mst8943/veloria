# Faz 1 kalanı — "Neler değişti?" ve eylem önizlemesi

Tarih: 2026-10-06. Yol haritası: `docs/YOL_HARITASI.md` Faz 1 (son iki madde).

## Sorun
Oyuncu her hafta aynı ekrana bakıyor ama **neyin değiştiğini** kendisi karşılaştırmak zorunda: geçen hafta Arden ne demişti, Voss'un tavrı ne zaman bozuldu, hangi sır yayılmaya başladı? Bilgi var ama okunmuyor. Ayrıca bir eylemin bedeli (mesai, servet, iz, risk) ancak uzun ipucu metni okunursa anlaşılıyor; seçili kişiye göre neyin işe yaramayacağı (zayıf noktası bilinmeyene şantaj, servet yetmezken ödeme) basılınca öğreniliyor.

## Tasarım soruları
1. **Ne kazandırır?** Haftalar arası örüntüyü görmek: "Arden üç haftadır karamsarlaşıyor, ama Voss hâlâ her şey yolunda diyor."
2. **Hangi karar?** Mesaiyi nereye harcayacağın: değişen kişiyi doğrula, çağır ya da araştır. Önizleme ise "bu eylemi bu kişiye şimdi yapmalı mıyım" kararını hızlandırır.
3. **Gerilim** çelişkiden gelir: rapor iyimserleşirken tavır kötüleşiyorsa biri yalan söylüyordur.
4. **Derinlik**: hiçbir gösterge gerçeği vermez; değişim de raporun **söylediğinin** değişimidir.
5. **Sayı yok**: kademe adları (iyimser / tedirgin / karamsar), renk ve çizilmiş küçük ok.
6. **Etkileşim**: raporlar (yalan filtresi), alametler/tavır, sırlar (KULİS/MANŞET), söz defteri, ertelenen kararlar.
7. **İstismar**: Yeni gizli bilgi yok. Her satır, oyuncunun zaten görebildiği bir göstergenin önceki haftayla farkı. Önizlemedeki risk yalnızca görünür girdilerden (güç kademesi, bilinen zayıf nokta, çember büyüklüğü) hesaplanır ve "tahmini" diye etiketlenir.
8. **Oyun evreleri**: Erken oyunda özet kısa olur; geç oyunda sırlar ve sözler biriktikçe değeri artar. Satır sayısı sınırlı (en çok 6, önemliye göre sıralı).

## İlke kontrolü
1 Belirsiz bilgi: destekliyor (değişim sinyali, gerçek değil). 2 Bedel: destekliyor (önizleme izi görünür kılar). 3 İnsanlar: destekliyor (her satır bir isimle başlar). 4 Dünya beklemez: destekliyor (gecikmeli sonuçlar özette görünür). 5 Ortak bilgi: destekliyor (KULİS/MANŞET satırları). 6 nötr.

## Kurallar (Sim)
- `report_prev: {kaynak: band}`: raporlar yeniden üretilmeden önce bir önceki haftanın söylenen bandı. Kayda yazılır.
- `week_changes: Array[{tone, text, actor}]`: `end_week` başında görünür durumun fotoğrafı (`_visible_snapshot`) çekilir, sonunda farkı alınır. Kaynaklar: rapor tonu, güç kademesi (3), tavır (`suspicion_level`), düşmanlaşma (`moved`), görevden düşenler, sözlerin durumu ve karşılık isteme, KULİS/MANŞET ve ERTELENDİ haberleri. `tone`: -1 kötü, 0 dikkat, +1 iyi. Kayda yazılır.

## Arayüz
- **Rapor satırı**: portrenin yanında çizilmiş küçük ok (yukarı yeşil: daha iyimser; aşağı kırmızı: daha karamsar). İpucu: "Geçen haftaya göre daha karamsar konuşuyor (raporun söylediği; gerçek olmayabilir)."
- **Gündem > GEÇEN HAFTADAN BERİ**: karar kartlarının altında, BU HAFTA defterinin üstünde (geçmiş, şimdi). Renkli sol çizgili satırlar; boşsa bölüm görünmez. Mobilde de var.
- **Eylem önizlemesi**: eylem düğmesinin üstüne gelince eylem panelinin iki satırlık açıklama alanında: 1. satır ad + "1 mesai · 5 servet · İz: dosyaya düşer · Tahmini risk: orta" (renkli); 2. satır seçili kişiye göre bağlam ya da kısa açıklama. Uzun açıklama ipucu balonunda kalır.

## Kapsam
MVP: yukarıdakiler. Sonraya: dosya eylemlerinin (sızdır/bastır/yok et) önizlemesi, özet satırına tıklayınca kişiyi seçme.

## Test
`sim_test.gd` (kayıt/yükleme ve hafta akışı), otomatik oynatma testleri (masaüstü/mobil/tam), `ui_shots` ile görsel kontrol. Mekanik değişmediği için denge sondajı gerekmez (yalnızca gösterim).
