# Canlılık ölçümü — gece görevi

Ölçüm: PIL `ImageStat` ile RGB'den HSV'ye çevrilen PNG'lerin kanal ortalaması (S ve V, 0–100%). Her çift aynı Godot ekran görüntüsü durumudur; masaüstü 1600×900, mobil 1067×600. `tools/gece_hsv.py` değerleri yeniden üretir.

## Masaüstü — Türkçe

Önce: `C:/Users/USER/Desktop/oyun_gece_s2_before_tr_desktop/`  
Sonra: `C:/Users/USER/Desktop/oyun_gece_s2_after_tr_desktop/`

| Ekran | S önce → sonra | S değişimi | V önce → sonra | V değişimi |
|---|---:|---:|---:|---:|
| Menü | 35.49 → 47.57 | +34.1% | 13.06 → 14.93 | +14.3% |
| Gündem / karar | 38.56 → 46.97 | +21.8% | 14.60 → 15.30 | +4.8% |
| Masa | 55.03 → 62.96 | +14.4% | 11.98 → 12.97 | +8.2% |
| Medya | 21.45 → 25.92 | +20.9% | 45.83 → 47.73 | +4.1% |
| Harita | 35.70 → 43.93 | +23.1% | 20.95 → 22.64 | +8.0% |
| Oyun sonu | 21.18 → 27.38 | +29.3% | 11.10 → 11.80 | +6.3% |
| **Ekran ortalaması** | **34.57 → 42.46** | **+23.9%** | **19.59 → 20.89** | **+7.6%** |

## Mobil — Türkçe

Önce: `C:/Users/USER/Desktop/oyun_gece_s2_before_tr_mobile/`  
Sonra: `C:/Users/USER/Desktop/oyun_gece_s2_after_tr_mobile/`

| Ekran | S önce → sonra | S değişimi | V önce → sonra | V değişimi |
|---|---:|---:|---:|---:|
| Menü | 33.36 → 43.17 | +29.4% | 11.21 → 12.30 | +9.7% |
| Gündem / karar | 37.21 → 47.53 | +27.7% | 14.33 → 15.55 | +8.5% |
| Masa | 52.87 → 60.78 | +15.0% | 11.85 → 13.07 | +10.3% |
| Medya | 20.57 → 26.40 | +28.3% | 54.69 → 57.06 | +4.3% |
| Harita | 34.08 → 41.98 | +23.2% | 18.85 → 20.42 | +8.3% |
| Oyun sonu | 22.48 → 30.51 | +35.7% | 14.14 → 15.41 | +9.0% |
| **Ekran ortalaması** | **33.43 → 41.73** | **+26.6%** | **20.84 → 22.30** | **+8.4%** |

İki çözünürlükte birleşik ekran ortalaması: S **+25.3%**, V **+8.0%**. Doygunluk/parlaklık hedefi karşılandı.

## Uygulama ve gözle kontrol

- Tek, en üst CanvasLayer renk derecelendirmesi kullanıldı: doygunluk 1.30, kontrast 1.00, parlaklık 1.03. Yeni ayar/anahtar veya renk eklenmedi; mevcut koyu-altın palet ve görseller korunuyor.
- Okunabilirlik için mevcut paletin DANGER rengi `#d8736b`, GOLD_DIM rengi `#a98e50` oldu. Bu iki rengin HOVER zemini üstündeki kaynak palet kontrastı sırasıyla 4.65:1 ve 4.71:1; TEXT_DIM 4.97:1, TEXT 11.68:1. Renk derecelendirmesi kırmızı-yeşil anlam ayrımını değiştirmedi.
- Önce/sonra klasörlerindeki PNG'ler masaüstü ve mobil temas sayfalarında açıldı; tam boy Gündem, medya, harita ve oyun sonu kareleri ayrıca incelendi. Karar metni/seçenekleri, haber ve medya gövdesi, harita etiketleri okunuyor; düşman kırmızısı ve olumlu yeşil ayırt ediliyor. Oyun sonu Özeti kendi kaydırma alanında sürer; ekran görüntüsünde alt satırların tamamı görünmeyebilir.
