// asset_history_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/asset_history_model.dart';
import '../services/asset_history_service.dart';


class AssetHistoryController extends GetxController {
  // Instance service
  final AssetHistoryService _historyService = AssetHistoryService.to;
  
  // List riwayat
  final RxList<AssetHistoryModel> _allHistories = <AssetHistoryModel>[].obs;
  final RxList<AssetHistoryModel> displayedHistories = <AssetHistoryModel>[].obs;
  
  // Status loading
  final RxBool isLoading = false.obs;
  
  // Filter-related reactive variables
  final RxString selectedAction = ''.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString searchQuery = ''.obs;
  
  // List untuk filter aksi
  final List<String> actionFilters = [
    'Semua',
    'Tambah',
    'Edit',
    'Hapus',
  ];
  
  @override
  void onInit() {
    super.onInit();
    loadHistories();
  }
  
  // Method untuk memuat riwayat dari service
  Future<void> loadHistories() async {
    isLoading.value = true;
    
    try {
      _allHistories.value = await _historyService.getAllHistories();
      
      // Urutkan riwayat (terbaru di atas)
      _allHistories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Terapkan filter yang ada
      filterHistories();
    } catch (e) {
      // Using logger is better than print, but keeping for compatibility
      // ignore: avoid_print
      print('Error loading histories: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data riwayat aset',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Menerapkan filter ke daftar riwayat
  void filterHistories() {
    displayedHistories.value = _allHistories.where((history) {
      // Filter berdasarkan aksi
      bool actionMatch = selectedAction.value.isEmpty || 
                       selectedAction.value == 'Semua' || 
                       history.action == selectedAction.value;
      
      // Filter berdasarkan tanggal mulai
      bool startDateMatch = startDate.value == null || 
                          history.timestamp.isAfter(
                            startDate.value!.subtract(const Duration(seconds: 1))
                          );
      
      // Filter berdasarkan tanggal selesai
      bool endDateMatch = endDate.value == null || 
                        history.timestamp.isBefore(
                          endDate.value!.add(const Duration(days: 1))
                        );
      
      // Filter berdasarkan kata kunci pencarian
      bool searchMatch = searchQuery.value.isEmpty || 
                       history.userName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                       history.assetName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                       history.getChangeDescription().toLowerCase().contains(searchQuery.value.toLowerCase());
      
      return actionMatch && startDateMatch && endDateMatch && searchMatch;
    }).toList();
  }
  
  // Method untuk mengatur pencarian
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterHistories();
  }
  
  // Method untuk memilih tanggal mulai
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      startDate.value = picked;
      filterHistories();
    }
  }
  
  // Method untuk memilih tanggal selesai
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      endDate.value = picked;
      filterHistories();
    }
  }
  
  // Method untuk mereset semua filter
  void resetFilter() {
    selectedAction.value = '';
    startDate.value = null;
    endDate.value = null;
    searchQuery.value = '';
    filterHistories();
  }
  
  // Method untuk menampilkan detail riwayat
  void showHistoryDetails(AssetHistoryModel history) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getActionIcon(history.action),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Riwayat ${history.action}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          history.getFormattedDate(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailItem(
                'Aset', 
                history.assetName,
                Icons.inventory,
              ),
              _buildDetailItem(
                'Aksi', 
                history.action,
                _getIconData(history.action),
              ),
              _buildDetailItem(
                'Pengguna', 
                history.userName,
                Icons.person,
              ),
              _buildDetailItem(
                'Waktu', 
                DateFormat('dd MMMM yyyy, HH:mm').format(history.timestamp),
                Icons.access_time,
              ),
              
              const SizedBox(height: 8),
              const Text(
                'Detail Perubahan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              // Jika tidak ada perubahan spesifik yang tercatat
              if (history.changedFields.isEmpty)
                const Text('Tidak ada detail perubahan yang tersedia'),
              
              // Jika ada perubahan, tampilkan dalam format tabel
              if (history.changedFields.isNotEmpty)
                _buildChangesTable(history),
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget untuk item detail
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk tabel perubahan
  Widget _buildChangesTable(AssetHistoryModel history) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header tabel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Field',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Nilai Lama',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Nilai Baru',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Isi tabel
          ...history.changedFields.entries.map((entry) {
            final fieldName = entry.key;
            final displayName = _getFieldDisplayName(fieldName);
            final oldValue = entry.value['old']?.toString() ?? '-';
            final newValue = entry.value['new']?.toString() ?? '-';
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(displayName),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      oldValue,
                      style: TextStyle(
                        color: Colors.red[800],
                        decoration: history.action == 'Tambah' ? TextDecoration.none : null,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      newValue,
                      style: TextStyle(
                        color: Colors.green[800],
                        decoration: history.action == 'Hapus' ? TextDecoration.none : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  // Helper untuk mendapatkan nama tampilan dari nama field
  String _getFieldDisplayName(String fieldName) {
    switch (fieldName) {
      case 'name': return 'Nama';
      case 'code': return 'Kode';
      case 'category': return 'Kategori';
      case 'location': return 'Lokasi';
      case 'condition': return 'Kondisi';
      case 'price': return 'Harga';
      case 'purchaseDate': return 'Tanggal Pembelian';
      case 'description': return 'Deskripsi';
      case 'namaBarang': return 'Nama Barang';
      case 'merk': return 'Merk';
      case 'type': return 'Tipe';
      case 'serialNumber': return 'Serial Number';
      case 'nip': return 'NIP';
      case 'namaPengguna': return 'Nama Pengguna';
      case 'unit': return 'Unit';
      case 'bidang': return 'Bidang';
      case 'subBidang': return 'Sub Bidang';
      case 'namaRuangan': return 'Nama Ruangan';
      case 'noInventarisBarang': return 'Nomor Inventaris';
      case 'noAktiva': return 'Nomor Aktiva';
      case 'jumlah': return 'Jumlah';
      case 'kategori': return 'Kategori';
      default: return fieldName.replaceFirst(fieldName[0], fieldName[0].toUpperCase());
    }
  }
  
  // Helper untuk mendapatkan icon aksi
  IconData _getIconData(String action) {
    switch (action) {
      case 'Tambah': return Icons.add_circle;
      case 'Edit': return Icons.edit;
      case 'Hapus': return Icons.delete;
      default: return Icons.history;
    }
  }
  
  // Helper untuk widget icon aksi
  Widget _getActionIcon(String action) {
    IconData iconData = _getIconData(action);
    Color color;
    
    switch (action) {
      case 'Tambah':
        color = Colors.green;
        break;
      case 'Edit':
        color = Colors.blue;
        break;
      case 'Hapus':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
}