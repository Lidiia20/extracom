// login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clearError() {
    errorMessage.value = '';
  }

  bool validateInputs() {
    clearError();

    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Email harus diisi';
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Format email tidak valid';
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      errorMessage.value = 'Password harus diisi';
      return false;
    }

    return true;
  }

  Future<void> login() async {
    if (!validateInputs()) return;

    isLoading.value = true;
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      isLoading.value = false;

      if (response.session != null) {
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = 'Login gagal. Periksa kembali email dan password.';
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Terjadi kesalahan: $e';
    }
  }
}
