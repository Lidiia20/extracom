import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../asset_data/models/asset_model.dart';
import '../../asset_data/services/asset_service.dart';

class CategoryController extends GetxController with GetSingleTickerProviderStateMixin {
  final AssetService _assetService = Get.find<AssetService>();
  
  // Status
  final isLoading = false.obs;
  final assets = <Asset>[].obs;
  final currentTabIndex = 0.obs;
  final categories = ['Elektronik', 'Furnitur'].obs;
  
  
  // Tab Controller
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    
    // Inisialisasi tab controller dengan 2 tab (Elektronik dan Furniture)
    tabController = TabController(length: categories.length, vsync: this);
    
    // Load semua data aset terlebih dahulu
    fetchAllAssets();
    
    // Listener untuk perubahan tab
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentTabIndex.value = tabController.index;
        loadAssetsByCategory(categories[currentTabIndex.value]);
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Memuat semua data aset dari service
  Future<void> fetchAllAssets() async {
    isLoading.value = true;
    try {
      await _assetService.fetchAssets();
      // Setelah data dimuat, filter berdasarkan kategori awal
      loadAssetsByCategory(categories[currentTabIndex.value]);
    } catch (e) {
      Get.log('Error fetching all assets: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data aset: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Memuat aset berdasarkan kategori
  void loadAssetsByCategory(String category) {
    try {
      // Reset daftar aset
      assets.clear();
      
      // Memeriksa apakah service sudah memiliki data
      final allAssets = _assetService.assets;
      if (allAssets.isEmpty) {
        Get.log('No assets found in service');
        return;
      }
      
      // Debug: print all assets categories for troubleshooting
      final availableCategories = allAssets.map((e) => e.kategori).toSet().toList();
      Get.log('Available categories: $availableCategories');
      
      // Filter berdasarkan kategori yang sesuai
      final filteredAssets = allAssets.where((asset) {
        // Untuk debugging
        Get.log('Asset kategori: ${asset.kategori}, comparing with: $category');
        
        return asset.kategori == category;
      }).toList();
      
      // Update observable list
      assets.assignAll(filteredAssets);
      
      Get.log('Loaded ${assets.length} assets with category $category');
    } catch (e) {
      Get.log('Error loading assets by category: $e');
      Get.snackbar(
        'Error',
        'Gagal memfilter data aset: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Method untuk refresh data
  Future<void> refreshData() async {
    await fetchAllAssets();
  }
  Future<void> fetchCategories() async {
  try {
    await _assetService.fetchAssets();
    final allAssets = _assetService.assets;
    categories.value = allAssets.map((e) => e.kategori).whereType<String>().toSet().toList();
    // Update tab controller jika jumlah kategori berubah
    if (tabController.length != categories.length) {
      tabController.dispose();
      tabController = TabController(length: categories.length, vsync: this);
    }
  } catch (e) {
    Get.log('Error fetching categories: $e');
  }
}
}