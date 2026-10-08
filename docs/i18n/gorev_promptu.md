# İngilizce yerelleştirme — görev promptu (kalıcı kopya)

Bu dosya, ilk oturumun promptunun kalıcı kopyasıdır. Yeni bir oturum başladığında önce bunu, sonra `docs/I18N_ILERLEME.md` dosyasını oku. Kurallar aynen geçerlidir.

## ÇALIŞMA BİÇİMİ (bağlam dolmasın diye; yeni)
- Bir oturumda yalnızca ilerleme dosyasındaki "SIRADAKİ ADIM"dan başlayarak BİR KAPSAM bitir (aşağıda "Oturum kapsamları"). Kapsam bitince dur ve rapor ver; rapor yazıp durma kuralı yalnızca kapsam sonunda geçerlidir. Kapsamın ortasında rapor yazma, sıradaki dosyaya geç.
- Büyük dosyaları (sim.gd, person_panel.gd, main.gd) tek seferde okuma: `tools/i18n_scan.py` çıktısındaki satır numaralarıyla bölümler hâlinde (~150 satır) oku, çevir, commit'le.
- Çıktıları kısa tut (uzun dosya içeriği ve test çıktısı yapıştırma); yalnızca özet ve OK/FAIL satırları.
- Başsız testler arayüz metnini DENETLEMEZ. Her kapsam sonunda pencereli `ui_shots.gd`'yi hem varsayılan (Türkçe) hem `--lang=en` ile çek, PNG'leri aç ve Türkçe modda ekranın TAMAMEN Türkçe, İngilizce modda İngilizce olduğunu gözle doğrula (S1'de Godot yedek dili "en" olduğu için Türkçe modda İngilizce görünmesi hatası böyle kaçtı; project.godot `locale/fallback="tr"` olmalı).
- Her commit sonrası ilerleme dosyasının "SIRADAKİ ADIM" satırını güncelle ve commit'le (bağlam kesilirse yeni oturum oradan devam eder).

## Oturum kapsamları (sırayla)
- S1: L2 — menu.gd kalan metinler (yardım, künye) + main.gd + agenda_view.gd + ui_kit.gd + truth_chart.gd + autoplay.gd.
- S2: L2 — person_panel.gd (ACTION_META dahil) + desk_view.gd + city_view.gd + media_view.gd + end_screen.gd; L2 kapısı (ekran görüntüleri masaüstü+mobil).
- S3: L3 — sim.gd'nin ilk yarısı (mantıksal bölümlerle, bölüm başına commit).
- S4: L3 — sim.gd'nin kalanı + narrative.gd + press.gd + advice.gd + content_data.gd hata mesajları; L3 kapısı.
- S5: L4 — content_*.json ve actors.json çevirisi (game/data/en/); L4 olay partileri 1–4.
- S6–S9: L4 — events.json partileri (parti ≈ 15 olay; alt ajan kullanılabilir), her oturumda ~50 olay.
- S10: L5 — ui_shots --lang=en, tam ölçüm, rehber, 1.5.0, paketler.

══════ ORİJİNAL PROMPT ══════

Veloria adlı bir Godot 4.7.2 strateji/simülasyon oyunu üzerinde çalışıyorsun (şu an yalnızca Türkçe). Proje: C:\Users\USER\Desktop\oyun, dal: veloria. Görev: oyuna İNGİLİZCE dil desteği eklemek ve tüm metni İngilizceye çevirmek. Türkçe oyun birebir aynı kalacak; İngilizce, oyun mantığını hiç değiştirmeyen bir dil katmanı olacak.

BAĞLAM
ÖNCE OKU (sırayla): CLAUDE.md, docs/DURUM_VE_YAPILACAKLAR.md, .claude/skills/game-design/VELORIA.md (mimari, olay şeması, komutlar, tuzaklar), docs/TECH_DEBT.md, docs/design/icerik_verisi.md, docs/design/yeni_kadro.md, docs/i18n/envanter.md, docs/i18n/sozluk_en.md, docs/I18N_ILERLEME.md.

OYUN: Kral Adrian IV 104 hafta tahtta kalmaya çalışır; oyuncu sayıları göremez, yalnızca yalan söyleyebilen insanların raporlarını okur. Mantık game/core/sim.gd (autoload "Sim"), meclis advice.gd, anlatı narrative.gd, basın press.gd, ses sfx.gd, veri okuma content_data.gd. Metin kaynakları: game/data/events.json (195 olay), content_*.json, actors.json, ve .gd dosyalarında gömülü Türkçe. Yazı tipleri (EB Garamond, IBM Plex Sans) Latin karakterleri karşılıyor.

DEĞİŞMEZ KURALLAR
- Önce incele, sonra kodla. Kalite > hız. Çalışan özellikleri bozma. Kayıtlar çalışmaya devam eder.
- DİL OYUN MANTIĞINI DEĞİŞTİRMEZ. Ana rng akışı, kayıt, ölçüm, tohum sonuçları dilden bağımsız. İngilizce oyunda `--autoplay --full` ve denge probe'u Türkçe ile SAYISAL OLARAK AYNI sonucu verir.
- "Sayı yok" ilkesi, web glifi kuralı (→ ◆ ✓ ★ ⏳ kullanma), `class_name` yok / `preload`, görünmez Control'lerde mouse_filter IGNORE: aynen geçerli.
- Düzenleme betiklerini heredoc ile değil, dosyaya yazıp çalıştır (Türkçe karakterler bozulur). Komutları zaman sınırıyla çalıştır; script hatasında --script süreci kapanmayabilir.
- Testler HER ZAMAN Türkçe kilitli çalışır (Loc varsayılanı tr; başsız modda sistem yerelini KULLANMA).

TEST ($G = C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe)
  & $G --headless --path . --script res://tests/sim_test.gd        -> "TEST: OK"
  & $G --headless --path . --script res://tests/event_check.gd     -> "EVENTS: OK"
  & $G --headless --path . --script res://tests/save_test.gd       -> "SAVE: OK"
  & $G --headless --path . --script res://tests/content_check.gd   -> "CONTENT: OK"
  & $G --headless --path . --script res://tests/i18n_check.gd      -> "I18N: OK"
  & $G --path . --script res://tests/ui_input_test.gd              -> "UI INPUT: OK" (pencereli)
  & $G --headless --path . -- --autoplay (ve --autoplay --mobile, --autoplay --full: tohum 101: 104 hafta, TAHTTA, Medya Rejimi, 112 olay)
  tempo: tests/pacing_test.gd (hiçbir dilim < 0,8)
  ekran görüntüsü (pencereli): ui_shots.gd -- --out=KLASÖR [--mobile] [--state] [--lang=en]; PNG'leri aç ve gözle kontrol et.
DENGE: .claude/skills/balance-check/probe_template.gd --n=80 --all-diffs --bots=advice_weighted; ölçüm sırasında oyun dosyalarını düzenleme, git stash/checkout yapma.

GIT
- Her mantıksal adım AYRI commit. PUSH YOK.
- Commit'e KATMA: .mcp.json, .cursor/, export_presets.cfg, BECKETT_SETUP.md, CLAUDE.md, dist/, art/portraits/PROMPTS.md, art/portraits/overview.png (+ .import). Yalnızca kendi dosyalarını tek tek `git add`.
- project.godot yalnızca sürüm satırı ve çeviri kaydı için değişir; çözünürlük 1600x900 kalmalı.
- Godot --import/export .mcp.json ve .cursor/mcp.json portunu 8772 yapabilir: işlemden sonra 8770'e geri al (.cursor kullanıcıya aittir).
- Çalışan "Godot_v4.7.2-stable_win64.exe" (konsol olmayan) süreç kullanıcının editörüdür: ASLA kapatma.

MİMARİ KARARLAR (değiştirme)
1) Kaynak dil Türkçe; Türkçe metin anahtar olarak kalır. Statik arayüz/sistem metinleri `tr("Yeni Oyun")`; çeviri gettext `game/i18n/en.po` (msgid = Türkçe kaynak, msgstr = İngilizce; çok satırlı ve biçim dizeli metinler dahil).
2) İçerik için KAPLAMA (overlay) dosyaları: `game/data/en/events.json` (id -> {title, text, news, choices:[{label,text}], ignore:{text}}), `game/data/en/content_*.json` (aynı yapı, aynı anahtarlar, aynı dizi uzunlukları), `game/data/en/actors.json` (id -> name, title, red_line, weak_point). Mantık alanları YALNIZCA ana dosyalardadır. Eksik İngilizce giriş olursa Türkçe düşer ve doğrulayıcıda hata olur.
3) Dil seçimi: `Loc` yardımcısı; menü > Ayarlar'da "Dil / Language"; ilk açılış Türkçe; kampanya dili KAYITTA saklanır; kayıtlı bekleyen metinler oluşturuldukları dilde kalır (kabul edilmiş sınırlama; belgeye yazılı).
4) Türkçe metin kimlik olarak kullanılan yerler (söz ödülleri "Naiplik", "Liman İhalesi", "Dokunulmazlık"; rejim ve etiket adları; ünvanlar; başarım adları; kurum/alan adları) İÇ ANAHTAR olarak Türkçe KALIR, yalnızca GÖSTERİLİRKEN çevrilir. Anahtar karşılaştırmasını çevrilmiş metinle YAPMA.
5) Ek uyumu: `Sim.ek(isim, "e"|"in"|"i")` Türkçe kalır. İngilizce şablonlar ek kullanmaz; dile bağlı yardımcı (`Loc.poss(name)` -> "Vale's"). `ek(...)` içeren her şablon için İngilizce şablonu AYRI tr() girdisi olarak yaz (parçalardan cümle kurma; tüm cümleyi çevir). Büyük harf: dile duyarlı (UIKit.tr_upper Türkçe kuralı; İngilizcede normal).
6) Terim sözlüğü ve üslup: docs/i18n/sozluk_en.md'ye UY. Kişi ve yer adları DEĞİŞMEZ. Eski adlar (Halden, Kessler, Dorn, Brandt, Falk, Lena, Cassian) hiçbir yerde olmayacak.

