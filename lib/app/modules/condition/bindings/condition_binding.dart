import 'package:get/get.dart';
import '../controllers/condition_controller.dart';

class ConditionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConditionController>(() => ConditionController());
  }
}