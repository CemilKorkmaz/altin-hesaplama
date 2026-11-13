# Google Sites'ta gizlilik politikası yayınlama (adım adım)

Play Console'a girilecek sayfa için hazır dosyalar:

| Dosya | Ne için |
|---|---|
| `docs/privacy-policy-google-sites.txt` | **Google Sites'a kopyala-yapıştır** için düz metin (TR + EN) |
| `docs/privacy-policy.html` | GitHub Pages / başka hosting için hazır HTML sayfası |
| `PRIVACY_POLICY.md` | Depodaki sürüm (yedek/kayıt) |

---

## 1. İletişim bilgileri (hazır — değiştirmenize gerek yok)

Metinlerde iletişim bilgisi olarak artık şunlar yazılı:

- **Geliştirici / Data controller:** C&A Digital Ventures
- **E-posta:** ca.digital.ventures@gmail.com

Bu bilgiler `PRIVACY_POLICY.md`, `docs/privacy-policy.html` ve `docs/privacy-policy-google-sites.txt`
dosyalarına işlendi. Kopyala-yapıştır yaparken hiçbir alanı doldurmanız gerekmiyor.

> Play, gizlilik politikası sayfasında görünür bir iletişim bilgisi görmek ister. E-posta sayfada
> yazılı olduğu için bu şart karşılanıyor.

---

## 2. Google Sites'ta sayfa oluşturun

1. <https://sites.google.com> → **Boş** şablon ile yeni site.
2. Sağ üstte **Site adı**: `Altın Defterim — Gizlilik Politikası`
3. Sol üstteki **Sayfa** panelinde sayfa adı: `Gizlilik Politikası` (URL'de `gizlilik-politikasi` olur).

---

## 3. İçeriği yapıştırın

1. Metin kutusunu ekleyin (**Ekle → Metin kutusu**).
2. `docs/privacy-policy-google-sites.txt` içeriğinin **tamamını** seçip yapıştırın.
3. Başlıkları biçimlendirin:
   - İlk 3 satır (`ALTIN DEFTERİM...`, `Yürürlük tarihi...`, `Paket adı...`) → **Başlık**
   - `1.`, `2.`, ... ile başlayan satırlar → **Başlık 2**
   - İki dil arasındaki `====` çizgisini silip yerine **Ekle → Ayırıcı** koyun.
4. İsterseniz Google Sites **tema** olarak sıcak/krem bir tema seçin; uygulamanın simge renkleriyle uyumlu olur.

---

### Yöntem B — biçimi koruyarak gömme (isteğe bağlı, daha hızlı)

Başlıklarla tek tek uğraşmak istemiyorsanız:

1. `docs/privacy-policy.html` dosyasını bir metin düzenleyicide açın, **tamamını** kopyalayın.
2. Google Sites'ta **Ekle → Yerleştir → Kodu yerleştir (Embed code)** seçin.
3. Kopyaladığınız HTML'i yapıştırın → **Sonraki → Ekle**.
4. Gömme kutusunu sayfa genişliğine çekin (yükseklik ~3000 px veya "tam boyut").
5. Metinlerde iletişim bilgisi hazır; e-posta değiştirilmiş durumda.

> Not: Google Sites'ta gömülü kod bazen dar bir çerçevede görünür. Play yalnızca içeriğin erişilebilir olmasını ister; görünüm ikincil. En temiz sonuç için Yöntem A (düz metin) önerilir.

---

## 4. Yayınlayın

1. Sağ üst **Yayınla**.
2. **Web adresi**: `altin-defterim` yazın → adres şu biçimde olur:
   ```
   https://sites.google.com/view/altin-defterim
   ```
3. **Görünürlük**: **Herkese açık** (Play inceleyicisi giriş yapamaz, "Kuruluşunuzdaki kişiler" seçmeyin).
4. **Yayınla** → açılan URL'yi kopyalayın.
5. Gizli/incognito pencerede açıp gerçekten erişilebildiğini doğrulayın.

---

## 5. Play Console'a girin

**Mağaza varlığı → Mağaza ayarları → Gizlilik politikası** alanına URL'yi yapıştırın.

> Not: Google Sites URL'leri genelde şu biçimde olur — `https://sites.google.com/view/<site-adi>/<sayfa-adi>`.
> Sayfa adını Türkçe karakter olmadan (`gizlilik-politikasi`) yazarsanız sorun çıkmaz, Play her iki biçimi de kabul eder.

---

## 6. Veri güvenliği formu — tutarlı cevaplar

Politika ile Play formunun birbiriyle çelişmemesi gerekir. Uygulamanın gerçek davranışına göre:

| Play sorusu | Cevap |
|---|---|
| Veri topluyor mu? | **Hayır** (toplanan veri yok) |
| Veri paylaşıyor mu? | **Hayır** |
| Veriler aktarımda şifreli mi? | Uygulanamaz / Evet (HTTPS) |
| Veri silme talebi | Uygulama içinden kayıt silme + kaldırma |
| Reklam | Yok |
| Analitik / çökme raporu | Yok |

> Fiyat isteklerinde IP adresinin sağlayıcı sunucularında teknik günlüğe yazılması, Play'in "veri toplama" tanımına göre geliştirici tarafından toplanan veri sayılmaz. Yine de formda uygulamanın internet erişimi olduğunu belirtin; metin bunu zaten açıklıyor.

---

## 7. Kontrol listesi

- [ ] İletişim bilgisi sayfada görünüyor (C&A Digital Ventures + e-posta)
- [ ] Site herkese açık yayınlandı
- [ ] Incognito pencerede açılıyor
- [ ] URL Play Console > Gizlilik politikası alanına girildi
- [ ] Veri güvenliği formu yukarıdaki tabloyla uyumlu
- [ ] Yürürlük tarihi (12 Kasım 2026) güncel

---

## Sık yapılan hatalar

| Hata | Çözüm |
|---|---|
| Sayfa "Kuruluşunuzdaki kişiler" görünürlüğünde | **Herkese açık** yapın |
| Play "URL erişilemiyor" diyor | Site henüz yayınlanmamış veya URL'de yazım hatası var |
| E-posta alanı boş kalmış | `ca.digital.ventures@gmail.com` her iki dilde de görünmeli |
| TR ve EN bölümü karışmış | `====` çizgisini ayırıcı ile değiştirin |
| Play "geliştirici adı uyuşmuyor" | Play Console'da geliştirici adı **C&A Digital Ventures** olmalı |
