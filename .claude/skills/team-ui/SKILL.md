---
name: team-ui
description: Veloria'da bir arayüz özelliğini uçtan uca bir ekip gibi yürütür — tasarım (ux-design), uygulama, görsel doğrulama (ux-review), testler, belgeler ve commit. "şu ekranı yap", "arayüzü yenile", "HUD'a X ekle" gibi tasarım+uygulama gerektiren arayüz işlerinde kullan.
---

# Arayüz Ekibi (uçtan uca)

Sırayla dört rolü oynarsın. Her rol bitmeden bir sonrakine geçme.

## Rol 1 — UX Tasarımcısı
`ux-design` skill'ini uygula. Küçük işte spesifikasyonu kısa tut (oyuncu sorusu, yerleşim, durumlar, metinler, kabul ölçütleri).
Mevcut ekranın görüntüsünü al (önce durumu).

## Rol 2 — Geliştirici
- Önce ilgili kodu oku; var olan bileşeni (`UIKit`, `_section`, `_trait`, `band_style`, `ornament`, `divider`) yeniden kullan.
- Yerleşim/stil sabitlerini dağıtma: tekrar eden stil `ui_kit.gd`'ye.
- `main.gd` büyük bir dosya: yeni büyük bir bileşen ekleyeceksen ayrı dosyada (`game/ui/<bilesen>.gd`, `preload` ile) yaz.
- Kuralları koru: sayı yok, web glifi yok, görünmez tıklama yutucu yok, `_fast()`'a saygı, mobil `_fs()`.
- Otomatik oynatma testinin kullandığı adları/düğmeleri (`_end_btn`, `_decision_buttons`, `_buttons[...]`, `_desk`, `_city`, `_media`) bozma.

## Rol 3 — UX/QA
- `ux-review` skill'ini uygula (masaüstü + mobil görüntü). Kritik/yüksek bulguları düzelt, yeniden görüntü al.
- Testler (hepsi geçmeli):
  - `"$G" --headless --path . -- --autoplay`
  - `"$G" --headless --path . -- --autoplay --mobile`
  - `"$G" --headless --path . -- --autoplay --full` (oyun sonu ekranına dokunduysan)
  - Simülasyona dokunduysan `sim_test.gd`.

## Rol 4 — Teslim
- Belgeler: `docs/OYUNCU_REHBERI.md` (oyuncunun gördüğü değiştiyse), `docs/GELISTIRICI_REHBERI.md` (yeni araç/komut), `docs/DURUM_VE_YAPILACAKLAR.md` (yapılanlar/yapılacaklar).
- Commit: yalnızca kendi dosyaların; kullanıcının değişikliklerini katma (VELORIA.md > Tuzaklar). Push yok.
- Kullanıcıya kısa Türkçe özet: ne değişti, nasıl doğrulandı (test + görüntü), bilinen sınırlamalar.
