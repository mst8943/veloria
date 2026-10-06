# Veloria — Oyuncu Rehberi

Veloria'da modern kurumlara sahip hayali bir krallığın yeni kralısın: **Adrian IV**. Amacın ülkeyi en iyi şekilde yönetmek değil, **104 hafta boyunca tahtta kalmak**. Ordu, istihbarat, medya, oligarklar, yargı, muhalefet ve kendi ailen birbirine karşı dengelemen gereken güç merkezleri.

> Her çözüm yeni bir problem yaratabilir. Protestoyu bastırdığın general bir gün darbe yapabilir.

## Kurulum

Bu rehber **1.2.0** Windows, Linux ve Web paketleriyle birlikte gelir.

| Platform | Nasıl açılır |
|---|---|
| Windows | `Veloria.exe` dosyasını çift tıkla. Kurulum gerekmez. |
| Linux | `Veloria.x86_64` dosyasına çalıştırma izni ver (`chmod +x`) ve çalıştır. |
| Web | Web zip'inin içeriğini bir web sunucusunda yayınla ve `index.html`'i aç. Telefon tarayıcısında otomatik olarak mobil düzene geçer. |

## Çalışma Masası

Her hafta masanın başında açılır. Masadaki nesnelere tıkla:

| Nesne | Açtığı yer |
|---|---|
| Mühürlü mektuplar | Gündem: kararlar ve raporlar |
| Gazete | Medya Merkezi |
| Telefon | Kişiler ve eylemler |
| Saltanat Günlüğü | Olup bitenlerin kaydı |
| Gizli Dosyalar | Sırlar ve Söz Defteri |
| Hanedan fotoğrafı | Hükümdarlık Arşivi ve başarımlar |
| Başkent haritası | Kurumlar |

Kırmızı rozetler dikkat isteyen şeyleri gösterir. Masaya üst çubuktaki **Masa** düğmesiyle dönebilirsin. İstemezsen Ayarlar'dan "Haftaya masadan başla" seçeneğini kapat.

**Akış şeridi:** Ekranın altında, Haftayı Bitir düğmesinin solunda haftanın durumu tek satırda görünür: kalan mesai, bekleyen kararlar (bu hafta düşecek olanlar kırmızı), okunmamış medya, vadesi gelen sözler ve yayılan sırların. Bir parçaya tıklarsan seni ilgili yere götürür.

## Başkent

Haritada yedi kurum var. Birine tıklayınca başındaki kişiyi, onun bu haftaki raporunu ve kuruma özgü bilgiyi görürsün: Adliye'de saraya uzanan dosyalar, Parlamento'da tutulmamış sözlerin.

## Medya Merkezi

- **Veloria Haber:** Halden'in kâğıda basılan gazetesi. Her şeyi güzel gösterir, saray skandallarını yalanlar.
- **Serbest Kalem:** Lena'nın bağımsız gazetesi. Gerçeğe daha yakın yazar ve kulis söylentilerini basar. Lena'yı susturursan kapanır.
- **Halden TV:** Tüplü televizyonda canlı yayın ve kayan haber şeridi.

İki gazete aynı haftayı farklı anlatıyorsa, aradaki fark sana söylenmeyenleri gösterir.

## Ekran

- **Gündem:** Bekleyen kararlar (görselli kartlar) ve haftanın raporları. Masaüstünde kararların altındaki **BU HAFTA** defteri, o hafta yaptığın eylemleri ve sonuçlarını sırayla tutar (bildirim kaybolsa da). Üstündeki **GEÇEN HAFTADAN BERİ** bölümü, görebildiğin göstergelerde neyin değiştiğini toplar: kimin raporu kötüleşti, kim güçlendi, kimin tavrı sertleşti, hangi sır yayıldı, hangi söz tutuldu ya da karşılığı istendi, hangi karar kendiliğinden çözüldü. Rapor satırlarındaki küçük ok, kaynağın geçen haftaya göre daha iyimser (yeşil) ya da daha karamsar (kırmızı) konuştuğunu gösterir; bu raporun söylediğidir, gerçek olmayabilir.
- **Eylem önizlemesi:** Bir eylem düğmesinin üstüne gelince Eylemler panelinin altında bedeli (mesai, servet), bıraktığı iz ve tahmini riski görürsün; seçili kişiye göre uyarı da çıkar (ör. zayıf noktası bilinmeyene şantaj olmaz).
- **Güç Merkezleri:** 9 karakterin portreleri. Birini seçince hakkında bildiklerin görünür.
- **Emirler ve eylemler:** Seçili kişi üzerinde yapabileceklerin.
- **Dosyalar:** Sırlar, kanıtlar ve **Söz Defteri**.
- **Günlük:** Olup bitenlerin kaydı.
- **Üst çubuk:** Hafta, kalan **mesai** (altın elmaslar) ve **kişisel servetin**.

