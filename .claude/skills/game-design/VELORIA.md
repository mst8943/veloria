# Veloria — Proje Başvuru Kartı (tüm skill'ler bunu kullanır)

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
| `game/ui/main.gd` | Ana ekran + menü + oyun sonu + akış; ~2600 satır (bilinen teknik borç) |
| `game/ui/ui_kit.gd` | Tema, palet, `box()`, `band_style()`, `ornament()`, `divider()`, `caps()`, `serif()`, `tr_upper()`, animasyon yardımcıları |
| `game/ui/desk_view.gd` | Çalışma Masası (diegetik merkez); `LAYOUT`, `FEEL`, `LAMP_UV`; `desk_lit/desk_shadow.gdshader` |
| `game/ui/city_view.gd`, `media_view.gd`, `cinema.gd`, `truth_chart.gd` | Başkent haritası, Medya Merkezi, sinematikler, hakikat grafiği |
| `game/data/actors.json` | 9 aktör: arden(ordu, military) voss(istihbarat) kessler(maliye) halden(medya) lena(basın, insider=false) dorn(kâhya) prens(royal) brandt(muhalefet, insider=false) falk(yargı) |
| `game/data/events.json` | 71 olay (veri odaklı) |
| `art/` | Görseller; `ART_PROMPTS.md` üretim promptları + STİL BLOĞU |
| `tests/` | `sim_test.gd`, `pacing_test.gd`, `cause_probe.gd`, `ui_shots.gd` (`unit_tests.gd` ve `ci-smoke.ps1` Beckett eklentisine ait, dokunma) |
| `docs/` | `DURUM_VE_YAPILACAKLAR.md` (devir notu — her oturum sonunda güncelle), `OYUNCU_REHBERI.md`, `GELISTIRICI_REHBERI.md`, `ARAYUZ_PLANI.md` |

## Ana döngü (kodda)
Hafta = `mesai_max` mesai (Normal 4, Kolay 5). Eylemler: karar (1), kişi eylemleri (1; terfi, gizli ödeme, söz, doğrula, araştır, emir ×3 kanal, şantaj, görevden al), operasyon (2), dosya (sızdır/bastır/yok et, 1).
`Sim.end_week()`: bekleyen kararlar yaşlanır (2 haftada `ignore` uygulanır) → `_world_tick` → `_decay_facts` (ortak bilgi; 0.25 dedikodu, 0.5 manşet) → `_fire_events` (haftada en çok 2 yeni karar, bekleyen en çok 3) → `_tick_promises` → `_run_cascade` (hazır olanların güç payı ≥ `coup_share` ve askerî/kraliyet "vurucu" varsa darbe) → `_generate_reports` (yalan, yankı odası, Kâhya haber saklar) → `_check_end` → otomatik kayıt.
Kayıp: king_strength ≤ 0 (darbe ya da elit koalisyonu), unrest ≥ 100 (ayaklanma), `legal_pressure()` ≥ 100 (yetkisiz bırakılma).

## Olay şeması (`events.json`)
Zorunlu: `id, title, text, choices[{label, text, fx}], ignore{text, fx}`.
Koşullar: `min_week, max_week, chance, once, cooldown, min_unrest, max_unrest, min_economy, max_economy, min_opposition, min_power{aktör:değer}, needs_flag, blocks_flag, any_flag, flag_age{flag:hafta}, actor_min/actor_max{aktör:{özellik:değer}}, alive[], needs_fact[], needs_ready`.
Etkiler (`fx`): `king, unrest, economy, opp, wealth, actors{aktör:{özellik|l_<sadakat>: delta}}, fact{id,text,subject,severity,knowers}, flag, leak[], remove[], promise_keep/break/delay`.
Seçim yapılınca bayrak `<olay_id>_<seçenek_index>` = hafta olarak yazılır (zincir olaylar bunu kullanır). Görsel: `art/events/<art|id>.png` (+ isteğe bağlı `_b`).

## Komutlar
Godot (console): `C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` (aşağıda `$G`)
- Simülasyon/denge: `"$G" --headless --path . --script res://tests/sim_test.gd` → sonda `TEST: OK`
- Tempo: `"$G" --headless --path . --script res://tests/pacing_test.gd`
- Arayüz otomatik oynatma: `"$G" --headless --path . -- --autoplay` (`--mobile`, `--full` = Kolay'da 104 hafta)
- Ekran görüntüsü (pencereli, headless çizmez): `"$G" --path . --script res://tests/ui_shots.gd -- --out=<klasör> [--mobile] [--only-desk|--only-world]` → PNG'leri Read ile incele
- Proje dışı deney betiği: scratchpad'e `extends SceneTree` betiği yaz, `--script "<mutlak yol>"` ile çalıştır (projeyi kirletmez). `Sim`'e `root.get_node("Sim")` ile eriş; `record_chronicle=false`, `autosave=false`, `save_path` değiştir.
- Build: `"$G" --headless --path . --export-release "Windows Desktop"|Linux|Web` → `dist/`; sonra `.mcp.json` portunu 8770'e geri al.
- Zaman sınırı: script hatasında süreç kapanmayabilir; komutları `timeout` ile çalıştır.

## Tuzaklar (bilinenler)
- `class_name` yerine `preload` kullan (editör önbelleği).
- Web'de sistem font yedeği yok: ◆ ⏳ → ✓ ✗ gibi glifler kutu çıkar. Şekil gerekiyorsa çiz (Panel/draw_*).
- Görünmez (modulate.a=0) Control'ler tıklama yutar; Beckett `ui_snapshot` → `occluded_by` ile tara.
- Yapay `push_input` tıklama testi çalışmıyor; düğmeyi `pressed.emit()` ile tetikle.
- Testler oyuncu kaydına/arşive dokunmamalı (`save_path`, `record_chronicle`, `autosave`).
- `veloria/dev_*` proje ayarları project.godot'ta **false/boş** kalmalı; deneyde yalnızca bellekte `ProjectSettings.set_setting` kullan.
- Çok satırlı GDScript lambdası bir blok içinde bitip ardından deyim gelirse ayrıştırma hatası verir; ayrı fonksiyona taşı.
- Git Bash heredoc içindeki python'da ters eğik çizgiler bozulabilir; kaçışlı metinleri Edit aracıyla düzenle.
- Commit'te kullanıcının kendi değişikliklerini (`.mcp.json`, `BECKETT_SETUP.md`, `project.godot` token satırı, `CLAUDE.md`) katma. Push yok (origin Beckett'in deposu).

## Ölçülmüş durum (2026-10-04, `balance-check/probe_template.gd`, Normal, 40 kampanya)
| Bot | Kazanma | Ort. hafta | Not |
|---|---|---|---|
| idle | 0% | 25 | hep askerî darbe |
| random | 0% | 26 | |
| visible (kararlar rastgele) | 17% | 53 | oyuncunun gerçekte yaşadığına en yakın |
| visible_wise (kararlarda etkiyi tahmin eder) | 75% | 94 | |
| omniscient (gizli drive'a rüşvet, dosya/rapor tepkisi yok) | 12% | 85 | |
**Sonuç:** Sonucu en çok kararların kalitesi belirliyor; oyuncu seçenek etkilerini göremediği için fiilen rastgele seçiyor. Seçeneklerde okunabilir ipucu en büyük kaldıraç.
- Kayıpların çoğu askerî darbe; kazananların çoğu "… Kuklası" ünvanı alıyor (ünvan çeşitliliği düşük).
- Olay/hafta: ilk yıl ~1.2, ikinci yıl ~0.5; 71 olayın 6'sı 52.+ hafta.
