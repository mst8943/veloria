# Teknik borç

Son güncelleme: 2026-10-06. Yöntem: `.claude/skills/tech-debt/SKILL.md`.

## Ölçüm
| Dosya | Satır | Not |
|---|---|---|
| `game/ui/main.gd` | 2548 (önce 3249) | ana ekran: kurulum, gündem, kartlar, eylem paneli, akış |
| `game/core/sim.gd` | 2478 | kurallar + içerik (PHRASES, SIGN_TEXTS) + kayıt + krizler |
| `game/ui/media_view.gd` | 688 | gazete + TV |
| `game/ui/desk_view.gd` | 649 | çalışma masası |
| `game/ui/menu.gd` | 324 | yeni (main.gd'den) |
| `game/ui/end_screen.gd` | 243 | yeni (main.gd'den) |
| `game/ui/autoplay.gd` | 121 | yeni (main.gd'den) |
| `game/ui/modal.gd` | 80 | yeni (main.gd'den) |

En uzun fonksiyonlar (main.gd): `_build_ui` ~350 satır, `_rebuild_agenda` ~170, `_end_week_pressed` ~65.

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
| 1 | main.gd büyük | **kısmen** (3249 -> 2548): otomatik oynatma, oyun sonu, menü, pencere ayrıldı | 6 | M |
| 2 | sim.gd'de içerik (PHRASES, SIGN_TEXTS, ACHIEVEMENTS) kodda | açık | 4 | M |
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
2. main.gd'nin kalanı, dokunuldukça: gündem (`_rebuild_agenda`, `_add_changes`, `_add_week_ledger`, raporlar, meclis; ~550 satır) -> `agenda_view.gd`; kişi kartları ve eylem paneli (`_make_card`, `_update_info`, `_preview`, `ACTION_META`; ~400 satır) -> `person_panel.gd`. Bunlar ana ekranın çekirdeği ve birbirine bağlı (`_sel`, `_hint`, `_buttons`); otomatik oynatma bu adlara eriştiği için birlikte güncellenmeli.
3. sim.gd içeriği (PHRASES, SIGN_TEXTS) `game/data/*.json`'a.
4. Artırımlı yeniden çizim (`_refresh` imzaları).
