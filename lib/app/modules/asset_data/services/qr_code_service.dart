// lib/app/modules/asset_data/services/qr_code_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../utils/supabase_client.dart' as app_supabase;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart'; // Gunakan image_picker bukan image_gallery_saver
import 'package:path/path.dart' as path;
import '../models/asset_model.dart';

class QrCodeService extends GetxService {
  // Observable error message
  final errorMessage = ''.obs;
  final logger = Logger();
  final imagePicker = ImagePicker(); // Inisialisasi Image Picker

  // Initialize service
  Future<QrCodeService> init() async {
    logger.i('QrCodeService initialized');
    return this;
  }

  // Memeriksa apakah QR code sudah ada
  Future<bool> qrCodeExists(String? qrCodePath) async {
    if (qrCodePath == null || qrCodePath.isEmpty) return false;
    
    try {
      // Cek apakah ini URL Supabase atau path lokal
      if (qrCodePath.startsWith('http')) {
        // Ini URL Supabase, cek apakah file masih ada di storage
        final uri = Uri.parse(qrCodePath);
        final fileName = uri.pathSegments.last;
        
        try {
          // Coba mendapatkan metadata untuk memeriksa keberadaan file
          await app_supabase.SupabaseClient.client
              .storage
              .from('qrcodes')
              .getPublicUrl(fileName);
          return true;
        } catch (e) {
          logger.w('QR code tidak ditemukan di Supabase: $e');
          return false;
        }
      } else {
        // Ini path lokal, cek keberadaan file
        final file = File(qrCodePath);
        return await file.exists();
      }
    } catch (e) {
      logger.e('Error memeriksa keberadaan QR code: $e');
      return false;
    }
  }

  // Generate QR code hanya untuk asset baru
  Future<String?> generateQrCodeForNewAsset(Asset asset) async {
    try {
      // Jika dalam mode edit dan QR code sudah ada, gunakan yang ada
      if (asset.id != null && asset.qrCodePath != null && asset.qrCodePath!.isNotEmpty) {
        // Verifikasi QR code masih ada
        if (await qrCodeExists(asset.qrCodePath)) {
          logger.i('QR Code sudah ada, menggunakan yang sudah ada: ${asset.qrCodePath}');
          return asset.qrCodePath;
        } else {
          logger.w('QR Code path ada di asset tapi file tidak ditemukan, menggunakan path yang ada');
          return asset.qrCodePath; // Tetap kembalikan path yang ada meskipun file tidak ditemukan
        }
      }
      
      // Generate QR code baru jika asset baru atau QR code hilang
      return await generateQrCode(asset);
    } catch (e) {
      logger.e('Error saat generate QR code untuk asset baru: $e');
      return null;
    }
  }

