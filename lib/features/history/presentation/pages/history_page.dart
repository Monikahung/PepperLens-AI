import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/custom_snackbar.dart';
import 'package:pepperlens_ai/features/history/logic/delete_file_helper.dart';
import 'package:pepperlens_ai/features/history/presentation/pages/visualization_page.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_card.dart';
import 'package:pepperlens_ai/features/history/data/repositories/history_repository.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_header_actions.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_delete_dialog.dart';
import 'package:pepperlens_ai/features/history/logic/pdf_export_helper.dart';

// Halaman riwayat yang menampilkan daftar riwayat deteksi penyakit
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

  // State untuk melacak apakah sedang mendownload data hasil deteksi
  bool _isDownloading = false;

  // Daftar kategori yang tersedia untuk filter
  final List<String> _categories = [
    'Hari ini',
    'Bulan ini',
    'Tahun ini',
    'Semua',
  ];

  @override
  void dispose() {
    // Tunda eksekusi pembersihan snackbar sampai render frame halaman ini selesai dihancurkan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Periksa apakah context global milik GetX aktif
      if (Get.context != null) {
        // Hapus semua snackbar yang ada
        ScaffoldMessenger.of(Get.context!).clearSnackBars();
      }
    });
    // Kembalikan fungsi dispose ke kelas induk
    super.dispose();
  }

  // Bangun tampilan halaman riwayat deteksi penyakit
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
      body: SafeArea(
        bottom: true,
        top: false,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyRepository.getHistoryDetection(
            filter: _selectedCategory,
          ),

          builder: (context, snapshot) {
            // Tampilkan indikator loading saat data sedang dimuat
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
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
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
                      // Halaman visualisasi masih kosong
                      onVisualisasiTap: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Get.to(
                          () => VisualizationPage(filter: _selectedCategory),
                        );
                      },
                      // Download gagal karena data masih kosong
                      onDownloadTap: () {
                        CustomSnackbar.showSnackbar(
                          context,
                          message: 'Data riwayat masih kosong',
                          isSuccess: false,
                        );
                      },
                      isDownloading: _isDownloading,
                    ),
                    // Halaman riwayat masih kosong
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 50,
                            color: AppColors.darkCyan.withAlpha(
                              (0.25 * 255).toInt(),
                            ),
                          ),
                          Text(
                            "Belum ada data riwayat\nuntuk periode ini",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.manropeOne,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Tampilkan daftar riwayat deteksi
            return ListView.separated(
              // Padding untuk menampilkan content di bawah appBar
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
                    // Halaman visualisasi sudah ada data
                    onVisualisasiTap: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      Get.to(
                        () => VisualizationPage(filter: _selectedCategory),
                      );
                    },
                    // Download data hasil deteksi
                    onDownloadTap: () async {
                      // State bernilai true
                      setState(() => _isDownloading = true);

                      try {
                        // Ambil data dari repository sesuai filter
                        final pdfData = await _historyRepository
                            .getDetailHistoryDetection(
                              filter: _selectedCategory,
                            );

                        // Generate dokumen berbentuk PDF
                        await PdfExportHelper.generateAndOpenReport(
                          category: _selectedCategory,
                          historyData: pdfData,
                        );
                      } catch (e) {
                        debugPrint("Error: $e");
                      } finally {
                        // State bernilai false
                        if (mounted) setState(() => _isDownloading = false);
                      }
                    },
                    isDownloading: _isDownloading,
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
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => HistoryDeleteDialog(),
                    );

                    // Jika mengklik tombol hapus
                    if (confirm == true) {
                      final String assetId = item['asset_id'] ?? '';

                      // Coba hapus dari galeri, tapi jangan jadikan penghalang jika gagal
                      if (assetId.isNotEmpty) {
                        await DeleteFileHelper.deleteGalleryFile(assetId);
                      }

                      // Hapus data dari database dan penyimpanan lokal aplikasi
                      await _historyRepository.deleteHistory(item['id_hasil']);

                      if (!context.mounted) return;

                      // Refresh UI
                      setState(() {});

                      // Tampilkan snackbar sukses jika penghapusan berhasil
                      CustomSnackbar.showSnackbar(
                        context,
                        message: "Riwayat berhasil dihapus",
                        isSuccess: true,
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
