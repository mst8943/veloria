# Veloria — Proje Başvuru Kartı (tüm skill'ler bunu kullanır)

Güncel dağıtım sürümü: **1.1.0** (Windows, Linux, Web). Sürüm `project.godot` içindeki `application/config/version` değeridir; paketler `dist/release/Veloria-1.1.0-<platform>.zip` adını taşır.

Bu dosya, skill'lerin projeyi her seferinde baştan keşfetmemesi için tek doğruluk kaynağıdır.
Bir şey değiştiyse (dosya taşındı, komut değişti) önce burayı güncelle.

## Oyun tek cümlede
Veloria bir ülke yönetme değil, **iktidarda kalma** simülasyonu: Kral Adrian IV, 104 hafta tahtta kalmaya çalışır;
sayıları göremez, yalnızca yalan söyleyebilen insanların raporlarını okur.

## Tasarım ilkeleri (her kararda kontrol et)
1. **Belirsiz bilgi, körlük değil.** Oyuncu gerçeği doğrudan görmez ama sezebilmelidir (gürültülü sinyal, çelişen kaynak, iz).
2. **Satın alınan sadakat seni satın alabilir.** Her güç aracı bir bedel/iz bırakır (kanıt, borç, hırs).
3. **İnsanlar, rakamlar değil.** Mekanik bir karaktere bağlanmalı; oyuncunun aklında isimler kalmalı.
4. **Dünya oyuncuyu beklemez.** Gecikmeli sonuç, zincir olay, eski kararın geri dönüşü.
5. **Herkesin bildiği sır, gizli sırdan tehlikelidir** (ortak bilgi → eşik kaskadı).
6. **Başarısızlık da hikâyedir.** Kayıp ekranı bir tarih kaydıdır.
Kaynak: `VELORIA — Oyun Tasarım Özeti.md` (958 satır, 30 bölüm) ve `CLAUDE.md` (çalışma kuralları, kalite soruları).

## Mimari haritası
| Dosya | Görev |
|---|---|
| `game/core/sim.gd` (autoload `Sim`) | Gerçek dünya durumu, oyuncu eylemleri, haftalık tick, olay motoru, kaskad/darbe, raporlar (yalan filtresi), kayıt, başarımlar, tarihçiler |
| `game/core/actor.gd` | Aktör verisi: power, ambition, fear, honesty, threshold, loyalty{money,fear,ideology,career,complicity}, obligation, perceived_king, ready, moved, secrets_on_king, known_weak/red. `rebellion_drive()` |
| `game/core/press.gd` | Gazeteler/TV: gizli durumdan, yayın sahibinin süslemesiyle üretilir |
| `game/core/sfx.gd` (autoload `Sfx`) | Ses (şu an sentez), müzik, ayarlar (`user://veloria_settings.cfg`) |
| `game/ui/main.gd` | Ana ekran: kurulum, gündem, kartlar, eylem paneli, akış; ~2550 satır (bölme süreci: `docs/TECH_DEBT.md`) |
| `game/ui/menu.gd`, `modal.gd`, `end_screen.gd`, `autoplay.gd` | main.gd'den ayrılan bileşenler (`_init(main)`, `host`); main.gd onları `_menu`, `_modal`, `_end_overlay` olarak tutar |
| `game/ui/ui_kit.gd` | Tema, palet, `box()`, `band_style()`, `ornament()`, `divider()`, `caps()`, `serif()`, `tr_upper()`, animasyon yardımcıları |
| `game/ui/desk_view.gd` | Çalışma Masası (diegetik merkez); `LAYOUT`, `FEEL`, `LAMP_UV`; `desk_lit/desk_shadow.gdshader` |
| `game/ui/city_view.gd`, `media_view.gd`, `cinema.gd`, `truth_chart.gd` | Başkent haritası, Medya Merkezi, sinematikler, hakikat grafiği |
| `game/data/actors.json` | 9 aktör: arden(ordu, military) voss(istihbarat) kessler(maliye) halden(medya) lena(basın, insider=false) dorn(kâhya) prens(royal) brandt(muhalefet, insider=false) falk(yargı) |
| `game/data/events.json` | 159 kayıt: 101 temel karar, 16 aktör hamlesi, 36 karakter yayı, 6 rejim hesaplaşması |
| `art/` | Görseller; `ART_PROMPTS.md` üretim promptları + STİL BLOĞU |
| `tests/` | `sim_test.gd`, `pacing_test.gd`, `cause_probe.gd`, `ui_shots.gd` (`unit_tests.gd` ve `ci-smoke.ps1` Beckett eklentisine ait, dokunma) |
| `docs/` | `DURUM_VE_YAPILACAKLAR.md` (devir notu — her oturum sonunda güncelle), `OYUNCU_REHBERI.md`, `GELISTIRICI_REHBERI.md`, `ARAYUZ_PLANI.md` |

