// lib/app/modules/asset_form/controllers/asset_form_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../asset_data/models/asset_model.dart';
import '../../asset_data/models/asset_history_model.dart';
import '../../asset_data/services/asset_service.dart';
import '../../asset_data/providers/asset_api_provider.dart';
import '../../asset_data/services/dropdown_options_service.dart';

class AssetFormController extends GetxController {
  // Services & Providers
  final AssetService _assetService = Get.find<AssetService>();
  late final _historyService;
  final AssetApiProvider _apiProvider = Get.find<AssetApiProvider>();
  final DropdownOptionsService _dropdownService = Get.find<DropdownOptionsService>();
  final logger = Logger();

  // Reactive variables
  final Rx<Asset?> assetToEdit = Rx<Asset?>(null);
  final RxString selectedCategory = ''.obs;
  final Rx<String?> currentBidang = Rx<String?>(null);
  final RxString selectedBidang = ''.obs;
  
  // Default bidang options to use when database returns nulls
  final List<String> defaultBidangOptions = [
    'BIDANG KKU',
    'BIDANG PST',
    'BIDANG HARTRANS',
    'BIDANG REN',
    'GM'
  ];
  
  // State variables
  final isLoading = false.obs;
  final isEditing = false.obs;
  final formKey = GlobalKey<FormState>();
  
  // Form controllers
  final namaBarangController = TextEditingController();
  final merkController = TextEditingController();
  final typeController = TextEditingController();
  final serialNumberController = TextEditingController();
  final nipController = TextEditingController();
  final namaPenggunaController = TextEditingController();
  final unitController = TextEditingController();
  final bidangController = TextEditingController();
  final subBidangController = TextEditingController();
  final namaRuanganController = TextEditingController();
  final noInventarisBarangController = TextEditingController();
  final noAktivaController = TextEditingController();
  final jumlahController = TextEditingController();
  final kondisiController = TextEditingController();

  // User information
  final Rx<String?> currentUserId = Rx<String?>(null);
  final Rx<String?> currentUserName = Rx<String?>(null);

  // Getters that ensure we always have valid options
  List<String> get safeKategoriOptions {
    final options = _dropdownService.kategoriOptions;
    return options.where((item) => item != null && item.isNotEmpty).toList();
  }
  
  List<String> get safeKondisiOptions {
    final options = _dropdownService.kondisiOptions;
    return options.where((item) => item != null && item.isNotEmpty).toList();
  }
  
  List<String> get safeBidangOptions {
    final options = _dropdownService.bidangOptions;
    final validOptions = options.where((item) => item != null && item.isNotEmpty).toList();
    
    // If the database returned all nulls, use default options
    if (validOptions.isEmpty) {
      return defaultBidangOptions;
    }
    
    return validOptions;
  }

  @override
  void onInit() {
    super.onInit();
    logger.i('AssetFormController initialized');
    
    // Initialize AssetHistoryService
    try {
      _historyService = Get.find<dynamic>(tag: 'AssetHistoryService');
    } catch (e) {
      logger.w('AssetHistoryService not found, using empty implementation');
      _historyService = _DummyHistoryService();
    }
    
    // Set default value for jumlah
    jumlahController.text = '1';
    
    // If we have valid bidang options, set initial selected bidang
    ensureValidBidangOptions();
    
    // Set current user info if available
    _setCurrentUserInfo();
    
    // Check edit or add mode
    checkForEditMode();
    
    // Print dropdown options for debugging
    printDropdownOptions();
  }
  
