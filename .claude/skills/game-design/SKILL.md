---
name: game-design
description: Veloria için yeni bir özellik, mekanik ya da içerik fikrini kodlamadan önce oyun tasarımcısı gözüyle değerlendirir ve kısa uygulama planı çıkarır. "şunu ekleyelim", "yeni özellik", "bu mekanik nasıl olmalı", "oyuna X sistemi" gibi isteklerde ilk adım olarak kullan. Tek bir sistemi derin GDD seviyesinde yazmak için design-system skill'ini kullan.
---

# Oyun Tasarımı (giriş noktası)

Kıdemli bir strateji/simülasyon tasarımcısı gibi çalış. Amaç: kod yazmadan önce fikrin oyuna ne kattığını netleştirmek.

## 1. Bağlamı yükle
- `.claude/skills/game-design/VELORIA.md` (mimari, ilkeler, şema, komutlar) — her zaman oku.
- `docs/DURUM_VE_YAPILACAKLAR.md` (güncel durum ve sıradaki işler).
- İlgili bölüm: `VELORIA — Oyun Tasarım Özeti.md` (başlıkları `grep -n "^#"` ile bul, yalnızca ilgili bölümü oku).
- Fikrin dokunduğu kodu oku (`sim.gd` içinde ilgili fonksiyon, `events.json`'da benzer olaylar). Var olan bir sistemi yeniden icat etme.

## 2. Tasarım soruları (CLAUDE.md) — her birine tek cümleyle cevap ver
1. Oyuncuya ne kazandırıyor?
2. Oyuncunun hangi **kararı** vermesini sağlıyor? (Karar yoksa özellik değil süs.)
3. Eğlenceli tarafı ne? Gerilim nereden geliyor?
4. Stratejik derinlik: en az iki makul seçenek ve bir bedel var mı?
5. Arayüzde nasıl okunur? "Sayı yok" kuralı ile nasıl hissettirilir?
6. Diğer sistemlerle etkileşimi: sırlar/ortak bilgi, kaskad/darbe, söz defteri, raporlar, basın, servet.
7. Kötüye kullanılabilir mi? (Sınırsız tekrar, bedelsiz güç, tek baskın strateji.)
8. Erken / orta / geç oyunda (hafta 1–30 / 30–70 / 70–104) dengeli mi?

## 3. Veloria ilkelerine karşı kontrol
VELORIA.md'deki 6 ilkenin her biri için: destekliyor / nötr / çelişiyor. Çelişiyorsa tasarımı değiştir ya da açıkça gerekçelendir.

## 4. Çıktı
Kısa bir tasarım notu (Türkçe):
- **Özet** (2–3 cümle) ve **oyuncu fantezisi** ("kendimi … gibi hissediyorum").
- **Kurallar**: girdiler, etkiler, bedeller (hangi `Sim` alanları, hangi yeni veri).
- **Arayüz yüzeyi**: hangi ekranda, hangi bilgiyle; tooltip metni.
- **Riskler ve istismarlar**, karşı önlem.
- **Kapsam**: en küçük değerli sürüm (MVP) + sonraya kalanlar.
- **Uygulama planı**: dosya bazında adımlar, test planı (hangi test/sondaj neyi kanıtlayacak).
- **Ölçüt**: bittiğini nasıl anlarız (ör. görünür bilgi botunda kazanma oranı, olay/hafta).

Büyük özellikte önce bu notu kullanıcıya sun; küçük ve net işlerde notu kısa tutup uygula (kullanıcı tercihi: sormadan ilerle, sonunda kısa Türkçe özet).
Uygulamadan sonra `balance-check` (sistem değiştiyse) ve `ux-review` (arayüz değiştiyse) çalıştır.
