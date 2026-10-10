# UI/UX denetimi (mobil + masaüstü)

Araç: `tests/ux_audit.gd` (pencereli). Her ekranı gezer, ekran görüntüsü alır, küçük dokunma hedeflerini, kırpılan düğmeleri, taşan metni ölçer.
`godot --path . --script res://tests/ux_audit.gd -- --out=KLASÖR [--mobile] [--lang=en]`

## Bulgular ve yapılanlar
| Sorun | Çözüm |
|---|---|
| Kişiler sekmesinde yalnızca alt kısım kayıyor, portre şeridi sabit | Grup sekmeleri, portre şeridi ve kişi bloğu TEK kaydırma sayfasında (`person_panel.gd`) |
| Mobilde dikey alan kıt (600 px) | Kenar boşlukları küçüldü; haber şeridi yalnızca Gündem'de görünür |
| Karar görseli ince bir şerit, metin küçük | Görsel kart yüksekliğini doldurur (kırpılarak), gövde metni büyüdü |
| Alt çubuktaki "Medya / N karar bekliyor" 31 px | 44 px dokunma hedefi |
| Ayarlarda onay kutuları 42 px, kaydırıcı tutamacı küçük | 44 px; altın yuvarlak tutamaç (dokunmaya uygun) |
| Masa'da "Gündemi aç" düğmesi 37 px | 46 px |
| Sekmeden bekleyen karar anlaşılmıyor | "Gündem · 3" rozeti |
| Yapılacak iş kalmadığında sonraki adım belli değil | Karar yok + mesai bitti → "Haftayı bitir" yumuşak nabız |
| Dokunmatikte ipucu (tooltip) yok | Uzun basışla ipucu balonu (`touch_scroll.gd`) |
| Düğmeye basarak kaydırma, düğmeye de basıyor | `touch_scroll.gd`: sürükleme düğmeyi iptal eder, kaydırır, atalet |
| İç içe çift çerçeve (Raporlar alt sekmeleri) | İç panel sade |
| Dil değişince arayüz eski dilde kalıyor | `main.rebuild_ui()`: dil değişince arayüz canlı yeniden kurulur |

## Ölçülü sonuç (mobil TR)
Küçük dokunma hedefi bulgusu 48 → 0 (kalanlar kaydırma alanı altında kırpılan düğmeler: beklenen).
