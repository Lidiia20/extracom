// lib/app/modules/asset_data/views/asset_detail_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asset_detail_controller.dart';
import '../models/asset_model.dart';

class AssetDetailView extends GetView<AssetDetailController> {
  const AssetDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final AssetDetailController controller;
    
    if (!Get.isRegistered<AssetDetailController>()) {
      Get.put(AssetDetailController());
    }
    
    controller = Get.find<AssetDetailController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aset'),
        backgroundColor: const Color(0xFF12B1B9),
        actions: [
          // Add History button
          Obx(() => controller.asset.value != null
            ? IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Lihat Riwayat',
                onPressed: controller.viewAssetHistory,
              )
            : const SizedBox.shrink()
          ),
          // Add QR Code button
          Obx(() => controller.asset.value?.qrCodePath != null
            ? IconButton(
                icon: const Icon(Icons.qr_code),
                tooltip: 'Lihat QR Code',
                onPressed: controller.showQrCodeDialog,
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data aset...'),
              ],
            ),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.errorMessage.value}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  onPressed: controller.refreshAsset,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        }

        final asset = controller.asset.value;
        if (asset == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  color: Colors.grey,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Data aset tidak ditemukan',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text(
                  'Aset mungkin telah dihapus atau dipindahkan',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard(asset),
              // const SizedBox(height: 20),
              // _buildActionButtons(controller, context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailCard(Asset asset) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with asset name and inventory number
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12B1B9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      _getCategoryIcon(asset.kategori),
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    asset.namaBarang ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${asset.merk ?? ''} ${asset.type ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(asset.kondisi),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      asset.kondisi ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Inventory number chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'No. Inv: ${asset.noInventarisBarang ?? '-'}',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // Information sections
            _buildSectionHeader('Informasi Barang'),
            _buildInfoItem(
              title: 'Serial Number',
              value: asset.serialNumber ?? '-',
              icon: Icons.numbers,
            ),
            _buildInfoItem(
              title: 'No. Aktiva',
              value: asset.noAktiva ?? '-',
              icon: Icons.tag,
            ),
            _buildInfoItem(
              title: 'Jumlah',
              value: asset.jumlah?.toString() ?? '1',
              icon: Icons.pin,
            ),
            _buildInfoItem(
              title: 'Kategori',
              value: asset.kategori ?? '-',
              icon: Icons.category,
            ),
            
            const Divider(height: 24),
            
            // User information section
            _buildSectionHeader('Informasi Pengguna'),
            _buildInfoItem(
              title: 'Nama Pengguna',
              value: asset.namaPengguna ?? '-',
              icon: Icons.person,
            ),
            _buildInfoItem(
              title: 'NIP',
              value: asset.nip ?? '-',
              icon: Icons.badge,
            ),
            _buildInfoItem(
              title: 'Unit',
              value: asset.unit ?? '-',
              icon: Icons.business,
            ),
            _buildInfoItem(
              title: 'Bidang',
              value: asset.bidang ?? '-',
              icon: Icons.account_balance,
            ),
            _buildInfoItem(
              title: 'Sub Bidang',
              value: asset.subBidang ?? '-',
              icon: Icons.account_tree,
            ),
            _buildInfoItem(
              title: 'Ruangan',
              value: asset.namaRuangan ?? '-',
              icon: Icons.meeting_room,
            ),
            
            // QR code path and last updated info
            if (asset.qrCodePath != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Gunakan tombol QR Code di atas untuk melihat atau menyimpan QR code aset.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF12B1B9),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF12B1B9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF12B1B9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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

  // Widget _buildActionButtons(AssetDetailController controller, BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Expanded(
  //         child: ElevatedButton.icon(
  //           icon: const Icon(Icons.edit),
  //           label: const Text('Edit'),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF12B1B9),
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //           ),
  //           onPressed: () => controller.editAsset(),
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: ElevatedButton.icon(
  //           icon: const Icon(Icons.delete),
  //           label: const Text('Hapus'),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //           ),
  //           onPressed: () => controller.confirmDeleteAsset()
  //         ),
  //       ),
  //     ],
  //   );
  // }
  
  // Helper method to get icon based on category
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.devices;
    
    switch (category.toLowerCase()) {
      case 'elektronik':
        return Icons.computer;
      case 'furniture':
        return Icons.chair;
      case 'kendaraan':
        return Icons.directions_car;
      case 'alat tulis':
        return Icons.edit;
      default:
        return Icons.inventory_2;
    }
  }
  
  // Helper method to get status color
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'layak pakai':
        return Colors.green.shade700;
      case 'rusak ringan':
        return Colors.orange;
      case 'rusak':
        return Colors.orange.shade700;
      case 'rusak berat':
        return Colors.red;
      case 'sudah lama':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}