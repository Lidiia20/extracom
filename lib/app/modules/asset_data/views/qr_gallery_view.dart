// lib/app/modules/asset_data/views/qr_gallery_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/qr_gallery_controller.dart';

class QrGalleryView extends GetView<QrGalleryController> {
  const QrGalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri QR Code'),
        backgroundColor: const Color(0xFF12B1B9),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.assetsWithQr.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_2,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambahkan aset baru atau generate QR code untuk aset yang ada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Aset Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12B1B9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/asset-form');
                  },
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.assetsWithQr.length,
            itemBuilder: (context, index) {
              final asset = controller.assetsWithQr[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () => controller.showQrCodeOptions(asset),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // QR Code Preview
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: asset.qrCodePath != null
                              ? Image.file(
                                  File(asset.qrCodePath!),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.red,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.qr_code,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      // Asset Info
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF12B1B9),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.namaBarang ?? 'Tanpa Nama',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No. Inv: ${asset.noInventarisBarang ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF12B1B9),
        child: const Icon(Icons.refresh),
        onPressed: controller.refreshQrGallery,
      ),
    );
  }
}