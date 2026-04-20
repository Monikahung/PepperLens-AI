import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_card.dart';
import 'package:pepperlens_ai/features/history/data/repositories/history_repository.dart';

// Halaman riwaya yang menampilkan daftar riwayat deteksi penyakit
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Instance repository untuk menangani logika pengambilan data hasil dan detail deteksi serta penghapusan data hasil deteksi
  final HistoryRepository _historyRepository = HistoryRepository();

  // State untuk menyimpan kategori filter yang dipilih pengguna
  String _selectedCategory = 'Semua';

  // Daftar kategori yang tersedia untuk filter
  final List<String> _categories = [
    'Hari ini',
    'Bulan ini',
    'Tahun ini',
    'Semua',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeydew,

      // Teks 'Riwayat' di bagian atas halaman
      appBar: AppBar(
        title: const Text("Riwayat", style: AppTextStyles.manropeFive),
        backgroundColor: AppColors.honeydew,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.honeydew,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.mysticJade,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // Content dari halaman riwayat
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyRepository.getHistoryDetection(
          filter: _selectedCategory,
        ),
        // Tampilkan indikator loading saat data sedang dimuat
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.mysticJade),
            );
          }

          // Tampilkan pesan kesalahan jika terjadi error pada query
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan: ${snapshot.error}",
                style: AppTextStyles.manropeOne,
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data ?? [];

          // Tampilkan pesan jika tidak ada data hasil dan riwayat deteksi ditemukan di database
          if (data.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildHeaderActions(),
                const SizedBox(height: 50),
                const Center(
                  child: Text(
                    "Belum ada data riwayat.",
                    style: AppTextStyles.manropeOne,
                  ),
                ),
              ],
            );
          }

          // Tampilkan daftar riwayat deteksi
          return ListView.separated(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 30,
            ),
            itemCount: data.length + 1,
            separatorBuilder: (context, index) {
              return index == 0
                  ? const SizedBox(height: 20)
                  : const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              // Jika index 0, tampilkan baris filter dan tombol visualisasi
              if (index == 0) {
                return _buildHeaderActions();
              }

              final item = data[index - 1];

              // Tampilkan kartu riwayat deteksi dengan data yang sesuai dari repository
              return HistoryCard(
                date: item['tanggal'],
                time: item['waktu'],
                imagePath: item['path_deteksi'] ?? '',
                diseasesData: List<Map<String, dynamic>>.from(
                  item['penyakit_data'],
                ),
                onDelete: () async {
                  // Tampilkan dialog konfirmasi sebelum menghapus riwayat
                  bool? confirm = await _showDeleteConfirmationDialog(context);

                  // Jika mengklik tombol hapus
                  if (confirm == true) {
                    final String pathDeteksi = item['path_deteksi'];
                    final String pathPotret = item['path_potret'];

                    // Hapus data hasil deteksi dari database
                    await _historyRepository.deleteHistory(item['id_hasil']);

                    // Hapus file gambar hasil deteksi dan gambar potret dari penyimpanan lokal
                    await deleteFile(pathDeteksi);
                    await deleteFile(pathPotret);

                    if (!context.mounted) return;

                    // Trigger UI refresh untuk mengambil data terbaru
                    setState(() {});

                    // Tampilkan snackbar sukses jika penghapusan berhasil
                    _showSuccessSnackBar(context);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan baris filter dan tombol visualisasi
  Widget _buildHeaderActions() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter dropdown untuk kategori berdasarkan rentang waktu
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.frostedMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: AppColors.frostedMint,
                  borderRadius: BorderRadius.circular(10),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.honeydew,
                    ),
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return _categories.map<Widget>((String item) {
                      return Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(Icons.tune, color: AppColors.honeydew),
                          const SizedBox(width: 10),
                          Text(item, style: AppTextStyles.manropeSeven),
                        ],
                      );
                    }).toList();
                  },
                  items: _categories.map((val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text(val, style: AppTextStyles.manropeSeven),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Tombol navigasi ke halaman visualisasi
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.frostedMint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.bar_chart, color: AppColors.honeydew),
                    const SizedBox(width: 5),
                    Text('Visualisasi', style: AppTextStyles.manropeSeven),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.honeydew,
                      size: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi sebelum menghapus riwayat
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.honeydew,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text("Hapus Riwayat", style: AppTextStyles.manropeEight),
        content: Text(
          "Apakah Anda yakin ingin menghapus riwayat deteksi ini?",
          style: AppTextStyles.manropeNine,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: AppTextStyles.manropeFourteen),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus", style: AppTextStyles.manropeFifteen),
          ),
        ],
      ),
    );
  }

  // Penghapusan file gambar dari penyimpanan lokal
  Future<void> deleteFile(String path) async {
    if (path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint("Berhasil hapus: $path");
      }
    }
  }

  // Snackbar sukses jika penghapusan riwayat berhasil
  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.frostedMint,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.honeydew,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              "Riwayat berhasil dihapus",
              style: AppTextStyles.manropeTwelve,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