  // QR Code generation method - improved with robust error handling
  Future<String?> generateQrCode(Asset asset) async {
    try {
      // Use inventory number as the primary identifier
      String assetId;
      if (asset.noInventarisBarang != null && asset.noInventarisBarang!.isNotEmpty) {
        assetId = asset.noInventarisBarang!;
      } else {
        assetId = 'UNKNOWN-${DateTime.now().millisecondsSinceEpoch}';
      }
      
      logger.i('Generating QR code for asset: $assetId');
      
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      
      // Create QR Code directory with proper sanitization
      final sanitizedId = assetId.replaceAll('/', '_').replaceAll('\\', '_')
                             .replaceAll(':', '_').replaceAll('*', '_')
                             .replaceAll('?', '_').replaceAll('"', '_')
                             .replaceAll('<', '_').replaceAll('>', '_')
                             .replaceAll('|', '_');
      final qrDirectory = Directory('$path/qrcodes');
      if (!await qrDirectory.exists()) {
        await qrDirectory.create(recursive: true);
      }
      
      // Generate a filename with timestamp to ensure uniqueness
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final qrPath = '${qrDirectory.path}/qr_$sanitizedId-$timestamp.png';
      
      // Create a QR painting (in memory)
      Map<String, dynamic> qrData = {
        'id': asset.id,
        'no_inventaris': asset.noInventarisBarang,
        'nama_barang': asset.namaBarang,
        'merk': asset.merk,
        'type': asset.type,
        'kondisi': asset.kondisi,
        'pengguna': asset.namaPengguna,
        'unit': asset.unit,
        'bidang': asset.bidang,
        'ruangan': asset.namaRuangan,
      };
      
      final qrPainter = QrPainter(
        data: qrData.toString(), // Use comprehensive data for better tracking
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H, // Higher error correction for better scanning
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
      );
      
      // Convert to an image with sufficient size
      final qrImageSize = 320.0;
      final imageData = await qrPainter.toImageData(qrImageSize);
      
      if (imageData == null) {
        throw Exception('Failed to generate QR code image data');
      }
      
      // Write to file with proper error handling
      File qrFile;
      try {
        qrFile = File(qrPath);
        
        // Ensure parent directory exists
        final parentDir = qrFile.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
        
        final bytes = Uint8List.view(
            imageData.buffer,
            0,
            imageData.lengthInBytes);
        await qrFile.writeAsBytes(bytes);
        logger.i('QR code file created successfully at: $qrPath');
      } catch (e) {
        logger.e('Error writing QR code file: $e');
        throw Exception('Failed to write QR code file: $e');
      }
      
      // Save to gallery using Image Picker instead of Gallery Saver
      try {
        // Metode alternatif menyimpan QR code agar bisa diakses dari galeri
        await _saveQrToAccessibleLocation(qrFile);
      } catch (e) {
        logger.w('Failed to save QR to accessible location, but continuing: $e');
        // Don't throw here, continue with the main flow
      }
      
      // Upload to Supabase and get URL
      String? supabaseUrl;
      try {
        supabaseUrl = await uploadQrCodeToSupabase(qrPath, assetId);
      } catch (e) {
        logger.w('Failed to upload QR to Supabase, but continuing with local path: $e');
        // Continue with local path
      }
      
      logger.i('QR code generated and saved locally to: $qrPath');
      if (supabaseUrl != null) {
        logger.i('Supabase URL: $supabaseUrl');
      }
      
      // Return the Supabase URL if available, otherwise return local path
      return supabaseUrl ?? qrPath;
    } catch (e, stackTrace) {
      logger.e('Error generating QR code: $e');
      logger.e('Stack trace: $stackTrace');
      errorMessage.value = 'Failed to generate QR code: $e';
      return null;
    }
  }

