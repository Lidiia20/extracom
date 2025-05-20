import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12B1B9),
        elevation: 0,
        title: const Text(
          'ExstraCom',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Blue Background
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF12B1B9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Profile Info Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // User Icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF12B1B9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                'User : ${controller.userName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              const SizedBox(height: 4),
                              const Text(
                                'Kelola Data Aset Perusahaan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // More Button
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Menu Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Menu Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    children: [
                      // 1. Data Aset
                      _buildMenuItem(
                        icon: Icons.inventory,
                        title: 'Data Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {
                          Get.toNamed('/asset-data');
                        },
                      ),
                      
                      // 2. Tambah Aset
                      _buildMenuItem(
                        icon: Icons.add_box,
                        title: 'Tambah Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {
                          Get.toNamed('/asset-form');
                        },
                      ),
                      
                      // 3. Scan QR Code - Updated untuk menggunakan route QR Scanner
                      // _buildMenuItem(
                      //   icon: Icons.qr_code_scanner,
                      //   title: 'Scan QR Code',
                      //   color: const Color(0xFF12B1B9),
                      //   onTap: () {
                      //     // Navigasi ke halaman QR scanner
                      //     Get.toNamed('/qr-scanner');
                      //   },
                      // ),
                      
                      // 4. Kategori Aset
                      _buildMenuItem(
                        icon: Icons.category,
                        title: 'Kategori Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {
                          // Navigasi ke halaman kategori
                          Get.toNamed('/category');
                        },
                      ),
                      
                      // 5. Lokasi Aset
                      _buildMenuItem(
                        icon: Icons.location_on,
                        title: 'Lokasi Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {
                          // Navigasi ke halaman lokasi
                          Get.toNamed('/location');
                        },
                      ),
                      
                      // 6. Riwayat Aset
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Riwayat Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {

                          // Navigasi ke halaman riwayat aset
                          Get.toNamed('/asset-history');
                        },
                      ),
                      
                      // 7. Laporan Aset
                      _buildMenuItem(
                        icon: Icons.summarize,
                        title: 'Laporan Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {
                          Get.toNamed('/asset_report');
                        },
                      ),
                      
                      // 8. Lainnya
                      _buildMenuItem(
                        icon: Icons.bar_chart,
                        title: 'Kondisi Aset',
                        color: const Color(0xFF12B1B9),
                        onTap: () {
                          _showMoreOptionsBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/manajemen.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Aset Lebih Mudah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Monitoring data aset perusahaan dengan aplikasi ExstraCoM PLN',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button untuk akses cepat ke scanner
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF12B1B9),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
        onPressed: () {
          // Navigasi ke halaman QR scanner
          Get.toNamed('/qr-scanner');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF12B1B9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.history),
          //   label: 'Histori',
          // ),
          // Memberikan ruang untuk FAB
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.qr_code_scanner, color: Colors.transparent),
          //   label: '',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fitur Tambahan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                children: [
                  // Upload Nota
                  // _buildMenuItem(
                  //   icon: Icons.receipt_long,
                  //   title: 'Upload Nota',
                  //   color: Colors.orange,
                  //   onTap: () {
                  //     Get.back(); // Tutup bottom sheet
                  //     Get.toNamed('/nota');
                  //   },
                  // ),
                  
                  // Generate QR Code - Menu baru untuk generate QR ke existing asset
                  // _buildMenuItem(
                  //   icon: Icons.qr_code,
                  //   title: 'Generate QR',
                  //   color: Colors.green,
                  //   onTap: () {
                  //     Get.back(); // Tutup bottom sheet
                  //     Get.toNamed('/asset-list', arguments: {'mode': 'qr_generation'});
                  //   },
                  // ),
                  
                  // Galeri QR Code - Menu baru untuk melihat QR code yang sudah dibuat
                  // _buildMenuItem(
                  //   icon: Icons.photo_library,
                  //   title: 'Galeri QR',
                  //   color: Colors.purple,
                  //   onTap: () {
                  //     Get.back(); // Tutup bottom sheet
                  //     Get.toNamed('/qr-gallery');
                  //   },
                  // ),
                  
                  // Notifikasi
                  // _buildMenuItem(
                  //   icon: Icons.notifications,
                  //   title: 'Notifikasi',
                  //   color: Colors.red,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  
                  // Kondisi Aset
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    title: 'Kondisi Aset',
                    color: Colors.purple,
                    onTap: () {
                      
                      Navigator.pop(context);
                      Get.toNamed('/condition');
                    },
                  ),
                  
                  // Pengaturan
                  // _buildMenuItem(
                  //   icon: Icons.settings,
                  //   title: 'Pengaturan',
                  //   color: Colors.blueGrey,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  
                  // Tentang Aplikasi
                  // _buildMenuItem(
                  //   icon: Icons.info,
                  //   title: 'Tentang',
                  //   color: Colors.blue,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}