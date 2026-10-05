---
name: tech-debt
description: Veloria kod tabanındaki teknik borçları (main.gd ve sim.gd'nin büyüklüğü, karışık sorumluluklar, kayıt sürümlemesi, veri doğrulama, gereksiz yeniden çizim, test kodunun üretim kodunda olması vb.) ölçer, risk/çaba ile önceliklendirir ve güvenli bir azaltma planı çıkarır ya da uygular. "teknik borç", "refactor", "main.gd çok büyük", "kod mimarisi", "kayıt sistemi riskli" isteklerinde kullan.
---

# Teknik Borç

## 1. Ölç (her seferinde güncel sayılarla)
- Boyut: `wc -l game/core/*.gd game/ui/*.gd | sort -n`
- Fonksiyon sayısı/uzunluğu: `grep -c "^func " <dosya>`; en uzun fonksiyonları bul (iki `^func` arası satır farkı).
- Tekrar: aynı stil/yardımcı kodun kopyaları (`grep -n "StyleBoxFlat.new()" game/ui/*.gd | wc -l`).
- Test kapsamı: hangi sistemlerin `sim_test.gd`/autoplay ile sınandığı.

## 2. Bilinen borç envanteri (doğrula, güncelle)
| # | Borç | Risk | Belirti/yer |
|---|---|---|---|
| 1 | `main.gd` ~2600 satır: ana ekran, menü, oyun sonu, akış, otomatik oynatma testi tek dosyada | Değişiklik maliyeti, çakışma, hata | `_build_ui`, `_build_menu`, `_build_end`, `_autoplay*` |
| 2 | `sim.gd` kurallar + içerik (`PHRASES`) + kayıt + başarımlar + tarihçiler bir arada | İçerik eklemek kod düzenlemek demek | `PHRASES`, `ACHIEVEMENTS`, `historians` |
| 3 | Kayıtta sürüm alanı yok; göç (migration) yok; bekleyen olaylar tam metniyle kayda gömülü | Güncellemeden sonra eski kayıt bozulur/eskir | `save_game`, `load_game` |
| 4 | Olay verisi doğrulanmıyor; `_bump` bilinmeyen alanı `set()` ile yazar | Yazım hatası sessiz hata | `_apply_effects`, `_bump` |
| 5 | Her `Sim.changed` sinyalinde gündem/kartlar/dosyalar baştan kuruluyor | Performans, animasyon sıçraması | `main.gd::_refresh` |
| 6 | Kullanıcı dosyaları `str_to_var` ile okunuyor | Bozuk dosya/güvenlik; JSON daha güvenli | kayıt, arşiv, başarımlar |
| 7 | Otomatik oynatma (test) kodu üretim betiğinde | Gereksiz kod, karışıklık | `main.gd::_autoplay*` |
| 8 | Metinler kodda sabit, `tr()` yok | Yerelleştirme pahalı | tüm UI ve `sim.gd` |
| 9 | Proje Beckett eklentisinin deposunda; README/LICENSE/bazı testler ona ait; uzakta yedek yok | Veri kaybı, karışık geçmiş | `git remote -v` |
| 10 | Ses tamamen kodla sentezleniyor | Kalite (teknik değil ürün borcu) | `sfx.gd` |

## 3. Önceliklendir
Her madde için **etki (1–3) × olasılık (1–3)** ve **çaba (S/M/L)**. Önce yüksek risk + düşük çaba (ör. kayıt sürümü, olay doğrulayıcı, yedek depo), sonra dokunulan yerde aşamalı bölme (ör. `main.gd`'den `end_screen.gd`, `menu.gd`, `person_panel.gd`).

## 4. Güvenli azaltma kuralları
- **Davranışı değiştirme**: refactor ile özellik değişikliğini aynı commit'e koyma.
- Her adımdan sonra: `sim_test.gd` (TEST: OK), `--autoplay`, `--autoplay --mobile`, `--autoplay --full`, `ui_shots.gd` görüntüleri önce/sonra aynı.
- `class_name` kullanma, `preload` kullan. Otomatik oynatmanın eriştiği alan adlarını koru ya da testi birlikte güncelle.
- Kayıt biçimini değiştirirsen: `version` alanı ekle, eski sürümü yükleyen göç fonksiyonu yaz, eski bir kayıt dosyasıyla test et.
- Bir dosyayı bölerken önce saf taşıma (kopyala-yapıştır + bağlantı), sonra iyileştirme.

## Çıktı
`docs/TECH_DEBT.md`: ölçümler, önceliklendirilmiş tablo, önerilen sıra ve her adımın doğrulama yöntemi. Uygulama istendiyse en yüksek öncelikli 1–2 maddeyi yap, testleri çalıştır, kısa özet ver.
