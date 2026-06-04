import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/custom_snackbar.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/history_download_dialog.dart';
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
    'Minggu ini',
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

            // Ambil data dari snapshot dan jika data kosong maka diinisialisasi dengan array kosong
            final data = snapshot.data ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  // Komponen header fitur riwayat (dropdown, visualisasi, unduh)
                  child: HistoryHeaderActions(
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    // Callback ketika user mengubah filter kategori riwayat
                    onCategoryChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    // Halaman visualisasi
                    onVisualisasiTap: () {
                      // Bersihkan snackbar jika sedang aktif
                      ScaffoldMessenger.of(context).clearSnackBars();

                      // Navigasi ke halaman visualisasi
                      Get.to(
                        () =>
                            VisualizationPage(initialFilter: _selectedCategory),
                      );
                    },
                    // Logika Download
                    onDownloadTap: data.isEmpty
                        ? () {
                            // Snackbar gagal download jika data riwayat kosong
                            CustomSnackbar.showSnackbar(
                              context,
                              message: 'Data riwayat pada periode ini kosong',
                              isSuccess: false,
                            );
                          }
                        : () {
                            // Dialog filter rentang riwayat untuk download
                            HistoryDownloadDialog.show(
                              context,
                              // Kategori filter yang dipilih pengguna di dropdown
                              currentCategory: _selectedCategory,
                              categories: [
                                'Semua',
                                'Hari ini',
                                'Minggu ini',
                                'Bulan ini',
                                'Tahun ini',
                                'Kustom',
                              ],
                              // Callback ketika pengguna memilih kategori filter
                              onDownloadConfirm: (filterParam, pdfTitle) async {
                                setState(() => _isDownloading = true);

                                try {
                                  // Ambil data SQLite melalui repository
                                  final pdfData = await _historyRepository
                                      .getDetailHistoryDetection(
                                        filter: filterParam,
                                      );

                                  if (!context.mounted) return;

                                  // Snackbar gagal download jika data riwayat kosong
                                  if (pdfData.isEmpty) {
                                    CustomSnackbar.showSnackbar(
                                      context,
                                      message:
                                          'Data riwayat pada periode ini kosong',
                                      isSuccess: false,
                                    );
                                    return;
                                  }

                                  // Izin akses galeri untuk mengakses gambar
                                  final PermissionState permission =
                                      await PhotoManager.requestPermissionExtend();
                                  final bool hasGalleryAccess =
                                      permission.isAuth;

                                  // List menyimpan data riwayat dengan path file gambar yang sudah tervalidasi
                                  List<Map<String, dynamic>> validatedPdfData =
                                      [];

                                  // Loop untuk mengambil gambar hasil deteksi
                                  for (var item in pdfData) {
                                    // Ambil path gambar hasil deteksi dan asset id dari SQLite
                                    final String internalPath =
                                        item['path_deteksi'] ?? '';
                                    final String assetId =
                                        item['asset_id'] ?? '';

                                    // Variabel penampung gambar hasil deteksi
                                    String finalImagePathForPdf = '';

                                    // Jika path gambar hasil deteksi tersedia dan filenya ada di storage aplikasi
                                    if (internalPath.isNotEmpty &&
                                        await File(internalPath).exists()) {
                                      finalImagePathForPdf = internalPath;
                                    }
                                    // Jika file internal tidak ada, coba ambil file dari galeri pakai asset id
                                    else if (assetId.isNotEmpty &&
                                        hasGalleryAccess) {
                                      try {
                                        final AssetEntity? asset =
                                            await AssetEntity.fromId(assetId);
                                        if (asset != null) {
                                          final File? galleryFile =
                                              await asset.file;
                                          if (galleryFile != null) {
                                            finalImagePathForPdf =
                                                galleryFile.path;
                                          }
                                        }
                                      } catch (e) {
                                        debugPrint(
                                          "Gagal mengambil gambar galeri untuk asset $assetId: $e",
                                        );
                                      }
                                    }

                                    // Tambahkan data item ke list validasi dengan memperbarui path_deteksi ke path file fisik yang valid
                                    validatedPdfData.add({
                                      ...item,
                                      'path_deteksi': finalImagePathForPdf,
                                    });
                                  }

                                  // Buat dokumen PDF dan bisa langsung dibuka di perangkat pengguna
                                  await PdfExportHelper.generateAndOpenReport(
                                    category: pdfTitle,
                                    historyData: validatedPdfData,
                                  );
                                } catch (e) {
                                  debugPrint("Error: $e");
                                  // Snackbar gagal download jika terjadi kesalahan
                                  if (context.mounted) {
                                    CustomSnackbar.showSnackbar(
                                      context,
                                      message: 'Gagal mengekspor dokumen PDF',
                                      isSuccess: false,
                                    );
                                  }
                                } finally {
                                  // Selalu dieksekusi setelah download selesai
                                  if (mounted) {
                                    setState(() => _isDownloading = false);
                                  }
                                }
                              },
                              // Tanggal awal dan akhir yang tersimpan di database
                              firstDataDate: data.isNotEmpty
                                  ? data.last['tanggal']
                                  : null,
                              lastDataDate: data.isNotEmpty
                                  ? data.first['tanggal']
                                  : null,
                            );
                          },
                    isDownloading: _isDownloading,
                  ),
                ),

                // Bagian daftar list riwayat deteksi penyakit
                Expanded(
                  child: data.isEmpty
                      // Jika data riwayat kosong
                      ? Column(
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
                        )
                      // Jika data riwayat tersedia
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 10,
                            bottom: 30,
                          ),
                          itemCount: data.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            final item = data[index];

                            // Tampilkan kartu riwayat deteksi dengan data yang sesuai dari repository
                            return HistoryCard(
                              date: item['tanggal'],
                              time: item['waktu'],
                              imagePath: item['path_deteksi'] ?? '',
                              timeProcess: item['waktu_proses'] ?? '',
                              assetId: item['asset_id'] ?? '',
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
                                    await DeleteFileHelper.deleteGalleryFile(
                                      assetId,
                                    );
                                  }

                                  // Hapus data dari database dan penyimpanan lokal aplikasi
                                  await _historyRepository.deleteHistory(
                                    item['id_hasil'],
                                  );

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
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