GÖREVLER (L0 ve L1 tamamlandı)
L2 — Arayüz metinleri (statik): menu.gd, main.gd, person_panel.gd (ACTION_META dahil), agenda_view.gd, desk_view.gd, city_view.gd, media_view.gd, end_screen.gd, ui_kit.gd, truth_chart.gd, autoplay.gd, modal.gd: tüm statik Türkçe metin tr() ile sarılır; en.po'ya İngilizce karşılık. Dosya başına AYRI commit. Biçim dizeleri tr("... %d ...") % x biçimine. Tooltip'ler, uyarılar, düğmeler, sekme adları, bant adları, kademeler dahil.
 KAPI L2: Türkçe ekran görüntüleri tabanla aynı; tüm testler geçer; İngilizce modda tüm ekranlar İngilizce (karışık dil kalmaz); masaüstü + mobil (1067x600) taşma/kırpılma yok.
L3 — Simülasyon ve anlatı metinleri (dinamik): sim.gd, narrative.gd, press.gd, advice.gd, content_data.gd hata mesajları. Her cümle TAM cümle olarak tr()'a girer. Türkçe çıktı DEĞİŞMEZ (sim_test çıktısı, autoplay çıktısı, haber akışı birebir aynı; bir kayıt/yükleme turu).
 KAPI L3: Türkçe çıktılar birebir aynı; İngilizce `--autoplay --full` tohum 101 SAYISAL olarak aynı (104/TAHTTA/Medya Rejimi/112) ve olay/haber akışı aynı sırada; 80 kampanyalık ölçüt probe İngilizce modda tabanla BİREBİR aynı; gösterimde çevrilmemiş Türkçe satır kalmadı.
