import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../controllers/nota_controller.dart';
import '../models/nota_model.dart';

class AssetNotaView extends GetView<NotaController> {
  final String noInventaris;
  final String assetName;
  
  const AssetNotaView({
    super.key, 
    required this.noInventaris,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    // Set current noInventaris for controller
    controller.setCurrentNoInventaris(noInventaris);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Nota Aset: $assetName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadNotasByInventaris(noInventaris),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadNotaDialog(context),
        tooltip: 'Tambah Nota',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildMessageArea(),
          Expanded(
            child: _buildNotaList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assetName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No. Inventaris: $noInventaris',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageArea() {
    return Obx(() {
      if (controller.errorMessage.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.red.shade100,
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else if (controller.successMessage.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.green.shade100,
          child: Text(
            controller.successMessage.value,
            style: const TextStyle(color: Colors.green),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildNotaList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredNotas.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada nota untuk aset ini',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showUploadNotaDialog(context),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Tambah Nota'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.filteredNotas.length,
        itemBuilder: (context, index) {
          final nota = controller.filteredNotas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text((index + 1).toString()),
              ),
              title: Text('Nota ${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal: ${nota.tanggalUpload}'),
                  if (nota.namaFile.isNotEmpty)
                    Text('File: ${nota.namaFile}', 
                        style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.blue),
                    tooltip: 'Lihat Gambar',
                    onPressed: () => _showNotaImage(nota),
                  ),
                ],
              ),
              onTap: () => _showNotaImage(nota),
            ),
          );
        },
      );
    });
  }

  void _showUploadNotaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Nota'),
          content: Obx(() {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info aset
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assetName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('No. Inventaris: $noInventaris'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Image preview
                  if (controller.selectedImage.value != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            controller.selectedImage.value!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: InkWell(
                              onTap: controller.clearSelectedImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Belum ada gambar yang dipilih'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: controller.takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (controller.selectedImage.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'File: ${controller.selectedImageName.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  // Error message
                  if (controller.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                controller.clearSelectedImage();
                controller.errorMessage.value = '';
                Get.back();
              },
              child: const Text('Batal'),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value || controller.selectedImage.value == null
                    ? null
                    : () async {
                        try {
                          final success = await controller.uploadNota();
                          if (success) {
                            Get.back();
                            // Show snackbar on success
                            Get.snackbar(
                              'Sukses',
                              'Nota berhasil diunggah',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.shade100,
                              colorText: Colors.green.shade800,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print('Error uploading nota: $e');
                          }
                          controller.errorMessage.value = 'Terjadi kesalahan: $e';
                        }
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Upload'),
              );
            }),
          ],
        );
      },
    );
  }

  void _showNotaImage(Nota nota) async {
    (
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: controller.getNotaImage(nota.id.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.data?['success']) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(
                  snapshot.data?['message'] ?? 'Gagal memuat gambar nota',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            }

            final imageData = snapshot.data?['imageData'];

            if (imageData == null) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Data gambar tidak ditemukan'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            assetName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No. Inventaris: $noInventaris'),
                        Text('Tanggal: ${nota.tanggalUpload}'),
                        if (nota.namaFile.isNotEmpty)
                          Text('File: ${nota.namaFile}'),
                      ],
                    ),
                  ),
                  // Image
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.memory(
                        base64Decode(imageData),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
}