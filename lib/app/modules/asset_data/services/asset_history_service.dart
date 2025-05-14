// lib/app/modules/asset_data/services/asset_history_service.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/asset_history_model.dart';
import '../providers/asset_api_provider.dart';

class AssetHistoryService extends GetxService {
  // Singleton instance
  static AssetHistoryService get to => Get.find<AssetHistoryService>();
  
  // Logger
  final logger = Logger();
  
  // API provider
  late final AssetApiProvider _apiProvider;
  
  // List of histories
  final RxList<AssetHistoryModel> _histories = <AssetHistoryModel>[].obs;
  
  // Error message
  final RxString errorMessage = ''.obs;
  
  // Init method that returns this service for binding
  Future<AssetHistoryService> init() async {
    logger.i('AssetHistoryService initialized');
    
    try {
      _apiProvider = Get.find<AssetApiProvider>();
    } catch (e) {
      logger.w('AssetApiProvider not found, initializing...');
      _apiProvider = Get.put(AssetApiProvider());
    }
    
    // Initial load of histories
    await loadHistories();
    
    return this;
  }
  
  // Load all histories from API/database
  Future<void> loadHistories() async {
    try {
      // Get histories from API
      final response = await _apiProvider.getAssetHistories();
      
      if (response['status'] == 'success') {
        final List<dynamic> historiesData = response['histories'] ?? [];
        _histories.value = historiesData
            .map((data) => AssetHistoryModel.fromJson(data))
            .toList();
        
        logger.i('Loaded ${_histories.length} histories');
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load histories';
        logger.e('Error loading histories: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      logger.e('Exception loading histories: $e');
      
      // Populate with sample data in development environment
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        _loadSampleData();
      }
    }
  }
  
  // Get all histories
  Future<List<AssetHistoryModel>> getAllHistories() async {
    // If no histories loaded yet, load them
    if (_histories.isEmpty) {
      await loadHistories();
    }
    
    return _histories;
  }
  
  // Get histories for a specific asset
  List<AssetHistoryEntry> getHistoryForAsset(int assetId) {
    return _histories
        .where((history) => history.assetId == assetId)
        .map((history) => AssetHistoryEntry(
              assetId: history.assetId,
              action: history.action,
              userId: history.userId,
              userName: history.userName,
              assetName: history.assetName,
              changedFields: history.changedFields,
              timestamp: history.timestamp,
            ))
        .toList();
  }
  
  // Add a new history entry
  Future<bool> addHistoryEntry(AssetHistoryEntry entry) async {
    try {
      // Add to API/database
      final response = await _apiProvider.addAssetHistory(entry.toJson());
      
      if (response['status'] == 'success') {
        // Add to local list
        _histories.add(entry);
        logger.i('Added history entry for asset: ${entry.assetId}, action: ${entry.action}');
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to add history entry';
        logger.e('Error adding history entry: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      logger.e('Exception adding history entry: $e');
      
      // In development, still add to local list
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        _histories.add(entry);
        return true;
      }
      
      return false;
    }
  }
  
  // Load sample data for development
  void _loadSampleData() {
    logger.i('Loading sample history data');
    
    final now = DateTime.now();
    
    _histories.addAll([
      AssetHistoryModel(
        assetId: 1,
        assetName: 'Laptop Lenovo ThinkPad',
        action: 'Tambah',
        userId: 'user1',
        userName: 'Admin',
        timestamp: now.subtract(Duration(days: 30)),
        changedFields: {},
      ),
      AssetHistoryModel(
        assetId: 1,
        assetName: 'Laptop Lenovo ThinkPad',
        action: 'Edit',
        userId: 'user2',
        userName: 'John Doe',
        timestamp: now.subtract(Duration(days: 15)),
        changedFields: {
          'condition': {
            'old': 'Baik',
            'new': 'Rusak Ringan',
          },
          'location': {
            'old': 'Ruang IT',
            'new': 'Ruang Administrasi',
          },
        },
      ),
      AssetHistoryModel(
        assetId: 2,
        assetName: 'Proyektor Epson',
        action: 'Tambah',
        userId: 'user1',
        userName: 'Admin',
        timestamp: now.subtract(Duration(days: 45)),
        changedFields: {},
      ),
      AssetHistoryModel(
        assetId: 3,
        assetName: 'Printer HP LaserJet',
        action: 'Tambah',
        userId: 'user1',
        userName: 'Admin',
        timestamp: now.subtract(Duration(days: 20)),
        changedFields: {},
      ),
      AssetHistoryModel(
        assetId: 3,
        assetName: 'Printer HP LaserJet',
        action: 'Hapus',
        userId: 'user3',
        userName: 'Jane Smith',
        timestamp: now.subtract(Duration(days: 5)),
        changedFields: {},
      ),
    ]);
  }
}