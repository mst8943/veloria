# Veloria — Durum ve Yapılacaklar (yeni oturum için devir notu)

Son güncelleme: 2026-10-04. Dal: `veloria` (son commit `274e6df`). Push YOK: `origin` Beckett'in kendi deposu; kullanıcı kendi deposuna yedeklemek isterse yeni repo açıp `veloria` dalını oraya göndermeli (öneri yapıldı, cevap gelmedi).

## Proje
Godot 4.7.2, Türkçe, yatay. Kral Adrian IV, 104 hafta tahtta kalma simülasyonu. Kullanıcı: Mesut Canturk. Görselleri kullanıcı ChatGPT/Imagen ile üretiyor; ben prompt veriyorum (`ART_PROMPTS.md`). Görselleri rastgele adla `art/` köküne ya da bir klasöre atıyor; ben içeriğe bakıp (kontakt sayfası) doğru ada taşıyorum, `.import` ayarlarına boyut sınırı + lossy + mipmap uyguluyorum.

## Çalıştırma ve test
- Godot console: `C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Testler: `--headless --path . --script res://tests/sim_test.gd` (denge+sistemler), `pacing_test.gd`, `cause_probe.gd`
- Arayüz otomatik oynatma: `-- --autoplay`, `--mobile`, `--full` (Kolay seviyede 104 haftayı arayüzden oynar)
- Build: `--export-release "Windows Desktop"|Linux|Web` → `dist/windows|linux|web`; zip'ler `dist/release/`. Export sonrası `.mcp.json` portu 8770'e geri alınmalı.
- Beckett MCP (127.0.0.1:8770) editör açıkken çalışır; araçlar oturumda görünmezse HTTP JSON-RPC ile çağır. Dev bayrakları (`veloria/dev_*`) project.godot'ta KAPALI kalmalı.
- Tuzaklar: `class_name` yerine `preload`; web'de ◆ ⏳ → gibi glifler kutu çıkar; görünmez Control'ler tıklama yutar (Beckett `ui_snapshot` → `occluded_by` ile tara); yapay `push_input` tıklama testi çalışmıyor; PowerShell'de çok satırlı commit mesajı için `-m` kullan; testler oyuncu kaydına dokunmaz (`save_path`, `record_chronicle`, `autosave`).

## Yapılanlar (tamamı commit'li)
Simülasyon: gizli durum+raporlar+yalan, ortak bilgi, eşik kaskadı/darbe, emir kanalları, operasyonlar, şantaj/araştır/kırmızı çizgi, söz defteri, zorluk (Kolay/Normal/Zor), 71 olay (zincirleme dahil), başarımlar (15), tarihçiler, hakikat dosyası+grafik, arşiv, otomatik kayıt, Türkçe ek uyumu (`Sim.ek`).
Arayüz: tema, sinematikler (açılış/final/hafta geçişi/mühür), Çalışma Masası, Başkent Haritası, Medya Merkezi (2 gazete + TV), mobil yatay düzen, kısayollar, ayarlar, Hakkında, açılış ekranı, tüm görseller yerleşik (71 olayın hepsi görselli, art/desk, art/city_map.png).
Son tur (274e6df): düğme hiyerarşisi (Ghost/Danger/Choice), gruplu eylem paneli, sır kartları, bildirim yığını, iki sütun rapor.
Belgeler: `docs/OYUNCU_REHBERI.md`, `docs/GELISTIRICI_REHBERI.md`, `docs/ARAYUZ_PLANI.md`.

## Yapılacaklar (öncelik sırası; kullanıcıya önerildi, onay/yanıt bekleniyor — söylemezse 1,4,5)
1. Akış şeridi: ekranın altında "2/4 mesai · 1 karar bekliyor · medya okunmadı" gibi hafta ilerleme göstergesi.
2. Masa nesnelerinin altına tek satırlık özet ("2 karar · en acil: Kâhya").
3. Kişi paneli: düz metin yerine sayısız küçük göstergeler (renkli noktalar/simgeler).
4. Oyun sonu ekranını sekmelere böl (Özet / Grafik / Tarihçiler / Hakikat Dosyası / Kararlar).
5. Menü: ayarları ayrı sayfaya taşı; ana menü 4 büyük düğme.
Diğer: kullanıcı henüz tam bir saltanat oynamadı; geri bildirimi (denge, metin, ses) bekleniyor. Sentezlenmiş sesleri kimse dinlemedi ("sesler iyi" dedi). Linux build gerçek makinede denenmedi. Android/iOS kasıtlı yapılmadı (kullanıcı: APK gerekmez).

## Kullanıcı tercihleri
Sormadan ilerle ("bana hiç sorma"); sonuçta kısa Türkçe özet; commit'e izin verdi; push etme.
