import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asset_data_controller.dart';
import '../controllers/asset_detail_controller.dart';
import '../models/asset_model.dart';
import '../../../routes/app_pages.dart';
import '../providers/asset_api_provider.dart';

class AssetDataView extends GetView<AssetDataController> {
  const AssetDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAssets(),
          ),
          // Tambahkan tombol untuk menambah aset baru
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.ADD_ASSET),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari aset...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.filterAssets('');
                        },
                      )
                    : const SizedBox.shrink()),
              ),
              onChanged: (value) => controller.filterAssets(value),
            ),
          ),
          
          // Data Aset
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${controller.errorMessage.value}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.refreshAssets(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.filteredAssets.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada data aset yang ditemukan',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.refreshAssets(),
                child: ListView.builder(
                  itemCount: controller.filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = controller.filteredAssets[index];
                    return _buildAssetCard(asset, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssetCard(Asset asset, AssetDataController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail dengan passing object asset
          _navigateToDetail(asset);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      asset.namaBarang ?? 'Tidak ada nama',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Tambahkan popup menu untuk edit dan hapus
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'detail') {
                        _navigateToDetail(asset);
                      } else if (value == 'edit') {
                        _navigateToEdit(asset);
                      } else if (value == 'delete') {
                        controller.confirmDeleteAsset(asset);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('Detail'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('No. Inventaris', asset.noInventarisBarang),
                        _buildInfoRow('Merk/Type', '${asset.merk ?? '-'} / ${asset.type ?? '-'}'),
                        _buildInfoRow('Serial Number', asset.serialNumber),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Pengguna', asset.namaPengguna),
                        _buildInfoRow('Unit', asset.unit),
                        _buildInfoRow('Ruangan', asset.namaRuangan),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  // Fungsi untuk navigasi ke detail yang aman
  void _navigateToDetail(Asset asset) {
    try {
      // Pastikan AssetDetailController sudah terdaftar
      if (!Get.isRegistered<AssetDetailController>()) {
        Get.put(AssetDetailController());
      }
      
      // Navigasi ke halaman detail dengan passing object asset
      Get.toNamed(Routes.ASSET_DETAIL, arguments: asset);
    } catch (e) {
      print('Error navigating to detail: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membuka detail: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Fungsi untuk navigasi ke form edit yang aman
  void _navigateToEdit(Asset asset) {
    try {
      Get.toNamed(Routes.EDIT_ASSET, arguments: asset);
    } catch (e) {
      print('Error navigating to edit: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membuka form edit: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}