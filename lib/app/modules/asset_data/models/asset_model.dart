// lib/app/modules/asset_data/models/asset_model.dart
class Asset {
  final int? no;
  final String? id; // Ubah dari int? ke String? untuk UUID
  final String? namaBarang;
  final String? merk;
  final String? type;
  final String? serialNumber;
  final String? nip;
  final String? namaPengguna;
  final String? unit;
  final String? bidang;
  final String? subBidang;
  final String? namaRuangan;
  final String? noInventarisBarang;
  final String? noAktiva;
  final int? jumlah;
  final String? kondisi;
  final String? kategori;
  final String? qrCodePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Asset({
    this.no,
    this.id,
    this.namaBarang,
    this.merk,
    this.type,
    this.serialNumber,
    this.nip,
    this.namaPengguna,
    this.unit,
    this.bidang,
    this.subBidang,
    this.namaRuangan,
    this.noInventarisBarang,
    this.noAktiva,
    this.jumlah,
    this.kondisi,
    this.kategori,
    this.qrCodePath,
    this.createdAt,
    this.updatedAt,
  });

  // Add copyWith method
  Asset copyWith({
    int? no,
    String? id, // Ubah dari int? ke String?
    String? namaBarang,
    String? merk,
    String? type,
    String? serialNumber,
    String? nip,
    String? namaPengguna,
    String? unit,
    String? bidang,
    String? subBidang,
    String? namaRuangan,
    String? noInventarisBarang,
    String? noAktiva,
    int? jumlah,
    String? kondisi,
    String? kategori,
    String? qrCodePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      no: no ?? this.no,
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      merk: merk ?? this.merk,
      type: type ?? this.type,
      serialNumber: serialNumber ?? this.serialNumber,
      nip: nip ?? this.nip,
      namaPengguna: namaPengguna ?? this.namaPengguna,
      unit: unit ?? this.unit,
      bidang: bidang ?? this.bidang,
      subBidang: subBidang ?? this.subBidang,
      namaRuangan: namaRuangan ?? this.namaRuangan,
      noInventarisBarang: noInventarisBarang ?? this.noInventarisBarang,
      noAktiva: noAktiva ?? this.noAktiva,
      jumlah: jumlah ?? this.jumlah,
      kondisi: kondisi ?? this.kondisi,
      kategori: kategori ?? this.kategori,
      qrCodePath: qrCodePath ?? this.qrCodePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Perbaikan metode fromJson
  factory Asset.fromJson(Map<String, dynamic> json) {
    try {
      return Asset(
        // Field no tidak ada di database dari log
        no: json['no_barang'] != null ? int.tryParse(json['no_barang'].toString()) : null,
        
        // ID dari database adalah string UUID
        id: json['id']?.toString(),
        
        // Field lainnya
        namaBarang: json['nama_barang'],
        merk: json['merk'],
        type: json['type'],
        serialNumber: json['serial_number'],
        nip: json['nip']?.toString(),
        namaPengguna: json['nama_pengguna'],
        unit: json['unit'],
        bidang: json['bidang'],
        subBidang: json['sub_bidang'],
        
        // Sesuaikan dengan nama field di database
        namaRuangan: json['nama_ruangan'],
        noInventarisBarang: json['no_inventaris'],  // Perbaikan nama field
        noAktiva: json['no_aktiva'],
        
        // Penanganan konversi tipe data
        jumlah: json['jumlah'] is String 
            ? int.tryParse(json['jumlah']) 
            : json['jumlah'],
        
        kondisi: json['kondisi'],
        kategori: json['kategori'],
        qrCodePath: json['qr_code_path'],
        
        // Konversi tanggal
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : null,
            
        // Field updated_at mungkin tidak ada di database
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at']) 
             : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing Asset: $e');
      print('Data yang bermasalah: $json');
      print('Stack trace: $stackTrace');
      rethrow; // Re-throw untuk debugging
    }
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'no_barang': no,
      'id': id,
      'nama_barang': namaBarang,
      'merk': merk,
      'type': type,
      'serial_number': serialNumber,
      'nip': nip,
      'nama_pengguna': namaPengguna,
      'unit': unit,
      'bidang': bidang,
      'sub_bidang': subBidang,
      'nama_ruangan': namaRuangan,
      'no_inventaris': noInventarisBarang, // Sesuaikan nama field
      'no_aktiva': noAktiva,
      'jumlah': jumlah,
      'kondisi': kondisi,
      'kategori': kategori,
      'qr_code_path': qrCodePath,
      // 'created_at': createdAt?.toIso8601String(),
      // 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  
}