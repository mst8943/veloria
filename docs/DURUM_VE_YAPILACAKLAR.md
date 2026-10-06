# Veloria — Durum ve Yapılacaklar (yeni oturum için devir notu)

Son güncelleme: 2026-10-06 (dağıtım 1.1.0). Dal: `veloria`.

## Faz 3 tamamlandı (kaynak ağacı; dağıtım paketleri henüz bu değişiklikleri içermez)
- Dokuz güç merkezi için yükseliş, sınav ve karara göre sadakat/kopuş sahneleri: 36 yeni `yay_*` olay kaydı. Başlangıçlar 20–60. haftalara dağıldı; mevcut olay görselleri kullanıldı. Tasarım ve gerekçe: `docs/design/hikaye_yaylari.md`.
- Altı rejim tipi hafta 60'ta geçmişten bir kez seçilir; haber ve "Geçen haftadan beri" satırı, 82–100. hafta arasında tipe özgü altı hesaplaşma kartından biri, final Özet'i ve ünvanı kullanır. Kayıt sürümü 4, v3 göçü eklendi. Tasarım: `docs/design/rejim_tipi.md`. Toplam 159 olay kaydı.
- İki ayrı 80 kampanyalık sondaj: yalnız yaylardan sonra ölçüt botu Kolay %80 / Normal %41 / Zor %16; rejim ayarından sonra iki bağımsız çalıştırmada %83 / %45 / %16 (hedef bantlarda). Oligark hesaplaşmasının yalnızca etki grubu ayarlandı; Arden/Prens'e güç veya hırs eklenmedi.
- `TEST: OK` (dokuz zincirin iki dalı ve altı rejim dahil), `EVENTS: OK (159 olay, 0 uyarı)`, `SAVE: OK`; masaüstü/mobil `AUTOPLAY DONE`; `--full` ilk tohum 101 ile 104 haftayı `TAHTTA`, "Oligark Rejimi" bitirdi. Pencereli kanıt: `dist/qa_phase3/5_rejim_son.png`, `dist/qa_phase3_mobile/5_rejim_son.png`; rejim haftası ve özet görüntüleri aynı klasörlerde.
- Bilinen sınır: rejim hesaplaşması mevcut kriz motoruna siyasi bağlam sağlar; yeni bir otomatik kayıp kuralı değildir. Dağıtım 1.1.0 bu Faz 3 çalışmasından önce derlendi; yeni paket için yeniden export gerekir.

## Dağıtım 1.1.0 (2026-10-06)
- `project.godot` sürümü 1.1.0; çözünürlük 1600×900. Windows, Linux ve Web export alındı; `export_presets.cfg` değiştirilmedi. Windows exe pencereli açıldı.
- Paketler (zip doğrulaması temiz): `dist/release/Veloria-1.1.0-windows.zip` **61.636.964 bayt**, `Veloria-1.1.0-linux.zip` **51.857.188 bayt**, `Veloria-1.1.0-web.zip` **35.567.249 bayt**. Eski 1.0.0 zip'leri arşiv olarak duruyor. Her pakette güncel `OYUNCU_REHBERI.md` var.
- Testler: `TEST: OK`, `EVENTS: OK` (117 olay, 0 uyarı), `SAVE: OK`; masaüstü/mobil `AUTOPLAY DONE`; `--full` ilk tohum 101 ile 104. haftayı `TAHTTA` bitirdi. Denge sondajı (80 kampanya, ölçüt bot): Kolay %80, Normal %41, Zor %27; önceki sonuçla aynı ve hedef bantlarda.
- Chrome WebGL 2 ile yerel HTTP üzerinden menü, oyun, üç Medya Merkezi sekmesi, bir hafta geçişi ve 15. haftada kayıp ekranı açıldı. Kâğıt ve yarım ton, CRT camı, IBM Plex Sans ile Türkçe karakterler ve oyun sonu düzgün görünüyor; tofu ya da siyah TV ekranı yok. Kanıtlar: `dist/qa_1_1_0/web_loaded.png`, `web_media_news.png`, `web_media_serbest.png`, `web_media_tv.png`, `web_week_2.png`, `web_end_screen.png`. Pencereli Godot görüntüleri aynı klasörde (`1_medya*.png`, `5_son_0.png`).
- Tarayıcı otomasyonunda ilk kullanıcı hareketinden önce Web Audio `AudioContext` uyarısı görüldü; ses işitsel olarak doğrulanmadı. Uzun otomatik tıklama denemesinde bir kez IndexedDB kayıt uyarısı görüldü; normal oyun akışında tekrarlanıp tekrarlanmadığı bilinmiyor. `.mcp.json` ve `.cursor/mcp.json` portları 8770.

