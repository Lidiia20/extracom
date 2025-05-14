import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/condition_controller.dart';
import '../../asset_data/models/asset_model.dart';

class ConditionView extends GetView<ConditionController> {
  const ConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12B1B9),
        elevation: 0,
        title: const Text(
          'Kondisi Aset',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Condition overview cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Row(
              children: [
                // Layak Pakai Card
                Expanded(
                  child: _buildConditionCard(
                    'Layak Pakai',
                    controller.totalLayakPakai.value,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Sudah Lama Card
                Expanded(
                  child: _buildConditionCard(
                    'Sudah Lama',
                    controller.totalSudahLama.value,
                    Colors.orange,
                    Icons.access_time,
                  ),
                ),
                const SizedBox(width: 12),
                // Rusak Card
                Expanded(
                  child: _buildConditionCard(
                    'Rusak',
                    controller.totalRusak.value,
                    Colors.red,
                    Icons.dangerous,
                  ),
                ),
              ],
            )),
          ),
          
          // Condition selection tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Obx(() => Row(
              children: controller.conditions.map((condition) {
                final isSelected = controller.selectedCondition.value == condition;
                return Expanded(
                  child: InkWell(
                    onTap: () => controller.changeCondition(condition),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? const Color(0xFF12B1B9) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        condition,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF12B1B9) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
          ),
          
          // Assets list based on selected condition
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(
                  color: Color(0xFF12B1B9),
                ));
              }
              
              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF12B1B9),
                        ),
                        onPressed: () {
                          if (controller.selectedCondition.value.isNotEmpty) {
                            controller.loadAssetsByCondition(controller.selectedCondition.value);
                          } else {
                            controller.fetchConditionStatistics();
                          }
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.selectedCondition.value.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, color: Color(0xFF12B1B9), size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Pilih kondisi untuk melihat daftar aset',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.conditionAssets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada aset dengan kondisi ${controller.selectedCondition.value}',
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.conditionAssets.length,
                itemBuilder: (context, index) {
                  final asset = controller.conditionAssets[index];
                  return _buildAssetCard(asset);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConditionCard(String title, int count, Color color, IconData icon) {
    return GestureDetector(
      onTap: () => controller.changeCondition(title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssetCard(Asset asset) {
    Color statusColor;
    if (asset.kondisi == 'Layak Pakai') {
      statusColor = Colors.green;
    } else if (asset.kondisi == 'Sudah Lama') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.toNamed('/asset-detail', arguments: asset.no.toString());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.namaBarang ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'No. Inventaris: ${asset.noInventarisBarang ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      asset.kondisi ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // const Divider(height: 24),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     _buildInfoItem(Icons.location_on, 'Lokasi', asset.lokasi ?? 'N/A'),
              //     _buildInfoItem(Icons.calendar_today, 'Tahun', asset.tahunPerolehan?.toString() ?? 'N/A'),
              //     _buildInfoItem(Icons.attach_money, 'Nilai', 'Rp${_formatCurrency(asset.nilaiPerolehan)}'),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}