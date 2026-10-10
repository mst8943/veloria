# T1 — İlk açılış yol göstericisi (tur)

AMAÇ: İlk kez oyunu indiren/açan oyuncuya kısa, atlanabilir bir tur: "Buradan şunu yap, şuradan ilk kararını ver." Menü dahil, oyundaki her ana parçanın ne işe yaradığını tanıt. Mobil (1067x600) ve masaüstünde çalışsın, TR ve EN.

TASARIM (önce docs/ux/ilk_acilis_turu.md içine kısa bir tasarım yaz, sonra kodla):
1. Tetik: ilk yeni oyunda (kayıtlı ayar "tour_done" yoksa); Sfx ayarlarına `tour_done` ekle (user:// ayar dosyası, kayıt dosyasına DEĞİL: save_test etkilenmesin). Menüde "Turu yeniden göster" düğmesi ve Ayarlar'da aç/kapa. Tur her adımda "Atla" ve "Geri/İleri" ile gezilir; Esc atlar. Otomatik oynatma, testler ve `_fast()` modunda tur ÇIKMAZ.
2. Biçim: karartılmış ekran üzerinde vurgulanan öğenin etrafı açık (spotlight), yanında altın çerçeveli (UIKit.tex_box / ornament) açıklama kutusu, "Adım 3 / 9" göstergesi, İleri düğmesi (PrimaryButton), Geri ve Atla (GhostButton). Hedef öğe kaydırma alanındaysa görünür olana kaydırılsın. Mobilde kutu ekranın üst/alt yarısında hedefi örtmeyecek yerde dursun, dokunma hedefleri >= 44 px, TouchScroll (game/ui/touch_scroll.gd) ile çakışmasın.
3. Adımlar (her biri 1-2 cümle, "sayı yok" ilkesi: gizli değerleri sayıyla anlatma):
   a) Karşılama: Taç sana emanet; 104 hafta tahtta kalmak amaç.
   b) Üst çubuk: hafta ilerlemesi, mesai (haftalık eylem hakkı), kişisel servet; Masa, Medya, Kaydet, Menü ne işe yarar.
   c) Gündem: bekleyen kararlar; danışman görüşü ("çıkarı var" uyarısı), "Gerekçeler".
   d) İlk kararını ver: karar kartında bir seçeneğe dokun (turda gerçek tıklama yapılır ve karar verilir; bu adım ancak oyuncu seçince devam eder; atlanırsa kimseyi zorlama).
   e) İzleme listesi ve Divan: 14 kişi, şerit + "+N Divan"; kişiye dokununca ne olur.
   f) Eylemler: 7 eylem sekmesinin kısa tanıtımı (Kazan, Söz Ver, Öğren, Emret, Baskı, Operasyon, Devlet), mesai harcar.
   g) Bu hafta değişenler ve Raporlar: kim güçleniyor/hoşnutsuz.
   h) Dosyalar ve Günlük: gerçeklerin, sözlerin, kararların kaydı; Medya: haber ve yayın.
   i) "Haftayı bitir": haftayı geçirir, kararlar 2 hafta sonra kendiliğinden çözülür; krizler ve darbe uyarısı.
   j) Menü: Ayarlar, Kaydet/Yükle, Zorluk, Dil, Turu yeniden göster.
4. Yeni metinler tr() + game/i18n/en.po (sentence case, iki dilde); i18n_check geçmeli. Glif kuralı: ok/simge glifi yerine çizilmiş şekil. Yeni renk ekleme.
5. Mevcut "Bu hafta ne yapmalı?" adım çubuğu ve AGENDA_VIEW.ADVICE ipuçları KALIR; turla çakışmasın (tur sürerken ipuçları gizlenir).

TEST/KAPI:
- Yeni tests/tour_test.gd (pencereli): tur başlar, adımlar İleri/Geri ile gezilir, Atla ile kapanır ve `tour_done` kaydedilir, ikinci açılışta çıkmaz, _fast() modunda hiç çıkmaz.
- Her tur adımının ekran görüntüsü, 1067x600 mobil + masaüstü, TR + EN; her PNG'yi aç ve kontrol et: vurgulanan öğe doğru mu, açıklama kutusu hedefi örtüyor mu, metin taşıyor mu/kesiliyor mu, düğmeler görünür mü. Rapora her PNG için neyi kontrol ettiğini yaz.