## Ana döngü (kodda)
Hafta = `mesai_max` mesai (Normal 4, Kolay 5). Eylemler: karar (1), kişi eylemleri (1; terfi, gizli ödeme, söz, doğrula, araştır, emir ×3 kanal, şantaj, görevden al), operasyon (2), dosya (sızdır/bastır/yok et, 1).
`Sim.end_week()`: bekleyen kararlar yaşlanır (2 haftada `ignore` uygulanır) → `_world_tick` → `_decay_facts` (ortak bilgi; 0.25 dedikodu, 0.5 manşet) → `_fire_events` (haftada en çok 2 yeni karar, bekleyen en çok 3) → `_tick_promises` → `_run_cascade` (komplo aşamaları, çekilme; koşul oluşunca **kriz kartı**, çözülmezse ertesi hafta darbe) → `_plot_signs` (alametler) → `_generate_reports` (yalan, yankı odası, Kâhya haber saklar) → `_check_end` → otomatik kayıt.
Kayıp: king_strength ≤ 0 (darbe ya da elit koalisyonu), unrest ≥ 100 (ayaklanma), `legal_pressure()` ≥ 100 (yetkisiz bırakılma).
**Birbirine Düşür** (`docs/design/birbirine_dusur.md`): operasyon sekmesinde, çoklu seçimle tam iki kişi, 2 mesai (`Sim.divide_rivals(ids)`, `rival_wait`, `RIVAL_COOLDOWN`=6). Başarıda ikisi de güç -4 / hırs -3; başarısızlıkta hırs +6, para sadakati -4 ve "dusurme_*" sırrı (şiddet 30); her durumda %15 sızıntı sırrı. `stats["rivalries"]`.
**Aktör hamleleri** (`docs/design/aktor_hamleleri.md`): `events.json`'da `hamle_*` seçeneksiz olaylar (`news`, `actor`, `tone`; `once: false`). Tetiklenince "HAMLE: ..." haberi ve `Sim.weekly_moves` -> "Geçen haftadan beri". Kural: darbe yapabilen aktörlerin (Arden, Prens) hamleleri güç/hırs eklememeli ya da çok küçük eklemeli; Prens'e küçük güç eklemek Normal'i %40 -> %22 yaptı.

