// lib/app/modules/asset_data/services/dropdown_options_service.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../providers/asset_api_provider.dart';

class DropdownOptionsService extends GetxService {
  // Singleton instance
  static DropdownOptionsService get to => Get.find<DropdownOptionsService>();
  
  final logger = Logger();
  late final AssetApiProvider _apiProvider;
  
  // Observable lists for options
  final RxList<String> _bidangOptions = <String>[].obs;
  final RxList<String> _kondisiOptions = <String>[].obs;
  final RxList<String> _kategoriOptions = <String>[].obs;
  
  // Getters for the options lists
  List<String> get bidangOptions => _bidangOptions;
  List<String> get kondisiOptions => _kondisiOptions;
  List<String> get kategoriOptions => _kategoriOptions;
  
  // Default constructor without parameters
  DropdownOptionsService();
  
  // Init method untuk registrasi dengan GetX
  Future<DropdownOptionsService> init() async {
    logger.i('Initializing DropdownOptionsService');
    
    try {
      // Get AssetApiProvider instance
      _apiProvider = Get.find<AssetApiProvider>();
      
      // Initialize with default options
      _initDefaultOptions();
      
      // Load options from API
      await _loadOptionsFromApi();
      
      logger.i('DropdownOptionsService initialized successfully');
    } catch (e) {
      logger.e('Error initializing DropdownOptionsService: $e');
    }
    
    return this;
  }
  
  // Initialize with default options
  void _initDefaultOptions() {
    logger.i('Initializing default dropdown options');
    
    // Default options for bidang
    _bidangOptions.assignAll([
      'BIDANG KKU',
      'BIDANG PST',
      'BIDANG HARTRANS',
      'BIDANG REN',
      'GM'
    ]);
    
    // Default options for kondisi
    _kondisiOptions.assignAll([
      'Layak Pakai',
      'Sudah Lama',
      'Rusak ',
    ]);
    
    // Default options for kategori
    _kategoriOptions.assignAll([
      'Elektronik',
      'Furnitur',
    ]);
  }
  
  // Load options from API
  Future<void> _loadOptionsFromApi() async {
    try {
      // Load bidang options
      final bidangResponse = await _apiProvider.getBidangList();
      if (bidangResponse['status'] == 'success') {
        final List<dynamic> bidangData = bidangResponse['bidang_list'];
        if (bidangData.isNotEmpty) {
          _bidangOptions.assignAll(bidangData.map((item) => item.toString()).toList());
          logger.i('Loaded bidang options from API: ${_bidangOptions.length} items');
        }
      }
      
      // Load other options (kondisi, kategori) if APIs are available
      // Example:
      // final kondisiResponse = await _apiProvider.getKondisiList();
      // if (kondisiResponse['status'] == 'success') {
      //   // Process response
      // }
      
    } catch (e) {
      logger.e('Error loading dropdown options: $e');
    }
  }
  
  // Refresh options from API
  Future<void> refreshOptions() async {
    await _loadOptionsFromApi();
  }
  
  // Add custom option to a list (if needed)
  void addCustomOption(String listName, String value) {
    if (value.isEmpty) return;
    
    switch (listName) {
      case 'bidang':
        if (!_bidangOptions.contains(value)) {
          _bidangOptions.add(value);
        }
        break;
      case 'kondisi':
        if (!_kondisiOptions.contains(value)) {
          _kondisiOptions.add(value);
        }
        break;
      case 'kategori':
        if (!_kategoriOptions.contains(value)) {
          _kategoriOptions.add(value);
        }
        break;
    }
  }
}