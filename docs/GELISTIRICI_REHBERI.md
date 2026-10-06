# Veloria — Geliştirici Rehberi

Godot 4.7 ile yazılmış, veri odaklı bir siyaset simülasyonu. Bu belge projeyi açmak, içerik eklemek, test etmek ve build almak için gerekenleri anlatır.

## Klasör yapısı

```
game/
  core/
    sim.gd        Simülasyon çekirdeği (autoload: Sim) — gizli dünya durumu, kurallar, kayıt
    actor.gd      Karakter modeli: güç, hırs, korku, sadakat nedenleri, sırlar
    sfx.gd        Ses sentezi ve ayarlar (autoload: Sfx)
    press.gd      Gazete ve TV içeriği: gizli durumdan, yayın sahibinin gözüyle üretilir
  data/
    actors.json   9 karakter
    events.json   Karar ve aktör olayları (159 kayıt)
    city_map.json (isteğe bağlı) harita bina konumları, yüzde olarak
  ui/
    main.gd       Ana ekran kurulumu, akış ve bileşen yönlendirmesi
    agenda_view.gd Gündem, değişim defteri, raporlar, Meclis ve dosyalar
    person_panel.gd Kişi kartları, eylem paneli ve önizleme
    menu.gd       Ana menü (sayfalar, ayarlar, Hakkında/Nasıl Oynanır metinleri)
    modal.gd      Bilgi/onay penceresi
    end_screen.gd Oyun sonu ekranı (sekmeler, Hakikat Dosyası)
    autoplay.gd   Otomatik oynatma testi (-- --autoplay)
    desk_view.gd  Çalışma Masası (art/desk/<id>.png varsa kullanır, yoksa kodla çizer)
    city_view.gd  Başkent Haritası (art/city_map.png varsa kullanır, yoksa kodla çizer)
    media_view.gd Medya Merkezi: iki gazete ve TV
    ui_kit.gd     Tema, renkler, animasyon yardımcıları, tr_upper (Türkçe büyük harf)
    cinema.gd     Sinematik katman (bantlar, Ken Burns, altyazı)
    truth_chart.gd Oyun sonu grafiği
    *.gdshader    Atmosfer, başlık parıltısı, gazete baskısı, TV tarama çizgileri
  fonts/          EB Garamond (başlık) + IBM Plex Sans (gövde), ikisi de OFL
art/
  portraits/      <karakter_id>.png
  events/         <olay_id>.png  (isteğe bağlı ikinci versiyon: <olay_id>_b.png)
  icons/          Arayüz ikonları
  *.png           Masa, menü ve dört final sahnesi
  _arsiv/         Kullanılmayan görseller (.gdignore ile Godot dışı)
tests/sim_test.gd Headless simülasyon, denge ve sistem testleri
tests/event_check.gd  events.json doğrulayıcısı (şema, aktör/özellik adları, bayrak başvuruları)
tests/save_test.gd    Kayıt sürümü ve göç testi
tests/content_check.gd İçerik JSON şeması
tests/ui_input_test.gd Kart ve rapor tıklamasından kişi seçimi (pencereli)
tests/ui_shots.gd Arayüz ekran görüntüleri (oyun, menü sayfaları, oyun sonu sekmeleri)
ART_PROMPTS.md    Tüm görsellerin üretim prompt'ları
export_presets.cfg Windows, Linux, Web
```

## Mimari

- **Sim** gerçeği tutar (tahtın gücü, huzursuzluk, ekonomi, muhalefet, sırlar). Oyuncu bu sayıları asla görmez.
- Her hafta aktörler kendi hamlelerini yapar, sırlar yayılır, olaylar tetiklenir, **eşik kaskadı** hesaplanır: her aktörün "kaç kişi kıpırdarsa ben de kıpırdarım" eşiği vardır; kamuya açık zayıflıklar bu eşikleri düşürür.
- Raporlar, gerçeğin aktörün korkusu ve dürüstlüğüyle süslenmiş hâlidir. Süslenen her rapor **Hakikat Dosyası**'na yazılır.
- Arayüz Sim'in sinyallerini (`changed`, `week_advanced`, `game_ended`) dinler.
- `main.gd` 1390 satırdır; `agenda_view.gd` ve `person_panel.gd` ana ekranı `_init(main)` ile `host` olarak alır. Dışarıdan kullanılan `_sel`, `_buttons`, `_cards` alanları ve yöntem adları `main.gd` üzerinde kalır (`docs/TECH_DEBT.md`).

## Yeni olay eklemek

`game/data/events.json`'a bir nesne ekle. Kod değişikliği gerekmez.

```json
{
  "id": "ornek_olay", "min_week": 10, "title": "Başlık",
  "text": "Olayın anlatımı.",
  "choices": [
    {"label": "Seçenek", "text": "Sonuç metni", "fx": {"unrest": -5, "actors": {"arden": {"power": 4}}}}
  ],
  "ignore": {"text": "Ertelenirse", "fx": {"king": -2}}
}
```

**Koşullar** (hepsi isteğe bağlı):

