import 'package:dio/dio.dart';
import 'dart:convert';

class ApiProvider {
  final Dio dio;
  // Ganti URL dengan URL aktif dari script Anda
  final String baseUrl = 'https://script.google.com/macros/s/AKfycbwqxVmg7t2qT1s2YygywzkajJKFa6i83pH2OdT6E11v_YC_Ov4f_BV74hcK9E-Uyd1HwA/exec';

  ApiProvider({Dio? dioInstance}) : dio = dioInstance ?? Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),  // Ditambah timeoutnya
      receiveTimeout: const Duration(seconds: 15),  // Ditambah timeoutnya
      responseType: ResponseType.plain, // Penting untuk mengatasi masalah respons
    )
  );

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login for $email');
      
      // Tambahkan random parameter untuk menghindari caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final response = await dio.get(
        baseUrl,
        queryParameters: {
          'action': 'login',
          'email': email,
          'password': password,
          't': timestamp, // Parameter anti-cache
        },
      );

      print('Response status: ${response.statusCode}');
      
      // Cek apakah respons kosong
      if (response.data == null || response.data.toString().trim().isEmpty) {
        print('Empty response received');
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons kosong.'
        };
      }
      
      // Log respons mentah untuk debugging
      final rawResponse = response.data.toString().trim();
      print('Raw response body: ${rawResponse}');

      // Cek apakah respons mengandung HTML
      if (rawResponse.startsWith('<!DOCTYPE html>') || rawResponse.startsWith('<html>')) {
        print('HTML response detected');
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons HTML. Pastikan script berjalan dengan benar.'
        };
      }

      // Parsing JSON dengan penanganan kesalahan
      try {
        final Map<String, dynamic> responseData = json.decode(rawResponse);
        
        // Log data yang berhasil di-parse
        print('Login response: $responseData');
        
        // Periksa status di respons
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'user': responseData['user']
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login gagal'
          };
        }
      } catch (jsonError) {
        print('JSON parsing error: $jsonError');
        
        return {
          'success': false,
          'message': 'Gagal memproses respons server: $jsonError'
        };
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Dio error type: ${e.type}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      
      return {
        'success': false,
        'message': 'Koneksi gagal: ${e.message}'
      };
    } catch (e) {
      print('Login failed: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }
}