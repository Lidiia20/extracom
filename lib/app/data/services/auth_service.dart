// auth_service.dart - AuthService menggunakan model User
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../../utils/storage.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StorageUtil _storageUtil = Get.find<StorageUtil>();
  
  // Observable user state menggunakan model User
  final Rx<User?> currentUser = Rx<User?>(null);
  
  // Method init untuk inisialisasi service
  Future<AuthService> init() async {
    await loadUserFromStorage();
    return this;
  }
  
  @override
  void onInit() {
    super.onInit();
    // Periksa apakah ada data user tersimpan
    loadUserFromStorage();
  }
  
  // Load data user dari penyimpanan lokal
  Future<void> loadUserFromStorage() async {
    try {
      final userData = await _storageUtil.getUserData();
      if (userData != null) {
        // Konversi Map ke User model
        currentUser.value = User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  // Fungsi login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Bersihkan data user jika ada
      await _storageUtil.clearUserData();
      currentUser.value = null;
      
      // Kirim permintaan login
      final response = await _apiProvider.login(email, password);
      print('Login response: $response');
      
      // Cek hasil login
      if (response['success'] == true && response['user'] != null) {
        // Simpan data user
        await _storageUtil.saveUserData(response['user']);
        
        // Konversi Map ke User model
        try {
          currentUser.value = User.fromJson(response['user']);
        } catch (e) {
          print('Error converting user data: $e');
          return {
            'success': false,
            'message': 'Error converting user data: $e'
          };
        }
        
        return {
          'success': true,
          'message': 'Login berhasil'
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Login gagal'
        };
      }
    } catch (e) {
      print('Auth service exception: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }
  
  // Fungsi logout
  Future<void> logout() async {
    try {
      await _storageUtil.clearUserData();
      currentUser.value = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }
  
  // Cek apakah user sedang login
  bool isLoggedIn() {
    return currentUser.value != null;
  }
  
  // Ambil ID user yang sedang login
  String? getUserId() {
    return currentUser.value?.id?.toString();
  }
  
  // Ambil nama user yang sedang login
  String? getUserName() {
    return currentUser.value?.name;
  }
  
  // Ambil email user yang sedang login
  String? getUserEmail() {
    return currentUser.value?.email;
  }
}