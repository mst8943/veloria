# �ngilizce yerelle�tirme envanteri

Bu rapor `tools/i18n_scan.py` ile �retilir. Say�lar metin y�zeyini g�sterir; oyun mant���n� de�i�tirmez.

## GDScript T�rk�e sabitleri

| Dosya | Sabit say�s� |
|---|---:|
| `game/core/actor.gd` | 1 |
| `game/core/advice.gd` | 2 |
| `game/core/content_data.gd` | 55 |
| `game/core/press.gd` | 84 |
| `game/core/sim.gd` | 308 |
| `game/ui/agenda_view.gd` | 53 |
| `game/ui/autoplay.gd` | 4 |
| `game/ui/cinema.gd` | 1 |
| `game/ui/city_view.gd` | 34 |
| `game/ui/desk_view.gd` | 20 |
| `game/ui/end_screen.gd` | 57 |
| `game/ui/main.gd` | 62 |
| `game/ui/media_view.gd` | 14 |
| `game/ui/menu.gd` | 18 |
| `game/ui/modal.gd` | 1 |
| `game/ui/person_panel.gd` | 144 |
| `game/ui/truth_chart.gd` | 5 |
| `game/ui/ui_kit.gd` | 4 |

Toplam: **867** T�rk�e sabit.

## JSON oyuncu metinleri

| Dosya | Metin alan� | Kelime | T�rk�e karakterli |
|---|---:|---:|---:|
| `actors.json` | 56 | 152 | 37 |
| `city_map.json` | 0 | 0 | 0 |
| `content_achievements.json` | 44 | 179 | 36 |
| `content_council.json` | 62 | 180 | 46 |
| `content_history.json` | 20 | 131 | 20 |
| `content_labels.json` | 22 | 158 | 20 |
| `content_reports.json` | 159 | 978 | 151 |
| `events.json` | 1528 | 8794 | 1382 |

## Riskli noktalar

