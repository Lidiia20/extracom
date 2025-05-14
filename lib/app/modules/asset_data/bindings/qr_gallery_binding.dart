// lib/app/modules/asset_data/bindings/qr_gallery_binding.dart
import 'package:get/get.dart';
import '../controllers/qr_gallery_controller.dart';
import '../services/asset_service.dart';
import '../services/qr_code_service.dart';

class QrGalleryBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure required services are registered
    if (!Get.isRegistered<AssetService>()) {
      Get.put(AssetService());
    }
    
    if (!Get.isRegistered<QrCodeService>()) {
      Get.put(QrCodeService());
    }
    
    // Register controller
    Get.put(QrGalleryController());
  }
}