## Yeni oturumda ilk iş
1. Bu dosyayı oku.
2. `CLAUDE.md` (kullanıcının çalışma kuralları: önce incele, tasarla, sonra kodla; kalite > hız).
3. `.claude/skills/game-design/VELORIA.md`: mimari, olay şeması, komutlar, tuzaklar, ölçülmüş denge.
4. Skill'ler: `docs/SKILL_KULLANIMI.md` (hangi iş için hangi skill).

## Dokunulmayacaklar
- Çalışma ağacındaki `.mcp.json`, `.cursor/mcp.json`, `export_presets.cfg` (editörde yapılan değişiklikler), `BECKETT_SETUP.md`, `project.godot` değişiklikleri, `CLAUDE.md` ve `.cursor/` kullanıcınındır. Commit'e katma; açık kullanıcı talebiyle yapılan sürüm değişikliği istisnadır.
- Godot `--import` ya da export `.mcp.json` ve `.cursor/mcp.json` portunu değiştirebiliyor (8772 gibi). İşlemden sonra portları 8770'e geri al; token satırını geri ekleme.
- `project.godot` çözünürlüğü 1600×900 kalmalı (kullanıcı bir kez 1920×1080 yapmıştı, geri aldı; arayüzün tamamı 1600×900 tabanına göre ayarlı).
- Push YOK: `origin` Beckett'in deposu. Kullanıcıya kendi deposunu açması önerildi, henüz cevap yok. **Kodun uzak yedeği yok.**
- Denge ölçümü arka planda çalışırken `git stash`/checkout ya da `events.json` düzenlemesi YAPMA: Sim her `new_game`'de olay dosyasını yeniden okur, ölçüm karışır.
- Düzenleme betiklerini Git Bash heredoc'uyla değil, Write ile `.py` dosyası yazarak çalıştır (Türkçe/özel karakterler bozulabiliyor).

## Proje
Godot 4.7.2, Türkçe, yatay. Kral Adrian IV, 104 hafta tahtta kalma simülasyonu. Kullanıcı: Mesut Canturk. Görselleri kullanıcı ChatGPT/Imagen ile üretiyor, prompt'ları ben veriyorum (`ART_PROMPTS.md`). Görselleri rastgele adla `art/` içine atıyor; yerleştirme süreci `/asset-spec` skill'inde tanımlı.

