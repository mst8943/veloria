# İngilizce sızıntı görevi (ikinci tur): oyun içinde üretilen Türkçe metinler

Önceki tarama (tests/en_leak_test.gd) yalnızca Türkçe harf ve ~30 kelimeye baktığı için kaçırdı. Yeni dedektör sözlük farkıyla çalışır ve gerçek oyundan aldığı dökümde 105 şüpheli buldu. Bu görev hepsini ve bulunacak diğerlerini sıfırlar.

## Araçlar (hazır, commit'li)
- `tests/en_dump.gd`: EN arayüzündeki TÜM metinleri (görünmeyenler, ipuçları, sekmeler dahil) TSV'ye döker. 14 kişi x 7 eylem sekmesi x tüm eylem önizlemeleri, 24 hafta, Masa, Hanedan, menü, künye. `-- --out=DOSYA.tsv [--mobile]`
- `tests/en_dump2.gd`: Oyun boyunca ÜRETİLEN metinler: eylem sonuçları, karar sonuçları, haberler, raporlar, günlük, dosyalar, oyun sonu sekmeleri (4 kampanya). `-- --out=DOSYA.tsv`
- `tools/i18n_leak_scan.py DOSYA.tsv ...`: şüpheli (Türkçe kalmış) metinleri yazar, varsa çıkış kodu 1.
- `tools/i18n_missing.py`: `tr("...")` kaynaklarından en.po'da olmayanları listeler.
Çalıştırma örneği: `$G --path . --script res://tests/en_dump2.gd -- --out=C:/Users/USER/Desktop/b.tsv` sonra `python tools/i18n_leak_scan.py C:/Users/USER/Desktop/b.tsv`

## Bulunan sızıntı sınıfları ve kaynakları
**A) en.po'da eksik tr() kaynakları (tools/i18n_missing.py: 9 adet)**
- agenda_view.gd ~747-764: danışman satırı ipuçları: "Danışmanların kararlara dair görüşü...", "Seçeneklerden en az biri onu doğrudan etkiliyor...", "Son zamanlarda hakkında alametler var.", "Kaçamak konuşuyor...", "Seçenekler arasında belirgin bir fark görmüyor."
- end_screen.gd:101 "Hakikat Dosyası" sekmesi; main.gd:931 "Yeni saltanat..." penceresi; agenda_view.gd:98 "Bir kişiye eylem\n".
- sim.gd:1890: Türkçe olması gereken kaynak İngilizce yazılmış ("FINANCE: The council couldn't debate...") tr()'ye verilmiş; kaynak Türkçe olmalı, en.po'ya İngilizcesi.

**B) Sim'in kurduğu Türkçe cümleler (en çok burada: çalışma anında %s ile birleştirilip SONRA tr() ye veriliyor, eşleşmez)**
- Gizli ipuçları ("alametler"), sim.gd ~674-678, ~733 ve narrative.gd `_sign_text`: "%s huzurda kaçamak cevaplar verdi; gözlerini kaçırdı.", "%s huzurda tedirgin görünüyordu.", "%s emri geciktirdi; uygulamak için 'koşulların olgunlaşmasını' bekliyor." Haberde "SIGN: the Prince huzurda tedirgin..." diye yarı çevrili çıkıyor.
- Sırlar/dosyalar (`_add_fact`, sim.gd ~705, 722, 811, 1165, 1188 ve diğerleri): "%s verilen yazılı emir", "%s yapılan şantaj", "%s yapılan gizli ödeme", "%s kralın sırlarını sızdırıyor", "Prensin gizlice izlenmesi", "Gazeteciye uygulanan baskı", "Yargıca yapılan baskı", "Yargıcın istifa mektubu", "Bakan ihale dosyası" ... Bunlar Dosyalar sekmesinde, haberlerde ("KULİS: '...' dolaşıma girdi", "MANŞET: ... kamuoyuna yansıdı") ve günlükte görünür. `fact_text_for_display` yalnızca 2 kalıbı kapsıyor.
- Künye/ünvan: "Your title: Devrilen Kral" (oyun sonu), "%s Kuklası" (sim.gd ~2777): Ünvan adları İngilizce kaplamada yok.
Çözüm yönü (önerilen): metni TÜRKÇE ve İNGİLİZCE birlikte üret. `Loc.en(msgid)` gibi, o anki dilden bağımsız İngilizce çeviriyi veren yardımcı ekle (TranslationServer.get_translation_object("en").get_message). `_add_fact`, `_add_sign`, `_add_news`e `text_en` (ya da kimlik + parametre) ekle ve görüntülerken `Loc.lang`e göre seç. Kayıtta eski kayıtlar (text_en yok) bozulmasın: yoksa mevcut davranışa düş. Kayıt sürümü gerekirse artır (save_test geçmeli). RNG tüketimi ve oyun sonuçları DEĞİŞMEMELİ.

