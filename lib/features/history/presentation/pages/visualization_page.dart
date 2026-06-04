import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/data/repositories/history_repository.dart';
import 'package:pepperlens_ai/features/history/logic/visualization_mapper.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/disease_bar_chart.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/visualization_filter.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/date_range_dialog.dart';

// Halaman visualisasi data yang menampilkan total deteksi per penyakit sesuai filter yang dipilih
class VisualizationPage extends StatefulWidget {
  // State untuk menyimpan filter yang dipilih
  final String initialFilter;

  const VisualizationPage({super.key, required this.initialFilter});

  @override
  State<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage> {
  // State untuk menyimpan filter yang aktif saat ini
  late String currentFilter;

  // Instance repository untuk menangani logika pengambilan data hasil dan detail deteksi untuk ditampilkan dalam bentuk visualisasi data
  final HistoryRepository _repository = HistoryRepository();

  // Inisialisasi state awal halaman sebelum widget dirender
  @override
  void initState() {
    super.initState();
    // Sinkron filter visualisasi dengan filter yang sedang aktif di halaman riwayat sebelumnya
    currentFilter = widget.initialFilter;
  }

  // Bangun tampilan halaman visualisasi data
  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.honeydew,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,

        systemNavigationBarColor: AppColors.mysticJade,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppColors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.honeydew,
        appBar: AppBar(
          backgroundColor: AppColors.honeydew,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          centerTitle: true,
          // Icon panah kembali ke halaman sebelumnya
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.darkCyan,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          // Teks paling atas pada halaman
          title: const Text("Visualisasi", style: AppTextStyles.manropeFive),
        ),

        body: SafeArea(
          bottom: true,
          top: false,
          child: Column(
            children: [
              // Widget selektor baris horizontal untuk mengubah filter periode visualisasi
              VisualizationFilter(
                selectedFilter: currentFilter,
                onFilterSelected: (filter) {
                  // Buka dialog kalender jika pengguna memilih filter kostum
                  if (filter == 'Kustom') {
                    DateRangeDialog.show(context, (pickedRange) {
                      setState(() {
                        // Format objek DateTime awal menjadi string standar ISO (YYYY-MM-DD)
                        String start = pickedRange.start
                            .toIso8601String()
                            .split('T')[0];
                        // Format objek DateTime akhir menjadi string standar ISO (YYYY-MM-DD)
                        String end = pickedRange.end.toIso8601String().split(
                          'T',
                        )[0];
                        // Gabungkan string tanggal awal dan akhir
                        currentFilter = "${start}_$end";
                      });
                    });
                  } else {
                    // Langsung perbarui state filter jika memilih kategori konstan (Hari ini, Minggu ini, Bulan ini, Tahun ini)
                    setState(() => currentFilter = filter);
                  }
                },
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  key: ValueKey(currentFilter),
                  future: _repository.getHistoryDetection(
                    filter: currentFilter,
                  ),
                  builder: (context, snapshot) {
                    // Tampilkan indikator loading saat data sedang dimuat
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        backgroundColor: AppColors.honeydew,
                        body: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.mysticJade,
                          ),
                        ),
                      );
                    }

                    // Tampilkan pesan kesalahan jika terjadi error pada query
                    if (snapshot.hasError) {
                      return Scaffold(
                        backgroundColor: AppColors.honeydew,
                        body: Center(
                          child: Text(
                            "${snapshot.error}",
                            style: AppTextStyles.manropeOne,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // Tampilkan pesan jika tidak ada data yang ditemukan
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 50,
                              color: AppColors.darkCyan.withAlpha(
                                (0.25 * 255).toInt(),
                              ),
                            ),
                            Text(
                              "Belum ada data deteksi\nuntuk periode ini",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.manropeOne,
                            ),
                          ],
                        ),
                      );
                    }

                    // Jika ada data, lakukan olah data
                    final Map<int, double> chartData =
                        VisualizationMapper.processChartData(snapshot.data!);

                    // Ambil teks rentang tanggal riwayat yang berhasil ditemukan
                    String dateRange = VisualizationMapper.getDateRangeByFilter(
                      currentFilter,
                      snapshot.data!,
                    );

                    // Format teks periode yang dipilih
                    String periodDisplay =
                        VisualizationMapper.getFormattedDateRange(
                          currentFilter,
                        );

                    // Logika teks catatan periode
                    String periodText = currentFilter == 'Semua'
                        ? "seluruh periode pencatatan"
                        : "periode $periodDisplay";

                    // Tampilkan visualisasi data serta catatannya
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          // Padding untuk menampilkan content di bawah appBar
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 10,
                            bottom: 30,
                          ),
                          child: Column(
                            children: [
                              // Judul visualisasi data
                              Text(
                                VisualizationMapper.getTitleByFilter(
                                  currentFilter,
                                ),
                                style: AppTextStyles.manropeThree,
                                textAlign: TextAlign.center,
                              ),
                              // Jarak antar komponen
                              const SizedBox(height: 4),
                              // Teks periode yang dipilih
                              Text(dateRange, style: AppTextStyles.manropeOne),
                              // Jarak antar komponen
                              const SizedBox(height: 20),
                              // Area visualisasi data berupa diagram batang
                              SizedBox(
                                width: double.infinity,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: DiseaseBarChart(chartData: chartData),
                                ),
                              ),
                              // Jarak antar komponen
                              const SizedBox(height: 20),
                              // Catatan visualisasi data
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.mysticJade,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Catatan:",
                                      style: AppTextStyles.poppinsFour,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Visualisasi data disajikan berdasarkan hasil deteksi gejala penyakit pada daun lada dalam $periodText. Penyajian ini bertujuan untuk membantu pengguna memahami distribusi hasil deteksi serta mengamati trend kondisi kesehatan daun selama periode tertentu.",
                                      style: AppTextStyles.manropeTen,
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
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: Container(
          color: AppColors.mysticJade,
          child: SafeArea(top: false, child: const SizedBox.shrink()),
        ),
      ),
    );
  }
}