| Anahtar | Anlamı |
|---|---|
| `min_week`, `max_week` | Hafta aralığı |
| `min_unrest`, `max_unrest`, `min_economy`, `max_economy`, `min_opposition` | Gizli durum eşikleri |
| `min_power` | `{"arden": 55}` |
| `actor_min`, `actor_max` | `{"kessler": {"fear": 50}}` — herhangi bir aktör özelliği |
| `needs_flag`, `blocks_flag`, `any_flag` | Bayrak koşulları |
| `flag_age` | `{"gida_protestosu_0": 8}` — o karar en az 8 hafta önce verilmiş olmalı (gecikmeli sonuç) |
| `alive`, `needs_fact`, `needs_ready` | Aktör hayatta / sır var / biri darbeye hazır |
| `once`, `cooldown`, `chance` | Tekrarlanabilirlik ve olasılık |
| `art` | Başka bir olayın görselini kullan |

Her seçim otomatik olarak `<olay_id>_<seçenek_no>` bayrağını, erteleme `<olay_id>_ertelendi` bayrağını koyar. Zincir olaylar bunlara `flag_age` ile bağlanır.

## İçerik metni eklemek

`game/data/content_reports.json` rapor ve alamet cümlelerini; `content_council.json` Meclis gerekçelerini, uzman eşleşmelerini ve söyleyişleri; `content_history.json` tarihçi anlatılarını; `content_achievements.json` başarım ad/açıklamalarını; `content_labels.json` ödül, kademe ve rejim adlarını tutar. Dizi sırası seçimleri etkileyebilir; var olan sırayı koru. Metinleri değiştirdikten sonra `tests/content_check.gd` çalıştır: eksik anahtar, boş metin, bilinmeyen aktör ve bozuk JSON'u yakalar. Yükleme hatası menüde dosya yoluyla görünür; yeni oyun açılmaz. Ayrıntı: `docs/design/icerik_verisi.md`.

Meclis'in sayısal hesabı `game/core/advice.gd`, rapor/alamet/tarihçi metni kurma `game/core/narrative.gd`, veri yükleme `game/core/content_data.gd` içindedir. `Sim`'in `choice_value`, `advice_for`, `short_name`, `historians` dış API'si korunur. İçerik dosyaları mevcut `game/data/*.json` export filtresine girer.

Faz 3'te dokuz karakterin üç sahnelik dallanan yayı `yay_*` kayıtlarında yer alır (`docs/design/hikaye_yaylari.md`). Hafta 60'ta `Sim._choose_regime()` oyuncu geçmişi, karar bayrakları ve görünen güç kademelerinden altı tipten birini seçer. `regime` kayıt alanı sürüm 4'tedir; `REJIM_*` bayrağı yalnızca seçilen `rejim_*_hesap` kartını açar. Oyun sonu Özet'i aynı etiketi ve tehdidi kullanır (`docs/design/rejim_tipi.md`).

**Etkiler (`fx`)**: `unrest`, `economy`, `king`, `opp`, `wealth`, `actors` (özellik değişimi; `l_<neden>` sadakat nedenini değiştirir, örn. `l_career`), `fact` (yeni sır), `flag`, `leak` (sırrı kamuya aç), `remove` (aktörü oyundan çıkar).

Görseli için `art/events/<id>.png` ekle; yoksa kart görselsiz çıkar.

## Yeni karakter eklemek

`game/data/actors.json`'a ekle (`domain` rapor alanını belirler), `art/portraits/<id>.png` koy. Yeni bir `domain` kullanılırsa `content_reports.json` içindeki `phrases` alanını ve `sim.gd::_domain_truth` kuralını güncelle.

## Görsel ekleme

1. Görseli doğru adla `art/` altına koy.
2. Godot editörüne odaklan (otomatik içe aktarma) ya da `--import` çalıştır.
3. `.import` dosyasında boyut sınırı (portre 512, olay 960), `compress/mode=1` ve `mipmaps/generate=true` kullan. Mevcut dosyalar örnek.

## Testler

Godot console exe ile:

```bash
Godot_console.exe --headless --path . --script res://tests/sim_test.gd
Godot_console.exe --headless --path . --script res://tests/event_check.gd   # olay ekleyince: EVENTS: OK
Godot_console.exe --headless --path . --script res://tests/content_check.gd # içerik metni ekleyince: CONTENT: OK
Godot_console.exe --headless --path . --script res://tests/save_test.gd     # SAVE: OK
```

Bu test 40'ar kampanyalık bot oyunlarıyla dengeyi ölçer (pasif, rastgele, dikkatli botlar), zorluk seviyelerini, kayıt/yükleme, şantaj, söz defteri, tarihçiler ve zincir olayların ulaşılabilirliğini kontrol eder. Testler oyuncunun kaydına ve arşivine dokunmaz.

Olay temposunu ölçmek için (haftalara göre olay yoğunluğu, en uzun olaysız seri):

```bash
Godot_console.exe --headless --path . --script res://tests/pacing_test.gd
```

Arayüzü baştan sona otomatik oynatmak için (masa, harita ve medya ekranlarını da açar):