  void ensureValidBidangOptions() {
    // Fix the bidang options if they're all null
    final options = _dropdownService.bidangOptions;
    
    // Check if we need to use default values
    bool allNullOrEmpty = true;
    for (var option in options) {
      if (option != null && option.isNotEmpty) {
        allNullOrEmpty = false;
        break;
      }
    }
    
    // If all options are null or empty, use the defaults
    if (allNullOrEmpty) {
      logger.w('All bidang options are null or empty, using defaults');
      
      // The DropdownOptionsService might have direct access to the RxList
      try {
        // Try to update the service's options list directly
        final rxList = _dropdownService.bidangOptions as RxList<String>;
        rxList.assignAll(defaultBidangOptions);
      } catch (e) {
        logger.e('Could not update service bidang options: $e');
        
        // In case we can't update the service, at least set our current bidang to a valid value
        if (defaultBidangOptions.isNotEmpty) {
          currentBidang.value = defaultBidangOptions.first;
          selectedBidang.value = defaultBidangOptions.first;
          bidangController.text = defaultBidangOptions.first;
        }
      }
    }
    
    // Set initial bidang value if needed
    if (currentBidang.value == null && safeBidangOptions.isNotEmpty) {
      currentBidang.value = safeBidangOptions.first;
      selectedBidang.value = safeBidangOptions.first;
      bidangController.text = safeBidangOptions.first;
    }
  }
  
  void printDropdownOptions() {
    try {
      logger.i('Kondisi options: ${safeKondisiOptions}');
      logger.i('Current kondisi: ${kondisiController.text}');
      
      logger.i('Kategori options: ${safeKategoriOptions}');
      logger.i('Current kategori: ${selectedCategory.value}');
      
      logger.i('Bidang options: ${safeBidangOptions}');
      logger.i('Current bidang: ${currentBidang.value}');
    } catch (e) {
      logger.e('Error printing dropdown options: $e');
    }
  }
  
  void _setCurrentUserInfo() {
    try {
      final userInfo = Get.find<dynamic>(); // Replace with your auth service
      currentUserId.value = userInfo?.userId ?? "system";
      currentUserName.value = userInfo?.userName ?? "System User";
    } catch (e) {
      // Fallback to system user if not found
      currentUserId.value = "system";
      currentUserName.value = "System User";
      logger.i('Using default system user');
    }
  }
  
  @override
  void onClose() {
    // Dispose all controllers
    namaBarangController.dispose();
    merkController.dispose();
    typeController.dispose();
    serialNumberController.dispose();
    nipController.dispose();
    namaPenggunaController.dispose();
    unitController.dispose();
    bidangController.dispose();
    subBidangController.dispose();
    namaRuanganController.dispose();
    noInventarisBarangController.dispose();
    noAktivaController.dispose();
    jumlahController.dispose();
    kondisiController.dispose();
    
    super.onClose();
  }
  
