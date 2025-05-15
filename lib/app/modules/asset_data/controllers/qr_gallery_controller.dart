// lib/app/modules/asset_data/controllers/qr_gallery_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/asset_model.dart';
import '../services/asset_service.dart';
import '../services/qr_code_service.dart';

class QrGalleryController extends GetxController {
  // Services
  final AssetService _assetService = Get.find<AssetService>();
  final QrCodeService _qrCodeService = Get.find<QrCodeService>();
  final logger = Logger();

  // Observable variables
  final RxList<Asset> assetsWithQr = <Asset>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssetsWithQr();
  }

  // Load assets with QR codes
  Future<void> loadAssetsWithQr() async {
    try {
      isLoading.value = true;
      
      // Fetch all assets first if necessary
      if (_assetService.assets.isEmpty) {
        await _assetService.fetchAssets();
      }
      
      // Filter assets with QR codes
      assetsWithQr.value = _assetService.getAssetsWithQrCode();
      
      // Sort by name
      assetsWithQr.sort((a, b) => 
        (a.namaBarang ?? '').compareTo(b.namaBarang ?? ''));
      
      logger.i('Loaded ${assetsWithQr.length} assets with QR codes');
    } catch (e) {
      logger.e('Error loading assets with QR codes: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh gallery
  void refreshQrGallery() {
    loadAssetsWithQr();
  }

  // Show QR code options
  void showQrCodeOptions(Asset asset) {
    if (asset.qrCodePath == null || asset.qrCodePath!.isEmpty) {
      Get.snackbar(
        'Error',
        'QR code tidak ditemukan untuk aset ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String qrPath = asset.qrCodePath!;
    
    // Check if path exists, if not, try to download from Supabase
    if (!File(qrPath).existsSync() && qrPath.startsWith('http')) {
      // Show downloading dialog
      
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Try to download
      _qrCodeService.downloadQrCodeFromSupabase(
        qrPath, 
        asset.noInventarisBarang ?? 'unknown'
      ).then((localPath) {
        Get.back(); // Close loading dialog
        
        if (localPath != null) {
          qrPath = localPath;
          showQrDialog(asset, qrPath);
        } else {
          Get.snackbar(
            'Error',
            'Gagal mengunduh QR code dari server',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    } else {
      showQrDialog(asset, qrPath);
    }
  }

  // Show QR dialog
  void showQrDialog(Asset asset, String qrPath) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF12B1B9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'QR Code: ${asset.namaBarang ?? "Unnamed Asset"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show QR code image
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Image.file(File(qrPath)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          asset.noInventarisBarang ?? 'No Inv: -',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (asset.namaBarang != null)
                          Text(asset.namaBarang!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await _downloadAsPdf(asset, qrPath);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('Simpan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await _saveToGallery(qrPath);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to download QR code as PDF
  Future<void> _downloadAsPdf(Asset asset, String qrPath) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final pdfPath = await _qrCodeService.generatePdf(asset, qrPath);
      
      Get.back(); // Close loading dialog
      
      if (pdfPath != null) {
        final success = await _qrCodeService.savePdf(pdfPath);
        if (success) {
          Get.back(); // Close QR dialog
          Get.snackbar(
            'Sukses',
            'PDF QR code berhasil didownload',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Gagal',
            'Gagal menyimpan PDF',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal membuat PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      logger.e('Error downloading PDF: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membuat PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Method to save QR code to gallery
  Future<void> _saveToGallery(String qrPath) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final success = await _qrCodeService.saveQrToGallery(qrPath);
      
      Get.back(); // Close loading dialog
      
      if (success) {
        Get.back(); // Close QR dialog
        Get.snackbar(
          'Sukses',
          'QR code berhasil disimpan ke galeri',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menyimpan QR code ke galeri',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      logger.e('Error saving to gallery: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menyimpan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Open asset detail when QR code is tapped
  void openAssetDetail(Asset asset) {
    Get.back(); // Close QR dialog
    Get.toNamed('/asset-detail', arguments: asset);
  }
}