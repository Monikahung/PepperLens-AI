import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/history/data/repositories/history_repository.dart';
import 'package:pepperlens_ai/features/history/logic/visualization_mapper.dart';
import 'package:pepperlens_ai/features/history/presentation/widgets/disease_bar_chart.dart';

// Halaman visualisasi data yang menampilkan total deteksi per penyakit sesuai filter yang dipilih
class VisualizationPage extends StatelessWidget {
  // State untuk menyimpan filter yang dipilih
  final String filter;

  // Instance repository untuk menangani logika pengambilan data hasil dan detail deteksi untuk ditampilkan dalam bentuk visualisasi data
  final HistoryRepository _repository = HistoryRepository();

  VisualizationPage({super.key, required this.filter});

  // Bangun tampilan halaman visualisasi data
  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.honeydew,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.mysticJade,
        systemNavigationBarIconBrightness: Brightness.light,
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
          // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: AppColors.honeydew,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.mysticJade,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),

        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _repository.getHistoryDetection(filter: filter),

          builder: (context, snapshot) {
            // Tampilkan indikator loading saat data sedang dimuat
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.honeydew,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.mysticJade),
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
                      color: AppColors.darkCyan.withAlpha((0.25 * 255).toInt()),
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
                        VisualizationMapper.getTitleByFilter(filter),
                        style: AppTextStyles.manropeThree,
                        textAlign: TextAlign.center,
                      ),

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
                            Text("Catatan:", style: AppTextStyles.poppinsFour),
                            const SizedBox(height: 4),
                            Text(
                              "Visualisasi data disajikan berdasarkan hasil deteksi gejala penyakit pada daun lada dalam periode ${filter.toLowerCase()}. Penyajian ini bertujuan untuk membantu pengguna memahami distribusi hasil deteksi serta mengamati trend kondisi kesehatan daun selama periode tertentu.",
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
    );
  }
}
