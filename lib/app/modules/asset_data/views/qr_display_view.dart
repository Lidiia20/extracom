import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/asset_model.dart';
import '../controllers/asset_data_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

class QRDisplayView extends StatefulWidget {
  final Asset asset;
  final String qrData;

  const QRDisplayView({
    Key? key,
    required this.asset,
    required this.qrData,
  }) : super(key: key);

  @override
  State<QRDisplayView> createState() => _QRDisplayViewState();
}

class _QRDisplayViewState extends State<QRDisplayView> {
  // Controller for getting reference to QR code for export
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Aset'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _isSaving ? null : _saveQRCode,
            tooltip: 'Simpan QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isSaving ? null : _shareQRCode,
            tooltip: 'Bagikan QR Code',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Asset details header
              Text(
                widget.asset.namaBarang ?? 'Aset',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.asset.noInventarisBarang ?? 'No Inventaris: -',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // QR Code with RepaintBoundary for capture
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: widget.qrData,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      // Add asset identifier text below QR
                      Text(
                        widget.asset.noInventarisBarang ?? widget.asset.serialNumber ?? 'ID: ${widget.asset.id ?? widget.asset.no ?? "-"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Asset details
              _buildAssetDetailsCard(),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.list),
                    label: const Text('Kembali ke Daftar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(result: true),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Aset Baru'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama Barang', widget.asset.namaBarang),
            _buildDetailRow('Merk', widget.asset.merk),
            _buildDetailRow('Tipe', widget.asset.type),
            _buildDetailRow('Serial Number', widget.asset.serialNumber),
            _buildDetailRow('No. Inventaris', widget.asset.noInventarisBarang),
            _buildDetailRow('Pengguna', widget.asset.namaPengguna),
            _buildDetailRow('NIP', widget.asset.nip?.toString()),
            _buildDetailRow('Unit', widget.asset.unit),
            _buildDetailRow('Ruangan', widget.asset.namaRuangan),
            _buildDetailRow('Bidang', widget.asset.bidang),
            _buildDetailRow('Sub Bidang', widget.asset.subBidang),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? '-'),
          ),
        ],
      ),
    );
  }

  // Method to save QR code to device
  Future<void> _saveQRCode() async {
    try {
      setState(() => _isSaving = true);
      
      // Capture the QR code as image
      final imageBytes = await _captureQRCode();
      if (imageBytes == null) {
        Get.snackbar(
          'Error',
          'Gagal mengambil gambar QR code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Get temporary directory
      final directory = await getApplicationDocumentsDirectory();
      final assetName = widget.asset.namaBarang?.replaceAll(' ', '_') ?? 'asset';
      final assetId = widget.asset.noInventarisBarang?.replaceAll(' ', '_') ?? 
                       widget.asset.serialNumber?.replaceAll(' ', '_') ?? 
                       'id_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '${directory.path}/QR_$assetName\_$assetId.png';
      
      // Save image
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      Get.snackbar(
        'Sukses',
        'QR code berhasil disimpan di $filePath',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Method to share QR code
  Future<void> _shareQRCode() async {
    try {
      setState(() => _isSaving = true);
      
      // Capture the QR code as image
      final imageBytes = await _captureQRCode();
      if (imageBytes == null) {
        Get.snackbar(
          'Error',
          'Gagal mengambil gambar QR code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Get temporary directory to store the file
      final directory = await getTemporaryDirectory();
      final assetName = widget.asset.namaBarang?.replaceAll(' ', '_') ?? 'asset';
      final assetId = widget.asset.noInventarisBarang?.replaceAll(' ', '_') ?? 
                     widget.asset.serialNumber?.replaceAll(' ', '_') ?? 
                     'id_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '${directory.path}/QR_$assetName\_$assetId.png';
      
      // Save image temporarily
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'QR Code Aset: ${widget.asset.namaBarang ?? "Aset"}${widget.asset.noInventarisBarang != null ? " - ${widget.asset.noInventarisBarang}" : ""}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membagikan QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Helper method to capture the QR code as image
  Future<Uint8List?> _captureQRCode() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing QR code: $e');
      return null;
    }
  }
}