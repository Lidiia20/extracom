class Nota {
  final int id;
  final String tanggalUpload;
  final String noInventaris;
  final String namaBarang;
  final String namaFile;
  final String? imageData; // Base64 string
  final String mimeType;

  Nota({
    required this.id,
    required this.tanggalUpload,
    required this.noInventaris,
    required this.namaBarang,
    required this.namaFile,
    this.imageData,
    required this.mimeType,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: json['ID'],
      tanggalUpload: json['TanggalUpload'] ?? '',
      noInventaris: json['NoInventaris'] ?? '',
      namaBarang: json['NamaBarang'] ?? '',
      namaFile: json['NamaFile'] ?? '',
      imageData: json['Base64Image'],
      mimeType: json['MimeType'] ?? 'image/jpeg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TanggalUpload': tanggalUpload,
      'NoInventaris': noInventaris,
      'NamaBarang': namaBarang,
      'NamaFile': namaFile,
      'Base64Image': imageData,
      'MimeType': mimeType,
    };
  }
}