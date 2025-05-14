// lib/app/modules/asset_data/di/dependency_injection.dart
// Update file ini jika sudah ada, atau buat baru jika belum ada

import 'package:get/get.dart';
import '../services/asset_service.dart';
import '../services/qr_code_service.dart';

class AssetDependencyInjection {
  static void init() {
    // Register AssetService jika belum ter-register
    if (!Get.isRegistered<AssetService>()) {
      Get.put<AssetService>(AssetService());
    }
    
    // Register QrCodeService
    if (!Get.isRegistered<QrCodeService>()) {
      Get.put<QrCodeService>(QrCodeService());
    }
  }
}

// Jika Anda menggunakan initialBinding di main, tambahkan ini:
class AssetBindings extends Bindings {
  @override
  void dependencies() {
    // Register AssetService
    Get.lazyPut<AssetService>(() => AssetService());
    
    // Register QrCodeService
    Get.lazyPut<QrCodeService>(() => QrCodeService());
  }
}