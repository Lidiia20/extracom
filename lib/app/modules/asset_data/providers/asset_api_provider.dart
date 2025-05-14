// lib/app/modules/asset_data/providers/asset_api_provider.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_model.dart';

class AssetApiProvider extends GetxService {
  final logger = Logger();
  final supabase = Supabase.instance.client;
  
  // Get all assets
  Future<Map<String, dynamic>> getAssets() async {
    try {
      logger.i('Fetching assets from Supabase');

      final response = await supabase.from('aset').select('*');

      if (response == null || response.isEmpty) {
        logger.e('No assets found');
        return {
          'status': 'error',
          'message': 'Tidak ada data yang ditemukan',
        };
      }

      logger.i('Successfully fetched ${response.length} assets');
      return {
        'status': 'success',
        'assets': response,
      };
    } catch (e) {
      logger.e('Exception getting assets: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Get single asset by ID (int version)
  Future<Map<String, dynamic>> getAsset(int id) async {
    try {
      logger.i('Fetching asset with ID: $id');
      
      final response = await supabase
          .from('aset')
          .select('*')
          .eq('id', id)
          .single();
      
      if (response == null) {
        logger.e('Asset not found with ID: $id');
        return {
          'status': 'error',
          'message': 'Aset tidak ditemukan',
        };
      }
      
      return {
        'status': 'success',
        'asset': response,
      };
    } catch (e) {
      logger.e('Exception getting asset: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Get asset by ID (string version)
  Future<Map<String, dynamic>> getAssetById(String id) async {
    try {
      logger.i('Fetching asset with String ID: $id');
      
      final response = await supabase
          .from('aset')
          .select('*')
          .eq('id', id)
          .single();
      
      if (response == null) {
        logger.e('Asset not found with ID: $id');
        return {
          'status': 'error',
          'message': 'Aset tidak ditemukan',
        };
      }
      
      return {
        'status': 'success',
        'asset': response,
      };
    } catch (e) {
      logger.e('Exception in getAssetById: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Add new asset
  Future<Map<String, dynamic>> addAsset(Map<String, dynamic> assetData) async {
    try {
      logger.i('Adding new asset: ${assetData['namaBarang'] ?? assetData['nama_barang'] ?? 'Unknown'}');
      
      // Standardize field names if needed (camelCase to snake_case)
      final standardizedData = _standardizeFieldNames(assetData);
      
      final response = await supabase
          .from('aset')
          .insert(standardizedData)
          .select();
      
      if (response == null || response.isEmpty) {
        logger.e('Failed to add asset');
        return {
          'status': 'error',
          'message': 'Gagal menambahkan aset',
        };
      }
      
      logger.i('Asset added successfully with ID: ${response[0]['id']}');
      return {
        'status': 'success',
        'asset': response[0],
        'assetId': response[0]['id'],
      };
    } catch (e) {
      logger.e('Exception adding asset: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Update existing asset with id and data
  Future<Map<String, dynamic>> updateAssetById(int id, Map<String, dynamic> assetData) async {
    try {
      logger.i('Updating asset with ID: $id');
      
      // Standardize field names if needed (camelCase to snake_case)
      final standardizedData = _standardizeFieldNames(assetData);
      
      // Remove id from update data to avoid conflicts
      standardizedData.remove('id');
      
      final response = await supabase
          .from('aset')
          .update(standardizedData)
          .eq('id', id)
          .select();
      
      if (response == null || response.isEmpty) {
        logger.e('Failed to update asset');
        return {
          'status': 'error',
          'message': 'Gagal memperbarui aset',
        };
      }
      
      logger.i('Asset updated successfully');
      return {
        'status': 'success',
        'asset': response[0],
      };
    } catch (e) {
      logger.e('Exception updating asset: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Update asset dengan memberikan langsung assetData
  Future<Map<String, dynamic>> updateAsset(Map<String, dynamic> assetData) async {
    try {
      // Pastikan ada id asset dalam data
      final assetId = assetData['id'];
      if (assetId == null) {
        logger.e('Asset ID tidak ditemukan dalam data');
        return {
          'status': 'error',
          'message': 'Asset ID tidak ditemukan dalam data',
        };
      }
      
      logger.i('Updating asset with ID: $assetId');
      
      // Standardize field names if needed (camelCase to snake_case)
      final standardizedData = _standardizeFieldNames(assetData);
      
      final response = await supabase
          .from('aset')
          .update(standardizedData)
          .eq('id', assetId)
          .select();
      
      if (response == null || response.isEmpty) {
        logger.e('Failed to update asset');
        return {
          'status': 'error',
          'message': 'Gagal memperbarui aset',
        };
      }
      
      logger.i('Asset updated successfully');
      return {
        'status': 'success',
        'asset': response[0],
      };
    } catch (e) {
      logger.e('Exception in updateAsset: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Delete asset (int version)
  Future<Map<String, dynamic>> deleteAssetById(int id) async {
    try {
      logger.i('Deleting asset with ID: $id');
      
      await supabase.from('aset').delete().eq('id', id);
      
      logger.i('Asset deleted successfully');
      return {
        'status': 'success',
        'message': 'Asset deleted successfully',
      };
    } catch (e) {
      logger.e('Exception deleting asset: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Delete asset dari string ID
  Future<Map<String, dynamic>> deleteAsset(String id) async {
    try {
      logger.i('Deleting asset with String ID: $id');
      
      await supabase.from('aset').delete().eq('id', id);
      
      logger.i('Asset deleted successfully');
      return {
        'status': 'success',
        'message': 'Asset deleted successfully',
      };
    } catch (e) {
      logger.e('Exception in deleteAsset: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Get asset histories
  Future<Map<String, dynamic>> getAssetHistories() async {
    try {
      logger.i('Fetching asset histories');
      
      final response = await supabase
          .from('asset_history')
          .select('*')
          .order('timestamp', ascending: false);
      
      if (response == null) {
        logger.e('Failed to fetch asset histories');
        return {
          'status': 'error',
          'message': 'Gagal memuat riwayat aset',
        };
      }
      
      return {
        'status': 'success',
        'histories': response,
      };
    } catch (e) {
      logger.e('Exception getting asset histories: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Add asset history
  Future<Map<String, dynamic>> addAssetHistory(Map<String, dynamic> historyData) async {
    try {
      logger.i('Adding asset history');
      
      // Make sure timestamp is included
      if (!historyData.containsKey('timestamp')) {
        historyData['timestamp'] = DateTime.now().toIso8601String();
      }
      
      final response = await supabase
          .from('asset_history')
          .insert(historyData)
          .select();
      
      if (response == null || response.isEmpty) {
        logger.e('Failed to add asset history');
        return {
          'status': 'error',
          'message': 'Gagal menambahkan riwayat aset',
        };
      }
      
      return {
        'status': 'success',
        'history': response[0],
      };
    } catch (e) {
      logger.e('Exception adding asset history: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Get dropdown options for bidang
  Future<Map<String, dynamic>> getBidangList() async {
  try {
    final logger = Logger();
    logger.i('Fetching bidang list from dropdown_options');
    
    // Default bidang values to use if database returns nulls
    final List<String> defaultBidangValues = [
      'BIDANG KKU',
      'BIDANG PST', 
      'BIDANG HARTRANS',
      'BIDANG REN',
      'GM'
    ];
    
    // Try to get data from API
    try {
      final response = await Supabase.instance.client
          .from('dropdown_options')
          .select('value')
          .eq('option_type', 'bidang');
      
      // Log raw response
      logger.i('Raw bidang response from database: $response');
      
      // Check if response contains valid data
      if (response != null && response is List && response.isNotEmpty) {
        // Try to get valid values from response
        List<String> validOptions = [];
        
        for (var item in response) {
          if (item != null && item['value'] != null && item['value'].toString().isNotEmpty) {
            validOptions.add(item['value'].toString());
          }
        }
        
        // If we found valid options, use them
        if (validOptions.isNotEmpty) {
          logger.i('Using ${validOptions.length} valid bidang options from database: $validOptions');
          return {
            'status': 'success',
            'bidang_list': validOptions
          };
        } else {
          logger.w('No valid bidang options found in database response, using defaults');
        }
      } else {
        logger.w('Empty or invalid response from database, using defaults');
      }
    } catch (dbError) {
      logger.e('Error querying database: $dbError');
    }
    
    // If we reach here, we need to use default values
    logger.i('Using default bidang values: $defaultBidangValues');
    return {
      'status': 'success',
      'bidang_list': defaultBidangValues
    };
  } catch (e) {
    Logger().e('Error in getBidangList: $e');
    // Return default values on any error
    return {
      'status': 'error',
      'message': e.toString(),
      'bidang_list': [
        'BIDANG KKU',
        'BIDANG PST',
        'BIDANG HARTRANS',
        'BIDANG REN',
        'GM'
      ]
    };
  }
}
  
  // Metode pencarian aset
  Future<Map<String, dynamic>> searchAsset(String query) async {
    try {
      logger.i('Searching assets with query: $query');
      
      final response = await supabase
          .from('aset')
          .select('*')
          .or('nama_barang.ilike.%$query%,merk.ilike.%$query%,serial_number.ilike.%$query%,nama_pengguna.ilike.%$query%');
      
      logger.i('Found ${response.length} assets matching query');
      return {
        'status': 'success',
        'assets': response,
      };
    } catch (e) {
      logger.e('Exception searching assets: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Mendapatkan aset berdasarkan kategori
  Future<Map<String, dynamic>> getAssetsByCategory(String category) async {
    try {
      logger.i('Fetching assets for category: $category');
      
      final response = await supabase
          .from('aset')
          .select('*')
          .ilike('kategori', '%$category%');
      
      logger.i('Found ${response.length} assets for category');
      return {
        'status': 'success',
        'assets': response,
      };
    } catch (e) {
      
      
      logger.e('Exception getting assets by category: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Mendapatkan aset berdasarkan lokasi/bidang
  Future<Map<String, dynamic>> getAssetsByLocation(String? location) async {
  try {
    final logger = Logger();
    
    // Make sure we have a valid location
    final String validLocation = (location != null && location.isNotEmpty) 
        ? location.trim() 
        : 'BIDANG KKU'; // Default location if null/empty
    
    logger.i('Fetching assets for location: $validLocation');
    
    // Query the database with proper filter
    // Using .ilike for case-insensitive filtering with pattern matching
    var query = Supabase.instance.client
        .from('aset') // Adjust table name if different 
        .select()
        .ilike('bidang', '%$validLocation%');
    
    // Execute the query
    final data = await query;
    logger.i('Raw data from Supabase: $data');
    
    // Log count of returned items
    if (data != null && data is List) {
      logger.i('Found ${data.length} assets for location: $validLocation');
      
      // Log a sample of the returned data for debugging
      if (data.isNotEmpty) {
        logger.i('Sample asset data: ${data[0].keys.toList()}');
        logger.i('Sample asset values: ${data[0]}');
      }
      
      return {
        'status': 'success',
        'assets': data,
      };
    } else {
      logger.w('No assets found or query returned null');
      return {
        'status': 'success',
        'assets': [],
      };
    }
  } catch (e) {
    Logger().e('Error in getAssetsByLocation: $e');
    return {
      'status': 'error',
      'message': e.toString(),
      'assets': []
    };
  }
}
  
  // Mendapatkan dropdown berdasarkan tipe: kategori, kondisi, atau bidang
  Future<Map<String, dynamic>> getDropdownOptions(String optionType) async {
    try {
      logger.i('Fetching dropdown options for type: $optionType');
      
      final response = await supabase
          .from('dropdown_options')
          .select('*')
          .eq('option_type', optionType);
      
      if (response == null || response.isEmpty) {
        logger.e('No dropdown options found for type: $optionType');
        return {
          'status': 'error',
          'message': 'Tidak dapat mengambil opsi dropdown',
        };
      }
      
      final List<String> options = response
          .map<String>((opt) => opt['option_value'].toString())
          .toList();
      
      return {
        'status': 'success',
        'options': options,
      };
    } catch (e) {
      logger.e('Exception in getDropdownOptions: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
  
  // Helper method to standardize field names from camelCase to snake_case
  Map<String, dynamic> _standardizeFieldNames(Map<String, dynamic> data) {
    final Map<String, dynamic> standardized = {};
    final Map<String, String> fieldMapping = {
      'namaBarang': 'nama_barang',
      'serialNumber': 'serial_number',
      'namaPengguna': 'nama_pengguna',
      'subBidang': 'sub_bidang',
      'namaRuangan': 'nama_ruangan',
      'noInventarisBarang': 'no_inventaris_barang',
      'noAktiva': 'no_aktiva',
      'qrCodePath': 'qr_code_path',
      'createdAt': 'created_at',
      'updatedAt': 'updated_at',
    };
    
    data.forEach((key, value) {
      // If the key has a mapping, use it, otherwise keep original key
      final newKey = fieldMapping[key] ?? key;
      standardized[newKey] = value;
    });
    
    return standardized;
  }
}