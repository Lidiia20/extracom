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
  
  // Tab Controller
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    
    // Inisialisasi tab controller dengan 2 tab (Elektronik dan Furniture)
    tabController = TabController(length: 2, vsync: this);
    
    // Load data aset kategori pertama (Elektronik) saat halaman dibuka
    loadAssetsByCategory('Elektronik');
    
    // Listener untuk perubahan tab
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentTabIndex.value = tabController.index;
        loadAssetsByCategory(currentTabIndex.value == 0 ? 'Elektronik' : 'Furniture');
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Memuat aset berdasarkan kategori
  Future<void> loadAssetsByCategory(String category) async {
    isLoading.value = true;
    try {
      // Reset daftar aset
      assets.clear();
      
      // Fetch semua aset dari service
      await _assetService.fetchAssets();
      
      // Filter berdasarkan kategori
      final allAssets = _assetService.assets;
      assets.value = allAssets.where((asset) => 
        asset.kategori == category
      ).toList();
      
      Get.log('Loaded ${assets.length} assets with category $category');
    } catch (e) {
      Get.log('Error loading assets by category: $e');
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
}