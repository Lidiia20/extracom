import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import '../../asset_data/models/asset_model.dart';
import '../../asset_data/controllers/asset_data_controller.dart';

class AssetReportController extends GetxController {
  // Reference to AssetDataController
  late AssetDataController assetDataController;
  
  // Filter variables
  final RxString selectedBidang = ''.obs;
  final RxString selectedKategori = ''.obs;
  final RxString selectedKondisi = ''.obs;
  
  // Filter options
  final RxList<String> bidangList = <String>[].obs;
  final RxList<String> kategoriList = <String>[].obs;
  final RxList<String> kondisiList = <String>[].obs;
  
  // Filtered assets
  final RxList<Asset> filteredAssets = <Asset>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize AssetDataController if not already initialized
    if (!Get.isRegistered<AssetDataController>()) {
      Get.put(AssetDataController());
    }
    
    // Get reference to the AssetDataController
    assetDataController = Get.find<AssetDataController>();
    
    // Initialize filter options after data is loaded
    ever(assetDataController.assets, (_) {
      _initializeFilterOptions();
      filterAssets(); // Apply default filters
    });
    
    // If assets are already loaded, initialize filter options immediately
    if (assetDataController.assets.isNotEmpty) {
      _initializeFilterOptions();
      filterAssets();
    }
  }
  
  void _initializeFilterOptions() {
    // Extract unique bidang values
    final uniqueBidang = assetDataController.assets
        .map((asset) => asset.bidang ?? '')
        .where((bidang) => bidang.isNotEmpty)
        .toSet()
        .toList();
    uniqueBidang.sort();
    bidangList.assignAll(uniqueBidang);
    
    // Extract unique kategori values
    final uniqueKategori = assetDataController.assets
        .map((asset) => asset.kategori ?? '')
        .where((kategori) => kategori.isNotEmpty)
        .toSet()
        .toList();
    uniqueKategori.sort();
    kategoriList.assignAll(uniqueKategori);
    
    // Extract unique kondisi values
    final uniqueKondisi = assetDataController.assets
        .map((asset) => asset.kondisi ?? '')
        .where((kondisi) => kondisi.isNotEmpty)
        .toSet()
        .toList();
    uniqueKondisi.sort();
    kondisiList.assignAll(uniqueKondisi);
  }
  
  void filterAssets() {
    final filtered = assetDataController.assets.where((asset) {
      // Check bidang filter
      if (selectedBidang.value.isNotEmpty && asset.bidang != selectedBidang.value) {
        return false;
      }
      
      // Check kategori filter
      if (selectedKategori.value.isNotEmpty && asset.kategori != selectedKategori.value) {
        return false;
      }
      
      // Check kondisi filter
      if (selectedKondisi.value.isNotEmpty && asset.kondisi != selectedKondisi.value) {
        return false;
      }
      
      return true;
    }).toList();
    
    filteredAssets.assignAll(filtered);
  }
  
  void resetFilters() {
    selectedBidang.value = '';
    selectedKategori.value = '';
    selectedKondisi.value = '';
    filterAssets();
  }
  
  Future<void> exportToPdf() async {
    try {
      // Create PDF document
      final pdf = pw.Document();
      
      // Add report title
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Laporan Aset', 
                  style: pw.TextStyle(
                    fontSize: 18, 
                    fontWeight: pw.FontWeight.bold
                  )
                )
              ),
              
              // Add filter information
              pw.Paragraph(
                text: 'Filter yang digunakan:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
              ),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Bidang', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(selectedBidang.value.isEmpty ? 'Semua' : selectedBidang.value)
                      ),
                    ]
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(selectedKategori.value.isEmpty ? 'Semua' : selectedKategori.value)
                      ),
                    ]
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Kondisi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(selectedKondisi.value.isEmpty ? 'Semua' : selectedKondisi.value)
                      ),
                    ]
                  ),
                ]
              ),
              
              pw.SizedBox(height: 20),
              
              // Add assets table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Table header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Nama Barang', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Kondisi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Lokasi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Jumlah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                      ),
                    ]
                  ),
                  
                  // Table rows for each asset
                  ...List.generate(filteredAssets.length, (index) {
                    final asset = filteredAssets[index];
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${index + 1}')
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(asset.namaBarang ?? 'Tidak ada nama')
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(asset.kategori ?? '-')
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(asset.kondisi ?? '-')
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${asset.bidang ?? '-'}, ${asset.namaRuangan ?? '-'}')
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${asset.jumlah ?? 0}')
                        ),
                      ]
                    );
                  })
                ]
              ),
              
              pw.SizedBox(height: 10),
              
              pw.Paragraph(
                text: 'Total Aset: ${filteredAssets.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
              ),
              
              pw.SizedBox(height: 20),
              
              pw.Paragraph(
                text: 'Laporan dibuat pada: ${DateTime.now().toString().substring(0, 19)}',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)
              ),
            ];
          }
        )
      );
      
      // Save the PDF to a file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/laporan_aset_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      // Open the file
      await OpenFile.open(filePath);
      
      // Show success message
      Get.snackbar(
        'Sukses',
        'File PDF berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Gagal membuat file PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  Future<void> exportToCsv() async {
    try {
      // Prepare CSV data
      List<List<dynamic>> csvData = [];
      
      // Add header row
      csvData.add([
        'No',
        'Nama Barang',
        'Kategori',
        'Kondisi',
        'Bidang',
        'Ruangan',
        'Jumlah',
        'Merk',
        'Type',
        'Serial Number',
        'No Inventaris',
        'Nama Pengguna',
        'NIP',
        'Unit',
      ]);
      
      // Add asset rows
      for (int i = 0; i < filteredAssets.length; i++) {
        final asset = filteredAssets[i];
        csvData.add([
          i + 1,
          asset.namaBarang ?? '',
          asset.kategori ?? '',
          asset.kondisi ?? '',
          asset.bidang ?? '',
          asset.namaRuangan ?? '',
          asset.jumlah ?? 0,
          asset.merk ?? '',
          asset.type ?? '',
          asset.serialNumber ?? '',
          asset.noInventarisBarang ?? '',
          asset.namaPengguna ?? '',
          asset.nip ?? '',
          asset.unit ?? '',
        ]);
      }
      
      // Convert to CSV
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Save the CSV to a file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/laporan_aset_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);
      await file.writeAsString(csv);
      
      // Open the file
      await OpenFile.open(filePath);
      
      // Show success message
      Get.snackbar(
        'Sukses',
        'File CSV berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Gagal membuat file CSV: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}