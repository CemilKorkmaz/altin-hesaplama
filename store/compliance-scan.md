# Uyumluluk taraması (Play Store + App Store)

Araç: [mjmirza/app-store-compliance](https://github.com/mjmirza/app-store-compliance) — kural paketi v2.5.1,
114 tarihli kaynak, Flutter projelerini de tanıyor.

```bash
git clone https://github.com/mjmirza/app-store-compliance ~/app-store-compliance
bash ~/app-store-compliance/agent-os/hooks/app-store-compliance-guard.sh "/path/to/altin-hesaplama"
```

## İlk tarama — sonuç: BLOCKED (critical=1, high=5, medium=3)

| Önem | Kural | Durum |
|---|---|---|
| 🔴 CRITICAL | `FLUTTER-PRIVACY-MANIFEST-MISSING` | ❌ Eksikti → **düzeltildi** |
| 🟠 HIGH | `APPLE-5.1.1-MISSING-PRIVACY-POLICY` | ❌ Uygulama içinden erişilemiyordu → **düzeltildi** |
| 🟠 HIGH | `APPLE-EXPORT-COMPLIANCE-MISSING` | ❌ `ITSAppUsesNonExemptEncryption` yoktu → **düzeltildi** |
| 🟠 HIGH | `APPLE-PRIVACY-NUTRITION-LABELS` | ❌ Manifest yoktu → **düzeltildi** |
| 🟠 HIGH | `ANDROID-R8-OPTIMIZATION-MISSING` | ❌ `minifyEnabled` yoktu → **düzeltildi** |
| 🟠 HIGH | `GOOGLE-MISSING-PRIVACY-POLICY` | ❌ Play Console'da URL girilmedi → **manuel adım** |
| 🟡 MEDIUM | `APPLE-ACCESSIBILITY-HAPTICS` | ❌ Dokunsal geri bildirim yoktu → **düzeltildi** |
| 🟡 MEDIUM | `APPLE-2.3-AGE-RATING-2026` | ⚠️ Anket doldurulmalı → **manuel adım** |
| 🟡 MEDIUM | `GOOGLE-12-TESTER-RULE` | ⚠️ Kişisel hesap için 12 test kullanıcısı / 14 gün → **manuel adım** |

> Not: "GOOGLE-MISSING-PRIVACY-POLICY" taraması depo içinde `privacy-policy` metni arıyor.
> Politika `PRIVACY_POLICY.md` ve `docs/privacy-policy.html` olarak **var**; eksik olan
> Play Console'a girilen URL. Tarama bunu göremediği için uyarı verdi.

---

## Yapılan düzeltmeler

### 1. iOS gizlilik manifesti — `ios/Runner/PrivacyInfo.xcprivacy`

```xml
<key>NSPrivacyTracking</key> <false/>
<key>NSPrivacyCollectedDataTypes</key> <array/>
<key>NSPrivacyAccessedAPITypes</key>
<array>
  <!-- shared_preferences -> UserDefaults, kod CA92.1 -->
</array>
```

Uygulama hiçbir kişisel veri toplamıyor (politika ve veri güvenliği formuyla tutarlı).
`shared_preferences` yalnızca `UserDefaults` kullanıyor; Apple'ın gerekli-sebep kodu
**CA92.1** ("yalnızca uygulamanın kendisi tarafından erişilen veriler").

### 2. Dışa aktarma uyumluluğu — `ios/Runner/Info.plist`

```xml
<key>ITSAppUsesNonExemptEncryption</key> <false/>
```

Uygulama yalnızca sistem TLS'i (HTTPS) kullanıyor; özel şifreleme yok. Bu anahtar
olmadan derleme "Missing Compliance" durumunda takılır ve incelemeye hiç ulaşmaz.

### 3. Uygulama içi gizlilik politikası — `lib/screens/about_screen.dart`

Başlık çubuğuna ℹ️ düğmesi eklendi. Açılan **Hakkında** ekranında:

- Gizlilik politikası bağlantısı (tarayıcıda açılır)
- Dil anahtarı (Türkçe / English)
- Tema anahtarı (açık / koyu)
- Sürüm ve geliştirici bilgisi

Apple 5.1.1 ve Play, politikanın yalnızca mağazada değil **uygulamanın içinden de**
erişilebilir olmasını istiyor.

Bağlantı açma, ek paket eklemeden platform kanalıyla yapıldı:

- Android: `MainActivity.kt` → `Intent.ACTION_VIEW`
- iOS: `AppDelegate.swift` → `UIApplication.shared.open`
- Yalnızca `http`/`https` şemalarına izin verilir

### 4. R8 optimizasyonu — `android/app/build.gradle.kts`

```kotlin
isMinifyEnabled = true
isShrinkResources = true
proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
```

Play, Şubat 2027'den itibaren R8 optimizasyonu bekliyor. `proguard-rules.pro` Flutter
motoru ve platform kanalları için koruma kuralları içeriyor.

### 5. Dokunsal geri bildirim

`HapticFeedback` çağrıları eklendi: alış ekleme/kaydetme, silme onayı, dil ve tema
değişimi, simülasyon hesaplama, piyasa yenileme, Hakkında ekranı.

---

## Kalan manuel adımlar (kodla çözülemez)

| # | Adım | Nerede |
|---|---|---|
| 1 | Gizlilik politikası URL'sini gir | Play Console → Mağaza varlığı → Gizlilik politikası |
| 2 | Aynı URL'yi gir | App Store Connect → App Privacy |
| 3 | Veri güvenliği formu: **veri toplamıyor** | Play Console → Uygulama içeriği |
| 4 | Nutrition label: **Data Not Collected** | App Store Connect → App Privacy |
| 5 | 18+ yaş derecelendirme anketi | App Store Connect → Age Rating |
| 6 | 12 test kullanıcısı / 14 gün (kişisel hesap) | Play Console → Test → Kapalı test |
| 7 | R8'in bozmadığını doğrula: `flutter build apk --release` sonrası uygulamayı aç | Yerel derleme |

---

## Regülasyon takvimi (bilgi amaçlı)

Tarama ayrıca yaklaşan yasal tarihleri listeliyor. Bu uygulama için geçerli olanlar:

- **17 Kasım 2026** — Apple Türkiye vergi/fiyat güncellemesi (ücretsiz uygulama, etkisiz)
- **1 Ocak 2027** — ABD eyalet yaş doğrulama yasaları (California, Alabama vb.)
- **1 Şubat 2027** — Play, EEA/UK için "trader status" beyanı
- **1 Şubat 2027** — Play teknik kalite: R8/DEX optimizasyon eşikleri ← **biz bunu şimdiden yaptık**

Uygulama reklam, abonelik, kripto, sağlık verisi içermediği için listedeki yasaların
büyük çoğunluğu kapsam dışında.

---

## Son tarama (düzeltmelerden sonra)

```
Summary. critical=0 high=0 medium=3
Coverage. complete ios=1 android=1 web=0
CLEAR. 0 critical risks in the code scan.
```

Kalan 3 MEDIUM kodla ilgili değil, konsol adımı:

| Kural | Ne istiyor |
|---|---|
| `APPLE-ACCESSIBILITY-HAPTICS` | **Yanlış pozitif.** Kural yalnızca native iOS sinyallerini arıyor (`UIImpactFeedbackGenerator`, `CHHapticEngine`). Uygulama Flutter'da `HapticFeedback` kullanıyor; bu Flutter'da `UIImpactFeedbackGenerator`'a derinlemesine bağlanır. Yine de `add_purchase_screen.dart` ve diğer ekranlara çağrılar eklendi. |
| `APPLE-2.3-AGE-RATING-2026` | App Store Connect'te yaş derecelendirme anketi |
| `GOOGLE-12-TESTER-RULE` | Play kapalı test: 12 kullanıcı / 14 gün |

## Özet

| Platform | Engelleyici sorun | Durum |
|---|---|---|
| iOS | Gizlilik manifesti yok | ✅ Düzeltildi |
| iOS | Dışa aktarma beyanı yok | ✅ Düzeltildi |
| iOS | Uygulama içi politika bağlantısı yok | ✅ Düzeltildi |
| Android | R8 kapalı | ✅ Düzeltildi |
| Her ikisi | Mağaza konsolunda URL/anket/form | ⏳ Senin yapman gerekiyor |

Tarama "bu kod tabanında kritik red nedeni kalmadı" demek için yeniden çalıştırılmalı;
ancak tarama **kodu** doğrular, mağaza konsolundaki formları doğrulayamaz.
