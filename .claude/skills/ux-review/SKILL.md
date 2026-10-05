---
name: ux-review
description: Veloria'nın uygulanmış arayüzünü ekran görüntüsü alarak kalite kontrolünden geçirir (okunabilirlik, hiyerarşi, tutarlılık, taşma/kırpılma, mobil, web glifleri, tıklama yutan görünmez öğeler) ve önem sıralı bulgu listesi çıkarır. Arayüz değişikliğinden sonra, "arayüzü kontrol et", "UI amatör görünüyor mu", "UX review" isteklerinde kullan. Tasarım belgesini değil çalışan oyunu denetler.
---

# UX İncelemesi

Kendi gözünle doğrula: kodu okuyup "doğru görünüyordur" deme, ekran görüntüsüne bak.

## 1. Görüntü al
`.claude/skills/game-design/VELORIA.md` > Komutlar:
- Masaüstü: `"$G" --path . --script res://tests/ui_shots.gd -- --out=<scratchpad>/shots`
- Mobil: aynısı `--mobile` ile `<scratchpad>/shots_m` klasörüne.
- Yalnızca masa: `--only-desk`; masa+harita+medya: `--only-world`.
Görüntüler: `1_oyun` (seçili kişiyle), `1_masa`, `1_harita`, `1_medya`, `2_menu`, `3_menu_yeni`, `4_menu_ayarlar`, `5_son_0..4` (oyun sonu sekmeleri).
İncelenecek ekran listede yoksa `tests/ui_shots.gd`'ye bir adım ekle (dev ayarlarını yalnızca bellekte aç).
Her PNG'yi Read ile aç ve incele. Etkileşimli durumlar (hover, devre dışı) için gerekiyorsa betikte durumu kodla kur.

## 2. Kontrol listesi (her ekran için)
**Okunabilirlik ve hiyerarşi**
- 3 saniyede oyuncu ne yapacağını anlıyor mu? Birincil eylem tek ve belirgin mi (tek PrimaryButton)?
- Birincil bilgi büyük/kontrastlı, ikincil bilgi sönük mü? Gereksiz metin var mı?
- Metin kontrastı: koyu zeminde TEXT_DIM altı renk kullanılmış mı (okunmaz)?
**Taşma ve yerleşim**
- Kırpılan, üst üste binen, üç noktayla kesilen ama anlamı kaybolan metin.
- Kaydırma gerektiren ama kaydırılamayan alan; boş kalan büyük alanlar; hizasız kenarlar.
**Tutarlılık** (ux-design > "Veloria UI dili")
- Başlık bandı, köşebent, ayraç, bölüm başlığı, düğme türleri ekranlar arasında aynı mı?
- Palet dışı renk, farklı köşe yarıçapı, farklı yazı tipi.
**Mobil**
- Yazılar okunur mu (taban 1067×600'de ~14px altı sorun), dokunma hedefleri ≥44px mi, iki sütun sığıyor mu?
**Teknik tuzaklar**
- Web'de kutu çıkacak glif (◆ ⏳ → ✓ ✗ ★ vb.) kullanılmış mı: `LC_ALL=C.UTF-8 grep -nP "[\x{2190}-\x{2BFF}]" game/ui/*.gd` (çıktı yoksa temiz; `·` ve `»` güvenli).
- Görünmez (alfa 0) ama tıklama yakalayan Control: kodda `modulate.a = 0` olup `mouse_filter` IGNORE olmayanlar; editör açıksa Beckett `ui_snapshot` → `occluded_by`.
- Bildirim/overlay başka ekranın üstüne biniyor mu?
**Oyun tasarımı açısından**
- "Sayı yok" kuralı bozulmuş mu? Gösterge gizli bilgiyi fazla mı açıyor?
- Devre dışı düğmeler nedenini (tooltip) söylüyor mu?

## 3. Rapor
Önem sırasıyla tablo: **önem (kritik/yüksek/orta/düşük) · ekran · sorun · kanıt (görüntü adı + konum) · öneri (dosya/fonksiyon)**.
Kritik = yanlış bilgi, kullanılamaz kontrol, okunamaz metin. Sonunda 2–3 cümle genel izlenim (profesyonel/amatör görünen yönler).
Kullanıcı düzeltmeyi istediyse düzelt, aynı görüntüleri yeniden alıp önce/sonra karşılaştır.
