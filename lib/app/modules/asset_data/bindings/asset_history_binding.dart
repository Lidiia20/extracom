// lib/app/modules/asset_data/bindings/asset_history_binding.dart
import 'package:get/get.dart';
import '../controllers/asset_history_controller.dart';
import '../services/asset_history_service.dart';
import '../providers/asset_api_provider.dart';

class AssetHistoryBinding implements Bindings {
  @override
  void dependencies() {
    // Register API provider if not already registered
    if (!Get.isRegistered<AssetApiProvider>()) {
      Get.put(AssetApiProvider(), permanent: true);
    }
    
    // Register service with proper initialization
    if (!Get.isRegistered<AssetHistoryService>()) {
      // Create instance and call init method explicitly
      final service = AssetHistoryService();
      Get.put<AssetHistoryService>(service, permanent: true);
      // Initialize the service
      service.init();
    }
    
    // Register controller
    Get.lazyPut<AssetHistoryController>(() => AssetHistoryController());
  }
}