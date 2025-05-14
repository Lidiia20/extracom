// lib/app/modules/asset_data/views/asset_history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/asset_history_controller.dart';
import '../models/asset_history_model.dart';

class AssetHistoryView extends GetView<AssetHistoryController> {
  const AssetHistoryView({super.key});

  // Dialog filter
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.filter_list, size: 20),
            SizedBox(width: 8),
            Text('Filter Riwayat'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jenis Aksi', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: controller.actionFilters.map((action) {
                    return ChoiceChip(
                      label: Text(action),
                      selected: controller.selectedAction.value == action,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedAction.value = action;
                        } else if (controller.selectedAction.value == action) {
                          controller.selectedAction.value = '';
                        }
                      },
                    );
                  }).toList(),
                )),
                
                const SizedBox(height: 24),
                const Text('Periode Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Tanggal awal
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                        onPressed: () => controller.selectStartDate(context),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          controller.startDate.value == null
                              ? 'Tanggal Awal'
                              : DateFormat('dd/MM/yyyy').format(controller.startDate.value!),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                        ),
                      )),
                    ),
                    if (controller.startDate.value != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          controller.startDate.value = null;
                        },
                        tooltip: 'Hapus tanggal awal',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Tanggal akhir
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                        onPressed: () => controller.selectEndDate(context),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          controller.endDate.value == null
                              ? 'Tanggal Akhir'
                              : DateFormat('dd/MM/yyyy').format(controller.endDate.value!),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                        ),
                      )),
                    ),
                    if (controller.endDate.value != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          controller.endDate.value = null;
                        },
                        tooltip: 'Hapus tanggal akhir',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              controller.resetFilter();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Reset'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              controller.filterHistories();
            },
            icon: const Icon(Icons.check),
            label: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk item history
  Widget _buildHistoryItem(BuildContext context, AssetHistoryModel history) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => controller.showHistoryDetails(history),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon aksi
              _buildActionAvatar(history.action),
              const SizedBox(width: 12),
              
              // Konten utama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama aset dan badge aksi
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            history.assetName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildActionBadge(history.action),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Deskripsi perubahan
                    Text(
                      history.getChangeDescription(),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Footer dengan informasi pengguna dan waktu
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          history.userName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(history.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget untuk filter chip
  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDelete,
        backgroundColor: Colors.blue[50],
        deleteIconColor: Colors.blue[700],
        labelStyle: TextStyle(color: Colors.blue[800]),
      ),
    );
  }
  
  // Widget untuk avatar aksi
  Widget _buildActionAvatar(String action) {
    IconData iconData;
    Color color;
    
    switch (action) {
      case 'Tambah':
        iconData = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case 'Edit':
        iconData = Icons.edit_outlined;
        color = Colors.blue;
        break;
      case 'Hapus':
        iconData = Icons.delete_outline;
        color = Colors.red;
        break;
      default:
        iconData = Icons.history;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }
  
  // Widget untuk badge aksi
  Widget _buildActionBadge(String action) {
    Color color;
    
    switch (action) {
      case 'Tambah':
        color = Colors.green;
        break;
      case 'Edit':
        color = Colors.blue;
        break;
      case 'Hapus':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        action,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetFilter();
              controller.loadHistories();
            },
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari riwayat aset...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                controller.setSearchQuery(value);
              },
            ),
          ),
          
          // Filter chips
          Obx(() {
            final hasActiveFilters = controller.selectedAction.value.isNotEmpty && 
                                    controller.selectedAction.value != 'Semua' || 
                                    controller.startDate.value != null || 
                                    controller.endDate.value != null;
            
            if (!hasActiveFilters) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                  child: Text(
                    'Filter Aktif:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      if (controller.selectedAction.value.isNotEmpty && 
                          controller.selectedAction.value != 'Semua')
                        _buildFilterChip(
                          'Aksi: ${controller.selectedAction.value}',
                          () {
                            controller.selectedAction.value = '';
                            controller.filterHistories();
                          },
                        ),
                      if (controller.startDate.value != null)
                        _buildFilterChip(
                          'Dari: ${DateFormat('dd/MM/yyyy').format(controller.startDate.value!)}',
                          () {
                            controller.startDate.value = null;
                            controller.filterHistories();
                          },
                        ),
                      if (controller.endDate.value != null)
                        _buildFilterChip(
                          'Sampai: ${DateFormat('dd/MM/yyyy').format(controller.endDate.value!)}',
                          () {
                            controller.endDate.value = null;
                            controller.filterHistories();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
          
          // List riwayat
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.displayedHistories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data riwayat',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (controller.selectedAction.value.isNotEmpty || 
                          controller.startDate.value != null || 
                          controller.endDate.value != null || 
                          controller.searchQuery.value.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => controller.resetFilter(),
                          icon: const Icon(Icons.filter_list_off),
                          label: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.displayedHistories.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (context, index) {
                  final history = controller.displayedHistories[index];
                  return _buildHistoryItem(context, history);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}