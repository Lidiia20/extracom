import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/nota_model.dart';

class NotaProvider {
  final Dio dio;
  final String baseUrl;

  NotaProvider({
    required this.baseUrl,
    Dio? dioInstance,
  }) : dio = dioInstance ?? Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.plain,
    )
  );

  // Upload nota
  Future<Map<String, dynamic>> uploadNota({
    required String notaBase64,
    required String notaFileName,
    required String noInventaris,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await dio.post(
        baseUrl,
        data: FormData.fromMap({
          'action': 'uploadNota',
          'notaBase64': notaBase64,
          'notaFileName': notaFileName,
          'noInventaris': noInventaris,
          't': timestamp,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final rawResponse = response.data.toString().trim();
      if (kDebugMode) {
        print('Upload nota response: $rawResponse');
      }

      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        return _retryWithGet('uploadNota', {
          'notaBase64': notaBase64,
          'notaFileName': notaFileName,
          'noInventaris': noInventaris,
        });
      }

      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        return responseData;
      } catch (jsonError) {
        if (kDebugMode) {
          print('JSON parsing error: $jsonError');
        }
        return {
          'status': 'error',
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading nota: $e');
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Get all notas
  Future<Map<String, dynamic>> getNotas() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await dio.get(
        baseUrl,
        queryParameters: {
          'action': 'getNotas',
          't': timestamp,
        },
      );

      final rawResponse = response.data.toString().trim();
      if (kDebugMode) {
        print('Get notas response: $rawResponse');
      }

      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons HTML. Pastikan script berjalan dengan benar.'
        };
      }

      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        return responseData;
      } catch (jsonError) {
        if (kDebugMode) {
          print('JSON parsing error: $jsonError');
        }
        return {
          'status': 'error',
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notas: $e');
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Get nota by inventaris
  Future<Map<String, dynamic>> getNotaByInventaris(String noInventaris) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await dio.get(
        baseUrl,
        queryParameters: {
          'action': 'getNotaByInventaris',
          'noInventaris': noInventaris,
          't': timestamp,
        },
      );

      final rawResponse = response.data.toString().trim();
      if (kDebugMode) {
        print('Get nota by inventaris response: $rawResponse');
      }

      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons HTML. Pastikan script berjalan dengan benar.'
        };
      }

      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        return responseData;
      } catch (jsonError) {
        if (kDebugMode) {
          print('JSON parsing error: $jsonError');
        }
        return {
          'status': 'error',
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nota by inventaris: $e');
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Search nota
  Future<Map<String, dynamic>> searchNota(String query) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await dio.get(
        baseUrl,
        queryParameters: {
          'action': 'searchNota',
          'query': query,
          't': timestamp,
        },
      );

      final rawResponse = response.data.toString().trim();
      if (kDebugMode) {
        print('Search nota response: $rawResponse');
      }

      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons HTML. Pastikan script berjalan dengan benar.'
        };
      }

      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        return responseData;
      } catch (jsonError) {
        if (kDebugMode) {
          print('JSON parsing error: $jsonError');
        }
        return {
          'status': 'error',
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching nota: $e');
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Get nota image
  Future<Map<String, dynamic>> getNotaImage(String notaId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await dio.get(
        baseUrl,
        queryParameters: {
          'action': 'getNotaImage',
          'notaId': notaId,
          't': timestamp,
        },
      );

      final rawResponse = response.data.toString().trim();
      if (kDebugMode) {
        print('Get nota image response length: ${rawResponse.length}');
      }

      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons HTML. Pastikan script berjalan dengan benar.'
        };
      }

      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        return responseData;
      } catch (jsonError) {
        if (kDebugMode) {
          print('JSON parsing error: $jsonError');
        }
        return {
          'status': 'error',
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nota image: $e');
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Fungsi untuk mencoba lagi dengan metode GET
  Future<Map<String, dynamic>> _retryWithGet(String action, Map<String, dynamic> params) async {
    try {
      if (kDebugMode) {
        print('Retrying $action with GET method');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      params['action'] = action;
      params['t'] = timestamp;
      
      final response = await dio.get(
        baseUrl,
        queryParameters: params,
      );

      final rawResponse = response.data.toString().trim();
      if (kDebugMode) {
        print('GET retry - Raw response body: ${rawResponse.substring(0, min(100, rawResponse.length))}...');
      }

      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        if (kDebugMode) {
          print('HTML response still detected with GET method');
        }
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons HTML. Pastikan script berjalan dengan benar.'
        };
      }

      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        return responseData;
      } catch (jsonError) {
        if (kDebugMode) {
          print('GET retry - JSON parsing error: $jsonError');
        }
        return {
          'status': 'error',
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('GET retry - Error: $e');
      }
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}