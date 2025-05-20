import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:barcode/barcode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Add this import for SVG rendering
import 'package:xml/xml.dart' as xml;
import 'package:qr/qr.dart';
import 'package:flutter/material.dart';

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
    final generatedId = isEditing.value
      ? assetToEdit.value?.id
      : const Uuid().v4();
    
    return Asset(
      // If edit mode, use existing no and id
      no: isEditing.value ? assetToEdit.value?.no : null,
      id: generatedId.toString(),
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
  
  String generateQrDataFromAsset(Asset asset) {
    // Create a map with all relevant asset data
    final assetData = {
      'id': asset.id,
      'no': asset.no,
      'namaBarang': asset.namaBarang,
      'merk': asset.merk,
      'type': asset.type,
      'serialNumber': asset.serialNumber,
      'nip': asset.nip,
      'namaPengguna': asset.namaPengguna,
      'unit': asset.unit,
      'bidang': asset.bidang,
      'subBidang': asset.subBidang,
      'namaRuangan': asset.namaRuangan,
      'noInventarisBarang': asset.noInventarisBarang,
      'noAktiva': asset.noAktiva,
      'jumlah': asset.jumlah,
      'kondisi': asset.kondisi,
      'kategori': asset.kategori,
    };
    
    // Convert to JSON string
    return jsonEncode(assetData);
  }
  
  // Generate SVG QR code using barcode package (legacy version, renamed to avoid conflict)
String generateQrSvgLegacy(String data, {double width = 300, double height = 300}) {
  try {
    // Create QR barcode
    final qrBarcode = Barcode.qrCode();
    
    // Generate basic SVG
    final qrCodeSvg = qrBarcode.toSvg(
      data,
      width: width - 20, // Leave space for border
      height: height - 20, // Leave space for border
      drawText: false,
    );
    
    // Create a complete SVG with border by wrapping the QR code SVG
    final svgWithBorder = '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="$width" height="$height" viewBox="0 0 $width $height">
  <!-- White background -->
  <rect x="0" y="0" width="$width" height="$height" fill="white" />
  
  <!-- Border rectangle -->
  <rect x="2" y="2" width="${width - 4}" height="${height - 4}" 
        fill="none" stroke="black" stroke-width="2" />
  
  <!-- QR Code (positioned inside the border) -->
  <g transform="translate(10, 10)">
    $qrCodeSvg
  </g>
</svg>
''';

    return svgWithBorder;
  } catch (e) {
    logger.e('Error generating QR SVG: $e');
    throw Exception('Failed to generate QR code: $e');
  }
}
  
  Future<void> showQrCodeDialogLegacy(Asset asset) async {
    try {
      // Generate QR data and SVG string
      final qrData = generateQrDataFromAsset(asset);
      final svgString = generateQrSvg(qrData);
      
      Get.dialog(
        AlertDialog(
          title: Text('QR Code: ${asset.namaBarang}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 300,
                  width: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                  ),
                  child: SvgPicture.string(
                    svgString,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Scan QR code untuk melihat data aset:'),
                const SizedBox(height: 10),
                Text(asset.namaBarang ?? 'Tidak ada nama',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('No. Inventaris: ${asset.noInventarisBarang ?? 'N/A'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () async {
                await _saveQrCode(asset);
              },
              child: const Text('Simpan QR'),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e('Error displaying QR code: $e');
      Get.snackbar(
        'Error',
        'Gagal menampilkan QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Method to save QR code to device storage
  
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
        logger.i('Updating asset: ${asset.namaBarang} (${asset.id})');
        
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
        
        // Show QR code when a new asset is added or when asset is updated
        await showQrCodeDialog(asset);
        
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
    Get.toNamed('/qr-scanner')?.then((result) {
      if (result != null && result is Map<String, dynamic>) {
        // A valid asset was scanned and returned
        logger.i('Asset scanned from QR: ${result['namaBarang']}');
        
        // Process the scanned asset data if needed
        processScannedAssetData(result);
      }
    });
  }
  
  // Process scanned asset data
  void processScannedAssetData(Map<String, dynamic> assetData) {
    try {
      // Create an Asset object from the scanned data
      final asset = Asset(
        id: assetData['id'],
        no: assetData['no'],
        namaBarang: assetData['namaBarang'],
        merk: assetData['merk'],
        type: assetData['type'],
        serialNumber: assetData['serialNumber'],
        nip: assetData['nip'],
        namaPengguna: assetData['namaPengguna'],
        unit: assetData['unit'],
        bidang: assetData['bidang'],
        subBidang: assetData['subBidang'],
        namaRuangan: assetData['namaRuangan'],
        noInventarisBarang: assetData['noInventarisBarang'],
        noAktiva: assetData['noAktiva'],
        jumlah: assetData['jumlah'],
        kondisi: assetData['kondisi'],
        kategori: assetData['kategori'],
      );
      
      // Display asset details
      Get.dialog(
        AlertDialog(
          title: const Text('Asset Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama Barang: ${asset.namaBarang ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Merk: ${asset.merk ?? "N/A"}'),
                Text('Type: ${asset.type ?? "N/A"}'),
                Text('Serial Number: ${asset.serialNumber ?? "N/A"}'),
                Text('No. Inventaris: ${asset.noInventarisBarang ?? "N/A"}'),
                Text('Kondisi: ${asset.kondisi ?? "N/A"}'),
                Text('Kategori: ${asset.kategori ?? "N/A"}'),
                Text('Pengguna: ${asset.namaPengguna ?? "N/A"}'),
                Text('Bidang: ${asset.bidang ?? "N/A"}'),
                Text('Ruangan: ${asset.namaRuangan ?? "N/A"}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                // Navigate to edit form if needed
                Get.toNamed('/asset-form', arguments: asset);
              },
              child: const Text('Edit Asset'),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e('Error processing scanned asset data: $e');
      Get.snackbar(
        'Error',
        'Gagal memproses data aset dari QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // IMPROVED QR Code Generation Methods
  
  // Generate SVG QR code using barcode package with proper border
  String generateQrSvg(String data, {double width = 300, double height = 300}) {
    try {
      // Create QR barcode
      final qrBarcode = Barcode.qrCode();
      
      // Define border settings
      final borderWidth = 2.0;
      const borderPadding = 10.0;
      
      // Create SVG string with a custom wrapper for border
      final qrCodeSvg = qrBarcode.toSvg(
        data,
        width: width - (borderPadding * 2) - (borderWidth * 2),
        height: height - (borderPadding * 2) - (borderWidth * 2),
        drawText: false,
      );
      
      // Create a complete SVG with border by wrapping the QR code SVG
      final svgWithBorder = '''
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="$width" height="$height" viewBox="0 0 $width $height">
  <!-- Border rectangle -->
  <rect x="0" y="0" width="$width" height="$height" fill="white" />
  <rect x="$borderWidth" y="$borderWidth" 
        width="${width - (borderWidth * 2)}" 
        height="${height - (borderWidth * 2)}" 
        fill="white" 
        stroke="black" 
        stroke-width="$borderWidth" />
  
  <!-- QR Code (positioned inside the border) -->
  <g transform="translate($borderPadding, $borderPadding)">
    $qrCodeSvg
  </g>
</svg>
''';

      return svgWithBorder;
    } catch (e) {
      logger.e('Error generating QR SVG: $e');
      throw Exception('Failed to generate QR code: $e');
    }
  }
  
  // Alternative implementation using the built-in border options
  String generateQrSvgAlternative(String data, {double width = 300, double height = 300}) {
    try {
      // Create QR barcode
      final barcode = Barcode.qrCode();
      
      // Generate SVG with border using the border parameter
      final svg = barcode.toSvg(
        data,
        width: width,
        height: height,
        drawText: false,
        fontHeight: 0, // No text
      );
      
      // Add a rect element for the border
      final parser = xml.XmlDocument.parse(svg);
      final svgRoot = parser.rootElement;
      
      // Create a border rectangle and insert it as the first child
      final borderRect = xml.XmlElement(
        xml.XmlName('rect'),
        [
          xml.XmlAttribute(xml.XmlName('x'), '0'),
          xml.XmlAttribute(xml.XmlName('y'), '0'),
          xml.XmlAttribute(xml.XmlName('width'), width.toString()),
          xml.XmlAttribute(xml.XmlName('height'), height.toString()),
          xml.XmlAttribute(xml.XmlName('fill'), 'none'),
          xml.XmlAttribute(xml.XmlName('stroke'), 'black'),
          xml.XmlAttribute(xml.XmlName('stroke-width'), '2'),
        ],
      );
      
      svgRoot.children.insert(1, borderRect);
      
      return parser.toXmlString();
    } catch (e) {
      logger.e('Error generating QR SVG with alternative method: $e');
      
      // Fallback to the simpler method if XML parsing fails
      return generateQrSvg(data, width: width, height: height);
    }
  }
  
  Future<void> showQrCodeDialog(Asset asset) async {
    try {
      // Generate QR data and SVG string
      final qrData = generateQrDataFromAsset(asset);
      final svgString = generateQrSvg(qrData);
      
      Get.dialog(
        AlertDialog(
          title: Text('QR Code: ${asset.namaBarang}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SvgPicture.string(
                    svgString,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Scan QR code untuk melihat data aset:'),
                const SizedBox(height: 10),
                Text(asset.namaBarang ?? 'Tidak ada nama',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('No. Inventaris: ${asset.noInventarisBarang ?? 'N/A'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () async {
                await _saveQrCode(asset);
              },
              child: const Text('Simpan QR'),
            ),
            TextButton(
              onPressed: () async {
                await _printQrCode(asset);
              },
              child: const Text('Cetak QR'),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e('Error displaying QR code: $e');
      Get.snackbar(
        'Error',
        'Gagal menampilkan QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Method to save QR code to device storage
  Future<void> _saveQrCode(Asset asset) async {
    try {
      // Generate QR data
      final qrData = generateQrDataFromAsset(asset);
      
      // Generate SVG string with border
      final svg = generateQrSvg(qrData);
      
      // Get temporary directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = (asset.namaBarang ?? 'asset')
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w\s]+'), '');
      
      final filePath = '${directory.path}/${sanitizedName}_$timestamp.svg';
      
      // Write to file
      final file = File(filePath);
      await file.writeAsString(svg);
      
      Get.snackbar(
        'Sukses',
        'QR Code telah disimpan ke $filePath',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      
      logger.i('QR Code saved to: $filePath');
    } catch (e) {
      logger.e('Error saving QR code: $e');
      Get.snackbar(
        'Error',
        'Gagal menyimpan QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Method to print QR code
  Future<void> _printQrCode(Asset asset) async {
    try {
      // This is a placeholder for printing functionality
      // You would need to integrate with a printing package like 'printing'
      Get.snackbar(
        'Info',
        'Fitur cetak QR Code akan segera hadir',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      
      // Example code for printing implementation:
      // final pdf = await _generatePdfWithQrCode(asset);
      // await Printing.layoutPdf(
      //   onLayout: (PdfPageFormat format) async => pdf.save(),
      // );
    } catch (e) {
      logger.e('Error printing QR code: $e');
      Get.snackbar(
        'Error',
        'Gagal mencetak QR Code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// Dummy implementation of AssetHistoryService for cases when it's not registered
class _DummyHistoryService {
  List<AssetHistoryEntry> getHistoryForAsset(int assetId) {
    return [];
  }
  
  Future<bool> addHistoryEntry(AssetHistoryEntry entry) async {
    return true;
  }
}