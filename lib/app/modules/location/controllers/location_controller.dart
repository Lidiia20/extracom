import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../asset_data/models/asset_model.dart';
import '../../asset_data/providers/asset_api_provider.dart';
import '../../asset_data/services/asset_service.dart';

class LocationController extends GetxController {
  final AssetService _assetService = Get.find<AssetService>();
  final AssetApiProvider _apiProvider = Get.find<AssetApiProvider>();
  final logger = Logger(); // Add logger instance
  
  // Bidang/lokasi dari database - inisialisasi kosong dulu
  final RxList<String> _locations = <String>[].obs;
  
  final RxString selectedLocation = ''.obs;
  final RxList<Asset> locationAssets = <Asset>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Default locations to use when database returns nulls
  final List<String> defaultLocations = [
    'BIDANG KKU',
    'BIDANG PST',
    'BIDANG HARTRANS',
    'BIDANG REN',
    'GM'
  ];
  
  // Getter that provides safe locations list (filtered and with defaults)
  List<String> get locations {
    // If _locations is empty or contains only nulls, return default values
    if (_locations.isEmpty || 
        _locations.every((item) => item == null || item.isEmpty)) {
      return defaultLocations;
    }
    
    // Otherwise filter out null values
    return _locations
        .where((item) => item != null && item.isNotEmpty)
        .toList();
  }
  
  @override
  void onInit() {
    super.onInit();
    logger.i('LocationController initialized');
    // Muat bidang dari database
    loadLocationsFromDatabase();
  }
  
  // Function to load locations/bidang directly from database
  Future<void> loadLocationsFromDatabase() async {
    try {
      logger.i('Loading bidang directly from database');
      final response = await _apiProvider.getBidangList();
      
      // Log the raw response for debugging
      logger.i('Raw bidang response: $response');
      
      if (response['status'] == 'success') {
        final bidangList = response['bidang_list'];
        logger.i('Raw bidang data: $bidangList');
        
        // Filter out null values before adding to _locations
        final List<String> validBidangList = [];
        
        if (bidangList != null && bidangList is List) {
          for (var item in bidangList) {
            if (item != null && item.toString().isNotEmpty) {
              validBidangList.add(item.toString());
            }
          }
        }
        
        // If we have valid items, use them; otherwise use default locations
        if (validBidangList.isNotEmpty) {
          _locations.assignAll(validBidangList);
          logger.i('Loaded ${validBidangList.length} bidang items from database');
        } else {
          _locations.assignAll(defaultLocations);
          logger.w('No valid bidang items found in database, using defaults');
        }
        
        logger.i('Bidang items: ${_locations.join(", ")}');
        
        // Set initial location if not set yet
        if (selectedLocation.value.isEmpty) {
          if (locations.isNotEmpty) {
            selectedLocation.value = locations.first;
            logger.i('Setting initial location to: ${selectedLocation.value}');
          }
        }
      } else {
        // If API returns error, use default locations
        _locations.assignAll(defaultLocations);
        logger.w('Failed to load locations: ${response['message']}');
        
        // Set initial location if not set yet
        if (selectedLocation.value.isEmpty) {
          selectedLocation.value = defaultLocations.first;
        }
      }
    } catch (e) {
      // If any error occurs, use default locations
      _locations.assignAll(defaultLocations);
      logger.e('Error loading locations: $e');
      
      // Set initial location if not set yet
      if (selectedLocation.value.isEmpty) {
        selectedLocation.value = defaultLocations.first;
      }
    }
  }
  
  // Function to load assets for selected location
  Future<void> loadAssetsByLocation([String? location]) async {
  isLoading.value = true;
  hasError.value = false;
  errorMessage.value = '';
  locationAssets.clear(); // Clear existing assets
  
  try {
    // Use provided location or currently selected location
    final String locationToUse = location ?? selectedLocation.value;
    
    // If location is empty, use first available location or default
    final String validLocation = locationToUse.isNotEmpty
        ? locationToUse
        : (locations.isNotEmpty ? locations.first : defaultLocations.first);
    
    // Update selected location if different
    if (selectedLocation.value != validLocation) {
      selectedLocation.value = validLocation;
    }
    
    logger.i('Fetching assets for location/bidang: $validLocation');
    
    // Debug the query before sending it
    logger.i('About to query database for bidang = $validLocation');
    
    // Gunakan langsung dari Supabase untuk mendapatkan data terbaru
    final response = await _apiProvider.getAssetsByLocation(validLocation);
    logger.i('Raw assets by location response: $response');
    
    if (response['status'] == 'success') {
      final List<dynamic> assetsData = response['assets'];
      logger.i('Received ${assetsData.length} assets from API');
      
      // Log all asset IDs for debugging
      if (assetsData.isNotEmpty) {
        final assetIds = assetsData.map((a) => a['id'] ?? 'unknown').toList();
        logger.i('Asset IDs: $assetIds');
      }
      
      final List<Asset> assets = [];
      
      // Parsing data aset ke model
      int successCount = 0;
      int errorCount = 0;
      
      for (var assetData in assetsData) {
        try {
          logger.d('Parsing asset: ${assetData['nama_barang'] ?? assetData['namaBarang'] ?? 'Unknown'}');
          final asset = Asset.fromJson(assetData);
          assets.add(asset);
          successCount++;
        } catch (e) {
          logger.e('Error parsing asset: $e');
          logger.e('Problematic data: $assetData');
          errorCount++;
        }
      }
      
      logger.i('Successfully parsed $successCount assets, $errorCount failed');
      locationAssets.value = assets;
      
      // Debug log
      logger.i('Found ${locationAssets.length} assets for location: $validLocation');
      if (locationAssets.isNotEmpty) {
        logger.i('Sample asset name: ${locationAssets.first.namaBarang}');
      } else {
        logger.w('No assets found for location: $validLocation');
        // Try to identify why no assets were found
        try {
          // Check if the Asset model's fromJson method might be failing
          if (assetsData.isNotEmpty) {
            final sampleAsset = assetsData.first;
            logger.i('Sample raw asset data: $sampleAsset');
            final fieldNames = sampleAsset.keys.toList();
            logger.i('Available fields: $fieldNames');
            
            // Check for expected fields
            final hasId = sampleAsset.containsKey('id');
            final hasNamaBarang = sampleAsset.containsKey('nama_barang') || 
                                 sampleAsset.containsKey('namaBarang');
            final hasBidang = sampleAsset.containsKey('bidang');
            
            logger.i('Field existence - id: $hasId, namaBarang: $hasNamaBarang, bidang: $hasBidang');
          }
        } catch (e) {
          logger.e('Error during debug: $e');
        }
      }
    } else {
      hasError.value = true;
      errorMessage.value = 'Error: ${response['message']}';
      logger.e('Error response from API: ${response['message']}');
    }
  } catch (e) {
    hasError.value = true;
    errorMessage.value = 'Error: ${e.toString()}';
    logger.e('Error in loadAssetsByLocation: $e');
    logger.e('Stack trace: ${StackTrace.current}');
  } finally {
    isLoading.value = false;
  }
}
  
  // Change selected location and load assets
  void changeLocation(String location) {
    if (location != selectedLocation.value) {
      logger.i('Location changed to: $location');
      loadAssetsByLocation(location);
    }
  }
}