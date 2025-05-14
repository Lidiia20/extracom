import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../asset_data/models/asset_model.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller terinisialisasi
    final CategoryController controller;
    if (!Get.isRegistered<CategoryController>()) {
      controller = Get.put(CategoryController());
    } else {
      controller = Get.find<CategoryController>();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Aset'),
        backgroundColor: const Color(0xFF12B1B9),
      ),
      body: Column(
        children: [
          // Tab untuk memilih kategori
          Container(
            color: Colors.white,
            child: TabBar(
              controller: controller.tabController,
              labelColor: const Color(0xFF12B1B9),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF12B1B9),
              tabs: const [
                Tab(text: 'Elektronik'),
                Tab(text: 'Furniture'),
              ],
              onTap: (index) {
                controller.currentTabIndex.value = index;
                controller.loadAssetsByCategory(
                  index == 0 ? 'Elektronik' : 'Furniture'
                );
              },
            ),
          ),
          
          // Daftar aset berdasarkan kategori
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.assets.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada aset dalam kategori ${controller.currentTabIndex.value == 0 ? 'Elektronik' : 'Furniture'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.assets.length,
                itemBuilder: (context, index) {
                  final asset = controller.assets[index];
                  return _buildAssetCard(asset);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk menampilkan kartu aset
  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
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
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B1B9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    asset.kategori ?? 'Tidak ada kategori',
                    style: const TextStyle(
                      color: Color(0xFF12B1B9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (asset.merk != null && asset.merk!.isNotEmpty)
              Text('Merk: ${asset.merk}'),
            if (asset.type != null && asset.type!.isNotEmpty)
              Text('Type: ${asset.type}'),
            Text('No. Inventaris: ${asset.noInventarisBarang ?? "-"}'),
            Text('Jumlah: ${asset.jumlah ?? 0}'),
            if (asset.namaPengguna != null && asset.namaPengguna!.isNotEmpty)
              Text('Pengguna: ${asset.namaPengguna}'),
            if (asset.namaRuangan != null && asset.namaRuangan!.isNotEmpty)
              Text('Ruangan: ${asset.namaRuangan}'),
          ],
        ),
      ),
    );
  }
}