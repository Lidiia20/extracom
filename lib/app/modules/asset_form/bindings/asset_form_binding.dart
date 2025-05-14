// lib/app/modules/asset_form/bindings/asset_form_binding.dart
import 'package:get/get.dart';
import '../controllers/asset_form_controller.dart';
import '../../asset_data/providers/asset_api_provider.dart';
import '../../asset_data/services/asset_service.dart';
import '../../asset_data/services/asset_history_service.dart';
import '../../asset_data/services/qr_code_service.dart';

class AssetFormBinding extends Bindings {
  @override
  void dependencies() {
    // Register dependencies
    if (!Get.isRegistered<AssetApiProvider>()) {
      Get.put(AssetApiProvider());
    }
    
    if (!Get.isRegistered<AssetService>()) {
      Get.put(AssetService());
    }
    
    if (!Get.isRegistered<AssetHistoryService>()) {
      Get.put(AssetHistoryService());
    }
    
    if (!Get.isRegistered<QrCodeService>()) {
      Get.put(QrCodeService());
    }
    
    // Register the controller
    Get.put(AssetFormController());
  }
}