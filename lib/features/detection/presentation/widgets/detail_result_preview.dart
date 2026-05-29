import 'package:flutter/material.dart';
import 'package:pepperlens_ai/core/constants/colors.dart';
import 'package:pepperlens_ai/core/constants/text_style.dart';
import 'package:pepperlens_ai/features/detection/presentation/widgets/crop_preview.dart';

// Widget untuk menampilkan preview crop hasil deteksi
class DetailResultPreview extends StatefulWidget {
  // Atribut yang diperlukan untuk menampilkan preview crop hasil deteksi
  final String title;
  final String originalPath;
  final List<Map<String, dynamic>> diseaseItems;
  final int initialIndex;

  // Instance dari DetailResultPreview dengan parameter wajib diisi
  const DetailResultPreview({
    super.key,
    required this.title,
    required this.originalPath,
    required this.diseaseItems,
    required this.initialIndex,
  });

  // Metode statis untuk menampilkan dialog preview crop hasil deteksi
  static void show(
    BuildContext context, {
    required String title,
    required String originalPath,
    required List<Map<String, dynamic>> diseaseItems,
    required int initialIndex,
  }) {
    showDialog(
      context: context,
      builder: (context) => DetailResultPreview(
        title: title,
        originalPath: originalPath,
        diseaseItems: diseaseItems,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<DetailResultPreview> createState() => _DetailResultPreviewState();
}

// Class untuk membangun tampilan dialog preview crop hasil deteksi
class _DetailResultPreviewState extends State<DetailResultPreview> {
  // Variabel penunjuk indeks gambar yang sedang aktif
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    // Inisialisasi indeks awal berdasarkan item yang diklik pengguna
    currentIndex = widget.initialIndex;
  }

  // Bangun tampilan dialog preview crop hasil deteksi
  @override
  Widget build(BuildContext context) {
    // Ambil data deteksi deteksi yang aktif
    final currentDetection = widget.diseaseItems[currentIndex];

    // Ambil nilai confidence
    double confidence = (currentDetection['confidence'] as num).toDouble();

    // Logika penentu pagination
    bool showPagination = widget.diseaseItems.length > 1;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.all(20),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.frostedMint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.honeydew, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol close
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.honeydew,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.darkCyan,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Jarak antar komponen
                const SizedBox(height: 4),

                // Nama penyakit
                Text(
                  widget.title,
                  style: AppTextStyles.manropeSeventeen,
                  textAlign: TextAlign.center,
                ),

                // Jarak antar komponen
                const SizedBox(height: 4),

                // Confidence
                Text(
                  "Tingkat Keyakinan: ${confidence.toStringAsFixed(0)}%",
                  style: AppTextStyles.manropeTen,
                ),

                // Jarak antar komponen
                const SizedBox(height: 12),

                // Crop preview
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CropPreview(
                      originalPath: widget.originalPath,
                      detection: currentDetection,
                      size: constraints.maxWidth,
                      showZoomIcon: false,
                    );
                  },
                ),

                // Jarak antar komponen
                const SizedBox(height: 12),

                // Pagination
                if (showPagination) ...[
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Prev button
                        Material(
                          color: AppColors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.honeydew,
                              size: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              setState(() {
                                currentIndex = currentIndex > 0
                                    ? currentIndex - 1
                                    : widget.diseaseItems.length - 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 50),
                        // Next button
                        Material(
                          color: AppColors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.honeydew,
                              size: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              setState(() {
                                currentIndex =
                                    currentIndex <
                                        widget.diseaseItems.length - 1
                                    ? currentIndex + 1
                                    : 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
