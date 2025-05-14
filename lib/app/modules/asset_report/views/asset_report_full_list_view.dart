import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asset_report_controller.dart';

class AssetReportFullListView extends GetView<AssetReportController> {
  const AssetReportFullListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lengkap Aset'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Summary Banner
          Obx(() => Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                      children: [
                        const TextSpan(text: 'Filter: '),
                        TextSpan(
                          text: controller.selectedBidang.value.isEmpty
                              ? 'Semua Bidang'
                              : controller.selectedBidang.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' | '),
                        TextSpan(
                          text: controller.selectedKategori.value.isEmpty
                              ? 'Semua Kategori'
                              : controller.selectedKategori.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' | '),
                        TextSpan(
                          text: controller.selectedKondisi.value.isEmpty
                              ? 'Semua Kondisi'
                              : controller.selectedKondisi.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  '${controller.filteredAssets.length} aset',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          )),
          
          // Search and Export Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari dalam hasil filter...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      // Implement local search if needed
                    },
                  ),
                ),
                const SizedBox(width: 8),
                
                // Export buttons
                ElevatedButton.icon(
                  onPressed: controller.filteredAssets.isEmpty 
                      ? null 
                      : () => controller.exportToPdf(),
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: controller.filteredAssets.isEmpty 
                      ? null 
                      : () => controller.exportToCsv(),
                  icon: const Icon(Icons.table_chart, size: 20),
                  label: const Text('CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
              ],
            ),
          ),
          
          // Assets List
          Expanded(
            child: Obx(() => controller.filteredAssets.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data yang sesuai dengan filter',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.filteredAssets.length,
                    itemBuilder: (context, index) {
                      final asset = controller.filteredAssets[index];
                      return AssetListItem(asset: asset, index: index);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssetListItem extends StatelessWidget {
  final dynamic asset;
  final int index;

  const AssetListItem({
    Key? key, 
    required this.asset,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text('${index + 1}'),
        ),
        title: Text(
          asset.namaBarang ?? 'Tidak ada nama',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${asset.kategori ?? '-'} | ${asset.kondisi ?? '-'}',
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow('Lokasi', '${asset.bidang ?? '-'}, ${asset.namaRuangan ?? '-'}'),
                if (asset.noInventarisBarang != null && asset.noInventarisBarang!.isNotEmpty)
                  _buildDetailRow('No. Inventaris', asset.noInventarisBarang!),
                if (asset.merk != null && asset.merk!.isNotEmpty)
                  _buildDetailRow('Merk', asset.merk!),
                if (asset.type != null && asset.type!.isNotEmpty)
                  _buildDetailRow('Tipe', asset.type!),
                if (asset.serialNumber != null && asset.serialNumber!.isNotEmpty)
                  _buildDetailRow('Serial Number', asset.serialNumber!),
                if (asset.namaPengguna != null && asset.namaPengguna!.isNotEmpty)
                  _buildDetailRow('Pengguna', asset.namaPengguna!),
                if (asset.nip != null && asset.nip!.isNotEmpty)
                  _buildDetailRow('NIP', asset.nip!),
                if (asset.unit != null && asset.unit!.isNotEmpty)
                  _buildDetailRow('Unit', asset.unit!),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}