**Faz 3:** `docs/design/hikaye_yaylari.md` (dokuz `yay_*` zinciri; sınav kararı sadakat/kopuş sahnesini seçer) ve `docs/design/rejim_tipi.md` (hafta 60'ta geçmişten tek seferlik rejim; `REJIM_*` bayrağı 82–100 haftasında altı hesaplaşma kartından birini açar). `Sim.SAVE_VERSION = 4`; eski v3 kaydı rejimi yeniden hesaplar, oluşum haberini tekrar yazmaz. Sonuç Özet'i rejim ve tehdidi gösterir.
**Sokak ve mahkeme krizleri** (`docs/design/kayip_cesitliligi.md`): bastırma emri gizli `street_anger` biriktirir (etkisi azalır, huzursuzluğu besler, haftada %7 söner). Huzursuzluk ≥ `UPRISING_AT` -> "Sokaklar ayakta" kriz kartı (force/concede/appeal); yargı baskısı ≥ `LEGAL_CRISIS_AT` -> yetki krizi (purge/testify/bargain, `legal_relief`). Çözülmezse ya da yol başarısızsa ayaklanma / yetkisiz bırakılma. `Sim.other_crisis`, `_check_crises()`, `active_crisis_label()`; kartlarda `crisis_kind` ve `banner`.
**Meclis görüşleri** (`docs/design/danisman_gorusleri.md`): `Sim.advice_for(pending_index)` her karta iki danışman görüşü üretir (taraf olan + uzman), tembel ve `pending[i]["advice"]` içinde saklı; ana `rng`'yi tüketmez. Kralın çıkarı tek yerde: `Sim.choice_value(fx)` (botlar da bunu kullanır). Karar verilince `advice_log`'a işlenir; oyun sonunda `record["council"]` = `council_record()`. Ayarlar `ADVICE_*` sabitleri ve `DIFFICULTY[*].advice_noise`.
**Darbe aşamaları** (`docs/design/darbe_asamalari.md`): `Actor.plot_stage` 0 sakin · 1 huzursuz · 2 komplocu (`ready`) · 3 hazırlıkta; `plot_calm` ile çekilme (ready artık geri dönebilir). Alametler `Actor.signs` ({w,text,weight,real}); oyuncu göstergesi `Sim.suspicion_level(id)` (yalnızca görülen alametlerden). Kriz: `Sim.coup_crisis`, kart `event.crisis = true` (meclis susar), `_resolve_crisis(rally|concede|appeal)`, `crisis_chance()`. Yeni eylem `Sim.summon(id)` (Huzura Çağır). Oyun sonu `record["plot"]`, `record["signs"]`. Zorluk: `crisis_odds`, `leave_gap`.

## Olay şeması (`events.json`)
Zorunlu: `id, title, text, choices[{label, text, fx}], ignore{text, fx}`.
Koşullar: `min_week, max_week, chance, once, cooldown, min_unrest, max_unrest, min_economy, max_economy, min_opposition, min_power{aktör:değer}, needs_flag, blocks_flag, any_flag, flag_age{flag:hafta}, actor_min/actor_max{aktör:{özellik:değer}}, alive[], needs_fact[], needs_ready, min_stat/max_stat{istatistik:sayı}` (istatistikler `Sim.stats`: bribes, written, blackmails, promotes, broken, ops...; oyuncu geçmişine bağlı "Bedellerin Dönüşü" olayları için). Olay ekledikten sonra `event_check.gd`.
Etkiler (`fx`): `king, unrest, economy, opp, wealth, actors{aktör:{özellik|l_<sadakat>: delta}}, fact{id,text,subject,severity,knowers}, flag, leak[], remove[], promise_keep/break/delay`.
Seçim yapılınca bayrak `<olay_id>_<seçenek_index>` = hafta olarak yazılır (zincir olaylar bunu kullanır). Görsel: `art/events/<art|id>.png` (+ isteğe bağlı `_b`).

## Komutlar
Godot (console): `C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` (aşağıda `$G`)
- Simülasyon/denge: `"$G" --headless --path . --script res://tests/sim_test.gd` → sonda `TEST: OK`
- Olay verisi doğrulayıcısı: `"$G" --headless --path . --script res://tests/event_check.gd` → `EVENTS: OK` (bilinmeyen anahtar/aktör/özellik, çözülemeyen bayrak, tutarsız hafta; **olay ekleyince/değiştirince çalıştır**). Başka dosya: `-- --file=<yol>`
- Kayıt sürümü/göç: `"$G" --headless --path . --script res://tests/save_test.gd` → `SAVE: OK`
- Tempo: `"$G" --headless --path . --script res://tests/pacing_test.gd`
- Arayüz otomatik oynatma: `"$G" --headless --path . -- --autoplay` (`--mobile`, `--full` = Kolay'da 104 hafta)
- Ekran görüntüsü (pencereli, headless çizmez): `"$G" --path . --script res://tests/ui_shots.gd -- --out=<klasör> [--mobile] [--only-desk|--only-world]` → PNG'leri Read ile incele
- Proje dışı deney betiği: scratchpad'e `extends SceneTree` betiği yaz, `--script "<mutlak yol>"` ile çalıştır (projeyi kirletmez). `Sim`'e `root.get_node("Sim")` ile eriş; `record_chronicle=false`, `autosave=false`, `save_path` değiştir.
- Build: `"$G" --headless --path . --export-release "Windows Desktop"|Linux|Web` → `dist/`; sonra `.mcp.json` portunu 8770'e geri al.
- Zaman sınırı: script hatasında süreç kapanmayabilir; komutları `timeout` ile çalıştır.

## Tuzaklar (bilinenler)
- `class_name` yerine `preload` kullan (editör önbelleği).
- Kayıt şemasını değiştirince (`save_game` sözlüğüne alan ekleyince) `Sim.SAVE_VERSION`'ı artır, `_migrate_save`'e adım, `save_test.gd`'ye eski sürümü taklit eden adım ekle.
- Olay motoru (`_apply_effects`, `_bump`) bilinmeyen anahtarı ve yanlış yazılmış aktör özelliğini hata vermeden yok sayar: `event_check.gd` bunun için var.
- Web'de sistem font yedeği yok: ◆ ⏳ → ✓ ✗ gibi glifler kutu çıkar. Şekil gerekiyorsa çiz (Panel/draw_*).
- Görünmez (modulate.a=0) Control'ler tıklama yutar; Beckett `ui_snapshot` → `occluded_by` ile tara.
- Yapay `push_input` tıklama testi çalışmıyor; düğmeyi `pressed.emit()` ile tetikle.
- Testler oyuncu kaydına/arşive dokunmamalı (`save_path`, `record_chronicle`, `autosave`).
- `veloria/dev_*` proje ayarları project.godot'ta **false/boş** kalmalı; deneyde yalnızca bellekte `ProjectSettings.set_setting` kullan.
- Çok satırlı GDScript lambdası bir blok içinde bitip ardından deyim gelirse ayrıştırma hatası verir; ayrı fonksiyona taşı.
- Git Bash heredoc içindeki python'da ters eğik çizgiler bozulur (`\n` gerçek satır sonuna dönüşür); kaçışlı metinleri Edit aracıyla düzenle.
- **Godot süreçlerini kapatırken başlangıç saatine bak.** Konsol exe ana exe'yi alt süreç olarak başlatır; kullanıcının açık editörü de aynı adı taşır. Yalnızca kendi başlattığın (StartTime ≥ başlatma anı) süreçleri durdur.
- Hafta ortasında oyun bitebilir (kriz). Test/bot döngülerinde `while mesai > 0` güvenli; çünkü `_end` mesaiyi sıfırlar.
- Commit'te kullanıcının kendi değişikliklerini (`.mcp.json`, `BECKETT_SETUP.md`, `project.godot` token satırı, `CLAUDE.md`) katma. Push yok (origin Beckett'in deposu).

## Ölçülmüş durum (2026-10-06, Faz 3, 159 olay, 80 kampanya)
İki bağımsız çalıştırma aynı sonucu verdi: **advice_weighted Kolay %83, Normal %45, Zor %16**. Dokuz yaydan sonra %80/%41/%16 idi. Oligark hesaplaşmasının tek etki grubu ayarlandı; seçilen rejim darbe aktörlerine güç/hırs eklemez.

## Önceki ölçüm (2026-10-06, aktör hamlelerinden sonra, 117 olay, 80 kampanya)
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible | 30% | 21% | 5% |
| advice_weighted (ölçüt) | 80% | 41% | 27% |
| advice_soft | 76% | 41% | 31% |
| advice_dirty | 53% | 33% | 22% |
| visible_wise | 98% | 92% | 72% |
Kayıp tarza bağlı: advice_dirty Kolay'da 20, Normal'de 10 kez yetkisiz; advice_soft ayaklanmayla 2–4.

## Eski ölçüm (2026-10-06, sokak/mahkeme krizlerinden sonra, 80 kampanya)
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible | 26% | 13% | 8% |
| advice_weighted (ölçüt) | 81% | 40% | 18% |
| visible_wise | 100% | 91% | 77% |
Normal'de tarz botları: advice_soft 43% (darbe dışı kayıp %11), advice_dirty 36% (%16). Kayıp oyun tarzına bağlı.

## Eski ölçüm (2026-10-06, ikinci yıl paketinden sonra, 101 olay, 80 kampanya)
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible | 41% | 17% | 12% |
| advice_weighted (ölçüt) | 85% | 48% | 21% |
| visible_wise | 100% | 85% | 81% |
Tempo: 57–96 arası her dilim ≥0,8 olay/hafta. Kayıplar hâlâ ~%95 darbe (açık konu: Faz 2 kayıp çeşitliliği).

## Eski ölçüm (2026-10-04, darbe aşamalarından sonra, `balance-check/probe_template.gd`, 80 kampanya)
| Bot | Kolay | Normal | Zor | Not |
|---|---|---|---|---|
| visible (görüşsüz, kararlar rastgele) | 56% | 23% | 15% | görüş ve alametlere bakmayan oyuncu |
| advice_naive (ilk danışmana uyar) | 90% | 61% | 32% | |
| advice_weighted (görüşleri tartar, alamete boş mesaide tepki) | 80% | 48% | 27% | **ölçüt: gerçek oyuncuya en yakın** |
| visible_wise (`choice_value` ve kriz olasılıklarını okur) | 100% | 98% | 88% | tavan, hedef değil |
**Sonuç:** Zorluk hedefleri tutuyor. Aynı hafta darbe ~%5–10 (önce %25). Krizlerin ~%40'ından sağ çıkılıyor. Alamete tepki vermek bot için nötr (açık konu).
- Kayıpların çoğu hâlâ askerî darbe (artık kriz kartından geçerek). Ünvan çeşitliliği arttı ama hâlâ çoğu "… Kuklası".
- Olay/hafta: ilk yıl ~1.2, ikinci yıl ~0.5; 71 olayın 6'sı 52.+ hafta.
