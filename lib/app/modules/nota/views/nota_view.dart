import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../controllers/nota_controller.dart';
import '../models/nota_model.dart';

class NotaView extends GetView<NotaController> {
  const NotaView({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadNotas(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadNotaDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildMessageArea(),
          Expanded(
            child: _buildNotaList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          labelText: 'Cari Nota',
          hintText: 'Cari berdasarkan nama barang atau no. inventaris',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.searchController.clear();
              controller.loadNotas();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSubmitted: (value) => controller.searchNotas(value),
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

  Widget _buildNotaList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredNotas.isEmpty) {
        return const Center(
          child: Text('Tidak ada data nota'),
        );
      }

      return ListView.builder(
        itemCount: controller.filteredNotas.length,
        itemBuilder: (context, index) {
          final nota = controller.filteredNotas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                child: Text((index + 1).toString()),
              ),
              title: Text(nota.namaBarang),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No. Inventaris: ${nota.noInventaris}'),
                  Text('Tanggal: ${nota.tanggalUpload}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.image),
                onPressed: () => _showNotaImage(context, nota),
              ),
            ),
          );
        },
      );
    });
  }

  void _showUploadNotaDialog(BuildContext context) {
    final noInventarisController = TextEditingController();

    if (controller.currentNoInventaris.isNotEmpty) {
      noInventarisController.text = controller.currentNoInventaris.value;
    }

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
                  TextField(
                    controller: noInventarisController,
                    decoration: const InputDecoration(
                      labelText: 'No. Inventaris',
                      hintText: 'Masukkan nomor inventaris aset',
                    ),
                    enabled: controller.currentNoInventaris.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  if (controller.selectedImage.value != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(
                        controller.selectedImage.value!,
                        fit: BoxFit.cover,
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
                      ),
                      ElevatedButton.icon(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
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
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                controller.clearSelectedImage();
                Get.back();
              },
              child: const Text('Batal'),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        final success = await controller.uploadNota(
                          customNoInventaris: noInventarisController.text,
                        );
                        if (success) {
                          Get.back();
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

  void _showNotaImage(BuildContext context, Nota nota) async {
    showDialog(
      context: context,
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
            final mimeType = snapshot.data?['mimeType'];

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

            return AlertDialog(
              title: Text(nota.namaBarang),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No. Inventaris: ${nota.noInventaris}'),
                  Text('Tanggal: ${nota.tanggalUpload}'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.memory(
                        base64Decode(imageData),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}