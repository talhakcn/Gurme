import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Harita anahtarı `Secrets.xcconfig` → Info.plist (`GMSApiKey`) yoluyla
  /// gelir. Dosya yoksa değer boş ya da çözülmemiş `$(MAPS_API_KEY)` kalır;
  /// o zaman harita açılmaz, uygulama "Harita bu derlemede kapalı" der.
  private var mapsKey: String? {
    guard let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
      !key.isEmpty, !key.hasPrefix("$(")
    else { return nil }
    return key
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = mapsKey {
      GMSServices.provideAPIKey(key)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Dart tarafı haritayı açmadan önce anahtar olup olmadığını sorar.
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GurmeMaps")
    else { return }
    let channel = FlutterMethodChannel(
      name: "gurme/maps", binaryMessenger: registrar.messenger())
    let available = mapsKey != nil
    channel.setMethodCallHandler { call, result in
      if call.method == "isAvailable" {
        result(available)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
