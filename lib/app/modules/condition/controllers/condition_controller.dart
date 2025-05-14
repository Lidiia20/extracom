import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../asset_data/models/asset_model.dart';
import '../../asset_data/services/asset_service.dart';

class ConditionController extends GetxController {
  final AssetService _assetService = Get.find<AssetService>();
  
  final RxList<String> conditions = <String>[
    'Layak Pakai',
    'Sudah Lama',
    'Rusak',
  ].obs;
  
  final RxString selectedCondition = ''.obs;
  final RxList<Asset> conditionAssets = <Asset>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Statistics for dashboard display
  final RxInt totalLayakPakai = 0.obs;
  final RxInt totalSudahLama = 0.obs;
  final RxInt totalRusak = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchConditionStatistics();
  }
  
  // Load statistics for all conditions
  Future<void> fetchConditionStatistics() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      // Fetch all assets and count by condition
      final allAssets = await _assetService.fetchAssets();
      
      if (allAssets) {
        // Reset counters
        totalLayakPakai.value = 0;
        totalSudahLama.value = 0;
        totalRusak.value = 0;
        
        // Count assets by condition
        for (var asset in _assetService.assets) {
          if (asset.kondisi == 'Layak Pakai') {
            totalLayakPakai.value++;
          } else if (asset.kondisi == 'Sudah Lama') {
            totalSudahLama.value++;
          } else if (asset.kondisi == 'Rusak') {
            totalRusak.value++;
          }
        }
        
        print('Statistics - Layak Pakai: ${totalLayakPakai.value}, Sudah Lama: ${totalSudahLama.value}, Rusak: ${totalRusak.value}');
      } else {
        hasError.value = true;
        errorMessage.value = _assetService.errorMessage.value;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: ${e.toString()}';
      print('Error fetching condition statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Function to load assets for selected condition
  Future<void> loadAssetsByCondition(String condition) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    selectedCondition.value = condition;
    
    try {
      final results = await _assetService.getAssetsByCondition(condition);
      
      conditionAssets.value = results;
      
      if (_assetService.errorMessage.isNotEmpty) {
        hasError.value = true;
        errorMessage.value = _assetService.errorMessage.value;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: ${e.toString()}';
      print('Error in loadAssetsByCondition: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Change selected condition and load assets
  void changeCondition(String condition) {
    if (condition != selectedCondition.value) {
      loadAssetsByCondition(condition);
    }
  }
}