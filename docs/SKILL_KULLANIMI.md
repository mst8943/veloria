# Skill'ler nasıl kullanılır?

Veloria'ya özel 11 skill `.claude/skills/` klasöründe. Her biri Claude'a bu projede belirli bir işi nasıl yapacağını anlatan hazır bir çalışma talimatı.

## Çağırmanın iki yolu

**1. Doğrudan komutla:** Mesajın başına `/` ve skill adını yaz, ardından ne istediğini ekle.

```
/balance-check Zor seviye çok mu zor?
/design-system darbe sistemini baştan tasarla
/asset-spec art klasörüne yeni bir görsel attım, yerleştir
```

**2. Doğal dille:** Skill adını bilmen gerekmez. "Denge nasıl?", "bu ekranı kontrol et", "yeni olay görseli lazım" gibi yazdığında Claude uygun skill'i kendisi seçer. Belirli bir yöntem istiyorsan komutla çağırmak daha garantilidir.

Yeni eklenen ya da değiştirilen skill'ler oturum başında yüklenir. Listede görünmüyorsa yeni bir oturum aç.

## Hangi iş için hangisi?

| Ne istiyorsun? | Skill | Ne üretir? |
|---|---|---|
| Aklına bir özellik geldi, oyuna değer mi? | `/game-design` | Kısa tasarım notu: oyuncu kararı, riskler, en küçük sürüm, uygulama planı |
| Tek bir sistemi (darbe, sırlar, ekonomi, sözler…) derinlemesine tasarlamak | `/design-system` | `docs/design/<sistem>.md`: kurallar, formüller, etkileşimler, denge hedefleri |
| Yazılmış bir tasarımı ya da olay paketini eleştirmek | `/design-review` | Onay / değişiklikle onay / yeniden tasarım kararı ve en önemli 3 sorun |
| Oyun çok mu zor, kolay mı, bir hile var mı? | `/balance-check` | Bot simülasyonu tablosu (kazanma %, kayıp türleri, ünvanlar, tempo) ve öneriler |
| Bir ekranı ya da HUD öğesini tasarlamak | `/ux-design` | `docs/ux/<ekran>.md`: yerleşim çizimi, durumlar, metinler |
| Arayüz amatör mü görünüyor, bir şey bozuk mu? | `/ux-review` | Ekran görüntülerine dayanan, önem sırasına dizilmiş bulgu listesi |
| Bir arayüz işini baştan sona bitirmek | `/team-ui` | Tasarım → kod → görsel kontrol → testler → belge → commit |
| Görsel kimliği belgelemek, tutarsız görselleri bulmak | `/art-bible` | `docs/ART_BIBLE.md` |
| Yeni görsel lazım ya da attığın görseli yerleştirmek | `/asset-spec` | Prompt + teknik özellik; gelen görseli tanıyıp doğru ada taşır, içe aktarma ayarlarını yapar |
| Kod sağlığı, yeniden düzenleme | `/tech-debt` | `docs/TECH_DEBT.md`: ölçümler, öncelik sırası, güvenli plan |
| Proje hangi aşamada, yayına ne kaldı? | `/project-stage-detect` | Aşama tespiti (prototip / dikey dilim / alfa / beta), eksik listesi |
| Yapılan kod değişikliklerini incelemek | `/code-review` | Claude Code'un yerleşik komutu |

## Önerilen iş akışları

**Yeni bir oyun sistemi**
1. `/game-design <fikir>`: değer mi, kapsamı ne?
2. `/design-system <sistem>`: ayrıntılı tasarım belgesi.
3. `/design-review docs/design/<sistem>.md`: uygulamadan önce eleştiri.
4. Uygulama ("şimdi uygula").
5. `/balance-check`: önce ve sonra ölçüm.

**Arayüz işi**
- Tek komutla: `/team-ui <iş>`
- Adım adım: `/ux-design` → uygulama → `/ux-review`

**Görsel üretimi**
1. `/asset-spec <ne lazım>`: prompt alırsın.
2. Görseli ChatGPT'de üretip `art/` klasörüne istediğin adla at.
3. `/asset-spec yeni görseli yerleştir`: adlandırma, içe aktarma ayarı ve ekranda kontrol yapılır.

**Durum kontrolü**
- `/project-stage-detect`, ardından önerdiği skill'ler.

## İpuçları
- Skill'lere bağlam ver: "Normal seviyede, ilk 30 hafta", "mobil görünüm de olsun" gibi.
- Bütün skill'lerin ortak bilgi kaynağı `.claude/skills/game-design/VELORIA.md`. Proje değişince (yeni dosya, yeni komut, yeni ölçüm) önce burası güncellenmeli. Bunu Claude'dan da isteyebilirsin.
- Skill'ler düz metin (`SKILL.md`). İstediğin gibi düzenleyebilir ya da yenisini ekleyebilirsin: `.claude/skills/<ad>/SKILL.md`, en üstte `name` ve `description` bulunmalı.
- Denge kararlarında ölçüt, ekranda görünen bilgiyle oynayan bottur. Gizli değerleri okuyan bot gerçek oyuncuyu temsil etmez.
