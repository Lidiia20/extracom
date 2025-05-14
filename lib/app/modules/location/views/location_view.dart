import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12B1B9),
        elevation: 0,
        title: const Text(
          'Lokasi Aset',
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
          // Dropdown location selector with custom styling
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: Obx(() {
              // Debug logs
              print('LocationView - Available locations: ${controller.locations}');
              print('LocationView - Selected location: ${controller.selectedLocation.value}');
              
              // Default locations if empty or contains nulls
              final defaultLocations = [
                'BIDANG KKU',
                'BIDANG PST',
                'BIDANG HARTRANS',
                'BIDANG REN',
                'GM'
              ];
              
              // Check if controller.locations has valid non-null values
              final hasValidLocations = controller.locations.isNotEmpty && 
                controller.locations.any((item) => item != null && item.isNotEmpty);
              
              // Use controller locations if valid, otherwise use defaults
              final List<String> locations = hasValidLocations
                  ? controller.locations.where((item) => item != null && item.isNotEmpty).toList()
                  : defaultLocations;
              
              // Determine current value - never use null
              String currentValue;
              if (controller.selectedLocation.value != null && 
                  controller.selectedLocation.value!.isNotEmpty &&
                  locations.contains(controller.selectedLocation.value)) {
                currentValue = controller.selectedLocation.value!;
              } else {
                currentValue = locations.first;
                // Update controller with valid value
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.selectedLocation.value = currentValue;
                });
              }
              
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Lokasi/Bidang',
                  border: InputBorder.none,
                  icon: Icon(Icons.location_on, color: Color(0xFF12B1B9)),
                ),
                isExpanded: true,
                value: currentValue, // Never use null here
                onChanged: (newValue) {
                  if (newValue != null) {
                    print('Location dropdown changed to: $newValue');
                    controller.changeLocation(newValue);
                  }
                },
                items: locations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            }),
          ),
          
          // Assets list based on selected location
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
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
                          if (controller.selectedLocation.value != null && 
                              controller.selectedLocation.value!.isNotEmpty) {
                            controller.loadAssetsByLocation(controller.selectedLocation.value);
                          }
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              
              // Handle case when no location is selected
              if (controller.selectedLocation.value == null || 
                  controller.selectedLocation.value!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_searching, color: Color(0xFF12B1B9), size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Silakan pilih lokasi untuk melihat aset',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.locationAssets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada aset di lokasi ${controller.selectedLocation.value}',
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.locationAssets.length,
                itemBuilder: (context, index) {
                  final asset = controller.locationAssets[index];
                  return _buildAssetCard(asset);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(dynamic asset) {
    // Tambahkan null check untuk menghindari error pada properti yang null
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final assetId = asset.no ?? asset.No;
          if (assetId != null) {
            Get.toNamed('/asset-detail', arguments: assetId);
          } else {
            // Tampilkan pesan error jika assetId null
            Get.snackbar(
              'Error',
              'ID aset tidak ditemukan',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
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
                      color: const Color(0xFF12B1B9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Color(0xFF12B1B9),
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
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(Icons.category, 'Kategori', asset.kategori ?? 'N/A'),
                  _buildInfoItem(Icons.check_circle_outline, 'Kondisi', asset.kondisi ?? 'N/A'),
                  _buildInfoItem(Icons.person_outline, 'Pengguna', asset.namaPengguna ?? 'N/A'),
                ],
              ),
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
}