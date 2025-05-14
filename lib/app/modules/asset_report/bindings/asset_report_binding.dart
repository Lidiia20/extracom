import 'package:get/get.dart';
import '../../asset_data/controllers/asset_data_controller.dart';
import '../controllers/asset_report_controller.dart';

class AssetReportBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure AssetDataController is initialized first
    if (!Get.isRegistered<AssetDataController>()) {
      Get.put(AssetDataController());
    }
    
    // Then initialize AssetReportController
    Get.put(AssetReportController());
  }
}