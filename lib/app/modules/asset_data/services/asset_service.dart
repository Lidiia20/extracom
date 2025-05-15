import 'package:get/get.dart';
import '../../../../main.dart';
import '../models/asset_model.dart';
import '../providers/asset_api_provider.dart';


class AssetService extends GetxService {
  

  final AssetApiProvider _apiProvider = Get.find<AssetApiProvider>();
  
  final RxList<Asset> assets = <Asset>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Method init untuk registrasi dengan GetX
  Future<bool> fetchAssets() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      print('Fetching assets from Supabase table: aset');
      
      final response = await _apiProvider.getAssets();
      
      if (response['status'] == 'success') {
        final List<dynamic> assetsData = response['assets'] ?? [];
        
        // Debug info
        print('Raw assets count: ${assetsData.length}');
        if (assetsData.isNotEmpty) {
          print('Sample asset data: ${assetsData[0].keys.toList()}');
          print('Sample asset values: ${assetsData[0]}');
        }
        
        // Clear existing assets
        assets.clear();
        
        // Process and add assets to the list
        for (var assetData in assetsData) {
          try {
            final asset = Asset.fromJson(assetData);
            assets.add(asset);
          } catch (e) {
            print('Error parsing asset: $e');
            print('Problematic data: $assetData');
          }
        }
        
        print('Successfully parsed ${assets.length} assets');
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Unknown error';
        print('Error response: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Exception in fetchAssets: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

// Modifikasi juga di getAssetById
Future<Asset?> getAssetById(String id) async {
  isLoading.value = true;
  errorMessage.value = '';
  try {
    print('Getting asset by ID: $id');
    final response = await _apiProvider.getAssetById(id);
    if (response['status'] == 'success') {
      final assetData = response['asset'];
      isLoading.value = false;
      print('Asset found: ${assetData['namaBarang']}');
      return Asset.fromJson(assetData);
    } else {
      errorMessage.value = response['message'] ?? 'Asset not found';
      print('Asset not found: ${errorMessage.value}');
      isLoading.value = false;
      return null;
    }
  } catch (e) {
    errorMessage.value = 'Error: $e';
    print('Error getting asset by ID: $e');
    isLoading.value = false;
    return null;
  }
}

  // Menambah aset dengan nota
  Future<Map<String, dynamic>> addAssetWithNota(Map<String, dynamic> assetData) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print('Adding new asset with nota');
      final response = await _apiProvider.addAsset(assetData);
      if (response['status'] == 'success') {
        print('Asset with nota added successfully');
        await fetchAssets();
        isLoading.value = false;
        return {
          'success': true,
          'message': 'Asset with nota added successfully',
          'assetId': response['assetId']
        };
      } else {
        errorMessage.value = response['message'] ?? 'Failed to add asset';
        print('Failed to add asset with nota: ${errorMessage.value}');
        isLoading.value = false;
        return {
          'success': false,
          'message': errorMessage.value
        };
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error adding asset with nota: $e');
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  // Memperbarui aset
  Future<bool> updateAsset(Asset asset) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print('Updating asset: ${asset.namaBarang} (${asset.no})');
      final response = await _apiProvider.updateAsset(asset.toJsonForInsert());
      if (response['status'] == 'success') {
        print('Asset updated successfully');
        int index = assets.indexWhere((item) => item.no == asset.no);
        if (index != -1) {
          assets[index] = asset;
        }
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to update asset';
        print('Failed to update asset: ${errorMessage.value}');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error updating asset: $e');
      isLoading.value = false;
      return false;
    }
  }

  // Menghapus aset
  Future<bool> deleteAsset(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print('Deleting asset with ID: $id');
      final response = await _apiProvider.deleteAsset(id);
      if (response['status'] == 'success') {
        print('Asset deleted successfully');
        assets.removeWhere((asset) => asset.no.toString() == id);
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to delete asset';
        print('Failed to delete asset: ${errorMessage.value}');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error deleting asset: $e');
      isLoading.value = false;
      return false;
    }
  }

  // Mencari aset
  Future<List<Asset>> searchAsset(String query) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print('Searching for assets with query: $query');
      final response = await _apiProvider.searchAsset(query);
      if (response['status'] == 'success') {
        final List<dynamic> assetList = response['assets'];
        final results = assetList.map((json) => Asset.fromJson(json)).toList();
        print('Found ${results.length} assets matching query');
        isLoading.value = false;
        return results;
      } else {
        errorMessage.value = response['message'] ?? 'Search failed';
        print('Search failed: ${errorMessage.value}');
        isLoading.value = false;
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error searching assets: $e');
      isLoading.value = false;
      return [];
    }
  }

  // Metode Tambah Asset 
Future<bool> addAsset(Asset asset) async {
  isLoading.value = true;
  errorMessage.value = '';
  try {
    print('Adding new asset: ${asset.namaBarang}');
    final response = await _apiProvider.addAsset(asset.toJsonForInsert());
    if (response['status'] == 'success') {
      print('Asset added successfully');
      await fetchAssets(); // Ambil ulang daftar aset
      isLoading.value = false;
      return true;
    } else {
      errorMessage.value = response['message'] ?? 'Failed to add asset';
      print('Failed to add asset: ${errorMessage.value}');
      isLoading.value = false;
      return false;
    }
  } catch (e) {
    errorMessage.value = 'Error: $e';
    print('Error adding asset: $e');
    isLoading.value = false;
    return false;
  }
}

  // Mendapatkan aset berdasarkan kategori
  Future<List<Asset>> getAssetsByCategory(String category) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiProvider.getAssetsByCategory(category);
      if (response['status'] == 'success') {
        final List<dynamic> assetList = response['dropdown_options'];
        print('Found ${assetList.length} assets for category: $category');
        return assetList.map((json) => Asset.fromJson(json)).toList();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to get assets by category';
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error getting assets by category: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mendapatkan aset berdasarkan lokasi
 Future<List<Asset>> getAssetsByLocation(String location) async {
    try {
      print('Getting assets for location: $location');
      
      // If assets are not loaded yet, load them
      if (assets.isEmpty) {
        print('Assets list is empty, fetching assets first');
        await fetchAssets();
      }
      
      // Filter assets by bidang
      final locationAssets = assets
          .where((asset) => asset.bidang?.trim().toUpperCase() == location.trim().toUpperCase())
          .toList();
      
      print('Filtered ${locationAssets.length} assets for location: $location');
      
      // Debug info
      if (locationAssets.isNotEmpty) {
        print('First asset in location: ${locationAssets[0].namaBarang}');
      }
      
      // Additional debug to see all bidang values
      final bidangValues = assets.map((asset) => asset.bidang?.trim().toUpperCase() ?? 'NULL').toSet().toList();
      print('All bidang values in assets: $bidangValues');
      
      return locationAssets;
    } catch (e) {
      errorMessage.value = 'Error getting assets by location: $e';
      print('Exception in getAssetsByLocation: $e');
      return [];
    }
  }
  // Future<List<Asset>> getAssetsByLocation(String location) async {
  //   isLoading.value = true;
  //   errorMessage.value = '';
  //   try {
  //     print('Getting assets by location: $location');
  //     final response = await _apiProvider.getAssetsByLocation(location);
  //     if (response['status'] == 'success') {
  //       final List<dynamic> assetList = response['assets'];
  //       final results = assetList.map((json) => Asset.fromJson(json)).toList();
  //       print('Found ${results.length} assets in location: $location');
  //       isLoading.value = false;
  //       return results;
  //     } else {
  //       errorMessage.value = response['message'] ?? 'Failed to get assets by location';
  //       print('Failed to get assets by location: ${errorMessage.value}');
  //       isLoading.value = false;
  //       return [];
  //     }
  //   } catch (e) {
  //     errorMessage.value = 'Error: $e';
  //     print('Error getting assets by location: $e');
  //     isLoading.value = false;
  //     return [];
  //   }
  // }

  // Add this method to your AssetService class

// Mendapatkan aset berdasarkan kondisi
// Mendapatkan aset berdasarkan kondisi
Future<List<Asset>> getAssetsByCondition(String condition) async {
  isLoading.value = true;
  errorMessage.value = '';
  try {
    print('Getting assets by condition: $condition');
    
    // If we already have assets loaded locally, filter them by condition
    if (assets.isNotEmpty) {
      final results = assets.where((asset) => asset.kondisi == condition).toList();
      print('Found ${results.length} assets with condition: $condition');
      isLoading.value = false;
      return results;
    }
    
    // Otherwise fetch all assets first
    final success = await fetchAssets();
    if (success) {
      final results = assets.where((asset) => asset.kondisi == condition).toList();
      print('Found ${results.length} assets with condition: $condition');
      isLoading.value = false;
      return results;
    } else {
      errorMessage.value = 'Failed to fetch assets';
      print('Failed to fetch assets for condition filtering: ${errorMessage.value}');
      isLoading.value = false;
      return [];
    }
  } catch (e) {
    errorMessage.value = 'Error: $e';
    print('Error getting assets by condition: $e');
    isLoading.value = false;
    return [];
  }
}
// Mendapatkan semua aset yang sudah di-fetch sebelumnya
// Mendapatkan semua aset yang sudah di-fetch sebelumnya
List<Asset> getAllAssets() {
  // Jika assets kosong, sebaiknya fetch dulu
  if (assets.isEmpty) {
    // Lakukan log tapi jangan block proses
    Get.log('Warning: Calling getAllAssets when assets is empty. Consider calling fetchAssets first.');
    
    // Alternatif 1: Return list kosong
    // return [];
    
    // Alternatif 2: Mencoba fetch secara sinkron (tidak disarankan, lebih baik gunakan fetchAssets() yang async)
    // fetchAssets();
  }
  
  // Mengembalikan salinan dari list assets
  return assets.toList();
}

// Mendapatkan semua aset dengan QR code
List<Asset> getAssetsWithQrCode() {
  // Filter assets yang memiliki QR code path
  return assets.where((asset) => 
    asset.qrCodePath != null && 
    asset.qrCodePath!.isNotEmpty
  ).toList();
}

// Mendapatkan aset berdasarkan filter
List<Asset> filterAssets({
  String? kategori,
  String? kondisi,
  String? lokasi,
  String? pengguna
}) {
  return assets.where((asset) {
    bool match = true;
    
    if (kategori != null && kategori.isNotEmpty) {
      match = match && asset.kategori == kategori;
    }
    
    if (kondisi != null && kondisi.isNotEmpty) {
      match = match && asset.kondisi == kondisi;
    }
    
    if (lokasi != null && lokasi.isNotEmpty) {
      match = match && asset.namaRuangan == lokasi;
    }
    
    if (pengguna != null && pengguna.isNotEmpty) {
      match = match && asset.namaPengguna == pengguna;
    }
    
    return match;
  }).toList();
}
}