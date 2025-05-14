// lib/app/modules/asset_data/controllers/qr_scanner_controller.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan jika belum


class QrScannerController extends GetxController {
  final logger = Logger();

  final MobileScannerController cameraController = MobileScannerController();

  final RxBool isScanning = true.obs;
  final RxBool hasTorch = false.obs;
  final RxBool isTorchOn = false.obs;

  @override
  void onInit() {
    super.onInit();
    logger.i('QrScannerController initialized');
    checkTorch();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  void toggleTorch() {
  try {
    isTorchOn.value = !isTorchOn.value;
    cameraController.toggleTorch();
    logger.d('Torch toggled: ${isTorchOn.value}');
  } catch (e) {
    logger.e('Torch toggle failed: $e');
    _showError('Torch tidak tersedia di perangkat ini.');
  }
}


  Future<void> checkTorch() async {
  try {
    // Anggap tersedia torch, karena MobileScanner tidak menyediakan `hasTorch`
    hasTorch.value = true;
    logger.d('Assuming device has torch (no explicit API available).');
  } catch (e) {
    logger.e('Error checking torch: $e');
    hasTorch.value = false;
  }
}


  void onBarcodeDetected(BarcodeCapture capture) {
    if (!isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      isScanning.value = false;

      final String? code = barcodes.first.rawValue;
      logger.i('Barcode detected: $code');

      if (code != null && code.isNotEmpty) {
        _processScannedCode(code);
      } else {
        isScanning.value = true;
      }
    }
  }

  // ✅ Ini yang diubah: cari berdasarkan no_inventaris, tanpa fungsi findAssetByInventoryNumber
  void _processScannedCode(String code) async {
    try {
      logger.i('Processing QR code: $code');

      if (_isValidQrFormat(code)) {
        final assetIdentifier = _extractAssetIdentifier(code);

        if (assetIdentifier != null) {
          logger.i('Found asset identifier: $assetIdentifier');

          final response = await Supabase.instance.client
              .from('assets')
              .select()
              .eq('no_inventaris', assetIdentifier)
              .maybeSingle();

          if (response != null) {
            Get.back(result: assetIdentifier);
            Get.toNamed('/asset-detail', arguments: response);
          } else {
            _showError('Aset tidak ditemukan untuk no inventaris: $assetIdentifier');
            isScanning.value = true;
          }
        } else {
          _showError('Format QR code tidak sesuai');
          isScanning.value = true;
        }
      } else {
        // Jika QR code hanya berisi no_inventaris langsung
        final response = await Supabase.instance.client
            .from('assets')
            .select()
            .eq('no_inventaris', code)
            .maybeSingle();

        if (response != null) {
          Get.back(result: code);
          Get.toNamed('/asset-detail', arguments: response);
        } else {
          _showError('Aset tidak ditemukan untuk kode: $code');
          isScanning.value = true;
        }
      }
    } catch (e) {
      logger.e('Error processing QR code: $e');
      _showError('Terjadi kesalahan: $e');
      isScanning.value = true;
    }
  }

  bool _isValidQrFormat(String code) {
    return code.contains('_');
  }

  String? _extractAssetIdentifier(String code) {
    try {
      final parts = code.split('_');
      if (parts.isNotEmpty) {
        return parts[0];
      }
    } catch (e) {
      logger.e('Error extracting asset identifier: $e');
    }
    return null;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
}
