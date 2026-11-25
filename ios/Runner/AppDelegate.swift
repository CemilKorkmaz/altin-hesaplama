import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // `FlutterImplicitEngineBridge` doğrudan `binaryMessenger` sunmaz;
    // messenger, uygulama kayıt nesnesi üzerinden alınır.
    registerLinkChannel(engineBridge.applicationRegistrar.messenger())
  }

  /// Gizlilik politikası gibi harici bağlantıları sistem tarayıcısında açar.
  /// `url_launcher` bağımlılığı eklememek için tek amaçlı kanal kullanılıyor.
  private func registerLinkChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "altin_hesaplama/links",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "open",
        let arguments = call.arguments as? [String: Any],
        let raw = arguments["url"] as? String,
        let url = URL(string: raw),
        let scheme = url.scheme?.lowercased(),
        scheme == "https" || scheme == "http"
      else {
        result(FlutterError(code: "invalid_url", message: nil, details: nil))
        return
      }

      DispatchQueue.main.async {
        UIApplication.shared.open(url, options: [:]) { opened in
          if opened {
            result(nil)
          } else {
            result(FlutterError(code: "open_failed", message: nil, details: nil))
          }
        }
      }
    }
  }
}
