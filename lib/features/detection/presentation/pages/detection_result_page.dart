import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/detection_disease_card.dart';
import 'package:pepperlens_ai/features/detection/data/repositories/detection_repository.dart';
import 'package:pepperlens_ai/features/encyclopedia/presentation/pages/encyclopedia_detail_page.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/crop_preview.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/result_image_header.dart';

// Halaman utama untuk menampilkan hasil deteksi beserta cropping gambar untuk setiap penyakit yang terdeteksi
class DetectionResultPage extends StatefulWidget {
  // Id hasil deteksi sebagai pencarian database
  final int idResult;

  const DetectionResultPage({super.key, required this.idResult});

  @override
  State<DetectionResultPage> createState() => _DetectionResultPageState();
}

class _DetectionResultPageState extends State<DetectionResultPage> {
  // Inisialisasi repository untuk akses data hasil deteksi beserta detailnya
  final DetectionRepository _repository = DetectionRepository();

  @override
  void initState() {
    super.initState();
    // Inisialisasi format tanggal bahasa Indonesia
    initializeDateFormatting('id_ID', null);
  }

  // Ambil data lengkap hasil deteksi beserta detailnya dari database
  Future<Map<String, dynamic>> _fetchFullData() async {
    return await _repository.getCompleteDetectionResult(widget.idResult);
  }

  // Kelompokkan hasil deteksi berdasarkan nama penyakitnya
  Map<String, List<Map<String, dynamic>>> _groupDiseases(
    List<Map<String, dynamic>> details,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in details) {
      String name = item['nama_penyakit'] ?? 'Tidak Diketahui';
      if (!grouped.containsKey(name)) grouped[name] = [];
      grouped[name]!.add(item);
    }
    return grouped;
  }

  // Konversi format ISO8601 ke format tanggal yang mudah dibaca
  String _formatDateTime(String isoString) {
    DateTime dt = DateTime.parse(isoString);
    return DateFormat('d MMMM yyyy  HH:mm:ss', 'id_ID').format(dt);
  }

  // Bangun tampilan halaman hasil deteksi penyakit beserta detailnya
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchFullData(),
      // Jika sedang menunggu data dari database, tampilkan loading
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.honeydew,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.mysticJade),
            ),
          );
        }

        // Jika terjadi error atau data tidak ditemukan, tampilkan teks 'Data tidak ditemukan'
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.honeydew,
            body: Center(
              child: Text(
                "Data tidak ditemukan",
                style: AppTextStyles.manropeOne,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Ekstraksi data dari snapshot
        final header = snapshot.data!['header'];
        final List<Map<String, dynamic>> details = snapshot.data!['details'];
        final groupedData = _groupDiseases(details);

        // Kelompokkan hasil deteksi berdasarkan nama penyakitnya
        final entries = groupedData.entries.toList();

        // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
        return Scaffold(
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
            title: const Text(
              "Hasil Deteksi",
              style: AppTextStyles.manropeFive,
            ),
            // AnnotatedRegion untuk mengontrol tampilan status bar dan navigasi sistem
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: AppColors.honeydew,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: AppColors.mysticJade,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
          ),
          body: SafeArea(
            bottom: true,
            top: false,
            child: SingleChildScrollView(
              // Padding untuk menampilkan content di bawah appBar
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan gambar utama berupa gambar yang ada bounding box hasil deteksi penyakit
                  ResultImageHeader(
                    path: header['path_gambar_deteksi'] ?? '',
                    noImage:
                        (header['path_gambar_deteksi'] ?? '').isEmpty ||
                        !File(header['path_gambar_deteksi']).existsSync(),
                    date: _formatDateTime(header['waktu_deteksi']),
                    processTime: header['waktu_proses'].toString(),
                  ),

                  // Jarak antar komponen
                  const SizedBox(height: 20),

                  // Tampilkan teks 'Penyakit Terdeteksi' dan garis pemisah
                  Row(
                    children: [
                      const Text(
                        "Penyakit Terdeteksi",
                        style: AppTextStyles.manropeEight,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Divider(color: AppColors.darkCyan, thickness: 2),
                      ),
                    ],
                  ),

                  // Jarak antar komponen
                  const SizedBox(height: 14),

                  // Tampilkan daftar penyakit yang terdeteksi beserta detailnya
                  ...entries.asMap().entries.map((mapEntry) {
                    int index = mapEntry.key;
                    var entry = mapEntry.value;
                    final List<Map<String, dynamic>> items = entry.value;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Konfigurasi jumlah gambar crop berdasarkan lebar layar
                        int crossAxisCount = constraints.maxWidth < 360 ? 3 : 4;
                        const double gap = 16.0;
                        const double paddingCard = 32.0;

                        // Hitung ukuran kotak crop secara dinamis
                        double availableWidth =
                            constraints.maxWidth - paddingCard;
                        double dynamicBoxSize =
                            (availableWidth - (gap * (crossAxisCount - 1))) /
                            crossAxisCount;

                        // Batasi jumlah gambar crop yang ditampilkan
                        int maxVisible = crossAxisCount;
                        bool hasMore = items.length > maxVisible;
                        int displayCount = hasMore
                            ? maxVisible - 1
                            : items.length;

                        // Tampilkan gambar header hasil deteksi
                        List<Widget> cardContent = items
                            .take(displayCount)
                            .map<Widget>((detection) {
                              return CropPreview(
                                originalPath: header['path_gambar_potret'],
                                detection: detection,
                                size: dynamicBoxSize,
                              );
                            })
                            .toList();

                        // Jika ada kelebihan gambar crop, tampilkan indikator "+X"
                        if (hasMore) {
                          cardContent.add(
                            Container(
                              width: dynamicBoxSize,
                              height: dynamicBoxSize,
                              decoration: BoxDecoration(
                                color: AppColors.darkCyan.withAlpha(
                                  (0.75 * 255).toInt(),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.honeydew,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "+${items.length - displayCount}",
                                  style: AppTextStyles.poppinsFour,
                                ),
                              ),
                            ),
                          );
                        }

                        // Pemanggilan widget untuk menampilkan daftar penyakit yang terdeteksi beserta detailnya
                        return DetectionDiseaseCard(
                          title: entry.key,
                          onTap: () => Get.to(
                            () => EncyclopediaDetailPage(
                              diseaseId: entry.value.first['id_penyakit'],
                              originalImagePath: header['path_gambar_potret'],
                              detectionResults: details,
                            ),
                          ),
                          isLast: index == entries.length - 1,
                          children: [
                            Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: cardContent,
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