Mobilde kişiler ve eylemler ayrı bir **Saray** sekmesindedir.

## Temel kurallar

1. **Mesai:** Her hafta sınırlı mesain var (Kolay'da 5, diğerlerinde 4). Kararlar, emirler ve operasyonlar mesai harcar.
2. **Sayı yok:** Kimsenin sadakatini, ordunun gücünü ya da halkın öfkesini sayıyla göremezsin. Sadece **raporlar** var ve herkes yalan söyleyebilir.
3. **Korku gerçeği öldürür:** İnsanlar senden korktukça sana kötü haber vermez. Raporlar birbirine benzemeye başlarsa kimse sana gerçeği söylemiyor demektir.
4. **Ertelemek de karardır:** Bir karar kartını iki hafta cevapsız bırakırsan kendi kendine, çoğu zaman en kötü biçimde çözülür. Süresi dolmak üzere olan kartların çerçevesi kırmızı yanıp söner.
5. **Meclis fısıldar:** Her karar kartında iki danışman görüş bildirir ("II'yi öneririm: hazineyi rahatlatır."). Gerekçeleri doğrudur ama seçicidir; işlerine gelmeyen bedeli anmazlar. Adının yanında **ÇIKARI VAR** yazan kişiyi seçeneklerden biri doğrudan etkiliyor. Uzman olduğu konuda daha isabetlidir. Bir danışmanın önerileri sürekli ötekilerle çelişiyorsa ona dikkat et. Korkan bir meclis "Takdir sizindir" demeye başlar.
6. **Darbe bir sabah gelmez:** Komplo önce **alametler** bırakır (haber şeridinde "ALAMET: …"). Kişi kartında rolün yanında **ŞÜPHELİ** ya da **TEHLİKELİ** yazar; panelde "Tavır" göstergesinin ipucu son alametleri listeler. Alametlerin bir kısmı dedikodudur. Gönlü alınan komplocu geri çekilebilir. Darbe kapına dayandığında son bir **kriz kartı** gelir: sadık birlikleri toplamak, taviz vermek ya da halka seslenmek. Kartın metni muhafızların ve sokağın durumunu anlatır; o hafta karar vermezsen saray düşer. Bir kez taviz verdiysen ikincisine inanılmayabilir.
7. **Sokak ve mahkeme de seni düşürebilir:** Sokağı bastırmak işe yarar ama öfke biriktirir; her bastırma bir öncekinden az etkili olur ve öfke huzursuzluğu kendi kendine besler (Eylemler önizlemesi bunu uyarır). Meydanlar taşarsa "Sokaklar ayakta" kriz kartı gelir. Kral hakkında biriken dosyalar (rüşvet izleri, yazılı emirler, şantaj, kanlı geceler) ise yargı baskısını büyütür; eşik aşılınca "Mahkeme yetkilerini askıya almayı görüşüyor" kartı gelir. İkisinden önce haber şeridinde SOKAK / MAHKEME uyarısı görürsün. Kartı o hafta çözmezsen ayaklanma ya da yetkisiz bırakılma ile düşersin.
8. **Güç merkezleri seni beklemez:** Her hafta kişiler kendi alanlarında küçük hamleler yapar: Arden kendi subaylarını atar, Brandt taşrada miting yapar, Kessler bütçede fazla bulur. Bunları haber şeridinde "HAMLE: …" olarak ve Gündem'deki "Geçen haftadan beri" bölümünde portreleriyle görürsün. Kimin ne yaptığını izlemek, kimin büyüdüğünü önceden görmenin en iyi yoludur.
9. **Eski kararlar geri döner:** Bugün verdiğin bir karar haftalar sonra yeni bir olay olarak karşına çıkabilir. Dokuz güç merkezinin kendi yükseliş, sınav ve sadakat ya da kopuş hikâyesi vardır; sınavda verdiğin karar son sahneyi belirler.
10. **Yönetimin bir ad kazanır:** Altmışıncı hafta dolayında saray, bugüne kadarki emirlerini ve ittifaklarını bir rejim olarak anmaya başlar. Bu yorum haberlerde ve "Geçen haftadan beri" bölümünde görünür. Son dönemde bu yönetim tarzına uygun bir güç merkezi hesap sorar; etiket gizli güç değerlerini açıklamaz.

## Eylemler

| Eylem | Ne işe yarar | Bedeli |
|---|---|---|
| Huzura Çağır | Kişiyi biraz yatıştırır; komplo kuran çoğu zaman kaçamak konuşur, temiz çıkanın hakkındaki dedikodular dağılır | İz bırakmaz; aynı kişi 4 haftada bir |
| Terfi | Güç ve minnet verir | Kişi güçlenir, hırslanır, sana borçlanırsın |
| Gizli Ödeme | Sadakat satın alır | 5 servet; zamanla aşınır, iz bırakır |
| Doğrula | Bir raporu başka kaynaklarla kıyaslar | Sonuç gürültülüdür |
| Görevden Al | Kişiyi oyundan çıkarır | Sırlarını bilen biri karşı saldırıya geçer |
| Araştır | Zayıf noktayı, sonra kırmızı çizgiyi öğrenir | Başarısız olabilir |
| Şantaj | Zayıf noktası bilineni korkuyla bağlar | İz bırakır, geri tepebilir |
| Yazılı / Sözlü Emir | Huzursuzluğu bastırır | Yazılı emir kanıt bırakır |
| İma | İnkâr edilebilir emir | Hırslı biri aşırı yorumlar |
| Soruşturma | Sorunlu isimlere dair ipucu getirir | İpucu yanlış olabilir |
| Gizli Operasyon | 1–3 kişiyle dikkat dağıt, muhalefeti böl, rakibi zayıflat | 2 mesai; çember büyüdükçe sızıntı riski artar |
| Birbirine Düşür | Çoklu seçimle tam iki kişiyi seç: kapışırlarsa ikisi de güç ve hırs kaybeder (komplo koordinasyonu zayıflar) | 2 mesai; başarısız olursa ikisi de kimin yaptığını anlar, hırsları artar ve bir sır doğar; aynı çift için 6 hafta bekleme |
| Söz Ver | Başbakanlık, ihale ya da dokunulmazlık vaat eder | Vadesi gelince ya tutarsın ya bedelini ödersin |

Eylemler, Eylemler panelinde altı sekmede toplanır (KAZAN · SÖZ VER · ÖĞREN · EMRET · BASKI · OPERASYON); bir sekmeye tıklayınca o gruptaki eylemler açılır. Bir eylemin üzerine gelince ne yaptığı, eylemden sonra da sonucu panelin altında görünür. Operasyon için birden fazla kişi seçmek gerekirse OPERASYON sekmesindeki **Çoklu seçim**i aç (ya da Ctrl ile tıkla).

**İlk haftalarda** gündemin üstünde "Bu hafta ne yapmalı?" yol göstericisi durur: 1 Kararını ver → 2 Raporları oku → 3 Bir kişiye eylem → 4 Haftayı bitir. Sıradaki adım altınla vurgulanır; bir adıma tıklamak seni ilgili yere götürür. İpuçları Ayarlar'dan kapatılabilir.

**Raporlar** masaüstünde güç merkezlerinin altında listelenir; bir rapora tıklamak o kişiyi seçer. Sol kenarın rengi raporun ne *söylediğini* gösterir (yeşil iyi, amber tedirgin, kırmızı kötü); gerçeği değil.

## Sırlar ve ortak bilgi

Yaptığın gizli işler **Dosyalar** sekmesinde iz olarak birikir. Bir sırrı ne kadar çok kişi bilirse o kadar hızlı yayılır: önce **dedikodu**, sonra **kamuya açık**. Herkesin bildiği bir zayıflık, sana karşı olanların birleşmesini kolaylaştırır ve yargıyı saraya yaklaştırır. Halk eski skandalları zamanla unutur, ama aynı anda patlayan birkaç skandal tahtı sallayabilir. Kanıtları **bastırabilir**, **yok edebilir** ya da rakiplerin hakkındakileri **sızdırabilirsin**.

## Nasıl kaybedilir

- Ordunun ya da hanedanın liderliğinde bir **darbe**
- **Halk ayaklanması**
- Biriken skandallar yüzünden Meclis ve yargının seni **yetkisiz bırakması**
- Tahtın desteğinin tamamen çökmesi

## Oyun sonu

Saltanat bittiğinde (104 hafta ya da düşüş) sana bir **ünvan** verilir. Tahtta kalırsan ünvanın yönetim tarzını taşıyan bir rejim adı olur; düşersen "Devrilen Kral" kalır. Özet, rejimini ve karşılaştığın son tehdidi anlatır. Sonuç ekranı sekmelere ayrılır:
- **Özet:** Nasıl bittiği, saltanat süresi, söz sicili, yeni başarımlar ve son kararların.
- **Grafik:** "Gerçekte ne oldu" grafiği, oyun boyunca gizli kalan gidişatı gösterir.
- **Tarihçiler:** Saray tarihçisi ve sürgündeki tarihçi saltanatını iki farklı biçimde anlatır.
- **Hakikat Dosyası:** Kim, ne zaman, sana ne yalan söyledi. Altında **Meclis Sicili** (her danışmanın kaç öneri verdiği, kaçını dinlediğin, kaçında seni yanılttığı) ve **Komplo Defteri** (kim ne zaman huzursuzlandı, komploya katıldı, çekildi; alametlerin kaçı gerçekti).
- **Kararlar:** Verdiğin ve ertelediğin tüm kararlar, en yenisi üstte.
- Saltanatın **Hükümdarlık Arşivi**'ne kaydedilir.
- Kazandığın yeni **başarımlar** duyurulur. 15 başarımın tamamı Arşiv'de listelenir.

## Kısayollar

| Tuş | İşlev |
|---|---|
| Boşluk | Haftayı bitir |
| Esc | Menüyü aç/kapat, pencereyi kapat, sinemayı geç |
| Ctrl+S | Kaydet |
| F11 | Tam ekran |

Oyun her hafta sonunda **otomatik kaydedilir**. Saltanat bittiğinde kayıt silinir; tarih tek yönlüdür.

## Ayarlar

Ana menüde dört düğme var: **Devam Et** (oyun sürüyorsa **Oyuna Dön**), **Yeni Oyun**, **Ayarlar**, **Çıkış**. Altındaki bağlantılar: Nasıl Oynanır, Hükümdarlık Arşivi, Hakkında.

Zorluk (Kolay / Normal / Zor) **Yeni Oyun** sayfasında seçilir. **Ayarlar** sayfasında: müzik ve efekt sesi, tam ekran, kısa geçişler, danışman ipuçları, açılış sineması ve haftaya masadan başlama. Esc alt sayfadan ana menüye döner.

## İpuçları

- İlk haftalarda Saray Kâtibi'nin notlarını oku.
- Kimseyi tek başına seni deviremeyecek kadar güçlü bırakma. Biri büyüyorsa rakibini güçlendir.
- Raporlar çelişiyorsa **Doğrula** kullan; kaynak karnesi zamanla kimin süslediğini gösterir.
- Aynı makamı iki kişiye vaat etmek mümkündür. Ama er geç duyulur.
