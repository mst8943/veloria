# Teknik borç

## Yeni Kadro sonrası

- Dış ilişki ve veliaht final çizgileri eski kayıtlar için güvenli varsayılan kullanır; geçmiş çizelgelerde ayrıntılı veri yoktur.
- `ui_shots.gd --state` yapay final durumları kurar; gerçek oyuncu akışını kapsayan tarayıcı testi ayrı bir iş olarak kalır.

Son güncelleme: 2026-10-08. Yöntem: `.claude/skills/tech-debt/SKILL.md`.

## Ölçüm
| Dosya | Satır | Not |
|---|---|---|
| `game/ui/main.gd` | 1390 (önce 2568; ilk bölmeden sonra 1958) | ana ekran: kurulum, akış ve bileşen yönlendirmesi |
| `game/ui/agenda_view.gd` | 632 | gündem, dosyalar, raporlar, meclis ve yol gösterici |
| `game/ui/person_panel.gd` | 630 | kişi kartları, eylem paneli ve önizleme |
| `game/core/sim.gd` | 2667 (önce 2607) | kurallar + kayıt + krizler + Faz 4 devlet ve patronaj sistemleri; içerik JSON'da |
| `game/core/advice.gd`, `narrative.gd`, `content_data.gd` | ayrı | Meclis hesabı, anlatı kurma, içerik şeması |
| `game/ui/media_view.gd` | 688 | gazete + TV |
| `game/ui/desk_view.gd` | 649 | çalışma masası |
| `game/ui/menu.gd` | 324 | yeni (main.gd'den) |
| `game/ui/end_screen.gd` | 276 | oyun sonu ve Devlet Defteri |
| `game/ui/truth_chart.gd` | 67 | beş final çizgisi |
| `game/ui/autoplay.gd` | 121 | yeni (main.gd'den) |
| `game/ui/modal.gd` | 80 | yeni (main.gd'den) |

`main.gd` içindeki gündem ve kişi paneli kurulumları bileşenlerine taşındı; dışarıdan kullanılan alan ve yöntem adları korundu.

## Bölme deseni (main.gd'den ayrılan bileşenler)
- Bileşen kendi betiğinde `extends Control` (ya da `RefCounted`), `_init(main)` ile ana ekranı `host` olarak alır ve kurulumu orada yapar.
- main.gd bileşeni eski adıyla tutar (`_menu`, `_modal`, `_end_overlay`), böylece dışarıdaki erişimler değişmez. Çok çağrılan girişler main.gd'de tek satırlık yönlendirici olarak kalır (`_show_modal`, `_menu_show_page`).
- Başka betiğin sabitine tipsiz erişilmez: sabit, kullanan bileşene taşınır ve `MENU.CREDITS` gibi betik üzerinden okunur.
- `host._x()` çağrısının dönüş tipi çıkarılamaz: `var t := host._art(...)` derlenmez, `var t: Texture2D = ...` yazılır.
- Kurulum sırası korunur (menü, pencere, oyun sonu kaplaması; z-sırası buna bağlı).
- Taşıma betikle yapılır (`main.gd` üyelerine önek eklenir), her adım ayrı commit, ardından: `--autoplay`, `--mobile`, `--full` (aynı tohum ve sonuç), `ui_shots` görüntüleri, `sim_test`.

## Envanter (öncelik: etki × olasılık, çaba)
| # | Borç | Durum | Öncelik | Çaba |
|---|---|---|---|---|
| 1 | main.gd büyük | **yapıldı** (3249 -> 1390): gündem ve kişi paneli de ayrıldı | — | — |
| 2 | sim.gd'de içerik (PHRASES, SIGN_TEXTS, ACHIEVEMENTS) kodda | **yapıldı** (`game/data/content_*.json`, `tests/content_check.gd`) | — | — |
| 3 | Kayıt sürümü / göç | **yapıldı** (`SAVE_VERSION`, `tests/save_test.gd`) | — | — |
| 4 | Olay verisi doğrulanmıyor | **yapıldı** (`tests/event_check.gd`) | — | — |
| 5 | Her `Sim.changed`'de gündem/kartlar baştan kuruluyor | açık | 3 | M |
| 6 | Kullanıcı dosyaları `str_to_var` ile okunuyor | açık (yükleme artık bozuk dosyada çökmeden reddediyor) | 2 | S |
| 7 | Otomatik oynatma kodu üretim betiğinde | **yapıldı** (`autoplay.gd`; hâlâ yalnızca `--autoplay` ile yükleniyor) | — | — |
| 8 | Metinler kodda, `tr()` yok | açık | 2 | L |
| 9 | Proje başkasının deposunda, uzak yedek yok | **açık, kullanıcıda** | 9 | S (kullanıcı) |
| 10 | Ses kodla sentezleniyor | açık (ürün borcu) | 3 | L |

## Önerilen sıra
1. **(Kullanıcı) kendi deponu aç** — kodun uzak yedeği yok; en yüksek risk.
2. **Yapıldı:** gündem `agenda_view.gd`, kişi kartları ve eylem paneli `person_panel.gd` içinde; `_sel`, `_hint`, `_buttons` gibi dış erişim adları main.gd'de korunuyor.
3. **Yapıldı:** sim.gd içerik tabloları `game/data/content_*.json`'a ayrıldı; `sim.gd` 402 satır kısaldı.
4. Artırımlı yeniden çizim (`_refresh` imzaları).
