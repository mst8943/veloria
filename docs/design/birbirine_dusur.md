# Birbirine Düşür — hedefli rekabet operasyonu

Tarih: 2026-10-06. Yol haritası Faz 2 (son kalem). Kaynak: Tasarım Özeti §18 "Rakipleri birbirine karşı kullanmak".

## Sorun
Operasyonlar (Dikkat Dağıt, Muhalefeti Böl, Rakibi Zayıflat) ya dünyaya ya da tek bir kişiye yönelik. Oyun "ikisini birbirine düşür" fantezisini hiç sunmuyor; oysa tüm komplo sistemi iki güçlünün **birlikte** hareket etmesine dayanıyor (ortak güç payı eşiği). Oyuncunun elinde bu koordinasyonu bozacak hedefli bir araç yok; yalnızca tek tek yatıştırma ya da zayıflatma var.

## Tasarım
**Eylem:** Operasyon sekmesinde **Birbirine Düşür** (2 mesai). Çoklu seçimle **tam iki kişi** seçilir. Kimse "moved" (düşman) olmamalı. Aynı çift için 6 hafta bekleme.

**Başarı olasılığı** hırslarına bağlı (gizli): iki hırslı kişi kolay kapışır. Oyuncu yalnızca güç kademelerini ve tavırlarını görür; önizleme riski "orta" der.

**Başarılı:** İkisi de birbiriyle uğraşırken güç (-4) ve hırs (-3) kaybeder, korkuları artar. Komplocuların birbirine güveni sarsılır: hırs düştüğü için isyan eğilimleri ve dolayısıyla komplo koordinasyonu zayıflar.
**Başarısız:** İkisi de **kimin yaptığını anlar**: hırsları artar (+6), paraya dayalı sadakatleri düşer, ve "kralın danışmanlarını birbirine düşürme girişimi" adlı bir sır (şiddet 30, ikisi bilir) doğar. Sırlar mahkeme baskısına gider.
**Her durumda** %15 ihtimalle sızıntı sırrı (şiddet 20) doğar.

**Oyuncuya ne kazandırır?** Güçlü iki komplocunun ya da iki rakibin kapışmasını sağlayarak darbe koordinasyonunu bölmek; ama kimin kimle çalıştığını bilmen gerekir (alametler, tavır göstergesi).
**Karar:** hangi iki kişi? Birini zayıflatmak (Rakibi Zayıflat) yerine ikisini birden uğraştırmak ne zaman değer?
**Bedel:** 2 mesai, başarısızlıkta düşman olabilecek iki kişi ve bir sır.
**İstismar:** 6 hafta bekleme + başarısızlık bedeli + 2 mesai; ölçülecek (bot sondajı).

## İlke kontrolü
1 Belirsiz bilgi: nötr (başarı gizli hırslara bağlı). 2 Satın alınan sadakat/bedel: destek (başarısızlıkta iz). 3 İnsanlar: destek (iki isim seçilir, metin ikisini anlatır). 4 Dünya beklemez: nötr. 5 Ortak bilgi: destek (sızıntı sırrı). 6 nötr.

## Ölçüt
Ölçüt botta kazanma bantta kalır; "düşürücü" bot (komplo yakınındaki en yüksek hırslı iki kişiyi düşürür) tek başına baskın strateji çıkmaz (ölçüt botu belirgin aşmaz).
