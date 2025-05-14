// lib/app/modules/asset_data/controllers/asset_detail_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/asset_model.dart';
import '../models/asset_history_model.dart';
import '../services/asset_service.dart';
import '../services/asset_history_service.dart';
import '../services/qr_code_service.dart';

class AssetDetailController extends GetxController {
  // Services
  final AssetService _assetService = Get.find<AssetService>();
  final AssetHistoryService _historyService = Get.find<AssetHistoryService>();
  final QrCodeService _qrCodeService = Get.find<QrCodeService>();
  final logger = Logger();

  // Observable variables
  final Rx<Asset?> asset = Rx<Asset?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAsset();
  }

  void loadAsset() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Check if asset is passed as argument
      if (Get.arguments != null && Get.arguments is Asset) {
        asset.value = Get.arguments as Asset;
        logger.i('Asset loaded from arguments: ${asset.value?.namaBarang ?? "Unknown"}');
      } 
      // Check if asset ID is passed as argument
      else if (Get.arguments != null && Get.arguments is int) {
        final assetId = Get.arguments as int;
        final loadedAsset = await _assetService.getAssetById(assetId.toString());
        if (loadedAsset != null) {
          asset.value = loadedAsset;
          logger.i('Asset loaded by ID: ${asset.value?.namaBarang ?? "Unknown"}');
        } else {
          throw Exception('Asset not found with ID: $assetId');
        }
      } 
      // Check if inventory number is passed as argument
      else if (Get.arguments != null && Get.arguments is String) {
        final inventoryNumber = Get.arguments as String;
        final assets = await _assetService.searchAsset(inventoryNumber);
        
        if (assets.isNotEmpty) {
          // Try to find exact match first
          Asset? matchingAsset;
          for (var a in assets) {
            if (a.noInventarisBarang == inventoryNumber) {
              matchingAsset = a;
              break;
            }
          }
          
          // If no exact match, use the first one
          asset.value = matchingAsset ?? assets.first;
          logger.i('Asset loaded by inventory number: ${asset.value?.namaBarang ?? "Unknown"}');
        } else {
          throw Exception('Asset not found with inventory number: $inventoryNumber');
        }
      } else {
        throw Exception('No asset or asset identifier provided');
      }
    } catch (e) {
      logger.e('Error loading asset: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void refreshAsset() {
    loadAsset();
  }

  void editAsset() {
    if (asset.value != null) {
      Get.toNamed('/asset-form', arguments: asset.value);
    } else {
      Get.snackbar(
        'Error',
        'Tidak ada aset untuk diedit',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void confirmDeleteAsset() {
    if (asset.value == null) {
      Get.snackbar(
        'Error',
        'Tidak ada aset untuk dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus aset ${asset.value?.namaBarang}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Get.back();
              deleteAsset();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void deleteAsset() async {
    if (asset.value == null || asset.value?.no == null) {
      Get.snackbar(
        'Error',
        'Tidak dapat menghapus aset: ID tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      final success = await _assetService.deleteAsset(asset.value!.no.toString());
      
      if (success) {
        Get.back(result: true); // Return to previous screen
        Get.snackbar(
          'Sukses',
          'Aset berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menghapus aset: ${_assetService.errorMessage.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      logger.e('Error deleting asset: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghapus aset: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to view asset history
  Future<void> viewAssetHistory() async {
  if (asset.value == null || asset.value?.no == null) {
    Get.snackbar(
      'Gagal',
      'Tidak ada aset yang dipilih untuk melihat riwayat',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  try {
    isLoading.value = true;
    
    // Get history for this asset
    final assetId = asset.value!.no ?? 0;
    // Add await here since getHistoryForAsset is likely async
    final histories = await _historyService.getHistoryForAsset(assetId);
    
    isLoading.value = false;
    
    // Show history dialog
    Get.dialog(
      AlertDialog(
        title: Text('Riwayat Aset: ${asset.value?.namaBarang ?? 'Tidak diketahui'}'),
        content: histories.isEmpty
            ? const Text('Tidak ada riwayat perubahan')
            : SizedBox(
                width: double.maxFinite,
                height: 400, // Fixed height for scrollable content
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final history = histories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          history.action,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${history.timestamp}\n'
                          'Oleh: ${history.userName ?? 'Tidak diketahui'}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            // Show change details
                            _showHistoryDetails(history);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  } catch (e) {
    isLoading.value = false;
    logger.e('Error fetching asset history: $e');
    Get.snackbar(
      'Error',
      'Terjadi kesalahan saat mengambil riwayat: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

  // Method to show history details
  // Method to show history details
void _showHistoryDetails(AssetHistoryModel history) {
  Get.dialog(
    AlertDialog(
      title: Text('Detail Riwayat ${history.action}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Waktu: ${history.getFormattedDate()}'),
            Text('Aksi: ${history.action}'),
            Text('Pengguna: ${history.userName ?? 'Tidak diketahui'}'),
            Text('Aset: ${history.assetName}'),
            const SizedBox(height: 16),
            const Text(
              'Perubahan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (history.changedFields.isEmpty)
              const Text('Tidak ada perubahan spesifik'),
            ...history.changedFields.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_getFieldDisplayName(entry.key)}: '
                  '${entry.value['old'] ?? 'Kosong'} → '
                  '${entry.value['new'] ?? 'Kosong'}',
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

// Helper untuk mendapatkan nama tampilan dari nama field
String _getFieldDisplayName(String fieldName) {
  switch (fieldName) {
    case 'namaBarang': return 'Nama Barang';
    case 'merk': return 'Merk';
    case 'type': return 'Type';
    case 'serialNumber': return 'Serial Number';
    case 'nip': return 'NIP';
    case 'namaPengguna': return 'Nama Pengguna';
    case 'unit': return 'Unit';
    case 'bidang': return 'Bidang';
    case 'subBidang': return 'Sub Bidang';
    case 'namaRuangan': return 'Nama Ruangan';
    case 'noInventarisBarang': return 'No Inventaris Barang';
    case 'noAktiva': return 'No Aktiva';
    case 'jumlah': return 'Jumlah';
    case 'kondisi': return 'Kondisi';
    case 'kategori': return 'Kategori';
    default: return fieldName.replaceFirst(fieldName[0], fieldName[0].toUpperCase());
  }
}
  
  // Method to show QR code dialog
  Future<void> showQrCodeDialog() async {
    if (asset.value == null) {
      Get.snackbar(
        'Error',
        'Tidak ada aset untuk ditampilkan QR code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      String? qrPath = asset.value!.qrCodePath;
      
      // If QR path is empty or null, generate a new one
      if (qrPath == null || qrPath.isEmpty) {
        qrPath = await _qrCodeService.generateQrCode(asset.value!);
        
        if (qrPath == null) {
          throw Exception('Failed to generate QR code');
        }
        
        // Update asset with new QR path
        final updatedAsset = asset.value!.copyWith(qrCodePath: qrPath);
        final success = await _assetService.updateAsset(updatedAsset);
        
        if (success) {
          asset.value = updatedAsset;
          logger.i('Asset updated with new QR code path');
        } else {
          logger.w('Failed to update asset with QR code path');
          // Continue showing the QR code dialog even if update fails
        }
      }
      // If QR path is a URL, download it
      else if (qrPath.startsWith('http')) {
        final localPath = await _qrCodeService.downloadQrCodeFromSupabase(
          qrPath, 
          asset.value!.noInventarisBarang ?? 'unknown'
        );
        
        if (localPath != null) {
          qrPath = localPath;
        } else {
          throw Exception('Failed to download QR code');
        }
      }
      
      isLoading.value = false;
      
      // Show QR code dialog
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
                        'QR Code: ${asset.value?.namaBarang ?? "Unnamed Asset"}',
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
                            asset.value!.noInventarisBarang ?? 'No Inv: -',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (asset.value!.namaBarang != null)
                            Text(asset.value!.namaBarang!),
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
                              await _downloadAsPdf(asset.value!, qrPath!);
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
                              await _saveToGallery(qrPath!);
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
    } catch (e) {
      isLoading.value = false;
      logger.e('Error showing QR code dialog: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menampilkan QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
}