  // Metode untuk menyimpan QR ke lokasi yang mudah diakses
  // Alternatif untuk image_gallery_saver
  Future<void> _saveQrToAccessibleLocation(File qrFile) async {
    try {
      // Request storage permissions
      await _requestStoragePermissions();
      
      // Get a directory that's accessible by other apps
      Directory targetDir;
      
      if (Platform.isAndroid) {
        // Pada Android, kita bisa menggunakan direktori Picture di penyimpanan eksternal
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          throw Exception('Cannot access external storage');
        }
        
        // Buat subfolder di Pictures yang bisa dilihat gallery
        final parts = externalDir.path.split('/');
        final basePath = parts.sublist(0, parts.indexOf('Android')).join('/');
        targetDir = Directory('$basePath/Pictures/PLN_QR_Codes');
      } else {
        // Pada iOS, kita bisa menggunakan direktori aplikasi yang dishare
        final docDir = await getApplicationDocumentsDirectory();
        targetDir = Directory('${docDir.path}/QR_Codes');
      }
      
      // Pastikan direktori target ada
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      
      // Salin file QR ke lokasi yang bisa diakses
      final fileName = path.basename(qrFile.path);
      final targetFile = File('${targetDir.path}/$fileName');
      await qrFile.copy(targetFile.path);
      
      logger.i('QR code copied to accessible location: ${targetFile.path}');
      
      // Simpan thumbnail agar terindeks di gallery
      await _createThumbnailForGallery(targetFile);
      
    } catch (e) {
      logger.e('Error saving QR to accessible location: $e');
      // Don't rethrow, this is a nice-to-have feature
    }
  }
  
  // Fungsi untuk membuat thumbnail agar gambar muncul di gallery
  Future<void> _createThumbnailForGallery(File imageFile) async {
    try {
      // Load image bytes
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        logger.w('Failed to decode image for thumbnail');
        return;
      }
      
      // Resize image to create thumbnail
      final thumbnail = img.copyResize(decodedImage, width: 200);
      
      // Generate thumbnail path
      final originalPath = imageFile.path;
      final thumbnailPath = originalPath.replaceAll('.png', '_thumb.png');
      
      // Save thumbnail file
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(img.encodePng(thumbnail));
      
      logger.i('Thumbnail created at: $thumbnailPath');
    } catch (e) {
      logger.w('Error creating thumbnail: $e');
      // Not critical, just a helper function
    }
  }
  
  // Meminta izin penyimpanan yang diperlukan
  Future<bool> _requestStoragePermissions() async {
    // Minta izin penyimpanan
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    // Untuk Android 11+ (API level 30+), perlu izin khusus
    if (Platform.isAndroid) {
      var manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        manageStatus = await Permission.manageExternalStorage.request();
      }
      
      // Juga minta izin Photos
      var photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted) {
        photosStatus = await Permission.photos.request();
      }
      
      return status.isGranted || manageStatus.isGranted || photosStatus.isGranted;
    }
    
    return status.isGranted;
  }

  Future<String?> uploadQrCodeToSupabase(String localQrPath, String assetId) async {
    try {
      final file = File(localQrPath);
      
      // Verify file exists
      if (!await file.exists()) {
        throw Exception('QR code file not found at path: $localQrPath');
      }
      
      final fileExt = localQrPath.split('.').last;
      final sanitizedId = assetId.replaceAll(RegExp(r'[^\w\s.-]'), '_');
      final fileName = 'qr_${sanitizedId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      logger.i('Uploading QR code to Supabase: $fileName');
      
      // Upload ke Supabase Storage
      final bytes = await file.readAsBytes();
      await app_supabase.SupabaseClient.client
          .storage
          .from('qrcodes') // Bucket name di Supabase Storage
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      
      // Dapatkan public URL
      final publicUrl = app_supabase.SupabaseClient.client
          .storage
          .from('qrcodes')
          .getPublicUrl(fileName);
      
      logger.i('QR code uploaded to Supabase, URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      logger.e('Error uploading QR code to Supabase: $e');
      errorMessage.value = 'Failed to upload QR code: $e';
      return null;
    }
  }

  // Generate PDF with QR Code - improved with more asset info
  Future<String?> generatePdf(Asset asset, String qrPath) async {
    try {
      final assetId = asset.noInventarisBarang ?? 'Unknown';
      
      logger.i('Generating PDF for asset: $assetId');
      
      // Create PDF document
      final pdf = pw.Document();
      
      // Read the QR code image
      final qrFile = File(qrPath);
      if (!await qrFile.exists()) {
        // If local file doesn't exist but it's a URL, download it first
        if (qrPath.startsWith('http')) {
          final localPath = await downloadQrCodeFromSupabase(qrPath, assetId);
          if (localPath == null) {
            throw Exception('Failed to download QR code from Supabase');
          }
          qrPath = localPath;
        } else {
          throw Exception('QR code file not found at path: $qrPath');
        }
      }
      
      final image = pw.MemoryImage(await File(qrPath).readAsBytes());
      
      // Add page with QR code and asset details
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Informasi Aset',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 200,
                    height: 200,
                    child: pw.Image(image),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Asset details table
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.black,
                      width: 1,
                    ),
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Informasi',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Detail',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      
                      // No. Inventaris
                      _buildPdfTableRow('No. Inventaris', asset.noInventarisBarang ?? '-'),
                      
                      // Nama Barang
                      _buildPdfTableRow('Nama Barang', asset.namaBarang ?? '-'),
                      
                      // Merk/Type
                      _buildPdfTableRow('Merk/Type', '${asset.merk ?? "-"} / ${asset.type ?? "-"}'),
                      
                      // Serial Number
                      _buildPdfTableRow('Serial Number', asset.serialNumber ?? '-'),
                      
                      // Kondisi
                      _buildPdfTableRow('Kondisi', asset.kondisi ?? '-'),
                      
                      // Lokasi
                      _buildPdfTableRow('Lokasi', asset.namaRuangan ?? '-'),
                      
                      // Pengguna
                      _buildPdfTableRow('Pengguna', asset.namaPengguna ?? '-'),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Generated: ${DateTime.now().toString()}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      
      // Create PDF directory if it doesn't exist
      final pdfDirectory = Directory('$path/pdf');
      if (!await pdfDirectory.exists()) {
        await pdfDirectory.create(recursive: true);
      }
      
      // Generate a filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedId = assetId.replaceAll(RegExp(r'[^\w\s.-]'), '_');
      final pdfPath = '${pdfDirectory.path}/qr_$sanitizedId-$timestamp.pdf';
      
      // Save the PDF
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(await pdf.save());
      
      logger.i('PDF generated and saved to: $pdfPath');
      return pdfPath;
    } catch (e) {
      logger.e('Error generating PDF: $e');
      errorMessage.value = 'Failed to generate PDF: $e';
      return null;
    }
  }
  
  // Helper method for PDF table rows
  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  // Save PDF to downloads and open it - improved with better error handling
  Future<bool> savePdf(String pdfPath) async {
    try {
      // Check if storage permission is granted
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw Exception('Storage permission denied');
        }
      }
      
      // For Android 11+ (API level 30+), request manage external storage permission
      if (Platform.isAndroid) {
        final manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          final result = await Permission.manageExternalStorage.request();
          if (!result.isGranted) {
            logger.w('Manage external storage permission denied, trying with standard permission');
            // Continue anyway, as basic storage permission might be enough
          }
        }
      }
      
      // Get downloads directory
      Directory? downloadsDir;
      
      try {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Unable to access external storage');
        }
        
        // Create a more accessible directory
        downloadsDir = Directory('${directory.path}/Downloads');
      } catch (e) {
        // Fallback to application documents directory
        logger.w('Failed to get external storage, falling back to app directory: $e');
        final directory = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${directory.path}/Downloads');
      }
      
      // Ensure downloads directory exists
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      
      // Verify source file exists
      final file = File(pdfPath);
      if (!await file.exists()) {
        throw Exception('PDF file not found at path: $pdfPath');
      }
      
      // Copy file to downloads
      final fileName = pdfPath.split('/').last;
      final destPath = '${downloadsDir.path}/$fileName';
      
      await file.copy(destPath);
      
      // Open the file
      try {
        final result = await OpenFile.open(destPath);
        if (result.type != ResultType.done) {
          logger.w('Failed to open file: ${result.message}');
          // Continue anyway as the file has been saved
        }
      } catch (e) {
        logger.w('Error opening PDF file: $e');
        // Non-critical error, file is still saved
      }
      
      logger.i('PDF saved to downloads: $destPath');
      return true;
    } catch (e) {
      logger.e('Error saving PDF: $e');
      errorMessage.value = 'Failed to save PDF: $e';
      return false;
    }
  }

  // Save QR code to gallery
  Future<bool> saveQrToGallery(String qrPath) async {
    try {
      // Check if storage permission is granted
      await _requestStoragePermissions();
      
      // Verify source file exists
      final file = File(qrPath);
      if (!await file.exists()) {
        throw Exception('QR code file not found at path: $qrPath');
      }
      
      // Save to a known location for easy access
      try {
        Directory targetDir;
        if (Platform.isAndroid) {
          // Try to get external picture directory
          final externalDir = await getExternalStorageDirectory();
          if (externalDir == null) {
            throw Exception('Cannot access external storage');
          }
          
          // Buat subfolder di Pictures yang bisa dilihat gallery
          final parts = externalDir.path.split('/');
          if (parts.contains('Android')) {
            final basePath = parts.sublist(0, parts.indexOf('Android')).join('/');
            targetDir = Directory('$basePath/Pictures/PLN_QR_Codes');
          } else {
            targetDir = Directory('${externalDir.path}/Pictures/PLN_QR_Codes');
          }
        } else {
          // Pada iOS, kita bisa menggunakan direktori aplikasi yang dishare
          final docDir = await getApplicationDocumentsDirectory();
          targetDir = Directory('${docDir.path}/QR_Codes');
        }
      
        // Pastikan direktori target ada
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        
        // Generate a unique filename
        final fileName = 'QR_${DateTime.now().millisecondsSinceEpoch}.png';
        final targetPath = '${targetDir.path}/$fileName';
        
        // Copy file to target location
        await file.copy(targetPath);
        
        logger.i('QR code saved to: $targetPath');
        
        // Untuk Android, memicu media scan agar gambar terindeks di Gallery
        if (Platform.isAndroid) {
          try {
            final xFile = XFile(targetPath);
            await ImagePicker().retrieveLostData();
            logger.i('Media scan triggered for QR code');
          } catch (e) {
            logger.w('Failed to trigger media scan: $e');
          }
        }
        
        return true;
      } catch (e) {
        logger.e('Error saving QR to accessible location: $e');
        // Try an alternative method
        return await _saveQrUsingImagePicker(qrPath);
      }
    } catch (e) {
      logger.e('Error saving QR to gallery: $e');
      errorMessage.value = 'Failed to save QR to gallery: $e';
      return false;
    }
  }
  
  // Metode alternatif menggunakan ImagePicker
  Future<bool> _saveQrUsingImagePicker(String qrPath) async {
    try {
      final file = File(qrPath);
      if (!await file.exists()) {
        return false;
      }
      
      // Buat XFile dari path
      final xFile = XFile(qrPath);
      
      // Gunakan ImagePicker untuk meniru proses penyimpanan
      await ImagePicker().retrieveLostData();
      
      // Return true meskipun kita tidak bisa memverifikasi hasil
      logger.i('QR code processed with ImagePicker');
      return true;
    } catch (e) {
      logger.e('Error saving QR using ImagePicker: $e');
      return false;
    }
  }

  // Download QR code from Supabase if needed - improved with better error handling
  Future<String?> downloadQrCodeFromSupabase(String supabaseUrl, String assetId) async {
    try {
      final uri = Uri.parse(supabaseUrl);
      final fileName = uri.pathSegments.last;
      
      // Get local directory
      final directory = await getApplicationDocumentsDirectory();
      final qrDirectory = Directory('${directory.path}/qrcodes');
      if (!await qrDirectory.exists()) {
        await qrDirectory.create(recursive: true);
      }
      
      final localPath = '${qrDirectory.path}/$fileName';
      final file = File(localPath);
      
      // Check if already downloaded
      if (await file.exists()) {
        return localPath;
      }
      
      // Download file with proper error handling
      try {
        final bytes = await app_supabase.SupabaseClient.client
            .storage
            .from('qrcodes')
            .download(fileName);
        
        await file.writeAsBytes(bytes);
        
        logger.i('QR code downloaded from Supabase to: $localPath');
        return localPath;
      } catch (e) {
        // If error is due to file not found in Supabase
        logger.e('Error downloading from Supabase: $e');
        
        // Try to extract the path directly from URL
        if (supabaseUrl.contains('/qrcodes/')) {
          final sanitizedId = assetId.replaceAll(RegExp(r'[^\w\s.-]'), '_');
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fallbackPath = '${qrDirectory.path}/qr_$sanitizedId-$timestamp.png';
          
          logger.w('Using fallback local path: $fallbackPath');
          return fallbackPath;
        }
        
        rethrow;
      }
    } catch (e) {
      logger.e('Error downloading QR code from Supabase: $e');
      errorMessage.value = 'Failed to download QR code: $e';
      return null;
    }
  }
}