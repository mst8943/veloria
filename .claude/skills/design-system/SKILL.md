---
name: design-system
description: Veloria'nın tek bir oyun sistemini (darbe/kaskad, sırlar ve ortak bilgi, söz defteri, servet/ekonomi, raporlar ve yalan, basın, patronaj, devlet kapasitesi vb.) profesyonel GDD seviyesinde tasarlar ve docs/design/ altına yazar. "X sistemini tasarla", "darbe sistemini baştan düşün", "ekonomi GDD" gibi isteklerde kullan.
---

# Sistem Tasarımı (GDD)

Tek bir sistemi, kodlanabilecek kesinlikte tasarla. Çıktı: `docs/design/<sistem-adi>.md` (yoksa klasörü oluştur).

## Hazırlık
1. `.claude/skills/game-design/VELORIA.md` oku.
2. Sistemin **şu anki** halini koddan çıkar: `sim.gd` içindeki fonksiyonlar, sabitler, formüller; `actor.gd` alanları; ilgili olaylar (`events.json` içinde `grep`). Formülleri olduğu gibi alıntıla (dosya:satır).
3. Tasarım özetindeki ilgili bölümü oku; belge ile kod arasındaki farkları listele.
4. Gerekirse proje dışı sondaj betiğiyle (VELORIA.md > Komutlar) mevcut davranışı ölç: tetiklenme sıklığı, ortalama hafta, dağılım.

## GDD şablonu
1. **Amaç ve oyuncu fantezisi** — sistem oyunda neden var, hangi gerilimi üretiyor.
2. **Mevcut durum** — kod özeti, ölçümler, belgeyle farklar, sorunlar.
3. **Oyuncu kararları** — her karar: seçenekler, kısa vadeli kazanç, uzun vadeli bedel.
4. **Kurallar ve durum** — veri alanları (yeni/değişen), durum makinesi (ör. darbe: tohum → işaret → gerilim → kriz → sonuç → artçı), haftalık tick sırası içindeki yeri.
5. **Formüller** — açık formül + parametre tablosu (varsayılan, aralık, zorluk çarpanı). Sihirli sayı bırakma.
6. **Bilgi tasarımı** — oyuncu neyi, hangi gürültüyle, nereden görür (rapor cümlesi, kart sinyali, basın, dosya). Gerçek değer ne zaman açığa çıkar (Hakikat Dosyası).
7. **Etkileşimler** — diğer sistemlerle giriş/çıkış matrisi (sırlar, kaskad, sözler, raporlar, basın, servet, olaylar).
8. **İçerik ihtiyacı** — yeni olaylar (şemaya uygun taslak), rapor cümleleri (`PHRASES` biçimi), görseller (asset-spec'e devret).
9. **Arayüz** — hangi ekran, hangi bileşen, tooltip metinleri; ux-design'a devredilecek noktalar.
10. **İstismarlar ve uç durumlar** — tekrar, sıfır maliyet, aktör ölümü/görevden alma, kayıt/yükleme, zorluk.
11. **Denge hedefleri** — ölçülebilir hedef (kazanma oranı, ortalama düşüş haftası, kayıp türü dağılımı, olay/hafta) ve hangi botla ölçüleceği.
12. **Uygulama planı** — adım adım, dosya bazında; kayıt uyumluluğu (yeni alanlar `SAVE_PROPS`/`save_game`'e, eski kayıtta varsayılan); test planı.
13. **Açık sorular** — kullanıcıya bırakılan kararlar.

## Kurallar
- "Sayı göstermeme" ilkesini koru; sezdirme yollarını tasarla.
- Her güç aracının bir izi/bedeli olsun.
- Tek bir baskın strateji yaratma; denge hedefini görünür bilgiyle oynayan bota göre koy (gizli değer okuyan bot yanıltıcıdır).
- Belgeyi yazınca kullanıcıya 5–8 satırlık özet ver; uygulamaya geçmeden önce açık soruları sor.