## Çalıştırma ve test (ayrıntı: VELORIA.md > Komutlar)
- Godot console: `C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Her değişiklikten sonra: `sim_test.gd` (**TEST: OK**), `event_check.gd` (**EVENTS: OK**, olay eklerken), `save_test.gd` (**SAVE: OK**, kayıt biçimi değişince), `-- --autoplay`, `--autoplay --mobile`, `--autoplay --full` (6 tohuma kadar dener; çıktıyı `tail` ile kısaltma, hepsini oku).
- Tempo: `pacing_test.gd`. Ekran görüntüsü: `ui_shots.gd` (pencereli; `--only-desk`, `--only-decision`, `--only-world`, `--mobile`, `--guide`). Denge sondajı: `.claude/skills/balance-check/probe_template.gd` (`-- --n=80 --all-diffs --bots=advice_weighted,advice_soft,advice_dirty,advice_scheme,visible_wise`).
- İçe aktarma (editör kapalıyken): `--headless --path . --import` (sonra `.mcp.json` portunu geri al).

## Yapılanlar (tamamı commit'li)
- **Simülasyon:** gizli durum + yalan söyleyen raporlar, ortak bilgi ve eşik kaskadı/darbe, emir kanalları, operasyonlar, şantaj/araştır/kırmızı çizgi, söz defteri, 3 zorluk, 117 olay kaydı (101 karar + 16 aktör hamlesi), 15 başarım, tarihçiler, Hakikat Dosyası + grafik, arşiv, otomatik kayıt.
- **Arayüz turları 1–3:**
  - akış şeridi
  - sekmeli oyun sonu
  - sayfalı menü (4 düğme, Yeni Oyun'da zorluk, Ayarlar ayrı sayfada)
  - masada ışık ve gölge (`desk_lit` / `desk_shadow` gölgelendiricileri)
  - masa etiketlerinin altında tek satır özet
  - kişi paneli göstergeleri
  - ortak görsel imza (`UIKit.band_style`, `ornament`, `divider`, `caps`, `_section`)
  - tam dolu portre kartları
- **Üçüncü oturum:**
  - Proje analizi raporu verildi (aşağıdaki "Yol haritası" ondan çıktı).
  - 11 projeye özel skill eklendi (`.claude/skills/`, `docs/SKILL_KULLANIMI.md`).
  - **Boş masa arka planı yerleşti:** yeni `art/bg_desk.png`, eskisi `art/_arsiv/bg_desk_esyali.png`; `desk_view.gd` `LAYOUT` yeni masaya göre ayarlandı.
- **Dördüncü oturum: Meclis görüşleri (Faz 1'in ilk maddesi) — tamamlandı**
  - Tasarım: `docs/design/danisman_gorusleri.md` (GDD, ölçümler, uygulamada değişenler §14).
  - Her karar kartında iki danışman (taraf olan + uzman) bir seçenek önerir, gerekçesi doğru ama seçicidir; ÇIKARI VAR etiketi; darbeye hazır olan kötü önerir; korkan meclis kaçamak konuşur.
  - Oyun sonu Hakikat Dosyası'nda Meclis Sicili, Özet'te "seni en çok X yanılttı".
  - `Sim.choice_value(fx)` tek doğruluk kaynağı; **sadakat terimi eklendi** (eski formül sadakati saymıyordu; tavan bot %80 → %95).
  - `probe_template`: `advice_naive`, `advice_weighted`, `advice_kessler` botları, `--bots=` süzgeci. `sim_test`: meclis testleri. `ui_shots`: `1_karar`, `5_son_3_meclis`, `--only-decision`.
- **Dördüncü oturum (devam): Darbe aşamaları ve alametler (Faz 1) — tamamlandı**
  - Tasarım: `docs/design/darbe_asamalari.md` (§11 ölçümler, §14 uygulamada değişenler).
  - Komplo aşamalı (sakin → huzursuz → komplocu → hazırlıkta) ve **geri çekilebilir**. Haber şeridinde "ALAMET: …" (bir kısmı dedikodu), kişi kartında ŞÜPHELİ/TEHLİKELİ, panelde "Tavır" göstergesi.
  - Darbe koşulu oluşunca **kriz kartı**: sadık birlikleri topla / taviz ver (giderek zorlaşır) / halka seslen. Çözülmezse ertesi hafta darbe. Krizde meclis susar.
  - Yeni eylem **Huzura Çağır** (izsiz; komplocu çoğu zaman ele verir, temiz çıkanın dedikoduları silinir).
  - Oyun sonu: Komplo Defteri, Özet'te "ilk kıvılcım", kayıp metninde darbe gecesi.
  - Hatalar: İstihbarat raporu komployu ölçmüyordu; hafta ortası oyun sonunda mesai döngüleri sonsuza dönüyordu (`_end` mesaiyi sıfırlar).
  - Zorluk yeniden ayarlandı (tablo tasarım belgesi §14).
- **Dördüncü oturum (devam): Ana ekran sadeleştirme (UX turu 4)**
  - Kullanıcı: "ilk sayfa kalabalık; özellik silme, gerekirse taşı; ilk girince ne yapacağını anlasın". Ayrıntı: `docs/ux/ana_ekran_sadelestirme.md`.
  - Eylemler kategori sekmelerinde; raporlar sağ sütunda kaynaklarının altında; ilk 3 haftada "Bu hafta ne yapmalı?" yol göstericisi; kompakt bildirim ve kâtip notu; mobil kartlar kısaldı.
  - Analiz raporunun durumlu sürümü: `docs/YOL_HARITASI.md` (yapılan / kalan).
- **Beşinci oturum: Görsel dil v2 ("devlet arşivi" cilası)**
  - Kullanıcı: "renk/tasarım fena değil ama daha profesyonel olsun". Ayrıntı ve kabul ölçütleri: `docs/ux/gorsel_dil_v2.md`.
  - Nötrler sıcak kömüre çekildi (mor kayma gitti; `UIKit.HOVER/SHADE/PLATE`), gövde fontu IBM Plex Sans (`UIKit.sans()`, metrikleri eski yedek fonta yakın, boyutlar korundu; CanvasLayer altındaki bildirim/perdeye tema ayrıca verildi), tüm kutular en fazla 3 px köşe (`UIKit.RADIUS`), köşebentli paneller çift çerçeve (iç kıl çizgisi), düğmeler 1 px kalkık, sekmeler üst çizgiyle seçili, alamet şeridi, rapor satırında yalnızca sol renk çizgisi, oyun sonu başlık bandı.
- **Beşinci oturum (devam): Medya Merkezi v2** — ayrıntı `docs/ux/medya_merkezi_v2.md`.
  - Gazeteler: kâğıt shader'ı (lif, sararma, katlanma izi), yarım ton fotoğraf baskısı + fotoğraf yazısı, künye kulakçıkları ve çift çizgi, iki yana yaslı serif gövde ("BAŞKENT —"), "Devamı sayfa N'de", çift çerçeveli ilan. Serbest Kalem kendi kimliğinde: gri ucuz kâğıt, kırmızı blok, kalın sans logo.
  - Halden TV: çizilmiş ceviz kasalı tüplü televizyon (VELTRON, düğmeler, hoparlör, güç ışığı); `crt.gdshader` ekran dokusunu okuyup görüntüyü ve kanal grafiklerini birlikte eğer (tarama, fosfor maskesi, parazit). Alt üçlü bant ve "HABERLER" bloklu şerit. Ekran boyutu eldeki alana göre (mobil sığar).
  - Hata: TV şeridi `ALAMET:` satırlarını yayınlıyordu (kralın gizli gözlemleri); `press.gd::broadcast` filtreler. `scanlines.gdshader` kaldırıldı. `ui_shots.gd` artık Serbest Kalem ve TV görüntüsünü de alır (`1_medya_serbest`, `1_medya_tv`).
  - Yayın durdurma mührü: prompt `ART_PROMPTS.md` (`art/media/yayin_muhru.png`, saydam ya da beyaz zemin). Kod hazır (`media_view.gd::_build_closed`, çarpma karışımı); görsel yerleşti (beyaz zemine yassılaştırılmış; çarpma karışımı saydamlığı yok sayar).
- **Beşinci oturum (devam): Gündemde "BU HAFTA" defteri** (masaüstü): karar kartlarının altında haftanın eylem sonuçları (`main.gd::_add_week_ledger`, `_week_log`); boşken sıradaki adımı söyler. Açılış/yükleme mesajı deftere girmez. Mobil TV kasası alt kenara taşmıyor.
- **Beşinci oturum (devam): Faz 1 tamamlandı** — `docs/design/faz1_okunabilirlik.md`.
  - `Sim.week_changes` (`_visible_snapshot` / `_diff_visible`, `end_week` içinde): yalnızca görünür göstergelerin farkı (rapor tonu, güç kademesi, tavır, düşmanlık, sözler, KULİS/MANŞET, kendiliğinden çözülen kararlar), en çok 6 satır, rng tüketmez. Gündemde "GEÇEN HAFTADAN BERİ" (masaüstü + mobil).
  - `Sim.report_prev`: rapor satırında çizilmiş yön oku (raporun söylediği bandın değişimi). İkisi de kayda yazılır.
  - Eylem önizlemesi: `main.gd::ACTION_META` + `_preview()` (mesai, servet, iz, tahmini risk; seçili kişiye göre bağlam). `Sim.power_tier()`, `Sim.BRIBE_COST` tek kaynak.
  - Hatalar: ertelenen kararların "ERTELENDİ" haberi eklendiği anda siliniyordu (`weekly_news.clear()` sırası) — artık oyuncuya ulaşıyor. TV şeridi yalnızca OLAY satırlarını yayınlar (önceden söz ve soruşturma notları da sızıyordu). Kategori sekmesi koddan değişince iki sekme basılı kalıyordu.
  - Mekanik değişmedi: `--full` sonucu birebir aynı (tohum 101, aynı ünvan, 54 olay).
  - Yayın durdurma mührü yerleşti (`art/media/yayin_muhru.png`).
- **Beşinci oturum (devam): Faz 0 güvence**
  - Kayıt sürümü: `Sim.SAVE_VERSION` (şimdi 3), `_migrate_save` (1 -> 2 -> 3), `SAVE_REQUIRED` denetimi `new_game`'den önce; yeni sürüm/eksik alan/bozuk dosya çökmeden reddedilir, menüde nedeni pencerede gösterilir (`Sim.load_error`). Test: `tests/save_test.gd`.
  - Olay doğrulayıcısı: `tests/event_check.gd` (71 olay temiz). Kendisi de sınandı: bilerek bozulmuş kopyada 8 hatanın 8'i yakalandı (`-- --file=`).
- **Beşinci oturum (devam): İkinci yıl paketi** — `docs/design/ikinci_yil.md`.
  - 30 yeni olay (71 -> 101): Bedellerin Dönüşü (oyuncu geçmişine bağlı; yeni koşul `min_stat`/`max_stat`), Hesaplaşma (ordu muhtırası, Halden'in meclisi, çadır kent, soylular meclisi, Saray dosyası, gölge kabine), ortam olayları, iki zincir devamı. Hepsi mevcut görsellere bağlı.
  - Tempo: 57–96 dilimleri 0,6 -> 0,8–1,1 olay/hafta. Denge (advice_weighted): Kolay 85, Normal 48, Zor 21 (bantta).
  - Açık: kayıp çeşitliliği değişmedi (~%95 darbe). sim_test ulaşılabilirlik kontrolü `min_stat` ve `min_week`'i artık hesaba katıyor.
- **Beşinci oturum (devam): Kayıp çeşitliliği** — `docs/design/kayip_cesitliligi.md`.
  - Teşhis: ayaklanma ve yetkisizlik yolları ölüydü (eşik 100, aktif oyuncuda en yüksek huzursuzluk ~40, yargı baskısı ~30). Bastırma bedelsizdi, her yol Arden'in darbesine çıkıyordu.
  - Sokak öfkesi (bastırma borçtur), ayaklanma krizi (huzursuzluk ≥ 54), yetki krizi (yargı baskısı ≥ 40); darbe kartı kalıbında, o hafta çözülmezse düşüş. SOKAK/MAHKEME uyarı satırları, Bastır önizlemesinde öfke uyarısı. Kayıt sürümü 3.
  - Sonuç: kayıp oyun tarzına bağlı (kirli %16, yumuşak %11, bastıran %4 darbe dışı). Ölçüt bot Kolay 81, Normal 40, Zor 18 (bantta). Sondaja `advice_soft` / `advice_dirty` botları eklendi.
  - Açık: darbe hâlâ baskın; daha fazla çeşitlilik için darbe sıklığının kendisi düşürülmeli.
- **Beşinci oturum (devam): Rüşvet ölçümü ve aktör hamleleri**
  - Rüşvete azalan getiri: istismar botuyla ölçüldü, gerek yok (rüşvet botu Kolay %51 / Normal %40 / Zor %20; mahkeme yolu bedeli yaratıyor).
  - Aktör hamleleri (`docs/design/aktor_hamleleri.md`): 16 seçeneksiz `hamle_*` olayı; "HAMLE: ..." haberi, özet bölümünde portreyle; haber şeridi önceliği (kriz/alamet önce, hamle sonda). Prens hamleleri darbe hesabını bozduğu için işarete çevrildi. Ölçüt bot Kolay 80, Normal 41, Zor 27.
  - Testler: `event_check` seçeneksiz olayı ayrı denetler; `pacing_test` hamleleri saymaz; sim_test ulaşılabilirlik kontrolü aktör koşullarını da sağlar; `--full` UI testi dikkatli oynar (haftada en çok bir ödeme, krizde uzlaşma).
- **Beşinci oturum (devam): main.gd bölme** — `docs/TECH_DEBT.md`.
  - 3249 -> 2548 satır: `autoplay.gd`, `end_screen.gd`, `menu.gd`, `modal.gd`. Her adım ayrı commit, davranış aynı (`--full` aynı tohum/sonuç, görüntüler aynı). Desen ve sıradaki adımlar (gündem -> `agenda_view.gd`, kişi paneli -> `person_panel.gd`) belgede.
- **Beşinci oturum (devam): Birbirine Düşür — Faz 2 tamamlandı** — `docs/design/birbirine_dusur.md`.
  - Operasyon sekmesinde yeni eylem: çoklu seçimle tam iki kişi, 2 mesai, aynı çift için 6 hafta bekleme (`Sim.divide_rivals`, `rival_wait`). Başarıda ikisi de güç -4 / hırs -3; başarısızlıkta ikisi de kimin yaptığını anlar (hırs +6, para sadakati -4, "dusurme" sırrı); %15 sızıntı sırrı. Önizleme, ipucu, kayıt testi (`_test_rivals`) ve sondaj botu (`advice_scheme`) eklendi.
  - Ölçüm: ilk sürüm Normal'de ölçüt botu %41 -> %55 yapıyordu; hırs etkisi -5 -> -3'e indirilerek %52'ye çekildi. Kolay'da kullanmak daha az kazandırıyor (başarısız denemelerin sırları mahkeme yolunu besliyor): bedelsiz bir güç değil.

### Oturum özeti (beşinci oturum, 2026-10-05/06) — neler değişti
Görünüm: sıcak palet, keskin köşeler, çift çerçeve, IBM Plex Sans gövde fontu, gerçekçi gazeteler (kâğıt/yarım ton) ve tüplü TV. Okunabilirlik: "Geçen haftadan beri", rapor yön okları, eylem önizlemesi, "Bu hafta" defteri. Güvence: kayıt sürümü (3), olay doğrulayıcısı. İçerik: 30 ikinci yıl olayı + 16 aktör hamlesi (toplam 117 kayıt). Denge/derinlik: sokak ve mahkeme krizleri (bastırma borç), Birbirine Düşür; rüşvet ölçüldü (gerek yok). Altyapı: main.gd 3249 -> 2548 satır (4 bileşen ayrıldı), `docs/TECH_DEBT.md`. Test araçları: `event_check.gd`, `save_test.gd`, sondaj botları `advice_soft/dirty/scheme`, `--keep=` yalıtma yöntemi (bkz. aktor_hamleleri.md).

## Ölçülmüş denge (2026-10-06, `probe_template`, 80 kampanya, tüm değişikliklerden sonra: 117 olay, krizler, hamleler, Birbirine Düşür)
| Bot | Kolay | Normal | Zor |
|---|---|---|---|
| visible (görüşsüz) | 30% | 21% | 5% |
| advice_weighted (**ölçüt**) | 80% | 41% | 27% |
| advice_soft (hiç bastırmaz) | 76% | 41% | 31% |
| advice_dirty (yazılı emir, şantaj) | 53% | 33% | 22% |
| advice_scheme (iki şüpheliyi düşürür) | 70% | 52% | 22% |
| visible_wise (tavan) | 98% | 92% | 72% |

Hedef bantlar (ölçüt bot): Kolay %70–85, Normal %35–55, Zor %15–30. Tarz botları kaybın oyun tarzına bağlı olduğunu gösterir (kirli oynayan mahkemeyle, sokağı bastırmayan sokakla yüzleşir). Tempo: 57–96. haftalar her dilimde ~0,7–1,1 olay/hafta (hamleler sayılmaz). Kayıpların çoğu hâlâ askerî darbe; darbe dışı pay ölçüt botta düşük (~%4–10).

## Yol haritası (durumlu tam sürüm: `docs/YOL_HARITASI.md`)
- **Faz 0 Güvence:** ✅ boş masa · ✅ görünür bilgi botu · ✅ kayıt sürümü ve göç · ✅ olay doğrulayıcısı · 👤 kendi depo (kullanıcıda)
- **Faz 1 Okunabilirlik:** ✅ danışman görüşleri · ✅ aşamalı darbe · ✅ rapor değişimi ve "neler değişti" · ✅ eylem önizlemesi
- **Faz 2 Strateji derinliği:** ✅ kayıp çeşitliliği (kısmi) · ✅ rüşvet (ölçüldü, gerekmedi) · ✅ Birbirine Düşür · ✅ aktör hamleleri
- **Faz 3 Kampanya ve içerik: ✅** dönemler · ✅ ikinci yıl olayları · ✅ karakter hikâye yayları · ✅ rejim tipi ve buna bağlı final tehdidi
- **Faz 4 Büyük sistemler:** ⬜ devlet bütçesi/kapasitesi (Tasarım Özeti §24) · ⬜ patronaj/oligark (§17)
- **Faz 5 Cila ve altyapı:** ⬜ gerçek ses/müzik · ◐ main.gd bölme (kalan: gündem, kişi paneli) · ⬜ artırımlı yeniden çizim · ⬜ yerelleştirme

## KALAN İŞLER (öncelik sırasıyla)
**Sizin (kullanıcı) yapmanız gerekenler**
1. 👤 **Kendi deponu aç** (GitHub/GitLab). Kodun uzak yedeği yok; en yüksek risk. Bağlamayı ben yaparım.
2. 👤 **Tam bir saltanat oyna (Normal)** ve not al: Normal fazla zor/kolay mı? Krizler (ayaklanma, yetki, darbe) adil mi, uyarı yeterli mi? Aktör hamleleri dünyanın yaşadığı hissini veriyor mu? Metinler (özellikle 30 yeni olay, ilk taslak) uyuyor mu? Açık tasarım soruları: `danisman_gorusleri.md` §13, `darbe_asamalari.md` §13.
3. 👤 `export_presets.cfg` değişikliğinin bilinçli olup olmadığını doğrula. `.cursor/mcp.json` portu 8770.
4. 👤 İsteğe bağlı görsel üretimi: yeni olaylar mevcut görsellere yaklaşık eşleştirildi; özel görsel istenenler (muhtıra, çadır kent, maden faciası, kuraklık, soylular meclisi, Saray dosyası): prompt'ları ben hazırlarım (`/asset-spec`).

**Geliştirme (benim)**
5. **Faz 4:** devlet kapasitesi/bütçesi (§24) ve patronaj/oligark (§17). Büyük sistemler: önce `/design-system` ile GDD, ayrı oturum.
6. **Faz 5:** gerçek ses ve müzik (şimdi sentez; kullanıcı dosya sağlar ya da prompt verilir); `main.gd`'nin kalanı (`docs/TECH_DEBT.md`: gündem -> `agenda_view.gd`, kişi paneli -> `person_panel.gd`); `sim.gd` içeriğini (PHRASES, SIGN_TEXTS, ACHIEVEMENTS) JSON'a; `_refresh` artırımlı çizim; `tr()` ile yerelleştirme.
7. **Dağıtım:** Faz 3 kodunu içerecek yeni Windows/Linux/Web paketlerini sonraki sürümde export et; 1.1.0 paketleri önceki içeriktir.
8. **Denge açıkları:** darbe hâlâ baskın kayıp (ölçüt botta darbe dışı ~%4–10): darbe sıklığı düşürülebilir ya da sokak/mahkeme yollarına daha çok sürekli baskı eklenebilir. Alamete tepki vermek botta nötr: oyuncu "gördüm ama işe yaramadı" derse Huzura Çağır güçlendirilmeli. Zor'da `visible_wise` ~%70'lerde (tavan hedef değil, ama izlenmeli).
9. **Küçük içerik/teknik:** meclis görüşü metinleri danışmana özgü değil (söyleyiş eklenebilir); olay görselleri için `_b` varyantları; sim_test botları rüşvet/şantaj kullanmadığı için istatistik olaylarını "hiç tetiklenmeyen" listesinde gösterir (ulaşılabilirlik kontrolü bunları doğrular); `FULLRUN` testi 104 haftayı ilk tohumda tamamlıyor, diğer tohumlar çoğu zaman düşüyor (bot basit).

## Bilinen küçük sorunlar
- Sağ üstteki bildirimler masa ve haritanın, mobilde alamet şeridinin üstünde kalıyor (masaüstünde şerit artık bildirim sütununa girmiyor).
- Aynı çift için Birbirine Düşür bekleme süresi 6 hafta; bot sondajında yalnızca "tavır" göstergesi olan çiftler seçiliyor, gerçek oyuncu daha zekice seçebilir (ölçüt botun üstünde kalabilir).
- Yeni olay metinleri gerçek oyuncu gözüyle tam kampanyada görülmedi; mühür/TV/gazete görünümü masaüstü ve web görüntülerinde denendi.
- Masada soldaki günlük lambadan uzak olduğu için karanlık kalıyor; okunurluk için `desk_lit` `ambient` ya da günlüğün yeri ayarlanabilir.
- Meclis görüşü metinleri genel kalıplardan kuruluyor (danışmana özgü ses yalnızca kılıf cümlelerinde). İçerik turunda danışman başına söyleyiş eklenebilir.
- Kullanıcı henüz tam bir saltanat oynamadı; denge, metin ve ses geri bildirimi bekleniyor. Linux paketi üretildi ama Linux üzerinde çalıştırılamadı. Android/iOS kasıtlı yapılmadı.

## Kullanıcı tercihleri
Sormadan ilerle; büyük özellikte önce tasarla (`CLAUDE.md`). Sonuçta kısa Türkçe özet. Commit'e izin var, push yok.
