import 'package:get/get.dart';
import '../providers/nota_provider.dart';
import '../models/nota_model.dart';
import 'package:flutter/foundation.dart';

class NotaService extends GetxService {
  final NotaProvider _notaProvider;
  
  NotaService({required NotaProvider notaProvider}) : _notaProvider = notaProvider;

  // Observable state
  final RxList<Nota> notas = <Nota>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  Future<NotaService> init() async {
    await loadNotas();
    return this;
  }
  
  // Upload nota
  Future<Map<String, dynamic>> uploadNota({
    required String notaBase64,
    required String notaFileName,
    required String noInventaris,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _notaProvider.uploadNota(
        notaBase64: notaBase64,
        notaFileName: notaFileName,
        noInventaris: noInventaris,
      );
      
      if (response['status'] == 'success') {
        // Reload notas to update the list
        await loadNotas();
        return {
          'success': true,
          'message': 'Nota berhasil diunggah',
          'notaId': response['notaId'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal mengunggah nota',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in uploadNota service: $e');
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Load all notas
  Future<void> loadNotas() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _notaProvider.getNotas();
      
      if (response['status'] == 'success') {
        final List<dynamic> notasData = response['notas'] ?? [];
        final List<Nota> loadedNotas = notasData
            .map((nota) => Nota.fromJson(nota))
            .toList();
        
        notas.assignAll(loadedNotas);
      } else {
        errorMessage.value = response['message'] ?? 'Gagal memuat data nota';
        if (kDebugMode) {
          print('Failed to load notas: ${response['message']}');
        }
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      if (kDebugMode) {
        print('Error in loadNotas: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get nota by inventaris
  Future<List<Nota>> getNotaByInventaris(String noInventaris) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _notaProvider.getNotaByInventaris(noInventaris);
      
      if (response['status'] == 'success') {
        final List<dynamic> notasData = response['notas'] ?? [];
        return notasData
            .map((nota) => Nota.fromJson(nota))
            .toList();
      } else {
        errorMessage.value = response['message'] ?? 'Gagal memuat data nota';
        if (kDebugMode) {
          print('Failed to load notas by inventaris: ${response['message']}');
        }
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      if (kDebugMode) {
        print('Error in getNotaByInventaris: $e');
      }
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Search nota
  Future<List<Nota>> searchNota(String query) async {
    if (query.isEmpty) {
      return notas;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _notaProvider.searchNota(query);
      
      if (response['status'] == 'success') {
        final List<dynamic> notasData = response['notas'] ?? [];
        return notasData
            .map((nota) => Nota.fromJson(nota))
            .toList();
      } else {
        errorMessage.value = response['message'] ?? 'Gagal mencari data nota';
        if (kDebugMode) {
          print('Failed to search notas: ${response['message']}');
        }
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      if (kDebugMode) {
        print('Error in searchNota: $e');
      }
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get nota image
  Future<Map<String, dynamic>> getNotaImage(String notaId) async {
    try {
      isLoading.value = true;
      
      final response = await _notaProvider.getNotaImage(notaId);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'imageData': response['imageData'],
          'mimeType': response['mimeType'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal memuat gambar nota',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getNotaImage: $e');
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    } finally {
      isLoading.value = false;
    }
  }
}