| Dosya: sat�r | Risk |
|---|---|
| `game/core/actor.gd:92` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/advice.gd:34` | ek() ek uyumu: t�m c�mle ayr� �evirilmeli |
| `game/core/content_data.gd:98` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/content_data.gd:100` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/content_data.gd:120` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/content_data.gd:122` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/content_data.gd:165` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/content_data.gd:167` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/content_data.gd:174` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/narrative.gd:45` | ek() ek uyumu: t�m c�mle ayr� �evirilmeli |
| `game/core/press.gd:126` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/press.gd:152` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/press.gd:178` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:574` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:844` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:847` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:849` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:1076` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:1424` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:1536` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:1539` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:2066` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:2171` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:2332` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:2349` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:2361` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/core/sim.gd:2368` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/city_view.gd:271` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/end_screen.gd:185` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/end_screen.gd:232` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/main.gd:1182` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/main.gd:1222` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/person_panel.gd:308` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/person_panel.gd:338` | ek() ek uyumu: t�m c�mle ayr� �evirilmeli |
| `game/ui/person_panel.gd:604` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |
| `game/ui/person_panel.gd:611` | T�rk�e metin i� anahtar/kar��la�t�rma olabilir; g�sterimde �evir, anahtar� koru |

## �eviri girdileri

| Dosya: sat�r | Kaynak | Bi�im yer tutucusu |
|---|---|---|
| `game/core/actor.gd:92` | ate� | `-` |
| `game/core/advice.gd:52` | �IKARI VAR | `-` |
| `game/core/advice.gd:281` |  Gazeteler ona ba�l�, Majesteleri. | `-` |
| `game/core/content_data.gd:19` | dosya bulunamad� | `-` |
| `game/core/content_data.gd:22` | JSON bozuk veya akt�r listesi dizi de�il | `-` |
| `game/core/content_data.gd:27` | akt�r kimli�i veya alan� eksik | `-` |
| `game/core/content_data.gd:34` | dosya bulunamad� | `-` |
| `game/core/content_data.gd:37` | JSON bozuk veya k�k s�zl�k de�il | `-` |
| `game/core/content_data.gd:62` | ��erik dosyas� hatal�: %s (%s). Oyunu ba�latmadan dosyay� d�zeltin. | `%s, %s` |
| `game/core/content_data.gd:93` | bo� rapor metni: %s | `%s` |
| `game/core/content_data.gd:95` | phrases/sign_texts s�zl�k olmal� | `-` |
| `game/core/content_data.gd:98` | eksik rapor alan�: %s | `%s` |
| `game/core/content_data.gd:100` | bilinmeyen rapor alan�: %s | `%s` |
| `game/core/content_data.gd:102` | %s: �� rapor band� gerekli | `%s` |
| `game/core/content_data.gd:104` | %s: bo� rapor metni | `%s` |
| `game/core/content_data.gd:106` | d�rt kurum raporu gerekli | `-` |
| `game/core/content_data.gd:111` | �� kurum band� gerekli: %s | `%s` |
| `game/core/content_data.gd:112` | aks�yor | `-` |
| `game/core/content_data.gd:112` | y�r�yor | `-` |
| `game/core/content_data.gd:112` | sa�lam | `-` |
| `game/core/content_data.gd:114` | eksik/bo� kurum raporu: %s/%s | `%s, %s` |
| `game/core/content_data.gd:118` | eksik/bo� alamet a�amas�: %s | `%s` |
| `game/core/content_data.gd:120` | bilinmeyen alamet a�amas�: %s | `%s` |
| `game/core/content_data.gd:122` | bilinmeyen alamet alan�: %s | `%s` |
| `game/core/content_data.gd:123` | bo� alamet metni: %s/%s | `%s, %s` |
| `game/core/content_data.gd:135` | bo� tarih�i metni: %s | `%s` |
| `game/core/content_data.gd:139` | tarih�i bi�im alan� eksik: %s | `%s` |
| `game/core/content_data.gd:148` | %s s�zl�k olmal� | `%s` |
| `game/core/content_data.gd:150` | eksik/bo� metin dizisi: %s | `%s` |
| `game/core/content_data.gd:151` | �� �neri kal�b� gerekli | `-` |
| `game/core/content_data.gd:152` | cover_default bo� | `-` |
| `game/core/content_data.gd:154` | Roma se�im etiketleri e�le�miyor | `-` |
| `game/core/content_data.gd:156` | �neri kal�b�nda bir %s gerekli | `%s` |
| `game/core/content_data.gd:160` | akt�r gerek�esinde ad eki eksik: %s | `%s` |
| `game/core/content_data.gd:163` | uzman �ifti eksik: %s | `%s` |
| `game/core/content_data.gd:165` | bilinmeyen uzman akt�r: %s | `%s` |
| `game/core/content_data.gd:167` | bilinmeyen k�l�f akt�r�: %s | `%s` |
| `game/core/content_data.gd:168` | bo� k�l�f: %s | `%s` |
| `game/core/content_data.gd:172` | eksik/bo� gerek�e: %s | `%s` |
| `game/core/content_data.gd:174` | eksik gerek�e: %s | `%s` |
| `game/core/content_data.gd:179` | ba�ar�m listesi bo� | `-` |
| `game/core/content_data.gd:182` | eksik/bo� ba�ar�m: %s | `%s` |
| `game/core/content_data.gd:191` | eksik/bo� etiket: %s | `%s` |
| `game/core/content_data.gd:192` | �� s�z �d�l� gerekli | `-` |
| `game/core/content_data.gd:194` | g�� kademeleri eksik | `-` |
| `game/core/content_data.gd:196` | bo� g�� kademesi | `-` |
| `game/core/content_data.gd:198` | rapor/tav�r kademeleri eksik | `-` |
| `game/core/content_data.gd:199` | rejim s�ras�/kimlikleri de�i�mi� | `-` |
| `game/core/content_data.gd:202` | b�t�e kart� anahtarlar� eksik | `-` |
| `game/core/content_data.gd:204` | bo� b�t�e metni: %s | `%s` |
| `game/core/content_data.gd:206` | b�t�e kart�nda d�rt se�enek gerekli | `-` |
| `game/core/content_data.gd:209` | b�t�e se�ene�i eksik | `-` |
| `game/core/content_data.gd:211` | b�t�e se�ene�i hatal� | `-` |
| `game/core/content_data.gd:214` | Sarne talep kart� anahtarlar� eksik | `-` |
| `game/core/content_data.gd:218` | Sarne talebinde d�rt se�enek gerekli | `-` |
| `game/core/content_data.gd:221` | Sarne talep se�ene�i hatal� | `-` |
| `game/core/content_data.gd:223` | %s s�zl�k olmal� | `%s` |
| `game/core/content_data.gd:227` | %s: %s bo� | `%s, %s` |
| `game/core/press.gd:7` | VELOR�A HABER | `-` |
| `game/core/press.gd:7` | Krall���n sesi � 1892'den beri | `-` |
| `game/core/press.gd:8` | Ba��ms�z � Korkusuz � Haftal�k | `-` |
| `game/core/press.gd:12` | Ekonomide alt�n d�nem | `-` |
| `game/core/press.gd:12` | Hazine g��l�, pazarlar canl�. Uzmanlar krall���n istikrar�n� �v�yor. | `-` |
| `game/core/press.gd:13` | Ekonomi sa�lam zeminde | `-` |
| `game/core/press.gd:13` | Baz� fiyat dalgalanmalar�na ra�men h�k�met kontrol� elinde tutuyor. | `-` |
| `game/core/press.gd:14` | Ge�ici zorluklar a��lacak | `-` |
| `game/core/press.gd:14` | Bakanl�k, d�� etkenlerden kaynaklanan s�k�nt�n�n k�sa s�rede bitece�ini a��klad�. | `-` |
| `game/core/press.gd:15` | Pazarda nefes al�n�yor | `-` |
| `game/core/press.gd:16` | Fiyatlar cebi yak�yor | `-` |
| `game/core/press.gd:16` | Ekmek ve yak�t fiyatlar� yine artt�. Maa�lar ayn� yerde duruyor. | `-` |
| `game/core/press.gd:17` | Kulislere g�re maa�lar i�in bor� aran�yor. Resm� rakamlar ise ba�ka bir �ey s�yl�yor. | `-` |
| `game/core/press.gd:20` | Ba�kentte huzur | `-` |
| `game/core/press.gd:20` | Vatanda�lar g�nl�k hayat�na devam ediyor; meydanlarda bayram havas�. | `-` |
| `game/core/press.gd:21` | Baz� gruplar tahrik pe�inde | `-` |
| `game/core/press.gd:21` | Polis, az say�daki provokat�r�n kamu d�zenini bozmas�na izin vermeyece�ini a��klad�. | `-` |
| `game/core/press.gd:22` | Yabanc� parma�� | `-` |
| `game/core/press.gd:22` | Uzmanlara g�re son olaylar�n arkas�nda d�� g��ler var. | `-` |
| `game/core/press.gd:24` | �fke b�y�yor | `-` |
| `game/core/press.gd:24` | F�r�n kuyruklar�nda konu�ulanlar art�k fiyatlar de�il, saray. | `-` |
| `game/core/press.gd:25` | Binlerce ki�i sokakta. Polisin baz� birimlerinin m�dahaleden ka��nd��� g�r�ld�. | `-` |
| `game/core/press.gd:28` | Muhalefet da��n�k | `-` |
| `game/core/press.gd:28` | Voss'un partisi i� kavgalarla u�ra��yor. | `-` |
| `game/core/press.gd:29` | Meclisteki baz� vekillerin s�ylemleri istikrar� tehdit ediyor. | `-` |
| `game/core/press.gd:30` | Muhalefete sert uyar� | `-` |
| `game/core/press.gd:30` | H�k�met, soka�� k��k�rtanlar�n hesap verece�ini a��klad�. | `-` |
| `game/core/press.gd:31` | Voss bu hafta k�rs�ye ��kmad�. | `-` |
| `game/core/press.gd:32` | Muhalefet �rg�tleniyor | `-` |
| `game/core/press.gd:32` | Kapal� kap�lar ard�nda iki kanad�n birle�me g�r��mesi s�r�yor. | `-` |
| `game/core/press.gd:33` | Muhalefet soka�a �a��r�yor | `-` |
| `game/core/press.gd:33` | Voss: 'Bu saray halk�n sesini art�k duymak zorunda.' | `-` |
| `game/core/press.gd:35` | Kral, saray bah�elerini halka a�t�. | `-` |
| `game/core/press.gd:35` | Kraliyet orkestras� hafta sonu konser verecek. | `-` |
| `game/core/press.gd:36` | Kral, yetimhaneye ba���ta bulundu. | `-` |
| `game/core/press.gd:36` | Saray protokol� yeni t�renler haz�rl�yor. | `-` |
| `game/core/press.gd:36` | Kral'�n sabah y�r�y��� halk� mutlu etti. | `-` |
| `game/core/press.gd:37` | Ba�kentte ya�mur, gece sis. | `-` |
| `game/core/press.gd:37` | A��k ve so�uk; sabah k�ra��. | `-` |
| `game/core/press.gd:37` | Bulutlu, ak�ama do�ru f�rt�na. | `-` |
| `game/core/press.gd:38` | G�ne�li ama r�zg�rl�. | `-` |
| `game/core/press.gd:38` | Kar bekleniyor; yollar kayganla�abilir. | `-` |
| `game/core/press.gd:38` | Il�k bir hafta, gece serin. | `-` |
| `game/core/press.gd:39` | KRAL�YET P�YANGOSU � B�y�k ikramiye bu cumartesi! | `-` |
| `game/core/press.gd:39` | SARNE ENERJ� � K��a haz�r m�s�n�z? | `-` |
| `game/core/press.gd:40` | Saat tamiri ve alt�n al�m sat�m� � Eski �ar�� No: 12 | `-` |
| `game/core/press.gd:40` | Grand Otel Veloria � Balo salonu kiralan�r. | `-` |
| `game/core/press.gd:41` | Kay�p: Gri kedi, ad� Baron. Bulana �d�l. | `-` |
| `game/core/press.gd:41` | Terc�me b�rosu � Gizlilik garantili. | `-` |
| `game/core/press.gd:54` | g�rd��� | `-` |
| `game/core/press.gd:82` | Serbest Kalem bu hafta da bas�lamad�. Matbaan�n kap�s�nda m�h�r var. Muhabirlerin bir k�sm� yurtd���nda. | `-` |
| `game/core/press.gd:95` | Saray, son g�nlerde yay�lan iddialar�n 'krall��� y�pratmaya y�nelik bir karalama' oldu�unu a��klad�. | `-` |
| `game/core/press.gd:98` | Belgeler art�k herkesin elinde. Saray sessiz. | `-` |
| `game/core/press.gd:100` | %s g�ndemde | `%s` |
| `game/core/press.gd:101` | Kulislerde konu�ulan iddia bu hafta kamuoyuna yans�d�. | `-` |
| `game/core/press.gd:114` | Yetkililer durumun kontrol alt�nda oldu�unu vurgulad�.  | `-` |
| `game/core/press.gd:118` | Krall�kta huzur ve istikrar | `-` |
| `game/core/press.gd:123` | Sab�r ta��yor mu? | `-` |
| `game/core/press.gd:123` | Ba�kent tedirgin | `-` |
| `game/core/press.gd:124` | Saraydan bu hafta da a��klama yok. Sokak ise konu�uyor. | `-` |
| `game/core/press.gd:126` | d��manca | `-` |
| `game/core/press.gd:127` | H�k�met s�z�n� tutmad� | `-` |
| `game/core/press.gd:128` | Sarne'nin yay�n kurulu bu hafta saray�n kararlar�n� sert s�zlerle sorguluyor. | `-` |
| `game/core/press.gd:135` | EKONOM� | `-` |
| `game/core/press.gd:139` | MECL�S | `-` |
| `game/core/press.gd:147` | KUL�S | `-` |
| `game/core/press.gd:147` | Saray koridorlar� sessiz | `-` |
| `game/core/press.gd:147` | Bu hafta kula��m�za bir �ey �al�nmad�. Ya da �al�nmas�na izin verilmedi. | `-` |
| `game/core/press.gd:149` | KUL�S | `-` |
| `game/core/press.gd:149` | Koridorlarda konu�ulanlar | `-` |
| `game/core/press.gd:149` | Kaynaklar�m�za g�re:  | `-` |
| `game/core/press.gd:151` | Kraliyet ajandas� | `-` |
| `game/core/press.gd:152` | d��manca | `-` |
| `game/core/press.gd:154` | EKONOM� | `-` |
| `game/core/press.gd:154` | Bakanl��a zor sorular | `-` |
| `game/core/press.gd:154` | Yay�n kurulu, saray�n harcamalar�na ili�kin hesab�n a��klanmas�n� istiyor. | `-` |
| `game/core/press.gd:155` | Halk�n sesi duyulmal� | `-` |
| `game/core/press.gd:155` | Sarne'nin k��e yazarlar� kararlar�n halka sorulmad���n� savunuyor. | `-` |
| `game/core/press.gd:156` | MECL�S | `-` |
| `game/core/press.gd:156` | Saray meclise d�ns�n | `-` |
| `game/core/press.gd:156` | Kanaldaki yorumcular kraliyet kararlar�n�n denetlenmesini talep ediyor. | `-` |
| `game/core/press.gd:157` | A��klama bekleniyor | `-` |
| `game/core/press.gd:157` | Yay�n kurulu saraydan cevap bekledi�ini duyurdu. | `-` |
| `game/core/press.gd:178` | DEVLET TELEV�ZYONU | `-` |
| `game/core/sim.gd:213` | a�ouei�� | `-` |
| `game/core/sim.gd:216` | a�ouei�� | `-` |
| `game/core/sim.gd:217` | a�ou | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:220` | � | `-` |
| `game/core/sim.gd:257` | Veri dosyas� a��lamad�:  | `-` |
| `game/core/sim.gd:386` | Kay�tl� oyun bulunamad�. | `-` |
| `game/core/sim.gd:391` | Kay�t dosyas� okunamad�; bozulmu� olabilir. | `-` |
| `game/core/sim.gd:395` | Bu kay�t oyunun daha yeni bir s�r�m�yle yap�lm��. Oyunu g�ncelleyin. | `-` |
| `game/core/sim.gd:401` | Kay�t dosyas� eksik ya da bozuk ('%s' yok). | `%s` |
| `game/core/sim.gd:471` | Bu hafta mesain kalmad�. | `-` |
| `game/core/sim.gd:488` | %s terfi etti. Sana minnettar, ama art�k daha g��l�. | `%s` |
| `game/core/sim.gd:498` | �ocuksu | `-` |
| `game/core/sim.gd:498` | Geli�iyor | `-` |
| `game/core/sim.gd:498` | Haz�r | `-` |
| `game/core/sim.gd:507` | Veliaht i�in bu kararname ��kar�lamaz. | `-` |
| `game/core/sim.gd:509` | Julian'�n yeni dersleri i�in beklemelisin. | `-` |
| `game/core/sim.gd:523` | Julian derslerini ilerletti. Prens Marcus ile Marcus Arden, veliahd�n sarayda fazla �ne ��kt���n� konu�uyor. | `-` |
| `game/core/sim.gd:525` | Julian derslerini ilerletti. Ne ��rendi�ini halk�n �n�nde g�receksin. | `-` |
| `game/core/sim.gd:534` | Heyet g�nderilecek el�iyi se�melisin. | `-` |
| `game/core/sim.gd:536` | El�ilikler �nceki heyetin cevab�n� bekliyor. | `-` |
| `game/core/sim.gd:545` | %s heyeti kabul etti. �teki el�ilikler bu yak�nl��� dikkatle not etti. | `%s` |
| `game/core/sim.gd:550` | Bu kadro kararnamesi ��kar�lamaz. | `-` |
| `game/core/sim.gd:552` | Bu kurumda yeni bir atama i�in beklemelisin. | `-` |
| `game/core/sim.gd:574` | %s i�in %s kadro kararnamesi imzaland�. Sonucu kurumun i�inde g�receksin. | `%s, %s` |
| `game/core/sim.gd:574` | sad�k | `-` |
| `game/core/sim.gd:585` | �hale komisyonu yeni dosyay� hen�z a�m�yor. | `-` |
| `game/core/sim.gd:597` | Sarne ihalesinden saraya aktar�lan komisyon | `-` |
| `game/core/sim.gd:599` | �hale Sarne'ye verildi. �irketleri i�i �stlendi; Veyra s�zle�menin bir kopyas�n� saklad�. | `-` |
| `game/core/sim.gd:605` | d��manca | `-` |
| `game/core/sim.gd:607` | s�cak | `-` |
| `game/core/sim.gd:608` | s�cak | `-` |
| `game/core/sim.gd:613` | s�n�rl� | `-` |
| `game/core/sim.gd:613` | yayg�n | `-` |
| `game/core/sim.gd:639` | %s art�k �a�r�na gelmiyor. | `%s` |
| `game/core/sim.gd:641` | %s yak�n zamanda huzura �a��rd�n; tekrar �a��rmak tela� gibi g�r�n�r. | `%s` |
| `game/core/sim.gd:652` | %s huzurda ka�amak cevaplar verdi; g�zlerini ka��rd�. | `%s` |
| `game/core/sim.gd:653` | %s huzurunda gergindi. Sorular�na ka�amak cevaplar verdi ve erken ayr�lmak i�in izin istedi. | `%s` |
| `game/core/sim.gd:654` | %s sakin ve sayg�l�yd�. Hi�bir �ey sezmedin. | `%s` |
| `game/core/sim.gd:656` | %s huzurda tedirgin g�r�n�yordu. | `%s` |
| `game/core/sim.gd:657` | %s tedirgindi; neden oldu�unu s�ylemedi. | `%s` |
| `game/core/sim.gd:661` | %s i�tenlikle konu�tu. | `%s` |
| `game/core/sim.gd:663` |  Hakk�ndaki f�s�lt�lar�n dedikodu oldu�una kanaat getirdin. | `-` |
| `game/core/sim.gd:665` |  Yine de saraydan baz� �ik�yetleri oldu�u belli. | `-` |
| `game/core/sim.gd:676` | Ki�isel servetin yetersiz. | `-` |
| `game/core/sim.gd:683` | %s yap�lan gizli �deme | `%s` |
| `game/core/sim.gd:685` | %s gizli �deme yap�ld�. Sadakati artt�; ama bir iz kald�. | `%s` |
| `game/core/sim.gd:700` | %s verilen yaz�l� emir | `%s` |
| `game/core/sim.gd:711` | %s emri geciktirdi; uygulamak i�in 'ko�ullar�n olgunla�mas�n�' bekliyor. | `%s` |
| `game/core/sim.gd:732` | %s emri fazla sert yorumlad�; bast�rma kontrolden ��k�yor. | `%s` |
| `game/core/sim.gd:734` | %s emri anlamad� ya da uygulamad�. Hi�bir �ey olmad�. | `%s` |
| `game/core/sim.gd:736` | %s harekete ge�ti. | `%s` |
| `game/core/sim.gd:741` | %s soru�turmay� ba�latt�. | `%s` |
| `game/core/sim.gd:743` | %s emri ald�. | `%s` |
| `game/core/sim.gd:745` | %s emri k�rm�z� �izgisini a�t��� i�in g�n�ls�zce, yar�m yamalak uygulad�. Bunu sana yazd�. (K�rm�z� �izgisi: %s) | `%s, %s` |
| `game/core/sim.gd:747` |  Ama acele etmedi; emri g�nlerce bekletti. | `-` |
| `game/core/sim.gd:757` | %s hakk�nda ��renilecek yeni bir �ey kalmad�. | `%s` |
| `game/core/sim.gd:768` | %s hakk�ndaki ara�t�rma sonu� vermedi. �zler so�uk. | `%s` |
| `game/core/sim.gd:772` | %s zay�f noktas� bulundu: %s. Art�k �antaj m�mk�n. | `%s, %s` |
| `game/core/sim.gd:775` | %s asla ge�meyece�i �izgi: %s. | `%s, %s` |
| `game/core/sim.gd:783` | �nce %s zay�f noktas�n� bulmal�s�n (Ara�t�r). | `%s` |
| `game/core/sim.gd:789` | %s yap�lan �antaj | `%s` |
| `game/core/sim.gd:796` | %s boyun e�medi; �antaj� if�a etmekle tehdit ediyor. Konu�ulmaya ba�land� bile. | `%s` |
| `game/core/sim.gd:802` | %s ne demek istedi�ini anlad�. Art�k senden korkuyor; korku ise sadakatin en k�r�lgan bi�imi. | `%s` |
| `game/core/sim.gd:817` | Soru�turma notu: %s hakk�nda endi�e verici bir ipucu bulundu. | `%s` |
| `game/core/sim.gd:821` | Soru�turma notu: %s hakk�nda endi�e verici bir ipucu bulundu. | `%s` |
| `game/core/sim.gd:837` | El�ilik kay�tlar� alt� hafta i�in a��k:  | `-` |
| `game/core/sim.gd:844` | %s raporu di�er kaynaklarla b�y�k �l��de �rt���yor.%s | `%s, %s` |
| `game/core/sim.gd:844` |  Kurum defterleri bir s�reli�ine a��ld�. | `-` |
| `game/core/sim.gd:847` | Ba�ka kaynaklar durumun %s anlatt���ndan DAHA K�T� oldu�unu s�yl�yor.%s | `%s, %s` |
| `game/core/sim.gd:847` |  Kurum defterleri bir s�reli�ine a��ld�. | `-` |
| `game/core/sim.gd:849` | Ba�ka kaynaklar durumu %s anlatt���ndan biraz daha iyi g�r�yor.%s | `%s, %s` |
| `game/core/sim.gd:849` |  Kurum defterleri bir s�reli�ine a��ld�. | `-` |
| `game/core/sim.gd:855` | Operasyon i�in 1�3 ki�i se� (Ctrl ile �oklu se�im). | `-` |
| `game/core/sim.gd:875` | Sahte kriz i�e yarad�; g�ndem de�i�ti. | `-` |
| `game/core/sim.gd:879` | Operasyon amat�rce kald�; kimse inanmad�. | `-` |
| `game/core/sim.gd:883` | Muhalefet kanatlar� birbirine d��t�. | `-` |
| `game/core/sim.gd:886` | Muhalefet plan� fark etti ve birle�me h�zland�. | `-` |
| `game/core/sim.gd:895` | Zay�flat�lacak kimse yok. | `-` |
| `game/core/sim.gd:899` | %s itibar� sars�ld�. Kim yapt���n� tahmin etmesi zor de�il. | `%s` |
| `game/core/sim.gd:901` | Operasyon bo�a gitti; %s ��phelendi. | `%s` |
| `game/core/sim.gd:903` |  (�ember: %s) | `%s` |
| `game/core/sim.gd:907` |  Ama bir �ey s�zm�� gibi. | `-` |
| `game/core/sim.gd:933` | Birbirine d���rmek i�in tam iki ki�i se� (�oklu se�im). | `-` |
| `game/core/sim.gd:937` | Se�ilen ki�ilerden biri art�k sarayda de�il. | `-` |
| `game/core/sim.gd:939` | Sana kar�� harekete ge�mi� biriyle oyun oynamak i�e yaramaz. | `-` |
| `game/core/sim.gd:942` | %s ile %s'i yak�n zamanda birbirine d���rmeyi denedin; %d hafta bekle. | `%s, %s, %d` |
| `game/core/sim.gd:944` | Birbirine d���rmek 2 mesai ister. | `-` |
| `game/core/sim.gd:955` | %s ile %s birbirine girdi. �kisi de art�k birbirini izliyor; sana ay�racak zamanlar� az. | `%s, %s` |
| `game/core/sim.gd:960` | Kral�n dan��manlar�n� birbirine d���rme giri�imi | `-` |
| `game/core/sim.gd:961` | %s ile %s oyunu anlad�: iki taraf da bunun arkas�nda kimin oldu�unu biliyor. | `%s, %s` |
| `game/core/sim.gd:963` | Saray i�i rekabetin kralca k��k�rt�lmas� | `-` |
| `game/core/sim.gd:964` |  Bir �ey s�zm�� gibi. | `-` |
| `game/core/sim.gd:972` | Olmad� (mesai ya da dosya yok). | `-` |
| `game/core/sim.gd:976` | '%s' bas�na s�zd�r�ld�. | `%s` |
| `game/core/sim.gd:981` | Olmad� (mesai ya da dosya yok). | `-` |
| `game/core/sim.gd:985` | '%s' i�in sessizlik sa�land�. Kan�t�n kopyalar� h�l� duruyor. | `%s` |
| `game/core/sim.gd:996` | Bu art�k herkesin bildi�i bir �ey; kan�t� yok etmek i�e yaramaz. | `-` |
| `game/core/sim.gd:1000` | '%s' kan�t�n�n bir kopyas� yok edildi; h�l� kopyalar� var. | `%s` |
| `game/core/sim.gd:1004` | Kan�t yok edildi. | `-` |
| `game/core/sim.gd:1007` | Giri�im fark edildi; dosya hakk�nda dedikodu artt�. | `-` |
| `game/core/sim.gd:1031` | %s art�k verilemez; zaten birine verildi. | `%s` |
| `game/core/sim.gd:1044` | %s %s s�z� verdin. G�zleri parlad�; vadesi geldi�inde hat�rlatacak. | `%s, %s` |
| `game/core/sim.gd:1076` | Ayn� makam�n birden �ok ki�iye vaat edilmesi (%s) | `%s` |
| `game/core/sim.gd:1078` | KUL�S: %s ayn� s�z� ald�klar�n� ��rendi: %s. | `%s, %s` |
| `game/core/sim.gd:1092` | %s, %d. haftada verdi�in '%s' s�z�n� hat�rlat�yor. Bekleyi�i sab�rl�, ama sonsuz de�il. | `%s, %d, %s` |
| `game/core/sim.gd:1094` |  Ayn� s�z� %s de vermi�tin. | `%s` |
| `game/core/sim.gd:1095` | %s s�z�n� hat�rlat�yor | `%s` |
| `game/core/sim.gd:1097` | S�z� tut: %s | `%s` |
| `game/core/sim.gd:1097` | %s s�z�n� ald�. Bunu unutmayacak. | `%s` |
| `game/core/sim.gd:1098` | %s bekleyecek. Ama hevesi azald�. | `%s` |
| `game/core/sim.gd:1099` | S�zden d�n | `-` |
| `game/core/sim.gd:1099` | %s y�z�ne bakmadan ��kt�. Saray bunu konu�acak. | `%s` |
| `game/core/sim.gd:1100` | S�z cevaps�z kald�; bozulmu� say�ld�. | `-` |
| `game/core/sim.gd:1101` | S�Z: %s kar��l���n� istiyor. | `%s` |
| `game/core/sim.gd:1114` | Ba�bakanl�k | `-` |
| `game/core/sim.gd:1117` | Liman �halesi | `-` |
| `game/core/sim.gd:1139` | %s verilip tutulmayan s�z (%s) | `%s, %s` |
| `game/core/sim.gd:1142` | %s, kendisine vaat edilen %s ba�kas�na verildi�i i�in �fkeli. | `%s, %s` |
| `game/core/sim.gd:1162` | %s kral�n s�rlar�n� s�zd�r�yor | `%s` |
| `game/core/sim.gd:1164` | %s g�revden al�nd� ama kral�n s�rlar�n� biliyordu ve konu�maya ba�lad�! | `%s` |
| `game/core/sim.gd:1168` | darbe gecesi g�revden al�nd�; komplo ba�s�z kald� | `-` |
| `game/core/sim.gd:1171` | %s g�revden al�nd�. Sessizce gitti. | `%s` |
| `game/core/sim.gd:1182` | Bu karar�n gerektirdi�i ki�i art�k sarayda de�il. | `-` |
| `game/core/sim.gd:1185` | Leyla art�k ba��ms�z yay�n kuram�yor. | `-` |
| `game/core/sim.gd:1187` | Renn art�k savc�l��a ba�vuram�yor. | `-` |
| `game/core/sim.gd:1190` | Ki�isel servetin yetersiz. | `-` |
| `game/core/sim.gd:1241` | saray pay� devlet kasas�ndan ayr�l�yor | `-` |
| `game/core/sim.gd:1342` | ERTELEND� � %s: %s | `%s, %s` |
| `game/core/sim.gd:1359` | REJ�M: Saray art�k %s bir d�zen olarak an�l�yor. | `%s` |
| `game/core/sim.gd:1370` | Y�netimin %s bir rejim olarak an�lmaya ba�lad�. | `%s` |
| `game/core/sim.gd:1390` | Neler de�i�ti? | `-` |
| `game/core/sim.gd:1413` | ERTELEND� �  | `-` |
| `game/core/sim.gd:1414` | Kendili�inden ��z�ld�:  | `-` |
| `game/core/sim.gd:1415` | MAN�ET:  | `-` |
| `game/core/sim.gd:1417` | KUL�S:  | `-` |
| `game/core/sim.gd:1419` | MAL�YE:  | `-` |
| `game/core/sim.gd:1419` | ADL�YE:  | `-` |
| `game/core/sim.gd:1419` | �DARE:  | `-` |
| `game/core/sim.gd:1419` | DI���LER�:  | `-` |
| `game/core/sim.gd:1424` | d��manca | `-` |
| `game/core/sim.gd:1425` | Sarne'nin yay�nlar�n�n havas� de�i�ti: art�k %s. | `%s` |
| `game/core/sim.gd:1430` | %s art�k sarayda de�il. | `%s` |
| `game/core/sim.gd:1434` | %s sana kar�� a��k�a harekete ge�ti. | `%s` |
| `game/core/sim.gd:1440` | %s tavr� %s: art�k %s. | `%s, %s, %s` |
| `game/core/sim.gd:1440` | sertle�ti | `-` |
| `game/core/sim.gd:1440` | yumu�ad� | `-` |
| `game/core/sim.gd:1445` | %s %s: art�k %s. | `%s, %s, %s` |
| `game/core/sim.gd:1445` | g��lendi | `-` |
| `game/core/sim.gd:1445` | g�� kaybetti | `-` |
| `game/core/sim.gd:1451` | %s raporu %s: art�k %s. | `%s, %s, %s` |
| `game/core/sim.gd:1451` | k�t�le�ti | `-` |
| `game/core/sim.gd:1451` | iyile�ti | `-` |
| `game/core/sim.gd:1461` | %s verdi�in %s s�z� tutuldu. | `%s, %s` |
| `game/core/sim.gd:1463` | %s verdi�in %s s�z� bozuldu. | `%s, %s` |
| `game/core/sim.gd:1465` | %s verdi�in %s s�z� ge�ersiz kald�. | `%s, %s` |
| `game/core/sim.gd:1467` | %s %s s�z�n�n kar��l���n� istiyor. | `%s, %s` |
| `game/core/sim.gd:1536` | s�cak | `-` |
| `game/core/sim.gd:1539` | d��manca | `-` |
| `game/core/sim.gd:1583` | DI���LER�: %s ile ili�ki yak�nla�t�; el�ilik kap�lar� a��k. | `%s` |
| `game/core/sim.gd:1586` | DI���LER�: %s ile ili�ki so�udu; el�ilikten sert bir nota geldi. | `%s` |
| `game/core/sim.gd:1595` | MAL�YE: Kasa daral�yor; maa� defterleri yeniden a��ld�. | `-` |
| `game/core/sim.gd:1596` | MAL�YE: Vergi defterleri masalarda birikiyor. | `-` |
| `game/core/sim.gd:1597` | ADL�YE: Dosyalar takviminden d���yor; savc�lar yeti�emiyor. | `-` |
| `game/core/sim.gd:1598` | ORDU: S�n�r birliklerinde haz�rl�k gecikiyor. | `-` |
| `game/core/sim.gd:1599` | �DARE: Saray emirleri valiliklere ge� ula��yor. | `-` |
| `game/core/sim.gd:1621` | aks�yor | `-` |
| `game/core/sim.gd:1621` | y�r�yor | `-` |
| `game/core/sim.gd:1621` | sa�lam | `-` |
| `game/core/sim.gd:1629` | s�k���k | `-` |
| `game/core/sim.gd:1638` | KUL�S: '%s' konu�ulmaya ba�lad�. | `%s` |
| `game/core/sim.gd:1650` | MAN�ET: %s herkesin bildi�i bir �ey oldu. | `%s` |
| `game/core/sim.gd:1679` | d��manca | `-` |
| `game/core/sim.gd:1770` | hen�z �ekillenmemi� | `-` |
| `game/core/sim.gd:1835` | Ge�en haftadan beri | `-` |
| `game/core/sim.gd:1848` | MAL�YE: Meclis b�t�eyi g�r��emedi; eski dengeli d�zen s�rd�. | `-` |
| `game/core/sim.gd:1853` |  Veyra'n�n son raporu:  | `-` |
| `game/core/sim.gd:1916` | Sarne'ye verilen yeni yay�n ve ihale pay� | `-` |
| `game/core/sim.gd:1943` |  Defterler a��ld�; Sarne geri �ekiliyor. | `-` |
| `game/core/sim.gd:1946` | Sarne soru�turmas�n�n saraydan s�zmas� | `-` |
| `game/core/sim.gd:1947` |  Dosya s�zd�; yay�nlar saray� hedef al�yor. | `-` |
| `game/core/sim.gd:1976` | ka� ki�i k�p�rdarsa ben de k�p�rdar�m | `-` |
| `game/core/sim.gd:1986` | Darbe kap�na dayand���nda karar veremedin. | `-` |
| `game/core/sim.gd:2061` | komploya kat�ld� | `-` |
| `game/core/sim.gd:2063` | darbe haz�rl���na ge�ti | `-` |
| `game/core/sim.gd:2065` | komplodan �ekildi | `-` |
| `game/core/sim.gd:2066` | huzursuzlanmaya ba�lad� | `-` |
| `game/core/sim.gd:2067` | huzursuzlanmaya ba�lad� | `-` |
| `game/core/sim.gd:2151` | darbe giri�imini ba�latt� | `-` |
| `game/core/sim.gd:2153` | KR�Z: %s harekete ge�ti. Saray ku�at�lmak �zere. | `%s` |
| `game/core/sim.gd:2158` | Prens'in muhaf�zlar� saray�n do�u kanad�n� tuttu. Soylular taht salonunda toplan�yor; kimse seni �a��rmad�. | `-` |
| `game/core/sim.gd:2160` | %s birlikleri ba�kentin giri�lerini tuttu. Saraya m�h�rl� bir mektup geldi: 'Majestelerinin istirahati i�in.' | `%s` |
| `game/core/sim.gd:2165` | Muhaf�z komutan� �a�r�lar�na cevap vermiyor. | `-` |
| `game/core/sim.gd:2165` | Muhaf�zlar�n bir k�sm� teredd�tte. | `-` |
| `game/core/sim.gd:2165` | Saray muhaf�zlar� sana ba�l� g�r�n�yor. | `-` |
| `game/core/sim.gd:2166` | Sokak �fkeli; meydanlar senin i�in dolmayabilir. | `-` |
| `game/core/sim.gd:2166` | Sokak tedirgin; kimse kimin kazanaca��n� bilmiyor. | `-` |
| `game/core/sim.gd:2168` | DARBE G�R���M� � bu hafta karar vermezsen saray d��er. | `-` |
| `game/core/sim.gd:2169` | Darbe kap�da | `-` |
| `game/core/sim.gd:2171` |  Bir kez boyun e�din; bu kez s�z�ne inanmayabilirler. | `-` |
| `game/core/sim.gd:2174` | Sad�k birlikleri topla, liderleri tutuklat | `-` |
| `game/core/sim.gd:2175` | %s istedi�ini ver | `%s` |
| `game/core/sim.gd:2176` | Balkona ��k, halka seslen | `-` |
| `game/core/sim.gd:2177` | Karar verilmedi. Kap�lar a��ld�. | `-` |
| `game/core/sim.gd:2196` | Darbenin lideri ortada yok; komplo da��ld�. | `-` |
| `game/core/sim.gd:2211` | tutukland� (darbe bast�r�ld�) | `-` |
| `game/core/sim.gd:2215` | Darbe giri�iminin gece yar�s� sert bi�imde bast�r�lmas� | `-` |
| `game/core/sim.gd:2216` | Sad�k birlikler gece yar�s� kararg�h� bast�. %s tutukland�. Komplocular sindi; ama bu gecenin izi kalacak. | `%s` |
| `game/core/sim.gd:2218` | Darbe gecesi sad�k birlikleri toplamaya �al��t�n; muhaf�zlar silahlar�n� indirdi. | `-` |
| `game/core/sim.gd:2219` | Muhaf�zlar silahlar�n� indirdi. %s kap�dan girdi�inde salonda senden ba�ka kimse yoktu. | `%s` |
| `game/core/sim.gd:2223` | Darbe gecesi bir kez daha taviz vermeyi denedin; bu kez kimse s�z�ne inanmad�. | `-` |
| `game/core/sim.gd:2224` | %s teklifini dinledi, sonra g�ld�: 'Bunu ge�en sefer de s�ylemi�tiniz, Majesteleri.' | `%s` |
| `game/core/sim.gd:2239` | taviz kopar�p geri �ekildi | `-` |
| `game/core/sim.gd:2240` | %s istedi�ini ald�. Tanklar k��laya d�nd�; ama art�k herkes bu �lkeyi ger�ekte kimin y�netti�ini biliyor. | `%s` |
| `game/core/sim.gd:2251` | halk saray�n �n�ne dolunca yaln�z kald� | `-` |
| `game/core/sim.gd:2252` | Meydan doldu. Kalabal�k ad�n� hayk�r�rken %s yan�ndakilerin birer birer telefonu kapatt���n� g�rd�. | `%s` |
| `game/core/sim.gd:2255` | Darbe gecesi halka seslendin; meydan bo� kald�. | `-` |
| `game/core/sim.gd:2256` | Balkona ��kt���nda meydan yar� bo�tu. Gelenler de senin i�in de�il, ne olaca��n� g�rmek i�in gelmi�ti. | `-` |
| `game/core/sim.gd:2284` | Kriz kap�na dayand���nda karar veremedin. | `-` |
| `game/core/sim.gd:2294` | SOKAK: Meydanlardaki kalabal�k her g�n b�y�yor; art�k da��lm�yorlar. | `-` |
| `game/core/sim.gd:2299` | MAHKEME: Savc�lar saraya dair dosyalar� tek bir soru�turmada topluyor. | `-` |
| `game/core/sim.gd:2332` | KR�Z: Meydanlar ayakta; sokak saray�n kap�s�nda. | `-` |
| `game/core/sim.gd:2333` | KR�Z: Mahkeme kral�n yetkilerini ask�ya almay� g�r���yor. | `-` |
| `game/core/sim.gd:2343` | Komutanlar halka ate� a�ma emrini tart���yor; kimse ilk ad�m� atmak istemiyor. | `-` |
| `game/core/sim.gd:2343` | Ordu emir bekliyor, ama emri kimin verece�ini merak ediyor. | `-` |
| `game/core/sim.gd:2343` | Birlikler haz�r; sana ba�l� g�r�n�yorlar. | `-` |
| `game/core/sim.gd:2344` | Kalabal�k art�k senin ad�n� de�il, sloganlar�n� hayk�r�yor. | `-` |
| `game/core/sim.gd:2344` | Kalabal�k �fkeli ama dinlemeye haz�r g�r�nenler var. | `-` |
| `game/core/sim.gd:2344` | Kalabal���n �o�u h�l� senden bir s�z bekliyor. | `-` |
| `game/core/sim.gd:2346` | AYAKLANMA � bu hafta karar vermezsen saray d��er. | `-` |
| `game/core/sim.gd:2348` | Ba�kentin b�t�n meydanlar� dolu. Barikatlar saray�n �� sokak �tesinde. Leyla'n�n gazetesi tek kelimelik bir man�et att�: 'Yeter.'\n%s %s%s | `%s, %s, %s` |
| `game/core/sim.gd:2349` |  Daha �nce taleplerini kabul etti�ini s�ylemi�tin; bu kez s�z�ne inanmayabilirler. | `-` |
| `game/core/sim.gd:2352` | Orduyu soka�a s�r | `-` |
| `game/core/sim.gd:2354` | Meydana in, halkla konu� | `-` |
| `game/core/sim.gd:2355` | Karar verilmedi. Barikatlar saray�n kap�s�na ula�t�. | `-` |
| `game/core/sim.gd:2361` | Ba�savc� Renn | `-` |
| `game/core/sim.gd:2361` | Ba�savc� | `-` |
| `game/core/sim.gd:2362` | Mahkemenin arkas�nda meclis ve sokak var; tasfiyeye kimse seyirci kalmaz. | `-` |
| `game/core/sim.gd:2362` | Mahkeme b�l�nm��; baz� yarg��lar senden bir i�aret bekliyor. | `-` |
| `game/core/sim.gd:2362` | Mahkeme yaln�z; arkas�nda duran pek kimse yok. | `-` |
| `game/core/sim.gd:2363` | Muhalefet meclisi elinde tutuyor; pazarl��a ihtiyac� yok. | `-` |
| `game/core/sim.gd:2363` | Mecliste karars�z s�ralar var. | `-` |
| `game/core/sim.gd:2363` | Meclis b�l�nm��; bir dokunulmazl�k yasas� ge�ebilir. | `-` |
| `game/core/sim.gd:2365` | YETK� KR�Z� � bu hafta karar vermezsen yetkilerin elinden al�n�r. | `-` |
| `game/core/sim.gd:2366` | Mahkeme yetkilerini ask�ya almay� g�r���yor | `-` |
| `game/core/sim.gd:2367` | %s biriken dosyalar� tek bir kararla birle�tirdi: kral�n yetkileri, soru�turma bitene kadar meclise devredilecek. Karar yar�n okunacak.\n%s %s%s | `%s, %s, %s, %s` |
| `game/core/sim.gd:2368` |  Daha �nce mahkemeyle uzla�t�n; bu kez yaln�zca s�z�nle yetinmeyebilirler. | `-` |
| `game/core/sim.gd:2372` | �fade ver, mahkemeyle uzla� | `-` |
| `game/core/sim.gd:2373` | Meclisle dokunulmazl�k pazarl��� yap | `-` |
| `game/core/sim.gd:2374` | Karar verilmedi. Mahkeme karar�n� okudu. | `-` |
| `game/core/sim.gd:2397` | Ayaklanma gecesi orduyu soka�a s�rd�n; askerler kalabal��a kat�ld�. | `-` |
| `game/core/sim.gd:2398` | Askerler barikata vard� ve durdu. Biri mi�ferini ��kard�; sonra hepsi. | `-` |
| `game/core/sim.gd:2404` | Ayaklanman�n ordu eliyle kanl� bast�r�lmas� | `-` |
| `game/core/sim.gd:2405` | Meydanlar sabaha temizlendi. Kimse say�y� s�ylemiyor; herkes biliyor. | `-` |
| `game/core/sim.gd:2408` | Ayaklanma gecesi yine s�z verdin; kimse inanmad�. | `-` |
| `game/core/sim.gd:2409` | Talepleri kabul etti�ini duyurdun. Meydandan gelen cevap bir kahkahayd�. | `-` |
| `game/core/sim.gd:2417` | Fiyatlar donduruldu, iki bakan istifa etti. Barikatlar s�k�ld�; muhalefet bu geceyi zafer say�yor. | `-` |
| `game/core/sim.gd:2420` | Ayaklanma gecesi meydana indin; kalabal�k seni dinlemedi. | `-` |
| `game/core/sim.gd:2421` | Meydana indi�inde sesin u�ultuda kayboldu. Muhaf�zlar�n seni geri �ekmesi gerekti. | `-` |
| `game/core/sim.gd:2426` | Meydanda konu�tun. Kalabal�k �nce sustu, sonra da��ld�. Bu gece kimse kazanmad�; kimse de kaybetmedi. | `-` |
| `game/core/sim.gd:2429` | Yetki krizinde mahkemeyi tasfiye etmeye kalkt�n; meclis ve sokak mahkemenin arkas�nda durdu. | `-` |
| `game/core/sim.gd:2430` | Tasfiye kararnamesini meclis bir saat i�inde iptal etti. Yarg��lar k�rs�de, sen saraydas�n; ama ne kadar? | `-` |
| `game/core/sim.gd:2438` | Y�ksek Mahkemenin tasfiye edilmesi | `-` |
| `game/core/sim.gd:2439` | Yeni yarg��lar yemin etti. Dosyalar rafa kalkt�; ama raf�n nerede oldu�unu herkes biliyor. | `-` |
| `game/core/sim.gd:2442` | Yetki krizinde mahkemeyle yeniden uzla�maya �al��t�n; bu kez s�z�ne itibar edilmedi. | `-` |
| `game/core/sim.gd:2443` | �fade verdin. Yarg��lar dinledi, not ald� ve karar� yine de okudu. | `-` |
| `game/core/sim.gd:2448` | Mahkemede saatlerce ifade verdin. Karar ertelendi; tac�n a��rl��� bir par�a hafifledi, bir par�a da azald�. | `-` |
| `game/core/sim.gd:2451` | Yetki krizinde meclisle dokunulmazl�k pazarl���na girdin; meclis pazarl��� reddetti. | `-` |
| `game/core/sim.gd:2452` | Dokunulmazl�k yasas� oylamada d��t�. Muhalefet s�ralar�nda alk�� vard�. | `-` |
| `game/core/sim.gd:2457` | Dokunulmazl�k yasas� birka� oy farkla ge�ti. Baz� vekiller bu hafta yeni arabalarla geldi. | `-` |
| `game/core/sim.gd:2464` | DARBE G�R���M� | `-` |
| `game/core/sim.gd:2469` | YETK� KR�Z� | `-` |
| `game/core/sim.gd:2535` | Saltanat�n�n %d. haftas�nda %s g�revden al�nd�. Darbenin lideri %s | `%d, %s, %s` |
| `game/core/sim.gd:2537` | , yaln�zca %d hafta �nce kendisi taraf�ndan terfi ettirilmi�ti. | `%d` |
| `game/core/sim.gd:2539` | . Onu hi� terfi ettirmemi�tin; g�c�n� sen ba�ka i�lerle u�ra��rken kendi ba��na toplad�. | `-` |
| `game/core/sim.gd:2543` | Saltanat�n�n %d. haftas�nda halk ayaklanmas� saray� ku�att�. | `%d` |
| `game/core/sim.gd:2547` | Saltanat�n�n %d. haftas�nda Meclis ve y�ksek mahkeme, biriken skandallar nedeniyle seni yetkisiz b�rakt�. | `%d` |
| `game/core/sim.gd:2551` | Saltanat�n�n %d. haftas�nda elit koalisyonu deste�ini �ekti; tahtta kimse seni savunmad�. | `%d` |
| `game/core/sim.gd:2553` | 104 haftal�k saltanat�n sonunda taht�n� korudun. | `-` |
| `game/core/sim.gd:2555` | Harap Devletin Kral� | `-` |
| `game/core/sim.gd:2555` | Liyakat Kral� | `-` |
| `game/core/sim.gd:2560` | %d s�z verdin: %d tutuldu, %d bozuldu. | `%d, %d, %d` |
| `game/core/sim.gd:2595` | O hafta kayda ge�en bir olay yok. | `-` |
| `game/core/sim.gd:2643` | Tutsa�� | `-` |
| `game/core/sim.gd:2712` | Harap Devletin Kral� | `-` |
| `game/core/sim.gd:2714` | Liyakat Kral� | `-` |
| `game/core/sim.gd:2717` | Generallerin Kuklas� | `-` |
| `game/core/sim.gd:2719` | Medya �mparatorunun Kuklas� | `-` |
| `game/core/sim.gd:2721` | G�lge Devletin Tutsa�� | `-` |
| `game/core/sim.gd:2722` | %s Kuklas� | `%s` |
| `game/core/sim.gd:2724` | Alt�n Kral | `-` |
| `game/core/sim.gd:2726` | Devleti T�keten | `-` |
| `game/core/sim.gd:2728` | Vaatler Kral� | `-` |
| `game/core/sim.gd:2730` | S�z�n�n Eri | `-` |
| `game/core/sim.gd:2732` | S�rlar�n Efendisi | `-` |
| `game/core/sim.gd:2734` | B�y�k Manip�lat�r | `-` |
| `game/core/sim.gd:2738` | Hanedan� Kurtaran | `-` |
| `game/core/sim.gd:2740` | Demir Ta� | `-` |
| `game/core/sim.gd:2741` | Saray�n Tilkisi | `-` |
| `game/core/sim.gd:2840` | So�uk | `-` |
| `game/core/sim.gd:2840` | Yak�n | `-` |
| `game/core/sim.gd:2879` | Krali�e Helena | `-` |
| `game/core/sim.gd:2879` | (k�t� haberi sana iletmedi) | `-` |
| `game/ui/agenda_view.gd:12` | Majesteleri, bu masada say�lar yoktur, insanlar vard�r. A�a��daki kartlar karar�n�z� bekliyor; her karar, emir ve operasyon s�n�rl� mesainizden harcar. Raporlar� da okuyun, ama hepsine inanmay�n. | `-` |
| `game/ui/agenda_view.gd:13` | Bir ki�iyi se�ip 'Do�rula' derseniz raporunu ba�ka kaynaklarla kar��la�t�r�r�m. Kimin sizi s�sledi�ini, kimin ger�e�i s�yledi�ini zamanla g�r�rs�n�z. | `-` |
| `game/ui/agenda_view.gd:14` | Kararlar� ertelemek de bir karard�r: iki hafta sonra kendi kendine, �o�u zaman en k�t� bi�imde ��z�l�r. | `-` |
| `game/ui/agenda_view.gd:15` | Terfi ve gizli �deme sadakat getirir. Ama terfi ettirdi�iniz ki�i g��lenir, para ise iz b�rak�r. �zler 'Dosyalar' sekmesinde birikir. | `-` |
| `game/ui/agenda_view.gd:16` | Birini ger�ekten kontrol etmek istiyorsan�z �nce 'Ara�t�r' ile zay�f noktas�n� ��renin. �antaj g��l�d�r, ama geri tepebilir. | `-` |
| `game/ui/agenda_view.gd:17` | Bir g�� merkezi fazla b�y�yorsa rakibini g��lendirin. Kimse sizi tek ba��na deviremeyecek kadar zay�f kalmal�. | `-` |
| `game/ui/agenda_view.gd:18` | B�rakt���n�z izler unutulmaz, sadece bekler. Dosyalar sekmesinde 'dedikodu' olanlar� bast�r�n ya da kan�t� yok edin; man�ete ��kan her s�r hem yarg�y� hem de size kar�� birle�mek isteyenleri cesaretlendirir. | `-` |
| `game/ui/agenda_view.gd:19` | �lk haftalar�n sessizli�i bitiyor. Art�k bir koalisyon sizi devirebilir. Raporlar birbirine benzemeye ba�larsa, kimsenin size ger�e�i s�ylemedi�ini bilin. | `-` |
| `game/ui/agenda_view.gd:24` | Karar�n� ver | `-` |
| `game/ui/agenda_view.gd:24` | A�a��daki karar kart�ndan bir se�enek se�. Meclisin g�r��� yol g�sterir; ama herkesin bir ��kar� var. | `-` |
| `game/ui/agenda_view.gd:25` | Raporlar� oku | `-` |
| `game/ui/agenda_view.gd:25` | Raporlar bu sayfan�n alt�nda, gazeteler Medya'da. Herkes yalan s�yleyebilir; �eli�kilere bak. | `-` |
| `game/ui/agenda_view.gd:26` | Bir ki�iye eylem | `-` |
| `game/ui/agenda_view.gd:26` | Bir portreye t�kla, Eylemler panelinde bir sekme ve eylem se�. Her eylem mesai harcar. | `-` |
| `game/ui/agenda_view.gd:27` | Haftay� bitir | `-` |
| `game/ui/agenda_view.gd:27` | Mesain bittiyse ya da yapacak �ey kalmad�ysa sa� alttaki d��meye bas; d�nya bir hafta ilerler. | `-` |
| `game/ui/agenda_view.gd:94` | Bir ki�iye eylem\n | `-` |
| `game/ui/agenda_view.gd:123` | Hen�z dosyada bir �ey yok. Gizli i�ler iz b�rak�r; izler burada birikir. | `-` |
| `game/ui/agenda_view.gd:153` | SANA DA�R | `-` |
| `game/ui/agenda_view.gd:154` | G�ZL� | `-` |
| `game/ui/agenda_view.gd:157` | KAMUYA A�IK | `-` |
| `game/ui/agenda_view.gd:160` | DED�KODU | `-` |
| `game/ui/agenda_view.gd:167` | %d ki�i biliyor  �  %d kopya | `%d, %d` |
| `game/ui/agenda_view.gd:185` | S�zd�r | `-` |
| `game/ui/agenda_view.gd:185` | Bast�r | `-` |
| `game/ui/agenda_view.gd:185` | Kan�t� Yok Et | `-` |
| `game/ui/agenda_view.gd:215` | Saray k�tibinin notu. �pu�lar� Ayarlar'dan kapat�labilir. | `-` |
| `game/ui/agenda_view.gd:243` | her karar 1 mesai � ertelenen karar 2 hafta sonra kendili�inden ��z�l�r | `-` |
| `game/ui/agenda_view.gd:299` | Bu hafta karar vermezsen saray d��er. | `-` |
| `game/ui/agenda_view.gd:299` | Karar bekliyor � bu hafta ��z�lmezse kendi kendine ��z�lecek. | `-` |
| `game/ui/agenda_view.gd:310` | Meclis susuyor. Bu karar� yaln�z vereceksin. | `-` |
| `game/ui/agenda_view.gd:319` | Bu se�enek i�in gerekli ki�i ya da servet yok. | `-` |
| `game/ui/agenda_view.gd:319` | Bu hafta mesain kalmad�. Haftay� bitir; karar bir hafta daha bekleyebilir. | `-` |
| `game/ui/agenda_view.gd:335` | masana ula�an: %d | `%d` |
| `game/ui/agenda_view.gd:379` | \nGe�en haftaya g�re daha karamsar konu�uyor. | `-` |
| `game/ui/agenda_view.gd:381` | \nGe�en haftaya g�re daha iyimser konu�uyor. | `-` |
| `game/ui/agenda_view.gd:409` | GE�EN HAFTADAN BER� | `-` |
| `game/ui/agenda_view.gd:409` | g�rebildiklerinde ne de�i�ti | `-` |
| `game/ui/agenda_view.gd:444` | yapt�klar�n ve sonu�lar� | `-` |
| `game/ui/agenda_view.gd:447` | Hen�z bir �ey yapmad�n. Bir g�� merkezine t�kla, Eylemler panelinden mesai harca. | `-` |
| `game/ui/agenda_view.gd:448` | Mesain bitti. Raporlara g�z at ve haftay� bitir. | `-` |
| `game/ui/agenda_view.gd:482` | masana ula�an: %d | `%d` |
| `game/ui/agenda_view.gd:495` | %s � %s\nT�kla: ki�iyi se�. Kenar rengi raporun s�yledi�idir, ger�ek olmayabilir.%s | `%s, %s, %s` |
| `game/ui/agenda_view.gd:530` | Veyra: �neriyor | `-` |
| `game/ui/agenda_view.gd:549` | MECL�S�N G�R��� | `-` |
| `game/ui/agenda_view.gd:554` | Dan��manlar�n kararlara dair g�r���. Gerek�eleri do�rudur ama se�icidir:\nherkes i�ine gelen taraf� anlat�r. Kime g�venece�in senin karar�n. | `-` |
| `game/ui/agenda_view.gd:564` | \nSe�eneklerden en az biri onu do�rudan etkiliyor. �nerisi tarafs�z olmayabilir. | `-` |
| `game/ui/agenda_view.gd:566` | \nSon zamanlarda hakk�nda alametler var. | `-` |
| `game/ui/agenda_view.gd:569` | \nKa�amak konu�uyor. Korkan bir meclis kral�na ger�e�i s�ylemez. | `-` |
| `game/ui/agenda_view.gd:571` | \nSe�enekler aras�nda belirgin bir fark g�rm�yor. | `-` |
| `game/ui/agenda_view.gd:592` | �IKARI VAR | `-` |
| `game/ui/agenda_view.gd:605` | %s: �neriyor | `%s` |
| `game/ui/agenda_view.gd:607` | %s: kar�� | `%s` |
| `game/ui/autoplay.gd:61` | Saltanat�n miras� | `-` |
| `game/ui/autoplay.gd:63` | FULLRUN tohum=%d hafta=%d sonu�=%s �nvan=%s miras_karar�=%s olay=%d son_ekran=%s | `%d, %d, %s, %s, %s, %d, %s` |
| `game/ui/autoplay.gd:64` | D��T� | `-` |
| `game/ui/autoplay.gd:128` | AUTOPLAY DONE: hafta=%d bas�lan=%d sonu�=%s | `%d, %d, %s` |
| `game/ui/cinema.gd:70` | Ge�  � | `-` |
| `game/ui/city_view.gd:10` | �al��ma odas� ve taht | `-` |
| `game/ui/city_view.gd:11` | ADL�YE | `-` |
| `game/ui/city_view.gd:11` | Soru�turmalar ve hukuk | `-` |
| `game/ui/city_view.gd:12` | MAL�YE BAKANLI�I | `-` |
| `game/ui/city_view.gd:15` | MEDYA MERKEZ� | `-` |
| `game/ui/city_view.gd:15` | Bas�n ve kamuoyu | `-` |
| `game/ui/city_view.gd:16` | �ST�HBARAT | `-` |
| `game/ui/city_view.gd:16` | Ar�ivler ve dosyalar | `-` |
| `game/ui/city_view.gd:17` | HALDEN HOLD�NG | `-` |
| `game/ui/city_view.gd:17` | Sermaye, ihaleler, bor�lar | `-` |
| `game/ui/city_view.gd:18` | ASTERIA EL��L��� | `-` |
| `game/ui/city_view.gd:19` | DRAKON EL��L��� | `-` |
| `game/ui/city_view.gd:19` | S�n�r ve g�venlik | `-` |
| `game/ui/city_view.gd:20` | SERAVIA TEMS�LC�L��� | `-` |
| `game/ui/city_view.gd:117` | BA�KENT | `-` |
| `game/ui/city_view.gd:125` | Bir kuruma t�kla | `-` |
| `game/ui/city_view.gd:133` | Masaya d�n  (Esc) | `-` |
| `game/ui/city_view.gd:133` | Masaya d�n | `-` |
| `game/ui/city_view.gd:271` | makam bo� | `-` |
| `game/ui/city_view.gd:272` | ��leyi�: [b]%s[/b]\nBa�kan: %s | `%s, %s` |
| `game/ui/city_view.gd:276` | N�fuz: [b]%s[/b]\nMedya: [b]%s[/b] | `%s, %s` |
| `game/ui/city_view.gd:278` | �li�ki: [b]%s[/b]\n[color=gray]Elena'n�n anlat�m� iyimser olabilir; Do�rula kay�tlar� alt� hafta a�ar.[/color] | `%s` |
| `game/ui/city_view.gd:295` | [color=#c0504a]Bu makam bo�. Sahibi art�k sarayda de�il.[/color] | `-` |
| `game/ui/city_view.gd:301` | Ki�iyle ilgilen | `-` |
| `game/ui/city_view.gd:305` | Dosyalar� a� | `-` |
| `game/ui/city_view.gd:307` | Do�rula | `-` |
| `game/ui/city_view.gd:327` | Saraya uzanan dosyalar: [b]%d[/b] (kamuya a��k: %d).\nHer dosya, yarg�n�n sana yakla�an bir ad�m�d�r. | `%d, %d` |
| `game/ui/city_view.gd:329` | Veyra b�t�e defterlerini tutuyor. Saray harcamalar�yla devlet kasas�n� kar��t�rma. | `-` |
| `game/ui/city_view.gd:335` | Meclis kulislerinde verilmi� ve hen�z tutulmam�� s�zlerin: [b]%d[/b].\nMuhalefet her s�z� sayar. | `%d` |
| `game/ui/city_view.gd:337` | Ordunun kime sad�k oldu�u, ne kadar g��l� oldu�undan daha �nemlidir. | `-` |
| `game/ui/city_view.gd:339` | Ara�t�rma yapt�r�rsan zay�f noktalar� bulur. Ama ��rendi�i her �eyi saklar. | `-` |
| `game/ui/city_view.gd:341` | Sarne'nin kanallar� ve Leyla'n�n gazetesi ayn� haftay� farkl� anlat�r. Kar��la�t�r. | `-` |
| `game/ui/city_view.gd:344` | Sarne sana yapt�klar�n�n kar��l���n� bekliyor. Bor� defterin onun masas�nda. | `-` |
| `game/ui/city_view.gd:345` | Sarne Holding enerji, in�aat ve medyada faaliyet g�steriyor. | `-` |
| `game/ui/desk_view.gd:20` | Ba�kent � Kurumlar | `-` |
| `game/ui/desk_view.gd:22` | Ki�iler | `-` |
| `game/ui/desk_view.gd:23` | Saltanat G�nl��� | `-` |
| `game/ui/desk_view.gd:24` | G�ndem | `-` |
| `game/ui/desk_view.gd:132` | HAFTA %d   �   KRAL ADR�AN IV | `%d` |
| `game/ui/desk_view.gd:158` | %d KARAR BEKL�YOR   �   G�NDEM� A�   � | `%d` |
| `game/ui/desk_view.gd:158` | G�NDEM� A�   � | `-` |
| `game/ui/desk_view.gd:374` | YEN� | `-` |
| `game/ui/desk_view.gd:377` | %d s�z | `%d` |
| `game/ui/desk_view.gd:405` | Bu haftan�n gazeteleri | `-` |
| `game/ui/desk_view.gd:417` |  � %d d��man | `%d` |
| `game/ui/desk_view.gd:419` |  � %d ��pheli | `%d` |
| `game/ui/desk_view.gd:424` | %d s�z�n vadesi yakla��yor | `%d` |
| `game/ui/desk_view.gd:425` | Hafta %d � saltanat�n kayd� | `%d` |
| `game/ui/desk_view.gd:428` | Dosya �imdilik bo� | `-` |
| `game/ui/desk_view.gd:438` | %d kay�t | `%d` |
| `game/ui/desk_view.gd:449` | %d saltanat � %d / %d ba�ar�m | `%d, %d, %d` |
| `game/ui/desk_view.gd:496` | VELOR�A HABER | `-` |
| `game/ui/desk_view.gd:564` | G�ZL� | `-` |
| `game/ui/desk_view.gd:612` | BA�KENT | `-` |
| `game/ui/end_screen.gd:64` | �zet | `-` |
| `game/ui/end_screen.gd:77` | Bu �izgileri oyun boyunca hi� g�rmedin. G�rd���n yaln�zca raporlard�; aradaki fark, sana s�ylenmeyenlerdir. | `-` |
| `game/ui/end_screen.gd:82` | Tarih�iler | `-` |
| `game/ui/end_screen.gd:83` | Hakikat Dosyas� | `-` |
| `game/ui/end_screen.gd:95` | YEN�DEN OYNA | `-` |
| `game/ui/end_screen.gd:103` | Ana Men� | `-` |
| `game/ui/end_screen.gd:130` | \n[b][color=#d9b359][font_size=22]KOMPLO DEFTER� � perde arkas�nda ne oldu[/font_size][/color][/b]\n | `-` |
| `game/ui/end_screen.gd:134` | [color=gray]Son g�rd���n alametlerin %d'i ger�ekti, %d'i dedikoduydu.[/color]\n\n | `%d, %d` |
| `game/ui/end_screen.gd:136` | Sarayda kimse sana kar�� �rg�tlenmedi.\n | `-` |
| `game/ui/end_screen.gd:140` | haz�rl���na | `-` |
| `game/ui/end_screen.gd:140` | darbe giri�imini | `-` |
| `game/ui/end_screen.gd:140` | �ekildi | `-` |
| `game/ui/end_screen.gd:140` | tutukland� | `-` |
| `game/ui/end_screen.gd:146` | \n[b][color=#d9b359][font_size=22]MECL�S S�C�L� � kim seni nereye y�nlendirdi[/font_size][/color][/b]\n | `-` |
| `game/ui/end_screen.gd:147` | [color=gray]�neri � dinledi�in � seni yan�ltt��� (�nerisi en iyi se�enekten belirgin bi�imde k�t�yd�)[/color]\n\n | `-` |
| `game/ui/end_screen.gd:149` | Meclis bu saltanatta hi� �neride bulunmad�.\n | `-` |
| `game/ui/end_screen.gd:154` | [b]%s[/b]   %d �neri � %d kez dinledin � [color=%s]%s[/color]\n | `%s, %d, %d, %s, %s` |
| `game/ui/end_screen.gd:155` | %d kez yan�ltt� | `%d` |
| `game/ui/end_screen.gd:155` | hi� yan�ltmad� | `-` |
| `game/ui/end_screen.gd:158` |    [color=gray]En pahal�s�, hafta %d � %s:[/color] \"%s\" dedi; en iyisi \"%s\" idi.%s\n | `%d, %s, %s, %s, %s` |
| `game/ui/end_screen.gd:165` | ��km�� | `-` |
| `game/ui/end_screen.gd:168` | sa�lam | `-` |
| `game/ui/end_screen.gd:174` | \n[b][color=#d9b359][font_size=22]DEVLET DEFTER� � ne pahas�na[/font_size][/color][/b]\n | `-` |
| `game/ui/end_screen.gd:175` | [color=gray]Kurumlar�n ortalama h�li:[/color] %s. En zay�f an: %d. hafta, %s.\n | `%s, %d, %s` |
| `game/ui/end_screen.gd:177` | [color=gray]O haftan�n kayd�:[/color] %s\n | `%s` |
| `game/ui/end_screen.gd:179` | �dare | `-` |
| `game/ui/end_screen.gd:181` | Kadroda yeni bir atama yapmad�n.\n | `-` |
| `game/ui/end_screen.gd:185` | Sad�k Ata | `-` |
| `game/ui/end_screen.gd:186` | [color=gray]�hale:[/color] %d kez. [color=gray]Sarne'nin d��man yay�n�:[/color] %d hafta.\n | `%d, %d` |
| `game/ui/end_screen.gd:188` | [color=gray]D�� ili�kiler:[/color] %d heyet; en so�uk an %d. hafta. [color=gray]Veliaht:[/color] %s.\n | `%d, %d, %s` |
| `game/ui/end_screen.gd:189` | Haz�r | `-` |
| `game/ui/end_screen.gd:189` | Geli�iyor | `-` |
| `game/ui/end_screen.gd:189` | �ocuksu | `-` |
| `game/ui/end_screen.gd:204` | Taht�n� korudun. | `-` |
| `game/ui/end_screen.gd:204` | Taht�n� kaybettin. | `-` |
| `game/ui/end_screen.gd:206` | [b][font_size=%d]Kral %s[/font_size][/b]   [font_size=%d][color=%s]%s[/color][/font_size]\n[font_size=%d][color=gray]�nvan�n:[/color] [color=#d9b359]%s[/color][/font_size] | `%d, %s, %d, %s, %s, %d, %s` |
| `game/ui/end_screen.gd:213` | [b]Saltanat:[/b] %d hafta  �  [b]En g��l� isim:[/b] %s\n[b]S�z sicili:[/b] %s\n[b]Karar defteri:[/b] %d kay�t\n | `%d, %s, %s, %d` |
| `game/ui/end_screen.gd:216` | [b]Rejimin:[/b] %s. [b]Son s�nav�:[/b] %s.\n | `%s, %s` |
| `game/ui/end_screen.gd:219` | [b]Devletin:[/b] %s. Bedeli Hakikat Dosyas�'ndaki Devlet Defteri'nde.\n | `%s` |
| `game/ui/end_screen.gd:221` | [b]Hakikat Dosyas�:[/b] kimse sana belirgin bi�imde yalan s�ylemedi.\n | `-` |
| `game/ui/end_screen.gd:226` | [b]Hakikat Dosyas�:[/b] [color=#c0504a]%d ki�i sana yalan s�yledi.[/color] Kim olduklar�n� Hakikat Dosyas� sekmesinde g�r.\n | `%d` |
| `game/ui/end_screen.gd:229` | [b]Meclis:[/b] seni en �ok [color=#d08a3d]%s[/color] yan�ltt� (%d kez). Ayr�nt�s� Hakikat Dosyas�'nda.\n | `%s, %d` |
| `game/ui/end_screen.gd:232` | komploya kat�ld� | `-` |
| `game/ui/end_screen.gd:233` | [b]Komplo:[/b] ilk k�v�lc�m %d. haftada, [color=#c0504a]%s[/color]. Kronolojisi Hakikat Dosyas�'nda.\n | `%d, %s` |
| `game/ui/end_screen.gd:237` | \n[b][color=#d9b359][font_size=22]YEN� BA�ARIM[/font_size][/color][/b]\n | `-` |
| `game/ui/end_screen.gd:242` | \n[b][color=#d9b359][font_size=22]Son kararlar�n[/font_size][/color][/b]   [color=gray]tamam� Kararlar sekmesinde[/color]\n | `-` |
| `game/ui/end_screen.gd:247` | [b][color=#d9b359][font_size=22]TAR�H NE YAZACAK?[/font_size][/color][/b]\n[color=gray]Ayn� saltanat, iki ayr� kalemden.[/color]\n\n | `-` |
| `game/ui/end_screen.gd:250` | [color=#d6b25e][b]Saray tarih�isi[/b][/color]\n[i]\"%s\"[/i]\n\n | `%s` |
| `game/ui/end_screen.gd:251` | [color=#c0504a][b]S�rg�ndeki tarih�i[/b][/color]\n[i]\"%s\"[/i]\n | `%s` |
| `game/ui/end_screen.gd:253` | Tarih�iler bu saltanat hakk�nda sessiz kald�. | `-` |
| `game/ui/end_screen.gd:256` | [b][color=#d9b359][font_size=22]HAK�KAT DOSYASI � sana s�ylenmeyenler[/font_size][/color][/b]\n\n | `-` |
| `game/ui/end_screen.gd:258` | Kimse sana belirgin bi�imde yalan s�ylemedi. Ya da hepsini fark ettin.\n | `-` |
| `game/ui/end_screen.gd:260` | � Hafta %d � [b]%s[/b] sana �unu s�yledi: \"%s\"\n   [color=gray]Ger�ekte:[/color] %s\n\n | `%d, %s, %s, %s` |
| `game/ui/end_screen.gd:266` | [b][color=#d9b359][font_size=22]KARARLARIN[/font_size][/color][/b]   [color=gray]%d kay�t � en yenisi �stte[/color]\n\n | `%d` |
| `game/ui/end_screen.gd:268` | Hi� karar vermedin. Tarih bunu da yazar. | `-` |
| `game/ui/end_screen.gd:271` | Hakikat Dosyas� (%d) | `%d` |
| `game/ui/end_screen.gd:271` | Hakikat Dosyas� | `-` |
| `game/ui/main.gd:102` | [b]��erik y�klenemedi[/b]\n\n%s | `%s` |
| `game/ui/main.gd:288` | G�ndem | `-` |
| `game/ui/main.gd:300` | �ubuk: s�rr�n ne kadar yay�ld��� � yar�s�nda man�ete ��kar | `-` |
| `game/ui/main.gd:309` | S�Z DEFTER� | `-` |
| `game/ui/main.gd:318` | G�nl�k | `-` |
| `game/ui/main.gd:346` | HAFTAYI B�T�R   � | `-` |
| `game/ui/main.gd:412` | KRAL ADR�AN IV | `-` |
| `game/ui/main.gd:433` | Mesai: bu hafta kalan eylem hakk�n. | `-` |
| `game/ui/main.gd:447` | Ki�isel servet: devlet b�t�esinden ayr�, gizli i�lerin i�in. | `-` |
| `game/ui/main.gd:454` | �al��ma masas�: g�ndem, gazete, ki�iler, g�nl�k, dosyalar, hanedan ve ba�kent haritas�. | `-` |
| `game/ui/main.gd:458` | Medya Merkezi: Sarne'nin gazetesi, Leyla'n�n ba��ms�z gazetesi ve Sarne TV. �kisini kar��la�t�r; biri yalan s�yl�yor olabilir. | `-` |
| `game/ui/main.gd:460` | Men� | `-` |
| `game/ui/main.gd:614` | [b][font_size=%d][color=#d6b25e]H�K�MDARLIK AR��V�[/color][/font_size][/b]\n[color=gray]Tarih, krallar�n� unutmaz.[/color]\n\n | `%d` |
| `game/ui/main.gd:616` | Hen�z tamamlanm�� bir saltanat yok. �lk h�k�mdarl���n burada an�lacak. | `-` |
| `game/ui/main.gd:623` | Saltanat say�s�: %d   �   Tahtta kalan: %d   �   En uzun saltanat: %d hafta\n\n | `%d, %d, %d` |
| `game/ui/main.gd:626` | [color=#c0504a]D��T�[/color] | `-` |
| `game/ui/main.gd:629` | \n[b][font_size=%d][color=#d6b25e]BA�ARIMLAR  �  %d / %d[/color][/font_size][/b]\n | `%d, %d, %d` |
| `game/ui/main.gd:807` | Oyuna D�n | `-` |
| `game/ui/main.gd:812` | Oyuna D�n | `-` |
| `game/ui/main.gd:845` | [b][font_size=%d][color=#d6b25e]Yeni saltanat[/color][/font_size][/b]\n\nS�ren ya da kay�tl� bir saltanat var. Yeni bir oyuna ba�larsan otomatik kay�t da �zerine yaz�lacak.\n\nDevam etmek istiyor musun? | `%d` |
| `game/ui/main.gd:846` | Yeni oyuna ba�la | `-` |
| `game/ui/main.gd:854` | [b]��erik y�klenemedi[/b]\n\n%s | `%s` |
| `game/ui/main.gd:860` | Ta� sana emanet edildi. G�� merkezleri seni test edecek. | `-` |
| `game/ui/main.gd:869` | Veloria Krall���. | `-` |
| `game/ui/main.gd:869` | Modern kurumlar. Eski bir ta�. | `-` |
| `game/ui/main.gd:870` | Baban�n cenazesinin ���nc� g�n�. | `-` |
| `game/ui/main.gd:870` | Ta� art�k senin ba��nda: Kral Adrian IV. | `-` |
| `game/ui/main.gd:872` | Casuslar senin i�in dinliyor. | `-` |
| `game/ui/main.gd:873` | Patronlar sana ekranlar�n� a��yor. | `-` |
| `game/ui/main.gd:874` | Ve kendi kan�ndan olanlar, s�ras�n� bekliyor. | `-` |
| `game/ui/main.gd:875` | Hepsi sana sad�k oldu�unu s�yl�yor. | `-` |
| `game/ui/main.gd:875` | Baz�lar� yalan s�yl�yor. | `-` |
| `game/ui/main.gd:882` | Kay�tl� oyun y�klendi (hafta %d). | `%d` |
| `game/ui/main.gd:884` | [b]Kay�t y�klenemedi[/b]\n\n%s\n\nYeni bir saltanat ba�latabilirsin. | `%s` |
| `game/ui/main.gd:938` | [color=#d6b25e][b]Ki�iler[/b][/color]\nSa�daki portrelerden birini se�; eylemler ve s�zler altta. | `-` |
| `game/ui/main.gd:1000` | Hafta %d sessiz ge�ti. | `%d` |
| `game/ui/main.gd:1099` | �nce bir ki�i se�. | `-` |
| `game/ui/main.gd:1156` | Medya  �  yeni say� | `-` |
| `game/ui/main.gd:1169` | [color=gray]Hen�z kimseye s�z vermedin. Saray sekmesinde/sa�da bir ki�i se�ip 'S�z Ver' kullanabilirsin.[/color] | `-` |
| `game/ui/main.gd:1181` | [color=gray]ge�ersiz[/color] | `-` |
| `game/ui/main.gd:1182` |   [color=#c0504a]� �eli�ki duyuldu[/color] | `-` |
| `game/ui/main.gd:1207` |   �  %d tanesi bu hafta d��er | `%d` |
| `game/ui/main.gd:1210` | Medya okunmad� | `-` |
| `game/ui/main.gd:1216` | %d s�z�n vadesi geldi | `%d` |
| `game/ui/main.gd:1216` | S�z vadesi | `-` |
| `game/ui/main.gd:1222` | S�rr�n yay�l�yor | `-` |
| `game/ui/main.gd:1222` | %d s�rr�n yay�l�yor | `%d` |
| `game/ui/main.gd:1224` | Haz�rs�n: haftay� bitir | `-` |
| `game/ui/main.gd:1224` | Haz�r | `-` |
| `game/ui/main.gd:1268` | G�ndeme git | `-` |
| `game/ui/main.gd:1268` | Medya Merkezi'ni a� | `-` |
| `game/ui/main.gd:1290` | KR�Z | `-` |
| `game/ui/main.gd:1290` | MAL�YE | `-` |
| `game/ui/main.gd:1290` | ADL�YE | `-` |
| `game/ui/main.gd:1290` | �DARE | `-` |
| `game/ui/main.gd:1290` | MAN�ET | `-` |
| `game/ui/main.gd:1290` | ERTELEND� | `-` |
| `game/ui/main.gd:1290` | KUL�S | `-` |
| `game/ui/main.gd:1290` | S�Z | `-` |
| `game/ui/main.gd:1310` | MAN�ET | `-` |
| `game/ui/main.gd:1329` | TAHTINI KAYBETT�N | `-` |
| `game/ui/main.gd:1330` | �nvan�n: %s | `%s` |
| `game/ui/media_view.gd:66` | MEDYA MERKEZ� | `-` |
| `game/ui/media_view.gd:87` | Masaya d�n  (Esc) | `-` |
| `game/ui/media_view.gd:284` | Foto�raf: %s | `%s` |
| `game/ui/media_view.gd:284` | muhabirimiz, ba�kent | `-` |
| `game/ui/media_view.gd:284` | Veloria Haber ar�ivi | `-` |
| `game/ui/media_view.gd:291` | [b]BA�KENT �[/b] %s | `%s` |
| `game/ui/media_view.gd:293` | Devam� sayfa %d'%s | `%d, %s` |
| `game/ui/media_view.gd:342` | BA�IMSIZ\nHAFTALIK | `-` |
| `game/ui/media_view.gd:350` | Say� %d | `%d` |
| `game/ui/media_view.gd:366` | F�YATI | `-` |
| `game/ui/media_view.gd:366` | 1 kuru� | `-` |
| `game/ui/media_view.gd:366` | 2 kuru� | `-` |
| `game/ui/media_view.gd:371` | BA�KENT | `-` |
| `game/ui/media_view.gd:552` | G�NDEM | `-` |
| `game/ui/menu.gd:42` | [b][font_size=26][color=#d6b25e]Nas�l oynan�r[/color][/font_size][/b]\n\n� 104 hafta tahtta kal. Haftada [b]4 mesain[/b] var; kararlar, emirler ve operasyonlar mesai harcar.\n� Say�lar� g�remezsin; yaln�zca [b]raporlar[/b] vard�r ve herkes yalan s�yleyebilir. Korktuk�a insanlar sana ger�e�i s�ylemez; hepsi ayn� c�mleyi kurmaya ba�lar.\n� Verdi�in g�� sana d�nebilir. Terfi, bor� ve gizli �demeler iz b�rak�r.\n� S�z vermek kolayd�r; vadesi gelince ya tutars�n ya da bedelini �dersin. Ayn� makam� iki ki�iye vaat etmek er ge� duyulur.\n� Herkesin bildi�i bir s�r, gizli bir s�rdan �ok daha tehlikelidir.\n� Her kararda [b]meclisten iki ki�i[/b] g�r�� bildirir. Gerek�eleri do�rudur ama se�icidir; [color=#d08a3d]�IKARI VAR[/color] olan�n �nerisi tarafs�z olmayabilir.\n� Darbe bir sabah gelmez: �nce [b]alametler[/b] g�r�n�r, ki�i kart�nda [color=#d08a3d]��PHEL�[/color] yazar. Bir k�sm� dedikodudur; [b]Huzura �a��r[/b] ile yoklayabilirsin. Darbe kap�na dayand���nda son karar� sen verirsin.\n� Erteledi�in kararlar iki hafta sonra kendi kendine ��z�l�r.\n� Oyun bitti�inde [b]Hakikat Dosyas�[/b] sana kimin ne zaman yalan s�yledi�ini g�sterir. | `-` |
| `game/ui/menu.gd:113` | V E L O R � A | `-` |
| `game/ui/menu.gd:126` | Tahtta kalmak, �lkeyi y�netmekten daha zordur. | `-` |
| `game/ui/menu.gd:148` | ��k�� | `-` |
| `game/ui/menu.gd:158` | Nas�l Oynan�r | `-` |
| `game/ui/menu.gd:158` | H�k�mdarl�k Ar�ivi | `-` |
| `game/ui/menu.gd:158` | Hakk�nda | `-` |
| `game/ui/menu.gd:169` | YEN� SALTANAT | `-` |
| `game/ui/menu.gd:172` | 5 mesai, daha uzun koruma s�resi ve bol gelir. �lk saltanat i�in. | `-` |
| `game/ui/menu.gd:173` | 4 mesai. Dengeli: hatalar�n� affeder ama unutmaz. | `-` |
| `game/ui/menu.gd:174` | 4 mesai, k�sa koruma, az gelir. Darbeler daha erken ve kolay gelir. | `-` |
| `game/ui/menu.gd:197` | Tahta ��k | `-` |
| `game/ui/menu.gd:211` | K�sa ge�i�ler | `-` |
| `game/ui/menu.gd:212` | Dan��man ipu�lar� | `-` |
| `game/ui/menu.gd:213` | A��l�� sinemas� | `-` |
| `game/ui/menu.gd:214` | Haftaya masadan ba�la | `-` |
| `game/ui/menu.gd:232` | M�zik | `-` |
| `game/ui/menu.gd:252` | v%s   �   Esc: men�   Bo�luk: haftay� bitir   Ctrl+S: kaydet   F11: tam ekran | `%s` |
| `game/ui/modal.gd:77` | Vazge� | `-` |
| `game/ui/person_panel.gd:7` | �stihbarat | `-` |
| `game/ui/person_panel.gd:7` | Bas�n | `-` |
| `game/ui/person_panel.gd:8` | D��i�leri | `-` |
| `game/ui/person_panel.gd:8` | Yarg� | `-` |
| `game/ui/person_panel.gd:11` | Huzura �a��r (1 mesai)\n�z b�rakmaz, para istemez. Ki�iyi biraz yat��t�r�r. Komplo kuran �o�u zaman ka�amak konu�ur; temiz ��kan birinin hakk�ndaki dedikodular da��l�r. Ayn� ki�i 4 haftada bir �a�r�labilir. | `-` |
| `game/ui/person_panel.gd:12` | Terfi Ettir (1 mesai)\nG�� ve minnet verir; ama onun g�c�, h�rs� ve sana olan borcun da b�y�r. | `-` |
| `game/ui/person_panel.gd:13` | Gizli �deme (1 mesai, 5 servet)\nSadakat sat�n al�r, zamanla a��n�r. Bir iz b�rak�r; iz dosyalara d��er. | `-` |
| `game/ui/person_panel.gd:14` | Raporu Do�rula (1 mesai)\nBir kayna��n raporunu ba�ka kaynaklarla k�yaslar. Sonu� g�r�lt�l�d�r; kaynak karnesine i�lenir. | `-` |
| `game/ui/person_panel.gd:15` | G�revden Al (1 mesai)\nS�rlar�n� �ok bilen ya da �ok g��l� biri kar�� sald�r�ya ge�er. Sessizce gidenler az olur. | `-` |
| `game/ui/person_panel.gd:16` | Yaz�l� Emir: Bast�r (1 mesai)\nKesin uygulan�r ama kan�t b�rak�r. | `-` |
| `game/ui/person_panel.gd:17` | S�zl� Emir: Bast�r (1 mesai)\nYar� kesin uygulan�r, iz b�rakmaz. | `-` |
| `game/ui/person_panel.gd:18` | �ma: 'Halledilsin' (1 mesai)\n�nk�r edilebilir; ama h�rsl� biri a��r� yorumlar, korkak biri hi� uygulamaz. | `-` |
| `game/ui/person_panel.gd:19` | Soru�turma (1 mesai)\n�stihbarat gibi g��l� birine verilirse sorunlu isimleri ipucu olarak getirebilir. | `-` |
| `game/ui/person_panel.gd:20` | Ara�t�r (1 mesai)\nSe�ilen ki�inin �nce zay�f noktas�n�, sonra k�rm�z� �izgisini ��renmeye �al���r. �stihbarat g��l�yse �ans artar. | `-` |
| `game/ui/person_panel.gd:21` | �antaj (1 mesai)\nZay�f noktas� bilinen birini korkuyla ba�lar, borcunu siler. Ama iz b�rak�r, h�rs�n� b�y�t�r; d�r�st biri if�a edebilir. | `-` |
| `game/ui/person_panel.gd:22` | S�z: Naiplik (1 mesai)\nHemen sadakat getirir. Tutarsan �ok g��lenir; senin g�c�nden de pay al�r. Yaln�zca bir ki�iye verilebilir. | `-` |
| `game/ui/person_panel.gd:23` | S�z: Liman �halesi (1 mesai)\nHemen sadakat getirir. Tutarsan zenginle�ir, sana da komisyon d��er. Yaln�zca bir ki�iye verilebilir. | `-` |
| `game/ui/person_panel.gd:24` | S�z: Dokunulmazl�k (1 mesai)\nHemen sadakat getirir. Tutarsan korkusu azal�r. Ayn� s�z� iki ki�iye vermek er ge� duyulur. | `-` |
| `game/ui/person_panel.gd:25` | Dikkat Da��t (2 mesai)\nSahte bir kriz yarat�p huzursuzlu�u azalt�r. �ember b�y�d�k�e ba�ar� da, s�z�nt� riski de artar. | `-` |
| `game/ui/person_panel.gd:26` | Muhalefeti B�l (2 mesai)\nMuhalefet kanatlar�n� birbirine d���r�r. | `-` |
| `game/ui/person_panel.gd:27` | Rakibi Zay�flat (2 mesai)\nEn g��l� ki�inin itibar�n� k�rar. Kim yapt���n� tahmin eder. | `-` |
| `game/ui/person_panel.gd:28` | Birbirine D���r (2 mesai)\n�oklu se�imle tam iki ki�i se�. Ba�ar�rsan ikisi de birbiriyle u�ra��rken g�� ve h�rs kaybeder; ba�ar�s�z olursan kimin yapt���n� anlarlar ve bir s�r do�ar. Ayn� �ift i�in 6 hafta bekle. | `-` |
| `game/ui/person_panel.gd:29` | S�zd�r (1 mesai)\nBir dosyay� bas�na verir; ortak bilgi artar. Herkesin bildi�i �ey en tehlikelisidir. | `-` |
| `game/ui/person_panel.gd:30` | Bast�r (1 mesai)\nDedikoduyu d���r�r ama kan�t�n kopyalar� durur. | `-` |
| `game/ui/person_panel.gd:31` | Kan�t� Yok Et (1 mesai)\nKopyalar bitince ger�ekten silinir; giri�im fark edilebilir. | `-` |
| `game/ui/person_panel.gd:32` | Sad�k Ata (1 mesai)\nBir kurum ba�kan� i�in sad�k kadro kararnamesi ��kar. Sonucunu zamanla raporlardan ��renirsin. | `-` |
| `game/ui/person_panel.gd:33` | Liyakatli Ata (1 mesai)\nBir kurum ba�kan� i�in liyakatli kadro kararnamesi ��kar. Sonucunu zamanla raporlardan ��renirsin. | `-` |
| `game/ui/person_panel.gd:34` | �hale Ver (1 mesai)\nSarne'nin �irketlerine yeni bir devlet i�i ver. S�zle�menin sonu�lar� zamanla ortaya ��kar. | `-` |
| `game/ui/person_panel.gd:35` | Veliahd� Yeti�tir (1 mesai)\nJulian i�in e�itim ve halkla bulu�ma program� haz�rla. S�rekli �ne ��karmak saraydaki ba�ka isimleri rahats�z edebilir. | `-` |
| `game/ui/person_panel.gd:36` | Heyet G�nder (1 mesai)\nSe�ili el�iyi ba�kente davet et. Yak�nl�k di�er iki el�ili�i tedirgin eder. | `-` |
| `game/ui/person_panel.gd:41` | Kazan\nSadakat kazanman�n yollar�: Huzura �a��r iz b�rakmaz, terfi g�� verir, gizli �deme iz b�rak�r. | `-` |
| `game/ui/person_panel.gd:42` | S�Z VER | `-` |
| `game/ui/person_panel.gd:42` | S�z Ver\nHemen sadakat getirir; vadesi gelince ya tutars�n ya bedelini �dersin. Her �d�l yaln�zca bir ki�iye verilebilir. | `-` |
| `game/ui/person_panel.gd:43` | ��REN | `-` |
| `game/ui/person_panel.gd:43` | ��ren\nRaporlar� do�rula, zay�f noktay� ve k�rm�z� �izgiyi ara�t�r, soru�turma a�. | `-` |
| `game/ui/person_panel.gd:44` | Emret\nHuzursuzlu�u bast�rma emri. Kanal se�imi sonucu ve ink�r edilebilirli�i belirler. | `-` |
| `game/ui/person_panel.gd:45` | Bask�\n�antaj ve g�revden alma. G��l� ara�lar, ama geri tepebilirler. | `-` |
| `game/ui/person_panel.gd:46` | Operasyon (2 mesai)\n1�3 ki�iyle gizli i�. �emberi kurmak i�in �oklu se�im'i a� ya da Ctrl ile ki�i ekle. | `-` |
| `game/ui/person_panel.gd:47` | Devlet\nKadro kararnameleri, ihale, veliaht e�itimi ve el�ilik heyetleri. | `-` |
| `game/ui/person_panel.gd:50` | [color=#8f7a45]Bir eylemin �zerine gel ya da dokun: ne yapt���n� ve bedelini burada g�r�rs�n.[/color] | `-` |
| `game/ui/person_panel.gd:73` | G�� MERKEZLER� | `-` |
| `game/ui/person_panel.gd:78` | �oklu se�im | `-` |
| `game/ui/person_panel.gd:81` | A��kken kartlara dokunmak se�ime ekler/��kar�r (Ctrl ile ayn�). Operasyon �emberi i�in. | `-` |
| `game/ui/person_panel.gd:84` | �oklu se�im %s. Operasyon i�in 1�3 ki�i se�. | `%s` |
| `game/ui/person_panel.gd:84` | a��k | `-` |
| `game/ui/person_panel.gd:84` | kapal� | `-` |
| `game/ui/person_panel.gd:133` | Huzura �a��r | `-` |
| `game/ui/person_panel.gd:133` | Gizli �deme | `-` |
| `game/ui/person_panel.gd:134` | S�Z VER | `-` |
| `game/ui/person_panel.gd:134` | Liman �halesi | `-` |
| `game/ui/person_panel.gd:134` | Dokunulmazl�k | `-` |
| `game/ui/person_panel.gd:135` | ��REN | `-` |
| `game/ui/person_panel.gd:135` | Do�rula | `-` |
| `game/ui/person_panel.gd:135` | Ara�t�r | `-` |
| `game/ui/person_panel.gd:135` | Soru�turma | `-` |
| `game/ui/person_panel.gd:136` | Yaz�l� Emir | `-` |
| `game/ui/person_panel.gd:136` | S�zl� Emir | `-` |
| `game/ui/person_panel.gd:136` | �ma | `-` |
| `game/ui/person_panel.gd:137` | �antaj | `-` |
| `game/ui/person_panel.gd:137` | G�revden Al | `-` |
| `game/ui/person_panel.gd:138` | Dikkat Da��t | `-` |
| `game/ui/person_panel.gd:138` | Muhalefeti B�l | `-` |
| `game/ui/person_panel.gd:138` | Rakibi Zay�flat | `-` |
| `game/ui/person_panel.gd:138` | Birbirine D���r | `-` |
| `game/ui/person_panel.gd:139` | Sad�k Ata | `-` |
| `game/ui/person_panel.gd:139` | �hale Ver | `-` |
| `game/ui/person_panel.gd:139` | Veliahd� Yeti�tir | `-` |
| `game/ui/person_panel.gd:139` | Heyet G�nder | `-` |
| `game/ui/person_panel.gd:262` | Huzura �a��r | `-` |
| `game/ui/person_panel.gd:264` | Gizli �deme | `-` |
| `game/ui/person_panel.gd:265` | Raporu Do�rula | `-` |
| `game/ui/person_panel.gd:266` | Ara�t�r | `-` |
| `game/ui/person_panel.gd:267` | Soru�turma | `-` |
| `game/ui/person_panel.gd:268` | Yaz�l� Emir | `-` |
| `game/ui/person_panel.gd:269` | S�zl� Emir | `-` |
| `game/ui/person_panel.gd:270` | �ma | `-` |
| `game/ui/person_panel.gd:271` | �antaj | `-` |
| `game/ui/person_panel.gd:272` | G�revden Al | `-` |
| `game/ui/person_panel.gd:273` | S�z: Naiplik | `-` |
| `game/ui/person_panel.gd:274` | S�z: Liman �halesi | `-` |
| `game/ui/person_panel.gd:275` | S�z: Dokunulmazl�k | `-` |
| `game/ui/person_panel.gd:276` | Dikkat Da��t | `-` |
| `game/ui/person_panel.gd:277` | Muhalefeti B�l | `-` |
| `game/ui/person_panel.gd:278` | Rakibi Zay�flat | `-` |
| `game/ui/person_panel.gd:279` | Birbirine D���r | `-` |
| `game/ui/person_panel.gd:280` | Sad�k Ata | `-` |
| `game/ui/person_panel.gd:282` | �hale Ver | `-` |
| `game/ui/person_panel.gd:283` | Veliahd� Yeti�tir | `-` |
| `game/ui/person_panel.gd:284` | Heyet G�nder | `-` |
| `game/ui/person_panel.gd:286` | iz b�rak�r | `-` |
| `game/ui/person_panel.gd:286` | kan�t b�rak�r | `-` |
| `game/ui/person_panel.gd:287` | d���k | `-` |
| `game/ui/person_panel.gd:287` | y�ksek | `-` |
| `game/ui/person_panel.gd:300` | �oklu se�imi a� ve tam iki ki�i se�. | `-` |
| `game/ui/person_panel.gd:302` | Bu �ifti yak�n zamanda denedin; %d hafta bekle. | `%d` |
| `game/ui/person_panel.gd:304` | �kisi de g��l� ve h�rsl�ysa daha �ok kap���rlar. Ba�ar�s�z olursa kimin yapt���n� anlarlar. | `-` |
| `game/ui/person_panel.gd:308` | �nce �emberi kur: 1�3 ki�i se�. | `-` |
| `game/ui/person_panel.gd:308` | �ember b�y�d�k�e ba�ar� da, s�z�nt� riski de artar. | `-` |
| `game/ui/person_panel.gd:310` | �nce bir ki�i se�. | `-` |
| `game/ui/person_panel.gd:317` | Yaln�zca Sarne'ye ihale verilebilir. | `-` |
| `game/ui/person_panel.gd:319` | �hale komisyonu yeni dosyay� hen�z a�m�yor. | `-` |
| `game/ui/person_panel.gd:322` | Yaln�zca Julian i�in kullan�labilir. | `-` |
| `game/ui/person_panel.gd:324` | Julian yeni derslerine haz�rlan�yor. | `-` |
| `game/ui/person_panel.gd:327` | Claire, Viktor ya da Lucien se�ilmeli. | `-` |
| `game/ui/person_panel.gd:329` | El�ilikler �nceki heyetin cevab�n� bekliyor. | `-` |
| `game/ui/person_panel.gd:332` | Yaln�zca kurum ba�kanlar� i�in kullan�labilir. | `-` |
| `game/ui/person_panel.gd:334` | Bu kurumda yeni atama i�in beklemelisin. | `-` |
| `game/ui/person_panel.gd:338` | %s yeniden �a��rmak i�in %d hafta beklemelisin. | `%s, %d` |
| `game/ui/person_panel.gd:342` | %s zaten vazge�ilmez; terfi onu daha da tehlikeli yapar. | `%s` |
| `game/ui/person_panel.gd:348` | Onun hakk�nda ��renilecek bir �ey kalmad�. | `-` |
| `game/ui/person_panel.gd:351` | �nce zay�f noktas�n� ��ren (Ara�t�r). | `-` |
| `game/ui/person_panel.gd:355` | Sokak bast�rmaya al���yor: her emir daha az i�e yar�yor, �fke birikiyor. | `-` |
| `game/ui/person_panel.gd:358` | G�c� var; kar��l�k verebilir. | `-` |
| `game/ui/person_panel.gd:358` | Vazge�ilmez birini d���rmek a��r bir kar�� sald�r� getirebilir. | `-` |
| `game/ui/person_panel.gd:361` | Bu �d�l zaten birine verildi. | `-` |
| `game/ui/person_panel.gd:363` | %s art�k sana kar��; eylemlerin i�e yaramayabilir. | `%s` |
| `game/ui/person_panel.gd:470` | D��man | `-` |
| `game/ui/person_panel.gd:550` | EYLEMLER   �   �nce bir ki�i se� | `-` |
| `game/ui/person_panel.gd:554` |   +%d ki�i | `%d` |
| `game/ui/person_panel.gd:595` | [color=gray]Bir ki�i se�. Say�lar� g�remezsin; yaln�zca davran��lar�ndan tahmin edebilirsin.[/color] | `-` |
| `game/ui/person_panel.gd:604` | G�� �  | `-` |
| `game/ui/person_panel.gd:605` | G�� merkezi olarak ne kadar a��rl��� var. Vazge�ilmez olanlar tehlikelidir. | `-` |
| `game/ui/person_panel.gd:608` | N�fuz �  | `-` |
| `game/ui/person_panel.gd:609` | Sarne'nin anlatt��� �irket a��; ger�ek s�n�rlar� daha geni� olabilir. | `-` |
| `game/ui/person_panel.gd:611` | d��manca | `-` |
| `game/ui/person_panel.gd:612` | Gazete ve kanal�n�n saraya kar�� tutumu. | `-` |
| `game/ui/person_panel.gd:615` | Veliahd�n sarayda ve halk�n �n�nde kendine yer bulma h�li. | `-` |
| `game/ui/person_panel.gd:617` | D��man | `-` |
| `game/ui/person_panel.gd:617` | Sana kar�� fiilen harekete ge�ti. | `-` |
| `game/ui/person_panel.gd:620` | Tav�r �  | `-` |
| `game/ui/person_panel.gd:622` | Kar��l�k bekliyor | `-` |
| `game/ui/person_panel.gd:622` | Ona verdiklerinin kar��l���n� bekliyor. | `-` |
| `game/ui/person_panel.gd:624` | Zay�f nokta:  | `-` |
| `game/ui/person_panel.gd:625` | Biliniyorsa �antaj m�mk�n. 'Ara�t�r' ile ��renilebilir. | `-` |
| `game/ui/person_panel.gd:625` | �antaj i�in kullan�labilir. | `-` |
| `game/ui/person_panel.gd:626` | K�rm�z� �izgi:  | `-` |
| `game/ui/person_panel.gd:627` | Bu �izgiyi a�arsan affetmez. | `-` |
| `game/ui/person_panel.gd:631` | Do�rulama: %d �rt��t� � %d �eli�ti | `%d, %d` |
| `game/ui/person_panel.gd:632` | Raporlar�n�n ba�ka kaynaklarla kar��la�t�r�lmas�. | `-` |
| `game/ui/person_panel.gd:634` | S�z: %s � hafta %d | `%s, %d` |
| `game/ui/person_panel.gd:634` | Ona verdi�in s�z ve vadesi. | `-` |
| `game/ui/person_panel.gd:636` | %d ki�i se�ili � operasyon �emberi | `%d` |
| `game/ui/person_panel.gd:646` | Son haftalarda hakk�nda bir alamet g�r�lmedi.\nDarbeyi yaln�zca ordu ya da hanedan ba�latabilir; ama herkes komploya kat�labilir. | `-` |
| `game/ui/person_panel.gd:648` | Son alametler:\n%s\n\nAlametlerin bir k�sm� dedikodudur. Huzura �a��r ile yoklayabilirsin. | `%s` |
| `game/ui/truth_chart.gd:7` | Taht�n g�c� | `-` |
| `game/ui/truth_chart.gd:8` | Halk�n �fkesi | `-` |
| `game/ui/truth_chart.gd:11` | Sarne'nin pay� | `-` |
| `game/ui/truth_chart.gd:12` | D�� ili�kiler | `-` |
| `game/ui/truth_chart.gd:39` | GER�EKTE NE OLDU | `-` |
| `game/ui/ui_kit.gd:18` | ��kar� var | `-` |
| `game/ui/ui_kit.gd:87` | haz�rlanm�� | `-` |
| `game/ui/ui_kit.gd:145` | � | `-` |
| `game/ui/ui_kit.gd:145` | � | `-` |
