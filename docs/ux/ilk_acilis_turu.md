# İlk açılış turu

Yeni oyunda, `user://veloria_settings.cfg` içindeki `game/tour_done` değeri yoksa ve tur açıksa, açılış sinemasından sonra başlar. Bu değer kayıt dosyasına yazılmaz. Oyuncu turu atlayabilir, Esc ile kapatabilir, ileri/geri gezebilir; seçim adımında gerçek bir karar vermeden ilerleyemez. Tur tamamlanınca veya atlanınca tamamlandı tercihi saklanır. Menüden yeniden başlatılabilir; Ayarlar'da ilk açılış turu kapatılabilir.

Tur, oyunun mevcut ekranının üzerinde hafif karartma, hedefin çevresinde boş bırakılan alan ve UIKit altın çerçeveli açıklama kartı kullanır. On adımın her biri oyunun mevcut bir alanını tanıtır. Mobilde kart ekranın altına sabitlenir; hedef kartla çakışırsa kart üstte gösterilir. İleri, Geri ve Atla düğmeleri en az 44 px yüksekliğindedir. Esc atlama ile aynıdır. Tur sırasında danışman ipucu satırı gizlenir ve kapanışta önceki görünürlüğü geri yüklenir.

Adımlar: (1) karşılama ve 104 hafta hedefi, (2) üst çubuk, (3) Gündem ve danışman gerekçeleri, (4) oyuncunun ilk gerçek kararı, (5) izleme listesi ve Divan, (6) yedi eylem kategorisi ve mesai, (7) haftalık değişimler ve raporlar, (8) Dosyalar/Günlük ve Medya, (9) haftayı bitirme ve gecikmeli sonuçlar, krizler, (10) menü, ayarlar, kayıt, zorluk, dil ve turu yeniden gösterme.

Tur `Sim` ve RNG'ye müdahale etmez; karar adımında oyuncunun var olan karar düğmesine basması gerekir. Otomatik oynatma, test kipleri ve `_fast()` açıkken tur başlamaz. Metinler `tr()` ve İngilizce çeviri kataloğundan gelir. Görsel işaretler metin glifi yerine çizilmiş şekillerdir.
