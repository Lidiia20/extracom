// storage_util.dart - StorageUtil
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageUtil extends GetxService {
  static const String USER_DATA_KEY = 'user_data';
  
  final GetStorage _box = GetStorage();
  
  Future<StorageUtil> init() async {
    await GetStorage.init();
    return this;
  }
  
  // Simpan data user ke storage
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _box.write(USER_DATA_KEY, userData);
      print('User data saved to storage');
    } catch (e) {
      print('Error saving user data: $e');
      throw e;
    }
  }
  
  // Ambil data user dari storage
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = _box.read(USER_DATA_KEY);
      print('Reading user data from storage: $data');
      
      if (data == null) {
        print('No user data found in storage');
        return null;
      }
      
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      } else if (data is String) {
        return json.decode(data);
      }
      
      return null;
    } catch (e) {
      print('Error reading user data: $e');
      return null;
    }
  }
  
  // Hapus data user dari storage
  Future<void> clearUserData() async {
    try {
      print('Clearing user data from storage');
      await _box.remove(USER_DATA_KEY);
      print('User data cleared successfully');
    } catch (e) {
      print('Error clearing user data: $e');
      throw e;
    }
  }
}