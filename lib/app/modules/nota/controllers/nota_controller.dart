import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/nota_service.dart';
import '../models/nota_model.dart';
import 'package:flutter/foundation.dart';

class NotaController extends GetxController {
  final NotaService _notaService = Get.find<NotaService>();
  
  final RxList<Nota> filteredNotas = <Nota>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  
  // For image picking
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString selectedImageName = ''.obs;
  final RxString selectedImageBase64 = ''.obs;
  
  // For searching
  final searchController = TextEditingController();
  
  // For upload in asset detail
  final RxString currentNoInventaris = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotas();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  // Refresh notas
  Future<void> loadNotas() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      await _notaService.loadNotas();
      filteredNotas.assignAll(_notaService.notas);
    } catch (e) {
      errorMessage.value = 'Gagal memuat data nota: $e';
      if (kDebugMode) {
        print('Error loading notas: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Set current noInventaris (for asset detail page)
  void setCurrentNoInventaris(String noInventaris) {
    currentNoInventaris.value = noInventaris;
    loadNotasByInventaris(noInventaris);
  }
  
  // Load notas by inventaris
  Future<void> loadNotasByInventaris(String noInventaris) async {
    if (noInventaris.isEmpty) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final notas = await _notaService.getNotaByInventaris(noInventaris);
      filteredNotas.assignAll(notas);
    } catch (e) {
      errorMessage.value = 'Gagal memuat data nota: $e';
      if (kDebugMode) {
        print('Error loading notas by inventaris: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Search notas
  Future<void> searchNotas(String query) async {
    if (query.isEmpty) {
      await loadNotas();
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final notas = await _notaService.searchNota(query);
      filteredNotas.assignAll(notas);
    } catch (e) {
      errorMessage.value = 'Gagal mencari data nota: $e';
      if (kDebugMode) {
        print('Error searching notas: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Adjust quality (0-100)
      );
      
      if (image != null) {
        selectedImage.value = File(image.path);
        selectedImageName.value = image.name;
        
        // Convert to base64
        final bytes = await selectedImage.value!.readAsBytes();
        selectedImageBase64.value = base64Encode(bytes);
        
        if (kDebugMode) {
          print('Image selected: ${selectedImageName.value}');
          print('Base64 length: ${selectedImageBase64.value.length}');
        }
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih gambar: $e';
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }
  
  // Take a photo
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        selectedImage.value = File(photo.path);
        // Generate a filename with timestamp
        selectedImageName.value = 'nota_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Convert to base64
        final bytes = await selectedImage.value!.readAsBytes();
        selectedImageBase64.value = base64Encode(bytes);
        
        if (kDebugMode) {
          print('Photo taken: ${selectedImageName.value}');
          print('Base64 length: ${selectedImageBase64.value.length}');
        }
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengambil foto: $e';
      if (kDebugMode) {
        print('Error taking photo: $e');
      }
    }
  }
  
  // Clear selected image
  void clearSelectedImage() {
    selectedImage.value = null;
    selectedImageName.value = '';
    selectedImageBase64.value = '';
  }
  
  // Upload nota
  Future<bool> uploadNota({String? customNoInventaris}) async {
    // Validate inputs
    final noInventaris = customNoInventaris ?? currentNoInventaris.value;
    
    if (noInventaris.isEmpty) {
      errorMessage.value = 'Nomor inventaris harus diisi';
      return false;
    }
    
    if (selectedImageBase64.value.isEmpty) {
      errorMessage.value = 'Silakan pilih gambar nota terlebih dahulu';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    
    try {
      final result = await _notaService.uploadNota(
        notaBase64: selectedImageBase64.value,
        notaFileName: selectedImageName.value,
        noInventaris: noInventaris,
      );
      
      if (result['success']) {
        successMessage.value = result['message'];
        clearSelectedImage();
        
        // Reload notas
        if (noInventaris.isNotEmpty) {
          await loadNotasByInventaris(noInventaris);
        } else {
          await loadNotas();
        }
        
        return true;
      } else {
        errorMessage.value = result['message'];
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengunggah nota: $e';
      if (kDebugMode) {
        print('Error uploading nota: $e');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get nota image for display
  Future<Map<String, dynamic>> getNotaImage(String notaId) async {
    try {
      return await _notaService.getNotaImage(notaId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nota image: $e');
      }
      return {
        'success': false,
        'message': 'Gagal memuat gambar nota: $e',
      };
    }
  }
}