import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bu derlemede harita anahtarı var mı? Yerel tarafa sorulur (iOS
/// `AppDelegate`, Android `MainActivity`). Anahtarsız derlemede, testte ya da
/// yanıt gelmezse `false`: harita yerine kısa bir açıklama gösterilir.
final mapsAvailableProvider = FutureProvider<bool>((ref) async {
  try {
    return await const MethodChannel('gurme/maps')
            .invokeMethod<bool>('isAvailable') ??
        false;
  } on Object {
    return false;
  }
});
