// lib/app/modules/qr_gallery/services/qr_gallery_service.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QrGalleryService extends GetxService {
  static const String _boxName = 'qr_gallery_box';
  final logger = Logger();
  
  // Reactive variables
  final RxList<Map<String, dynamic>> qrGallery = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Hive box for storing QR data
  late Box<Map<dynamic, dynamic>> _qrBox;
  
  @override
  void onInit() {
    super.onInit();
    _initHive();
  }
  
  Future<void> _initHive() async {
    try {
      isLoading.value = true;
      
      // Initialize Hive
      await Hive.initFlutter();
      
      // Open box for QR gallery
      _qrBox = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      
      // Load existing QR codes
      await loadQrGallery();
      
      logger.i('QrGalleryService initialized with ${qrGallery.length} codes');
    } catch (e) {
      errorMessage.value = 'Failed to initialize QR gallery: $e';
      logger.e(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadQrGallery() async {
    try {
      isLoading.value = true;
      
      // Clear current list
      qrGallery.clear();
      
      // Get all QR codes from box
      final qrCodes = _qrBox.values.toList();
      
      // Sort by timestamp (newest first)
      qrCodes.sort((a, b) {
        final aTime = a['timestamp'] as int? ?? 0;
        final bTime = b['timestamp'] as int? ?? 0;
        return bTime.compareTo(aTime); // Newest first
      });
      
      // Add to reactive list
      for (var qrCode in qrCodes) {
        // Convert to correct Map<String, dynamic> format
        final Map<String, dynamic> qrData = {};
        qrCode.forEach((key, value) {
          qrData[key.toString()] = value;
        });
        
        // Check if file still exists before adding
        final imagePath = qrData['imagePath'] as String?;
        if (imagePath != null && File(imagePath).existsSync()) {
          qrGallery.add(qrData);
        } else if (imagePath != null) {
          // Image file is missing, set a flag
          qrData['fileNotFound'] = true;
          qrGallery.add(qrData);
        }
      }
      
      logger.i('Loaded ${qrGallery.length} QR codes from storage');
    } catch (e) {
      errorMessage.value = 'Failed to load QR gallery: $e';
      logger.e(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> addQrToGallery(Map<String, dynamic> qrInfo) async {
    try {
      // Generate a unique key
      final key = 'qr_${DateTime.now().millisecondsSinceEpoch}_${qrInfo['assetId']}';
      
      // Add to Hive box
      await _qrBox.put(key, qrInfo);
      
      // Add to reactive list (at beginning)
      qrGallery.insert(0, qrInfo);
      
      logger.i('Added QR code to gallery: ${qrInfo['assetName']}');
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add QR to gallery: $e';
      logger.e(errorMessage.value);
      return false;
    }
  }
  
  Future<bool> removeQrFromGallery(Map<String, dynamic> qrInfo) async {
    try {
      // Find key by matching timestamp
      final timestamp = qrInfo['timestamp'];
      final assetId = qrInfo['assetId'];
      
      String? keyToRemove;
      _qrBox.keys.forEach((key) {
        final item = _qrBox.get(key);
        if (item != null && 
            item['timestamp'] == timestamp && 
            item['assetId'] == assetId) {
          keyToRemove = key.toString();
        }
      });
      
      if (keyToRemove != null) {
        // Delete file if it exists
        final imagePath = qrInfo['imagePath'] as String?;
        if (imagePath != null) {
          final file = File(imagePath);
          if (await file.exists()) {
            await file.delete();
            logger.i('Deleted QR image file: $imagePath');
          }
        }
        
        // Remove from Hive box
        await _qrBox.delete(keyToRemove);
        
        // Remove from reactive list
        qrGallery.removeWhere((item) => 
          item['timestamp'] == timestamp && item['assetId'] == assetId);
        
        logger.i('Removed QR code from gallery: ${qrInfo['assetName']}');
        return true;
      } else {
        logger.w('QR code not found in gallery');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to remove QR from gallery: $e';
      logger.e(errorMessage.value);
      return false;
    }
  }
  
  Future<void> clearAllQrCodes() async {
    try {
      isLoading.value = true;
      
      // Delete all image files
      for (var qrInfo in qrGallery) {
        final imagePath = qrInfo['imagePath'] as String?;
        if (imagePath != null) {
          final file = File(imagePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
      
      // Clear Hive box
      await _qrBox.clear();
      
      // Clear reactive list
      qrGallery.clear();
      
      logger.i('Cleared all QR codes from gallery');
    } catch (e) {
      errorMessage.value = 'Failed to clear QR gallery: $e';
      logger.e(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<File?> getQrImageFile(Map<String, dynamic> qrInfo) async {
    try {
      final imagePath = qrInfo['imagePath'] as String?;
      
      if (imagePath == null) {
        return null;
      }
      
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      } else {
        logger.w('QR image file not found: $imagePath');
        
        // Update status in gallery
        final index = qrGallery.indexWhere((item) => 
          item['timestamp'] == qrInfo['timestamp'] && 
          item['assetId'] == qrInfo['assetId']);
        
        if (index != -1) {
          qrGallery[index]['fileNotFound'] = true;
        }
        
        return null;
      }
    } catch (e) {
      logger.e('Error getting QR image file: $e');
      return null;
    }
  }
  
  Future<bool> regenerateQrImage(Map<String, dynamic> qrInfo, File newImageFile) async {
    try {
      // Remove old item
      await removeQrFromGallery(qrInfo);
      
      // Create updated info with new file path
      final updatedInfo = Map<String, dynamic>.from(qrInfo);
      updatedInfo['imagePath'] = newImageFile.path;
      updatedInfo['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      
      // Add updated item
      return await addQrToGallery(updatedInfo);
    } catch (e) {
      logger.e('Error regenerating QR image: $e');
      return false;
    }
  }
  
  // Search QR gallery by asset name or ID
  List<Map<String, dynamic>> searchQrGallery(String query) {
    if (query.isEmpty) {
      return qrGallery;
    }
    
    final lowercaseQuery = query.toLowerCase();
    
    return qrGallery.where((qrItem) {
      final assetName = (qrItem['assetName'] as String? ?? '').toLowerCase();
      final assetId = (qrItem['assetId'] as dynamic).toString().toLowerCase();
      
      return assetName.contains(lowercaseQuery) || 
             assetId.contains(lowercaseQuery);
    }).toList();
  }
  
  // Filter QR gallery by missing files
  List<Map<String, dynamic>> filterMissingFiles() {
    return qrGallery.where((qrItem) => 
      qrItem['fileNotFound'] == true).toList();
  }
  
  // Method to export all QR codes to a single PDF
  Future<String?> exportAllQrCodesToPdf() async {
    try {
      if (qrGallery.isEmpty) {
        logger.w('No QR codes to export');
        return null;
      }
      
      // This would be implemented with the pdf package as seen in AssetFormController
      // For brevity, I'm leaving the implementation details out
      // The implementation would:
      // 1. Create a PDF with multiple pages (one QR code per page or multiple per page)
      // 2. Save the PDF to the documents directory
      // 3. Return the file path
      
      logger.i('Export all QR codes to PDF not implemented');
      return null;
    } catch (e) {
      logger.e('Error exporting QR codes to PDF: $e');
      return null;
    }
  }
  
  @override
  void onClose() {
    // Close Hive box when service is disposed
    _qrBox.close();
    super.onClose();
  }
}