L4 — İçerik çevirisi: content_*.json ve actors.json, sonra events.json (195 olay) PARTİLERLE (parti ≈ 15 olay, ayrı commit; alt ajan kullanılabilir: her ajan kendi parti dosyasına yazar, birleştirme ve doğrulama sende). Çeviri ilkeleri: sözlüğe tam uyum; atmosfer (gerilimli, ironik, kısa); "Majesteleri" -> "Your Majesty"; deyimler yerelleştirilir; sayılar ve yer tutucular korunur; seçenek etiketleri kısa; aynı fikirli etiketler benzersiz.
 KAPI L4: "I18N: OK"; event_check ve content_check `--lang=en` OK; İngilizce tam kampanya çevirisiz Türkçe satır çıkarmaz; her 10 olayda bir örnek İngilizce metni gözle oku (docs/i18n/kalite_ornekleri.md).
L5 — Doğrulama ve sürüm: ui_shots --lang=en (masaüstü+mobil); tam denge ölçümü iki dilde sayısal eşit; OYUNCU_REHBERI.en.md; VELORIA.md ve belge kuralı "yeni metin = tr() + en.po / data/en kaplaması"; docs/design/yerellestirme.md; sürüm 1.5.0 (project.godot yalnızca version satırı, AYRI commit); Windows/Linux/Web export (export_presets.cfg'ye DOKUNMA; şablon eksikse dur ve bildir); web'i yerel HTTP ile aç (iki dil, dil değiştirme, oyun, DEVLET, medya); portları 8770'e geri al.

BİTİRİRKEN (her oturum kapsamı sonunda)
Türkçe kısa özet: ne değişti, commit listesi, test çıktıları, tr/en sayısal eşitlik kanıtı, bilinen sınırlamalar. git status'ta yalnızca kullanıcının dosyaları kalmış olmalı. PUSH YOK.