```bash
Godot_console.exe --headless --path . -- --autoplay
Godot_console.exe --headless --path . -- --autoplay --mobile
Godot_console.exe --headless --path . -- --autoplay --full
```

Ekran görüntüleri (pencereli çalışır; headless çizim yapmaz; kayda ve arşive dokunmaz):

```bash
Godot_console.exe --path . --script res://tests/ui_shots.gd -- --out=C:/klasor
Godot_console.exe --path . --script res://tests/ui_shots.gd -- --out=C:/klasor --mobile
```

## Claude Code skill'leri

Projeye özel skill'ler `.claude/skills/` altında (Claude Code'da `/ad` ile çağrılır). Ortak proje bilgisi: `.claude/skills/game-design/VELORIA.md`. Klasörde `.gdignore` var; Godot bunları içe aktarmaz.

| Skill | Ne yapar |
|---|---|
| `/game-design` | Yeni özellik fikrini kodlamadan önce değerlendirir, kısa plan çıkarır |
| `/design-system` | Tek bir sistemi GDD seviyesinde tasarlar (`docs/design/`) |
| `/design-review` | Tasarım önerisini, GDD'yi ya da olay paketini eleştirel inceler |
| `/balance-check` | Bot simülasyonlarıyla denge, baskın strateji, tempo ölçer (`probe_template.gd`) |
| `/ux-design` | Ekran/HUD/akış spesifikasyonu (`docs/ux/`) |
| `/ux-review` | Ekran görüntüsü alıp arayüzü kalite kontrolünden geçirir |
| `/team-ui` | Arayüz işini uçtan uca yürütür: tasarım, uygulama, inceleme, test, belge |
| `/art-bible` | Görsel kimlik kitabı (`docs/ART_BIBLE.md`) |
| `/asset-spec` | Görsel spesifikasyonu + prompt; gelen görseli tanıyıp yerleştirir |
| `/tech-debt` | Teknik borcu ölçer, önceliklendirir (`docs/TECH_DEBT.md`) |
| `/project-stage-detect` | Projenin aşamasını ölçütlerle belirler |

Kod incelemesi için Claude Code'un yerleşik `/code-review` komutu kullanılır.

## Geliştirici ayarları

Proje ayarlarında `veloria/` altında; dağıtımdan önce hepsi kapalı olmalı:
`dev_autostart`, `dev_skip_weeks`, `dev_press_end`, `dev_choose`, `dev_end`, `dev_mobile`, `dev_tab`, `dev_select`, `dev_event`, `dev_modal`, `dev_intro`, `dev_desk`, `dev_city` (`map` ya da kurum id'si), `dev_media` (`state`, `free`, `tv`).

## Dikkat edilecekler

- **Tıklama yutan görünmez kontroller:** Görünmez ama `mouse_filter` açık bir kapsayıcı alttaki düğmeleri örtebilir. Arayüz değişikliğinden sonra Beckett `ui_snapshot` ile `occluded_by` alanını tara.
- **Web fontları:** Web sürümünde sistem yazı tipi yedeği yok. ◆ ⏳ → ● gibi semboller kutu olarak görünür; ya çiz ya da Latin karakter kullan.
- **Gizli kurulan Control'ler:** `hide()` ile kurulan ve CanvasLayer altında duran tam ekran Control'lerin boyutu açılırken açıkça ekrana eşitlenmeli (bkz. `cinema.gd`, `media_view.gd`).

## Build

```bash
Godot_console.exe --headless --path . --export-release "Windows Desktop"
Godot_console.exe --headless --path . --export-release Linux
Godot_console.exe --headless --path . --export-release Web
```

Not: Beckett eklentisi headless export sırasında `.mcp.json` portunu değiştirebilir; export sonrası `8770` olduğunu kontrol et.

Presetler `dist/windows/Veloria.exe`, `dist/linux/Veloria.x86_64` ve `dist/web/index.html` üretir. Sürüm `project.godot` içindeki `application/config/version` alanından gelir. Her platform klasörünün içeriğini kökte olacak şekilde `dist/release/Veloria-<sürüm>-<platform>.zip` içine paketle; güncel `docs/OYUNCU_REHBERI.md` dosyasını `OYUNCU_REHBERI.md` adıyla ekle.

Web sürümünü yerelde denemek için: `python -m http.server 8060 --directory dist/web`. Menü, üç medya sekmesi, hafta geçişi ve oyun sonunu tarayıcıda kontrol et.

`tests/ui_input_test.gd` pencereli çalışır; kişi kartı ve rapor tıklamalarını gerçek GUI giriş olayıyla sınar. `ui_shots.gd --regime` rejim haberi, “Geçen haftadan beri” satırı ve rejimli finali görüntüler.

## Lisanslar

- Godot Engine: MIT (bildirim oyunun Hakkında ekranında)
- EB Garamond: SIL OFL 1.1 (`game/fonts/OFL.txt`, build'e dahil)
- IBM Plex Sans: SIL OFL 1.1 (`game/fonts/OFL_IBMPlexSans.txt`, build'e dahil: export `include_filter` `game/fonts/*.txt`)
- Görseller: yapay zekâ ile üretilmiş özgün görseller
