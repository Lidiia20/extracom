// lib/app/modules/asset_data/models/asset_history_model.dart
import 'package:intl/intl.dart';
import 'asset_model.dart';

class AssetHistoryModel {
  final int assetId;
  final String assetName;
  final String action;
  final String? userId;
  final String userName;
  final DateTime timestamp;
  final Map<String, Map<String, dynamic>> changedFields;

  AssetHistoryModel({
    required this.assetId,
    required this.assetName,
    required this.action,
    this.userId,
    required this.userName,
    DateTime? timestamp,
    Map<String, Map<String, dynamic>>? changedFields,
  }) : 
    this.timestamp = timestamp ?? DateTime.now(),
    this.changedFields = changedFields ?? {};

  // Method untuk mendapatkan deskripsi perubahan
  String getChangeDescription() {
    switch (action) {
      case 'Tambah':
        return 'Menambahkan aset baru';
      case 'Edit':
        if (changedFields.isEmpty) {
          return 'Mengubah informasi aset';
        } else {
          final fields = changedFields.keys.map((key) {
            switch (key) {
              case 'name': return 'nama';
              case 'code': return 'kode';
              case 'category': return 'kategori';
              case 'location': return 'lokasi';
              case 'condition': return 'kondisi';
              case 'price': return 'harga';
              case 'purchaseDate': return 'tanggal pembelian';
              default: return key;
            }
          }).join(', ');
          return 'Mengubah $fields';
        }
      case 'Hapus':
        return 'Menghapus aset dari inventaris';
      default:
        return 'Melakukan aksi pada aset';
    }
  }
  
  // Method untuk mendapatkan waktu yang diformat
  String getFormattedDate() {
    return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp);
  }
  
  // Konversi dari JSON
  factory AssetHistoryModel.fromJson(Map<String, dynamic> json) {
    return AssetHistoryModel(
      assetId: json['asset_id'] ?? 0,
      assetName: json['asset_name'] ?? 'Tidak diketahui',
      action: json['action'] ?? 'Tidak diketahui',
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Sistem',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      changedFields: json['changed_fields'] != null 
          ? Map<String, Map<String, dynamic>>.from(
              (json['changed_fields'] as Map).map((key, value) => 
                MapEntry(key.toString(), Map<String, dynamic>.from(value)))
            )
          : {},
    );
  }
  
  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'asset_id': assetId,
      'asset_name': assetName,
      'action': action,
      'user_id': userId,
      'user_name': userName,
      'timestamp': timestamp.toIso8601String(),
      'changed_fields': changedFields,
    };
  }
}

// Alias for backwards compatibility
class AssetHistoryEntry extends AssetHistoryModel {
  AssetHistoryEntry({
    required int assetId,
    required String action,
    String? userId,
    String? userName,
    String? assetName,
    Map<String, Map<String, dynamic>>? changedFields,
    DateTime? timestamp,
  }) : super(
    assetId: assetId,
    assetName: assetName ?? 'Unknown Asset',
    action: action,
    userId: userId,
    userName: userName ?? 'System',
    changedFields: changedFields,
    timestamp: timestamp,
  );
  
  // Copy with method untuk mengubah nilai
  AssetHistoryEntry copyWith({
    int? assetId,
    String? action,
    String? userId,
    String? userName,
    Map<String, Map<String, dynamic>>? changedFields,
  }) {
    return AssetHistoryEntry(
      assetId: assetId ?? this.assetId,
      action: action ?? this.action,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      assetName: this.assetName,
      changedFields: changedFields ?? this.changedFields,
      timestamp: this.timestamp,
    );
  }
  
  // Static method untuk membandingkan dua aset dan menghasilkan field yang berubah
  static Map<String, Map<String, dynamic>> compareAssets(
    Asset? oldAsset, 
    Asset newAsset
  ) {
    if (oldAsset == null) {
      return {}; // Jika aset lama null, tidak dapat membandingkan
    }
    
    final changedFields = <String, Map<String, dynamic>>{};
    
    // Fungsi helper untuk membandingkan dan menyimpan perubahan
    void compareField(String fieldName, dynamic oldValue, dynamic newValue) {
      if (oldValue != newValue) {
        changedFields[fieldName] = {
          'old': oldValue,
          'new': newValue,
        };
      }
    }
    
    // Bandingkan semua field yang relevan
    compareField('namaBarang', oldAsset.namaBarang, newAsset.namaBarang);
    compareField('merk', oldAsset.merk, newAsset.merk);
    compareField('type', oldAsset.type, newAsset.type);
    compareField('serialNumber', oldAsset.serialNumber, newAsset.serialNumber);
    compareField('nip', oldAsset.nip, newAsset.nip);
    compareField('namaPengguna', oldAsset.namaPengguna, newAsset.namaPengguna);
    compareField('unit', oldAsset.unit, newAsset.unit);
    compareField('bidang', oldAsset.bidang, newAsset.bidang);
    compareField('subBidang', oldAsset.subBidang, newAsset.subBidang);
    compareField('namaRuangan', oldAsset.namaRuangan, newAsset.namaRuangan);
    compareField('noInventarisBarang', oldAsset.noInventarisBarang, newAsset.noInventarisBarang);
    compareField('noAktiva', oldAsset.noAktiva, newAsset.noAktiva);
    compareField('jumlah', oldAsset.jumlah, newAsset.jumlah);
    compareField('kondisi', oldAsset.kondisi, newAsset.kondisi);
    compareField('kategori', oldAsset.kategori, newAsset.kategori);
    
    return changedFields;
  }
}