# Yerelleştirme mimarisi

Veloria'nın kaynak dili Türkçedir. İngilizce, oyunun anlam ve ekran metinlerinin çevirisidir; oyun kurallarının, kayıt şemasının veya içerik kimliklerinin ikinci bir kopyası değildir.

## Metin nerede tutulur?

- Arayüz ve koddan kurulan dinamik cümleler `tr("Türkçe kaynak cümlesi")` kullanır. İngilizce karşılığı `game/i18n/en.po` içine aynı `msgid` ile eklenir. Yer tutucular (`%s`, `%d`, `{name}`) ve biçim işaretleri aynen korunur.
- Veri tablolarındaki görünen içerik `game/data/en/` altındaki kaplama dosyalarındadır: ör. `events.json`, `actors.json`, `content_reports.json`. Kaplama, Türkçe ana dosyanın yapısını ve metin girişlerinin anahtarlarını/dizi uzunluklarını korur; yalnızca metin alanlarını taşır.
- Olay kimlikleri, aktör id'leri, bayraklar, koşullar, `fx`, kurum kodları, zorluk indeksleri ve kayıt anahtarları çevrilmez. Türkçe bir iç anahtar ekranda görünecekse anahtar korunur, yalnızca görüntüleme sınırında `tr()` uygulanır.
- Dil `Loc` üzerinden ayarlanır. Menü/oyun başlamadan önce dili belirleyin; `Sim.new_game()` dile göre veri kaplamalarını yükler. Dil metinleri RNG'yi, seçimleri veya dengeyi değiştirmemelidir.

Parça birleştirerek cümle kurmayın. Tam Türkçe cümleyi tek `tr()` anahtarı yapın; İngilizcede doğal cümle sırasını kullanın. Türkçe iyelik gerekiyorsa kaynakta `Sim.ek()`/`ek()` düzenini, İngilizce iyelikte `Loc.poss()` yardımcısını kullanın. Aynı bağlamdaki kısa etiketler kısa ve birbiriyle tutarlı olmalıdır.

## Yeni dil ekleme

Örneğin Fransızca için:

1. `Loc` dil kodunu ve ayarlar menüsündeki seçimi ekleyin; kaydedilen dil tercihinin yeniden açılışta korunduğunu doğrulayın.
2. `game/i18n/fr.po` oluşturup tüm UI `msgid`'leri ve yer tutucuları eşleştirin.
3. `game/data/fr/` altında ilgili metin kaplamalarını Türkçe kaynaklarla aynı şema ve anahtarlarla oluşturun. Mantık alanlarını kopyalayıp değiştirmeyin.
4. `i18n_check.gd`, `content_check.gd --lang=fr` ve `event_check.gd --lang=fr` doğrulamalarını çalıştırın; eksik kaplamanın Türkçe kaynak metne güvenli düşüşünü koruyun.
5. Pencereli `ui_shots.gd` görüntülerini ve `tools/i18n_dump.gd` kampanya dökümünü gözden geçirin. Başsız testler UI metni veya taşmayı denetlemez.
6. Çoklu dilde aynı tohumla `--full` ve denge sondajını karşılaştırın; metin değişikliği oyun sonucunu değiştirmemelidir.

## Denetim araçları

- `tests/i18n_check.gd`: PO/kaplama biçimi, kaynak ve iç anahtarların korunması, cinsiyet ve tırnak stili uyarıları.
- `tests/content_check.gd -- --lang=en`: veri şemaları ve İngilizce kaplama yüklemesi.
- `tests/event_check.gd -- --lang=en`: olay kaplaması, seçenek uzunlukları ve biçim doğrulaması.
- `tools/i18n_dump.gd`: pencereli autoplay oturumunda UI kontrollerinde gösterilmiş metinleri TSV'ye toplar ve Türkçe karakter/sözcük sezgisellerini raporlar. Kullanımı: `docs/i18n/english_screen_dump.md`.
- `tests/ui_shots.gd`: gerçek pencereli ekran görüntüleri; masaüstü ve `--mobile` (1067×600) varyantları.

Belgede, menüde veya oyunda yeni bir oyuncu metni eklendiğinde, aynı değişiklikte Türkçe kaynak `tr()` ya da Türkçe ana veri metniyle birlikte İngilizce `en.po` girdisi veya `game/data/en/` kaplaması eklenir. Sadece Türkçe ekleyip işi sonraya bırakmayın.
