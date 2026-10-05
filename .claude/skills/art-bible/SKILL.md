---
name: art-bible
description: Veloria'nın görsel kimlik kitabını (art bible) oluşturur ya da günceller — palet, ışık kuralları, kompozisyon, karakter/olay/arka plan stilleri, tipografi, arayüz süsleri, yapılacak/yapılmayacaklar ve örnek görseller. "görsel kimlik", "art bible", "stil rehberi", "görseller tutarlı değil" isteklerinde kullan. Tekil görsel üretim promptu için asset-spec kullan.
---

# Görsel Kimlik Kitabı

Çıktı: `docs/ART_BIBLE.md`. Var olan belgeyi baştan yazma; güncelle.

## Kaynaklar (önce oku/gör)
- `ART_PROMPTS.md`: **STİL BLOĞU** (tüm üretimlerin ortak eki), kurallar, mevcut promptlar.
- `game/ui/ui_kit.gd`: palet ve arayüz imzaları (`band_style`, `ornament`, `divider`, `caps`).
- Görsellerin kendisi: python + PIL ile kontakt sayfası üret (her klasörden küçük resimler yan yana) ve Read ile incele:
  `art/portraits/` (10 portre), `art/events/` (~128), `art/desk/` (7 nesne, saydam), `art/*.png` (arka planlar, son sahneler), `art/icons/`.
- Oyun içi görünüm: `tests/ui_shots.gd` ekran görüntüleri.

## Belge yapısı
1. **Kimlik cümlesi** — "Modern kurumlara sahip hayali bir Orta Avrupa krallığında, gece yarısı bir siyasi gerilim filmi" gibi tek cümle; ruh hali anahtar kelimeleri.
2. **Palet** — kömür siyahı, koyu zeytin yeşili, eskitilmiş altın, kemik beyazı (+ UIKit hex kodları). Vurgu: kan kırmızısı yalnızca tehlike/mühür. Kullanılmayacak renkler (doygun mavi, neon, saf beyaz).
3. **Işık** — chiaroscuro; sıcak tek kaynak (masa lambası, mum, sokak lambası); soğuk gece dolgusu. Masa sahnesinde lamba **sağ arka köşede**, gölgeler sol alta düşer (`desk_view.gd` `LAMP_UV`, `desk_shadow.gdshader` ofseti bu kurala bağlı).
4. **Kompozisyon** — arka planlar 16:9, merkez sakin (arayüz üstüne biner), kenarlarda ağır vinyet. Olay görselleri: tek net odak, okunur siluet, yazı yok.
5. **Karakter portreleri** — büst, üç çeyrek açı, koyu dokulu fon, yan ışık, ciddi ifade; kostüm modern-kurumsal + eski monarşi izleri. Her karakterin sabit tanımı (ART_PROMPTS'tan) ve renk aksanı.
6. **Nesneler (masa)** — saydam PNG, aynı açı ve ışık; stüdyo ışığında üretilse bile oyun içi `desk_lit` gölgelendiricisi sahne ışığına uydurur. Nesne başına alan ve dönüş: `desk_view.gd` `LAYOUT`/`FEEL`.
7. **Arayüz dili** — EB Garamond başlıklar, aralıklı büyük harf bölüm başlıkları, altın köşebentler, ince altın ayraç, koyu cam paneller; köşe yarıçapı 6–10; düğme hiyerarşisi.
8. **Yapılacaklar / Yapılmayacaklar** — görsel içinde yazı/logo yok; gerçek kişilere benzerlik yok; fotogerçekçi değil, boyalı editoryal; anime/çizgi film yok; aşırı doygunluk yok.
9. **Tutarlılık denetimi** — kontakt sayfasında stilden sapan görseller listesi (dosya adı + sorun + yeniden üretim önerisi; promptu asset-spec ile hazırla).
10. **Teknik** — boyutlar ve içe aktarma ayarları (asset-spec > "Teknik standart").

## Kurallar
- Kontakt sayfasını proje dışında (scratchpad) üret; projeye geçici görsel bırakma.
- Sapan görselleri silme; `art/_arsiv/` (Godot dışı, .gdignore'lu) altına taşımayı öner.
