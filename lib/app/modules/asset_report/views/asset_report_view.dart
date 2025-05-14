import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asset_report_controller.dart';

class AssetReportView extends GetView<AssetReportController> {
  const AssetReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Aset'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Laporan',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        // Reset Filter Button
                        ElevatedButton.icon(
                          onPressed: () => controller.resetFilters(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Filter Bidang
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Bidang (Lokasi):'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Obx(() => DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            value: controller.selectedBidang.value.isEmpty ? null : controller.selectedBidang.value,
                            hint: const Text('Pilih Bidang'),
                            items: controller.bidangList
                                .map((bidang) => DropdownMenuItem(
                                      value: bidang,
                                      child: Text(bidang),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              controller.selectedBidang.value = value ?? '';
                              controller.filterAssets();
                            },
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Filter Kategori
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Kategori:'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Obx(() => DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            value: controller.selectedKategori.value.isEmpty ? null : controller.selectedKategori.value,
                            hint: const Text('Pilih Kategori'),
                            items: controller.kategoriList
                                .map((kategori) => DropdownMenuItem(
                                      value: kategori,
                                      child: Text(kategori),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              controller.selectedKategori.value = value ?? '';
                              controller.filterAssets();
                            },
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Filter Kondisi
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Kondisi:'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Obx(() => DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            value: controller.selectedKondisi.value.isEmpty ? null : controller.selectedKondisi.value,
                            hint: const Text('Pilih Kondisi'),
                            items: controller.kondisiList
                                .map((kondisi) => DropdownMenuItem(
                                      value: kondisi,
                                      child: Text(kondisi),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              controller.selectedKondisi.value = value ?? '';
                              controller.filterAssets();
                            },
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Result and Export Section
            Obx(() => Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Hasil Filter: ${controller.filteredAssets.length} aset',
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        // Export buttons
                        Wrap(
                          spacing: 8,
                          children: [
                            // Export to PDF button
                            ElevatedButton.icon(
                              onPressed: controller.filteredAssets.isEmpty 
                                  ? null 
                                  : () => controller.exportToPdf(),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                            
                            // Export to CSV button
                            ElevatedButton.icon(
                              onPressed: controller.filteredAssets.isEmpty 
                                  ? null 
                                  : () => controller.exportToCsv(),
                              icon: const Icon(Icons.table_chart),
                              label: const Text('CSV'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Summary Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Filter:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text('Bidang:'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    controller.selectedBidang.value.isEmpty
                                        ? 'Semua Bidang'
                                        : controller.selectedBidang.value,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text('Kategori:'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    controller.selectedKategori.value.isEmpty
                                        ? 'Semua Kategori'
                                        : controller.selectedKategori.value,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text('Kondisi:'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    controller.selectedKondisi.value.isEmpty
                                        ? 'Semua Kondisi'
                                        : controller.selectedKondisi.value,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Asset List Preview
                    controller.filteredAssets.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Tidak ada data yang sesuai dengan filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.filteredAssets.length > 5 
                                ? 5 
                                : controller.filteredAssets.length,
                            itemBuilder: (context, index) {
                              final asset = controller.filteredAssets[index];
                              return AssetListItem(asset: asset);
                            },
                          ),
                    
                    // Show more button if more than 5 assets
                    if (controller.filteredAssets.length > 5)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed('/asset_report_full_list'),
                            icon: const Icon(Icons.list),
                            label: const Text('Lihat Semua Aset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class AssetListItem extends StatelessWidget {
  final dynamic asset;

  const AssetListItem({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          asset.namaBarang ?? 'Tidak ada nama',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${asset.kategori ?? '-'}')),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${asset.kondisi ?? '-'}')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(child: Text('${asset.bidang ?? '-'}, ${asset.namaRuangan ?? '-'}')),
              ],
            ),
            if (asset.noInventarisBarang != null && asset.noInventarisBarang!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('No. Inv: ${asset.noInventarisBarang}'),
                  ],
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${asset.jumlah ?? 0}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}