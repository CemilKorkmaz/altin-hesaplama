# Yayından sonra reklam eklemek

**Kısa cevap: Evet, ekleyebilirsin.** "Reklam içermiyor" beyanı kalıcı bir taahhüt değil, o sürümdeki durumun beyanıdır. Reklam eklediğin **yeni sürümü** yüklerken beyanı güncellersin.

Ancak sırası önemli: **önce beyanı değiştir, sonra reklamlı sürümü yayınla.** Reklamı yayınlayıp beyanı "Hayır" bırakmak Play politikası ihlalidir ve uygulama askıya alınabilir.

---

## Reklam eklemeye karar verdiğinde yapılacaklar

### 1. Play Console beyanı
**Politika ve programlar → Uygulama içeriği → Reklamlar → Yönet** → **Evet** seç.
Mağaza sayfasında "Reklam içeriyor" etiketi görünür.

### 2. Gizlilik politikasını güncelle (zorunlu)
Reklam = reklam kimliği ve üçüncü taraf SDK veri işleme demektir. Mevcut politikada
"reklam kimliği toplanmaz" yazıyor; reklam eklersen bu ifade yanlış olur.
`docs/privacy-policy-google-sites.txt` ve `PRIVACY_POLICY.md` dosyalarında
**"Toplamadığımız bilgiler"** bölümünden "Reklam kimliği (Advertising ID)" satırını çıkar,
yerine şu bölümü ekle:

**TR:**
> **Reklamlar.** Uygulama, ücretsiz kalabilmek için [ADMOB] aracılığıyla reklam gösterebilir.
> Reklam ortağı; reklam kimliği, cihaz modeli, işletim sistemi sürümü ve yaklaşık konum
> (IP adresinden türetilen ülke/bölge) gibi verileri reklam kişiselleştirme ve ölçümleme
> amacıyla işleyebilir. Portföy kayıtlarınız (miktar, alış fiyatı, tarih) reklam
> ortaklarıyla **paylaşılmaz**. Reklam kişiselleştirmeyi cihaz ayarlarından kapatabilirsiniz.

**EN:**
> **Ads.** To remain free, the app may display ads through [ADMOB]. The ad partner may
> process data such as the advertising ID, device model, OS version and approximate
> location (country/region derived from IP) for ad personalisation and measurement.
> Your portfolio records (quantity, purchase price, date) are **not** shared with ad
> partners. You can opt out of ad personalisation in your device settings.

Güncelleme tarihini de değiştir.

### 3. Gizlilik politikası URL'si aynı kalır
Google Sites sayfasını düzenleyip yeniden yayınla. Play'deki URL değişmez.

### 4. Veri güvenliği formunu güncelle
- "Veri topluyor mu?" → **Evet**
- Tür: **Cihaz veya diğer kimlikler** + **Yaklaşık konum**
- Amaç: **Reklam veya pazarlama**
- Paylaşım: **Evet** (reklam ağıyla)
- Veriler aktarımda şifreli mi: **Evet**

### 5. AD_ID izni
AdMob SDK'sı `com.google.android.gms.permission.AD_ID` iznini otomatik ekler.
Play Console, yeni sürümü yüklerken "Advertising ID" beyanı ister → **Evet** seç ve
amacı **Reklam veya pazarlama** olarak işaretle.

### 6. Yaş ve içerik sınıflandırması
Finans uygulaması + reklam birlikte değerlendirilir. İçerik derecelendirmesi formunu
reklam ekledikten sonra yeniden gözden geçir.

### 7. Teknik kontrol listesi
- [ ] AdMob hesabı ve uygulama kaydı (`com.cemilkorkmaz.altin_hesaplama`)
- [ ] `google_mobile_ads` paketi eklendi
- [ ] Ön-test reklam kimlikleriyle denendi (canlı reklam ID'si yalnızca sonrasında)
- [ ] Reklamlar "portföy ekle" ve "simülasyon" akışını bozmuyor
- [ ] Reklamlar koyu temada okunabilir
- [ ] Reklam yüklenemezse uygulama çökmüyor (fallback var)
- [ ] Play Console beyanı **Evet** olarak güncellendi
- [ ] Gizlilik politikası güncellendi ve yayınlandı
- [ ] Veri güvenliği formu güncellendi

---

## Dikkat edilecekler

| Konu | Not |
|---|---|
| Zamanlama | Beyanı reklamlı sürümden **önce** güncelle |
| Askıya alma riski | Yanlış beyan = politika ihlali, ciddi sonuç |
| Çocuk kitlesi | Uygulama 13+ ise "çocuklara yönelik" işaretleme; reklam ağında aile dostu ayar |
| Kişiselleştirilmiş reklam | AB/İngiltere kullanıcıları için onay (UMP SDK) gerekir |
| Finans kategorisi | Reklam içeriği finans mevzuatına aykırı olmamalı (kredi/kolay kazanç vaadi yasak) |

> Bu uygulama şu an reklam içermiyor ve `AndroidManifest.xml` içinde AD_ID izni yok.
> Reklam eklenmediği sürece beyan **Hayır** kalmalı.
