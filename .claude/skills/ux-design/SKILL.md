---
name: ux-design
description: Veloria için bir ekran, HUD öğesi, panel ya da oyuncu akışı tasarlar (bilgi hiyerarşisi, yerleşim, durumlar, tooltip metinleri, mobil düzen) ve uygulanabilir bir UI spesifikasyonu çıkarır. "ekranı tasarla", "HUD", "bu bilgi nerede görünmeli", "akış", "menü düzeni", "panel" gibi isteklerde kullan. Uygulanmış arayüzü denetlemek için ux-review kullan.
---

# UX Tasarımı

Profesyonel PC strateji oyunları seviyesinde düşün (Crusader Kings, Suzerain, Frostpunk, Papers, Please'in okunabilirliği).

## Bağlam
- `.claude/skills/game-design/VELORIA.md` (mimari, tuzaklar).
- `docs/ARAYUZ_PLANI.md` (diegetik yön: masa / başkent / medya).
- İlgili kod: ekran `game/ui/*.gd`; ortak bileşenler `game/ui/ui_kit.gd`.
- Mevcut hali gör: `tests/ui_shots.gd` ile ekran görüntüsü al ve oku (VELORIA.md > Komutlar).

## Veloria UI dili (uyulacak sistem)
- **Palet** (`UIKit`): BG `0e0c0a`, PANEL `171511`, PANEL_HI `221e18`, HOVER `2c271e`, SHADE (örtü), PLATE (pencere zemini), GOLD `d6b25e`, GOLD_DIM `8f7a45`, TEXT `e9e4d6`, TEXT_DIM `9a958a`, DANGER `c0504a`, OK `7fae7a`. Nötrler sıcak (mor/mavi kayma yok). Köşe en fazla `UIKit.RADIUS` (3 px). Yeni renk ekleme; gerekiyorsa UIKit'e sabit olarak ekle. Ayrıntı: `docs/ux/gorsel_dil_v2.md`.
- **Tipografi**: başlık/ad `UIKit.serif()` (EB Garamond); bölüm başlığı `UIKit.caps()` aralıklı büyük harf; gövde varsayılan sans. Türkçe büyük harf için `UIKit.tr_upper()`.
- **İmza öğeler**: ekran başlık bandı `UIKit.band_style()`; önemli panelde `UIKit.ornament()` köşebentleri; ekran başlığı altında `UIKit.divider()`; bölüm başlığı `main.gd::_section(başlık, açıklama)`.
- **Düğme hiyerarşisi**: `PrimaryButton` (ekranda bir tane: ana eylem), varsayılan Button, `ChoiceButton` (karar seçenekleri), `GhostButton` (gezinme), `DangerButton` (geri dönüşsüz/zarar veren).
- **Bilgi kuralı**: Sayı yok. Seviye/kademe (3 nokta), renk, ifade ve "?" ile sezdir. Yeni gösterge oyuncuya eskisinden fazla gizli bilgi vermemeli.
- **Glif kuralı**: Web'de sembol glifleri kutu çıkar; ok, onay, elmas gibi şekilleri çiz.
- **Mobil**: yatay 1067×600 taban; `main.gd::_fs()` ile yazı ×1.22; dokunma hedefi ≥44px; yan yana sığmayan iki sütun mobilde sekmeye döner.

## Süreç
1. **Oyuncu sorusu**: Bu ekranda oyuncu hangi soruya cevap arıyor ve hangi kararı verecek? (En fazla 3 soru.)
2. **Bilgi envanteri**: gösterilecek her veri için kaynak (`Sim` alanı/fonksiyonu), doğruluk (gerçek/rapor/tahmin), önem (birincil/ikincil/talep üzerine).
3. **Hiyerarşi**: birincil bilgi bir bakışta (konum, boyut, renk), ikincil hover/tooltip'te, ayrıntı tıklamada.
4. **Yerleşim**: ASCII tel çerçeve (masaüstü 1600×900 ve mobil 1067×600), bileşen adlarıyla.
5. **Durumlar**: boş, normal, uyarı/acil, devre dışı (neden? tooltip), yükleme/animasyon, hata. Her biri için metin.
6. **Etkileşim**: tıklama/hover/klavye kısayolu; geri dönüş (Esc); ses (`Sfx.play`); animasyon (UIKit `fade_in/pop_in/pulse`, kısa geçişler ayarına saygı: `_fast()`).
7. **Metinler**: tüm etiket ve tooltip metinleri Türkçe, kısa, oyun sesinde; ek uyumu için `Sim.ek(isim, "e"|"in")`.
8. **Uygulama notları**: hangi dosyada hangi fonksiyon; mevcut bileşen yeniden kullanımı; tıklama yutabilecek görünmez Control riski.

## Çıktı
`docs/ux/<ekran>.md` (ya da küçük işlerde doğrudan cevap): oyuncu soruları, bilgi envanteri tablosu, tel çerçeveler, durumlar, metinler, uygulama notları, kabul ölçütleri (ux-review'un kontrol edeceği maddeler).
