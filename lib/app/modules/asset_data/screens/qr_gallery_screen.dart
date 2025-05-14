// lib/app/modules/asset_data/screens/qr_gallery_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../services/asset_service.dart';
import '../services/qr_code_service.dart';
import '../models/asset_model.dart';

class QrGalleryController extends GetxController {
  final AssetService _assetService = Get.find<AssetService>();
  final QrCodeService _qrCodeService = Get.find<QrCodeService>();
  
  final RxList<Asset> assetsWithQr = <Asset>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadAssetsWithQr();
  }
  
  Future<void> loadAssetsWithQr() async {
    try {
      isLoading.value = true;
      
      // Menggunakan getAllAssets() yang ada di AssetService Anda
      final allAssets = _assetService.getAllAssets();
      
      // Filter assets with QR codes that exist
      assetsWithQr.value = allAssets.where((asset) => 
        asset.qrCodePath != null && 
        asset.qrCodePath!.isNotEmpty &&
        File(asset.qrCodePath!).existsSync()
      ).toList();
      
    } catch (e) {
      Get.log('Error loading QR gallery: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat galeri QR: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> downloadQrAsPdf(Asset asset) async {
  if (asset.qrCodePath == null) return;
  
  try {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    // Perbaikan: Meneruskan objek Asset, bukan String
    final pdfPath = await _qrCodeService.generatePdf(
      asset,  // Perubahan di sini: meneruskan objek Asset utuh
      asset.qrCodePath!
    );
    
    Get.back(); // Close loading dialog
    
    if (pdfPath != null) {
      final success = await _qrCodeService.savePdf(pdfPath);
      if (success) {
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
    }
  } catch (e) {
    Get.back(); // Close loading dialog
    Get.log('Error downloading PDF: $e');
    Get.snackbar(
      'Error',
      'Terjadi kesalahan saat membuat PDF: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  
  // Menyimpan QR ke penyimpanan
  Future<void> saveQrToGallery(Asset asset) async {
    if (asset.qrCodePath == null) return;
    
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Mengcopy file QR ke directory Downloads
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsDir = Directory('${directory.path}/QRCodes');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        
        final qrFile = File(asset.qrCodePath!);
        final fileName = 'QR_${asset.noInventarisBarang ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}.png';
        final destPath = '${downloadsDir.path}/$fileName';
        
        await qrFile.copy(destPath);
        
        Get.back(); // Close loading dialog
        
        Get.snackbar(
          'Sukses',
          'QR code berhasil disimpan ke penyimpanan: $destPath',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Gagal',
          'Tidak dapat mengakses penyimpanan eksternal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.log('Error saving to storage: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menyimpan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class QrGalleryScreen extends StatelessWidget {
  const QrGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QrGalleryController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAssetsWithQr(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.assetsWithQr.isEmpty) {
          return const Center(
            child: Text('Belum ada QR code yang tersimpan'),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.assetsWithQr.length,
          itemBuilder: (context, index) {
            final asset = controller.assetsWithQr[index];
            return QrCardItem(
              asset: asset,
              onDownloadPdf: () => controller.downloadQrAsPdf(asset),
              onSaveToGallery: () => controller.saveQrToGallery(asset),
            );
          },
        );
      }),
    );
  }
}

class QrCardItem extends StatelessWidget {
  final Asset asset;
  final VoidCallback onDownloadPdf;
  final VoidCallback onSaveToGallery;
  
  const QrCardItem({
    super.key,
    required this.asset,
    required this.onDownloadPdf,
    required this.onSaveToGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR Code Image
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: asset.qrCodePath != null
                ? Image.file(
                    File(asset.qrCodePath!),
                    fit: BoxFit.contain,
                  )
                : const Center(child: Text('QR tidak tersedia')),
            ),
          ),
          
          // Asset Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.namaBarang ?? 'Tidak ada nama',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'No. Inv: ${asset.noInventarisBarang ?? '-'}',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  tooltip: 'Download PDF',
                  onPressed: onDownloadPdf,
                ),
                IconButton(
                  icon: const Icon(Icons.save_alt, size: 20),
                  tooltip: 'Simpan ke Penyimpanan',
                  onPressed: onSaveToGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}