  void checkForEditMode() {
    try {
      logger.i('Checking edit mode, arguments: ${Get.arguments}');
      
      // Reset editing status
      isEditing.value = false;
      
      if (Get.arguments != null && Get.arguments is Asset) {
        // Edit mode
        logger.i('Edit mode detected');
        assetToEdit.value = Get.arguments as Asset;
        isEditing.value = true;
        
        // Fill form with existing data
        populateFormWithAssetData();
      } else {
        // Add mode
        logger.i('Add mode detected');
        resetForm();
      }
    } catch (e) {
      logger.e('Error in checkForEditMode: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat form: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void populateFormWithAssetData() {
    if (assetToEdit.value == null) {
      logger.w('Cannot populate form: asset is null');
      return;
    }
    
    try {
      final asset = assetToEdit.value!;
      
      logger.i('Populating form with data: ${asset.namaBarang}');
      
      // Set all text fields
      namaBarangController.text = asset.namaBarang ?? '';
      merkController.text = asset.merk ?? '';
      typeController.text = asset.type ?? '';
      serialNumberController.text = asset.serialNumber ?? '';
      nipController.text = asset.nip ?? '';
      namaPenggunaController.text = asset.namaPengguna ?? '';
      unitController.text = asset.unit ?? '';
      subBidangController.text = asset.subBidang ?? '';
      namaRuanganController.text = asset.namaRuangan ?? '';
      noInventarisBarangController.text = asset.noInventarisBarang ?? '';
      noAktivaController.text = asset.noAktiva ?? '';
      jumlahController.text = asset.jumlah?.toString() ?? '1';
      
      // Set dropdown values - for bidang
      try {
        if (asset.bidang != null && asset.bidang!.isNotEmpty) {
          bidangController.text = asset.bidang!;
          currentBidang.value = asset.bidang;
          selectedBidang.value = asset.bidang!;
          
          // Add to options if not exists
          if (!safeBidangOptions.contains(asset.bidang)) {
            _dropdownService.addCustomOption('bidang', asset.bidang!);
          }
        } else if (safeBidangOptions.isNotEmpty) {
          // Set to first valid option if asset.bidang is null or empty
          final firstOption = safeBidangOptions.first;
          bidangController.text = firstOption;
          currentBidang.value = firstOption;
          selectedBidang.value = firstOption;
        }
      } catch (e) {
        logger.w('Error setting Bidang: $e');
        
        // Fallback to first valid option
        if (safeBidangOptions.isNotEmpty) {
          final firstOption = safeBidangOptions.first;
          bidangController.text = firstOption;
          currentBidang.value = firstOption;
          selectedBidang.value = firstOption;
        }
      }
      
      // Set dropdown values - for kategori
      if (asset.kategori != null && asset.kategori!.isNotEmpty) {
        selectedCategory.value = asset.kategori!;
        
        // Add to options if not exists
        if (!safeKategoriOptions.contains(asset.kategori)) {
          _dropdownService.addCustomOption('kategori', asset.kategori!);
        }
      } else if (safeKategoriOptions.isNotEmpty) {
        selectedCategory.value = safeKategoriOptions.first;
      }
      
      // Set dropdown values - for kondisi
      if (asset.kondisi != null && asset.kondisi!.isNotEmpty) {
        kondisiController.text = asset.kondisi!;
        
        // Add to options if not exists
        if (!safeKondisiOptions.contains(asset.kondisi)) {
          _dropdownService.addCustomOption('kondisi', asset.kondisi!);
        }
      } else if (safeKondisiOptions.isNotEmpty) {
        kondisiController.text = safeKondisiOptions.first;
      }
      
    } catch (e) {
      logger.e('Error in populateFormWithAssetData: $e');
    }
  }
  
  void resetForm() {
    logger.i('Resetting form');
    
    // Clear all text controllers
    namaBarangController.clear();
    merkController.clear();
    typeController.clear();
    serialNumberController.clear();
    nipController.clear();
    namaPenggunaController.clear();
    unitController.clear();
    bidangController.clear();
    subBidangController.clear();
    namaRuanganController.clear();
    noInventarisBarangController.clear();
    noAktivaController.clear();
    kondisiController.clear();
    
    // Set default values
    jumlahController.text = '1';
    
    // Reset dropdown values but set to first option if available
    selectedCategory.value = safeKategoriOptions.isNotEmpty ? safeKategoriOptions.first : '';
    
    if (safeBidangOptions.isNotEmpty) {
      selectedBidang.value = safeBidangOptions.first;
      currentBidang.value = safeBidangOptions.first;
      bidangController.text = safeBidangOptions.first;
    } else {
      selectedBidang.value = '';
      currentBidang.value = null;
    }
    
    if (safeKondisiOptions.isNotEmpty) {
      kondisiController.text = safeKondisiOptions.first;
    }
  }
  
  Asset getAssetFromForm() {
    // Create Asset object from form data
    
    return Asset(
      
      // If edit mode, use existing no and id
      no: isEditing.value ? assetToEdit.value?.no : null,
      id: isEditing.value ? assetToEdit.value?.id : null,
      namaBarang: namaBarangController.text,
      merk: merkController.text,
      type: typeController.text,
      serialNumber: serialNumberController.text,
      nip: nipController.text,
      namaPengguna: namaPenggunaController.text,
      unit: unitController.text,
      bidang: bidangController.text, // Use bidangController.text for bidang
      subBidang: subBidangController.text,
      namaRuangan: namaRuanganController.text,
      noInventarisBarang: noInventarisBarangController.text,
      noAktiva: noAktivaController.text,
      jumlah: int.tryParse(jumlahController.text) ?? 1,
      kondisi: kondisiController.text, // Use kondisiController.text for kondisi
      kategori: selectedCategory.value, // Use selectedCategory for kategori
      createdAt: isEditing.value ? assetToEdit.value?.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
  
  Future<void> saveAsset() async {
    if (!validateForm()) {
      logger.w('Form validation failed');
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Create asset object from form
      final asset = getAssetFromForm();
      
      // Check inventory number
      if (asset.noInventarisBarang == null || asset.noInventarisBarang!.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Nomor inventaris barang tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Prepare history entry
      AssetHistoryEntry? historyEntry;
      
      // Save asset
      bool success;
      if (isEditing.value) { 
        // Edit mode: compare changes
        logger.i('Updating asset: ${asset.namaBarang} (${asset.no})');
        
        // Find changes
        try {
          final changedFields = AssetHistoryEntry.compareAssets(
            assetToEdit.value, 
            asset
          );
          
          // If there are changes
          if (changedFields.isNotEmpty) {
            historyEntry = AssetHistoryEntry(
              assetId: asset.no ?? 0,
              action: 'Edit',
              userId: currentUserId.value,
              userName: currentUserName.value,
              changedFields: changedFields,
            );
          }
        } catch (e) {
          logger.w('Error comparing assets: $e');
        }
        
        success = await _assetService.updateAsset(asset);
      } else {
        // Add mode
        logger.i('Adding new asset: ${asset.namaBarang}');
        
        // Create history entry for addition
        try {
          historyEntry = AssetHistoryEntry(
            assetId: 0, // Will be updated after asset is saved
            action: 'Tambah',
            userId: currentUserId.value,
            userName: currentUserName.value,
          );
        } catch (e) {
          logger.w('Error creating history entry: $e');
        }
        
        success = await _assetService.addAsset(asset);
      }
      
      if (success) {
        // Add history if there are changes or new addition
        if (historyEntry != null) {
          try {
            // If add mode, set assetId
            if (!isEditing.value) {
              historyEntry = historyEntry.copyWith(
                assetId: asset.no ?? 0, // Get newly created ID
              );
            }
            
            // Add to history
            await _historyService.addHistoryEntry(historyEntry);
          } catch (e) {
            logger.w('Error adding history entry: $e');
          }
        }

        logger.i('Asset saved successfully');
        
        // Return to previous page
        Get.back(result: true);
        Get.snackbar(
          'Sukses',
          isEditing.value 
              ? 'Aset berhasil diperbarui'
              : 'Aset baru berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        logger.e('Failed to save asset: ${_assetService.errorMessage.value}');
        Get.snackbar(
          'Gagal',
          'Gagal menyimpan aset: ${_assetService.errorMessage.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      logger.e('Error saving asset: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
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
    if (!isEditing.value || assetToEdit.value == null) {
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
      // Get history for this asset
      final assetId = assetToEdit.value!.no ?? 0;
      
      // Get history with error handling
      List<AssetHistoryEntry> histories = [];
      try {
        histories = _historyService.getHistoryForAsset(assetId);
      } catch (e) {
        logger.e('Error getting history: $e');
        histories = [];
      }
      
      // Show history dialog
      Get.dialog(
        AlertDialog(
          title: Text('Riwayat Aset: ${assetToEdit.value?.namaBarang ?? 'Tidak diketahui'}'),
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
  void _showHistoryDetails(AssetHistoryEntry history) {
    Get.dialog(
      AlertDialog(
        title: Text('Detail Riwayat ${history.action}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Waktu: ${history.timestamp}'),
              Text('Aksi: ${history.action}'),
              Text('Pengguna: ${history.userName ?? 'Tidak diketahui'}'),
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
                    '${entry.key}: '
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
  
  // Method to scan QR code
  void scanQrCode() {
    Get.toNamed('/qr-scanner');
  }
}

// Dummy class for when AssetHistoryService is not available
class _DummyHistoryService {
  List<AssetHistoryEntry> getHistoryForAsset(int assetId) {
    return [];
  }
  
  Future<bool> addHistoryEntry(AssetHistoryEntry entry) async {
    return true;
  }
}