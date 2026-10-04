---
name: balance-check
description: Veloria'da denge, zorluk, baskın strateji, kayıp/ünvan çeşitliliği ve tempo sorunlarını ölçerek arar. Bot simülasyonları çalıştırır (görünür bilgiyle oynayan bot dahil) ve sayılarla rapor verir. "denge", "çok zor/kolay", "baskın strateji", "zorluk ayarı", "exploit", bir sistem değiştikten sonra kontrol gibi durumlarda kullan.
---

# Denge Kontrolü

Hiçbir denge yargısını hissiyatla verme: önce ölç. Proje dosyalarını değiştirmeden ölçülür.

## 1. Ölç
`.claude/skills/game-design/VELORIA.md` > Komutlar bölümündeki `$G` yolunu kullan. Komutları `timeout` ile çalıştır.
1. Mevcut testler: `sim_test.gd` (bot dengesi + sistem kontrolleri, `TEST: OK` olmalı) ve `pacing_test.gd` (olay/hafta, olaysız seri).
2. Bot sondajı: `.claude/skills/balance-check/probe_template.gd` dosyasını scratchpad'e kopyala, gerekirse botu/senaryoyu değiştir, çalıştır:
   `"$G" --headless --path . --script "<scratchpad>/probe.gd" -- --n=40 --all-diffs`
   Doğrudan şablonu çalıştırmak da güvenlidir (projeye yazmaz).
3. Belirli bir şüpheyi sına: ilgili eylemi tekrar eden ya da ilk hafta uygulayan küçük bir bot yaz (ör. "hafta 1'de X'i görevden al", "her hafta rüşvet", "hiç karar verme"). Bir istismar iddiasını sondajla kanıtlamadan rapora yazma.

## 2. Değerlendir (kontrol listesi)
- **Zorluk hedefleri** — ölçüt botu `advice_weighted` (ekrandaki meclis görüşlerini tartar; gerçek oyuncuya en yakın). `visible` görüşsüz zemin, `visible_wise` tavandır; `omniscient` hedef değildir. Bot listesi `--bots=a,b` ile daraltılabilir.
  Öneri hedefleri (advice_weighted): Kolay ≈ 70–85%, Normal ≈ 35–55%, Zor ≈ 15–30%. visible her seviyede advice_weighted'ın belirgin altında, visible_wise üstünde kalmalı. idle/random her seviyede ~0 kalmalı ama 15. haftadan önce ölmemeli.
- **Baskın strateji** — tek bir eylem/döngü diğerlerinden açıkça iyi mi? Eylem başına kazanç tekrarla azalıyor mu (rüşvet, terfi)? Bedelsiz eylem var mı?
- **Kayıp çeşitliliği** — darbe / saray darbesi / ayaklanma / yetkisiz / elit koalisyonu dağılımı. Tek tür %70'i geçiyorsa sorun.
- **Ünvan çeşitliliği** — kazananların ünvan dağılımı; tek ünvan baskınsa `_survivor_title` eşiklerini incele.
- **Tempo** — olay/hafta dilimleri (hedef: her dilimde ≥0.8), en uzun olaysız seri (hedef ≤4), ikinci yılın içeriği.
- **Ölüm zamanı** — ortalama düşüş haftası ve dağılımı; hep aynı haftada ölüyorsa sistem deterministik hissettirir.
- **Kopukluk** — hiç tetiklenmeyen olaylar (sim_test listeler), hiç kullanılmayan eylemler.

## 3. Rapor biçimi
1. Ölçüm tablosu (bot × zorluk: kazanma %, ort. hafta, kayıp türleri, ünvanlar).
2. Bulgular: önem sırasıyla, her biri **kanıt (sayı) → neden (kod: dosya:satır, formül) → öneri** biçiminde.
3. Öneriler: parametre değişikliği (sabit ve yeni değer) ya da mekanik değişiklik; beklenen etki.
4. Bir değişiklik uygulandıysa önce/sonra tablosu.

## Kurallar
- Parametre değiştirirsen yalnızca bir grup değiştir, sonra yeniden ölç (karışık değişiklikler yorumlanamaz).
- Zorluk parametreleri `Sim.DIFFICULTY` içinde; olay etkileri `events.json`'da; aktör başlangıçları `actors.json`'da.
- Dengeyi değiştiren her commit'in mesajına önce/sonra kazanma oranını yaz; `VELORIA.md` > "Ölçülmüş durum" tablosunu güncelle.
