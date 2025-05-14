import 'package:get/get.dart';
import '../controllers/nota_controller.dart';
import '../services/nota_service.dart';
import '../providers/nota_provider.dart';

class NotaBinding extends Bindings {
  @override
  void dependencies() {
    // Get base URL from ApiProvider
    final baseUrl = Get.find<String>(tag: 'baseUrl') ?? 
                   'https://script.google.com/macros/s/AKfycbwqxVmg7t2qT1s2YygywzkajJKFa6i83pH2OdT6E11v_YC_Ov4f_BV74hcK9E-Uyd1HwA/exec';

    // Provider
    Get.lazyPut<NotaProvider>(() => NotaProvider(baseUrl: baseUrl));
    
    // Service
    Get.lazyPut<NotaService>(() => NotaService(notaProvider: Get.find<NotaProvider>()));
    
    // Controller
    Get.lazyPut<NotaController>(() => NotaController());
  }
}