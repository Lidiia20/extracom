import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Add this import
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final userName = ''.obs;
  final assetCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    getUserInfo();
    // Simulasi pengambilan jumlah aset, nantinya bisa terhubung ke database
    simulateGetAssetCount();
  }
  
  void getUserInfo() {
    final user = _authService.currentUser.value;
    if (user != null) {
      userName.value = user.name;
    }
  }
  
  void simulateGetAssetCount() {
    // Simulasi data aset, nantinya akan diambil dari database
    assetCount.value = 42;
  }
  
  void logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.LOGIN);
  }
  
  void showFeatureNotImplemented() {
    Get.snackbar(
      'Info',
      'Fitur ini sedang dalam pengembangan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF12B1B9).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}