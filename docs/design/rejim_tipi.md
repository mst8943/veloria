# Rejim tipi ve final tehdidi — Faz 3 tasarımı

Tarih: 2026-10-06. Kaynak: Tasarım Özeti §20–22; `docs/design/ikinci_yil.md`.

## Oyuncuya görünen sonuç
60. haftadan sonra yönetim tarzı bir kez adlandırılır. Haber satırı ve “Geçen haftadan beri” özeti bunu siyasi yorum olarak söyler; gizli gücü, borcu, sadakati ya da kesin darbe olasılığını göstermez. Etiket kayda girer ve saltanat boyunca sabit kalır. Oyun sonunda Özet, rejimin adını ve onu sınayan güç merkezini söyler; sağ kalan hükümdarın ünvanına “... Rejimi” eklenir. Kaybeden “Devrilen Kral” ünvanını korur, rejimi Özet'te görünür.

## Altı tip ve karşısındaki hesaplaşma

| Tip | Oyuncunun bildiği belirti | Final tehdidinin yüzü |
|---|---|---|
| Güvenlikçi | yazılı emir, bastırma, operasyon | Ordu komutasının muhtırası |
| Popülist | sokakla uzlaşma, muhalefetle açık temas | Meydanın ve Brandt'ın kuşatması |
| Patronajcı | terfi, söz ve kişisel lütuf | Dorn'un dağıttığı makamların hesabı |
| Oligarklara dayanan | gizli ödemeler, Halden'e açılan alan | Sermaye ve meclis kuşatması |
| Medya kontrollü | basın/kanal lehine kararlar, yayın bayrakları | Yayınların desteği çekmesi |
| İstihbarat merkezli | araştırma, şantaj, dosya, gizli operasyon | Voss'un arşiv muhtırası |

## Hesap
Hafta 60'ta altı adayın ağırlığı `Sim.stats`, oyuncunun verdiği karar bayrakları, görünür güç kademeleri ve açık söz/borç kayıtlarından hesaplanır. Ham gizli `power`, `obligation` veya `loyalty` eşik olarak gösterilmez; güç yalnızca kişinin kartındaki kademeye yuvarlanır. Böylece etiket oyuncunun zaten yaptığı ve gördüğü şeylerin yorumu olur. İstatistikler ağırlıklı ve üst sınırla toplanır; tek bir spam eylemi bütün kampanyayı tanımlamaz. Eşitlikte sabit sıra kullanılır, RNG tüketilmez. Bir kez seçildikten sonra tekrar hesaplanmaz; eski kayıtlar için göçte hafta 60+ ise bilinen geçmişten yeniden hesaplanır, haber tekrar gösterilmez.

## Hesaplaşma motoru
80–100. haftalar arasında yalnızca seçilen tipe ait bir hesaplaşma kartı açılır. Kart mevcut güçlü merkezin meydan okumasını **gösterir**, darbe gücü veya hırs üretmez. Seçenekler siyasi karşılık ve küçük bedeller taşır; mevcut darbe/sokak/mahkeme krizleri aynen karar verir. Kartın bayrağı final kaydında hangi tehdidin yaşandığını belirtir. Mevcut ikinci yıl hesaplaşma olayları genel dünyayı anlatmaya devam edebilir; seçilen rejim kartı onların yerine gizli bir ikinci kazanma/kaybetme kuralı kurmaz.

## Kayıt ve doğrulama
Yeni `regime` alanı için `SAVE_VERSION` 4 olur; `_migrate_save` 3→4 adımı ve `tests/save_test.gd` v3 taklidi eklenir. Yüklenen kampanyada haber tekrarlanmaz. Altı tipin her biri yapay geçmişle erişilebilir ve doğru tek final kartı seçilir. `event_check`, `sim_test`, `save_test`, otomatik oynatma ve iki ayrı 80 kampanyalık denge sondajı geçer. Oyun sonu Özet ekran görüntüsüyle doğrulanır.
