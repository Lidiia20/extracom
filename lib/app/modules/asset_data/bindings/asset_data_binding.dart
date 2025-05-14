import 'package:get/get.dart';
import '../providers/asset_api_provider.dart';
import '../services/asset_service.dart';
import '../controllers/asset_data_controller.dart';
import '../controllers/asset_detail_controller.dart';

class AssetDataBinding extends Bindings {
  @override
  void dependencies() {
    // Registrasi providers
    Get.lazyPut<AssetApiProvider>(() => AssetApiProvider(), fenix: true);
    
    // Registrasi services
    Get.lazyPut<AssetService>(() => AssetService(), fenix: true);
    
    // Registrasi controllers
    Get.lazyPut<AssetDataController>(() => AssetDataController(), fenix: true);
    
    // Mendaftarkan AssetDetailController juga di binding
    Get.lazyPut<AssetDetailController>(() => AssetDetailController(), fenix: true);
  }
}