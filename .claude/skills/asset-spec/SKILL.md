---
name: asset-spec
description: Veloria için üretilecek görsellerin teknik ve görsel spesifikasyonunu ve ChatGPT/Imagen promptlarını hazırlar; kullanıcının attığı rastgele adlı görselleri tanıyıp doğru ada/klasöre yerleştirir ve içe aktarma ayarlarını uygular. "görsel lazım", "prompt ver", "yeni olay görseli", "attığım resmi yerleştir", "arka planı değiştir" isteklerinde kullan.
---

# Görsel Spesifikasyonu ve Yerleştirme

İş akışı: Ben prompt veririm → kullanıcı ChatGPT/Imagen ile üretir → görseli rastgele adla `art/` köküne ya da bir klasöre atar → ben tanıyıp yerleştiririm.

## A. Spesifikasyon + prompt hazırlama
1. `ART_PROMPTS.md`'yi oku: kurallar, **STİL BLOĞU**, var olan benzer promptlar (karakter tanımlarını aynen tekrar kullan). Varsa `docs/ART_BIBLE.md`.
2. Görselin oyunda nerede ve hangi boyutta görüneceğini koddan bul (ör. olay kartı çerçevesi 240×135 + perde geçişinde tam ekran; portre kartı; masa nesnesi alanı `LAYOUT`).
3. Spesifikasyon (her görsel için):
   - Dosya yolu ve adı (aşağıdaki standart), en-boy oranı, üretim boyutu, saydamlık.
   - Konu, kompozisyon (odak nerede, arayüz nereye binecek), ışık yönü, ruh hali.
   - Prompt (İngilizce) + "+ STİL BLOĞU" notu. Mevcut görseli düzenletmek daha tutarlıysa (ör. arka plandan nesne silmek) **düzenleme promptu** ver ve kullanıcıya hangi dosyayı yükleyeceğini söyle.
   - Kabul ölçütü (yazı yok, siluet okunur, ışık kurala uygun…).
4. Promptları `ART_PROMPTS.md`'nin ilgili bölümüne ekle (yeni satır/tablo), kullanıcıya kopyalanabilir biçimde de ver.

## B. Gelen görseli yerleştirme
1. Yeni dosyaları bul: `git status --short art/` (izlenmeyenler) ya da en yeni dosyalar.
2. Tanı: dosyayı Read ile aç; birden çoksa python + PIL ile scratchpad'de kontakt sayfası üret (küçük resim + dosya adı) ve onu oku.
3. Eşleştir: hangi spesifikasyona karşılık geldiğini belirle; emin değilsen kullanıcıya göster/sor.
4. Taşı: doğru ada `git mv`/`mv` (Türkçe karakterli/boşluklu adları tırnakla). Değiştirilen eski görseli silme, `art/_arsiv/` altına taşı.
5. Boyut: saydam nesnelerde gereksiz boş kenarı kırp (alfa sınır kutusu), en-boy oranını koru.
6. İçe aktarma: Godot editörü odaklanınca `.import` oluşur (editör kapalıysa `"$G" --headless --path . --import`). Sonra `.import` içinde `[params]` ayarla ve yeniden içe aktar:
   `compress/mode=1` (lossy; ikonlarda 0), `compress/lossy_quality=0.85`, `mipmaps/generate=true`, `process/size_limit` = aşağıdaki tablo.
7. Doğrula: `tests/ui_shots.gd` ile ilgili ekranın görüntüsünü al ve bak (masa nesnesi/arka plan değiştiyse `desk_view.gd` `LAYOUT`/`FEEL`/`LAMP_UV` ince ayarı gerekebilir).

## Teknik standart
| Tür | Yol | Üretim | `size_limit` | Not |
|---|---|---|---|---|
| Arka plan | `art/bg_desk.png`, `art/menu_bg.png`, `art/end_*.png`, `art/splash.png` | 1920×1080 (16:9) | 0 (sınırsız) | merkez sakin, kenar vinyet |
| Başkent haritası | `art/city_map.png` | 16:9 | 1920 | bina konumları `game/data/city_map.json` (yüzde) |
| Olay | `art/events/<olay_id>.png` (+ `_b` varyant) | 16:9, 1280×720+ | 960 | `events.json` içinde `art` alanı başka adı gösterebilir |
| Portre | `art/portraits/<aktor_id>.png` | 1:1, 1024 → 512 | 512 | id'ler: arden voss kessler halden lena dorn prens brandt falk king |
| Masa nesnesi | `art/desk/<id>.png` (saydam) | 1:1 1024 | 640 | id'ler: gundem medya kisiler gunluk dosyalar hanedan harita |
| İkon | `art/icons/<ad>.png` | 1:1 | 128 | compress/mode=0 (kayıpsız) |

## Kurallar
- Görselde yazı/logo istenmez (oyun yazıları kendisi ekler); gerçek kişiye benzerlik yok.
- Aynı karakteri yeniden üretirken tanımı ART_PROMPTS'tan birebir kopyala.
- Commit'e `.png` + `.import` dosyalarını birlikte ekle (`.gitignore` `art/**/*.import`'u izinli tutar).
