---
name: project-stage-detect
description: Veloria'nın hangi geliştirme aşamasında olduğunu (prototip / dikey dilim / alfa / beta / yayına hazır) ölçülebilir ölçütlerle belirler; içerik sayımı, test sonuçları, tasarım belgesine göre eksikler ve bir sonraki aşamaya geçiş için gerekenleri raporlar. "proje ne durumda", "hangi aşamadayız", "yayına ne kadar kaldı", "durum raporu" isteklerinde kullan. Kod değiştirmez.
---

# Proje Aşaması Tespiti

## 1. Topla (hiçbir dosyayı değiştirmeden)
- Devir notu: `docs/DURUM_VE_YAPILACAKLAR.md`, son commit'ler (`git log --oneline -15`), çalışma ağacı (`git status --short`).
- İçerik sayımı (python ile `game/data/*.json`): olay sayısı, `min_week` dağılımı (çeyrek yıllara göre), zincir olay sayısı (`needs_flag`/`flag_age`), olay görseli kapsaması (`art/events`), aktör sayısı, rapor cümlesi varyantları (`PHRASES`), ünvan ve başarım sayısı.
- Testler: `sim_test.gd`, `pacing_test.gd`, `--autoplay`, `--autoplay --full`; `balance-check/probe_template.gd` sonuç tablosu.
- Platform: `export_presets.cfg` ön ayarları, `dist/release` içeriği.
- Tasarım belgesi kapsaması: `VELORIA — Oyun Tasarım Özeti.md` başlıkları (`grep -n "^#"`) → her bölüm için Var / Kısmi / Yok (kanıt: dosya/fonksiyon).

## 2. Aşama ölçütleri
| Aşama | Ölçüt |
|---|---|
| Prototip | Çekirdek döngü oynanır, içerik yer tutucu |
| Dikey dilim | Döngü baştan sona, gerçek görsel/ses kalitesi bir dilimde, oyun sonu var |
| Alfa | Tüm ana sistemler var (belgenin çekirdek bölümleri), içerik eksik olabilir, denge kaba |
| Beta | İçerik tam (iki yıl boyunca tempo), denge hedeflerde, kritik hata yok, oyuncu testinden geçti |
| Yayına hazır | Cila (ses, erişilebilirlik, ayarlar), kayıt uyumluluğu/sürümleme, platform build'leri denenmiş, mağaza materyali |
Her ölçüt için: sağlanıyor / kısmen / hayır + kanıt.

## 3. Rapor
1. **Aşama** (tek kelime) ve gerekçe (3–5 madde, sayılarla).
2. **Ölçüm tablosu** (içerik, testler, denge, platform).
3. **Belge kapsaması** (Var/Kısmi/Yok tablosu).
4. **Bir sonraki aşamaya geçiş için gerekenler**, öncelik sırasıyla, her biri için hangi skill'in kullanılacağı (design-system, balance-check, ux-design, asset-spec, tech-debt…).
5. Yalnızca kullanıcının yapabileceği şeyler (oyun testi, görsel üretimi, yedek depo).
