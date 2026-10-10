# Android APK son testi (tam ekran + TR/EN dil denetimi)

Amaç: `dist/release/Veloria-1.6.0-android.apk` gerçekten (1) durum çubuğu (şarj, saat, sinyal) ve gezinme düğmeleri (geri, ana sayfa, son uygulamalar) olmadan TAM EKRAN açılıyor, (2) Türkçe ve İngilizce modda hiçbir yerde karışık dil yok. Gerçek telefon yoksa Android emülatöründe test edilir.

## Bağlam
- Kök neden bulundu ve düzeltildi (commit 7f71e2c): `Sfx._apply()` oyun açılışında pencereyi WINDOWED yapıyordu; bu Android'de "immersive mode"u iptal edip çubukları geri getiriyordu. Artık mobilde her zaman FULLSCREEN. Ayrıca `main._safe_insets()` çentik/yuvarlak köşe boşluklarını ekliyor. Export ön ayarı: `screen/immersive_mode=true`, `screen/edge_to_edge=false`.
- Bunun gerçek cihazda/emülatörde işe yaradığı DOĞRULANMADI. Sizin işiniz bunu ölçmek, çalışmıyorsa kök nedeni bulup düzeltmek.
- Android araçları: SDK `C:\Users\USER\AppData\Local\Android\Sdk` (adb: platform-tools, emulator: emulator, build-tools 36.0.0, system-images android-35/36 x86_64), JDK 17 `JAVA_HOME`. Hazır emülatör AVD'leri başka projeler için (codex-lovask vb.); yenisini aç: `avdmanager create avd -n veloria-test -k "system-images;android-35;google_apis;x86_64" -d pixel_6` (yatay 2400x1080 çözünürlük de dene).
- APK yalnızca arm64-v8a. x86_64 emülatörde çalışması için ya ARM çevirisi olan bir görüntü (google_apis_playstore) kullan ya da emülatör denemesi için PREST'i GEÇİCİ olarak x86_64 mimarisiyle dışa aktar (`architectures/x86_64=true`, çıktıyı dist/test/ altına yaz, export_presets.cfg değişikliğini geri al). Teslim edilen APK arm64 kalsın.
- Kurallar: PUSH YOK, her mantıksal adım ayrı commit, commit'e girmeyenler: .mcp.json, .cursor/, project.godot, art/portraits/PROMPTS.md, overview.png(.import), audio/_kaynak, docs/marketing. Çalışan editörü kapatma. Bilgisayarı KAPATMA/zamanlama.

## Görev 1 — Tam ekran kanıtı
1. APK'yı yeniden üret: `$G --headless --path . --export-debug "Android" dist/release/Veloria-1.6.0-android.apk`.
2. Emülatör/cihaza kur (`adb install -r`), `adb shell am start -n com.mesutcanturk.veloria/com.godot.game.GodotApp` ile aç.
3. Kanıt: `adb exec-out screencap -p > shot.png`: ekranın üstünde saat/şarj/sinyal, altında 3 düğme/hareket çubuğu OLMAMALI; oyun tüm ekranı kaplamalı. Ayrıca `adb shell dumpsys window` çıktısında durum çubuğu ve gezinme çubuğu görünürlüğünü doğrula. Şu durumlarda tekrar: menü açık, oyun içi, ara sahne, uygulama arka plana gidip dönünce (HOME sonra geri), ekran kapanıp açılınca, kenardan kaydırma (çubuklar geçici çıkıp kendiliğinden kaybolmalı), yatay döndürme (iki yön).
4. Çentik/delik kamera: emülatörde "display cutout" ayarı aç (`adb shell cmd overlay enable com.android.internal.display.cutout.emulation.corner` veya `.tall`), arayüzün çentiğin altında kalmadığını ve düğmelerin kesilmediğini doğrula; kalırsa `_safe_insets` mantığını düzelt (Godot `DisplayServer.get_display_safe_area` birimleri, `content_scale` ölçeği).
5. Çalışmıyorsa: kök nedeni bul (immersive_mode, window mode, edge_to_edge, gradle gerektiriyor mu, sticky immersive davranışı), düzelt, APK'yı yeniden üret ve yeniden kanıtla.

