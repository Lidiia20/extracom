import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add QR code package
import '../models/asset_model.dart';
import '../services/asset_service.dart';
import '../providers/asset_api_provider.dart';
import '../views/qr_display_view.dart'; // Import QR display view

class AssetDataController extends GetxController {
  // Services & Providers
  final AssetApiProvider apiProvider = AssetApiProvider();
  final AssetService assetService = Get.put(AssetService());
  final TextEditingController searchController = TextEditingController();
  final logger = Logger(); // Add logger instance
  
  // Observable variables
  final RxList<Asset> assets = <Asset>[].obs;
  final RxList<Asset> filteredAssets = <Asset>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    logger.i('AssetDataController initialized'); // Use logger instead of print
    loadAssets();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  Future<void> loadAssets() async {
    if (isLoading.value) return; // Prevent multiple simultaneous loads
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      logger.i('Fetching assets from Supabase table: aset'); // Use logger instead of print
      final success = await assetService.fetchAssets();
      
      if (success) {
        assets.assignAll(assetService.assets); // More efficient than .value =
        filteredAssets.assignAll(assets);
        
        // Debug logs using logger
        logger.i('Assets loaded: ${assets.length}');
        if (assets.isNotEmpty) {
          logger.d('Sample asset data: ${assets.first.toJsonForInsert().keys.toList()}');
          logger.d('Sample asset values: ${assets.first.toJsonForInsert()}');
        } else {
          logger.w('No assets loaded from database');
        }
        
        // Periksa apakah data bidang sudah benar
        final bidangCounts = <String, int>{};
        for (final asset in assets) {
          if (asset.bidang != null && asset.bidang!.isNotEmpty) {
            bidangCounts[asset.bidang!] = (bidangCounts[asset.bidang!] ?? 0) + 1;
          }
        }
        logger.d('Bidang distribution: $bidangCounts');
        
      } else {
        errorMessage.value = assetService.errorMessage.value;
        logger.e('Error from service: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      logger.e('Exception in loadAssets: $e');
      
      // Tambahan: coba tangkap error lebih detail
      logger.e('Stacktrace: ${StackTrace.current}');
    } finally {
      isLoading.value = false;
    }
  }
  
  void filterAssets(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredAssets.assignAll(assets);
      return;
    }
    
    final searchLower = query.toLowerCase();
    final filtered = assets.where((asset) {
      // Combine property checks for more readable code
      final searchableProperties = [
        asset.namaBarang,
        asset.merk,
        asset.type,
        asset.serialNumber,
        asset.noInventarisBarang,
        asset.namaPengguna,
        asset.unit,
        asset.namaRuangan,
        asset.bidang,           // Tambahkan bidang sebagai searchable property
        asset.subBidang,        // Tambahkan sub_bidang sebagai searchable property
        asset.nip?.toString(),  // Convert nip (String) to searchable
      ].map((prop) => prop?.toLowerCase() ?? '');
      
      // Check if any property contains the search query
      return searchableProperties.any((prop) => prop.contains(searchLower));
    }).toList();
    
    filteredAssets.assignAll(filtered);
    
    // Debug log with logger
    logger.d('Query: "$query", Found: ${filteredAssets.length}');
  }
  
  Future<void> refreshAssets() async {
    searchController.clear();
    searchQuery.value = '';
    await loadAssets();
  }
  
  // Add method to handle new asset creation with QR code generation
  void onAssetCreated(Asset newAsset) {
    logger.i('New asset created: ${newAsset.namaBarang}');
    
    // Generate QR code data - use the most unique identifier available
    final String qrData = _generateQRData(newAsset);
    
    // Navigate to QR display view with the new asset and QR data
    Get.to(() => QRDisplayView(asset: newAsset, qrData: qrData));
  }
  
  // Helper method to generate QR code data based on asset properties
  String _generateQRData(Asset asset) {
    // Prioritize identifiers: noInventarisBarang, serialNumber, or constructed ID
    final String assetId = asset.noInventarisBarang ?? 
                          asset.serialNumber ?? 
                          'ASSET-${asset.no ?? asset.id ?? DateTime.now().millisecondsSinceEpoch}';
    
    // Create a map of essential asset information
    final Map<String, dynamic> qrMap = {
      'id': assetId,
      'name': asset.namaBarang ?? 'Unknown Asset',
      'merk': asset.merk ?? '-',
      'type': asset.type ?? '-',
      'user': asset.namaPengguna ?? '-',
      'location': asset.namaRuangan ?? '-',
      'bidang': asset.bidang ?? '-',
    };
    
    // Convert map to JSON string for QR code
    return qrMap.toString();
  }
  
  Future<bool> deleteAsset(Asset asset) async {
    if (isLoading.value) return false;
    
    try {
      isLoading.value = true;
      
      // Determine asset ID for deletion
      final String assetId = asset.no?.toString() ?? asset.id?.toString() ?? '';
      
      if (assetId.isEmpty) {
        throw Exception('ID aset tidak valid');
      }
      
      final success = await assetService.deleteAsset(assetId);
      
      if (success) {
        // Remove from lists efficiently with proper ID check
        if (asset.no != null) {
          assets.removeWhere((item) => item.no == asset.no);
          filteredAssets.removeWhere((item) => item.no == asset.no);
        } else if (asset.id != null) {
          assets.removeWhere((item) => item.id == asset.id);
          filteredAssets.removeWhere((item) => item.id == asset.id);
        }
        
        Get.snackbar(
          'Sukses',
          'Aset berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        return true;
      } else {
        Get.snackbar(
          'Gagal',
          assetService.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        return false;
      }
    } catch (e) {
      logger.e('Error deleting asset: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  void confirmDeleteAsset(Asset asset) {
    final assetName = asset.namaBarang ?? 'Aset';
    final assetNumber = asset.noInventarisBarang ?? '';
    
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus aset $assetName${assetNumber.isNotEmpty ? " - $assetNumber" : ""}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await deleteAsset(asset);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}