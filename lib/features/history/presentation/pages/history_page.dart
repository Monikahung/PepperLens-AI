import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/logic/file_helper.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_card.dart';
import 'package:pepperlens_ai/features/history/data/repositories/history_repository.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_header_actions.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_delete_dialog.dart';

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
                HistoryHeaderActions(
                  selectedCategory: _selectedCategory,
                  categories: _categories,
                  onCategoryChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  onVisualisasiTap: () {},
                ),
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
                return HistoryHeaderActions(
                  selectedCategory: _selectedCategory,
                  categories: _categories,
                  onCategoryChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  onVisualisasiTap: () {},
                );
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
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) => HistoryDeleteDialog(),
                  );

                  // Jika mengklik tombol hapus
                  if (confirm == true) {
                    final String pathDetection = item['path_deteksi'];
                    final String pathOriginal = item['path_potret'];

                    // Hapus data hasil deteksi dari database
                    await _historyRepository.deleteHistory(item['id_hasil']);

                    // Hapus file gambar hasil deteksi dan gambar potret dari penyimpanan lokal
                    await FileHelper.deleteLocalFile(pathDetection);
                    await FileHelper.deleteLocalFile(pathOriginal);

                    if (!context.mounted) return;

                    // Trigger UI refresh untuk mengambil data terbaru
                    setState(() {});

                    // Tampilkan snackbar sukses jika penghapusan berhasil
                    HistoryDeleteDialog.showSuccessSnackBar(context);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
