# Gece görevi: İngilizce sızıntı taraması, canlılık, ilk açılış turu

Bu dosya kalıcı görev tanımıdır. Üç dilimi SIRAYLA, DURMADAN, kullanıcıya SORMADAN uygula. Belirsizlikte en makul seçimi kendin yap ve docs/ux/GECE_ILERLEME.md içine "Kararlar" başlığıyla yaz. Her dilim sonunda ilerleme dosyasını güncelle ve commit'le; sonraki dilime geç. Yalnızca üç dilim de bitince (ya da aşılamayan bir engelde, nedenini yazarak) dur ve kısa Türkçe rapor ver.

## Değişmez kurallar
- Önce oku: docs/ux/gundem_v2_gorev_promptu.md (kurallar aynen geçerli), docs/i18n/gorev_promptu.md (çeviri kuralları), CLAUDE.md. Oyun mantığı (Sim, RNG, denge) DEĞİŞMEZ.
- PUSH YOK. Her mantıksal adım AYRI commit. Commit'e GİRMEYENLER: .mcp.json, .cursor/, export_presets.cfg, project.godot, art/portraits/PROMPTS.md, art/portraits/overview.png(.import), audio/_kaynak, docs/marketing. Godot --import portları 8772 yaparsa 8770'e geri al. Çalışan editörü (konsol olmayan Godot exe) ASLA kapatma. Düzenleme betiklerini heredoc ile değil dosyayla çalıştır (Türkçe karakter).
- Test: $G = C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe. Başsız: sim_test, event_check, save_test, content_check, i18n_check. Pencereli: ui_input_test (masaüstü ve -- --mobile), touch_scroll_test, cutscene_check, audio_check. --autoplay, --autoplay --mobile, --autoplay --full (--full tohum 101: hafta 104, TAHTTA, Medya Rejimi, 112 olay, tr ve en AYNI). Ölçüt probe .claude/skills/balance-check/probe_template.gd: 68/80, 36/80, 16/80 (Kolay/Normal/Zor) tr ve en birebir aynı.
- Başsız testler arayüzü denetlemez: her dilim sonunda tests/ui_shots.gd ile ekran görüntüsü al (masaüstü + -- --mobile, TR + --lang=en), PNG'leri AÇ ve gözle kontrol et.

