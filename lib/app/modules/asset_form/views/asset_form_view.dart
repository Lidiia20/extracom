// lib/app/modules/asset_form/views/asset_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../asset_data/services/dropdown_options_service.dart';
import '../../asset_form/controllers/asset_form_controller.dart';

class AssetFormView extends GetView<AssetFormController> {
  const AssetFormView({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Find services
    final dropdownService = Get.find<DropdownOptionsService>();
    
    // Fungsi untuk membangun section title
    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF12B1B9),
          ),
        ),
      );
    }
    
    // Fungsi untuk membangun text form field
    Widget buildTextFormField({
      required TextEditingController controller,
      required String label,
      required String hint,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      );
    }
    
    // Widget khusus untuk dropdown kategori
    Widget buildKategoriDropdown() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Obx(() {
          // Debug log untuk kategori options
          print('Kategori options: ${dropdownService.kategoriOptions}');
          print('Current kategori: ${controller.selectedCategory.value}');
          
          final options = dropdownService.kategoriOptions.isEmpty 
              ? ['Elektronik', 'Furnitur']
              : dropdownService.kategoriOptions;
          
          // Cek apakah nilai controller valid, jika tidak set null
          final currentValue = options.contains(controller.selectedCategory.value) 
              ? controller.selectedCategory.value 
              : null;
          
          return DropdownButtonFormField<String>(
            isExpanded: true, // Tambahkan property ini untuk mengatasi overflow
            value: currentValue,
            hint: Text("Pilih Kategori"), // Tambahkan hint
            decoration: InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis, // Tambahkan ini untuk mencegah overflow teks
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                controller.selectedCategory.value = newValue;
                print('Kategori changed to: $newValue');
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih kategori';
              }
              return null;
            },
          );
        }),
      );
    }

    Widget buildBidangDropdown() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Obx(() {
      // Debug logs
      print('Bidang options: ${dropdownService.bidangOptions}');
      print('Current bidang: ${controller.currentBidang.value}');

      // Create default options that will be used if no valid options are found
      final List<String> defaultOptions = [
        'BIDANG KKU',
        'BIDANG PST',
        'BIDANG HARTRANS',
        'BIDANG REN',
        'GM'
      ];
      
      // Use the default options directly instead of trying to filter invalid options
      final List<String> options = defaultOptions;

      // Set current value - IMPORTANT: DO NOT USE NULL as value
      final String currentValue = controller.bidangController.text.isNotEmpty 
          ? controller.bidangController.text 
          : defaultOptions.first;
          
      // Always update controller with a valid value
      if (controller.currentBidang.value == null || 
          !options.contains(controller.currentBidang.value)) {
        controller.currentBidang.value = currentValue;
        controller.bidangController.text = currentValue;
      }

      print('Using bidang value: $currentValue from options: $options');

      return DropdownButtonFormField<String>(
        isExpanded: true,
        value: currentValue, // NEVER USE NULL HERE
        decoration: InputDecoration(
          labelText: 'Bidang',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            controller.currentBidang.value = newValue;
            controller.bidangController.text = newValue;
            print('Bidang changed to: $newValue');
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Pilih bidang';
          }
          return null;
        },
      );
    }),
  );
}
    

    Widget buildKondisiDropdown() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Obx(() {
          // Debug log untuk kondisi options
          print('Kondisi options: ${dropdownService.kondisiOptions}');
          print('Current kondisi: ${controller.kondisiController.text}');
          
          final options = dropdownService.kondisiOptions.isNotEmpty 
              ? dropdownService.kondisiOptions
              : ['Rusak', 'Layak Pakai', 'Sudah Lama'];
               
          final currentValue = options.contains(controller.kondisiController.text) 
              ? controller.kondisiController.text 
              : null;

          return DropdownButtonFormField<String>(
            isExpanded: true, // Tambahkan property ini untuk mengatasi overflow
            value: currentValue, // Nilai null jika tidak ada dalam options
            hint: Text("Pilih Kondisi"), // Tampilkan hint jika null
            decoration: InputDecoration(
              labelText: 'Kondisi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis, // Tambahkan ini untuk mencegah overflow teks
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                controller.kondisiController.text = newValue;
                print('Kondisi changed to: $newValue');
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih kondisi';
              }
              return null;
            },
          );
        }),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value ? 'Edit Aset' : 'Tambah Aset Baru')),
        backgroundColor: const Color(0xFF12B1B9),
        actions: [
          // Show history button only in edit mode
          Obx(() => controller.isEditing.value
            ? IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Lihat Riwayat',
                onPressed: controller.viewAssetHistory,
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionTitle('Informasi Barang'),
                    buildTextFormField(
                      controller: controller.namaBarangController,
                      label: 'Nama Barang',
                      hint: 'Masukkan nama barang',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama barang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            controller: controller.merkController,
                            label: 'Merk',
                            hint: 'Masukkan merk',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildTextFormField(
                            controller: controller.typeController,
                            label: 'Type',
                            hint: 'Masukkan type',
                          ),
                        ),
                      ],
                    ),
                    buildTextFormField(
                      controller: controller.serialNumberController,
                      label: 'Serial Number',
                      hint: 'Masukkan serial number',
                    ),
                    buildTextFormField(
                      controller: controller.noInventarisBarangController,
                      label: 'No. Inventaris Barang',
                      hint: 'Masukkan nomor inventaris',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor inventaris tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    buildTextFormField(
                      controller: controller.noAktivaController,
                      label: 'No. Aktiva',
                      hint: 'Masukkan nomor aktiva',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            controller: controller.jumlahController,
                            label: 'Jumlah',
                            hint: '1',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Jumlah harus angka positif';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildKondisiDropdown(),
                        ),
                      ],
                    ),
                    buildKategoriDropdown(),
                    
                    const SizedBox(height: 24),
                    buildSectionTitle('Informasi Pengguna'),
                    
                    buildTextFormField(
                      controller: controller.namaPenggunaController,
                      label: 'Nama Pengguna',
                      hint: 'Masukkan nama pengguna',
                    ),
                    buildTextFormField(
                      controller: controller.nipController,
                      label: 'NIP',
                      hint: 'Masukkan NIP',
                      keyboardType: TextInputType.number,
                    ),
                    buildTextFormField(
                      controller: controller.unitController,
                      label: 'Unit',
                      hint: 'Masukkan unit',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: buildBidangDropdown(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildTextFormField(
                            controller: controller.subBidangController,
                            label: 'Sub Bidang',
                            hint: 'Masukkan sub bidang',
                          ),
                        ),
                      ],
                    ),
                    buildTextFormField(
                      controller: controller.namaRuanganController,
                      label: 'Nama Ruangan',
                      hint: 'Masukkan nama ruangan',
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.saveAsset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF12B1B9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          controller.isEditing.value ? 'Perbarui Aset' : 'Simpan Aset',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Loading indicator
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withAlpha(76),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}