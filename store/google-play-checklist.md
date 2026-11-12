# Google Play yayınlama kontrol listesi

Teknik paket ve mağaza görselleri hazırdır. Hesaba özel şu adımlar geliştirici tarafından tamamlanmalıdır:

1. Android Studio'da **Build > Generate Signed App Bundle or APK** ile bir **upload key** oluşturun ve güvenli bir yerde yedekleyin.
2. `android/key.properties.example` dosyasını `android/key.properties` olarak kopyalayıp anahtar bilgilerinizi girin. Bu dosyayı ve `.jks` dosyasını Git'e eklemeyin.
3. `bash tool/build_play_release.sh` komutunu çalıştırın. İmzalı paket `store/altin-defterim-release.aab` olur.
4. Google Play Console'da Finans kategorisinde uygulama oluşturun ve paket adının `com.cemilkorkmaz.altin_hesaplama` olduğunu doğrulayın.
5. `store/icon-512.png` ve `store/play-feature-graphic.png` görsellerini yükleyin. `listing-tr.md` ve `listing-en.md` metinlerini kullanın.
6. Gizlilik politikası sayfasını herkese açık bir URL'de yayınlayın (`PRIVACY_POLICY.md` veya `docs/privacy-policy.html`). URL'yi Play Console'a girin.
7. Veri güvenliği bölümünde uygulamanın kişisel veri toplamadığını, kayıtların cihazda tutulduğunu belirtin. İnternet fiyat istekleri için sağlayıcıların standart teknik günlüklerini değerlendirin.
8. İçerik derecelendirmesi, hedef kitle, uygulama erişimi ve ülke dağıtımı formlarını tamamlayın.
9. En az bir kapalı test yapın; Android 7.0 ve güncel bir Android sürümünde alış, canlı fiyat, simülasyon, İngilizce ve koyu tema kontrollerini gerçekleştirin.
10. Play App Signing'i etkinleştirip imzalı AAB'yi yükleyin ve incelemeye gönderin.

**Önemli:** CI'da üretilen APK/AAB test amaçlı debug anahtarıyla imzalanır. Play Console'a yalnızca kendi upload key'inizle yerel olarak ürettiğiniz AAB'yi yükleyin. Upload key ve şifrelerini kaybetmeyin veya paylaşmayın.
