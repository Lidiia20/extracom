import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Pastikan splash screen muncul selama 3 detik
      await Future.delayed(const Duration(seconds: 3));
      
      // Hapus data user yang tersimpan untuk memastikan harus login ulang
      final storageUtil = Get.find<StorageUtil>();
      await storageUtil.clearUserData();
      
      // Gunakan logger GetX daripada print
      Get.log('Navigating to LOGIN page');
      // Selalu arahkan ke halaman login tanpa pemeriksaan status
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.log('Error in splash screen: $e');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_pln.png',
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                Get.log('Error loading image: $error');
                return const Icon(Icons.error, size: 100, color: Colors.red);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'ExstraCoM',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kelola Data Aset Perusahaan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}