# Veloria — Durum ve Yapılacaklar (yeni oturum için devir notu)

Son güncelleme: 2026-10-04 (ikinci oturum). Dal: `veloria`. Çalışma ağacındaki `.mcp.json`, `BECKETT_SETUP.md`, `project.godot` değişiklikleri (Beckett token'ının kaldırılması) kullanıcınındır; commit'lere katılmadı, dokunma. Push YOK: `origin` Beckett'in kendi deposu; kullanıcı kendi deposuna yedeklemek isterse yeni repo açıp `veloria` dalını oraya göndermeli (öneri yapıldı, cevap gelmedi).

## Proje
Godot 4.7.2, Türkçe, yatay. Kral Adrian IV, 104 hafta tahtta kalma simülasyonu. Kullanıcı: Mesut Canturk. Görselleri kullanıcı ChatGPT/Imagen ile üretiyor; ben prompt veriyorum (`ART_PROMPTS.md`). Görselleri rastgele adla `art/` köküne ya da bir klasöre atıyor; ben içeriğe bakıp (kontakt sayfası) doğru ada taşıyorum, `.import` ayarlarına boyut sınırı + lossy + mipmap uyguluyorum.

## Çalıştırma ve test
- Godot console: `C:\Users\USER\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Testler: `--headless --path . --script res://tests/sim_test.gd` (denge+sistemler), `pacing_test.gd`, `cause_probe.gd`
- Arayüz otomatik oynatma: `-- --autoplay`, `--mobile`, `--full` (Kolay seviyede 104 haftayı arayüzden oynar)
- Ekran görüntüsü: pencereli `--path . --script res://tests/ui_shots.gd -- --out=KLASÖR [--mobile]` (görüntüleri Read ile incele)
- Build: `--export-release "Windows Desktop"|Linux|Web` → `dist/windows|linux|web`; zip'ler `dist/release/`. Export sonrası `.mcp.json` portu 8770'e geri alınmalı.
- Beckett MCP (127.0.0.1:8770) editör açıkken çalışır; araçlar oturumda görünmezse HTTP JSON-RPC ile çağır. Dev bayrakları (`veloria/dev_*`) project.godot'ta KAPALI kalmalı.
- Tuzaklar: `class_name` yerine `preload`; web'de ◆ ⏳ → gibi glifler kutu çıkar; görünmez Control'ler tıklama yutar (Beckett `ui_snapshot` → `occluded_by` ile tara); yapay `push_input` tıklama testi çalışmıyor; PowerShell'de çok satırlı commit mesajı için `-m` kullan; testler oyuncu kaydına dokunmaz (`save_path`, `record_chronicle`, `autosave`).

## Yapılanlar (tamamı commit'li)
Simülasyon: gizli durum+raporlar+yalan, ortak bilgi, eşik kaskadı/darbe, emir kanalları, operasyonlar, şantaj/araştır/kırmızı çizgi, söz defteri, zorluk (Kolay/Normal/Zor), 71 olay (zincirleme dahil), başarımlar (15), tarihçiler, hakikat dosyası+grafik, arşiv, otomatik kayıt, Türkçe ek uyumu (`Sim.ek`).
Arayüz: tema, sinematikler (açılış/final/hafta geçişi/mühür), Çalışma Masası, Başkent Haritası, Medya Merkezi (2 gazete + TV), mobil yatay düzen, kısayollar, ayarlar, Hakkında, açılış ekranı, tüm görseller yerleşik (71 olayın hepsi görselli, art/desk, art/city_map.png).
Son tur (274e6df): düğme hiyerarşisi (Ghost/Danger/Choice), gruplu eylem paneli, sır kartları, bildirim yığını, iki sütun rapor.
Belgeler: `docs/OYUNCU_REHBERI.md`, `docs/GELISTIRICI_REHBERI.md`, `docs/ARAYUZ_PLANI.md`.

Arayüz turu 2 (2026-10-04, ikinci oturum): 1, 4, 5 yapıldı —
- Akış şeridi (`_rebuild_flow`, `_flow_chip`, `_on_flow`): alt satırda Haftayı Bitir'in solunda; mesai, bekleyen/acil karar, okunmamış medya, vadesi gelen söz, yayılan sır. Parçalar tıklanınca Gündem/Medya/Dosyalar'a götürür.
- Oyun sonu sekmeleri (`_end_tabs`, `_end_page`): Özet / Grafik / Tarihçiler / Hakikat Dosyası (n) / Kararlar; grafik sekme ilk açılınca çizilir. "Ana Menü" düğmesi eklendi.
- Menü sayfaları (`_menu_page`, `_menu_show_page`): ana sayfa 4 düğme (Devam Et|Oyuna Dön, Yeni Oyun, Ayarlar, Çıkış — web'de Çıkış gizli) + bağlantılar (Nasıl Oynanır, Arşiv, Hakkında). Zorluk "Yeni Oyun" sayfasında, ayarlar ayrı sayfada. Esc alt sayfadan ana sayfaya döner.
- Ekran görüntüsü aracı: `tests/ui_shots.gd` (pencereli; `-- --out=KLASÖR [--mobile]`), dev ayarlarını yalnızca bellekte açar.

Arayüz turu 3 (görsel cila):
- Masa: nesneler masanın lambasıyla aydınlatılıyor (`desk_lit.gdshader`, `LAMP_UV`) ve silüetlerinden gölge düşürüyor (`desk_shadow.gdshader`: geniş düşen gölge + dar temas gölgesi). Yerleşim/dönüş/yükseklik `LAYOUT` ve `FEEL`'de. Üzerine gelince nesne kalkar, gölgesi yumuşar. Rozetler nesneden kalktı; etiketin yanında küçük işaret + altında tek satır özet (`_summary`).
- Kişi paneli: göstergeler (`_trait`): güç 3 kademe, düşman, karşılık bekliyor, zayıf nokta/kırmızı çizgi (bilinmiyorsa "?"), doğrulama karnesi, sözler. Bilgi miktarı eskisiyle aynı.
- Ortak imza: `UIKit.band_style()` (ana ekran, harita, medya başlık bandı), `UIKit.ornament()` (köşebentler), `UIKit.divider()` (masa ve menü başlık ayracı), `UIKit.caps()` (aralıklı başlık fontu), `_section()` bölüm başlıkları. Portre kartları tam dolu, ad portrenin üstünde.

## Yapılacaklar (öncelik sırası)
1. Boş masa arka planı bekleniyor (prompt: `ART_PROMPTS.md` > "Boş masa arka planı"). Gelince `art/bg_desk.png` yerine koy (eskisini `art/_arsiv`), `LAYOUT`'u yeni görselde nesneler masaya otursun diye ince ayarla, `LAMP_UV`'yi lambaya göre düzelt.
Not: menü açılınca sağ üstteki bildirimler temizleniyor (eskiden menünün üstünde kalıyordu).
Diğer: kullanıcı henüz tam bir saltanat oynamadı; geri bildirimi (denge, metin, ses) bekleniyor. Sentezlenmiş sesleri kimse dinlemedi ("sesler iyi" dedi). Linux build gerçek makinede denenmedi. Android/iOS kasıtlı yapılmadı (kullanıcı: APK gerekmez).

## Kullanıcı tercihleri
Sormadan ilerle ("bana hiç sorma"); sonuçta kısa Türkçe özet; commit'e izin verdi; push etme.
