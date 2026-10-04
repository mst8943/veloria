---
name: design-review
description: Veloria için yazılmış bir tasarım önerisini, GDD'yi, olay paketini ya da özellik planını eleştirel bir kıdemli tasarımcı gözüyle inceler (ilkelere uyum, oyuncu kararı, istismar, denge, kapsam, sistem etkileşimleri). "bu tasarımı incele", "plan mantıklı mı", "olayları gözden geçir", "GDD review" isteklerinde kullan. Kodu değil tasarımı inceler; kod için code-review, arayüz için ux-review.
---

# Tasarım İncelemesi

Nazik ama net ol: amaç onaylamak değil, zayıf noktayı uygulamadan önce bulmak.

## Bağlam
`.claude/skills/game-design/VELORIA.md` (ilkeler, mevcut sistemler, ölçülmüş denge) ve incelenen belge.
Belge mevcut bir sisteme dokunuyorsa ilgili kodu oku: belge kodla çelişiyor mu?

## İnceleme eksenleri (her biri: Güçlü / Sorun / Öneri)
1. **Oyuncu kararı** — Gerçek bir ikilem var mı? Bariz doğru seçenek var mı? Seçeneklerin bedelleri farklı eksenlerde mi (kısa vade vs. uzun vade, güç vs. iz)?
2. **İlkeler** — Belirsiz bilgi (körlük değil), her gücün bedeli, insanlar > rakamlar, dünya beklemez, ortak bilgi, başarısızlık hikâyedir.
3. **Okunabilirlik** — Oyuncu bu sistemi nasıl öğrenir? Geri bildirim ne zaman ve nerede? Sonuç adil hissettirir mi?
4. **Etkileşimler** — Sırlar, kaskad/darbe, sözler, raporlar, basın, servet, olaylar: istenmeyen geri besleme döngüsü (kartopu) var mı?
5. **İstismar** — Tekrarla sonsuz kazanç, bedelsiz eylem, ilk hafta hilesi, kayıt/yükleme ile kaçış, aktör çıkarma uç durumları.
6. **Denge ve tempo** — Erken/orta/geç oyunda etkisi; balance-check hedeflerine (görünür bilgi botu) etkisi tahmini; ölçüm planı var mı?
7. **Kapsam** — En küçük değerli sürüm net mi? Gereksiz karmaşıklık (CLAUDE.md kural 9)? İçerik maliyeti (olay, metin, görsel sayısı)?
8. **Tekrar oynanabilirlik** — Her kampanyada farklı mı oynanıyor, yoksa ezberlenebilir mi?
9. **Uygulanabilirlik** — Veri şeması (`events.json` alanları), kayıt uyumluluğu, test edilebilirlik.

## Olay paketi incelerken ek kontroller
- Şema: zorunlu alanlar, `ignore` var mı, bayrak adları zincirle uyumlu mu (`<id>_<index>`), `alive` aktörleri var mı.
- Her seçenek farklı bir değer sistemine hitap ediyor mu; bir seçenek diğerlerini her koşulda geçiyor mu (fx karşılaştır)?
- Metin: Türkçe, kısa, karakter sesinde, oyuncuya doğrudan gizli sayıyı söylemiyor.
- Zamanlama: `min_week` dağılımı ikinci yılı besliyor mu?

## Çıktı
1. Kararlar: **Onay / Değişiklikle onay / Yeniden tasarım**.
2. En önemli 3 sorun (kanıt + öneri).
3. Eksen bazında kısa notlar.
4. Açık sorular.