## Görev 2 — Dil denetimi, APK üzerinde, iki yönlü
Kaynak ve dökümler başsız testle zaten temiz (tools/i18n_leak_scan.py → 0), ama gerçek APK'da yazı tipi, uzunluk ve dinamik değişim farklı davranabilir. Burada gerçek ekranda doğrula.
1. Dil ayarını ayar dosyasına yaz (debug APK `run-as` ile): `adb shell run-as com.mesutcanturk.veloria` ile `files/veloria_settings.cfg` içine `[game]\nlanguage="en"` (ve `intro=false`, `desk_start=false`, `tips=true` gibi ayarlar; sizin ayar anahtarları game/core/sfx.gd `_load_settings`te). Önce TR sonra EN koş. Menüde Ayarlar → Dil seçeneğiyle CANLI dil değişimini de dene (TR→EN→TR): arayüz yeniden kurulmalı (main.rebuild_ui).
2. Dokunmatik gezinmeyi `adb shell input tap/swipe` ile otomatikleştir (koordinatlar için ekran görüntüsü kullan; 1067x600 mantıksal, gerçek piksel oranını hesaba kat). Her dilde şu yolu gez ve her ekranı `screencap`le kaydet: Menü → Yeni oyun → (açılış turu açıksa tüm adımları geç) → Gündem (karar kartı, Gerekçeler, seçenek seç), Kişiler (dört grup, bir kişi seç, her eylem sekmesi, bir eylemin ipucunu UZUN BASIŞLA aç, bir eylem yap), Raporlar/Dosyalar/Günlük, Masa, Harita (bir kuruma gir), Medya (3 kanal), Hafta bitir (perde), birkaç hafta ilerle, haber şeridine dokun (açılıp kapanmalı), bir ara sahne, Ayarlar, Menü künyesi, oyun sonu (hızlı bitirmek için adb ile kayıt dosyası ya da dev bayrağı kullanabilirsin).
3. Her PNG'yi AÇ ve gözle kontrol et. İngilizce modda Türkçe, Türkçe modda İngilizce (ya da karışık, yarı çevrilmiş cümle, "%s", "{n_in}" gibi doldurulmamış yer tutucu, eksik ad, "…" ile kesik ya da taşan metin, yanlış cinsiyet zamiri, tek-çoğul hatası) KALMAMALI. Yazı tipi eksik glif (kutu ▯) göstermemeli (Türkçe ğüşiöç İ ı ve kıvrık tırnaklar, tireler).
4. TERS YÖN dökümü: Şu an yalnızca "EN'de Türkçe" taranıyor. `tools/i18n_leak_scan.py`ye `--reverse` ekle (İngilizce-yalnız kelime dağarcığı ile TR arayüzde İngilizce kalıntı ara) ve `tests/en_dump.gd`/`en_dump2.gd` benzeri TR dökümü al (`--lang=tr`: betikler dili parametreyle seçebilsin). TR'de çıkan İngilizce kalıntıları (örn. çevrilmemiş yeni metinler, sızan `msgstr`ler) düzelt. Özel adlar, "Sarne TV", "VIA" gibi izin listesine.
5. Bulunan her sızıntıyı kökünden çöz (Sim/narrative metinleri çift dilli üretilir: Türkçe + İngilizce, saklanan metin gösterim anında dile göre seçilir; bak docs/i18n/sizinti_gorevi.md "Kararlar"). Oyun mantığı ve RNG değişmez; eski kayıtlar yüklenmeli.

## Görev 3 — Mobil davranış denetimi (kısa)
- Uzun basış ipucu balonu, sürükleyerek kaydırma (düğmeye basmadan), Kişiler tek sayfa kaydırma, Gündem sekmesi rozeti, haber şeridi genişleme, ses (ambient + efektler çalıyor mu, `adb shell dumpsys audio`), çökme/ANR (`adb logcat -s godot:* AndroidRuntime:E`), kare hızı (`adb shell dumpsys gfxinfo` ya da oyun içi), bellek. Sorun varsa düzelt.

## Kabul / çıktı
- Tam ekran: yukarıdaki durumların hepsinde çubuk yok; kanıt PNG'leri `C:/Users/USER/Desktop/apk_test/{tr,en}/` altında, her biri için neyi kontrol ettiğini rapora yaz.
- Dil: TR ve EN yolunda ~30+ ekran görüntüsü, hepsi gözle kontrol edildi, karışık dil yok; `i18n_leak_scan` iki yönde 0.
- Tüm testler: sim_test, event_check, save_test, content_check, i18n_check, en_leak_test, ui_input_test (masaüstü ve mobil), lang_switch_test, touch_scroll_test, tour_test; `--full` tr ve en aynı (101/104/TAHTTA/Medya Rejimi/112); ölçüt probe 68/80, 36/80, 16/80.
- Yeni APK: `dist/release/Veloria-1.6.0-android.apk` (arm64, debug imzalı). Sürüm numarasını artırma.
- Rapor: bulunan sorunlar, düzeltmeler, commit'ler, kalan riskler. PUSH YOK.