## DİLİM 1 — İngilizce'de kalan Türkçeyi bul ve çevir (tam tarama)
Kullanıcı şu sızıntıları gördü (hepsi mutlaka düzelsin, ama bunlarla sınırlı değil):
- Gündem'in üstündeki sekmelerin (Agenda / People / Reports) hemen üzerindeki şeritte: "Fırınlar önünde kuyruk eridi; ama..." gibi haber/bildirim cümleleri.
- "Soruşturma 1 mesai iz yok" ve "İstihbarat gibi güçlü birine verilirse" gibi eylem açıklamaları; Kazan, Söz Ver, Öğren, Emret, Baskı, Operasyon, Devlet sekmeleri ve düğmelerin ALT AÇIKLAMALARI/ipuçları (tooltip_text dahil).
- Masa ekranında "ERTELENDİ — Taç giyme töreni..." gibi bildirimler.
- Hafta geçişi perdesi (HAFTA N, başlık/özet cümleleri).
Yöntem:
1. Yeni tests/en_leak_test.gd (pencereli): --lang=en ile oyunu başlat; ana ekranın her sekmesini, her eylem sekmesini, Divan'ı, Masa, Medya (üç kanal), Harita, Dosyalar, Günlük, Menü, Ayarlar, modalları, ara sahneleri (cutscenes.json), oyun sonu ekranının tüm sekmelerini gez; her Label/RichTextLabel/Button/TabContainer sekmesi/ProgressBar/tooltip_text metnini topla. Türkçe sızıntı ölçütü: Türkçe'ye özgü harf (çğıöşüİÇĞÖŞÜ) VEYA Türkçe sık sözcük listesi (ve, bir, için, bu, ile, gibi, olarak, daha, çok, kadar, ama, ancak, veya, ise, değil, var, yok, mesai, hafta, karar, kişi…). Özel ad izin listesi (Veloria, Sarne, Arden vb.) olsun. Bulunanları dosya:satır ve ekran adıyla raporla.
2. Kök nedenleri çöz: (a) tr("...") ile sarılmamış arayüz dizgileri, (b) Sim/narrative/press/advice içinde ÜRETİLEN metinler (haber, rapor, günlük, bildirim, neden/ipucu cümleleri, "iz yok" gibi eylem sonuçları; Loc.ntr çoğul, Sim.ek() Türkçe ek, Loc.poss İngilizce iyelik), (c) game/data/*.json içeriği için eksik game/data/en/*.json kaplamaları, (d) format dizgilerine gömülü Türkçe sözcükler ("%s mesai" gibi), (e) sabit listelerdeki Türkçe (eylem adları, durum etiketleri, rejim adları gösterimi). İç anahtarlar/kimlikler Türkçe kalabilir, gösterimde çevrilir.
3. Sim mantığını ve RNG tüketimini DEĞİŞTİRME; yalnızca metin katmanı. İngilizce sentence case, kıvrık tırnak standardı, cinsiyet tablosu (docs/i18n kurallarına bak) geçerli.
4. Üretilen metinler için de tarama: en az 5 tam kampanyayı (Kolay/Normal/Zor, farklı tohumlar, --lang=en autoplay) oynayıp Sim.history, Sim.weekly_news, raporlar, günlük ve görünen bildirimleri aynı sızıntı ölçütüyle denetle. SIFIR sızıntı hedefi.
5. tests/en_leak_test.gd KALICI test olsun; i18n_check ile birlikte çalışsın. Kapı: sızıntı 0; tüm testler; --full tr/en aynı (101/104/TAHTTA/Medya Rejimi/112); probe tr/en tabanla aynı.
6. Ekran görüntüsü: --lang=en masaüstü + mobil, Gündem (karar, eylem sekmeleri, tüm 7 eylem sekmesi), Masa, Medya, Harita, Dosyalar, Günlük, Menü, hafta geçişi perdesi, oyun sonu; hepsini aç, Türkçe kalmış satır var mı gözle kontrol et.

## DİLİM 2 — Oyun %25 daha canlı
Sorun: oyun fazla soluk. Hedef: genel görünüm yaklaşık %25 daha canlı (doygunluk ve kontrast), ama okunabilirlik ve atmosfer korunsun (koyu, altın, siyasi gerilim).
Yöntem (ölçülebilir):
1. Önce "önce" ekran görüntülerini al (masaüstü + mobil, TR): Menü, Gündem (karar kartı açık), Masa, Medya, Harita, oyun sonu. PIL ile her biri için ortalama HSV doygunluğu (S) ve parlaklık (V) hesapla.
2. Canlandırma yolları (hangisi gerekirse): UIKit paletini (GOLD, TEXT, DANGER, OK, AMBER, REPORT_BLUE) doygunluk/parlaklık açısından artır; panel/zemin koyuluğunu bir miktar aç (PANEL, PANEL_HI, HOVER) ama metin kontrastı (WCAG >= 4.5:1) korunsun; arka plan görsellerinin üstündeki koyu örtüleri (ColorRect SHADE/perde alfaları, atmosphere/desk_lit/crt/newsprint shader'ları, vinyet) azalt; portre ve olay görsellerinin doygunluğunu görüntüleme anında artırmak için hafif bir renk derecelendirme (ör. CanvasLayer + ColorRect + canvas_item shader: doygunluk x1.25, kontrast x1.08, parlaklık x1.04) ekleyebilirsin. Tercih: önce palet + örtü azaltma, gerekirse hafif tek bir global derecelendirme; çok katmanlı karmaşa ekleme. Ayarlar'a "Canlılık" aç/kapa EKLEME (varsayılan canlı).
3. Kapı: "sonra" ekran görüntülerinde ortalama S en az +%20..+%30 (hedef ~+%25), V +%0..+%10 arası; okunabilirlik bozulmasın (metin, rozet noktaları, kart kenarları). Kırmızı = düşman/komplo belirtisi gibi anlamlı renkler karışmasın. Önce/sonra yan yana karşılaştırmayı docs/ux/canlilik_oncesi_sonrasi.md içine yolları ve sayılarıyla yaz.
4. Test: tüm başsız/pencereli testler, --full tr/en, probe aynı. Her ekran görüntüsünü AÇ ve gözle kontrol et (çok parlak/yapay mı, metin okunuyor mu, kırmızı/yeşil anlamları korunmuş mu, mobil dahil).

## DİLİM 3 — İlk açılış yol göstericisi (tur)
docs/ux/ilk_acilis_turu_gorevi.md dosyasını oku ve BAŞTAN SONA uygula (tasarım belgesi, kod, tr + en metinler, tests/tour_test.gd, ekran görüntüleri). Dilim 1'in sızıntı testi turun İngilizce metinlerini de kapsasın (tur adımlarını en_leak_test içinde gez). Dilim 2'nin canlılığı turun kutularında da geçerli olsun.

## Bitiş raporu (kısa, Türkçe)
Her dilim için: commit'ler, test çıktıları (--full satırı, probe), kaç sızıntı bulundu/çevrildi, canlılık önce/sonra sayıları, ekran görüntüsü yolları ve her biri için neyi gözle kontrol ettiğin, açık sorunlar. docs/ux/GECE_ILERLEME.md'yi güncelle.