**C) Türkçe ek sızıntısı (`Sim.ek()`): EN metne "Vale'nin's", "Duvall'ın's", "Veyra'nın", "Duvall'ı" giriyor**
- "Lucien Vale'nin's red line", "First you need to find Claire Duvall'ın's weakness (Investigate)", "A weakness of Selin Veyra'nın has been found", "You summoned Claire Duvall'ı recently". Kök neden: `ek()` çıktısı İngilizce şablona (`%s's`) veriliyor. Ek kullanan ~39 yer var (grep "ek(").
- Çözüm: gösterilen metinlerde `ek` EN'de düz adı döndürsün (iyelik şablonda zaten `%s's`); SAKLANAN Türkçe metinler için ayrı `ek_tr` (her zaman Türkçe ek) kullan. Zaten dallanan yerler (`Loc.poss(name) if Loc.lang == "en" else ek(...)`) tutarlı kalsın.

**D) Eylem adları/açıklamaları**
- "Görevden Al" düğmesi/önizleme başlığı çevrilmemiş (en.po'da yalnızca "Görevden Al (1 mesai)\n..." tooltip satırı var).
- Söz ödülleri: önizleme başlıklarında "Söz: Naiplik / Liman İhalesi / Dokunulmazlık" (ve söz defteri, rapor satırları): ödül adları Türkçe iç anahtar, gösterimde çevrilmeli.
- "Terfi Ettir (1 mesai)\nGüç ve minnet verir; ama onun gücü, hırsı ve sana olan borcun da büyür." ipucu kısmen Türkçe; "Promote 1 action · no trace · ... ⏎ Güç ve minnet verir; ..." ikinci satır Türkçe.

**E) Menü künyesi (`MENU.CREDITS`, menu.gd)** tamamen Türkçe: "VELORIA / Reaktif bir siyaset ve iktidar simülasyonu / Yapım / Tasarım ve geliştirme desteği ...". Çevrilmeli (tr() ile).

**F) Eski ad kalıntısı:** Danışman metninde "If III is chosen, it strengthens Falk's hand." (Renn olmalı). advice.gd:302 `aid.capitalize()` geri dönüşü eski kimliği ("falk") ad diye basıyor; Sim.actors içinde yokken de gerçek ad (a.display_name / en kaplama adı) kullanılmalı. Eski kimlik adlarının (Falk, Kessler, Halden, Brandt, Lena, Dorn) hiçbir gösterimde çıkmadığını tara.

## Kapılar
1. `python tools/i18n_missing.py` → 0.
2. En az şu dökümlerde `python tools/i18n_leak_scan.py` → ŞÜPHELİ 0: `en_dump.gd` masaüstü, `en_dump.gd --mobile`, `en_dump2.gd` (kampanya sayısını 4'ten 12'ye çıkar: tohum x 3 zorluk, tam 104 hafta, kriz/darbe yolları dahil; eylemleri ve karar seçeneklerini rastgele ama farklı seçsin). Dedektörün kendisi yeni sızıntı sınıfı bulursa çöz.
3. `tests/en_leak_test.gd`'yi zayıf harf/kelime listesi yerine bu sözlük-farkı yöntemiyle güçlendir (kalıcı kapı), tr_dump karşılaştırması gerekmez.
4. Tüm testler: sim_test, event_check (tr/en), save_test (eski kayıt yükleme dahil), content_check (tr/en), i18n_check, en_leak_test, ui_input_test (masaüstü ve mobil), lang_switch_test, touch_scroll_test, tour_test. `--full` tr ve en AYNI: tohum 101, 104 hafta, TAHTTA, Medya Rejimi, 112 olay. Ölçüt probe tabanla birebir (68/80, 36/80, 16/80) tr ve en.
5. Gözle: ui_shots/ux_audit ile EN masaüstü + mobil: Gündem, her eylem sekmesi, Dosyalar (sırlar), Günlük, Medya, Harita, menü künyesi, oyun sonu (5 sekme), hafta geçişi perdesi; PNG'leri aç, Türkçe kalmış satır var mı bak.
6. Dili oyun sırasında değiştirme: `main.rebuild_ui()` (dil değişince arayüzü yeniden kurar) çalışıyor; saklanan metinlerin (dosya, haber, günlük) dil değişince de doğru dilde görünmesini sağla (kayıtlı Türkçe metni görüntüleme anında dile göre seç).
